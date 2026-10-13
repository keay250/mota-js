# -*- coding: utf-8 -*-
"""把游戏内全部文本提取成 Markdown 档案。

输出目录：<游戏根>\游戏文本档案\
  00-章节与地图总览.md
  NN-第X章-xxx.md        （每章一份，含该章所有地图的对话）
  90-物品图鉴.md  91-装备图鉴.md  92-技能图鉴.md
  93-敌人图鉴.md  94-角色职业状态.md  95-公共事件文本.md
  99-附录-系统与模板地图.md
  README.md
"""
import os, sys, re, glob, json
sys.path.insert(0, r'D:\Games\永不复还(500F)\永不复还(500F)\_analysis')
from rubymarshal.reader import load

ROOT = r'D:\Games\永不复还(500F)\永不复还(500F)'
DATA = os.path.join(ROOT, 'Data')
OUTDIR = os.path.join(ROOT, '游戏文本档案')
os.makedirs(OUTDIR, exist_ok=True)

def A(o):
    a = getattr(o, 'attributes', None)
    return a if isinstance(a, dict) else {}

def dec(v):
    if isinstance(v, bytes):
        return v.decode('utf-8', 'replace')
    return v if isinstance(v, str) else str(v)

def safe(name):
    return re.sub(r'[\\/:*?"<>|]', '_', name).strip()

# ---------------------------------------------------------------- MapInfos
mi = load(open(os.path.join(DATA, 'MapInfos.rxdata'), 'rb'))
infos = {}
src = mi.items() if isinstance(mi, dict) else enumerate(mi)
for k, v in src:
    if v is None: continue
    a = A(v)
    infos[int(k)] = {'name': dec(a.get('@name', '')), 'parent': a.get('@parent_id') or 0,
                     'order': a.get('@order') or 0}

CHAP_RE = re.compile(r'第[一二三四五六七八九十]+章')
def chapter_of(mid):
    """向上找最近的「第X章」祖先，返回 (章节地图ID, 章节名)；找不到返回 (None, None)。"""
    cur, guard = mid, 0
    while cur and guard < 40:
        info = infos.get(cur)
        if not info: break
        if CHAP_RE.search(info['name']):
            return cur, info['name']
        cur = info['parent']
        guard += 1
    return None, None

def path_of(mid):
    """返回从根到该地图的名字路径。"""
    parts, cur, guard = [], mid, 0
    while cur and guard < 40:
        info = infos.get(cur)
        if not info: break
        parts.append(info['name'])
        cur = info['parent']
        guard += 1
    return ' › '.join(reversed(parts))

# ---------------------------------------------------------------- 地图文本提取
TEXT_CODES = (401, 405, 408)
SCRIPT_CODES = (355, 655)
NOTE_CODES = (108, 408)
CN = re.compile(r'[\u4e00-\u9fff]')

def extract_map(mid):
    """返回 {'dialogs':[...], 'choices':[...], 'notes':[...], 'scripts':[...]}"""
    path = os.path.join(DATA, f'Map{mid:03d}.rxdata')
    if not os.path.exists(path):
        return None
    try:
        m = load(open(path, 'rb'))
    except Exception as e:
        return {'error': str(e)}
    events = A(m).get('@events') or {}
    out = {'dialogs': [], 'choices': [], 'notes': [], 'scripts': []}
    for eid in sorted(events.keys()):
        ev = events[eid]
        ea = A(ev)
        ename = dec(ea.get('@name', ''))
        pages = ea.get('@pages') or []
        for pi, page in enumerate(pages):
            cmds = A(page).get('@list') or []
            cmds = [A(c) for c in cmds]
            k = 0
            while k < len(cmds):
                c = cmds[k]
                code = c.get('@code')
                params = c.get('@parameters') or []
                # —— 显示文章：101 后跟若干 401
                if code == 101:
                    face = dec(params[0]) if params else ''
                    block = []
                    k += 1
                    while k < len(cmds) and cmds[k].get('@code') == 401:
                        block.append(dec((cmds[k].get('@parameters') or [''])[0]))
                        k += 1
                    if any(x.strip() for x in block):
                        out['dialogs'].append({'event': eid, 'name': ename, 'page': pi + 1,
                                               'face': face, 'lines': block})
                    continue
                # —— 选择项：102
                if code == 102:
                    opts = params[0] if params and isinstance(params[0], list) else []
                    opts = [dec(x) for x in opts]
                    if opts:
                        out['choices'].append({'event': eid, 'name': ename, 'page': pi + 1, 'options': opts})
                    k += 1
                    continue
                # —— 注释：108 + 408
                if code == 108:
                    block = []
                    k += 1
                    while k < len(cmds) and cmds[k].get('@code') == 408:
                        block.append(dec((cmds[k].get('@parameters') or [''])[0]))
                        k += 1
                    txt = '\n'.join(block).strip()
                    if txt and CN.search(txt):
                        out['notes'].append({'event': eid, 'name': ename, 'page': pi + 1, 'text': txt})
                    continue
                # —— 脚本：355 + 655（只留含中文的）
                if code == 355:
                    block = []
                    k += 1
                    while k < len(cmds) and cmds[k].get('@code') == 655:
                        block.append(dec((cmds[k].get('@parameters') or [''])[0]))
                        k += 1
                    txt = '\n'.join(block).strip()
                    if txt and CN.search(txt):
                        # 只保留像是"对白/提示"的行
                        keep = [l for l in txt.split('\n')
                                if CN.search(l) and not re.match(r'\s*(#|def |end\b|if |else|elsif|when |case )', l)]
                        if keep:
                            out['scripts'].append({'event': eid, 'name': ename, 'page': pi + 1,
                                                   'text': '\n'.join(keep)})
                    continue
                k += 1
    return out

