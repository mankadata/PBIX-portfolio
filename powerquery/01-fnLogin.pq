// =====================================================================
//  fnLogin
//  ---------------------------------------------------------------------
//  Exchanges an email and a password for a bearer token.
//  The token is valid for 60 minutes and there is no refresh endpoint, so fnFAOSTAT calls this function again whenever it gets a 401.
//
// =====================================================================

let
    Login = () as record =>
    let
        Email    = "<email>",
        Password = "<***** password>",

        Endpoint = "https://faostatservices.fao.org/api/v1/auth/login",

        Body =
            "username=" & Uri.EscapeDataString( Email )
            & "&password=" & Uri.EscapeDataString( Password ),

        Response = Web.Contents(
            Endpoint,
            [
                Headers = [ #"Content-Type" = "application/x-www-form-urlencoded" ],
                Content = Text.ToBinary( Body ),

                // handle the auth failures ourselves so the message is useful
                ManualStatusHandling = { 400, 401 }
            ]
        ),

        Status = Value.Metadata( Response )[Response.Status]?,

        Parsed =
            if Status = 400 or Status = 401 then
                error Error.Record(
                    "LoginFailed",
                    "Login failed (" & Text.From( Status ) & "). Check the Email and Password values.",
                    Text.FromBinary( Response )
                )
            else
                Json.Document( Response )[AuthenticationResult]
    in
        [
            AccessToken = Parsed[AccessToken],
            ExpiresIn   = Parsed[ExpiresIn],
            ObtainedAt  = DateTimeZone.UtcNow()
        ]
in
    Login
