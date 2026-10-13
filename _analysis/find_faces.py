# -*- coding: utf-8 -*-
"""查清游戏如何显示「说话人形象」：搜 set_namewindow / \m[] / 立绘相关代码。"""
import os, sys, zlib, re
sys.path.insert(0, r'D:\Games\永不复还(500F)\永不复还(500F)\_analysis')
from rubymarshal.reader import load

S = r'D:\Games\永不复还(500F)\永不复还(500F)\Data\Scripts.rxdata'
w = load(open(S, 'rb'))

PATTERNS = [
    ('set_namewindow', r'set_namewindow'),
    ('namewindow', r'namewindow'),
    ('\\m[ 处理', r'\\\\m\['),
    ('definition of \\m', r"'\\\\m'|\"\\\\m\""),
    ('face/pictures', r'Graphics/(Pictures|Faces|Battlers|Characters)'),
    ('draw_face', r'draw_face|face_name|face_index'),
    ('Window_Message', r'class Window_Message'),
]

hits = {k: [] for k, _ in PATTERNS}
for seg in w:
    if seg is None: continue
    try:
        name = seg[1].decode('utf-8', 'replace')
        code = zlib.decompress(seg[2]).decode('utf-8', 'replace')
    except Exception:
        continue
    for label, pat in PATTERNS:
        for m in re.finditer(pat, code):
            line_no = code[:m.start()].count('\n') + 1
            line = code.split('\n')[line_no - 1].strip()
            hits[label].append((name, line_no, line[:120]))

for label, _ in PATTERNS:
    lst = hits[label]
    print(f'===== {label}  ({len(lst)} 处) =====')
    seen = set()
    for name, ln, line in lst[:25]:
        key = (name, line)
        if key in seen: continue
        seen.add(key)
        print(f'  [{name}:{ln}] {line}')
    print()
