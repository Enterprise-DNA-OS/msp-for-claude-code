import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { spawnSync } from 'node:child_process';
import { getDb,REPO_ROOT } from './lib/db.mjs';
import { migrate } from './migrate.mjs';
import { seed } from './seed.mjs';
import { run,reads } from './msp.mjs';
import { parseCsv } from './lib/csv.mjs';
import { table as htmlTable } from './lib/render.mjs';
const tmp=fs.mkdtempSync(path.join(os.tmpdir(),'msp-test-'));
process.env.DATABASE_URL=process.env.TEST_DATABASE_URL||'';
process.env.DATA_DIR=path.join(tmp,'db');process.env.OUTPUT_DIR=tmp;
let db=await getDb();let assertions=0;
function ok(value,msg){assert.ok(value,msg);assertions++;}
async function fails(fn,regex){await assert.rejects(fn,regex);assertions++;}
const call=(...args)=>run(db,args);
try{
 if(db.mode==='postgres'){const existing=await db.query("select tablename from pg_tables where schemaname='public'");assert.equal(existing.length,0,'TEST_DATABASE_URL must be an empty disposable database');}
 await migrate(db);await seed(db);const before=(await db.query('select count(*) n from audit'))[0].n;await seed(db);assert.equal((await db.query('select count(*) n from audit'))[0].n,before);ok((await migrate(db)).ran.length===0,'migration is repeat-safe');
 for(const cmd of Object.keys(reads))ok(Array.isArray(await call(cmd)),cmd);
 ok((await call('help'))[0].commands.includes('billing-snapshot'));
 ok((await call('record','clients','HARBOUR'))[0].name==='Harbour Accounting');
 await fails(()=>call('record','clients','10000000'),/ambiguous/);
 await fails(()=>call('record','clients','nobody'),/no match/);
 const period=new Date().toISOString().slice(0,7);
 let b=(await call('billing-preview',period)).find(x=>x.client==='Harbour Accounting');
 assert.equal(b.quantity,24);assert.equal(Number(b.base_cents),228000);assert.equal(b.used_minutes,180);assert.equal(b.overage_minutes,60);assert.equal(b.overage_cents,15000);assert.equal(b.total_cents,243000);assert.equal(b.pending_entries,1);assertions+=7;
 await fails(()=>call('billing-snapshot',period,'Harbour'),/pending time/);
 await call('update','time_entries','Review recovery',JSON.stringify({approved:true}));
 const snapshot=(await call('billing-snapshot',period,'Harbour'))[0];assert.equal(Number(snapshot.total_cents),250500);assertions++;
 await fails(()=>call('billing-snapshot',period,'Harbour'),/already exists/);
 await fails(()=>call('update','time_entries','Restore investigation',JSON.stringify({minutes:1})),/frozen/);
 await call('update','agreements','Harbour managed',JSON.stringify({unit_cents:1}));assert.equal(Number((await call('billing-runs'))[0].total_cents),250500);assertions++;
 ok(!(await call('unbilled-time')).some(x=>x.client==='Harbour Accounting'),'allocated time removed from unbilled desk');
 b=(await call('billing-preview',period)).find(x=>x.client==='Kauri Distribution');assert.equal(b.quantity,2);assert.equal(b.total_cents,20000);assertions+=2;
 await fails(()=>call('billing-preview','2026-99'),/YYYY-MM/);
 await fails(()=>call('add','tickets',JSON.stringify({name:'Bad cross-client',client_id:'Kauri',project_id:'Harbour backup',opened_at:'2026-01-01T00:00:00Z',response_due:'2026-01-02T00:00:00Z',resolve_due:'2026-01-03T00:00:00Z'})),/another client/);
 await fails(()=>call('add','clients',JSON.stringify({name:'Negative',country:'NZ',currency:'NZD',licensed_users:-1})),/whole nonnegative/);
 await fails(()=>call('update','tickets','Warehouse WiFi',JSON.stringify({status:'closed'})),/check constraint/);
 await fails(()=>call('update','tickets','Backup restore',JSON.stringify({client_id:'Kauri'})),/cannot change/);
 await fails(()=>call('log',JSON.stringify({name:'Bad minutes',ticket_id:'Warehouse',technician_id:'James',minutes:0,worked_at:new Date().toISOString()})),/check constraint/);
 await call('log',JSON.stringify({name:'Follow-up work',ticket_id:'Warehouse',technician_id:'James',minutes:15,worked_at:new Date().toISOString(),billable:false}));
 await call('add','clients',JSON.stringify({name:'West Support',country:'NZ',currency:'NZD'}));
 await call('update','tickets','Warehouse',JSON.stringify({responded_at:new Date().toISOString(),last_activity_at:new Date().toISOString()}));
 ok((await call('weekly-review')).length>3);
 const comp=await call('compliance');ok(comp.some(x=>x.rule==='NZ-NOTIFY'));ok(comp.some(x=>x.rule==='NZ-PEOPLE'));ok(comp.some(x=>x.rule==='PRIVACY-ASSESS'));
 await call('update','incidents','Misaddressed',JSON.stringify({regulator_notified_at:new Date().toISOString(),people_notified_at:new Date().toISOString()}));ok(!(await call('compliance')).some(x=>x.rule==='NZ-NOTIFY'));
 const fixture=path.join(REPO_ROOT,'fixtures/halopsa');await call('import','halopsa',fixture,'--dry-run');await fails(()=>call('record','clients','Example Harbour'),/no match/);
 let imp=await call('import','halopsa',fixture);ok(imp.every(x=>x.added===1));imp=await call('import','halopsa',fixture);ok(imp.every(x=>x.skipped===1));
 const bad=path.join(tmp,'bad');fs.cpSync(fixture,bad,{recursive:true});fs.appendFileSync(path.join(bad,'clients.csv'),'C102,Must roll back,NZ,NZD,2,2026-11-01\n');fs.writeFileSync(path.join(bad,'tickets.csv'),fs.readFileSync(path.join(bad,'tickets.csv'),'utf8').replace('Printer, floor two','Changed summary'));
 await fails(()=>call('import','halopsa',bad),/Changed source/);await fails(()=>call('record','clients','Must roll back'),/no match/);
 fs.writeFileSync(path.join(bad,'tickets.csv'),fs.readFileSync(path.join(fixture,'tickets.csv'),'utf8').replace('Ticket ID,','Ticket ID,Unknown,').replace('T101,','T102,x,').replace('C101,A101','MISSING,A101'));
 await fails(()=>call('import','halopsa',bad),/Unmapped columns/);
 fs.writeFileSync(path.join(bad,'tickets.csv'),fs.readFileSync(path.join(fixture,'tickets.csv'),'utf8').replace('T101,','T102,').replace('C101,A101','MISSING,A101'));
 await fails(()=>call('import','halopsa',bad),/Missing imported reference/);
 assert.equal(parseCsv('\uFEFFID,Note\r\n1,"a,b\nline ""two"""\r\n')[0].Note,'a,b\nline "two"');assertions++;
 assert.throws(()=>parseCsv('a,A\n1,2'),/unique/);assert.throws(()=>parseCsv('a,b\n1'),/expected/);
 ok(htmlTable([{name:'<script>alert(1)</script>'}]).includes('&lt;script&gt;'),'HTML escapes records');
 for(const cmd of ['draft-review','draft-billing']){const [d]=await call(cmd,'Harbour Accounting');ok(fs.readFileSync(d.file,'utf8').includes('Internal draft'));}
 const out=path.join(tmp,'export');const exported=await call('export',out);ok(exported.length===12);const data=JSON.parse(fs.readFileSync(path.join(out,'all.json')));ok(data.audit.length>0&&data.import_rows.length===3&&data.billing_runs.length===1);await fails(()=>call('export',out),/already exists/);
 await db.close();db=null;
 for(const script of ['view.mjs','docs.mjs']){const p=spawnSync(process.execPath,[path.join(REPO_ROOT,'scripts',script)],{env:process.env,encoding:'utf8'});assert.equal(p.status,0,p.stderr);assertions++;}
 ok(fs.readdirSync(path.join(tmp,'views')).length===3);ok(fs.readdirSync(path.join(tmp,'docs-out','billing-proposal')).length===1);
 for(const [args,status]of [[['record','clients','10000000','--json'],1],[['bogus'],1],[['client-review','--json'],0]]){const p=spawnSync(process.execPath,[path.join(REPO_ROOT,'scripts/msp.mjs'),...args],{env:process.env,encoding:'utf8'});assert.equal(p.status,status,p.stderr);if(!status)ok(Array.isArray(JSON.parse(p.stdout)));assertions++;}
 console.log(`PASS: ${assertions} assertions; every read route, billing arithmetic, immutable snapshots, imports and rollback, documents, views and CLI exit codes`);
}finally{if(db)await db.close();fs.rmSync(tmp,{recursive:true,force:true});}
