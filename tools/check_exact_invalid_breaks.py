import os
import re

SCRIPTS_DIR = "/Users/zt-lin/Document/永不复还/移植包-永不复还转mota-js/_analysis/_ybfh_scripts"

def analyze_file(filepath):
    with open(filepath, "r", encoding="utf-8", errors="replace") as f:
        lines = f.readlines()

    # 精确栈追踪
    block_stack = []
    invalid_breaks = []

    # 关键字正则
    re_def = re.compile(r'^\s*def\b')
    re_class = re.compile(r'^\s*(class|module)\b')
    re_loop = re.compile(r'^\s*(while|until|for)\b|(\.each|\.times|\bloop)\s*(\{|do\b)')
    re_case = re.compile(r'^\s*case\b')
    re_begin = re.compile(r'^\s*begin\b')
    re_if = re.compile(r'^\s*(if|unless)\b')
    re_end = re.compile(r'^\s*end\b')
    re_break = re.compile(r'\bbreak\b')

    for idx, raw_line in enumerate(lines, 1):
        line = raw_line.split("#")[0].strip()
        if not line:
            continue

        # 检查是否包含 break
        if re_break.search(line):
            # 检查当前栈中是否有 loop
            has_loop = any(b == 'loop' for b in block_stack)
            if not has_loop:
                invalid_breaks.append((idx, raw_line.strip(), list(block_stack)))

        # 块进出
        # 简单块进入判定（排除单行修饰符，如 `break if cond` 或 `stmt while cond`）
        words = line.split()
        first_word = words[0] if words else ""

        if re_loop.search(line) and not re.search(r'\b(while|until)\b\s*$', line) and first_word in ['while', 'until', 'for'] or re.search(r'(\.each|\.times|\bloop)\s*(\{|do\b)', line):
            block_stack.append('loop')
        elif first_word in ['def']:
            block_stack.append('def')
        elif first_word in ['class', 'module']:
            block_stack.append('class')
        elif first_word in ['case']:
            block_stack.append('case')
        elif first_word in ['begin']:
            block_stack.append('begin')
        elif first_word in ['if', 'unless']:
            block_stack.append('if')

        if first_word == 'end':
            if block_stack:
                block_stack.pop()

    return invalid_breaks

all_invalids = []
for file in sorted(os.listdir(SCRIPTS_DIR)):
    if not file.endswith(".rb"): continue
    path = os.path.join(SCRIPTS_DIR, file)
    res = analyze_file(path)
    for line_no, content, stack in res:
        all_invalids.append((file, line_no, content, stack))

print(f"Total REAL invalid breaks found: {len(all_invalids)}")
for f, l, c, s in all_invalids:
    print(f"[{f}:{l}] {c} (Stack: {s})")
