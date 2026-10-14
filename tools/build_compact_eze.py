# -*- coding: utf-8 -*-
"""
精简版【厄泽城·中心广场】构建脚本
功能：
1. 烘焙并输出 15x15 厄泽城中心广场背景图 map017_compact_bg.png
2. 生成 MT6.js 楼层脚本（含西城门互通、格瑞迪对话、佣兵公会/装备店/酒馆大门、告示牌、黑市商人、东门守卫）
3. 更新 MT5.js (14, 7) 城门出口无缝衔接进入 MT6 (1, 7)
4. 更新 project/data.js 注册 MT6
"""

import os, json, struct, re
from rubymarshal.reader import load
import PIL.Image as Image

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MOTA_DIR = os.path.join(BASE_DIR, '_analysis', '_ybfh-mota')
RX_DATA_DIR = os.path.join(os.path.dirname(BASE_DIR), 'Data')
RX_GFX_DIR = os.path.join(os.path.dirname(BASE_DIR), 'Graphics')

print(f"[*] Base dir: {BASE_DIR}")
print(f"[*] Mota dir: {MOTA_DIR}")

# 1. 渲染 map017_compact_bg.png
print("\n[1/4] 渲染 15x15 厄泽城背景图...")
with open(os.path.join(RX_DATA_DIR, 'Tilesets.rxdata'), 'rb') as f:
    tilesets = load(f)

t10 = tilesets[10]
t_name = t10.attributes.get('@tileset_name').decode('utf-8')
at_names = [n.decode('utf-8') for n in t10.attributes.get('@autotile_names')]

autotile_imgs = {}
for i, an in enumerate(at_names):
    if an:
        p = os.path.join(RX_GFX_DIR, 'Autotiles', f'{an}.png')
        if os.path.exists(p):
            autotile_imgs[i] = Image.open(p).convert('RGBA')

tileset_img = Image.open(os.path.join(RX_GFX_DIR, 'Tilesets', f'{t_name}.png')).convert('RGBA')

with open(os.path.join(BASE_DIR, 'tools', 'autotiles.cpp'), 'r') as f:
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
                tile.paste(sub, positions[i], sub)
            return tile
        return None
    idx = tid - 384
    col = idx % 8
    row = idx // 8
    return tileset_img.crop((col * 32, row * 32, (col + 1) * 32, (row + 1) * 32))

def get_ts_tile(idx):
    col = idx % 8
    row = idx // 8
    return tileset_img.crop((col * 32, row * 32, (col + 1) * 32, (row + 1) * 32))

with open(os.path.join(RX_DATA_DIR, 'Map017.rxdata'), 'rb') as f:
    m = load(f)

w = m.attributes.get('@width') or m.attributes.get(b'@width')
h = m.attributes.get('@height') or m.attributes.get(b'@height')
tbl_data = m.attributes.get('@data')._private_data
tbl = struct.unpack(f'<{w*h*3}h', tbl_data[20:])

out = Image.new('RGBA', (15*32, 15*32), (0,0,0,0))

# 1. Base Pavement (Cobblestone Street)
for y in range(15):
    for x in range(15):
        for layer in range(3):
            tid = tbl[layer * (w*h) + 28 * w + 41]
            t = render_tile(tid)
            if t:
                out.paste(t, (x*32, y*32), t)

# 2. Mercenary Guild at (0..6, 0..4):
for layer in range(3):
    for dy, gy in enumerate(range(19, 24)):
        for dx, gx in enumerate(range(38, 45)):
            tid = tbl[layer * (w*h) + gy * w + gx]
            t = render_tile(tid)
            if t:
                out.paste(t, ((0 + dx)*32, (0 + dy)*32), t)

# Symmetrical stairs leading down at (2..4, 4..5)
for layer in range(3):
    for dy, gy in enumerate(range(23, 26)):
        for dx, gx in enumerate(range(39, 44)):
            tid = tbl[layer * (w*h) + gy * w + gx]
            t = render_tile(tid)
            if t:
                out.paste(t, ((1 + dx)*32, (2 + dy)*32), t)

# 3. Equipment Shop at (8..14, 0..4):
for layer in range(3):
    for dy, gy in enumerate(range(13, 18)):
        for dx, gx in enumerate(range(65, 72)):
            tid = tbl[layer * (w*h) + gy * w + gx]
            t = render_tile(tid)
            if t:
                out.paste(t, ((8 + dx)*32, (0 + dy)*32), t)

# Sign at (9, 3)
sign = get_ts_tile(160)
out.paste(sign, (9*32, 3*32), sign)

