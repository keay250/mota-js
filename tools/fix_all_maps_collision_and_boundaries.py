# -*- coding: utf-8 -*-
"""
fix_all_maps_collision_and_boundaries.py
批量修复所有楼层 (MT1 ~ MT16) 的边界穿模、黑边虚空漫游、阻挡泄漏以及传送落点堵塞问题。
"""

import os, json, re

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
FLOORS_DIR = os.path.join(BASE_DIR, '_analysis', '_ybfh-mota', 'project', 'floors')
COLLISIONS_JSON = os.path.join(BASE_DIR, 'tools', 'rmxp_indoor_collisions.json')

with open(COLLISIONS_JSON, 'r', encoding='utf-8') as f:
    indoor_collisions = json.load(f)

def load_floor(floor_id):
    path = os.path.join(FLOORS_DIR, f'{floor_id}.js')
    with open(path, 'r', encoding='utf-8') as f:
        text = f.read()
    m = re.search(r'main\.floors\.\w+\s*=\s*(\{[\s\S]*\})', text)
    if not m:
        raise ValueError(f"Failed to parse {floor_id}.js")
    data = json.loads(m.group(1))
    return path, data

def save_floor(path, floor_id, data):
    with open(path, 'w', encoding='utf-8') as f:
        f.write(f'main.floors.{floor_id} =\n')
        json.dump(data, f, ensure_ascii=False, indent=4)
        f.write('\n')
    print(f"  [+] Saved {floor_id}.js")

# 1. 修复 MT1.js: (2, 14) 底部空气墙
print("\n[1/12] 修复 MT1.js 底部边缘穿模...")
p, d = load_floor('MT1')
d['map'][14][2] = 17
save_floor(p, 'MT1', d)

# 2. 修复 MT3.js: (0, 3) 西侧未开放支线空气墙 + (13, 5) 落地安全点
print("\n[2/12] 修复 MT3.js 边界与怪物 202 站位...")
p, d = load_floor('MT3')
d['map'][3][0] = 17
d['events'] = d.get('events', {})
d['events']['0,3'] = {
    "trigger": "action",
    "enable": True,
    "data": [
        {"type": "playSound", "name": "cursor.mp3"},
        "\t[山壁塌方]通往密林更深处的哥布林洞穴已被巨石阻塞，前方道路暂未开放。"
    ]
}
# 移走 (13, 5) 的怪物 202 到 (12, 5)，腾出安全落脚点
if d['map'][5][13] == 202:
    d['map'][5][12] = 202
    d['map'][5][13] = 0
    print("  [+] MT3: 怪物 202 已移至 (12, 5)，(13, 5) 成为安全落点")
save_floor(p, 'MT3', d)

# 3. 修复 MT4.js: (13, 7) 怪物 214 站位
print("\n[3/12] 修复 MT4.js 怪物 214 站位...")
p, d = load_floor('MT4')
if d['map'][7][13] == 214:
    d['map'][6][13] = 214
    d['map'][7][13] = 0
    print("  [+] MT4: 怪物 214 已移至 (13, 6)，(13, 7) 成为安全落点")
save_floor(p, 'MT4', d)

# 4. 修复 MT5.js: 顶部/底部/右侧城墙边界空气墙
print("\n[4/12] 修复 MT5.js 边界空气墙...")
p, d = load_floor('MT5')
# 顶部 9..14
for x in range(9, 15):
    d['map'][0][x] = 17
# 底部 9..14
for x in range(9, 15):
    d['map'][14][x] = 17
# 右侧 14, 除了 (14, 7) 城门外其余全为 17
for y in range(15):
    if y != 7:
        d['map'][y][14] = 17
save_floor(p, 'MT5', d)

# 5. 修复 MT6.js: 75x75 外围全周密封空气墙
print("\n[5/12] 修复 MT6.js 75x75 外围全周空气墙...")
p, d = load_floor('MT6')
w, h = d['width'], d['height']
for x in range(w):
    d['map'][0][x] = 17
    d['map'][h - 1][x] = 17
for y in range(h):
    d['map'][y][0] = 17
    d['map'][y][w - 1] = 17
save_floor(p, 'MT6', d)

# 6. 修复 MT7.js: RMXP 真实室内碰撞矩阵 + 守卫放行逻辑
print("\n[6/12] 修复 MT7.js 佣兵公会碰撞与守卫逻辑...")
p, d = load_floor('MT7')
rmxp_g7 = indoor_collisions['MT7']
for y in range(len(rmxp_g7)):
    for x in range(len(rmxp_g7[0])):
        if rmxp_g7[y][x] == 17:
            # 仅在非关键出口/落点处覆盖为 17
            if (x, y) not in [(15, 37), (15, 36), (23, 30), (22, 30)]:
                d['map'][y][x] = 17
        elif d['map'][y][x] == 17 and (x, y) not in [(22, 30)]:
            # 如果原版未阻挡且不是事件NPC，则还原为 0
            coord_k = f"{x},{y}"
            if coord_k not in d.get('events', {}):
                d['map'][y][x] = 0

# 确保所有 action NPC 具有阻挡 (避免穿模/保证碰撞交互生效)
for k, ev in d.get('events', {}).items():
    if ev.get('trigger') == 'action' and k not in d.get('changeFloor', {}) and k != '22,30':
        nx, ny = map(int, k.split(','))
        d['map'][ny][nx] = 17

# 确保出口和安全落点为 0
d['map'][37][15] = 0
d['map'][36][15] = 0
d['map'][30][23] = 0
d['map'][30][22] = 0

