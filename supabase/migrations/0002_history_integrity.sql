create or replace function track_change() returns trigger language plpgsql as $$ begin
 insert into audit(entity,record_id,operation,before_record,after_record) values(TG_TABLE_NAME,NEW.id,TG_OP,case when TG_OP='UPDATE' then to_jsonb(OLD) else null end,to_jsonb(NEW));
 return NEW;
end $$;
create function stamp_updated() returns trigger language plpgsql as $$ begin NEW.updated_at=now(); return NEW; end $$;
do $$ declare t text; begin foreach t in array array['clients','technicians','agreements','devices','projects','tickets','time_entries','incidents','billing_runs','billed_time','import_rows'] loop
 execute format('drop trigger track on %I',t);
 execute format('create trigger stamp before update on %I for each row execute function stamp_updated()',t);
 execute format('create trigger track after insert or update on %I for each row execute function track_change()',t);
end loop; end $$;
create function protect_time() returns trigger language plpgsql as $$ declare client uuid; begin
 select client_id into client from tickets where id=NEW.ticket_id;
 perform id from clients where id=client for update;
 if TG_OP='UPDATE' and exists(select 1 from billed_time where time_entry_id=OLD.id) then raise exception 'Billed time is frozen'; end if;
 return NEW;
end $$;
create trigger protect_time before insert or update on time_entries for each row execute function protect_time();
create function protect_ticket_owner() returns trigger language plpgsql as $$ begin
 if (NEW.client_id is distinct from OLD.client_id or NEW.project_id is distinct from OLD.project_id) and exists(select 1 from time_entries where ticket_id=OLD.id) then raise exception 'Ticket with time cannot change client or project'; end if;
 return NEW;
end $$;
create trigger protect_ticket_owner before update on tickets for each row execute function protect_ticket_owner();