# 4. Tavern at (8..14, 9..14):
for layer in range(3):
    for dy, gy in enumerate(range(63, 69)):
        for dx, gx in enumerate(range(55, 62)):
            tid = tbl[layer * (w*h) + gy * w + gx]
            t = render_tile(tid)
            if t:
                out.paste(t, ((8 + dx)*32, (9 + dy)*32), t)

# 5. Black Market & Park at (0..6, 9..14):
for y in range(9, 15):
    for x in range(0, 7):
        pt = get_ts_tile(75)
        out.paste(pt, (x*32, y*32), pt)

# Market awning (striped tent) at (2..4, 10..11)
for i, idx in enumerate([99, 100, 101]):
    t = get_ts_tile(idx)
    out.paste(t, ((2 + i)*32, 10*32), t)
for i, idx in enumerate([107, 108, 109]):
    t = get_ts_tile(idx)
    out.paste(t, ((2 + i)*32, 11*32), t)

# Barrels and crates at (1, 10..12)
for i, idx in enumerate([12, 20, 28]):
    t = get_ts_tile(idx)
    out.paste(t, (1*32, (10 + i)*32), t)

# Wooden bench at (3..4, 13)
b1 = get_ts_tile(120); b2 = get_ts_tile(121)
out.paste(b1, (3*32, 13*32), b1); out.paste(b2, (4*32, 13*32), b2)

# Full potted tree at (5, 12..13)
t_top = get_ts_tile(18); t_bot = get_ts_tile(26)
out.paste(t_top, (5*32, 12*32), t_top)
out.paste(t_bot, (5*32, 13*32), t_bot)

# 6. Central Plaza Town Fountain at (6..7, 6..7):
f1 = get_ts_tile(22); f2 = get_ts_tile(23); f3 = get_ts_tile(30); f4 = get_ts_tile(31)
out.paste(f1, (6*32, 6*32), f1); out.paste(f2, (7*32, 6*32), f2)
out.paste(f3, (6*32, 7*32), f3); out.paste(f4, (7*32, 7*32), f4)

# Flower urns beside fountain
u1 = get_ts_tile(16); u2 = get_ts_tile(24)
out.paste(u1, (5*32, 6*32), u1); out.paste(u2, (5*32, 7*32), u2)
out.paste(u1, (8*32, 6*32), u1); out.paste(u2, (8*32, 7*32), u2)

# Street lamps at corners: (0, 5), (14, 5), (0, 9), (14, 9)
for lx, ly in [(0, 5), (14, 5), (0, 9), (14, 9)]:
    l1 = get_ts_tile(96); l2 = get_ts_tile(104)
    out.paste(l1, (lx*32, ly*32), l1)
    out.paste(l2, (lx*32, (ly+1)*32), l2)

bg_dest = os.path.join(MOTA_DIR, 'project', 'images', 'map017_compact_bg.png')
out.save(bg_dest)
print(f"[*] 背景图已保存至: {bg_dest}")

# 2. 生成 MT6.js
print("\n[2/4] 生成 MT6.js 楼层脚本...")
map_arr = [[0 for _ in range(15)] for _ in range(15)]

# Guild
for y in range(4):
    for x in range(7):
        map_arr[y][x] = 17
map_arr[4][0] = 17
map_arr[4][1] = 17
map_arr[4][2] = 17
map_arr[4][4] = 17
map_arr[4][5] = 17
map_arr[4][6] = 17
map_arr[5][0] = 17
map_arr[5][6] = 17

# Shop
for y in range(4):
    for x in range(8, 15):
        map_arr[y][x] = 17
map_arr[4][8] = 17
map_arr[4][9] = 17
map_arr[4][11] = 17
map_arr[4][12] = 17
map_arr[4][13] = 17
map_arr[4][14] = 17
map_arr[5][14] = 17

# Tavern
for y in range(10, 15):
    for x in range(8, 15):
        map_arr[y][x] = 17
map_arr[9][8] = 17
map_arr[9][9] = 17
map_arr[9][11] = 17
map_arr[9][12] = 17
map_arr[9][13] = 17
map_arr[9][14] = 17

# Market & Garden
map_arr[9][0] = 17
map_arr[10][1] = 17
map_arr[11][1] = 17
map_arr[12][1] = 17
map_arr[10][2] = 17
map_arr[10][3] = 17
map_arr[10][4] = 17
map_arr[13][3] = 17
map_arr[13][4] = 17
map_arr[12][5] = 17
map_arr[13][5] = 17

# Fountain & Flowers
map_arr[6][5] = 17
map_arr[7][5] = 17
map_arr[6][6] = 17
map_arr[7][6] = 17
map_arr[6][7] = 17
map_arr[7][7] = 17
map_arr[6][8] = 17
map_arr[7][8] = 17

