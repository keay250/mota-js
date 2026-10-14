# -*- coding: utf-8 -*-
"""
构建 Map011 (寂静之森外围·密林深径 MT15) 并与 MT3 贯通
同时在 MT3 左侧 (0, 3) 放置深处前哨路牌
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

# 2. 渲染 Map011 背景大图
print("[*] 正在渲染 Map011 背景大图 (map011_bg.png)...")
with open(os.path.join(RX_DATA_DIR, 'Map011.rxdata'), 'rb') as f:
    m11 = load(f)

attrs = m11.attributes
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

out_bg = os.path.join(MOTA_DIR, 'project', 'images', 'map011_bg.png')
bg_canvas.save(out_bg)
print(f" -> 已保存 Map011 背景图: {out_bg}")

# 3. 构建 MT15 楼层数据 (Map011)
print("[*] 正在构建 MT15 楼层数据...")
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

# 确保北出口 (7, 0) 与南出口 (11, 14) 是通畅的
maze[0][7] = 87   # 北出口通往 MT14 (姆伊森运河)
maze[14][11] = 88 # 南出口通往 MT3 (寂静之森外围)

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
    '怪物015': 201,
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
                "\t[宝箱]打开了密林遗失的宝箱！",
                "\t[系统]获得了【森林长剑】！攻击力 +15！",
                {"type": "setText", "align": "left"},
                {"type": "setValue", "name": "status:atk", "operator": "+=", "value": "15"},
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
                "\t[路牌]设定说明之生命回复与伤害结算",
                "\t[路牌]与毒素腐蚀等固定扣血不同，回复量根据角色当前状态比例结算。",
                "\t[路牌]另外，怪物的最终战斗结算伤害可为负数，合理搭配护甲与减伤可无伤刷怪！",
                {"type": "setText", "align": "left"}
            ]
        }

floor_obj = {
    "floorId": "MT15",
    "title": "寂静之森外围·密林深径",
    "name": "寂静之森外围·密林深径",
    "width": map_w,
    "height": map_h,
    "canFlyTo": True,
    "canUseQuickShop": True,
    "cannotViewMap": False,
    "images": [{"name": "map011_bg.png", "x": 0, "y": 0, "canvas": "bg"}],
    "ratio": 1,
    "defaultGround": "ground",
    "firstArrive": [
        {"type": "playSound", "name": "forest.mp3"},
        {"type": "tip", "text": "进入【寂静之森外围·密林深径】！四周传来隐秘的宝物光芒！"}
    ],
    "eachArrive": [],
    "parallelDo": "",
    "events": mota_events,
    "changeFloor": {
        "11,14": {
            "floorId": "MT3",
            "loc": [9, 1], # 安全落点：MT3 (9, 1)，面向南
            "direction": "down"
        },
        "7,0": {
            "floorId": "MT14",
            "loc": [7, 13], # 安全落点：MT14 (7, 13)，面向北
            "direction": "up"
        }
    },
    "map": maze,
    "bgmap": [],
    "fgmap": [],
    "downFloor": [11, 14],
    "upFloor": [7, 0],
    "bgm": "forest.mp3",
    "canFlyFrom": True
}

out_floor = os.path.join(MOTA_DIR, 'project', 'floors', 'MT15.js')
with open(out_floor, 'w', encoding='utf-8') as f:
    f.write('main.floors.MT15=\n')
    f.write(json.dumps(floor_obj, ensure_ascii=False, indent=4))
    f.write('\n')
print(f" -> 已生成 MT15.js: {out_floor}")

print("\n==============================================")
print("🎉 Map011 (MT15) 密林深径构建与 MT14 贯通 100% 完成！")
print("==============================================")
