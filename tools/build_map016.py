# -*- coding: utf-8 -*-
"""
构建 Map016 (姆伊森运河 支流) 并与 MT4 无缝对接，重构全线出入口安全落点
"""
import os, sys, re, struct, json
from rubymarshal.reader import load
import PIL.Image as Image

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MOTA_DIR = os.path.join(BASE_DIR, '_analysis', '_ybfh-mota')
RX_DATA_DIR = os.path.join(os.path.dirname(BASE_DIR), 'Data')
RX_GFX_DIR = os.path.join(os.path.dirname(BASE_DIR), 'Graphics')

# 1. 准备渲染器
with open(os.path.join(RX_DATA_DIR, 'Tilesets.rxdata'), 'rb') as f:
    tilesets = load(f)

t4 = tilesets[4]
t_name_raw = t4.attributes.get('@tileset_name') or t4.attributes.get(b'@tileset_name')
t_name = t_name_raw.decode('utf-8', 'ignore') if isinstance(t_name_raw, bytes) else str(t_name_raw)

at_names_raw = t4.attributes.get('@autotile_names') or t4.attributes.get(b'@autotile_names')
at_names = [n.decode('utf-8', 'ignore') if isinstance(n, bytes) else str(n) for n in at_names_raw]

autotile_imgs = {}
for i, an in enumerate(at_names):
    if an:
        p = os.path.join(RX_GFX_DIR, 'Autotiles', f'{an}.png')
        if os.path.exists(p):
            autotile_imgs[i] = Image.open(p).convert('RGBA')

tileset_img = Image.open(os.path.join(RX_GFX_DIR, 'Tilesets', f'{t_name}.png')).convert('RGBA')

autotiles_cpp_path = os.path.join(BASE_DIR, 'tools', 'autotiles.cpp')
with open(autotiles_cpp_path, 'r', encoding='utf-8') as f:
    text = f.read()

matches = re.findall(r'\{\s*([\d\.]+),\s*([\d\.]+),\s*([\d\.]+),\s*([\d\.]+)\s*\}', text)
rects = [(int(float(m[0])), int(float(m[1])), int(float(m[2])), int(float(m[3]))) for m in matches]

def render_tile(tid):
    if tid < 48:
        return None
    if 48 <= tid < 384:
        at_idx = (tid - 48) // 48
        sub_idx = (tid - 48) % 48
        if at_idx in autotile_imgs:
            src = autotile_imgs[at_idx]
            base = sub_idx * 4
            tile = Image.new('RGBA', (32, 32), (0, 0, 0, 0))
            positions = [(0, 0), (16, 0), (0, 16), (16, 16)]
            for i in range(4):
                rx, ry, rw, rh = rects[base + i]
                sub = src.crop((rx, ry, rx + 16, ry + 16))
                tile.paste(sub, positions[i])
            return tile
        return None
    idx = tid - 384
    col = idx % 8
    row = idx // 8
    tile = tileset_img.crop((col * 32, row * 32, (col + 1) * 32, (row + 1) * 32))
    return tile

# 2. 渲染 Map016 背景大图
print("[*] 正在渲染 Map016 背景大图 (map016_bg.png)...")
with open(os.path.join(RX_DATA_DIR, 'Map016.rxdata'), 'rb') as f:
    m16 = load(f)

attrs = m16.attributes
data_bytes = attrs['@data']._private_data
dim, w, h, z, total = struct.unpack('<5i', data_bytes[:20])
tiles = struct.unpack(f'<{total}h', data_bytes[20:])

map_w, map_h = 15, 15
bg_canvas = Image.new('RGBA', (map_w * 32, map_h * 32), (0, 0, 0, 0))

for y in range(map_h):
    for x_prime in range(map_w):
        x = x_prime + 5 # 裁剪原版 x 5..19
        for layer in range(z):
            tid = tiles[layer * (w * h) + y * w + x]
            timg = render_tile(tid)
            if timg:
                bg_canvas.paste(timg, (x_prime * 32, y * 32), timg)

out_bg = os.path.join(MOTA_DIR, 'project', 'images', 'map016_bg.png')
bg_canvas.save(out_bg)
print(f" -> 已保存 Map016 背景图: {out_bg}")

# 3. 构建 MT16 楼层数据
print("[*] 正在构建 MT16 楼层数据...")
flags = t4.attributes['@passages']._private_data

maze = []
for y in range(map_h):
    row = []
    for x_prime in range(map_w):
        x = x_prime + 5
        passable = True
        for layer in range(z):
            tid = tiles[layer * (w * h) + y * w + x]
            if tid < len(flags) and (flags[tid] & 0x0f == 0x0f):
                passable = False
                break
        row.append(0 if passable else 17)
    maze.append(row)

# 确保底部出口 (7, 14) 是通畅的
maze[14][7] = 88

