# -*- coding: utf-8 -*-
"""
永不复还(500F) -> mota-js 第二层 (Map009 寂静之森外围·深处) 100% 像素级复刻总装脚本。
执行内容：
1. 使用 RMXP 48-Autotile + Tileset 完整渲染算法生成 15x15 (480x480) 真实地图背景图 map009_bg.png。
2. 构建精准 15x15 楼层 MT2.js：
   - 提取 Tilesets.rxdata 通行度与空气墙 (17)
   - 自动映射 19 只魔兽 (严格对齐 Enemies.rxdata 与 CE1)
   - 自动映射 5 扇黄门 (81)、1 把黄钥匙 (21)
   - 自动映射 4 颗月牙宝石碎片 (3红1蓝)、2 颗翠绿生命上限水晶、10 瓶恢复血瓶 (8红2蓝)
   - 配置双向楼梯与场所移动 (下楼口 (2, 14) 回 MT1，上楼口 (12, 0) 去 MT3)
3. 更新 MT1.js 的出口跳转，确保可通向 MT2。
4. 更新 project/data.js (注册 MT2 楼层与 map009_bg.png 背景图)。
5. 自增 main.js 版本号触发热重载。
"""

import os, sys, re, struct, json, shutil
from rubymarshal.reader import load
import PIL.Image as Image

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MOTA_DIR = os.path.join(BASE_DIR, '_analysis', '_ybfh-mota')
RX_DATA_DIR = os.path.join(os.path.dirname(BASE_DIR), 'Data')
RX_GFX_DIR = os.path.join(os.path.dirname(BASE_DIR), 'Graphics')

print(f"[*] Base dir: {BASE_DIR}")
print(f"[*] Mota dir: {MOTA_DIR}")
print(f"[*] RMXP data dir: {RX_DATA_DIR}")

# -------------------------------------------------------------
# 1. 生成 15x15 真实原版背景图 map009_bg.png
# -------------------------------------------------------------
print("\n[1/5] 正在生成 15x15 (480x480) 真实地图背景图 map009_bg.png...")

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
    # tid >= 384: normal tileset
    idx = tid - 384
    col = idx % 8
    row = idx // 8
    tile = tileset_img.crop((col * 32, row * 32, (col + 1) * 32, (row + 1) * 32))
    return tile

with open(os.path.join(RX_DATA_DIR, 'Map009.rxdata'), 'rb') as f:
    m = load(f)

attrs = m.attributes
w, h = attrs['@width'], attrs['@height']
data_bytes = attrs['@data']._private_data
dim, w, h, z, total = struct.unpack('<5i', data_bytes[:20])
tiles = struct.unpack(f'<{total}h', data_bytes[20:])

map_w, map_h = 15, 15
full_bg = Image.new('RGBA', (map_w * 32, map_h * 32), (0, 0, 0, 0))

for l in range(z):
    for y in range(map_h):
        for x_prime in range(map_w):
            x = x_prime + 5
            tid = tiles[l * (w * h) + y * w + x]
            tile = render_tile(tid)
            if tile:
                full_bg.paste(tile, (x_prime * 32, y * 32), tile)

bg_dest = os.path.join(MOTA_DIR, 'project', 'images', 'map009_bg.png')
full_bg.save(bg_dest)
print(f" -> 已生成 15x15 地图背景: {bg_dest} (480x480)")

# -------------------------------------------------------------
# 2. 生成 15x15 楼层脚本 MT2.js
# -------------------------------------------------------------
print("\n[2/5] 正在构建 MT2.js 真实 15x15 地图与事件...")

p_data = t4.attributes['@passages']._private_data
flags = struct.unpack('<536h', p_data[20:])

# 基础 15x15 地图矩阵
# 0: 可通行地面, 17: 不可通行障碍物 (空气墙碰撞体)
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

