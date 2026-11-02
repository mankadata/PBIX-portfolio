
// =====================================================================
//  Config
//  ---------------------------------------------------------------------
//  Parameters used (Home -> Manage Parameters):
//    p_StartYear   Whole Number   2010
//    p_EndYear     Whole Number   2024
//    p_ItemCode    Text           656      
//    p_ItemLabel   Text           Coffee
// =====================================================================

let
    Config = [
        // A URL built from a parameter is treated as a dynamic data source by the Service, which blocks scheduled refresh.
        BaseUrl   = "https://faostatservices.fao.org",
        ApiRoot   = "api/v1",
        Language  = "en",
        DataPath  = "data",
        AreaCs    = "M49",         

        // from parameters, so they can be changed in Desktop and in the Service without editing any code
        StartYear = p_StartYear,
        EndYear   = p_EndYear,
        ItemCode  = p_ItemCode,    
        ItemLabel = p_ItemLabel,

        ExcludedAreas = {}
    ]
in
    Config
