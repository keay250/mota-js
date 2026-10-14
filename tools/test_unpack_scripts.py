import os
import zlib
import re
from rubymarshal.reader import load

scripts_path = "/Users/zt-lin/Document/永不复还/Data/Scripts.rxdata"

with open(scripts_path, "rb") as f:
    scripts_data = load(f)

print(f"Total script sections: {len(scripts_data)}")

# 提取所有脚本，并解压
all_scripts = []
for idx, item in enumerate(scripts_data):
    s_id, s_name_raw, s_code_compressed = item
    try:
        s_name = s_name_raw.decode("utf-8")
    except UnicodeDecodeError:
        try:
            s_name = s_name_raw.decode("gbk")
        except Exception:
            s_name = str(s_name_raw)
            
    try:
        code_bytes = zlib.decompress(s_code_compressed)
        try:
            code_text = code_bytes.decode("utf-8")
        except UnicodeDecodeError:
            code_text = code_bytes.decode("gbk", errors="replace")
    except Exception as e:
        code_text = ""
        print(f"Error decompressing {s_name}: {e}")
        
    all_scripts.append({
        "index": idx,
        "name": s_name,
        "code": code_text,
        "lines": code_text.splitlines()
    })

print(f"Successfully loaded {len(all_scripts)} scripts.")
