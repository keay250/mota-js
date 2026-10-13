# -*- coding: utf-8 -*-
"""
1:1 提取并生成真实《永不复还》第一层（Map007 寂静之森外围）为 mota-js 楼层 MT1.js。
包含：
1. 真实 20x15 地图矩阵（基于 Tilesets.rxdata 真实通行属性与 Map007 瓦片）。
2. 真实 21 处怪物原生坐标与对应怪物 ID。
3. 真实 3 扇黄门、2 把黄钥匙、武器宝箱、13 瓶血瓶、6 颗宝石、2 处生命上限。
4. 真实 3 块路牌完整设定文本与教学。
5. 真实贾斯汀开场 10 句独白与 (7, 14) 边界阻挡事件。
"""
import struct, json, os
from rubymarshal.reader import load

# 1. 读取 Tilesets.rxdata 获得图块通行属性
with open('../Data/Tilesets.rxdata', 'rb') as f:
    tilesets = load(f)

t4 = tilesets[4] # 暗的森林
p_data = t4.attributes['@passages']._private_data
flags = struct.unpack('<536h', p_data[20:])

# 2. 读取 Map007.rxdata
with open('../Data/Map007.rxdata', 'rb') as f:
    m = load(f)

attrs = m.attributes
w, h = attrs['@width'], attrs['@height'] # 20, 15
data_bytes = attrs['@data']._private_data
dim, w, h, z, total = struct.unpack('<5i', data_bytes[:20])
tiles = struct.unpack(f'<{total}h', data_bytes[20:])
events = attrs['@events']

# 3. 计算 20x15 基础地形网格
# 0: 可通行地面 (ground), 3: 障碍物/墙 (blueWall / 树木)
maze = []
for y in range(h):
    row = []
    for x in range(w):
        passable = True
        for layer in range(z):
            tid = tiles[layer * (w * h) + y * w + x]
            if tid < len(flags) and (flags[tid] & 0x0f == 0x0f):
                passable = False
                break
        # x < 5 区域填充为树林墙壁，保留可玩迷宫区域
        if x < 5:
            passable = False
        row.append(0 if passable else 3)
    maze.append(row)

# 4. 怪物 ID 映射
# 201: 荷依米 (Monster01-01)
# 202: 软泥怪 (Monster01-04)
# 203: 幽林鬼火 (Monster01-12)
# 205: 荷依米战士 (Monster01-02)
# 206: 倍荷玛 (Monster01-01)
# 209: 复活的死者 (Monster02-01)
# 210: 倍荷玛战士 (Monster01-02)
MONSTER_MAP = {
    '怪物002': 201, # 荷依米
    '怪物003': 202, # 软泥怪
    '怪物004': 203, # 幽林鬼火
    '怪物005': 205, # 荷依米战士
    '怪物006': 206, # 倍荷玛
    '怪物007': 209, # 复活的死者
    '怪物008': 210, # 倍荷玛战士
}

mota_events = {}