# 真实怪物映射 (严格对齐 Enemies.rxdata 与 CE1)
MONSTER_MAP = {
    '怪物002': 201, # greenSlime: 荷依米 (绿色史莱姆)
    '怪物006': 202, # redSlime: 倍荷玛 (粉红圆圆史莱姆)
    '怪物004': 203, # blackSlime: 幽林鬼火 (深蓝火焰)
    '怪物003': 204, # slimelord: 软泥怪 (亮蓝色水花怪)
    '怪物005': 205, # bat: 荷依米战士 (持剑盾绿史莱姆)
    '怪物007': 209, # skeleton: 复活的死者 (白色骷髅兵)
    '怪物008': 210, # skeletonWarrior: 倍荷玛战士 (持剑盾粉红怪)
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
    
    # 怪物
    if name in MONSTER_MAP:
        maze[y][x_prime] = MONSTER_MAP[name]
    # 黄门
    elif name == '黄门':
        maze[y][x_prime] = 81
    # 黄钥匙
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
    # 宝石碎片
    elif name == '红宝石:1':
        maze[y][x_prime] = 27
    elif name == '蓝宝石:1':
        maze[y][x_prime] = 28
    # 血瓶
    elif name == '血瓶:50':
        maze[y][x_prime] = 31 # redPotion
        mota_events[f"{x_prime},{y}"] = {
            "trigger": "action",
            "enable": True,
            "data": [
                {
                    "type": "if",
                    "condition": "(status:hpmax - status:hp < 50)",
                    "true": [
                        {"type": "setText", "align": "center"},
                        "\t[说明]生命上限不足，已损失血量少于 50 点。\n为避免浪费，待需要时再来饮用吧。",
                        {"type": "setText", "align": "left"}
                    ],
                    "false": [
                        {"type": "playSound", "name": "recovery.mp3"},
                        {"type": "setValue", "name": "status:hp", "operator": "+=", "value": "50"},
                        {"type": "hide", "remove": True}
                    ]
                }
            ]
        }
    elif name == '血瓶:100':
        maze[y][x_prime] = 32 # bluePotion
        mota_events[f"{x_prime},{y}"] = {
            "trigger": "action",
            "enable": True,
            "data": [
                {
                    "type": "if",
                    "condition": "(status:hpmax - status:hp < 100)",
                    "true": [
                        {"type": "setText", "align": "center"},
                        "\t[说明]生命上限不足，已损失血量少于 100 点。\n为避免浪费，待需要时再来饮用吧。",
                        {"type": "setText", "align": "left"}
                    ],
                    "false": [
                        {"type": "playSound", "name": "recovery.mp3"},
                        {"type": "setValue", "name": "status:hp", "operator": "+=", "value": "100"},
                        {"type": "hide", "remove": True}
                    ]
                }
            ]
        }
    # 生命上限
    elif name == '生命上限:20':
        maze[y][x_prime] = 33 # greenPotion
        mota_events[f"{x_prime},{y}"] = {
            "trigger": "action",
            "enable": True,
            "data": [
                {"type": "playSound", "name": "recovery.mp3"},
                {"type": "setValue", "name": "status:hpmax", "operator": "+=", "value": "20"},
                {"type": "setValue", "name": "status:hp", "operator": "+=", "value": "20"},
                {"type": "tip", "text": "生命上限 +20！当前生命值随比例同步提升！"},
                {"type": "hide", "remove": True}
            ]
        }
    # 下楼口 (Event 45, (7, 14) -> (2, 14))
    elif eid == 45:
        maze[y][x_prime] = 88 # downFloor
    # 上楼口 (Event 44, (17, 0) -> (12, 0))
    elif eid == 44:
        maze[y][x_prime] = 87 # upFloor

mt2_obj = {
    "floorId": "MT2",
    "title": "寂静之森外围 2F",
    "name": "寂静之森外围 2F",
    "width": 15,
    "height": 15,
    "canFlyTo": True,
    "canUseQuickShop": True,
    "cannotViewMap": False,
    "images": [
        {
            "name": "map009_bg.png",
            "x": 0,
            "y": 0,
            "canvas": "bg"
        }
    ],
    "ratio": 1,
    "defaultGround": "ground",
    "firstArrive": [
        {"type": "playSound", "name": "forest.mp3"},
        {"type": "tip", "text": "进入【寂静之森外围 2F】！"}
    ],
    "eachArrive": [],
    "parallelDo": "",
    "events": mota_events,
    "changeFloor": {
        "2,14": {"floorId": "MT1", "stair": "upFloor"},
        "12,0": {"floorId": ":next", "stair": "downFloor"}
    },
    "afterBattle": {},
    "afterGetItem": {},
    "afterOpenDoor": {},
    "cannotMove": {},
    "map": maze,
    "bgmap": [],
    "fgmap": [],
    "downFloor": [2, 14],
    "upFloor": [12, 0],
    "bgm": "forest.mp3",
    "beforeBattle": {},
    "cannotMoveIn": {},
    "autoEvent": {},
    "canFlyFrom": True
}

mt2_path = os.path.join(MOTA_DIR, 'project', 'floors', 'MT2.js')
with open(mt2_path, 'w', encoding='utf-8') as f:
    f.write('main.floors.MT2=\n')
    f.write(json.dumps(mt2_obj, ensure_ascii=False, indent=4))
    f.write('\n')

print(f" -> MT2.js 已生成并写入: {mt2_path}")

# -------------------------------------------------------------
# 3. 更新 MT1.js 的出口跳转，确保可通向 MT2
# -------------------------------------------------------------
print("\n[3/5] 正在更新 MT1.js 出口跳转链接至 MT2...")
mt1_path = os.path.join(MOTA_DIR, 'project', 'floors', 'MT1.js')
with open(mt1_path, 'r', encoding='utf-8') as f:
    mt1_code = f.read()

# 更新 12,0 跳转至 MT2
if '"12,0": {"floorId": ":next"' in mt1_code or '"12,0": {"floorId": "MT2"' in mt1_code:
    mt1_code = re.sub(r'"12,0":\s*\{\s*"floorId":\s*":next"[^}]*\}', '"12,0": {"floorId": "MT2", "stair": "downFloor"}', mt1_code)
    with open(mt1_path, 'w', encoding='utf-8') as f:
        f.write(mt1_code)
    print(" -> MT1.js (12, 0) 上楼口已正确链接至 MT2 downFloor")

# -------------------------------------------------------------
# 4. 更新 project/data.js 注册 MT2 和 map009_bg.png
# -------------------------------------------------------------
print("\n[4/5] 正在更新 project/data.js 楼层与图片注册...")
data_path = os.path.join(MOTA_DIR, 'project', 'data.js')
with open(data_path, 'r', encoding='utf-8') as f:
    data_code = f.read()

# 确保 main.floorIds 包含 MT2
if '"MT2"' not in data_code:
    data_code = data_code.replace('"MT1"', '"MT1",\n\t\t"MT2"')
    print(" -> main.floorIds 已加入 MT2")

# 确保 images 包含 map009_bg.png
if '"map009_bg.png"' not in data_code:
    data_code = data_code.replace('"map007_bg.png"', '"map007_bg.png",\n\t\t"map009_bg.png"')
    print(" -> images 列表已加入 map009_bg.png")

with open(data_path, 'w', encoding='utf-8') as f:
    f.write(data_code)

# -------------------------------------------------------------
# 5. 更新 main.js 版本号触发热重载
# -------------------------------------------------------------
print("\n[5/5] 正在提升 main.js 版本号...")
main_path = os.path.join(MOTA_DIR, 'main.js')
with open(main_path, 'r', encoding='utf-8') as f:
    main_code = f.read()

v_match = re.search(r'this\.version\s*=\s*[\'"]([^\'"]+)[\'"]', main_code)
if v_match:
    old_v = v_match.group(1)
    new_v = "2.10.3-ybfh-mt2-v1"
    main_code = main_code.replace(f"this.version = '{old_v}'", f"this.version = '{new_v}'")
    with open(main_path, 'w', encoding='utf-8') as f:
        f.write(main_code)
    print(f" -> main.js 已更新版本号为 {new_v}")

print("\n✨ MT2 第二层 (寂静之森外围 2F) 像素级 1:1 自动化总装完成！")