MONSTER_MAP = {
    '怪物002': 201, # 荷依米
    '怪物006': 202, # 倍荷玛
    '怪物004': 203, # 幽林鬼火
    '怪物003': 204, # 软泥怪
    '怪物005': 205, # 荷依米战士
    '怪物007': 209, # 复活的死者
    '怪物008': 210, # 倍荷玛战士
    '怪物009': 211, # 嗜血死者
    '怪物010': 213, # 寒冰软泥怪
    '怪物011': 214, # 荷依米贵族
    '怪物012': 215, # 丛林幽影
    '怪物013': 217, # 流浪法师
    '怪物014': 218, # 倍荷玛拉
    '怪物015': 201, # 绿色史莱姆
}

mota_events = {}
events = attrs['@events']
for eid, ev in sorted(events.items()):
    ea = ev.attributes
    x_orig, y = ea['@x'], ea['@y']
    x_prime = x_orig - 5
    if x_prime < 0 or x_prime >= map_w:
        continue
    
    name = ea['@name'].decode('utf-8', 'replace') if isinstance(ea['@name'], bytes) else str(ea['@name'])
    
    if name in MONSTER_MAP:
        maze[y][x_prime] = MONSTER_MAP[name]
    elif name == '黄门':
        maze[y][x_prime] = 81
    elif name == '蓝门':
        maze[y][x_prime] = 82
    elif name == '红门':
        maze[y][x_prime] = 83
    elif '机关门' in name:
        maze[y][x_prime] = 85
    elif name == '黄钥匙':
        maze[y][x_prime] = 21
        mota_events[f"{x_prime},{y}"] = {
            "trigger": "action",
            "enable": True,
            "data": [
                {"type": "playSound", "name": "item.mp3"},
                {"type": "setValue", "name": "item:yellowKey", "operator": "+=", "value": "1"},
                {"type": "hide", "remove": True}
            ]
        }
    elif name == '蓝钥匙':
        maze[y][x_prime] = 22
        mota_events[f"{x_prime},{y}"] = {
            "trigger": "action",
            "enable": True,
            "data": [
                {"type": "playSound", "name": "item.mp3"},
                {"type": "setValue", "name": "item:blueKey", "operator": "+=", "value": "1"},
                {"type": "hide", "remove": True}
            ]
        }
    elif name == '红宝石:1':
        maze[y][x_prime] = 27
    elif name == '蓝宝石:1':
        maze[y][x_prime] = 28
    elif name == '血瓶:50':
        maze[y][x_prime] = 31
    elif name == '血瓶:100':
        maze[y][x_prime] = 32
    elif '武器' in name or '宝箱' in name:
        maze[y][x_prime] = 38 # 宝箱
        mota_events[f"{x_prime},{y}"] = {
            "trigger": "action",
            "enable": True,
            "data": [
                {"type": "playSound", "name": "item.mp3"},
                {"type": "setText", "align": "center"},
                "\t[宝箱]打开了古代遗物宝箱！",
                "\t[系统]获得了【精钢长剑】！攻击力 +15！",
                {"type": "setText", "align": "left"},
                {"type": "setValue", "name": "status:atk", "operator": "+=", "value": "15"},
                {"type": "hide", "remove": True}
            ]
        }

floor_obj = {
    "floorId": "MT16",
    "title": "姆伊森运河·支流前哨",
    "name": "姆伊森运河·支流前哨",
    "width": map_w,
    "height": map_h,
    "canFlyTo": True,
    "canUseQuickShop": True,
    "cannotViewMap": False,
    "images": [{"name": "map016_bg.png", "x": 0, "y": 0, "canvas": "bg"}],
    "ratio": 1,
    "defaultGround": "ground",
    "firstArrive": [
        {"type": "playSound", "name": "forest.mp3"},
        {"type": "tip", "text": "进入【姆伊森运河·支流前哨】！前方水流隐约可见！"}
    ],
    "eachArrive": [],
    "parallelDo": "",
    "events": mota_events,
    "changeFloor": {
        "7,14": {
            "floorId": "MT4",
            "loc": [7, 1], # 安全落点：MT4 的林道 (7, 1)，面向南
            "direction": "down"
        }
    },
    "map": maze,
    "bgmap": [],
    "fgmap": [],
    "downFloor": [7, 14],
    "upFloor": [7, 1],
    "bgm": "forest.mp3",
    "canFlyFrom": True
}

out_floor = os.path.join(MOTA_DIR, 'project', 'floors', 'MT16.js')
with open(out_floor, 'w', encoding='utf-8') as f:
    f.write('main.floors.MT16=\n')
    f.write(json.dumps(floor_obj, ensure_ascii=False, indent=4))
    f.write('\n')
print(f" -> 已生成 MT16.js: {out_floor}")

# 4. 在 MT4.js 中配置正上方 (7, 0) 入口指向 MT16
print("[*] 正在更新 MT4.js 接入 MT16 正上方通道及安全落点...")
mt4_path = os.path.join(MOTA_DIR, 'project', 'floors', 'MT4.js')
with open(mt4_path, 'r', encoding='utf-8') as f:
    mt4_txt = f.read()