maps = sorted(int(re.search(r'Map(\d+)\.rxdata$', p).group(1))
              for p in glob.glob(os.path.join(DATA, 'Map*.rxdata'))
              if re.search(r'Map\d+\.rxdata$', p))
print('地图总数:', len(maps))

by_chapter = {}     # chap_id -> {'name':..., 'maps': {mid: data}}
orphan = {}
for i, mid in enumerate(maps):
    data = extract_map(mid)
    if data is None or 'error' in (data or {}):
        continue
    if not (data['dialogs'] or data['choices'] or data['notes'] or data['scripts']):
        continue
    cid, cname = chapter_of(mid)
    if cid is None:
        orphan[mid] = data
    else:
        by_chapter.setdefault(cid, {'name': cname, 'maps': {}})
        by_chapter[cid]['maps'][mid] = data
    if (i + 1) % 100 == 0:
        print(f'  ...{i+1}/{len(maps)}')

print('章节数:', len(by_chapter), ' 未归属地图:', len(orphan))

# ---------------------------------------------------------------- 写章节文件
def map_body(mid, data):
    L = []
    name = infos.get(mid, {}).get('name', '')
    L.append(f'## [{mid}] {name}')
    L.append('')
    L.append(f'*路径：{path_of(mid)}*')
    L.append('')
    if data['dialogs']:
        # 同一「事件+页码」的连续对话合并到一个小节；连续同一说话人只标一次名字
        groups, order = {}, []
        for dd in data['dialogs']:
            key = (dd['event'], dd['page'])
            if key not in groups:
                groups[key] = []
                order.append(key)
            groups[key].append(dd)
        for (eid_, page_) in order:
            blocks = groups[(eid_, page_)]
            L.append(f'### 事件{eid_}「{blocks[0]["name"]}」页{page_}')
            L.append('')
            prev_sp = None
            for b in blocks:
                sp = (b.get('face') or '').rstrip('：: ').strip()
                if sp and sp != prev_sp:
                    L.append(f'**{sp}：**')
                    L.append('')
                    prev_sp = sp
                for line in b['lines']:
                    L.append('> ' + line.replace('\n', '  '))
                L.append('>')
            if L and L[-1] == '>':
                L.pop()
            L.append('')
            L.append('')
    if data['choices']:
        for c in data['choices']:
            L.append(f"**[选项]** 事件{c['event']}「{c['name']}」页{c['page']}：" +
                     ' / '.join(f'`{o}`' for o in c['options']))
            L.append('')
    if data['scripts']:
        L.append('<details><summary>脚本内嵌文本</summary>')
        L.append('')
        for s in data['scripts']:
            L.append(f"- 事件{s['event']}「{s['name']}」页{s['page']}：")
            for line in s['text'].split('\n'):
                L.append(f'  - `{line.strip()}`')
        L.append('')
        L.append('</details>')
        L.append('')
    if data['notes']:
        L.append('<details><summary>作者注释</summary>')
        L.append('')
        for n in data['notes']:
            L.append(f"- 事件{n['event']}「{n['name']}」页{n['page']}：")
            for line in n['text'].split('\n'):
                L.append(f'  > {line}')
        L.append('')
        L.append('</details>')
        L.append('')
    return '\n'.join(L)

written = []
chap_sorted = sorted(by_chapter.items(), key=lambda kv: infos.get(kv[0], {}).get('order', kv[0]))
for idx, (cid, ch) in enumerate(chap_sorted, 1):
    fname = f'{idx:02d}-{safe(ch["name"])}.md'
    L = [f'# {ch["name"]}', '', f'*本章共 {len(ch["maps"])} 张有文本的地图*', '', '---', '']
    for mid in sorted(ch['maps'].keys()):
        L.append(map_body(mid, ch['maps'][mid]))
        L.append('---')
        L.append('')
    body = '\n'.join(L)
    open(os.path.join(OUTDIR, fname), 'w', encoding='utf-8').write(body)
    written.append((fname, len(body), ch['name'], len(ch['maps'])))
    print(f'  写出 {fname}  {len(body):,} 字符  ({len(ch["maps"])} 张地图)')

if orphan:
    L = ['# 附录：系统与模板地图', '', f'*共 {len(orphan)} 张未归属章节的地图*', '', '---', '']
    for mid in sorted(orphan.keys()):
        L.append(map_body(mid, orphan[mid]))
        L.append('---')
        L.append('')
    body = '\n'.join(L)
    open(os.path.join(OUTDIR, '99-附录-系统与模板地图.md'), 'w', encoding='utf-8').write(body)
    print(f'  写出 99-附录-系统与模板地图.md  {len(body):,} 字符  ({len(orphan)} 张地图)')

json.dump({'chapters': [{'id': c, 'name': n, 'maps': sorted(m)} for c, (n, m) in
                        [(k, (v['name'], v['maps'])) for k, v in by_chapter.items()]]},
          open(os.path.join(OUTDIR, '_chapters.json'), 'w', encoding='utf-8'), ensure_ascii=False, indent=1)
print()
print('章节文件完成')
