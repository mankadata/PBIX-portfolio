// =====================================================================
//  fnLogin
//  ---------------------------------------------------------------------
//  Exchanges an email and a password for a bearer token.
//
//  The FAOSTAT login endpoint takes a form-urlencoded POST body and
//  answers with an AuthenticationResult record. The token is valid for
//  60 minutes and there is no refresh endpoint, so fnFAOSTAT calls this
//  function again whenever it gets a 401.
//
//  CREDENTIALS
//  The two values below are placeholders. Fill them in locally and do
//  not commit the real ones. Use an account created only for this API,
//  with a password you do not use anywhere else: anything written here
//  is stored inside the .pbix file.
// =====================================================================

let
    Login = () as record =>
    let
        Email    = "<your-faostat-email>",
        Password = "<your-faostat-password>",

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
