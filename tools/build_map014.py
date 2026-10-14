# -*- coding: utf-8 -*-
"""
构建 Map014 (姆伊森运河·主河道 MT14) 并与 MT15 (密林深径)、MT16 (支流前哨) 全线贯通
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

# 2. 渲染 Map014 背景大图
print("[*] 正在渲染 Map014 背景大图 (map014_bg.png)...")
with open(os.path.join(RX_DATA_DIR, 'Map014.rxdata'), 'rb') as f:
    m14 = load(f)

attrs = m14.attributes
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

out_bg = os.path.join(MOTA_DIR, 'project', 'images', 'map014_bg.png')
bg_canvas.save(out_bg)
print(f" -> 已保存 Map014 背景图: {out_bg}")

# 3. 构建 MT14 楼层数据 (Map014)
print("[*] 正在构建 MT14 楼层数据...")
p_data = t4.attributes['@passages']._private_data
flags = struct.unpack('<536h', p_data[20:])

maze = []
for y in range(map_h):
    row = []
    for x_prime in range(map_w):
        x = x_prime + 5
        passable = True
        for layer in [2, 1, 0]:
            tid = tiles[layer * (w * h) + y * w + x]
            if tid == 0: continue
            if tid < len(flags) and (flags[tid] & 0x0f == 0x0f):
                passable = False
                break
            else:
                passable = True
                break
        row.append(0 if passable else 17)
    maze.append(row)

# 确保南出口 (7, 14) 和东出口 (14, 9) 是通畅的
maze[14][7] = 88 # 南出口通往 MT15 (密林深径)
maze[9][14] = 88 # 东出口通往 MT16 (支流前哨)

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
        if x_prime == 13 and y == 9:
            # 丛林幽影守在 (12, 9)，给从 MT16 (支流前哨) 进来的玩家留出安全落点 (13, 9)
            maze[9][12] = MONSTER_MAP[name]
            maze[9][13] = 0
        else:
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
    elif name == '血瓶:100' or name == '血瓶:200':
        maze[y][x_prime] = 32
    elif '生命上限' in name:
        maze[y][x_prime] = 33 # 绿水晶
        mota_events[f"{x_prime},{y}"] = {
            "trigger": "action",
            "enable": True,
            "data": [
                {"type": "playSound", "name": "recovery.mp3"},
                {"type": "function", "function": "function() {\n    core.addMaxHp(20);\n}"},
                {"type": "tip", "text": "获得生命水晶，生命上限 +20！"},
                {"type": "hide", "remove": True}
            ]
        }
    elif '武器' in name or '宝箱' in name:
        maze[y][x_prime] = 38 # 宝箱
        mota_events[f"{x_prime},{y}"] = {
            "trigger": "action",
            "enable": True,
            "data": [
                {"type": "playSound", "name": "item.mp3"},
                {"type": "setText", "align": "center"},
                "\t[宝箱]打开了古代运河遗物宝箱！",
                "\t[系统]获得了强化物资！",
                {"type": "setText", "align": "left"},
                {"type": "setValue", "name": "status:atk", "operator": "+=", "value": "10"},
                {"type": "hide", "remove": True}
            ]
        }
    elif '路牌' in name:
        maze[y][x_prime] = 129
        mota_events[f"{x_prime},{y}"] = {
            "trigger": "action",
            "enable": True,
            "data": [
                {"type": "setText", "align": "center"},
                "\t[路牌]设定说明之闪避与普攻结算",
                "\t[路牌]每回合实际造成的伤害除了攻速系数外，还存在着命中系数。",
                "\t[路牌]通常情况下初始命中系数为 1，而闪避类技能可大幅削弱命中系数！",
                {"type": "setText", "align": "left"}
            ]
        }

# 西侧 (0, 8) 是通往 Map022 的道路，设立前哨提示
mota_events["0,8"] = {
    "trigger": "action",
    "enable": True,
    "data": [
        {"type": "playSound", "name": "cursor.mp3"},
        "\t[警示标志]前方为【姆伊森运河·下游激流】！水流极为湍急，水流闸门紧闭，暂无法涉水渡河！"
    ]
}

floor_obj = {
    "floorId": "MT14",
    "title": "姆伊森运河·主河道",
    "name": "姆伊森运河",
    "width": map_w,
    "height": map_h,
    "canFlyTo": True,
    "canUseQuickShop": True,
    "cannotViewMap": False,
    "images": [{"name": "map014_bg.png", "x": 0, "y": 0, "canvas": "bg"}],
    "ratio": 1,
    "defaultGround": "ground",
    "firstArrive": [
        {"type": "playSound", "name": "forest.mp3"},
        {"type": "tip", "text": "进入【姆伊森运河·主河道】！运河波光粼粼，水汽扑面而来！"}
    ],
    "eachArrive": [],
    "parallelDo": "",
    "events": mota_events,
    "changeFloor": {
        "7,14": {
            "floorId": "MT15",
            "loc": [7, 1], # 安全落点：MT15 密林深径 (7, 1)，面向南
            "direction": "down"
        },
        "14,9": {
            "floorId": "MT16",
            "loc": [1, 9], # 安全落点：MT16 支流前哨 (1, 9)，面向东
            "direction": "right"
        }
    },
    "map": maze,
    "bgmap": [],
    "fgmap": [],
    "downFloor": [7, 14],
    "upFloor": [14, 9],
    "bgm": "forest.mp3",
    "canFlyFrom": True
}

out_floor = os.path.join(MOTA_DIR, 'project', 'floors', 'MT14.js')
with open(out_floor, 'w', encoding='utf-8') as f:
    f.write('main.floors.MT14=\n')
    f.write(json.dumps(floor_obj, ensure_ascii=False, indent=4))
    f.write('\n')
print(f" -> 已生成 MT14.js: {out_floor}")

# 4. 更新 project/data.js 注册 MT14 与 map014_bg.png
print("[*] 正在更新 project/data.js 注册 MT14...")
data_path = os.path.join(MOTA_DIR, 'project', 'data.js')
with open(data_path, 'r', encoding='utf-8') as f:
    data_txt = f.read()

if '"MT14"' not in data_txt:
    data_txt = data_txt.replace('"MT15"', '"MT14",\n\t\t\t"MT15"')

if '"map014_bg.png"' not in data_txt:
    data_txt = data_txt.replace('"map011_bg.png"', '"map014_bg.png",\n\t\t"map011_bg.png"')

with open(data_path, 'w', encoding='utf-8') as f:
    f.write(data_txt)
print(" -> project/data.js 已完成 MT14 注册！")

print("\n==============================================")
print("🎉 Map014 (MT14) 姆伊森运河构建与全网络打通 100% 完成！")
print("==============================================")
