# MSP for Claude Code

An MSP owner's service and billing desk: clients, agreements, devices, tickets, time, projects and privacy incident records in a database you own. Built by Enterprise DNA. MIT licence.

| Do it yourself | We customise it | We run it for you |
| --- | --- | --- |
| Free source. Install and follow the quick start. | Your agreement rules, fields, HaloPSA mapping, connections, front end or different stack. | Installed and operated through Omni by Enterprise DNA. One setup fee, then a retainer. |

[Talk to Sam](https://enterprisedna.co/omni/book/?offer=replace-software&utm_campaign=halopsa&utm_medium=readme) · [Instead of HaloPSA](https://enterprisedna.co/omni/instead-of/halopsa?utm_source=github&utm_medium=readme&utm_campaign=halopsa)

Works with Claude Code, Codex, OpenCode or Cursor. Read AGENTS.md and CLAUDE.md.

## Quick start

```bash
git clone https://github.com/Enterprise-DNA-OS/msp-for-claude-code.git
cd msp-for-claude-code
npm install
npm run demo
npm run msp -- weekly-review
npm run view
npm run docs
```

Node 20 or newer. Embedded PGlite needs no database installation. Set DATABASE_URL for Postgres using the same migrations. Dates and billing periods use UTC. The demo is fictional: three NZ and AU clients, a failed restore, an unassigned access review, unapproved time, an overdue renewal and missing privacy evidence. Seed is idempotent and does not overwrite existing records.

For real data choose a fresh DATA_DIR or empty database, run npm run migrate and do not seed. Credentials and generated records stay out of Git. Source is free. Agent subscriptions, hosting, connections and support have separate costs.

[Halo's pricing page](https://www.usehalo.com/pricing), checked 28 September 2026, displays a UK rate of GBP 66 per agent per month billed annually. That rate annualises to GBP 792 per agent, before bespoke onboarding and any quote-specific adjustments. The page supports other currencies and licence quantities. Halo includes its modules in the one price. This is not a verified all-in customer invoice or a claim that Halo lacks reporting.

## The weekly MSP desk

- `/dispatch`: Prioritise open work by priority and resolution deadline. Waiting tickets still count against their absolute deadlines.
- `/sla-watch`: Review missed first-response and resolution deadlines. Separate open work from historical breaches. The base has no business calendar or automatic pause rules.
- `/unbilled-time`: Review time not included in a saved billing proposal. Separate approved, pending and nonbillable time. Never sum currencies.
- `/billing-preview`: Read agreements and unbilled time first. Preview the specified month. Uses current active device or licensed user quantities, no proration, no tax or pass-through licences. Confirm quantities represent the chosen period. Partial-month agreements are omitted and require separate review.
- `/renewals-due`: Review active agreements with a renewal review date in the next 60 days or overdue. This date is an operator policy.
- `/device-review`: Review active devices with expired warranty or missing or older-than-seven-day observations. Missing warranty dates remain unknown.
- `/projects`: Compare recorded project minutes against the budget and due date. Negative remaining time means over budget. This is time consumption, not monetary profit.
- `/client-review`: Prepare client discussions from open work, breached service deadlines, unbilled minutes and device concerns. Historical breaches include closed tickets.
- `/capacity`: Compare current UTC-week logged minutes against the configured technician capacity. This is logged time, not a scheduling forecast.
- `/compliance`: Read docs/compliance.md first. Present missing evidence and the named rule. A person decides applicable duties and exceptions. Never certify compliance or send a notification.
- `/weekly-review`: Run attention, unbilled-time, renewals-due, device-review and compliance. Produce a Monday plan naming client, finding, evidence and owner. Do not combine currencies or invent missing commitments.

Every route accepts --json. Read operations print aligned text by default. Relationships accept full UUIDs, ID prefixes and case-insensitive names. Ambiguity lists candidates and exits 1. Run npm run msp -- help for fields and syntax. Add, update and log accept one JSON object, quoted for your shell. All record writes produce audit history.

## Commercial and service rules

- One current agreement per client. Monthly base uses active device count, client licensed_users, or one flat unit. Included minutes are one monthly client allowance. Overage is approved billable minutes above that allowance, multiplied by the hourly cents rate and rounded once to the nearest cent.
- All amounts exclude tax. No foreign exchange totals. No tax invoice, payment, credit, supplier licence or pass-through charge processing. This is a proposal for review before invoicing in your accounting system.
- Billing takes a YYYY-MM UTC period and requires an active agreement covering that whole month. Partial months need reviewed proration. Quantities and rates are current at preview time, not reconstructed history: verify them for the period. Preview includes pending count but bills only approved entries. Snapshot refuses pending billable entries.
- One saved proposal per client and period. It freezes quantity, currency, allowance, time and amounts. Billed time cannot be edited. Late time remains on the unbilled desk and needs a separately reviewed adjustment. There is no automatic invoice posting or hidden rebilling.
- Service deadlines are explicit instants. Response and resolution breaches compare recorded actual completion or now against those deadlines. Closed breaches remain visible. Waiting does not pause the clock. Business calendars, holiday logic and integration-driven updates require custom configuration.
- Capacity compares logged minutes this UTC week against configured capacity. Project budget is in minutes. Neither is a revenue or profit forecast. Device observations are entered facts, not live monitoring. Audit records are editable by database administrators and are not tamper proof.

## Documents and views

npm run docs writes service review drafts, renewal reviews, incident reviews and billing proposals as branded HTML. Billing proposals appear after a billing snapshot is saved. npm run view writes service, commercial and risk dashboards. Change business name, colours and logo path in brand.json. Draft discussions stay in drafts. A person checks and shares them.

Read [the privacy record checks](docs/compliance.md). Serious harm and legal duties require the responsible person's decision. The software neither certifies compliance nor sends notifications. AU incidents are routed for officer review without an invented automatic legal deadline.

## Ten questions across your MSP

Halo supports custom reports. These are questions this build answers today, not unsupported claims that Halo cannot answer them.

1. Which agreements need a renewal discussion in the next 60 days? (`renewals-due`)
2. Which open tickets have missed a recorded service deadline? (`sla-watch`)
3. Which tickets have had no activity for three days? (`attention`)
4. Which technicians have unassigned or urgent work in their queue? (`dispatch`)
5. Which billable entries are still waiting for approval? (`unbilled-time`)
6. Which client has unbilled work and overdue device checks? (`client-review`)
7. Which projects are late or over their time budget? (`projects`)
8. Which active devices have old observations or expired warranties? (`device-review`)
9. What does this month look like under our current agreement quantities? (`billing-preview YYYY-MM`)
10. Which privacy incidents lack assessment or notification evidence? (`compliance`)

## Your first hour: ten things to ask for

1. Put our business name and logo on service reviews.
2. Add our clients and their reporting currency.
3. Map our actual Halo export headings.
4. Enter our device or user agreement quantities.
5. Set our included time and hourly overage rates.
6. Add our renewal review dates.
7. Record our contractual service deadlines.
8. Add our technician capacity and project budgets.
9. Write our Monday review in our own words.
10. Add a view of clients needing a commercial discussion.

Use /customise for changes with migrations and tests. Use /new-view for read-only reports.

## Bring your HaloPSA records

[The replacement guide](docs/replace-halopsa.md) covers report export, explicit mapping, one-command import, preview and reconciliation. The fixture headers are illustrative. Unknown headings or missing references fail the whole import. Exact repeats skip, and changed source rows stop for review. The importer preserves raw rows and mappings. It does not migrate attachments, mail, rich action histories, historical invoice allocations or monitoring connections.

[Why no front end](docs/why-no-front-end.md) describes the fit. This base is an owner's working desk. A dispatcher portal, mobile capture, live mail intake and remote monitoring are separately scoped connections. Keep existing capture until the replacement is tested.

## Verification and operations

npm test uses a temporary database and exercises every CLI route, repeated seed, service findings, billing arithmetic and frozen proposals, name ambiguity, cross-client checks, CSV parsing, import preview and rollback, export, HTML escaping and process exit codes. CI runs PGlite on Windows and Linux and Postgres on Linux. TEST_DATABASE_URL must be an empty disposable test database. A local Linux pass is not proof the hosted CI has run.

Export includes every entity plus billing, audit and import history in JSON and CSV. It is an interchange snapshot, not an automatic restore. Back up the database and evidence files and test restoration. Use one MSP per database. Before shared use configure least-privilege roles, access review and backups. Do not give clients direct database access. No tenant isolation or credential storage is provided.
