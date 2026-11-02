# The World of Coffee 
## Power BI report

![Power BI](https://img.shields.io/badge/Power%20BI-F2C811?style=flat&logo=powerbi&logoColor=black)
![DAX](https://img.shields.io/badge/DAX-1B1613?style=flat)
![Power Query M](https://img.shields.io/badge/Power%20Query%20M-4A332A?style=flat)
![REST API](https://img.shields.io/badge/REST%20API-5F7154?style=flat)
![HTML](https://img.shields.io/badge/HTML-E34F26?style=flat&logo=html5&logoColor=white)
![CSS](https://img.shields.io/badge/CSS-1572B6?style=flat&logo=css3&logoColor=white)
![SVG](https://img.shields.io/badge/SVG-7D8F6E?style=flat)
![JSON](https://img.shields.io/badge/JSON-E4DCCB?style=flat&logoColor=black)

### Why I built this

I have been working with Power BI and with data for years. This project is an experiment. I wanted a pet portfolio that shows what I can do, but not one built from the usual BI elements and native visuals.<br>
I wanted to show something that goes beyond drag-and-drop work.

If you work with it for years, sooner or later you notice that it has limits, and in real projects you have to do something about them. I have run into small gaps like this many times.<br>
The native charts are good, and they get better with every update. The Gantt chart is a good example. For a long time there was no native Gantt visual in Power BI, so anyone who needed one had to find an alternative. 
I watched countless videos from people in the field, showing how they work around the problem and what solutions they come up with. (October 2026.)

I think this is exactly where a hand-built visual starts to make sense: at the limits. <br>
So I asked myself. What if I use almost only hand-built visuals in this pet project? I wanted to see how far I could go with DAX as a vizualisation tool. Of course, you can download more visuals from AppSource. <br>
*(Still, I have to admit that I was not always happy with those either. And in some cases I would have had to pay a subscription just to get a chart without a watermark.)* <br>
And what if the company policy does not allow downloading them? <br>
Or what if I want to build the report according to the International Business Communication Standards (IBCS)? <br>
Which native charts can an HTML visual really replace?

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


### The data

| | |
|---|---|
| **Source** | [FAOSTAT](https://www.fao.org/faostat/) REST API — `faostatservices.fao.org/api/` |
| **Domains** | `QCL` (crops and livestock production), `TCL` (crops and livestock trade) |
| **Item** | FAO item code `656` — coffee, green |
| **Period** | 2010–2024 |
| **Grain** | Country × year × element |

---

**Data loading** The data comes from the FAOSTAT REST API, not from an Excel file or a folder of CSVs. It is called from Power Query, and the logic is split into four parts. <br>
Config is a record that holds the endpoint, the item code and the year range in one place. If I want to point the report at a different items or a different period, there is only one place to touch.<br> 
fnLogin exchanges an email and a password for a bearer token. <br>
Auth runs it once. fnFAOSTAT takes a domain and a list of element codes, and returns a typed table.<br>
The token expires after 60 minutes, and the API has no separate refresh endpoint. So fnFAOSTAT checks the status code of the response: if it gets a 401, it logs in again and repeats the call once. <br>

**Semantic model** Two fact tables, **Production and Trade**, share the **Countries and Year dimensions**, and there are a few disconnected tables for the field parameters. The dimensions, however, come straight out of the API response, not from a maintained data warehouse.
The measures live in a _Measures table. I wrote them in **DAX query view**, with comments, so they can be read and reviewed like code.

> <sub>In Kimball's dimensional modelling, fact tables hold events and measurements, many rows, mostly numeric values, while dimension tables hold the descriptive attributes we filter and group by. Microsoft's own guidance recommends this as the default modelling approach for Power BI.<br>
In a prod environment this layer would not be built inside the report. There, the medallion architecture is the usual pattern, and its point is that data does not travel through one big transformation but through clearly separated stations. Raw files land in the landing layer.<br>
Bronze holds raw data in a consistent format, silver holds cleaned and typed data, and gold holds the aggregated, report-ready model.<br>
In dbt the same idea appears as staging, intermediate and mart.<br>
Staging only cleans, renames and types, with no business logic, and stays one-to-one with the source tables.<br>
Intermediate joins the sources and brings in the business rules. This is where an order meets its customer and its product.<br>
Mart is the report-ready layer: dimension and fact tables, usually materialised as physical tables, often named with `dim_` and `fct_` prefixes.<br>
Exactly which dbt layer maps to which medallion level varies a little from team to team, but the logic is the same everywhere.<br>
> For a pet project built around visuals, setting all of this up would be overkill. The difference is still worth seeing. </sub>

**Security and access** Workspace permissions and row-level security work the same way as in any other report: the HTML does not go around them. I did not set up row-level security in this project, because the data is public and there is no group of users I would need to separate from another. The point is that if it were needed, the HTML would not stand in the way.

**Publishing and refresh** The report is published to the Power BI Service. FAOSTAT tokens expire after 60 minutes, so a token cannot simply be stored, the solution is the re-login described above. <br>
The published version uses imported data.

**Theming** A custom theme JSON controls all the native visuals. The HTML visuals, on the other hand, have their own colour constants, and I keep the two in sync by hand.

---

### Layers behind the HTML dashboard

There are a lot of posts these days about how easy it has become to build a full HTML dashboard with AI, and how this might be the future of BI. And it is true: you no longer need a deep understanding of HTML, CSS or JavaScript to produce a good-looking visual. *(You do have to write a good prompt to get back what you actually wanted. But that is another question.)*<br>
My problem with a full HTML dashboard is not how it looks. It is that you cannot see what sits behind it.<br>
What you see on the screen is the top of the iceberg: the modern design, the cards, the colours. But, in this case, if you build a full HTML dashboard with AI, you will not see is the data model, access management, security, governance, refresh and maintenance. <br>
Those layers are the larger part of our work, and the larger part of Power BI itself. The job is not only beautiful charts.<br>

---

### What HTML visuals do not solve

Custom HTML visuals are popular right now, and the screenshots look great. People talk much less about the limits.

**They cannot filter the report back.** An HTML visual gets filters, but it cannot send one. If you click a bar in the waffle chart, nothing else on the page changes. The more of the page you give to HTML, the less the report works as a tool you can explore, and the more it becomes a poster. <br>
This is the strongest argument against the approach.

**Accessibility is almost completely missing.** Screen readers cannot read inside the visual’s iframe, and you cannot move through it with the keyboard. <br>
The alt text measures in this model help a little, but they do not fix it. In the public sector, or in a regulated company, this alone can stop the whole idea.

**Certification, export and subscriptions.** A visual that draws HTML cannot be certified in AppSource. To be certified, a visual must not write raw input into the page, and must not call out to the internet. That is exactly what an HTML visual does.<br>
Certification is what makes two things work: export to PowerPoint, and the image that goes out with an email subscription. Neither works here.<br>
An administrator can also allow certified visuals only, or turn off custom visuals completely. Then the report does not run at all.

**Someone has to maintain it, and that means documenting it.** There is no formatting pane. With a native visual the settings are visible to anyone who opens it; with a visual drawn in DAX, nothing is visible anywhere. <br>
The next person who opens this file has to read several hundred lines of HTML, CSS and SVG inside DAX text, so I wrote comments throughout. That person also has to be an advanced DAX reader and a BI developer at the same time. <br>
If the work is ever going to be handed over, it has to be documented well, and AI can help you with that part, which I think is a fair use of it.

> <sub> Documentation matters everywhere, not only here. I once took over a report that did not contain a single line of HTML, and it still felt like forever before I understood what was happening in it, and why it had been built that way. There was nothing written down, not even the stakeholder requests. Documentation is not an extra, it is a basic condition.</sub>

**Performance and debugging.** If a text concatenation breaks, you get an empty box, not an error message.

---

### Why there is no .pbix here

The report is published as a read-only public embed. The visuals, the measures and the layout are the work. <br>

I am happy for people to look at all of it, but not to copy it wholesale.<br>
If you want to talk about how a particular part is built, ask me and I will walk you through it.

---

**Mariann M.** · [LinkedIn](https://www.linkedin.com/in/mmariann/)

Budapest, Hungary

