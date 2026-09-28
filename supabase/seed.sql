insert into clients(id,name,country,currency,licensed_users,review_due,contact_email) values
 ('10000000-0000-0000-0000-000000000001','Harbour Accounting','NZ','NZD',24,current_date-7,'ops@example.invalid'),
 ('10000000-0000-0000-0000-000000000002','Kauri Distribution','NZ','NZD',15,current_date+14,'it@example.invalid'),
 ('10000000-0000-0000-0000-000000000003','River Engineering','AU','AUD',18,current_date-2,'owner@example.invalid') on conflict do nothing;
insert into technicians(id,name) values ('20000000-0000-0000-0000-000000000001','Mia Chen'),('20000000-0000-0000-0000-000000000002','James Patel') on conflict do nothing;
insert into agreements(id,client_id,name,basis,unit_cents,included_minutes,overage_cents,starts_on,ends_on,renewal_due) values
 ('30000000-0000-0000-0000-000000000001','10000000-0000-0000-0000-000000000001','Harbour managed support','user',9500,120,15000,current_date-365,current_date+30,current_date-5),
 ('30000000-0000-0000-0000-000000000002','10000000-0000-0000-0000-000000000002','Kauri endpoint care','device',6500,60,14000,current_date-120,current_date+180,current_date+150),
 ('30000000-0000-0000-0000-000000000003','10000000-0000-0000-0000-000000000003','River support block','flat',180000,300,16000,current_date-90,current_date+90,current_date+60) on conflict do nothing;
insert into devices(id,client_id,name,serial,warranty_until,last_seen) values
 ('40000000-0000-0000-0000-000000000001','10000000-0000-0000-0000-000000000001','Harbour file server','DEMO-H001',current_date-20,now()-interval '8 days'),
 ('40000000-0000-0000-0000-000000000002','10000000-0000-0000-0000-000000000002','Kauri reception laptop','DEMO-K001',current_date+365,now()),
 ('40000000-0000-0000-0000-000000000003','10000000-0000-0000-0000-000000000002','Kauri warehouse laptop','DEMO-K002',current_date+200,now()) on conflict do nothing;
insert into projects(id,client_id,name,budget_minutes,due_on) values ('50000000-0000-0000-0000-000000000001','10000000-0000-0000-0000-000000000001','Harbour backup migration',120,current_date-1) on conflict do nothing;
insert into tickets(id,client_id,project_id,technician_id,name,priority,opened_at,response_due,resolve_due,last_activity_at) values
 ('60000000-0000-0000-0000-000000000001','10000000-0000-0000-0000-000000000001','50000000-0000-0000-0000-000000000001','20000000-0000-0000-0000-000000000001','Backup restore failed',1,now()-interval '5 days',now()-interval '5 days'+interval '1 hour',now()-interval '4 days',now()-interval '4 days'),
 ('60000000-0000-0000-0000-000000000002','10000000-0000-0000-0000-000000000002',null,'20000000-0000-0000-0000-000000000002','Warehouse WiFi coverage',3,now()-interval '1 hour',now()+interval '3 hours',now()+interval '2 days',now()),
 ('60000000-0000-0000-0000-000000000003','10000000-0000-0000-0000-000000000003',null,null,'Leaver access review',2,now()-interval '2 days',now()-interval '1 day',now()+interval '1 day',now()-interval '1 day') on conflict do nothing;
insert into time_entries(id,ticket_id,technician_id,name,worked_at,minutes,billable,approved) values
 ('70000000-0000-0000-0000-000000000001','60000000-0000-0000-0000-000000000001','20000000-0000-0000-0000-000000000001','Restore investigation',now(),180,true,true),
 ('70000000-0000-0000-0000-000000000002','60000000-0000-0000-0000-000000000001','20000000-0000-0000-0000-000000000002','Review recovery evidence',now(),30,true,false),
 ('70000000-0000-0000-0000-000000000003','60000000-0000-0000-0000-000000000002','20000000-0000-0000-0000-000000000002','Wireless survey',now(),90,true,true) on conflict do nothing;
insert into incidents(id,client_id,name,discovered_at,serious_harm,assessment) values
 ('80000000-0000-0000-0000-000000000001','10000000-0000-0000-0000-000000000001','Misaddressed payroll attachment',now()-interval '4 days','yes','Fictional exercise: privacy officer recorded likely serious harm.'),
 ('80000000-0000-0000-0000-000000000002','10000000-0000-0000-0000-000000000003','Unknown external mailbox access',now()-interval '1 day','unknown',null) on conflict do nothing;