# NPCs
map_arr[5][3] = 128  # 格瑞迪 (youngMan)
map_arr[5][7] = 129  # 告示牌 (sign)
map_arr[11][3] = 123 # 行踪诡秘的商人 (thief)
map_arr[6][13] = 121 # 守卫甲 (man)
map_arr[8][13] = 121 # 守卫乙 (man)

mt6_data = {
    "floorId": "MT6",
    "title": "厄泽城·中心广场",
    "name": "厄泽城",
    "width": 15,
    "height": 15,
    "canFlyTo": True,
    "canUseQuickShop": True,
    "cannotViewMap": False,
    "images": [
        {
            "name": "map017_compact_bg.png",
            "x": 0,
            "y": 0,
            "canvas": "bg"
        }
    ],
    "ratio": 1,
    "defaultGround": "ground",
    "firstArrive": [
        {
            "type": "playSound",
            "name": "town.mp3"
        },
        {
            "type": "tip",
            "text": "穿过西城门，成功抵达【厄泽城·中心广场】！"
        },
        {
            "type": "setText",
            "align": "left"
        },
        "\t[格瑞迪]你这小子，想不到居然还活着。怎么没和你们那傻瓜队长一块儿留在森林里？",
        "\t[贾斯汀]…………",
        "\t[格瑞迪]而且，我不止跟你说过一遍了吧？离法芙娜远一点，穷小子！",
        "\t[格瑞迪]她的容貌可不是你这种卑贱的穷佣兵所配拥有的，只有本少爷这种职业者家族出身的高贵人物才配得上，你明白吗？",
        "\t[贾斯汀]格瑞迪，休要说什么大话，你的家族也不过是和那位职业者沾点远亲关系罢了！",
        "\t[格瑞迪]哼，那又如何？还不是本少爷有权有势？告诉你，下次再见到你接近法芙娜，我就让人打断你的三条腿！",
        "\t[格瑞迪]没了你那个穷鬼队长的保护，看你还敢硬气多久！",
        "\t[贾斯汀]（格瑞迪那家伙，一直对法芙娜图谋不轨……现在拉瓦尔队长不在了，我究竟该……）",
        "\t[贾斯汀]（或许应该先去东边的【装备商店】看一看，有了公会给的这笔抚恤金，说不定能买到不错的武器与防具防身。）"
    ],
    "eachArrive": [],
    "parallelDo": "",
    "events": {
        "0,7": {
            "trigger": "action",
            "enable": True,
            "data": [
                {
                    "type": "playSound",
                    "name": "door.mp3"
                },
                {
                    "type": "changeFloor",
                    "floorId": "MT5",
                    "loc": [13, 7],
                    "direction": "left"
                }
            ]
        },
        "3,4": {
            "trigger": "action",
            "enable": True,
            "data": [
                {
                    "type": "playSound",
                    "name": "cursor.mp3"
                },
                "\t[佣兵公会]沉重的橡木大门半掩着，里面传来冒险者们喧闹的交谈声与接取委托的争辩声。",
                "\t[公会接待员]年轻的佣兵，辛苦了！目前公会正在清点寂静之森战役的抚恤金与委托清单，稍后开放大厅进入！"
            ]
        },
        "10,4": {
            "trigger": "action",
            "enable": True,
            "data": [
                {
                    "type": "playSound",
                    "name": "item.mp3"
                },
                "\t[厄泽城装备商店]工匠学徒正在叮当作响地打磨锋利的剑刃，展示架上整齐陈列着佣兵短剑、劣质皮甲、小圆盾与各种附魔首饰。",
                "\t[铁匠大师]嘿，小伙子！想换上更好的行头吗？本店正在筹备上架全新的【6格神装背包】和特技装备，很快就能为你量身打造！"
            ]
        },
        "10,9": {
            "trigger": "action",
            "enable": True,
            "data": [
                {
                    "type": "playSound",
                    "name": "recovery.mp3"
                },
                "\t[瑞格沃酒馆]扑面而来的是醇厚的麦酒香气与烤肉滋滋作响的声音，游吟诗人正坐在炉火旁拨弄琴弦。",
                "\t[酒馆侍者]欢迎光临瑞格沃酒馆！来一杯冰镇麦酒暖暖身子吧，疲劳度已完全清除！",
                {
                    "type": "setValue",
                    "name": "status:hp",
                    "operator": "=",
                    "value": "status:maxHp"
                },
                {
                    "type": "tip",
                    "text": "生命值已完全恢复！"
                }
            ]
        },
        "5,3": {
            "trigger": "action",
            "enable": True,
            "data": [
                {
                    "type": "playSound",
                    "name": "cursor.mp3"
                },
                "\t[格瑞迪]还站在这儿发什么愣？听懂我的话了就赶紧滚开，别妨碍本少爷去向法芙娜献殷勤！"
            ]
        },
        "5,7": {
            "trigger": "action",
            "enable": True,
            "data": [
                {
                    "type": "playSound",
                    "name": "cursor.mp3"
                },
                "\t[厄泽城政厅告示牌]—— 厄泽城公报 ——\n1. 寂静之森外围魔物滋生，西城门严禁平民无护卫通行；\n2. 佣兵公会正在发放阵亡队伍同伴抚恤与装备折现；\n3. 城东要道通往姆伊森运河与王都，目前战备戒严，非高阶佣兵不得擅闯。"
            ]
        },
        "11,3": {
            "trigger": "action",
            "enable": True,
            "data": [
                {
                    "type": "playSound",
                    "name": "door.mp3"
                },
                "\t[行踪诡秘的商人]嘘……小声点！我这里有一些从古代遗迹流出来的神秘卷轴和特技技能书……",
                "\t[行踪诡秘的商人]等风头过了，我会在黑市正式出摊，可别忘了多攒点金币！"
            ]
        },
        "6,13": {
            "trigger": "action",
            "enable": True,
            "data": [
                {
                    "type": "playSound",
                    "name": "cursor.mp3"
                },
                "\t[城东守卫甲]站住！前方是通向王都与运河的城防前线，没有总督特批的通行公文严禁出城！"
            ]
        },
        "8,13": {
            "trigger": "action",
            "enable": True,
            "data": [
                {
                    "type": "playSound",
                    "name": "cursor.mp3"
                },
                "\t[城东守卫乙]小佣兵，城里有公会、铁匠铺和酒馆，先去休整武装好自己吧！"
            ]
        },
        "14,7": {
            "trigger": "action",
            "enable": True,
            "data": [
                {
                    "type": "playSound",
                    "name": "cursor.mp3"
                },
                "\t[城东大门]高耸坚固的黑铁城门紧闭着，两旁守卫森严，通往辽阔的大陆彼端与第二章【王都崛起】。"
            ]
        }
    },
    "changeFloor": {},
    "beforeBattle": {},
    "afterBattle": {},
    "afterGetItem": {},
    "afterOpenDoor": {},
    "cannotMove": {},
    "map": map_arr
}