# 在 eachArrive 增加守卫自动放行
d['eachArrive'] = d.get('eachArrive', [])
has_guard_arrive = any('fafna_quest_done' in json.dumps(x) for x in d['eachArrive'])
if not has_guard_arrive:
    d['eachArrive'].append({
        "type": "if",
        "condition": "core.hasFlag('fafna_quest_done')",
        "true": [
            {
                "type": "function",
                "function": "function() { core.removeBlock(22, 30); }"
            }
        ]
    })
# 更新 22,30 守卫对话
if '22,30' in d.get('events', {}):
    d['events']['22,30']['data'] = [
        {
            "type": "if",
            "condition": "core.hasFlag('fafna_quest_done')",
            "true": [
                {"type": "function", "function": "function() { core.removeBlock(22, 30); }"},
                "\t[重装佣兵,man]\b[up,22,30]……原来是贾斯汀兄弟！既然执事大人准许，回廊里面请！"
            ],
            "false": [
                "\t[重装佣兵,man]\b[up,22,30]这里闲人免进！后面的回廊通向公会重地与接待员寝居，没有许可不得入内！"
            ]
        }
    ]
save_floor(p, 'MT7', d)

# 7. 修复 MT8.js: 装备商店 RMXP 真实碰撞
print("\n[7/12] 修复 MT8.js 装备商店全周黑边与柜台碰撞...")
p, d = load_floor('MT8')
rmxp_g8 = indoor_collisions['MT8']
for y in range(len(rmxp_g8)):
    for x in range(len(rmxp_g8[0])):
        if rmxp_g8[y][x] == 17:
            if (x, y) not in [(5, 16), (5, 15)]:
                d['map'][y][x] = 17
        elif d['map'][y][x] == 17:
            d['map'][y][x] = 0
d['map'][16][5] = 0
d['map'][15][5] = 0
save_floor(p, 'MT8', d)

# 8. 修复 MT9.js: 瑞格沃酒馆 RMXP 真实碰撞
print("\n[8/12] 修复 MT9.js 瑞格沃酒馆全周黑边碰撞...")
p, d = load_floor('MT9')
rmxp_g9 = indoor_collisions['MT9']
for y in range(len(rmxp_g9)):
    for x in range(len(rmxp_g9[0])):
        if rmxp_g9[y][x] == 17:
            if (x, y) not in [(5, 15), (5, 14)]:
                d['map'][y][x] = 17
        elif d['map'][y][x] == 17:
            d['map'][y][x] = 0
d['map'][15][5] = 0
d['map'][14][5] = 0
save_floor(p, 'MT9', d)

# 9. 修复 MT10.js: 公会右侧回廊 RMXP 真实碰撞 + 传送落点修正
print("\n[9/12] 修复 MT10.js 公会右侧回廊碰撞与落点...")
p, d = load_floor('MT10')
rmxp_g10 = indoor_collisions['MT10']
for y in range(len(rmxp_g10)):
    for x in range(len(rmxp_g10[0])):
        if rmxp_g10[y][x] == 17:
            if (x, y) not in [(1, 8), (2, 8), (16, 7)]:
                d['map'][y][x] = 17
        elif d['map'][y][x] == 17 and (x, y) not in [(16, 6)]:
            d['map'][y][x] = 0
d['map'][8][1] = 0
d['map'][8][2] = 0
d['map'][7][16] = 0
d['map'][6][16] = 17 # 门
# 修正返回 MT7 的落脚点至 [22, 30]
d['changeFloor']['1,8']['loc'] = [22, 30]
d['changeFloor']['1,8']['direction'] = "left"
save_floor(p, 'MT10', d)

# 10. 修复 MT11.js: 法芙娜寓所 RMXP 真实碰撞 + 传送落点修正
print("\n[10/12] 修复 MT11.js 法芙娜寓所碰撞与落点...")
p, d = load_floor('MT11')
rmxp_g11 = indoor_collisions['MT11']
for y in range(len(rmxp_g11)):
    for x in range(len(rmxp_g11[0])):
        if rmxp_g11[y][x] == 17:
            if (x, y) not in [(8, 12), (8, 11)]:
                d['map'][y][x] = 17
        elif d['map'][y][x] == 17:
            d['map'][y][x] = 0
d['map'][12][8] = 0
d['map'][11][8] = 0
# 修正返回 MT10 的落点至 [16, 7]
d['changeFloor']['8,12']['loc'] = [16, 7]
d['changeFloor']['8,12']['direction'] = "down"
save_floor(p, 'MT11', d)

# 11. 修复 MT14.js: (0, 8) 姆伊森运河下游激流未开放支线空气墙
print("\n[11/12] 修复 MT14.js (0, 8) 激流边界空气墙...")
p, d = load_floor('MT14')
d['map'][8][0] = 17
d['events'] = d.get('events', {})
d['events']['0,8'] = {
    "trigger": "action",
    "enable": True,
    "data": [
        {"type": "playSound", "name": "cursor.mp3"},
        "\t[湍急激流]前方姆伊森运河下游激流湍急，尚未开放通行。"
    ]
}
save_floor(p, 'MT14', d)

# 12. 修复 MT15.js: 怪物 210 站位
print("\n[12/12] 修复 MT15.js 怪物 210 站位...")
p, d = load_floor('MT15')
if d['map'][1][7] == 210:
    d['map'][1][5] = 210
    d['map'][1][6] = 0
    d['map'][1][7] = 0
    print("  [+] MT15: 怪物 210 已移至 (5, 1)，(7, 1) 成为安全落点")
save_floor(p, 'MT15', d)

print("\n🎉 全量楼层碰撞与边界修复完成！")