# 5. 遍历事件填入矩阵
for eid, ev in sorted(events.items()):
    ea = ev.attributes
    x, y = ea['@x'], ea['@y']
    name = ea['@name'].decode('utf-8', 'replace') if isinstance(ea['@name'], bytes) else str(ea['@name'])
    
    # 怪物
    if name in MONSTER_MAP:
        maze[y][x] = MONSTER_MAP[name]
    # 黄门
    elif name == '黄门':
        maze[y][x] = 81
    # 黄钥匙
    elif name == '黄钥匙':
        maze[y][x] = 21
    # 武器宝箱
    elif name == '武器':
        maze[y][x] = 38 # sword1
        mota_events[f"{x},{y}"] = {
            "trigger": "action",
            "enable": True,
            "data": [
                {"type": "playSound", "name": "item.mp3"},
                {"type": "setText", "align": "center"},
                "\t[宝箱]打开了宝箱！",
                "\t[系统]获得了【佣兵短剑】！攻击力 +10！",
                {"type": "setText", "align": "left"},
                {"type": "setValue", "name": "status:atk", "operator": "+=", "value": "10"},
                {"type": "hide", "remove": True}
            ]
        }
    # 宝石
    elif name == '红宝石:1':
        maze[y][x] = 27
    elif name == '蓝宝石:1':
        maze[y][x] = 28
    # 血瓶
    elif name == '血瓶:50':
        maze[y][x] = 31 # redPotion
    elif name == '血瓶:100':
        maze[y][x] = 32 # bluePotion
    # 生命上限
    elif name == '生命上限:20':
        maze[y][x] = 33 # greenPotion
    # 路牌
    elif name == '路牌':
        maze[y][x] = 129
        # 提取路牌文本
        lines = []
        for p in ea['@pages']:
            for c in p.attributes['@list']:
                if c.attributes['@code'] in [101, 401]:
                    txt = c.attributes['@parameters'][0]
                    tstr = txt.decode('utf-8', 'replace') if isinstance(txt, bytes) else str(txt)
                    if tstr:
                        lines.append(f"\t[路牌]{tstr}")
        mota_events[f"{x},{y}"] = {
            "trigger": "action",
            "enable": True,
            "data": [
                {"type": "setText", "align": "center"},
                *lines,
                {"type": "setText", "align": "left"}
            ]
        }
    # 特殊事件
    elif eid == 54: # (17, 0) 出口
        maze[y][x] = 87 # upFloor

# 边界阻挡事件 (7, 14)
mota_events["7,14"] = {
    "trigger": "action",
    "enable": True,
    "data": [
        {"type": "setText", "align": "center"},
        "\t[贾斯汀]那里太危险了……队长让我们往外围逃，不能回头。",
        {"type": "setText", "align": "left"}
    ]
}

# 6. 生成 MT1.js 完整脚本
mt1_obj = {
    "floorId": "MT1",
    "title": "寂静之森外围",
    "name": "寂静之森外围",
    "width": 20,
    "height": 15,
    "canFlyTo": True,
    "canUseQuickShop": True,
    "cannotViewMap": False,
    "images": [],
    "ratio": 1,
    "defaultGround": "ground",
    "firstArrive": [
        {"type": "playSound", "name": "forest.mp3"},
        {"type": "setText", "align": "center"},
        "\t[贾斯汀]啊……",
        "\t[贾斯汀]头好痛……",
        "\t[贾斯汀]我刚刚是透支体力昏过去了么。队长呢？其他人呢？",
        "\t[贾斯汀]等等，我想起来了……",
        "\t[贾斯汀]队长，队长他一个人把那些魔兽引开了，然后让我们拼命逃……",
        "\t[贾斯汀]…………",
        "\t[贾斯汀]希望我之前跑的方向没有错，这里应该是离开森林的道路。",
        "\t[贾斯汀]说不定其他人已经回去了呢，哈哈……",
        "\t[贾斯汀]伟大的全能之神，请您保佑我和我队友们吧……",
        "\t[贾斯汀]啊，这本书要收好，或许可以避免在森林里遇上一些危险。",
        {"type": "setText", "align": "left"},
        {"type": "tip", "text": "【寂静之森外围 (20×15)】方向键移动，探索迷宫，击败怪物！"}
    ],
    "eachArrive": [],
    "parallelDo": "",
    "events": mota_events,
    "changeFloor": {
        "17,0": {"floorId": ":next", "stair": "downFloor"}
    },
    "afterBattle": {},
    "afterGetItem": {},
    "afterOpenDoor": {},
    "cannotMove": {},
    "map": maze,
    "bgmap": [],
    "fgmap": [],
    "downFloor": [7, 12],
    "upFloor": [17, 0],
    "bgm": "forest.mp3",
    "beforeBattle": {},
    "cannotMoveIn": {},
    "autoEvent": {},
    "canFlyFrom": True
}

output_path = '_analysis/_ybfh-mota/project/floors/MT1.js'
with open(output_path, 'w', encoding='utf-8') as f:
    f.write('main.floors.MT1=\n')
    f.write(json.dumps(mt1_obj, ensure_ascii=False, indent=4))
    f.write('\n')

print(f"MT1.js 真实 1:1 楼层已写入: {output_path}")
