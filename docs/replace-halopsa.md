# Bring HaloPSA records across

Halo documents CSV report export in [Reports and Scheduling](https://www.usehalo.com/guides/887). Its reporting system permits custom queries and headings. There is no single verified universal Halo export header set. The files in fixtures/halopsa are fictional examples of a report configuration, not captured customer exports.

1. In Halo, have an authorised administrator run reports for the customers, agents, agreements, devices, projects, tickets, time entries and incident records you need. Export each report to CSV. Include stable source IDs and the IDs of linked records. Preserve original files outside this source repository.
2. Inspect real headers. Create mapping.json in the same folder, following the fixture. Each item names an entity, a file, its source key and a columns object mapping exact exported headings to supported fields. Ignore unwanted headings explicitly with an ignore array. The original row and mapping are kept as import provenance.
3. Order the files: clients, technicians, agreements, devices, projects, tickets, time_entries, incidents. Foreign reference values are source IDs from an earlier import, never guessed names. Convert status codes explicitly to open, waiting or closed. Dates use YYYY-MM-DD, timestamps include a timezone, money uses whole cents excluding tax, and boolean values are true or false. A closed ticket needs its actual closed_at value. Optional unknown fields use empty cells. Required fields cannot be empty.
4. On a fresh unseeded database, migrate then preview and import:

```bash
npm run migrate
npm run msp -- import halopsa /path/to/export --dry-run --json
npm run msp -- import halopsa /path/to/export --json
```

The import is one command after export mapping. Preview rolls the entire transaction back. A missing linked ID, unknown column, invalid status or malformed row rolls the whole batch back. Identical repeated imports skip rows. A changed row or changed mapping for a source ID stops for reviewed reconciliation, rather than overwriting locally maintained facts. This is an initial migration tool, not a live synchronisation feed. Map additional fields with /customise before importing them. Files support BOM, quoted commas, embedded newlines and escaped quotes.

The CLI help lists every supported field. One current agreement per client is supported. Map multiple Halo agreements into an explicitly reviewed commercial arrangement or extend the model before cutover. Agreement quantities use active devices, client licensed_users, or one flat unit. Included time is one monthly allowance, not per device. Imported response and resolution deadlines are absolute instants. Business calendars, pause rules and automated clock recalculation need separate configuration.

Attachments, emails, rich action history, credentials, supplier licensing, tax invoices, historical billing allocations and monitoring connections do not transfer through this importer. Keep those exports and evidence files separately. Time imported here is initially unallocated: import only the open billing period or reconcile historical allocations before using the billing desk. Never feed previously invoiced time into a new billing proposal.

Reconcile counts by entity, client ownership, devices per agreement, open tickets by status, unresolved deadlines, currency, billable minutes and sample client histories. Compare a billing period against Halo before relying on the calculation. Run both systems for an agreed period and keep the original export. Do not cancel Halo until the owner accepts the migration and the separately scoped connections work.

Export with npm run msp -- export /new/folder. This produces JSON and CSV snapshots including audit and import history. It is not a restore command. Back up the database and supporting files, and test a restore separately. CSV is raw interchange data and should be opened as text, not executed as spreadsheet formulas.