# MT4 changeFloor
mt4_cf = {
    "7,0": {
        "floorId": "MT16",
        "loc": [7, 13], # 安全落点：MT16 出口前一格 (7, 13)，面向北
        "direction": "up"
    },
    "0,7": {
        "floorId": "MT3",
        "loc": [13, 5], # 安全落点：MT3 林道 (13, 5)，面向西
        "direction": "left"
    },
    "14,7": {
        "floorId": "MT5",
        "loc": [1, 7],  # 安全落点：MT5 城外林道 (1, 7)，面向东
        "direction": "right"
    }
}
mt4_txt = re.sub(r'\"changeFloor\":\s*\{[\s\S]+?\n    \},', f'"changeFloor": {json.dumps(mt4_cf, ensure_ascii=False, indent=8)},\n', mt4_txt)

# 确保 MT4 地图矩阵在 (7, 0) 为 87 (upFloor 或可触发传送图块)
m = re.search(r'\"map\":\s*(\[\s*\[[\s\S]+?\]\s*\])', mt4_txt)
if m:
    mt4_map = json.loads(m.group(1))
    mt4_map[0][7] = 87 # 设置为传送楼梯
    mt4_map[7][0] = 88 # 左侧出口
    mt4_map[7][14] = 87 # 右侧出口
    mt4_txt = mt4_txt.replace(m.group(0), f'"map": {json.dumps(mt4_map)}')

with open(mt4_path, 'w', encoding='utf-8') as f:
    f.write(mt4_txt)
print(" -> MT4.js 拓扑及落点已更新！")

# 5. 更新 MT3.js 安全落点
print("[*] 正在更新 MT3.js 出入口安全落点...")
mt3_path = os.path.join(MOTA_DIR, 'project', 'floors', 'MT3.js')
with open(mt3_path, 'r', encoding='utf-8') as f:
    mt3_txt = f.read()

mt3_cf = {
    "3,14": {
        "floorId": "MT2",
        "loc": [12, 1], # 安全落点：MT2 林道 (12, 1)，面向南
        "direction": "down"
    },
    "14,5": {
        "floorId": "MT4",
        "loc": [1, 7],  # 安全落点：MT4 林道 (1, 7)，面向东
        "direction": "right"
    }
}
mt3_txt = re.sub(r'\"changeFloor\":\s*\{[\s\S]+?\n    \},', f'"changeFloor": {json.dumps(mt3_cf, ensure_ascii=False, indent=8)},\n', mt3_txt)
with open(mt3_path, 'w', encoding='utf-8') as f:
    f.write(mt3_txt)
print(" -> MT3.js 落点已更新！")

# 6. 更新 MT5.js 安全落点
print("[*] 正在更新 MT5.js 出入口安全落点...")
mt5_path = os.path.join(MOTA_DIR, 'project', 'floors', 'MT5.js')
with open(mt5_path, 'r', encoding='utf-8') as f:
    mt5_txt = f.read()

mt5_cf = {
    "0,7": {
        "floorId": "MT4",
        "loc": [13, 7], # 安全落点：MT4 林道 (13, 7)，面向西
        "direction": "left"
    }
}
mt5_txt = re.sub(r'\"changeFloor\":\s*\{[\s\S]+?\n    \},', f'"changeFloor": {json.dumps(mt5_cf, ensure_ascii=False, indent=8)},\n', mt5_txt)
with open(mt5_path, 'w', encoding='utf-8') as f:
    f.write(mt5_txt)
print(" -> MT5.js 落点已更新！")

# 7. 更新 MT2.js 安全落点
print("[*] 正在更新 MT2.js 出入口安全落点...")
mt2_path = os.path.join(MOTA_DIR, 'project', 'floors', 'MT2.js')
with open(mt2_path, 'r', encoding='utf-8') as f:
    mt2_txt = f.read()

mt2_cf = {
    "2,14": {
        "floorId": "MT1",
        "loc": [12, 1],
        "direction": "down"
    },
    "12,0": {
        "floorId": "MT3",
        "loc": [3, 13], # 安全落点：MT3 草地 (3, 13)，面向北
        "direction": "up"
    }
}
mt2_txt = re.sub(r'\"changeFloor\":\s*\{[\s\S]+?\n    \},', f'"changeFloor": {json.dumps(mt2_cf, ensure_ascii=False, indent=8)},\n', mt2_txt)
with open(mt2_path, 'w', encoding='utf-8') as f:
    f.write(mt2_txt)
print(" -> MT2.js 落点已更新！")

# 8. 更新 data.js 注册 MT16 与 map016_bg.png
print("[*] 正在更新 project/data.js 注册 MT16...")
data_path = os.path.join(MOTA_DIR, 'project', 'data.js')
with open(data_path, 'r', encoding='utf-8') as f:
    data_txt = f.read()

if '"MT16"' not in data_txt:
    data_txt = data_txt.replace('"MT5"', '"MT5",\n\t\t\t"MT16"')

if '"map016_bg.png"' not in data_txt:
    data_txt = data_txt.replace('"map013_bg.png"', '"map013_bg.png",\n\t\t"map016_bg.png"')

with open(data_path, 'w', encoding='utf-8') as f:
    f.write(data_txt)
print(" -> project/data.js 已完成 MT16 注册！")

print("\n==============================================")
print("🎉 Map016 接入与全地图出入口安全落点重构 100% 完成！")
print("==============================================")
