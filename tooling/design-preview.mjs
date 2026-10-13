import { createServer } from 'node:http';
import { createReadStream, existsSync, mkdirSync, writeFileSync } from 'node:fs';
import { resolve, extname, join, sep } from 'node:path';
import { spawn } from 'node:child_process';
import { setTimeout as delay } from 'node:timers/promises';


const root = resolve('build/web');
const artifacts = resolve('docs/artifacts/everyday');
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
  writeFileSync(join(artifacts, 'login-light.png'), Buffer.from(screenshot.data, 'base64'));
  if (errors.length) throw new Error('Browser errors: ' + errors.join(', '));
  console.log('PASS: release Flutter web view initialized at ' + url);
  console.log('Screenshot: docs/artifacts/everyday/login-light.png');
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
  await waitText('Открыть демонстрацию');
  await click('Открыть демонстрацию');
  await waitText('Добро пожаловать, гость!');
  const capture = async (name) => {
    await delay(500);
    const shot = await send('Page.captureScreenshot', {format:'png'});
    writeFileSync(join(artifacts, name + '.png'), Buffer.from(shot.data, 'base64'));
  };
  for (const mode of ['light', 'dark']) {
    await send('Emulation.setEmulatedMedia', {features:[{name:'prefers-color-scheme', value:mode}]});
    await delay(500);
    await click('Главная');
    await waitText('Добро пожаловать, гость!');
    await capture('home-' + mode);
    await click('Расписание');
    await waitText('Учебная группа');
    await click('Пн');
    await capture('schedule-' + mode);
    await click('Лента');
    await waitText('Новости и события');
    await capture('feed-' + mode);
    await click('Каталог');
    await waitText('Найдите свою аудиторию');
    await capture('campus-' + mode);
    await click('Настройки');
    await waitText('Профиль и настройки');
    await capture('profile-' + mode);
  }
  await send('Emulation.setEmulatedMedia', {features:[{name:'prefers-color-scheme', value:'light'}]});
  await send('Emulation.setDeviceMetricsOverride', {width:1100,height:900,deviceScaleFactor:1,mobile:false});
  await delay(500);
  await click('Главная');
  await capture('tablet-light');
  if (errors.length) throw new Error('Browser errors: ' + errors.join(', '));
  console.log('PASS: 5 screens in light/dark themes and tablet rail; screenshots in docs/artifacts/everyday');
  await send('Browser.close');
} finally {
  socket?.close();
  if (chrome.exitCode === null) chrome.kill();
  server.closeAllConnections();
  await new Promise((done) => server.close(done));
}


