import { spawn } from 'node:child_process';
import { writeFileSync, mkdirSync } from 'node:fs';
import { resolve } from 'node:path';
import { setTimeout as delay } from 'node:timers/promises';
const url = process.argv[2] ?? 'http://localhost:51731';
const chrome = spawn('C:/Program Files/Google/Chrome/Application/chrome.exe', [
  '--headless=new', '--no-first-run', '--no-default-browser-check', '--remote-debugging-port=9229',
  '--user-data-dir=' + resolve('.browser-check-startup'), url
], { windowsHide: true, stdio: 'ignore' });
let socket;
const errors = [];
try {
  let tab;
  for (let i=0;i<100;i++) {
    try { tab=(await(await fetch('http://127.0.0.1:9229/json/list')).json()).find(e=>e.url.startsWith(url)); if(tab)break; } catch {}
    await delay(100);
  }
  if(!tab)throw Error('Browser did not open the debug URL');
  socket=new WebSocket(tab.webSocketDebuggerUrl);
  await new Promise((done,reject)=>{socket.onopen=done;socket.onerror=reject;});
  let id=0;
  const pending=new Map();
  socket.onmessage=event=>{
    const m=JSON.parse(event.data);
    if(m.id){const p=pending.get(m.id);if(p){pending.delete(m.id);m.error?p.reject(m.error):p.resolve(m.result);}}
    if(m.method==='Runtime.exceptionThrown'){errors.push(m.params.exceptionDetails.exception?.description??m.params.exceptionDetails.text);console.log('Exception: '+errors.at(-1));}
    if(m.method==='Runtime.consoleAPICalled'){const text=m.params.args.map(a=>a.value??a.description??'').join(' ');if(m.params.type==='error'||text.includes('Starting application'))console.log('Console '+m.params.type+': '+text.slice(0,1000));}
    if(m.method==='Network.loadingFailed')console.log('Network failure: '+m.params.errorText);
  };
  const send=(method,params={})=>new Promise((resolve,reject)=>{const next=++id;pending.set(next,{resolve,reject});socket.send(JSON.stringify({id:next,method,params}));});
  await send('Runtime.enable');
  await send('Network.enable');
  const evaluate=async expression=>(await send('Runtime.evaluate',{expression,returnByValue:true})).result.value;
  let loaded=false;
  for(let i=0;i<120;i++){
    await evaluate("document.querySelector('flt-semantics-placeholder')?.click()");
    const text=await evaluate("document.body.innerText");
    if(text.includes('Вход в приложение')||text.includes('Добро пожаловать')){loaded=true;console.log('PASS: debug app rendered; '+text.slice(0,400));break;}
    if(i%20===0)console.log('Waiting for first Flutter screen: '+(i/2)+' seconds');
    await delay(500);
  }
  mkdirSync('docs/artifacts',{recursive:true});
  const shot=await send('Page.captureScreenshot',{format:'png'});
  writeFileSync('docs/artifacts/debug-startup.png',Buffer.from(shot.data,'base64'));
  if(!loaded){
    console.log(await evaluate("JSON.stringify({html:document.body.innerHTML.slice(0,1500),external:performance.getEntriesByType('resource').filter(r=>!r.name.startsWith(location.origin)).map(r=>r.name)})"));
    throw Error('Debug app did not render within 60 seconds');
  }
  if(errors.length)throw Error('Runtime exceptions detected');
  await send('Browser.close');
}finally{
  socket?.close();
  if(chrome.exitCode===null)chrome.kill();
}
