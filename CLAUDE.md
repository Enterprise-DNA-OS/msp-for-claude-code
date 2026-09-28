# MSP for Claude Code

For an MSP owner reviewing service delivery, agreements, work logs and client risk. Configure business_name in brand.json. Read the relevant command recipe before running it.

## Routes

- `/clients`: Read each client, currency, licensed user count and next review date. Run `npm run msp -- clients --json`.
- `/technicians`: Read technicians and their configured weekly capacity. Run `npm run msp -- technicians --json`.
- `/agreements`: Review current agreement basis, quantity, monthly allowance and hourly overage rate. Rates are cents excluding tax. Run `npm run msp -- agreements --json`.
- `/devices`: Review devices, ownership, warranty and the last recorded observation. These are entered records, not live monitoring. Run `npm run msp -- devices --json`.
- `/tickets`: Read ticket priority, assigned technician and recorded service deadlines, including closed-ticket breaches. Run `npm run msp -- tickets --json`.
- `/dispatch`: Prioritise open work by priority and resolution deadline. Waiting tickets still count against their absolute deadlines. Run `npm run msp -- dispatch --json`.
- `/sla-watch`: Review missed first-response and resolution deadlines. Separate open work from historical breaches. The base has no business calendar or automatic pause rules. Run `npm run msp -- sla-watch --json`.
- `/unbilled-time`: Review time not included in a saved billing proposal. Separate approved, pending and nonbillable time. Never sum currencies. Run `npm run msp -- unbilled-time --json`.
- `/renewals-due`: Review active agreements with a renewal review date in the next 60 days or overdue. This date is an operator policy. Run `npm run msp -- renewals-due --json`.
- `/device-review`: Review active devices with expired warranty or missing or older-than-seven-day observations. Missing warranty dates remain unknown. Run `npm run msp -- device-review --json`.
- `/projects`: Compare recorded project minutes against the budget and due date. Negative remaining time means over budget. This is time consumption, not monetary profit. Run `npm run msp -- projects --json`.
- `/client-review`: Prepare client discussions from open work, breached service deadlines, unbilled minutes and device concerns. Historical breaches include closed tickets. Run `npm run msp -- client-review --json`.
- `/capacity`: Compare current UTC-week logged minutes against the configured technician capacity. This is logged time, not a scheduling forecast. Run `npm run msp -- capacity --json`.
- `/incidents`: Read the incident summary and assessment before interpreting a finding. Do not put breached files or credentials in the record. Run `npm run msp -- incidents --json`.
- `/compliance`: Read docs/compliance.md first. Present missing evidence and the named rule. A person decides applicable duties and exceptions. Never certify compliance or send a notification. Run `npm run msp -- compliance --json`.
- `/billing-runs`: Read saved billing proposals. These are frozen calculations, not tax invoices or payments. Run `npm run msp -- billing-runs --json`.
- `/audit`: Read before and after records. Ordinary database history is not tamper proof. Run `npm run msp -- audit --json`.
- `/attention`: Review overdue service work, stale tickets, late projects, renewal reviews, client reviews and pending time. Name the client, issue, evidence and responsible technician where known. Run `npm run msp -- attention --json`.
- `/help`: Read supported CLI routes and editable entity fields before any unfamiliar operation. Run `npm run msp -- help --json`.
- `/record`: Read the full record. Use a full ID, ID prefix or case-insensitive name. If several records match, list the candidates and let the operator choose. Run `npm run msp -- record <entity> <name-or-id> --json`.
- `/add`: Read help and related records first. Add only supplied facts. Money is whole cents excluding tax. Timestamps need explicit timezones. Each client has one agreement. Run `npm run msp -- add <entity> <json> --json`.
- `/update`: Read the record first and update only supplied fields. Closed tickets need an actual closed_at timestamp. Billed time and ticket ownership with time are protected. No deleting. Run `npm run msp -- update <entity> <name-or-id> <json> --json`.
- `/log`: Record actual work with ticket, technician, description, timestamp and whole minutes. Billable does not mean approved. Use approved=true only when the operator states it was approved. Run `npm run msp -- log <json-time-entry> --json`.
- `/billing-preview`: Read agreements and unbilled time first. Preview the specified month. Uses current active device or licensed user quantities, no proration, no tax or pass-through licences. Confirm quantities represent the chosen period. Partial-month agreements are omitted and require separate review. Run `npm run msp -- billing-preview YYYY-MM --json`.
- `/billing-snapshot`: Run billing-preview first. Confirm quantity, allowance, time approval and selected period with the operator. Save one frozen billing proposal for that client and month. This records a proposal, never issues an invoice or moves money. Late entries require reviewed adjustments outside the existing snapshot. Run `npm run msp -- billing-snapshot YYYY-MM <client> --json`.
- `/weekly-review`: Run attention, unbilled-time, renewals-due, device-review and compliance. Produce a Monday plan naming client, finding, evidence and owner. Do not combine currencies or invent missing commitments. Run `npm run msp -- weekly-review --json`.
- `/draft-review`: Read the client and full related records. Save an internal client review in drafts. Check every claim against current data. A person reviews and sends. Run `npm run msp -- draft-review <client> --json`.
- `/draft-billing`: Read saved billing proposals and write a billing discussion in drafts. Keep amounts and currencies together. Do not issue an invoice or send. Run `npm run msp -- draft-billing <client> --json`.
- `/import`: Read docs/replace-halopsa.md. Inspect the actual CSV files and explicit mapping, preview, reconcile counts and values, then run the same import without --dry-run. Historical billed time needs separate reconciliation. No guessing source columns or status codes. Run `npm run msp -- import halopsa <folder> --dry-run --json`.
- `/export`: Export all entities plus billing, import and audit history as JSON and CSV. Keep credentials and private output out of Git. Database restoration and attachment backups are separate. Run `npm run msp -- export <new-folder> --json`.
- `/customise`: Read the requested field, rule or workflow change. Add a new migration without editing applied migrations. Update CLI validation, mapping documentation and meaningful tests. Apply to a disposable copy and run npm test before the operator uses it. Keep currency, period and client boundaries intact.
- `/new-view`: Read the requested question and current database views. Add a read-only entry to views.json using existing views or a new tested migration. Run npm run view. Use brand.json. Do not add write controls, a server or a front end.

## Operating rules

Every answer starts with current CLI data. Never invent a time entry, customer, deadline, approval, incident assessment or notification. An ambiguous match must be resolved by the operator. Use whole cents excluding tax and minutes for time. Dates and periods use UTC. Never add mixed currencies.

Read docs/replace-halopsa.md before migration and docs/compliance.md before interpreting findings. Billing snapshots are internal proposals, not accounting invoices. Explicitly review the current quantities and rates against the selected period. Do not infer historic bill allocations, automated timers, live monitoring or profit from these records. Preserve audit history and billed facts. No delete route exists.

Draft only into drafts. Never send, publish, notify an authority or transfer money. A saved notification timestamp records a person doing that elsewhere. No sending or payment connector exists. Keep credentials, private records, exports and generated reports out of Git.

For real use migrate a fresh database without seed. Use one MSP per database, least-privilege database roles, backups and a tested restore before sharing. Coding agents read AGENTS.md and this file. Run npm test after changes.
