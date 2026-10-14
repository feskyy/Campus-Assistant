import { createServer } from 'node:http';
import { createReadStream, existsSync, mkdirSync, writeFileSync } from 'node:fs';
import { resolve, extname, join, sep } from 'node:path';
import { spawn } from 'node:child_process';
import { setTimeout as delay } from 'node:timers/promises';


const root = resolve('build/web');
const mapRooms = process.argv.includes('--map-rooms');
const tasksOnly = process.argv.includes('--daily-tasks');
const daily = process.argv.includes('--daily') || tasksOnly;
const artifacts = resolve(daily ? 'docs/artifacts/daily-planner' : mapRooms ? 'docs/artifacts/map-rooms' : 'docs/artifacts/redesign');
mkdirSync(artifacts, { recursive: true });
const types = { '.html': 'text/html', '.js': 'text/javascript', '.json': 'application/json', '.wasm': 'application/wasm', '.png': 'image/png', '.ttf': 'font/ttf' };
const server = createServer((request, response) => {
  const url = new URL(request.url, 'http://localhost');
  const file = resolve(root, '.' + (url.pathname === '/' ? '/index.html' : decodeURIComponent(url.pathname)));
  if (!file.startsWith(root + sep) || !existsSync(file)) { response.writeHead(404); response.end(); return; }
  response.setHeader('Content-Type', types[extname(file)] ?? 'application/octet-stream');
  createReadStream(file).pipe(response);
});
await new Promise((done) => server.listen(8097, '127.0.0.1', done));
const url = 'http://127.0.0.1:' + server.address().port;
const chrome = spawn('C:/Program Files/Google/Chrome/Application/chrome.exe', [
  '--headless=new', '--no-first-run', '--no-default-browser-check',
  '--disable-background-networking', '--remote-debugging-port=9228',
  '--user-data-dir=' + resolve('.browser-check-design'), '--window-size=390,844', url
], { windowsHide: true, stdio: 'ignore' });
let socket;
try {
  let target;
  for (let i = 0; i < 150; i++) {
    try {
      const targets = await (await fetch('http://127.0.0.1:9228/json/list')).json();
      target = targets.find((entry) => entry.type === 'page' && entry.url.startsWith(url));
      if (target) break;
    } catch {}
    await delay(200);
  }
  if (!target) throw new Error('Headless Chrome did not open the local app');
  socket = new WebSocket(target.webSocketDebuggerUrl);
  await new Promise((done, reject) => { socket.onopen = done; socket.onerror = reject; });
  const pending = new Map();
  let sequence = 0;
  const errors = [];
  socket.onmessage = (event) => {
    const message = JSON.parse(event.data);
    if (message.method === 'Runtime.exceptionThrown') errors.push(message.params.exceptionDetails.text);
    if (message.id) {
      const task = pending.get(message.id);
      if (task) { pending.delete(message.id); message.error ? task.reject(message.error) : task.resolve(message.result); }
    }
  };
  const send = (method, params = {}) => new Promise((resolve, reject) => {
    const id = ++sequence;
    pending.set(id, { resolve, reject });
    socket.send(JSON.stringify({ id, method, params }));
  });
  await send('Runtime.enable');
  await send('Page.enable');
  await send('Emulation.setEmulatedMedia', {features:[{name:'prefers-color-scheme', value:'light'}]});
  await send('Emulation.setDeviceMetricsOverride', { width: 390, height: 844, deviceScaleFactor: 1, mobile: true });
  let ready = false;
  for (let i = 0; i < 150; i++) {
    const result = await send('Runtime.evaluate', { expression: "!!document.querySelector('flutter-view')", returnByValue: true });
    if (result.result.value) { ready = true; break; }
    await delay(200);
  }
  if (!ready) throw new Error('Flutter web view did not initialize');
  await delay(3000);
  await send('Runtime.evaluate', { expression: "document.querySelector('flt-semantics-placeholder')?.click()" });
  await delay(1000);
  const content = await send('Runtime.evaluate', { expression: "document.body.innerText", returnByValue: true });
  const screenshot = await send('Page.captureScreenshot', { format: 'png' });
  writeFileSync(join(artifacts, 'initial.png'), Buffer.from(screenshot.data, 'base64'));
  if (errors.length) throw new Error('Browser errors: ' + errors.join(', '));
  console.log('PASS: release Flutter web view initialized at ' + url);
  console.log('Screenshot: ' + join(artifacts, 'initial.png'));
  console.log('Accessible text: ' + String(content.result.value).slice(0, 500));

  const evaluate = async (expression) => (await send('Runtime.evaluate', { expression, returnByValue: true })).result.value;
  const accessibleText = async () => await evaluate("document.body.innerText + '\\n' + [...document.querySelectorAll('[aria-label]')].map(e => e.getAttribute('aria-label')).join('\\n')");
  const waitText = async (text) => {
    for (let i = 0; i < 100; i++) {
      if ((await accessibleText()).includes(text)) return;
      await delay(100);
    }
    throw new Error('Text not shown: ' + text + '\\n' + await evaluate('document.body.innerText'));
  };
  const click = async (text) => {
    const encoded = JSON.stringify(text);
    const point = await evaluate(`(() => {
      const text = ${encoded};
      const nodes = [...document.querySelectorAll(text === 'Избранное' ? 'flt-semantics[role="checkbox"]' : 'flt-semantics')].reverse();
      const match = nodes.find(e => {
        const r = e.getBoundingClientRect();
        return r.width > 0 && r.height > 0 && (e.textContent.trim() === text || new RegExp('^' + text + '(?:\\\\s|\\\\d)').test(e.textContent.trim()) || (e.getAttribute('aria-label') ?? '').includes(text));
      });
      if (!match) return null;
      const r = match.getBoundingClientRect();
      return { x: r.x + r.width/2, y: r.y + r.height/2 };
    })()`);
    if (!point) throw new Error('Control not found: ' + text + '\\n' + await evaluate('document.body.innerText'));
    await send('Input.dispatchMouseEvent', { type: 'mousePressed', button: 'left', clickCount: 1, ...point });
    await send('Input.dispatchMouseEvent', { type: 'mouseReleased', button: 'left', clickCount: 1, ...point });
    await delay(300);
  };
  const capture = async (name) => {
    await delay(1800);
    const shot=await send('Page.captureScreenshot',{format:'png'});
    writeFileSync(join(artifacts,name+'.png'),Buffer.from(shot.data,'base64'));
  };
  const screens = tasksOnly ? [] : daily ? [['home',''],['schedule',''],['feed','']] : mapRooms ? [['map','']] : process.argv.includes('--editorial')
    ? [['feed',''],['event','e1']]
    : [['login',''],['home',''],['schedule',''],['feed',''],['profile',''],['map',''],['news','n1'],['event','e1'],['lesson','l1'],['subject','math'],['teacher','ivanov'],['week3',''],['design','']];
  for(const theme of ['light','dark']){
    for(const [screen,id] of screens){
      await send('Page.navigate',{url:url+'/?theme='+theme+'&screen='+screen+'&id='+id+(daily?'&at=2026-10-12T08:35:00':mapRooms?'&at=2026-10-12T09:30:00':'')});
      await delay(3500);
      await send('Runtime.evaluate',{expression:"document.querySelector('flt-semantics-placeholder')?.click()"});
      await capture(screen+'-'+theme);
      if (daily && screen === 'home') {
        await send('Input.dispatchMouseEvent',{type:'mouseWheel',x:220,y:480,deltaY:800,deltaX:0});
        await capture('home-tasks-'+theme);
        await send('Input.dispatchMouseEvent',{type:'mouseWheel',x:220,y:480,deltaY:550,deltaX:0});
        await capture('home-campus-'+theme);
      }
      if (daily && screen === 'schedule') {
        await click('Новая задача');
        await capture('task-editor-'+theme);
        await click('Закрыть');
      }
      if (daily && screen === 'feed') {
        await click('События');
        await capture('feed-events-'+theme);
      }
      if (mapRooms) {
        await click('Развернуть карту');
        await click('Главный корпус');
        await waitText('Свободны по расписанию');
        await capture('expanded-'+theme);
        await click('Корпус Б');
        await capture('expanded-other-'+theme);
        await send('Page.navigate', {url:url+'/?theme='+theme+'&screen=map&building=main&room=214&at=2026-10-12T09:30:00'});
        await delay(3500);
        await send('Runtime.evaluate',{expression:"document.querySelector('flt-semantics-placeholder')?.click()"});
        await send('Input.dispatchMouseEvent',{type:'mouseWheel',x:220,y:480,deltaY:600,deltaX:0});
        await capture('rooms-'+theme);
        await click('Аудитория 214');
        await waitText('Оснащение');
        await capture('room-info-'+theme);
      }
      if(!daily && ['home','lesson','news','event','profile'].includes(screen)){
        await send('Input.dispatchMouseEvent',{type:'mouseWheel',x:220,y:480,deltaY:550,deltaX:0});
        await capture(screen+'-scroll-'+theme);
      }
    }
  }
  if (daily) {
    for (const width of tasksOnly ? [] : [667,1280]) {
      await send('Emulation.setDeviceMetricsOverride',{width,height:950,deviceScaleFactor:1,mobile:width<840});
      for (const screen of ['home','schedule','feed']) {
        await send('Page.navigate',{url:url+'/?theme=dark&screen='+screen+'&at=2026-10-12T08:35:00'});
        await delay(3500);
        await send('Runtime.evaluate',{expression:"document.querySelector('flt-semantics-placeholder')?.click()"});
        await capture(screen+'-dark-'+width);
      }
    }
    await send('Page.navigate',{url:url+'/?theme=dark&screen=schedule&at=2026-10-12T08:35:00'});
    await delay(3500);
    await send('Runtime.evaluate',{expression:"document.querySelector('flt-semantics-placeholder')?.click()"});
    await click('Новая задача');
    const inputPoint = await evaluate(`(() => {
      const input = [...document.querySelectorAll('input,textarea')].find(e => e.getBoundingClientRect().width > 0);
      if (!input) throw Error('Task title input not present');
      input.focus();
      const r = input.getBoundingClientRect();
      return {x:r.x+r.width/2,y:r.y+r.height/2};
    })()`);
    await send('Input.dispatchMouseEvent',{type:'mousePressed',button:'left',clickCount:1,...inputPoint});
    await send('Input.dispatchMouseEvent',{type:'mouseReleased',button:'left',clickCount:1,...inputPoint});
    await send('Input.insertText',{text:'Проверить план курсовой'});
    await click('Сохранить');
    await send('Page.reload');
    await delay(3500);
    await send('Runtime.evaluate',{expression:"document.querySelector('flt-semantics-placeholder')?.click()"});
    await send('Input.dispatchMouseEvent',{type:'mouseWheel',x:350,y:480,deltaY:850,deltaX:0});
    await waitText('Проверить план курсовой');
    await capture('task-persisted');
    await click('Действия задачи: Проверить план курсовой');
    await click('Удалить');
    await click('Удалить');
    if ((await accessibleText()).includes('Проверить план курсовой')) throw new Error('Review task was not deleted');
    console.log('PASS: personal task survives a browser reload; review task deleted');
  }
  await send('Emulation.setDeviceMetricsOverride',{width:1280,height:800,deviceScaleFactor:1,mobile:false});
  if (!daily) { await send('Page.navigate',{url:url+'/?theme=light&screen=map'});await delay(3500);await capture('map-desktop'); }
  if (mapRooms) {
    await send('Runtime.evaluate',{expression:"document.querySelector('flt-semantics-placeholder')?.click()"});
    await click('Развернуть карту');
    await click('Главный корпус');
    await waitText('Свободны по расписанию');
    await capture('expanded-desktop');
  }
  console.log('Visual review screenshots: '+artifacts);
  if(errors.length)throw new Error('Browser errors: '+errors.join(', '));
  await send('Browser.close');
} finally {
  socket?.close();
  if(chrome.exitCode===null)chrome.kill();
  server.closeAllConnections();
  await new Promise(done=>server.close(done));
}
