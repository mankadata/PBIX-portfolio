# Power Query — the FAOSTAT API layer

These are the four queries that fetch the data. They are the part of the model I am happy to share: the DAX measures that draw the HTML visuals are not in this repository.

| File | Query | What it does |
|---|---|---|
| `00-Config.pq` | `Config` | One record with the endpoint, the item code and the year range. The only place to edit when pointing the report at a different item or period. |
| `01-fnLogin.pq` | `fnLogin` | Exchanges an email and a password for a bearer token. |
| `02-Auth.pq` | `Auth` | Runs `fnLogin` once and holds the result. |
| `03-fnFAOSTAT.pq` | `fnFAOSTAT` | Takes a domain and a list of element codes, returns a typed table. |

The two fact tables are then one line each:

```m
Production = fnFAOSTAT( "QCL", { 5510, 5312, 5412 } )
Trade      = fnFAOSTAT( "TCL", { 5910, 5922, 5610 } )
```

### Credentials

`01-fnLogin.pq` contains placeholders, not real credentials:

```m
Email    = "<email>",
Password = "<**** password>",
```

### Three things worth knowing

**The token expires after 60 minutes, and the API has no refresh endpoint.** `fnFAOSTAT` checks the status code of the response: a 401 means log in again and retry once. <br>
**The first argument of `Web.Contents` has to be a literal string.** The variable part of the path goes into `RelativePath`. Build the whole URL by concatenation instead, and the Power BI Service classifies it as a dynamic data source and refuses to schedule a refresh. <br>
**Numbers are parsed with the `"en-US"` culture.** On a machine with a European locale, the decimal point in the response would otherwise be read as a thousands separator — and a yield of 0.90 t/ha would quietly become 90. <br>

### How to use these in Power BI Desktop

1. **Home → Transform data** to open Power Query
2. **New Source → Blank Query** for each file, in the order above
3. **Home → Advanced Editor**, paste the file contents, rename the query to the name in the table
4. On `Auth`, right-click and clear **Enable load**
5. Fill in your credentials in `fnLogin`
6. Set the data source authentication to **Anonymous** — the token travels in the header, not through Power Query's own credential layer
