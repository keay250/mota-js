import os
import re

SCRIPTS_DIR = "/Users/zt-lin/Document/永不复还/移植包-永不复还转mota-js/_analysis/_ybfh_scripts"

def check_script(filepath):
    with open(filepath, "r", encoding="utf-8", errors="replace") as f:
        lines = f.readlines()
        
    invalid_breaks = []
    
    # 模拟简单的块作用域跟踪
    stack = []
    for line_no, line in enumerate(lines, 1):
        stripped = line.strip()
        if stripped.startswith("#"):
            continue
            
        # 简单分词/模式
        # 检测循环开始
        is_loop = False
        if re.search(r'\b(while|until|for)\b', stripped) and not re.search(r'\b(while|until)\b\s*$', stripped):
            # 排除修饰符用法：如 `statement while condition`
            if re.match(r'^(while|until|for)\b', stripped):
                is_loop = True
        if re.search(r'\.each\s*(do|\{)', stripped) or re.search(r'\bloop\s*(do|\{)', stripped):
            is_loop = True
            
        # 检测其他块开始
        is_other_block = False
        if re.match(r'^(def|class|module|case|if|unless|begin)\b', stripped):
            is_other_block = True
            
        # 匹配单行的 if / unless 修饰符，不入栈
        # 比如 `do_something if condition` 不是块
        
        # 匹配 break
        # 如果当前行有 break
        m_break = re.search(r'\bbreak\b', stripped)
        if m_break:
            # 排除字符串或注释
            # 检查上下文：最近的循环块
            # 如果外层没有循环或者最近的不是循环
            pass

    return invalid_breaks

# 更直接的检测：直接查找 `break if` 或者 `break` 出现在 `when` 之后但在任何 `for/while` 之前的行
when_breaks = []
for file in sorted(os.listdir(SCRIPTS_DIR)):
    if not file.endswith(".rb"): continue
    filepath = os.path.join(SCRIPTS_DIR, file)
    with open(filepath, "r", encoding="utf-8", errors="replace") as f:
        lines = f.readlines()
        
    in_loop = 0
    in_case = 0
    for idx, line in enumerate(lines, 1):
        stripped = line.strip()
        if stripped.startswith("#"):
            continue
            
        # 进入循环
        if re.match(r'^(for\s+\w+\s+in|while\b|until\b)', stripped):
            in_loop += 1
        elif re.search(r'\.(times|each)\s*(do|\{)', stripped):
            in_loop += 1
            
        # 退出块
        if re.match(r'^end\b', stripped):
            if in_loop > 0:
                in_loop -= 1
            elif in_case > 0:
                in_case -= 1
                
        # 检查 break
        if re.search(r'\bbreak\b', stripped):
            if in_loop == 0:
                when_breaks.append({
                    "file": file,
                    "line_no": idx,
                    "line": stripped
                })

print(f"Total potential invalid breaks (break outside loop): {len(when_breaks)}")
for item in when_breaks:
    print(f"[{item['file']}:{item['line_no']}] {item['line']}")
