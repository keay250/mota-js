# -*- coding: utf-8 -*-
"""重新提取 System.rxdata：术语、菜单词条、元素表、开关名、变量名。"""
import os, sys
sys.path.insert(0, r'D:\Games\永不复还(500F)\永不复还(500F)\_analysis')
from rubymarshal.reader import load

ROOT = r'D:\Games\永不复还(500F)\永不复还(500F)'
OUTDIR = os.path.join(ROOT, '游戏文本档案')

def A(o):
    a = getattr(o, 'attributes', None)
    return a if isinstance(a, dict) else {}

def dec(v):
    if isinstance(v, bytes):
        return v.decode('utf-8', 'replace')
    return v if isinstance(v, str) else str(v)

d = load(open(os.path.join(ROOT, 'Data', 'System.rxdata'), 'rb'))
a = A(d)
print('System 顶层字段:', list(a.keys()))

W = []
W.append('# 系统术语 · 元素 · 开关 · 变量')
W.append('')
W.append('> 这张表是理解游戏的钥匙：开关名和变量名直接揭示了作者的设计意图。')
W.append('')

# ---- 术语
terms = A(a.get('@terms'))
if terms:
    W.append('## 术语表（@terms）')
    W.append('')
    W.append('| 字段 | 文本 |')
    W.append('|---|---|')
    for k, v in terms.items():
        W.append(f'| `{k}` | {dec(v)} |')
    W.append('')

# ---- 菜单词条
words = A(a.get('@words'))
if words:
    W.append('## 菜单词条（@words）')
    W.append('')
    W.append('| 字段 | 文本 |')
    W.append('|---|---|')
    for k, v in words.items():
        W.append(f'| `{k}` | {dec(v)} |')
    W.append('')

# ---- 元素表
els = a.get('@elements')
if isinstance(els, list):
    W.append(f'## 属性/元素表（@elements，共 {len(els)} 项）')
    W.append('')
    for i, e in enumerate(els):
        t = dec(e)
        if t: W.append(f'- `{i}` {t}')
    W.append('')

# ---- 开关名
sw = a.get('@switches')
if isinstance(sw, list):
    named = [(i, dec(x)) for i, x in enumerate(sw) if dec(x).strip()]
    W.append(f'## 开关名（@switches，共 {len(sw)} 个，其中 {len(named)} 个有名字）')
    W.append('')
    for i, t in named:
        W.append(f'- 开关[{i}] = **{t}**')
    W.append('')

# ---- 变量名
vr = a.get('@variables')
if isinstance(vr, list):
    named = [(i, dec(x)) for i, x in enumerate(vr) if dec(x).strip()]
    W.append(f'## 变量名（@variables，共 {len(vr)} 个，其中 {len(named)} 个有名字）')
    W.append('')
    for i, t in named:
        W.append(f'- 变量[{i}] = **{t}**')
    W.append('')

# ---- 其它标量
W.append('## 其它')
W.append('')
for f in ('@game_title', '@currency_unit', '@version_id', '@party_members', '@title_name',
          '@battleback_name', '@battle_transition', '@magic_number'):
    v = a.get(f)
    if v is not None:
        W.append(f'- `{f}` = {dec(v)}')
W.append('')

open(os.path.join(OUTDIR, '96-系统术语.md'), 'w', encoding='utf-8').write('\n'.join(W))
print('写出 96-系统术语.md', len(W), '行')
