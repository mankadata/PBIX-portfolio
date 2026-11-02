// =====================================================================
//  fnFAOSTAT
//  ---------------------------------------------------------------------
//  Takes a FAOSTAT domain and a list of element codes, and returns a typed table.
//
//    fnFAOSTAT( "QCL", { 5510, 5312, 5412 } )   -> production
//    fnFAOSTAT( "TCL", { 5910, 5922, 5610 } )   -> trade
//
//  Notes on the parts that are not obvious:
//  * The first argument of Web.Contents is a literal string, and the
//    variable part sits in RelativePath. Build the whole URL by
//    concatenation instead and the Power BI Service treats it as a
//    dynamic data source, which blocks scheduled refresh.
//
//  * Tokens last 60 minutes and there is no refresh endpoint. So the
//    response status is checked by hand: a 401 means log in again.
//
//  * Numbers are parsed with the "en-US" culture. On a machine with a
//    European locale the decimal point would otherwise be read as a
//    thousands separator, and 0.90 t/ha would silently become 90.
//
//  * TypeMap is filtered against the columns that are actually present,
//    so a response missing an optional column does not break the query.
// =====================================================================

let
    fnFAOSTAT = (Domain as text, ElementCodes as list) as table =>
        let
            C = Config,

            YearList =
                Text.Combine(
                    List.Transform( { C[StartYear] .. C[EndYear] }, Text.From ),
                    ","
                ),

            // ---- one API call, with a given token ----------------------
            CallApi = (Token as text) as binary =>
                let
                    Path =
                        C[ApiRoot] & "/" & C[Language] & "/" & C[DataPath] & "/" & Domain,

                    Response = Web.Contents(
                        "https://faostatservices.fao.org",
                        [
                            RelativePath = Path,

                            Query =
                            [
                                item        = C[ItemCode],
                                area_cs     = C[AreaCs],
                                year        = YearList,
                                show_codes  = "true",
                                show_unit   = "true",
                                show_flags  = "true",
                                show_notes  = "true",
                                null_values = "false",
                                output_type = "csv",
                                limit       = "-1"
                            ],

                            Headers =
                            [
                                #"Authorization" = "Bearer " & Token,
                                #"Accept"        = "text/csv, */*"
                            ],

                            ManualStatusHandling = { 401, 403, 429 },
                            Timeout              = #duration( 0, 0, 10, 0 )
                        ]
                    )
                in
                    Response,

            FirstTry  = CallApi( Auth[AccessToken] ),
            FirstStat = Value.Metadata( FirstTry )[Response.Status]?,

            // ---- the token may have expired mid-run --------------------
            Guarded =
                if FirstStat = 401 then
                    let
                        FreshAuth  = fnLogin(),
                        SecondTry  = CallApi( FreshAuth[AccessToken] ),
                        SecondStat = Value.Metadata( SecondTry )[Response.Status]?
                    in
                        if SecondStat = 401 then
                            error Error.Record(
                                "LoginFailed",
                                "401: the token is still rejected after logging in again.",
                                "Check the Email and Password values in fnLogin."
                            )
                        else
                            SecondTry

                else if FirstStat = 403 then
                    error Error.Record(
                        "NoAccessToDomain",
                        "403: the token is valid but has no access to the " & Domain & " domain.",
                        "Check on the developer portal whether the account can reach this domain."
                    )

                else if FirstStat = 429 then
                    error Error.Record(
                        "RateLimited",
                        "429: too many requests.",
                        "Wait a few minutes and try again."
                    )

                else
                    FirstTry,

            // ---- CSV -> table ------------------------------------------
            Source =
                Csv.Document(
                    Guarded,
                    [ Delimiter = ",", Encoding = 65001, QuoteStyle = QuoteStyle.Csv ]
                ),

            Promoted = Table.PromoteHeaders( Source, [ PromoteAllScalars = true ] ),

            // ---- numeric columns, parsed with an explicit culture -------
            NumCols    = { "Area Code (M49)", "Element Code", "Year Code", "Year", "Value" },
            PresentNum = List.Select( NumCols, each List.Contains( Table.ColumnNames( Promoted ), _ ) ),

            SafeNum =
                Table.TransformColumns(
                    Promoted,
                    List.Transform(
                        PresentNum,
                        each { _, (v) =>
                            try Number.From( Text.Select( Text.From( v ), { "0".."9", ".", "-" } ), "en-US" )
                            otherwise null }
                    ),
                    null,
                    MissingField.Ignore
                ),

            // ---- types, applied only to the columns that exist ----------
            TypeMap =
                {
                    { "Domain Code",      type text },  { "Domain",           type text },
                    { "Area Code (M49)",  Int64.Type }, { "Area",             type text },
                    { "Element Code",     Int64.Type }, { "Element",          type text },
                    { "Item Code",        Int64.Type }, { "Item",             type text },
                    { "Year Code",        Int64.Type }, { "Year",             Int64.Type },
                    { "Unit",             type text },  { "Value",            type number },
                    { "Flag",             type text },  { "Flag Description", type text },
                    { "Note",             type text }
                },

            ExistingCols = Table.ColumnNames( SafeNum ),
            Applicable   = List.Select( TypeMap, each List.Contains( ExistingCols, _{0} ) ),
            Typed        = Table.TransformColumnTypes( SafeNum, Applicable, "en-US" ),

            KeepElements =
                Table.SelectRows( Typed, each List.Contains( ElementCodes, [Element Code] ) ),

            NoDoubleCount =
                Table.SelectRows(
                    KeepElements,
                    each not List.Contains( C[ExcludedAreas], [Area] )
                )
        in
            NoDoubleCount
in
    fnFAOSTAT
