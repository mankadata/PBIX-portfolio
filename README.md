# The World of Coffee — Power BI report

## Why I built this

I have been working with Power BI and with data for years. This project is an experiment. I wanted a pet portfolio that shows what I can do, but not one built from the usual BI elements and native visuals.
Many people can use Power BI at a basic level today. I wanted to show something that goes beyond drag-and-drop work.

If you work with it for years, sooner or later you notice that it has limits, and in real projects you have to do something about them. I have run into small gaps like this many times.
The native charts are good, and they get better with every update. However, gaps still exist, and they can stay with us for years. The Gantt chart is a good example. For a long time there was no native Gantt visual in Power BI, so anyone who needed one had to find an alternative. I watched countless videos from people in the field, showing how they work around the problem and what solutions they come up with. (October 2026.)

I think this is exactly where a hand-built visual starts to make sense: at the limits. 
So I asked myself. What if I use almost only hand-built visuals in this pet project? I wanted to see how far I could go with DAX as a vizualisation tool. Of course, you can download more visuals from AppSource. Still, I have to admit that I was not always happy with those either. And in some cases I would have had to pay a subscription just to get a chart without a watermark. And what if the company policy does not allow downloading them? Or what if I want to build the report according to the International Business Communication Standards (IBCS)? Which native charts can an HTML visual really replace?

---
A Power BI report built on FAOSTAT data. It shows where coffee is grown, where it is traded, and where the money in the chain ends up.
### ▶ [Open the live report](https://mankadata.github.io/PBIX-portfolio/)

Interactive. Click through the pages, hover the visuals, use the slicers. No download and no Power BI licence needed.

<!-- Optional, once you have a screenshot:
![The World of Coffee — cover](docs/screenshots/cover.png)
-->

<img width="1044" height="583" alt="image" src="https://github.com/user-attachments/assets/c4e2770f-b781-43f2-8fa6-6f2ae3d8d61f" />

---

<img width="1039" height="585" alt="image" src="https://github.com/user-attachments/assets/17701a0b-b6ca-44d6-9eeb-3a9ca95f4014" />


## The data

| | |
|---|---|
| **Source** | [FAOSTAT](https://www.fao.org/faostat/) REST API — `faostatservices.fao.org/api/v1` |
| **Domains** | `QCL` (crops and livestock production), `TCL` (crops and livestock trade) |
| **Item** | FAO item code `656` — coffee, green |
| **Period** | 2010–2024 |
| **Grain** | Country × year × element |

---

**Data loading** The data comes from the FAOSTAT REST API, not from an Excel file or a folder of CSVs. It is called from Power Query, and the logic is split into four parts. Config is a record that holds the endpoint, the item code and the year range in one place. If I want to point the report at a different items or a different period, there is only one place to touch. fnLogin exchanges an email and a password for a bearer token. Auth runs it once. fnFAOSTAT takes a domain and a list of element codes, and returns a typed table.
The token expires after 60 minutes, and the API has no separate refresh endpoint. So fnFAOSTAT checks the status code of the response: if it gets a 401, it logs in again and repeats the call once. 

**Semantic model** Two fact tables, **Production and Trade**, share the **Countries and Year dimensions**, and there are a few disconnected tables for the field parameters. The dimensions, however, come straight out of the API response, not from a maintained data warehouse.
The measures live in a _Measures table. I wrote them in **DAX query view**, with comments, so they can be read and reviewed like code.

[^note]:...

**Security and access** Workspace permissions and row-level security work the same way as in any other report: the HTML does not go around them. I did not set up row-level security in this project, because the data is public and there is no group of users I would need to separate from another. The point is that if it were needed, the HTML would not stand in the way.

**Publishing and refresh** The report is published to the Power BI Service. FAOSTAT tokens expire after 60 minutes, so a token cannot simply be stored — the solution is the re-login described above. The published version uses imported data.

**Theming** A custom theme JSON controls all the native visuals. The HTML visuals, on the other hand, have their own colour constants, and I keep the two in sync by hand. This is exactly the maintenance cost the next section is about.

---

## Layers legyen a cím szerintem, behind the HMTL vizuals

Mostanában sok poszt jelenik meg arról, hogy mennyire könnyű lett full HTML-dashboardot készíteni AI segítségével, és hogy ez talán a BI jövője, esetleg a Power BI kiváltója. És bevallom, szerintem is könnyebb lett: ma már nem kell mélyen érteni a HTML-hez, a CSS-hez vagy a JavaScripthez ahhoz, hogy látványos vizualizáció szülessen. (a hibákat, bugokat viszont észre kell venni, és jól kell promtolni, hogy azt kapjuk vissza amit szeretnénk, de ez egy más kérdés)
Azonban ami a képernyőn látszik, az a jéghegy csúcsa: modern design, kártyák, a színek. 
Ami nem látszik: az adatmodell, a hozzáférés-kezelés, a biztonság, a governance, a frissítés, na meg a karbantartás. Sőt mitöbb ezek teszik ki a munkánk és a power BI kardinális részét. 
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

The report is published as a read-only public embed. The visuals, the measures and the layout are the work. I am happy for people to look at all of it, but not to copy it wholesale.

If you want to talk about how a particular part is built, ask me and I will walk you through it.

---

**Mariann M.** · [LinkedIn](https://www.linkedin.com/in/mmariann/)

**Budapest, Hungary · 2026** 
