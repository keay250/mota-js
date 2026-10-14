import os
import zlib
import re
from rubymarshal.reader import load

SCRIPTS_PATH = "/Users/zt-lin/Document/永不复还/Data/Scripts.rxdata"
COMMON_EVENTS_PATH = "/Users/zt-lin/Document/永不复还/Data/CommonEvents.rxdata"
OUTPUT_DIR = "/Users/zt-lin/Document/永不复还/移植包-永不复还转mota-js/_analysis/_ybfh_scripts"
os.makedirs(OUTPUT_DIR, exist_ok=True)

with open(SCRIPTS_PATH, "rb") as f:
    scripts_data = load(f)

print(f"Total script sections: {len(scripts_data)}")

scripts_list = []
total_lines = 0

for idx, item in enumerate(scripts_data):
    s_id = item[0]
    s_name_raw = item[1]
    s_code_compressed = item[2]
    
    # 解码名称
    try:
        s_name = s_name_raw.decode("utf-8")
    except UnicodeDecodeError:
        try:
            s_name = s_name_raw.decode("gbk")
        except Exception:
            s_name = f"script_{idx}"
            
    # 清理文件名非法字符
    safe_name = re.sub(r'[/\\:*?"<>|]', '_', s_name).strip()
    if not safe_name:
        safe_name = f"empty_{idx}"
    file_name = f"{idx:03d}_{safe_name}.rb"
    
    try:
        code_bytes = zlib.decompress(s_code_compressed)
        # 尝试 utf-8，其次 gbk
        try:
            code_text = code_bytes.decode("utf-8")
            encoding = "utf-8"
        except UnicodeDecodeError:
            try:
                code_text = code_bytes.decode("gbk")
                encoding = "gbk"
            except UnicodeDecodeError:
                code_text = code_bytes.decode("gbk", errors="replace")
                encoding = "gbk_lossy"
    except Exception as e:
        code_text = ""
        encoding = "error"
        print(f"Error decompressing {s_name}: {e}")
        
    lines = code_text.splitlines()
    total_lines += len(lines)
    
    # 写入单个 rb 文件以供随时审查
    out_file = os.path.join(OUTPUT_DIR, file_name)
    with open(out_file, "w", encoding="utf-8", errors="replace") as out_f:
        out_f.write(code_text)
        
    scripts_list.append({
        "index": idx,
        "id": s_id,
        "name": s_name,
        "file": file_name,
        "lines": lines,
        "line_count": len(lines),
        "encoding": encoding
    })

print(f"Successfully extracted {len(scripts_list)} scripts, total {total_lines} lines.")

# 1. 扫描 Win32API
win32_hits = []
for s in scripts_list:
    for line_no, line in enumerate(s["lines"], 1):
        if "Win32API" in line or "kernel33" in line or "user33" in line or "screenshot" in line:
            # 提取前后各 2 行
            start_l = max(0, line_no - 3)
            end_l = min(len(s["lines"]), line_no + 2)
            context = "\n".join(f"{l_idx+1:4d}: {s['lines'][l_idx]}" for l_idx in range(start_l, end_l))
            win32_hits.append({
                "script_index": s["index"],
                "script_name": s["name"],
                "line_no": line_no,
                "line": line.strip(),
                "context": context
            })

print(f"\n--- Found {len(win32_hits)} Win32API occurrences ---")
for hit in win32_hits:
    print(f"[{hit['script_index']:03d} {hit['script_name']}] Line {hit['line_no']}: {hit['line']}")

# 2. 扫描 Ruby 1.8 字符串切片 [x, y]
slice_pattern = re.compile(r'(\w+\[\s*\d+\s*,\s*\d+\s*\])')
slice_hits = []
for s in scripts_list:
    for line_no, line in enumerate(s["lines"], 1):
        # 排除纯注释
        stripped = line.strip()
        if stripped.startswith("#"):
            continue
        m = slice_pattern.search(line)
        if m:
            slice_hits.append({
                "script_index": s["index"],
                "script_name": s["name"],
                "line_no": line_no,
                "match": m.group(1),
                "line": line.strip()
            })

print(f"\n--- Found {len(slice_hits)} slice pattern occurrences ---")
for hit in slice_hits[:20]:
    print(f"[{hit['script_index']:03d} {hit['script_name']}] Line {hit['line_no']}: {hit['line']}")
if len(slice_hits) > 20:
    print(f"... and {len(slice_hits) - 20} more.")
