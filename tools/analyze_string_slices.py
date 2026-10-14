import os
import re

SCRIPTS_DIR = "/Users/zt-lin/Document/永不复还/移植包-永不复还转mota-js/_analysis/_ybfh_scripts"

# 查找所有包含中文字符串比较的切片
chinese_char = re.compile(r'[\u4e00-\u9fa5]')
slice_str = re.compile(r'(\w+(?:\.\w+)*\[\s*\d+\s*,\s*\d+\s*\]\s*==\s*"([^"]+)")')

found_comparisons = []
for file in sorted(os.listdir(SCRIPTS_DIR)):
    if not file.endswith(".rb"):
        continue
    filepath = os.path.join(SCRIPTS_DIR, file)
    with open(filepath, "r", encoding="utf-8", errors="replace") as f:
        for idx, line in enumerate(f, 1):
            stripped = line.strip()
            if stripped.startswith("#"):
                continue
            for match in slice_str.finditer(line):
                full_expr = match.group(1)
                target_str = match.group(2)
                if chinese_char.search(target_str):
                    found_comparisons.append({
                        "file": file,
                        "line_no": idx,
                        "expr": full_expr,
                        "str": target_str,
                        "str_len": len(target_str),
                        "str_bytes_utf8": len(target_str.encode("utf-8")),
                        "str_bytes_gbk": len(target_str.encode("gbk", errors="ignore")),
                        "line": stripped
                    })

print(f"Total Chinese string slice comparisons found: {len(found_comparisons)}")
for item in found_comparisons[:30]:
    print(f"[{item['file']}:{item['line_no']}] {item['line']}")
    print(f"   -> target: '{item['str']}', char_len={item['str_len']}, utf8_bytes={item['str_bytes_utf8']}, gbk_bytes={item['str_bytes_gbk']}")
