/**
 * 用 Chrome DevTools Protocol 真实驱动浏览器，诊断 mota-js 黑屏。
 * 能拿到 console 日志、JS 异常、网络请求失败，并执行真实点击/按键。
 */
const { spawn } = require('child_process');
const fs = require('fs');
const os = require('os');
const path = require('path');

const EDGE = 'C:\\Program Files (x86)\\Microsoft\\Edge\\Application\\msedge.exe';
const PORT = 9333;
const URL = 'http://127.0.0.1:3000/index.html';
const OUT = 'D:\\Games\\永不复还(500F)\\永不复还(500F)\\_analysis\\cdp_';
const udd = path.join(os.tmpdir(), 'edge-cdp-' + Date.now());

const logs = [];
const errors = [];
const netFails = [];

function sleep(ms) { return new Promise(r => setTimeout(r, ms)); }

(async () => {
  const proc = spawn(EDGE, [
    '--headless=new', '--disable-gpu', '--no-first-run', '--no-default-browser-check',
    '--remote-debugging-port=' + PORT, '--user-data-dir=' + udd,
    '--window-size=560,780', 'about:blank'
  ], { stdio: 'ignore', detached: false });

  // 等调试端口就绪
  let list = null;
  for (let i = 0; i < 40; i++) {
    await sleep(500);
    try {
      const r = await fetch(`http://127.0.0.1:${PORT}/json/list`);
      list = await r.json();
      if (list && list.length) break;
    } catch (e) { /* 还没起来 */ }
  }
  if (!list || !list.length) { console.log('无法连接调试端口'); proc.kill(); process.exit(1); }

  const target = list.find(t => t.type === 'page') || list[0];
  const ws = new WebSocket(target.webSocketDebuggerUrl);
  let id = 0;
  const pending = new Map();

  function send(method, params = {}) {
    return new Promise((resolve, reject) => {
      const mid = ++id;
      pending.set(mid, { resolve, reject });
      ws.send(JSON.stringify({ id: mid, method, params }));
      setTimeout(() => { if (pending.has(mid)) { pending.delete(mid); resolve(null); } }, 15000);
    });
  }

  await new Promise(r => ws.addEventListener('open', r));
  ws.addEventListener('message', ev => {
    const msg = JSON.parse(ev.data);
    if (msg.id && pending.has(msg.id)) { pending.get(msg.id).resolve(msg.result); pending.delete(msg.id); return; }
    if (msg.method === 'Runtime.consoleAPICalled') {
      const txt = (msg.params.args || []).map(a => a.value !== undefined ? a.value : a.description).join(' ');
      logs.push(`[${msg.params.type}] ${txt}`);
    }
    if (msg.method === 'Runtime.exceptionThrown') {
      const d = msg.params.exceptionDetails;
      errors.push(`异常: ${d.text} ${d.exception && d.exception.description ? d.exception.description.split('\n')[0] : ''}`);
    }
    if (msg.method === 'Log.entryAdded') {
      const e = msg.params.entry;
      if (e.level === 'error') errors.push(`[${e.source}] ${e.text}`);
      else logs.push(`[${e.level}] ${e.text}`);
    }
    if (msg.method === 'Network.loadingFailed') {
      netFails.push(`${msg.params.type} ${msg.params.errorText}`);
    }
    if (msg.method === 'Network.responseReceived') {
      const r = msg.params.response;
      if (r.status >= 400) netFails.push(`HTTP ${r.status} ${r.url}`);
    }
  });

  await send('Runtime.enable');
  await send('Log.enable');
  await send('Network.enable');
  await send('Page.enable');

  console.log('导航到游戏...');
  await send('Page.navigate', { url: URL });
  await sleep(18000);

  async function shot(name) {
    const r = await send('Page.captureScreenshot', { format: 'png' });
    if (r && r.data) {
      fs.writeFileSync(OUT + name + '.png', Buffer.from(r.data, 'base64'));
      console.log(`  截图 ${name}: ${fs.statSync(OUT + name + '.png').size} B`);
    }
  }

  // 真实鼠标点击（按文本找坐标）
  async function clickText(txt) {
    const r = await send('Runtime.evaluate', {
      expression: `(function(){
        var els=document.querySelectorAll('div,span,button,a');
        for(var i=0;i<els.length;i++){
          if((els[i].textContent||'').trim()===${JSON.stringify(txt)} && els[i].children.length===0){
            var b=els[i].getBoundingClientRect();
            if(b.width>0&&b.height>0) return JSON.stringify({x:Math.round(b.left+b.width/2),y:Math.round(b.top+b.height/2)});
          }
        }
        return '';
      })()`,
      returnByValue: true
    });
    const v = r && r.result && r.result.value;
    if (!v) { console.log(`  未找到按钮: ${txt}`); return false; }
    const { x, y } = JSON.parse(v);
    for (const type of ['mousePressed', 'mouseReleased']) {
      await send('Input.dispatchMouseEvent', { type, x, y, button: 'left', clickCount: 1 });
    }
    console.log(`  点击「${txt}」@(${x},${y})`);
    return true;
  }

  async function pressKey(key, code, keyCode) {
    for (const type of ['keyDown', 'keyUp']) {
      await send('Input.dispatchKeyEvent', { type, key, code, windowsVirtualKeyCode: keyCode, nativeVirtualKeyCode: keyCode });
    }
  }

  await shot('1_title');

  console.log('\n--- 点击 开始游戏 ---');
  await clickText('开始游戏');
  await sleep(3000);
  await shot('2_difficulty');

  console.log('\n--- 点击 简单 ---');
  await clickText('简单');
  await sleep(4000);
  await shot('3_after_difficulty');

  console.log('\n--- 连按回车/空格推进剧情 ---');
  for (let i = 0; i < 15; i++) {
    await pressKey('Enter', 'Enter', 13);
    await sleep(300);
    await pressKey(' ', 'Space', 32);
    await sleep(300);
  }
  await sleep(2000);
  await shot('4_gameplay');

  // 读取游戏内部状态
  const st = await send('Runtime.evaluate', {
    expression: `(function(){
      try{
        if(typeof core==='undefined') return 'core 未定义';
        var o={};
        o.floorId = core.status && core.status.floorId;
        o.hero = core.status && core.status.hero && core.status.hero.loc;
        o.eventId = core.status && core.status.event && core.status.event.id;
        o.eventData = core.status && core.status.event && core.status.event.data;
        o.mapSize = core.status && core.status.map && core.status.map.length;
        o.canvasCount = document.querySelectorAll('canvas').length;
        o.gameGroup = (function(){var g=document.getElementById('gameGroup');if(!g)return null;var r=g.getBoundingClientRect();return [Math.round(r.width),Math.round(r.height)];})();
        o.curFloorName = core.status && core.status.thisMap && core.status.thisMap.title;
        return JSON.stringify(o);
      }catch(e){ return '读取状态出错: '+e.message; }
    })()`,
    returnByValue: true
  });
  console.log('\n=== 游戏内部状态 ===');
  console.log(' ', st && st.result && st.result.value);

  console.log('\n=== console 日志（最后 25 条）===');
  logs.slice(-25).forEach(l => console.log('  ' + l.slice(0, 200)));
  console.log('\n=== 错误 (' + errors.length + ') ===');
  errors.slice(0, 25).forEach(e => console.log('  ' + e.slice(0, 250)));
  console.log('\n=== 网络失败 (' + netFails.length + ') ===');
  [...new Set(netFails)].slice(0, 25).forEach(f => console.log('  ' + f.slice(0, 200)));

  ws.close();
  try { proc.kill(); } catch (e) {}
  process.exit(0);
})().catch(e => { console.log('脚本出错:', e.message); process.exit(1); });
