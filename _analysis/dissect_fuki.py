# -*- coding: utf-8 -*-
"""解剖 fuki对话 脚本段：对话系统如何决定说话人与形象。"""
import os, sys, zlib, re
sys.path.insert(0, r'D:\Games\永不复还(500F)\永不复还(500F)\_analysis')
from rubymarshal.reader import load

S = r'D:\Games\永不复还(500F)\永不复还(500F)\Data\Scripts.rxdata'
w = load(open(S, 'rb'))

target = None
for seg in w:
    if seg is None: continue
    try:
        nm = seg[1].decode('utf-8', 'replace')
    except Exception:
        continue
    if nm == 'fuki对话':
        target = zlib.decompress(seg[2]).decode('utf-8', 'replace')
        break

if target is None:
    print('找不到 fuki对话'); sys.exit(1)

print('fuki对话 段长度:', len(target), '字符')
lines = target.split('\n')
print('总行数:', len(lines))
print()
print('=== 类与方法清单 ===')
for i, l in enumerate(lines):
    if re.match(r'\s*(class|module)\s+\S+', l) or re.match(r'\s*def\s+\S+', l):
        print(f'  {i+1:>5}: {l.strip()[:100]}')

print()
print('=== set_namewindow 实现（含上下文）===')
for i, l in enumerate(lines):
    if 'def set_namewindow' in l:
        for k in range(max(0, i - 6), min(len(lines), i + 34)):
            print(f'  {k+1:>5}: {lines[k][:120]}')
        break

print()
print('=== 搜反斜杠 m 控制符 / 名字窗口相关 ===')
pats = [r'\\m', r'kkme', r'@name_window', r'show_name', r'name=', r'\\n\[']
for p in pats:
    cnt = 0
    print(f'--- 模式 {p} ---')
    for i, l in enumerate(lines):
        if re.search(p, l):
            print(f'  {i+1:>5}: {l.strip()[:110]}')
            cnt += 1
            if cnt >= 12: break
    if cnt == 0: print('   (无)')
