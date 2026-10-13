# -*- coding: utf-8 -*-
"""从 dialogue_raw.json 统计出场人物，生成附录：人物表。"""
import os, sys, json, re, collections

ROOT = r'D:\Games\永不复还(500F)\永不复还(500F)'
recs = json.load(open(os.path.join(ROOT, '_analysis', 'dialogue_raw.json'), encoding='utf-8'))
OUT = os.path.join(ROOT, '游戏剧情小说', '附录-人物表.md')

CTRL = re.compile(r'\\[a-z]')
def looks_like_text(s):
    if not s: return True
    if CTRL.search(s): return True
    if len(s) > 12: return True
    if re.search(r'[，。！？、；：]', s): return True
    if re.search(r'价格|购买|出售|需要|消耗|钥匙|存档|设置|菜单|按.*键|点击|积分|层|模式|说明|提示|注意', s): return True
    return False

sp = collections.Counter()
first = {}
chaps = collections.defaultdict(set)
for r in recs:
    if r['kind'] != 'dialog': continue
    s = r['speaker']
    if looks_like_text(s): continue
    sp[s] += 1
    if s not in first:
        first[s] = (r['map'], r['map_name'], r.get('chapter'))
    if r.get('chapter'):
        chaps[s].add(r['path'].split('›')[1].strip() if '›' in (r['path'] or '') else '')

# 章节序号
def chap_no(path):
    m = re.search(r'第([一二三四五六七八九十]+)章', path or '')
    return m.group(1) if m else '?'

named = [(k, v) for k, v in sp.items() if v >= 8]
monster = [(k, v) for k, v in named if re.match(r'^\d+[-－]', k)]
people = [(k, v) for k, v in named if not re.match(r'^\d+[-－]', k)]

L = ['# 附录 · 人物表', '',
     f'*统计自全部对话记录（{sum(1 for r in recs if r["kind"]=="dialog"):,} 条），已剔除系统提示类伪说话人。*',
     f'*共出现 **{len(sp)}** 个说话人标签，下表列出台词数 ≥ 8 句的 **{len(named)}** 个。*', '',
     '---', '', '## 一、主要人物（按台词数排序）', '',
     '| 角色 | 台词数 | 首次出场 |', '|---|---|---|']
for k, v in sorted(people, key=lambda x: -x[1]):
    m, mn, ch = first.get(k, ('', '', None))
    L.append(f'| **{k}** | {v} | 地图{m} {mn} |')
L += ['', '---', '', '## 二、敌手与怪物（带编号标签）', '',
      '| 标签 | 台词数 | 首次出场 |', '|---|---|---|']
for k, v in sorted(monster, key=lambda x: -x[1]):
    m, mn, ch = first.get(k, ('', '', None))
    L.append(f'| {k} | {v} | 地图{m} {mn} |')

L += ['', '---', '', '## 三、台词数少于 8 句的角色', '',
      '| 角色 | 台词数 |', '|---|---|']
rest = sorted([(k, v) for k, v in sp.items() if v < 8 and not looks_like_text(k)], key=lambda x: -x[1])
for k, v in rest[:400]:
    L.append(f'| {k} | {v} |')
if len(rest) > 400:
    L.append(f'| *（其余 {len(rest)-400} 个略）* | |')

open(OUT, 'w', encoding='utf-8').write('\n'.join(L))
print('写出', OUT, len(L), '行')
print()
print('台词最多的 25 个角色:')
for k, v in sorted(people, key=lambda x: -x[1])[:25]:
    print(f'  {v:>5}  {k}')
