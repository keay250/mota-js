import zlib
from rubymarshal.reader import load
from rubymarshal.writer import dump
import shutil

scripts_path = "/Users/zt-lin/Document/永不复还/Data/Scripts.rxdata"
backup_path = "/Users/zt-lin/Document/永不复还/Data/Scripts.rxdata.bak"

# 1. 备份原版
shutil.copyfile(scripts_path, backup_path)
print(f"Backed up to {backup_path}")

# 2. 读取
with open(scripts_path, "rb") as f:
    scripts_data = load(f)

# 3. 定位 112 号脚本
target_idx = 112
item = scripts_data[target_idx]
s_id = item[0]
s_name = item[1]
compressed = item[2]

code_bytes = zlib.decompress(compressed)
code_str = code_bytes.decode("utf-8")

old_snippet = "break if @soulcost+a[3].to_i>$game_variables[197]"
new_snippet = "return if @soulcost+a[3].to_i>$game_variables[197]"

if old_snippet in code_str:
    print("Found invalid break snippet! Replacing...")
    code_str = code_str.replace(old_snippet, new_snippet)
    new_compressed = zlib.compress(code_str.encode("utf-8"))
    
    # 重新赋值
    if len(item) == 3:
        scripts_data[target_idx] = [s_id, s_name, new_compressed]
    else:
        scripts_data[target_idx] = [s_id, s_name, new_compressed] + list(item[3:])
        
    with open(scripts_path, "wb") as f:
        dump(f, scripts_data)
    print("Successfully patched Scripts.rxdata!")
else:
    print("Snippet not found! Checking...")
