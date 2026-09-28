create table clients (
 id uuid primary key default gen_random_uuid(), name text not null unique, country text not null check(country in ('NZ','AU')), currency text not null check(currency in ('NZD','AUD')), licensed_users integer not null default 0 check(licensed_users>=0), review_due date, contact_email text,
 created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table technicians (
 id uuid primary key default gen_random_uuid(), name text not null unique, weekly_minutes integer not null default 2400 check(weekly_minutes>0), created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table agreements (
 id uuid primary key default gen_random_uuid(), client_id uuid not null unique references clients, name text not null, basis text not null check(basis in ('flat','device','user')), unit_cents integer not null check(unit_cents>=0), included_minutes integer not null default 0 check(included_minutes>=0), overage_cents integer not null check(overage_cents>=0), starts_on date not null, ends_on date not null, renewal_due date not null, status text not null default 'active' check(status in ('active','ended')), check(ends_on>=starts_on), created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table devices (
 id uuid primary key default gen_random_uuid(), client_id uuid not null references clients, name text not null, serial text not null unique, status text not null default 'active' check(status in ('active','retired')), warranty_until date, last_seen timestamptz, created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table projects (
 id uuid primary key default gen_random_uuid(), client_id uuid not null references clients, name text not null, budget_minutes integer not null check(budget_minutes>=0), due_on date not null, status text not null default 'open' check(status in ('open','closed')), created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table tickets (
 id uuid primary key default gen_random_uuid(), client_id uuid not null references clients, project_id uuid references projects, technician_id uuid references technicians, name text not null, priority integer not null default 3 check(priority between 1 and 4), status text not null default 'open' check(status in ('open','waiting','closed')), opened_at timestamptz not null default now(), response_due timestamptz not null, resolve_due timestamptz not null, responded_at timestamptz, closed_at timestamptz, last_activity_at timestamptz not null default now(), check(response_due>=opened_at and resolve_due>=response_due), check(responded_at is null or responded_at>=opened_at), check((status='closed')=(closed_at is not null)), check(closed_at is null or closed_at>=opened_at), created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table time_entries (
 id uuid primary key default gen_random_uuid(), ticket_id uuid not null references tickets, technician_id uuid not null references technicians, name text not null, worked_at timestamptz not null, minutes integer not null check(minutes>0 and minutes<=1440), billable boolean not null default true, approved boolean not null default false, created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table incidents (
 id uuid primary key default gen_random_uuid(), client_id uuid not null references clients, name text not null, discovered_at timestamptz not null, serious_harm text not null default 'unknown' check(serious_harm in ('unknown','yes','no')), assessment text, regulator_notified_at timestamptz, people_notified_at timestamptz, exception_reason text, status text not null default 'open' check(status in ('open','closed')), created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table billing_runs (
 id uuid primary key default gen_random_uuid(), client_id uuid not null references clients, period date not null check(extract(day from period)=1), name text not null, currency text not null, quantity integer not null, base_cents bigint not null, included_minutes integer not null, used_minutes integer not null, overage_minutes integer not null, overage_cents bigint not null, total_cents bigint not null, created_at timestamptz not null default now(), updated_at timestamptz not null default now(), unique(client_id,period)
);
create table billed_time (
 id uuid primary key default gen_random_uuid(), billing_run_id uuid not null references billing_runs, time_entry_id uuid not null unique references time_entries, created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table import_rows (
 id uuid primary key default gen_random_uuid(), entity text not null, source_id text not null, target_id uuid not null, payload jsonb not null, created_at timestamptz not null default now(), updated_at timestamptz not null default now(), unique(entity,source_id)
);
create table audit (
 id uuid primary key default gen_random_uuid(), entity text not null, record_id uuid not null, operation text not null, before_record jsonb, after_record jsonb, created_at timestamptz not null default now()
);
create function track_change() returns trigger language plpgsql as $$ begin
 if TG_OP='UPDATE' then NEW.updated_at=now(); end if;
 insert into audit(entity,record_id,operation,before_record,after_record) values(TG_TABLE_NAME,NEW.id,TG_OP,case when TG_OP='UPDATE' then to_jsonb(OLD) else null end,to_jsonb(NEW));
 return NEW;
end $$;
do $$ declare t text; begin foreach t in array array['clients','technicians','agreements','devices','projects','tickets','time_entries','incidents','billing_runs','billed_time','import_rows'] loop
 execute format('create trigger track before insert or update on %I for each row execute function track_change()',t);
end loop; end $$;
create function enforce_relationships() returns trigger language plpgsql as $$ begin
 if NEW.project_id is not null and not exists(select 1 from projects where id=NEW.project_id and client_id=NEW.client_id) then raise exception 'Project belongs to another client'; end if;
 return NEW;
end $$;
create trigger ticket_client before insert or update on tickets for each row execute function enforce_relationships();
create index ticket_client_idx on tickets(client_id);
create index time_ticket_idx on time_entries(ticket_id,worked_at);
create view sla_watch as
 select t.id,c.name client,t.name ticket,t.priority,t.status,coalesce(a.name,'Unassigned') technician,
 t.response_due,t.resolve_due,
 (coalesce(t.responded_at,now())>t.response_due) response_breached,
 (coalesce(t.closed_at,now())>t.resolve_due) resolution_breached,
 (t.status<>'closed' and t.last_activity_at<now()-interval '3 days') stale
 from tickets t join clients c on c.id=t.client_id left join technicians a on a.id=t.technician_id;
create view agreement_desk as
 select a.*,c.name client,c.currency,
 case a.basis when 'device' then (select count(*)::integer from devices d where d.client_id=a.client_id and d.status='active') when 'user' then c.licensed_users else 1 end quantity
 from agreements a join clients c on c.id=a.client_id;
create view unbilled_time as
 select e.id,c.id client_id,c.name client,c.currency,t.name ticket,e.name description,a.name technician,e.worked_at,e.minutes,e.billable,e.approved
 from time_entries e join tickets t on t.id=e.ticket_id join clients c on c.id=t.client_id join technicians a on a.id=e.technician_id
 where not exists(select 1 from billed_time b where b.time_entry_id=e.id);
create view project_desk as
 select p.id,c.name client,p.name project,p.status,p.due_on,p.budget_minutes,coalesce(sum(e.minutes),0)::integer used_minutes,
 p.budget_minutes-coalesce(sum(e.minutes),0)::integer remaining_minutes
 from projects p join clients c on c.id=p.client_id left join tickets t on t.project_id=p.id left join time_entries e on e.ticket_id=t.id group by p.id,c.name;
create view client_review as
 select c.id,c.name client,c.currency,c.review_due,
 (select count(*) from tickets t where t.client_id=c.id and t.status<>'closed') open_tickets,
 (select count(*) from tickets t join sla_watch s on s.id=t.id where t.client_id=c.id and (s.response_breached or s.resolution_breached)) breached_tickets,
 (select coalesce(sum(minutes),0) from unbilled_time u where u.client_id=c.id and u.billable) unbilled_minutes,
 (select count(*) from devices d where d.client_id=c.id and d.status='active' and (d.warranty_until<current_date or d.last_seen<now()-interval '7 days' or d.last_seen is null)) device_attention
 from clients c;
create view compliance_findings as
 select i.id,c.name client,'PRIVACY-ASSESS' rule,'Assess harm and document the decision' finding from incidents i join clients c on c.id=i.client_id where i.serious_harm='unknown' or nullif(trim(i.assessment),'') is null
 union all select i.id,c.name,'NZ-NOTIFY','Serious harm recorded: review regulator notification immediately' from incidents i join clients c on c.id=i.client_id where c.country='NZ' and i.serious_harm='yes' and i.regulator_notified_at is null
 union all select i.id,c.name,'NZ-PEOPLE','Review affected-person notification or documented exception' from incidents i join clients c on c.id=i.client_id where c.country='NZ' and i.serious_harm='yes' and i.people_notified_at is null and nullif(trim(i.exception_reason),'') is null
 union all select i.id,c.name,'AU-REVIEW','Review applicable Australian breach duties with the privacy officer' from incidents i join clients c on c.id=i.client_id where c.country='AU' and i.status='open'
 union all select a.id,c.name,'CONTRACT-RENEWAL','Agreement renewal review is overdue (business policy)' from agreements a join clients c on c.id=a.client_id where a.status='active' and a.renewal_due<current_date;
