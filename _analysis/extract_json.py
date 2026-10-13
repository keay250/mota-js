# -*- coding: utf-8 -*-
"""把 576 张地图的对话导出成结构化 JSON（供剧情清洗/小说化使用）。

每条记录：
  {map, map_name, path, event, event_name, page, speaker, lines[], kind}
kind 由脚本粗判：dialog(有说话人) / narration(无说话人) / script / note
"""
import os, sys, re, glob, json
sys.path.insert(0, r'D:\Games\永不复还(500F)\永不复还(500F)\_analysis')
from rubymarshal.reader import load

ROOT = r'D:\Games\永不复还(500F)\永不复还(500F)'
DATA = os.path.join(ROOT, 'Data')
OUT = os.path.join(ROOT, '_analysis', 'dialogue_raw.json')

def A(o):
    a = getattr(o, 'attributes', None)
    return a if isinstance(a, dict) else {}

def dec(v):
    if isinstance(v, bytes):
        return v.decode('utf-8', 'replace')
    return v if isinstance(v, str) else str(v)

mi = load(open(os.path.join(DATA, 'MapInfos.rxdata'), 'rb'))
infos = {}
for k, v in (mi.items() if isinstance(mi, dict) else enumerate(mi)):
    if v is None: continue
    a = A(v)
    infos[int(k)] = {'name': dec(a.get('@name', '')), 'parent': a.get('@parent_id') or 0,
                     'order': a.get('@order') or 0}

def path_of(mid):
    parts, cur, g = [], mid, 0
    while cur and g < 40:
        i = infos.get(cur)
        if not i: break
        parts.append(i['name']); cur = i['parent']; g += 1
    return ' › '.join(reversed(parts))

def chapter_of(mid):
    cur, g = mid, 0
    while cur and g < 40:
        i = infos.get(cur)
        if not i: return None
        if re.search(r'第[一二三四五六七八九十]+章', i['name']): return cur
        cur = i['parent']; g += 1
    return None

records = []
maps = sorted(int(re.search(r'Map(\d+)\.rxdata$', p).group(1))
              for p in glob.glob(os.path.join(DATA, 'Map*.rxdata'))
              if re.search(r'Map\d+\.rxdata$', p))

for idx, mid in enumerate(maps):
    p = os.path.join(DATA, f'Map{mid:03d}.rxdata')
    if not os.path.exists(p): continue
    try:
        m = load(open(p, 'rb'))
    except Exception:
        continue
    events = A(m).get('@events') or {}
    for eid in sorted(events.keys()):
        ea = A(events[eid])
        ename = dec(ea.get('@name', ''))
        for pi, page in enumerate(ea.get('@pages') or []):
            cmds = [A(c) for c in (A(page).get('@list') or [])]
            k = 0
            while k < len(cmds):
                c = cmds[k]; code = c.get('@code'); params = c.get('@parameters') or []
                if code == 101:
                    face = dec(params[0]) if params else ''
                    block = []
                    k += 1
                    while k < len(cmds) and cmds[k].get('@code') == 401:
                        block.append(dec((cmds[k].get('@parameters') or [''])[0])); k += 1
                    if block:
                        # 标准形式：101 的 params[0] 是说话人，正文在后续 401
                        txt = '\n'.join(block).strip()
                        sp = face.rstrip('：: ').strip()
                    else:
                        # 变体形式：正文直接写在 101 的参数里，可带 \m[名字] 头部
                        raw = face
                        m = re.match(r'\\m\[([^\]]*)\]\s*(.*)', raw, re.S)
                        if m:
                            sp = m.group(1).strip()
                            txt = m.group(2).strip()
                        else:
                            sp = ''
                            txt = raw.strip()
                    if txt:
                        records.append({'map': mid, 'map_name': infos.get(mid, {}).get('name', ''),
                                        'path': path_of(mid), 'chapter': chapter_of(mid),
                                        'event': eid, 'event_name': ename, 'page': pi + 1,
                                        'speaker': sp, 'lines': txt.split('\n'), 'text': txt,
                                        'kind': 'dialog' if sp else 'narration'})
                    continue
                if code == 102:
                    opts = params[0] if params and isinstance(params[0], list) else []
                    opts = [dec(x) for x in opts]
                    if opts:
                        records.append({'map': mid, 'map_name': infos.get(mid, {}).get('name', ''),
                                        'path': path_of(mid), 'chapter': chapter_of(mid),
                                        'event': eid, 'event_name': ename, 'page': pi + 1,
                                        'speaker': '', 'lines': opts, 'text': ' / '.join(opts),
                                        'kind': 'choice'})
                    k += 1
                    continue
                if code in (108, 408):
                    block = []
                    k += 1
                    while k < len(cmds) and cmds[k].get('@code') == 408:
                        block.append(dec((cmds[k].get('@parameters') or [''])[0])); k += 1
                    txt = '\n'.join(block).strip()
                    if txt:
                        records.append({'map': mid, 'map_name': infos.get(mid, {}).get('name', ''),
                                        'path': path_of(mid), 'chapter': chapter_of(mid),
                                        'event': eid, 'event_name': ename, 'page': pi + 1,
                                        'speaker': '', 'lines': block, 'text': txt, 'kind': 'note'})
                    continue
                k += 1
    if (idx + 1) % 100 == 0:
        print(f'  ...{idx+1}/{len(maps)}  记录 {len(records):,}')

json.dump(records, open(OUT, 'w', encoding='utf-8'), ensure_ascii=False)
print('总记录:', len(records))
print('已写出:', OUT, os.path.getsize(OUT) // 1024, 'KB')

# 统计
import collections
c = collections.Counter(r['kind'] for r in records)
print('类型分布:', dict(c))
for kind in ('dialog', 'narration', 'choice', 'note'):
    rs = [r for r in records if r['kind'] == kind]
    chars = sum(len(r['text']) for r in rs)
    print(f'  {kind}: {len(rs):,} 条 / {chars:,} 字')
    if kind in ('narration', 'note'):
        for r in rs[:12]:
            print(f'      [{r["map"]} {r["map_name"][:12]}] {r["text"][:70]}')
