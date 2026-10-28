# The World of Coffee — Power BI report

A Power BI report built on FAOSTAT data. It shows where coffee is grown, where it is traded, and where the money in the chain ends up.

### ▶ [Open the live report]((https://mankadata.github.io/PBIX-portfolio/))

Interactive — click through the pages, hover the visuals, use the slicers. No download and no Power BI licence needed.

<!-- Optional, once you have a screenshot:
![The World of Coffee — cover](docs/screenshots/cover.png)
-->

---

## Why I built this

I have worked with Power BI for five years. This is a pet project, not client work. I built it to widen my own skill set, to add something to what I already know how to do.

Concretely, I wanted to go past the point where drag-and-drop runs out, and see what is under it. How far can you push DAX as a drawing language? How much design control do you really have inside Power BI? And just as important: where does this approach stop being a good idea?

The visuals on the Production and Trade pages are HTML and SVG, generated in DAX. The map is a native visual. That split was a choice, and the rest of this README explains it.

---

## The data

| | |
|---|---|
| **Source** | [FAOSTAT](https://www.fao.org/faostat/) REST API — `faostatservices.fao.org/api/v1` |
| **Domains** | `QCL` (crops and livestock production), `TCL` (crops and livestock trade) |
| **Item** | FAO item code `656` — coffee, green |
| **Period** | 2010–2024 |
| **Grain** | Country × year × element |

### One thing worth knowing about FAOSTAT

The API returns aggregate rows alongside country rows: *World*, *Africa*, *European Union (27)*, *Least Developed Countries*, *Small Island Developing States*, and others. They arrive in the same response, in the same shape, with the same column names.

Left in, they are counted twice — or five times, depending on how many aggregates a country belongs to. Every total in the report would run **4 to 7 times too high**, and nothing about the output would look obviously wrong.

I found it because the same country showed 33.2% in one visual and 4.6% in another on the same page. The aggregates are filtered out in Power Query, against the country list from the FAOSTAT country endpoint rather than against a hand-typed list of names.

---

## What is still Power BI

People often say that HTML dashboards bring back all the problems a BI platform solves: data modelling, access, security, governance, refresh, distribution. That is true when the HTML file is the product. It is not true here, because the HTML is only the last drawing step.

**Data loading.** The data comes from the FAOSTAT REST API, called from Power Query. A `Config` record holds the endpoint, the item code, the year range and the excluded aggregates in one place; `fnLogin` exchanges credentials for a bearer token; `fnFAOSTAT` takes a domain and a list of element codes and returns a typed table. Credentials are never committed to this repository.

**Semantic model.** A star schema: two fact tables (Production, Trade) with shared Countries and Year dimensions, plus disconnected slicer tables for the field parameters. Measures live in a `_Measures` table and are written in **DAX query view**, with comments, so they can be read and reviewed as code.

**Security and access.** Workspace permissions and row-level security work the same way as in any other report. The HTML does not go around them.

**Publishing and refresh.** The report is published to the Power BI Service. FAOSTAT access tokens expire after 60 minutes, which rules out caching one in a parameter — so `fnFAOSTAT` calls `fnLogin` itself and gets a fresh token on every run. Scheduled refresh works. The published version uses imported data.

**Theming.** A custom theme JSON controls all native visuals. The HTML visuals keep their own colour constants, and I keep them in sync by hand — which is exactly the maintenance cost I describe in the next section.

---

## What HTML visuals do not solve

Custom HTML visuals are popular right now, and the screenshots look great. People talk much less about the limits. Here they are, because they apply to this report too, and I knew about them when I started.

**They cannot filter the report back.** An HTML visual gets filters, but it cannot send one. If you click a bar in the waffle chart, nothing else on the page changes. The more of the page you give to HTML, the less the report works as a tool you can explore, and the more it becomes a poster. This is the strongest argument against the approach. It is also why the map here stayed native.

**Accessibility is basically missing.** Screen readers cannot read inside the visual's iframe, and you cannot move through it with the keyboard. The alt text measures in this model help a little, but they do not fix it. In the public sector or in regulated companies this alone can block the whole idea.

**Certification, export and subscriptions.** Many HTML content visuals are not certified in AppSource. Without certification, PDF export, email subscriptions and server-side rendering stop working, and some companies block these visuals completely. Worth checking before you start.

**Someone has to maintain it later.** There is no formatting pane and no theme support. Changing the accent colour in this report meant replacing **77 distinct hex values across 234 occurrences** in the measures. The next person who opens this file needs to read several hundred lines of CSS and SVG inside DAX text — not just write measures, but read them, in DAX query view.

**You have to document it.** The drawing logic is invisible in the Power BI interface, so the code must explain itself. I used AI help for part of that documentation. I think that is a fair use of it: it writes the explanation around code where I made the decisions.

**Performance and debugging.** Every HTML visual is an iframe with its own render cycle. There is no developer console. If a text concatenation breaks, you get an empty box, not an error message.

---

## Why there is no .pbix here

The report is published as a read-only public embed instead. The visuals, the measures and the layout are the work; I am happy for people to look at all of it and not to fork it wholesale.

If you want to talk about how a particular piece is built, ask me — I will walk you through it.

---

**Mariann Matyóka** · [LinkedIn](https://www.linkedin.com/in/mmariann/)
