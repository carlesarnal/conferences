# Public portfolio source

`portfolio.json` is the reviewed public content for https://carlesarnal.github.io/.
The website imports **only this file**, never the review queue, proposals, travel
notes or private tracker. Repository descriptions and topic summaries are edited
for public readers rather than generated from confidential review material.

## Updating the site

1. Edit `portfolio.json`. Add a delivered talk only with a recording or explicit
   speaker confirmation. Use `title_kind: topic` when the exact historic title is
   not established; do not substitute a revised CFP title.
2. Run `python3 scripts/export_portfolio.py --output /tmp/portfolio.json`.
3. Commit and push this repository. The website checks this file daily and on
   manual workflow dispatch, validates it, then builds and deploys GitHub Pages.
4. For an immediate update, run the website's **Publish portfolio** workflow.

Corrections supplied October 23, 2026: Data Saturday Oslo and API Days Amsterdam
were delivered. JavaZone, Community Over Code Asia and FOST Munich were not
delivered and are intentionally absent. Paris is accepted/upcoming, not delivered.
The site hides upcoming entries after their date; it never promotes them into
speaking history automatically.

Career, education, language and patent information comes from the LinkedIn export
supplied by Carles in this conversation. Patent titles are listed without claiming
grant status or numbers, which were not supplied. The public contact is Gmail;
the supplied mobile number is intentionally not included in the public data.
