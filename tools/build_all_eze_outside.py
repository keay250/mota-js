# -*- coding: utf-8 -*-
"""
《永不复还》-> mota-js 复刻总装脚本：全线贯通至“厄泽城外”
生成内容：
1. 真实背景大图渲染：map010_bg.png, map012_bg.png, map013_bg.png (480x480, 48-Autotiles + Tileset)
2. 构建楼层脚本：MT3.js (Map010), MT4.js (Map012), MT5.js (Map013)
3. 补全更新 enemys.js 中全量怪兽数值 (严格对齐 Enemies.rxdata)
4. 更新 MT2.js 楼梯出口指向 MT3
5. 更新 project/data.js (注册 MT3, MT4, MT5 及所有背景图)
6. 更新 main.js 版本号触发热重载
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
# 1. 准备 Tileset 4 (003-Forest01) 与 48-Autotile 渲染器
# -------------------------------------------------------------
print("\n[1/6] 正在初始化 RMXP Tileset 4 与 Autotile 渲染管线...")

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

p_data = t4.attributes['@passages']._private_data
flags = struct.unpack('<536h', p_data[20:])

# -------------------------------------------------------------
# 2. 渲染背景大图 (Map010, Map012, Map013)
# -------------------------------------------------------------
map_configs = [
    (10, 'map010_bg.png', 'MT3', '寂静之森外围 3F'),
    (12, 'map012_bg.png', 'MT4', '寂静之森外围 4F'),
    (13, 'map013_bg.png', 'MT5', '寂静之森外围 5F·厄泽城外')
]

map_w, map_h = 15, 15

print("\n[2/6] 正在批量渲染 15x15 (480x480) 真实地图背景图...")
for mid, bg_name, floor_id, title in map_configs:
    rx_path = os.path.join(RX_DATA_DIR, f'Map{mid:03d}.rxdata')
    with open(rx_path, 'rb') as f:
        m = load(f)
    attrs = m.attributes
    data_bytes = attrs['@data']._private_data
    dim, w, h, z, total = struct.unpack('<5i', data_bytes[:20])
    tiles = struct.unpack(f'<{total}h', data_bytes[20:])

    full_bg = Image.new('RGBA', (map_w * 32, map_h * 32), (0, 0, 0, 0))
    for l in range(z):
        for y in range(map_h):
            for x_prime in range(map_w):
                x = x_prime + 5
                tid = tiles[l * (w * h) + y * w + x]
                tile = render_tile(tid)
                if tile:
                    full_bg.paste(tile, (x_prime * 32, y * 32), tile)

    bg_dest = os.path.join(MOTA_DIR, 'project', 'images', bg_name)
    full_bg.save(bg_dest)
    print(f" -> 已生成背景图: {bg_name} ({bg_dest})")

# -------------------------------------------------------------
# 3. 补全更新 enemys.js 怪兽数值
# -------------------------------------------------------------
print("\n[3/6] 正在对齐 enemys.js 中全量敌人属性...")
enemys_path = os.path.join(MOTA_DIR, 'project', 'enemys.js')
with open(enemys_path, 'r', encoding='utf-8') as f:
    enemys_content = f.read()

# 真实属性映射 (严格对齐 Enemies.rxdata 与原版数据)
enemy_updates = {
    "skeletonCaptain": {"name": "嗜血死者", "hp": 75, "atk": 18, "def": 1, "money": 3, "exp": 5, "point": 0, "special": 0},
    "zombie": {"name": "寒冰软泥怪", "hp": 300, "atk": 2, "def": 0, "money": 2, "exp": 4, "point": 0, "special": 0},
    "zombieKnight": {"name": "荷依米贵族", "hp": 101, "atk": 13, "def": 3, "money": 3, "exp": 5, "point": 0, "special": 0},
    "rock": {"name": "丛林幽影", "hp": 122, "atk": 11, "def": 2, "money": 3, "exp": 6, "point": 0, "special": 0},
    "bluePriest": {"name": "流浪法师", "hp": 96, "atk": 12, "def": 4, "money": 3, "exp": 6, "point": 0, "special": 0},
    "redPriest": {"name": "倍荷玛拉", "hp": 157, "atk": 19, "def": 8, "money": 4, "exp": 7, "point": 0, "special": 0}
}

for k, v in enemy_updates.items():
    pattern = rf'"{k}":\s*\{{[^}}]*\}}'
    replacement = f'"{k}": {json.dumps(v, ensure_ascii=False)}'
    if re.search(pattern, enemys_content):
        enemys_content = re.sub(pattern, replacement, enemys_content)
    else:
        # 如果未找到则插入
        enemys_content = enemys_content.replace('var enemys_fcae963b_31c9_42b4_b48c_bb48d09f3f80 = \n{',
                                               f'var enemys_fcae963b_31c9_42b4_b48c_bb48d09f3f80 = \n{{\n\t"{k}": {json.dumps(v, ensure_ascii=False)},')

with open(enemys_path, 'w', encoding='utf-8') as f:
    f.write(enemys_content)
print(" -> enemys.js 属性对齐完毕！")

# -------------------------------------------------------------
# 4. 生成楼层脚本 MT3.js, MT4.js, MT5.js
# -------------------------------------------------------------
print("\n[4/6] 正在构建楼层脚本 MT3.js, MT4.js, MT5.js...")

MONSTER_MAP = {
    '怪物002': 201, # greenSlime: 荷依米
    '怪物006': 202, # redSlime: 倍荷玛
    '怪物004': 203, # blackSlime: 幽林鬼火
    '怪物003': 204, # slimelord: 软泥怪
    '怪物005': 205, # bat: 荷依米战士
    '怪物007': 209, # skeleton: 复活的死者
    '怪物008': 210, # skeletonWarrior: 倍荷玛战士
    '怪物009': 211, # skeletonCaptain: 嗜血死者
    '怪物010': 213, # zombie: 寒冰软泥怪
    '怪物011': 214, # zombieKnight: 荷依米贵族
    '怪物012': 215, # rock: 丛林幽影
    '怪物013': 217, # bluePriest: 流浪法师
    '怪物015': 218, # redPriest: 倍荷玛拉
}

def build_floor_data(mid, floor_id, title, bg_name, prev_floor, next_floor, is_final=False):
    rx_path = os.path.join(RX_DATA_DIR, f'Map{mid:03d}.rxdata')
    with open(rx_path, 'rb') as f:
        m = load(f)
    attrs = m.attributes
    data_bytes = attrs['@data']._private_data
    dim, w, h, z, total = struct.unpack('<5i', data_bytes[:20])
    tiles = struct.unpack(f'<{total}h', data_bytes[20:])

    # 1. 基础空气墙矩阵
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

    mota_events = {}
    events = attrs['@events']
    down_floor_pos = None
    up_floor_pos = None

    for eid, ev in sorted(events.items()):
        ea = ev.attributes
        x_orig, y = ea['@x'], ea['@y']
        x_prime = x_orig - 5
        if x_prime < 0 or x_prime >= map_w:
            continue
        
        name = ea['@name'].decode('utf-8', 'replace') if isinstance(ea['@name'], bytes) else str(ea['@name'])

        # 怪物映射
        if name in MONSTER_MAP:
            maze[y][x_prime] = MONSTER_MAP[name]
        # 门类
        elif name == '黄门':
            maze[y][x_prime] = 81
        elif name == '蓝门':
            maze[y][x_prime] = 82
        elif name == '红门':
            maze[y][x_prime] = 83
        elif '机关门' in name:
            maze[y][x_prime] = 85
        # 钥匙类
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
        # 宝石与血瓶
        elif name == '红宝石:1':
            maze[y][x_prime] = 27
        elif name == '蓝宝石:1':
            maze[y][x_prime] = 28
        elif name == '血瓶:50':
            maze[y][x_prime] = 31
        elif name == '血瓶:100':
            maze[y][x_prime] = 32
        elif name == '血瓶:200':
            maze[y][x_prime] = 34
        elif name == '生命上限:20':
            maze[y][x_prime] = 33
        # NPC 与路牌
        elif name == '路牌':
            maze[y][x_prime] = 129
        elif '路过的佣兵' in name:
            maze[y][x_prime] = 128
        elif '小站' in name:
            # 恢复小站 (可用星空传送门或神圣地块表示)
            maze[y][x_prime] = 90
            mota_events[f"{x_prime},{y}"] = {
                "trigger": "action",
                "enable": True,
                "data": [
                    {"type": "playSound", "name": "recovery.mp3"},
                    {"type": "setValue", "name": "status:hp", "operator": "=", "value": "status:maxHp"},
                    {"type": "tip", "text": "在厄泽城小站充分休整，生命值已完全恢复！"}
                ]
            }

    # 特殊剧情事件与楼梯出入口配置
    change_floor = {}
    each_arrive = []
    auto_event = {}

    if mid == 10:
        # MT3 (Map010): 下楼回到 MT2 (12, 0), 上楼前往 MT4 (0, 7)
        down_floor_pos = [3, 14] # (8, 14) -> (3, 14)
        up_floor_pos = [14, 5]   # (19, 5) -> (14, 5)
        maze[14][3] = 88 # downFloor
        maze[5][14] = 87 # upFloor
        change_floor["3,14"] = {"floorId": "MT2", "loc": [12, 0]}
        change_floor["14,5"] = {"floorId": "MT4", "loc": [0, 7]}

        # 机关门 (2, 6) 联动与自愈
        each_arrive = [
            {
                "type": "if",
                "condition": "core.hasFlag('mt3_doors_opened') || !core.hasMonsterInArea('MT3', 1, 7, 5, 11) || !core.hasEnemyLeft(null, 'MT3')",
                "true": [
                    {
                        "type": "function",
                        "function": "function() {\n    core.setFlag('mt3_doors_opened', true);\n    var b = core.getBlock(2, 6);\n    if (b && (b.number == 85 || (b.event && b.event.id == 'specialDoor'))) {\n        core.removeBlock(2, 6);\n    }\n}"
                    }
                ]
            }
        ]
        auto_event = {
            "0,0": [
                {
                    "condition": "(!core.hasFlag('mt3_doors_opened')) && (!core.hasMonsterInArea('MT3', 1, 7, 5, 11) || !core.hasEnemyLeft(null, 'MT3'))",
                    "currentFloor": True,
                    "priority": 0,
                    "delayExecute": False,
                    "multiExecute": False,
                    "data": [
                        { "type": "setValue", "name": "flag:mt3_doors_opened", "value": "true" },
                        { "type": "playSound", "name": "door.mp3" },
                        { "type": "tip", "text": "【机关门已开启！】机关解除了！" },
                        { "type": "openDoor", "loc": [2, 6], "needKey": False, "async": False }
                    ]
                }
            ]
        }
        mota_events["2,6"] = {
            "trigger": "action",
            "enable": True,
            "data": [
                {
                    "type": "if",
                    "condition": "!core.hasMonsterInArea('MT3', 1, 7, 5, 11) || !core.hasEnemyLeft(null, 'MT3')",
                    "true": [
                        { "type": "setValue", "name": "flag:mt3_doors_opened", "value": "true" },
                        { "type": "playSound", "name": "door.mp3" },
                        { "type": "tip", "text": "【机关门已开启！】机关解除了！" },
                        { "type": "openDoor", "loc": [2, 6], "needKey": False, "async": False }
                    ],
                    "false": [
                        {
                            "type": "show",
                            "text": "\t[机关门]一道沉重冰冷的特殊铁门紧紧锁着……\n隐约能感觉到左下方守护怪物的魔力牵制，\n击败它们或许就能解除机关！"
                        }
                    ]
                }
            ]
        }

        # 路牌对话事件 (6, 8)
        mota_events["6,8"] = {
            "trigger": "action",
            "enable": True,
            "data": [
                {"type": "playSound", "name": "cursor.mp3"},
                "\t[路牌]↑ 姆依森运河\n→ 厄泽城\n←↓ 寂静之森深处",
                "\t[贾斯汀]太好了，看到路牌了，小站应该就在前面。\n只要到了小站就能安全回城了。"
            ]
        }

    elif mid == 12:
        # MT4 (Map012): 下楼回到 MT3 (14, 5), 上楼前往 MT5 (0, 7)
        down_floor_pos = [0, 7]  # (5, 7) -> (0, 7)
        up_floor_pos = [14, 7]   # (19, 7) -> (14, 7)
        maze[7][0] = 88 # downFloor
        maze[7][14] = 87 # upFloor
        change_floor["0,7"] = {"floorId": "MT3", "loc": [14, 5]}
        change_floor["14,7"] = {"floorId": "MT5", "loc": [0, 7]}

        # 机关门 (7, 4), (5, 1), (9, 1) 联动与自愈
        each_arrive = [
            {
                "type": "if",
                "condition": "core.hasFlag('mt4_doors_opened') || !core.hasMonsterInArea('MT4', 11, 12, 13, 13) || !core.hasEnemyLeft(null, 'MT4')",
                "true": [
                    {
                        "type": "function",
                        "function": "function() {\n    core.setFlag('mt4_doors_opened', true);\n    [[7, 4], [5, 1], [9, 1]].forEach(function(loc) {\n        var b = core.getBlock(loc[0], loc[1]);\n        if (b && (b.number == 85 || (b.event && b.event.id == 'specialDoor'))) {\n            core.removeBlock(loc[0], loc[1]);\n        }\n    });\n}"
                    }
                ]
            }
        ]
        auto_event = {
            "0,0": [
                {
                    "condition": "(!core.hasFlag('mt4_doors_opened')) && (!core.hasMonsterInArea('MT4', 11, 12, 13, 13) || !core.hasEnemyLeft(null, 'MT4'))",
                    "currentFloor": True,
                    "priority": 0,
                    "delayExecute": False,
                    "multiExecute": False,
                    "data": [
                        { "type": "setValue", "name": "flag:mt4_doors_opened", "value": "true" },
                        { "type": "playSound", "name": "door.mp3" },
                        { "type": "tip", "text": "【机关门已开启！】通往森林深处的铁门打开了！" },
                        { "type": "openDoor", "loc": [7, 4], "needKey": False, "async": True },
                        { "type": "openDoor", "loc": [5, 1], "needKey": False, "async": True },
                        { "type": "openDoor", "loc": [9, 1], "needKey": False, "async": True },
                        { "type": "waitAsync" }
                    ]
                }
            ]
        }
        for dpos in ["7,4", "5,1", "9,1"]:
            mota_events[dpos] = {
                "trigger": "action",
                "enable": True,
                "data": [
                    {
                        "type": "if",
                        "condition": "!core.hasMonsterInArea('MT4', 11, 12, 13, 13) || !core.hasEnemyLeft(null, 'MT4')",
                        "true": [
                            { "type": "setValue", "name": "flag:mt4_doors_opened", "value": "true" },
                            { "type": "playSound", "name": "door.mp3" },
                            { "type": "tip", "text": "【机关门已开启！】机关解除了！" },
                            { "type": "openDoor", "loc": [7, 4], "needKey": False, "async": True },
                            { "type": "openDoor", "loc": [5, 1], "needKey": False, "async": True },
                            { "type": "openDoor", "loc": [9, 1], "needKey": False, "async": True },
                            { "type": "waitAsync" }
                        ],
                        "false": [
                            {
                                "type": "show",
                                "text": "\t[机关门]一道沉重冰冷的特殊铁门紧紧锁着……\n隐约能感觉到右下角守护怪物的魔力牵制，\n击败它们或许就能解除机关！"
                            }
                        ]
                    }
                ]
            }

        # 初见荷依米贵族剧情 (1, 7)
        mota_events["1,7"] = {
            "trigger": "action",
            "enable": True,
            "data": [
                {"type": "playSound", "name": "cursor.mp3"},
                "\t[贾斯汀]我的天，这里怎么会有一只荷依米贵族！\n这种高阶魔物原本绝不会出现在森林外围啊。",
                "\t[贾斯汀]一定要小心谨慎，先绕过它……",
                {"type": "hide", "remove": True}
            ]
        }
        # 路牌1 (3, 5)
        mota_events["3,5"] = {
            "trigger": "action",
            "enable": True,
            "data": [
                {"type": "playSound", "name": "cursor.mp3"},
                "\t[路牌]【设定说明之等级】\n通过与怪物战斗获取经验，适时升级提升属性。\n面对伤害过高的强敌，可先消灭弱小怪物凑经验升级！"
            ]
        }
        # 路牌2 (4, 0)
        mota_events["4,0"] = {
            "trigger": "action",
            "enable": True,
            "data": [
                {"type": "playSound", "name": "cursor.mp3"},
                "\t[路牌]【设定说明之机关门】\n机关门往往需要达成特定条件才能开启，最常见的是击杀附近的守护怪物！"
            ]
        }

    elif mid == 13:
        # MT5 (Map013 - 厄泽城外！): 下楼回到 MT4 (14, 7), 终点通向厄泽城门 (14, 7)
        down_floor_pos = [0, 7]  # (5, 7) -> (0, 7)
        up_floor_pos = [14, 7]   # (19, 7) -> (14, 7)
        maze[7][0] = 88 # downFloor
        change_floor["0,7"] = {"floorId": "MT4", "loc": [14, 7]}

        # 走出森林剧情 (7, 7)
        mota_events["7,7"] = {
            "trigger": "action",
            "enable": True,
            "data": [
                {"type": "playSound", "name": "cursor.mp3"},
                "\t[贾斯汀]终于走出来了……森林里的雾气开始散去了！",
                "\t[贾斯汀]其他人没有在这里等待吗？也许已经安全回城了也说不定。",
                "\t[贾斯汀]前面好像有人，去问问看！",
                {"type": "hide", "remove": True}
            ]
        }

        # 路过的佣兵 NPC (11, 6)
        mota_events["11,6"] = {
            "trigger": "action",
            "enable": True,
            "data": [
                {"type": "playSound", "name": "cursor.mp3"},
                "\t[路过的佣兵]你问我在这里干什么？\n好吧，偷偷告诉你，我的祖传信物丢在森林深处了……",
                "\t[路过的佣兵]看到年轻的勇士这么有活力，这把祖传【蓝钥匙】就送给你防身吧！",
                {"type": "playSound", "name": "item.mp3"},
                {"type": "setValue", "name": "item:blueKey", "operator": "+=", "value": "1"},
                {"type": "tip", "text": "获得了【蓝钥匙】！"},
                "\t[贾斯汀]多谢大叔！城门就在前方，我得赶紧赶回厄泽城了。"
            ]
        }

        # 路牌 (8, 5)
        mota_events["8,5"] = {
            "trigger": "action",
            "enable": True,
            "data": [
                {"type": "playSound", "name": "cursor.mp3"},
                "\t[路牌]【厄泽城外小站】\n向东穿过最后一道哨卡，即是光辉之城【厄泽城】西城门！"
            ]
        }

        # 终点城门事件 (14, 7) -> 胜利通关！
        maze[7][14] = 89 # portal / 传送门
        mota_events["14,7"] = {
            "trigger": "action",
            "enable": True,
            "data": [
                {"type": "playSound", "name": "confirm.mp3"},
                "\t[贾斯汀]呼……终于看到厄泽城高耸雄伟的城墙和城门卫兵了！",
                "\t[贾斯汀]队长、同伴们，我活着回来了！",
                {
                    "type": "win",
                    "reason": "【胜利通关】\n恭喜你成功穿越寂静之森全部外围险境，顺利抵达【厄泽城外】！\n本垂直切片全流程已圆满达成！",
                    "norank": True
                }
            ]
        }

    floor_obj = {
        "floorId": floor_id,
        "title": title,
        "name": title,
        "width": 15,
        "height": 15,
        "canFlyTo": True,
        "canUseQuickShop": True,
        "cannotViewMap": False,
        "images": [
            {
                "name": bg_name,
                "x": 0,
                "y": 0,
                "canvas": "bg"
            }
        ],
        "ratio": 1,
        "defaultGround": "ground",
        "firstArrive": [
            {"type": "playSound", "name": "forest.mp3"},
            {"type": "tip", "text": f"进入【{title}】！"}
        ],
        "eachArrive": each_arrive,
        "parallelDo": "",
        "events": mota_events,
        "changeFloor": change_floor,
        "afterBattle": {},
        "afterGetItem": {},
        "afterOpenDoor": {},
        "cannotMove": {},
        "map": maze,
        "bgmap": [],
        "fgmap": [],
        "downFloor": down_floor_pos,
        "upFloor": up_floor_pos,
        "bgm": "forest.mp3",
        "beforeBattle": {},
        "cannotMoveIn": {},
        "autoEvent": auto_event,
        "canFlyFrom": True
    }

    out_file = os.path.join(MOTA_DIR, 'project', 'floors', f'{floor_id}.js')
    with open(out_file, 'w', encoding='utf-8') as f:
        f.write(f'main.floors.{floor_id}=\n')
        f.write(json.dumps(floor_obj, ensure_ascii=False, indent=4))
        f.write('\n')
    print(f" -> 已生成楼层脚本: {out_file}")

build_floor_data(10, 'MT3', '寂静之森外围 3F', 'map010_bg.png', 'MT2', 'MT4')
build_floor_data(12, 'MT4', '寂静之森外围 4F', 'map012_bg.png', 'MT3', 'MT5')
build_floor_data(13, 'MT5', '寂静之森外围 5F·厄泽城外', 'map013_bg.png', 'MT4', None, is_final=True)

# -------------------------------------------------------------
# 5. 更新 MT2.js 的楼梯跳转指向 MT3
# -------------------------------------------------------------
print("\n[5/6] 正在更新 MT2.js 出口连接至 MT3...")
mt2_path = os.path.join(MOTA_DIR, 'project', 'floors', 'MT2.js')
with open(mt2_path, 'r', encoding='utf-8') as f:
    mt2_txt = f.read()

mt2_txt = mt2_txt.replace('"12,0": {\n            "floorId": ":next",\n            "stair": "downFloor"\n        }',
                          '"12,0": {\n            "floorId": "MT3",\n            "loc": [3, 14]\n        }')
mt2_txt = mt2_txt.replace('"floorId": ":next"', '"floorId": "MT3", "loc": [3, 14]')

with open(mt2_path, 'w', encoding='utf-8') as f:
    f.write(mt2_txt)
print(" -> MT2.js 已连接至 MT3！")

# -------------------------------------------------------------
# 6. 更新 project/data.js 注册全量楼层与图片
# -------------------------------------------------------------
print("\n[6/6] 正在更新 project/data.js...")
data_path = os.path.join(MOTA_DIR, 'project', 'data.js')
with open(data_path, 'r', encoding='utf-8') as f:
    data_txt = f.read()

# 楼层注册
new_floors = '[\n\t\t\t"MT1",\n\t\t\t"MT2",\n\t\t\t"MT3",\n\t\t\t"MT4",\n\t\t\t"MT5"\n\t\t]'
data_txt = re.sub(r'"floorIds":\s*\[[^\]]*\]', f'"floorIds": {new_floors}', data_txt)

# 图片注册
for img in ['map010_bg.png', 'map012_bg.png', 'map013_bg.png']:
    if img not in data_txt:
        data_txt = data_txt.replace('"images": [', f'"images": [\n\t\t\t"{img}",')

with open(data_path, 'w', encoding='utf-8') as f:
    f.write(data_txt)
print(" -> project/data.js 注册完成！")

# 刷新 main.js 版本戳
main_path = os.path.join(MOTA_DIR, 'main.js')
with open(main_path, 'r', encoding='utf-8') as f:
    main_txt = f.read()
main_txt = re.sub(r'main\.version\s*=\s*"[^"]*"', f'main.version = "eze_outside_{os.urandom(4).hex()}"', main_txt)
with open(main_path, 'w', encoding='utf-8') as f:
    f.write(main_txt)

print("\n[✔] 《永不复还》-> mota-js 厄泽城外全链路构建完成！")
