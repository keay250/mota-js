# -*- coding: utf-8 -*-
"""把 dialogue_raw.json 按章节拆成便于阅读/整理的文本，输出到 _analysis\story_src\。"""
import os, sys, json, re, collections

ROOT = r'D:\Games\永不复还(500F)\永不复还(500F)'
SRC = os.path.join(ROOT, '_analysis', 'dialogue_raw.json')
OUT = os.path.join(ROOT, '_analysis', 'story_src')
os.makedirs(OUT, exist_ok=True)

recs = json.load(open(SRC, encoding='utf-8'))

# 章节名（从记录里取）
chap_names = {}
for r in recs:
    if r.get('chapter'):
        # 用地图路径里的章节名
        m = re.search(r'第[一二三四五六七八九十]+章[^›]*', r['path'] or '')
        if m:
            chap_names[r['chapter']] = m.group(0).strip()

buckets = collections.defaultdict(list)
for r in recs:
    c = r.get('chapter')
    buckets[c if c is not None else 0].append(r)

print('章节数:', len(buckets))
for c in sorted(buckets, key=lambda x: (x is None, x or 0)):
    rs = buckets[c]
    chars = sum(len(r['text']) for r in rs)
    nm = chap_names.get(c) or ('未归属章节' if not c else f'章节{c}')
    print(f'  {nm:<22} {len(rs):>6} 条 / {chars:>8,} 字')

def render(rs, title):
    L = [f'# {title}', '', f'*原始记录 {len(rs)} 条*', '']
    cur_key = None
    for r in rs:
        key = (r['map'], r['event'], r['page'])
        if key != cur_key:
            cur_key = key
            L.append('')
            L.append(f'--- [地图{r["map"]} {r["map_name"]}] 事件{r["event"]}「{r["event_name"]}」页{r["page"]} ---')
            L.append('')
        if r['kind'] == 'dialog':
            sp = r['speaker']
            L.append(f'{sp}：{r["text"]}')
        elif r['kind'] == 'choice':
            L.append(f'【选项】{r["text"]}')
        elif r['kind'] == 'narration':
            L.append(f'（旁白）{r["text"]}')
        elif r['kind'] == 'note':
            L.append(f'【作者注释】{r["text"]}')
    return '\n'.join(L)

index = []
for i, c in enumerate(sorted(buckets, key=lambda x: (x is None, x or 0)), 1):
    rs = buckets[c]
    nm = chap_names.get(c) or ('未归属章节' if not c else f'章节{c}')
    safe = re.sub(r'[\\/:*?"<>|]', '_', nm)
    fn = f'{i:02d}-{safe}.txt'
    body = render(rs, nm)
    open(os.path.join(OUT, fn), 'w', encoding='utf-8').write(body)
    index.append((fn, len(rs), len(body), nm))
    print(f'  写出 {fn}  {len(body):,} 字符')

json.dump(index, open(os.path.join(OUT, '_index.json'), 'w', encoding='utf-8'), ensure_ascii=False, indent=1)
print()
print('已写出到', OUT)