mt6_file = os.path.join(MOTA_DIR, 'project', 'floors', 'MT6.js')
with open(mt6_file, 'w', encoding='utf-8') as f:
    f.write('main.floors.MT6=\n' + json.dumps(mt6_data, ensure_ascii=False, indent=4) + '\n')
print(f"[*] MT6.js 已写入: {mt6_file}")

# 3. 更新 MT5.js (14, 7) 城门出口
print("\n[3/4] 更新 MT5.js 城门出口指向 MT6...")
mt5_file = os.path.join(MOTA_DIR, 'project', 'floors', 'MT5.js')
with open(mt5_file, 'r', encoding='utf-8') as f:
    mt5_text = f.read()

# Replace the victory event at 14,7 with a smooth transition to MT6
mt5_json = json.loads(mt5_text.split('=', 1)[1])
mt5_json['events']['14,7'] = {
    "trigger": "action",
    "enable": True,
    "data": [
        {
            "type": "playSound",
            "name": "door.mp3"
        },
        "\t[贾斯汀]队长、同伴们，我活着回来了！",
        {
            "type": "changeFloor",
            "floorId": "MT6",
            "loc": [1, 7],
            "direction": "right"
        }
    ]
}

with open(mt5_file, 'w', encoding='utf-8') as f:
    f.write('main.floors.MT5=\n' + json.dumps(mt5_json, ensure_ascii=False, indent=4) + '\n')
print(f"[*] MT5.js 已更新城门出口 -> MT6 (1, 7)")

# 4. 更新 project/data.js
print("\n[4/4] 更新 project/data.js 注册 MT6...")
data_file = os.path.join(MOTA_DIR, 'project', 'data.js')
with open(data_file, 'r', encoding='utf-8') as f:
    data_content = f.read()

data_json = json.loads(data_content.split('=', 1)[1])

if 'MT6' not in data_json['main']['floorIds']:
    data_json['main']['floorIds'].append('MT6')
    print("[*] MT6 添加至 main.floorIds")

if 'map017_compact_bg.png' not in data_json['main']['images']:
    data_json['main']['images'].append('map017_compact_bg.png')
    print("[*] map017_compact_bg.png 添加至 main.images")

with open(data_file, 'w', encoding='utf-8') as f:
    f.write('var data_a1e2fb4a_e986_4524_b0da_9b7ba7c0874d =\n' + json.dumps(data_json, ensure_ascii=False, indent=4) + '\n')
print(f"[*] data.js 已更新")

print("\n[OK] 厄泽城·中心广场 (MT6) 构建并注册完毕！")
