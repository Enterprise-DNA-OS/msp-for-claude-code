# Privacy incident record checks

Checked 2026-09-28. These are selected record checks for an MSP's internal privacy desk. They do not certify compliance, determine serious harm or send a notification. The privacy officer reviews the evidence and the law that applies to the organisation. Store only the incident summary here, not passwords, tokens or the breached files.

| Check | Implemented rule | Basis |
| --- | --- | --- |
| PRIVACY-ASSESS | Flag unknown harm or a missing written assessment, even on a closed incident. | Operator review policy supporting a documented harm decision. |
| NZ-NOTIFY | A NZ incident with serious_harm=yes and no regulator notification record is flagged immediately. | [NZ Privacy Commissioner, NotifyUs](https://www.privacy.org.nz/responsibilities/privacy-breaches/notify-us/). |
| NZ-PEOPLE | Flag missing affected-person notification unless an exception reason is recorded. | The same regulator guidance. A stored reason is evidence for review, not proof an exception applies. |
| AU-REVIEW | Flag open Australian incidents for the privacy officer's assessment of applicable duties. | No automatic Australian legal deadline is asserted by this build. Configure the applicable rules with the officer before relying on them. |
| CONTRACT-RENEWAL | Flag active agreements past their renewal review date. | Operator contract policy, not a statute. |

NZ guidance says notification is required for a privacy breach causing or potentially causing serious harm. It asks agencies to notify ideally within 72 hours of awareness of a notifiable breach, and affected people as soon as possible unless an exception applies. That 72-hour guidance is not treated as a grace period or a statutory countdown here. The checks flag missing evidence immediately. Assessment, notifications, exceptions and containment remain the responsible person's work.

Three-day ticket inactivity, seven-day device freshness, weekly technician capacity and 60-day renewal lookahead are demo business policies. Service deadlines come from the agreement or imported records, not legislation. The app records a notification a person made elsewhere. It never sends one.

Shared deployment needs least-privilege database roles, an access review, encrypted backups and a tested restore. The source does not include row-level tenant isolation. Run one MSP per database and do not grant customers direct access. Audit history is ordinary database data and administrators can alter it.
