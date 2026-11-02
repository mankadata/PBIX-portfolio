// =====================================================================
//  Auth
//  ---------------------------------------------------------------------
//  Runs fnLogin once and holds the result for the session.
//
//  fnFAOSTAT takes its first token from here. If that token has expired,
//  the call comes back 401 and fnFAOSTAT logs in again on its own, so
//  this query does not need to know anything about expiry.
// =====================================================================

let
    Auth = fnLogin()
in
    Auth
