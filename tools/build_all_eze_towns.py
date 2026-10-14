# -*- coding: utf-8 -*-
"""
1:1 完整构建《永不复还》厄泽城生活区与室内建筑体系 (MT8 ~ MT11)
包含：
1. MT8: 装备商店 (Map018 - 裁切居中 15x17) - 带真实店员购买系统 (短剑/皮甲/护手/骷髅盾/回复戒指)
2. MT9: 瑞格沃酒馆 (Map020 - 裁切居中 21x16) - 老板娘生活氛围、生命完全恢复、红发佣兵与重甲佣兵
3. MT10: 公会右侧回廊 (Map048 - 裁切居中 23x15) - 探索回廊、守卫、格瑞迪破门对峙
4. MT11: 法芙娜寓所 (Map058 - 裁切居中 15x15) - 32句核心主线剧情摊牌、第一章大转场通往王都
5. 更新 MT6.js (打通装备店 68,16 与酒馆 58,67 大门)
6. 更新 MT7.js (打通右侧回廊 23,30 大门与守卫放行逻辑)
7. 注册 project/data.js, items.js, plugins.js 全套资源与装备
"""

import os, json, struct, re, time
from rubymarshal.reader import load
import PIL.Image as Image

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MOTA_DIR = os.path.join(BASE_DIR, '_analysis', '_ybfh-mota')
RX_DATA_DIR = os.path.join(os.path.dirname(BASE_DIR), 'Data')
RX_GFX_DIR = os.path.join(os.path.dirname(BASE_DIR), 'Graphics')

true = True
false = False

print(f"[*] Base dir: {BASE_DIR}")
print(f"[*] Mota dir: {MOTA_DIR}")
print(f"[*] RMXP data dir: {RX_DATA_DIR}")

# 载入 autotiles.cpp 的 48-Autotile 切片坐标
with open(os.path.join(BASE_DIR, 'tools', 'autotiles.cpp'), 'r') as f:
    text = f.read()
matches = re.findall(r'\{\s*([\d\.]+),\s*([\d\.]+),\s*([\d\.]+),\s*([\d\.]+)\s*\}', text)
rects = [(int(float(m[0])), int(float(m[1])), int(float(m[2])), int(float(m[3]))) for m in matches]

# 载入 Tilesets.rxdata
with open(os.path.join(RX_DATA_DIR, 'Tilesets.rxdata'), 'rb') as f:
    tilesets = load(f)

dir_row_map = {2: 0, 4: 1, 6: 2, 8: 3}

def render_town_map(map_id, tileset_id, bg_filename, crop_x=0, crop_w=None, crop_y=0, crop_h=None):
    print(f"\n---> 开始渲染 Map{map_id:03d} (Tileset {tileset_id}) -> {bg_filename}...")
    t0 = time.time()
    ts_obj = tilesets[tileset_id]
    t_name = ts_obj.attributes.get('@tileset_name').decode('utf-8')
    at_names = [n.decode('utf-8') if n else '' for n in ts_obj.attributes.get('@autotile_names')]

    autotile_imgs = {}
    for i, an in enumerate(at_names):
        if an:
            p = os.path.join(RX_GFX_DIR, 'Autotiles', f'{an}.png')
            if os.path.exists(p):
                autotile_imgs[i] = Image.open(p).convert('RGBA')

    tileset_img = Image.open(os.path.join(RX_GFX_DIR, 'Tilesets', f'{t_name}.png')).convert('RGBA')

    tile_cache = {}
    def render_tile(tid):
        if tid < 48:
            return None
        if tid in tile_cache:
            return tile_cache[tid]
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
                tile_cache[tid] = tile
                return tile
            return None
        idx = tid - 384
        col = idx % 8
        row = idx // 8
        tile = tileset_img.crop((col * 32, row * 32, (col + 1) * 32, (row + 1) * 32))
        tile_cache[tid] = tile
        return tile

    with open(os.path.join(RX_DATA_DIR, f'Map{map_id:03d}.rxdata'), 'rb') as f:
        m = load(f)

    orig_w = m.attributes.get('@width') or m.attributes.get(b'@width')
    orig_h = m.attributes.get('@height') or m.attributes.get(b'@height')
    tbl_data = m.attributes.get('@data')._private_data
    tbl = struct.unpack(f'<{orig_w*orig_h*3}h', tbl_data[20:])

    pri_data = ts_obj.attributes['@priorities']._private_data
    priorities = struct.unpack(f'<{len(pri_data)//2 - 10}h', pri_data[20:])

    render_items = []
    seq = 0

    for layer in range(3):
        layer_offset = layer * (orig_w * orig_h)
        for y in range(orig_h):
            for x in range(orig_w):
                tid = tbl[layer_offset + y * orig_w + x]
                if tid == 0: continue
                p = priorities[tid] if tid < len(priorities) else 0
                t = render_tile(tid)
                if not t: continue
                if p == 0:
                    render_items.append((0, layer, seq, 'tile', (t, x * 32, y * 32)))
                else:
                    z = y * 32 + p * 32
                    render_items.append((z, layer, seq, 'tile', (t, x * 32, y * 32)))
                seq += 1

    events = m.attributes.get('@events', {})
    for eid, ev in sorted(events.items()):
        attrs = ev.attributes
        ex = attrs.get('@x')
        ey = attrs.get('@y')
        pages = attrs.get('@pages', [])
        if not pages: continue
        p0 = pages[0].attributes
        g = p0.get('@graphic')
        if not g: continue
        g_attrs = g.attributes
        cname = g_attrs.get('@character_name', '')
        if isinstance(cname, bytes): cname = cname.decode('utf-8', 'ignore')
        if not cname: continue

        char_path = os.path.join(RX_GFX_DIR, 'Characters', f'{cname}.png')
        if os.path.exists(char_path):
            cimg = Image.open(char_path).convert('RGBA')
            cw = cimg.width // 4
            ch = cimg.height // 4
            direction = g_attrs.get('@direction', 2)
            pattern = g_attrs.get('@pattern', 0)
            row = dir_row_map.get(direction, 0)
            col = pattern
            sub = cimg.crop((col * cw, row * ch, (col + 1) * cw, (row + 1) * ch))

            px = ex * 32 + (32 - cw) // 2
            py = (ey + 1) * 32 - ch
            z = (ey + 1) * 32
            render_items.append((z, 1.5, seq, 'npc', (sub, px, py, cname, ex, ey)))
            seq += 1

    render_items.sort(key=lambda it: (it[0], it[1], it[2]))
    full_img = Image.new('RGBA', (orig_w * 32, orig_h * 32), (0, 0, 0, 0))
    for it in render_items:
        if it[3] == 'tile':
            t, tx, ty = it[4]
            full_img.paste(t, (tx, ty), t)
        else:
            sub, px, py, cname, ex, ey = it[4]
            full_img.paste(sub, (px, py), sub)

    # 计算原始通行矩阵
    p_data = ts_obj.attributes['@passages']._private_data
    flags = struct.unpack(f'<{len(p_data)//2 - 10}h', p_data[20:])
    orig_map_arr = [[0 for _ in range(orig_w)] for _ in range(orig_h)]

    for y in range(orig_h):
        for x in range(orig_w):
            is_blocked = False
            for layer in [2, 1, 0]:
                tid = tbl[layer * (orig_w * orig_h) + y * orig_w + x]
                if tid == 0:
                    continue
                flag = flags[tid] if tid < len(flags) else 0
                if (flag & 0x10) != 0:
                    continue
                if (flag & 0x0f) != 0:
                    is_blocked = True
                    break
                else:
                    break
            if is_blocked:
                orig_map_arr[y][x] = 17

    # 给 NPC 所在格子加上阻挡
    for eid, ev in events.items():
        attrs = ev.attributes
        ex = attrs.get('@x')
        ey = attrs.get('@y')
        pages = attrs.get('@pages', [])
        if pages and pages[0].attributes.get('@graphic') and pages[0].attributes.get('@graphic').attributes.get('@character_name'):
            orig_map_arr[ey][ex] = 17

    # 裁切优化
    final_w = crop_w if crop_w is not None else orig_w
    final_h = crop_h if crop_h is not None else orig_h
    if crop_x != 0 or crop_y != 0 or crop_w is not None or crop_h is not None:
        full_img = full_img.crop((crop_x * 32, crop_y * 32, (crop_x + final_w) * 32, (crop_y + final_h) * 32))
        map_arr = []
        for y in range(crop_y, crop_y + final_h):
            row = []
            for x in range(crop_x, crop_x + final_w):
                row.append(orig_map_arr[y][x])
            map_arr.append(row)
    else:
        map_arr = orig_map_arr

    bg_dest = os.path.join(MOTA_DIR, 'project', 'images', bg_filename)
    full_img.save(bg_dest)
    print(f"  [+] {bg_filename} 渲染完成 ({full_img.size})，用时 {time.time() - t0:.2f}s")

    return final_w, final_h, map_arr, events

# -------------------------------------------------------------
# 1. 渲染四大室内地图并提取阻挡矩阵 (包含黄金居中裁切)
# -------------------------------------------------------------
# Map018 (装备商店): 原 20x18，裁剪 x 从 5 到 20 (宽 15)，y 从 0 到 17 (高 17)
w18, h18, map18, ev18 = render_town_map(18, 73, 'map018_bg.png', crop_x=5, crop_w=15, crop_y=0, crop_h=17)

# Map020 (瑞格沃酒馆): 原 30x20，裁剪 x 从 7 到 28 (宽 21)，y 从 0 到 16 (高 16)
w20, h20, map20, ev20 = render_town_map(20, 74, 'map020_bg.png', crop_x=7, crop_w=21, crop_y=0, crop_h=16)

# Map048 (公会右侧回廊): 原 30x15，裁剪 x 从 7 到 30 (宽 23)，y 从 0 到 15 (高 15)
w48, h48, map48, ev48 = render_town_map(48, 73, 'map048_bg.png', crop_x=7, crop_w=23, crop_y=0, crop_h=15)

# Map058 (法芙娜寓所): 原 20x15，裁剪 x 从 5 到 20 (宽 15)，y 从 0 到 15 (高 15)
w58, h58, map58, ev58 = render_town_map(58, 73, 'map058_bg.png', crop_x=5, crop_w=15, crop_y=0, crop_h=15)

# -------------------------------------------------------------
# 2. 构建 MT8.js (装备商店 Map018 - 裁切后 15x17)
# -------------------------------------------------------------
print("\n[2/7] 构建 MT8.js (装备商店)...")
# 原坐标 x=10 变为 x=5 (10-5); y=15, y=16
map18[15][5] = 0 # 入口落脚点
map18[16][5] = 0 # 大门出口

mt8_events = {
    # 出门传送回到 MT6 (68, 17)
    "5,16": {
        "trigger": "action",
        "enable": True,
        "data": [
            {"type": "playSound", "name": "door.mp3"},
            {"type": "changeFloor", "floorId": "MT6", "loc": [68, 17], "direction": "down"}
        ]
    },
    # 店员 (原 12,8 变为 7,8) 售卖真实商品
    "7,8": {
        "trigger": "action",
        "enable": True,
        "data": [
            {"type": "playSound", "name": "cursor.mp3"},
            "\t[店员,shopkeeper]\b[up,7,8]小哥，来选个装备吧！保证物美价廉，实用不易磨损！",
            {
                "type": "choices",
                "text": "\t[店员,shopkeeper]你想挑选哪件装备？",
                "choices": [
                    {
                        "text": "佣兵短剑 (30 G) - 攻击力 +15",
                        "action": [
                            {
                                "type": "if",
                                "condition": "core.getStatus('money') >= 30",
                                "true": [
                                    {"type": "setValue", "name": "status:money", "operator": "-=", "value": "30"},
                                    {"type": "getItem", "name": "mercenarySword"},
                                    {"type": "playSound", "name": "item.mp3"},
                                    "\t[店员,shopkeeper]\b[up,7,8]多谢惠顾！这把短剑虽然轻便，但非常趁手！"
                                ],
                                "false": [
                                    "\t[店员,shopkeeper]\b[up,7,8]小哥，你带的金币好像不够 30G 呢……"
                                ]
                            }
                        ]
                    },
                    {
                        "text": "劣质皮甲 (20 G) - 防御 +3, 生命 +50",
                        "action": [
                            {
                                "type": "if",
                                "condition": "core.getStatus('money') >= 20",
                                "true": [
                                    {"type": "setValue", "name": "status:money", "operator": "-=", "value": "20"},
                                    {"type": "getItem", "name": "poorLeather"},
                                    {"type": "playSound", "name": "item.mp3"},
                                    "\t[店员,shopkeeper]\b[up,7,8]多谢惠顾！好歹能抵挡野兽的撕咬！"
                                ],
                                "false": [
                                    "\t[店员,shopkeeper]\b[up,7,8]小哥，金币不够 20G 哦。"
                                ]
                            }
                        ]
                    },
                    {
                        "text": "轻骑护手 (120 G) - 攻击速度与敏捷 +15",
                        "action": [
                            {
                                "type": "if",
                                "condition": "core.getStatus('money') >= 120",
                                "true": [
                                    {"type": "setValue", "name": "status:money", "operator": "-=", "value": "120"},
                                    {"type": "getItem", "name": "lightGauntlets"},
                                    {"type": "playSound", "name": "item.mp3"},
                                    "\t[店员,shopkeeper]\b[up,7,8]好眼光！轻骑兵专用护手，让你出刀快如疾风！"
                                ],
                                "false": [
                                    "\t[店员,shopkeeper]\b[up,7,8]这件护手需要 120G 呢，攒够钱再来吧！"
                                ]
                            }
                        ]
                    },
                    {
                        "text": "骷髅盾 (70 G) - 防御 +12, 自带10%物理减伤",
                        "action": [
                            {
                                "type": "if",
                                "condition": "core.getStatus('money') >= 70",
                                "true": [
                                    {"type": "setValue", "name": "status:money", "operator": "-=", "value": "70"},
                                    {"type": "getItem", "name": "skullShield"},
                                    {"type": "playSound", "name": "item.mp3"},
                                    "\t[店员,shopkeeper]\b[up,7,8]从古代遗迹发掘出的坚固骨盾，防御力非常惊人！"
                                ],
                                "false": [
                                    "\t[店员,shopkeeper]\b[up,7,8]骷髅盾需要 70G 哦。"
                                ]
                            }
                        ]
                    },
                    {
                        "text": "回复戒指 (850 G) - 持续生命回复 +15/t",
                        "action": [
                            {
                                "type": "if",
                                "condition": "core.getStatus('money') >= 850",
                                "true": [
                                    {"type": "setValue", "name": "status:money", "operator": "-=", "value": "850"},
                                    {"type": "getItem", "name": "ringOfRegen"},
                                    {"type": "playSound", "name": "item.mp3"},
                                    "\t[店员,shopkeeper]\b[up,7,8]镇店之宝！持续恢复活力的附魔戒指，祝你在战场上化险为夷！"
                                ],
                                "false": [
                                    "\t[店员,shopkeeper]\b[up,7,8]这是本店的高阶附魔首饰，售价 850G 呢。"
                                ]
                            }
                        ]
                    },
                    {
                        "text": "我再看看 (离开)",
                        "action": [
                            "\t[店员,shopkeeper]\b[up,7,8]没关系，随时欢迎回来挑选！"
                        ]
                    }
                ]
            }
        ]
    },
    # 路牌 (原 10,10 变为 5,10) 护甲机制
    "5,10": {
        "trigger": "action",
        "enable": True,
        "data": [
            {"type": "playSound", "name": "cursor.mp3"},
            "\t[设定说明之护甲]\b[up,5,10]护甲能够以百分比形式减少敌人的物理伤害。\n这个减伤系数由你的护甲值决定。\n至于其中的公式，可以变相理解为每点护甲为你提供6%的血量收益，10点护甲相当于在计算物理伤害时你的1点血量可以发挥出1.6点血量的作用。\n而护甲为负时每点则会增加6%受到的物理伤害。\n当然，有必要再次重申：护甲减伤只对物理伤害有效，而敌人的普通攻击属于物理伤害。"
        ]
    }
}

mt8_data = {
    "floorId": "MT8",
    "title": "厄泽城·装备商店",
    "name": "装备商店",
    "width": w18,
    "height": h18,
    "canFlyTo": False,
    "canUseQuickShop": True,
    "cannotViewMap": False,
    "defaultGround": "ground",
    "images": [
        {"name": "map018_bg.png", "canvas": "bg", "x": 0, "y": 0}
    ],
    "ratio": 1,
    "upFloor": [5, 15],
    "downFloor": [5, 15],
    "firstArrive": [{"type": "tip", "text": "进入【厄泽城·装备商店】"}],
    "eachArrive": [],
    "parallelDo": "",
    "events": mt8_events,
    "changeFloor": {
        "5,16": {"floorId": "MT6", "loc": [68, 17], "direction": "down"}
    },
    "beforeBattle": {},
    "afterBattle": {},
    "afterGetItem": {},
    "afterOpenDoor": {},
    "cannotMove": {},
    "map": map18
}

with open(os.path.join(MOTA_DIR, 'project', 'floors', 'MT8.js'), 'w', encoding='utf-8') as f:
    f.write('main.floors.MT8 =\n')
    json.dump(mt8_data, f, ensure_ascii=False, indent=4)
print("  [+] MT8.js 写入完成！")

# -------------------------------------------------------------
# 3. 构建 MT9.js (瑞格沃酒馆 Map020 - 裁切后 21x16)
# -------------------------------------------------------------
print("\n[3/7] 构建 MT9.js (瑞格沃酒馆)...")
# 原坐标 x=12 变为 x=5 (12-7); y=14, y=15
map20[14][5] = 0 # 入口落脚点
map20[15][5] = 0 # 出门点

mt9_events = {
    # 出门传送回到 MT6 (58, 68)
    "5,15": {
        "trigger": "action",
        "enable": True,
        "data": [
            {"type": "playSound", "name": "door.mp3"},
            {"type": "changeFloor", "floorId": "MT6", "loc": [58, 68], "direction": "down"}
        ]
    },
    # 老板娘 (原 14,7 变为 7,7)
    "7,7": {
        "trigger": "action",
        "enable": True,
        "data": [
            {"type": "playSound", "name": "cursor.mp3"},
            "\t[老板娘,woman]\b[up,7,7]哎呀小哥，看你风尘仆仆的，快坐下歇歇脚！",
            "\t[老板娘,woman]\b[up,7,7]瑞格沃酒馆有全城最地道的麦酒和烤肉，喝上一杯，疲劳一扫而空！",
            {
                "type": "choices",
                "text": "\t[老板娘,woman]要来一杯招牌麦酒（恢复全部生命与体力）吗？",
                "choices": [
                    {
                        "text": "来一杯！(免费犒劳年轻佣兵)",
                        "action": [
                            {"type": "playSound", "name": "recovery.mp3"},
                            {"type": "setValue", "name": "status:hp", "operator": "=", "value": "status:maxHp"},
                            {"type": "tip", "text": "生命值已完全恢复！"},
                            "\t[老板娘,woman]\b[up,7,7]精神好多了吧！在外面闯荡可别太拼命，公会那群老狐狸可不会心疼你！"
                        ]
                    },
                    {
                        "text": "暂时不用，谢谢老板娘",
                        "action": [
                            "\t[老板娘,woman]\b[up,7,7]好嘞，有需要随时叫我！"
                        ]
                    }
                ]
            }
        ]
    },
    # 重甲佣兵 (原 18,11 变为 11,11)
    "11,11": {
        "trigger": "action",
        "enable": True,
        "data": [
            {"type": "playSound", "name": "cursor.mp3"},
            "\t[重甲佣兵,man]\b[up,11,11]妈的，公会那帮人真是让人火大！",
            "\t[重甲佣兵,man]\b[up,11,11]居然说只允许特级佣兵通过封锁线，还把老子给踹了回来！",
            "\t[重甲佣兵,man]\b[up,11,11]奶奶的，不就是特级佣兵吗，老子只需要顶多几个月就能晋升了，至于在乎那么一会儿？！"
        ]
    },
    # 红发佣兵 (原 20,6 变为 13,6)
    "13,6": {
        "trigger": "action",
        "enable": True,
        "data": [
            {"type": "playSound", "name": "cursor.mp3"},
            "\t[红发佣兵,man]\b[up,13,6]ZZZZ……呼噜噜……",
            "\t[贾斯汀,hero]\b[up,hero]好像已经彻底睡着了，而原本坐在他对面的人并没有买单的样子。"
        ]
    },
    # 客房通道 (原 10,8 变为 3,8)
    "3,8": {
        "trigger": "action",
        "enable": True,
        "data": [
            "\t[贾斯汀,hero]\b[up,hero]那边是通往酒馆二楼客房的走廊，目前不需要住宿。"
        ]
    }
}

mt9_data = {
    "floorId": "MT9",
    "title": "厄泽城·瑞格沃酒馆",
    "name": "瑞格沃酒馆",
    "width": w20,
    "height": h20,
    "canFlyTo": False,
    "canUseQuickShop": True,
    "cannotViewMap": False,
    "defaultGround": "ground",
    "images": [
        {"name": "map020_bg.png", "canvas": "bg", "x": 0, "y": 0}
    ],
    "ratio": 1,
    "upFloor": [5, 14],
    "downFloor": [5, 14],
    "firstArrive": [{"type": "tip", "text": "进入【厄泽城·瑞格沃酒馆】"}],
    "eachArrive": [],
    "parallelDo": "",
    "events": mt9_events,
    "changeFloor": {
        "5,15": {"floorId": "MT6", "loc": [58, 68], "direction": "down"}
    },
    "beforeBattle": {},
    "afterBattle": {},
    "afterGetItem": {},
    "afterOpenDoor": {},
    "cannotMove": {},
    "map": map20
}

with open(os.path.join(MOTA_DIR, 'project', 'floors', 'MT9.js'), 'w', encoding='utf-8') as f:
    f.write('main.floors.MT9 =\n')
    json.dump(mt9_data, f, ensure_ascii=False, indent=4)
print("  [+] MT9.js 写入完成！")

# -------------------------------------------------------------
# 4. 构建 MT10.js (公会右侧回廊 Map048 - 裁切后 23x15)
# -------------------------------------------------------------
print("\n[4/7] 构建 MT10.js (公会右侧回廊)...")
# 原坐标 x=8 变为 x=1 (8-7)
map48[8][1] = 0 # 入口落脚点
# 门1 (13-7=6, 6)
map48[6][6] = 17
# 门2 (18-7=11, 6)
map48[6][11] = 17
# 门3 (23-7=16, 6)
map48[6][16] = 17

mt10_events = {
    # 返回公会大厅 MT7 (23, 29)
    "1,8": {
        "trigger": "action",
        "enable": True,
        "data": [
            {"type": "playSound", "name": "door.mp3"},
            {"type": "changeFloor", "floorId": "MT7", "loc": [23, 29], "direction": "down"}
        ]
    },
    # 门1 (6, 6)
    "6,6": {
        "trigger": "action",
        "enable": True,
        "data": [
            {"type": "playSound", "name": "cursor.mp3"},
            "\t[贾斯汀,hero]\b[up,hero]……不是这间！"
        ]
    },
    # 门2 (11, 6)
    "11,6": {
        "trigger": "action",
        "enable": True,
        "data": [
            {"type": "playSound", "name": "cursor.mp3"},
            "\t[贾斯汀,hero]\b[up,hero]……也不是这间！"
        ]
    },
    # 门3 破门而入 (16, 6)
    "16,6": {
        "trigger": "action",
        "enable": True,
        "data": [
            {"type": "playSound", "name": "door.mp3"},
            "\t[回廊深处]\b[up,16,6]里面传来了少女的低吟和男人粗重的喘息声。",
            "\t[贾斯汀,hero]\b[up,hero]…………",
            "\t[贾斯汀,hero]\b[up,hero]……………………",
            "\t[贾斯汀,hero]\b[up,hero]………………………………！",
            "\t[格瑞迪,man]\b[up,16,6]咦？！你这家伙，不是死了吗！为什么会出现在这里？！",
            "\t[格瑞迪,man]\b[up,16,6]你，你杀了门外他们两个？！",
            "\t[格瑞迪,man]\b[up,16,6]呃……啊啊啊啊！",
            {"type": "playSound", "name": "attack.mp3"},
            {"type": "tip", "text": "怒火中烧的贾斯汀一剑斩杀了格瑞迪，踹开了房门！"},
            {"type": "setFlag", "name": "killed_gredy", "value": True},
            {"type": "changeFloor", "floorId": "MT11", "loc": [8, 11], "direction": "up"}
        ]
    },
    # 守卫 1 (原 12,7 变为 5,7)
    "5,7": {
        "trigger": "action",
        "enable": True,
        "data": [
            {"type": "playSound", "name": "cursor.mp3"},
            "\t[巡逻佣兵,man]\b[up,5,7]这里是公会高层的专属休息区，别乱晃悠！"
        ]
    },
    # 守卫 2 (原 12,9 变为 5,9)
    "5,9": {
        "trigger": "action",
        "enable": True,
        "data": [
            {"type": "playSound", "name": "cursor.mp3"},
            "\t[巡逻佣兵,man]\b[up,5,9]刚才好像看见格瑞迪少爷往最里面的房间去了……"
        ]
    }
}

mt10_data = {
    "floorId": "MT10",
    "title": "厄泽城·公会右侧回廊",
    "name": "公会右侧回廊",
    "width": w48,
    "height": h48,
    "canFlyTo": False,
    "canUseQuickShop": True,
    "cannotViewMap": False,
    "defaultGround": "ground",
    "images": [
        {"name": "map048_bg.png", "canvas": "bg", "x": 0, "y": 0}
    ],
    "ratio": 1,
    "upFloor": [1, 8],
    "downFloor": [1, 8],
    "firstArrive": [{"type": "tip", "text": "进入【厄泽城·公会右侧回廊】"}],
    "eachArrive": [],
    "parallelDo": "",
    "events": mt10_events,
    "changeFloor": {
        "1,8": {"floorId": "MT7", "loc": [23, 29], "direction": "down"},
        "16,6": {"floorId": "MT11", "loc": [8, 11], "direction": "up"}
    },
    "beforeBattle": {},
    "afterBattle": {},
    "afterGetItem": {},
    "afterOpenDoor": {},
    "cannotMove": {},
    "map": map48
}

with open(os.path.join(MOTA_DIR, 'project', 'floors', 'MT10.js'), 'w', encoding='utf-8') as f:
    f.write('main.floors.MT10 =\n')
    json.dump(mt10_data, f, ensure_ascii=False, indent=4)
print("  [+] MT10.js 写入完成！")

# -------------------------------------------------------------
# 5. 构建 MT11.js (法芙娜寓所 Map058 - 裁切后 15x15)
# -------------------------------------------------------------
print("\n[5/7] 构建 MT11.js (法芙娜寓所)...")
# 原坐标 x=13 变为 x=8 (13-5); y=11, y=12
map58[11][8] = 0 # 入口落脚点
map58[12][8] = 0 # 出门点

fafna_story = [
    {"type": "playSound", "name": "cursor.mp3"},
    "\t[贾斯汀,hero]\b[up,hero]…………",
    "\t[法芙娜,woman]\b[up,7,6]…………",
    "\t[贾斯汀,hero]\b[up,hero]为什么要这么做。",
    "\t[法芙娜,woman]\b[up,7,6]他们说你死了。死在了遗迹里。",
    "\t[贾斯汀,hero]\b[up,hero]那又如何。",
    "\t[法芙娜,woman]\b[up,7,6]我，我总得为未来……做出点什么。",
    "\t[贾斯汀,hero]\b[up,hero]那为什么偏偏是他！",
    "\t[法芙娜,woman]\b[up,7,6]……他有钱。他有很多很多钱。有他在，城里没有人敢欺负我。",
    "\t[贾斯汀,hero]\b[up,hero]…………法芙娜，告诉我，告诉我你不是自愿的！",
    "\t[贾斯汀,hero]\b[up,hero]快告诉我你是被他逼迫的！！",
    "\t[法芙娜,woman]\b[up,7,6]…………是又怎么样？！",
    "\t[法芙娜,woman]\b[up,7,6]实话告诉你，早在半年之前，我们就已经好上了！这次也不过是把你支出去了而已！",
    "\t[贾斯汀,hero]\b[up,hero]不，为什么……",
    "\t[法芙娜,woman]\b[up,7,6]我一个女孩子，想在这世上生存容易吗！不过是出卖一下自己的身体，那又怎么样？！",
    "\t[法芙娜,woman]\b[up,7,6]看清楚你自己吧！你只是个穷小子，一穷二白的穷小子！你难道想让我陪你一辈子吃糠咽菜吗？！",
    "\t[贾斯汀,hero]\b[up,hero]不，法芙娜，不要再说了……",
    "\t[法芙娜,woman]\b[up,7,6]我梦想中要的大房子，奢侈的生活，就凭你能够带给我吗？",
    "\t[法芙娜,woman]\b[up,7,6]格瑞迪他则不同，他是贵族，他的家里有王牌佣兵级别的供奉，他更是当今厄泽城第一强者佣兵公会会长马格罗斯的亲外甥！",
    "\t[法芙娜,woman]\b[up,7,6]那可是一位尊贵无比的职业者，职业者啊！这些，你能比吗？！",
    "\t[贾斯汀,hero]\b[up,hero]…………",
    "\t[贾斯汀,hero]\b[up,hero]……他没办法再带给你这些了。",
    "\t[法芙娜,woman]\b[up,7,6]什么意思？",
    "\t[贾斯汀,hero]\b[up,hero]……我杀了他。",
    "\t[法芙娜,woman]\b[up,7,6]啊？！你，你竟然……你竟然杀了他！",
    "\t[贾斯汀,hero]\b[up,hero]听我说，法芙娜，你想要的金币，和舒适的生活，我都能给你！我现在已经是一名辉煌佣兵了，就算是职业者我也不是没有对抗的能力，这些东西很快就会有的，相信我……",
    "\t[法芙娜,woman]\b[up,7,6]你在做什么白日梦！天呐，你竟然杀了格瑞迪！我要去告诉会长！！",
    "\t[贾斯汀,hero]\b[up,hero]不！不要……！",
    {"type": "playSound", "name": "attack.mp3"},
    "\t[法芙娜,woman]\b[up,7,6]…………诶？",
    "\t[贾斯汀,hero]\b[up,hero]……………………",
    {"type": "tip", "text": "失控的剑锋穿透了法芙娜的胸膛。曾经海誓山盟的恋人，倒在了血泊中。"},
    {"type": "setFlag", "name": "ch1_ended", "value": True},
    "\t[系统提示]第一章【寂静之森与厄泽城】主线剧情全部达成！\n\n贾斯汀在公会与全城的通缉追杀下，连夜逃离厄泽城，登上开往【普利斯特王都】的远洋商船……"
]

mt11_events = {
    # 房门 (8, 12) 出门回到回廊 (落脚点 MT10 [16, 7])
    "8,12": {
        "trigger": "action",
        "enable": True,
        "data": [
            {"type": "playSound", "name": "door.mp3"},
            {"type": "changeFloor", "floorId": "MT10", "loc": [16, 7], "direction": "down"}
        ]
    },
    # 法芙娜 (原 12,6 变为 7,6)
    "7,6": {
        "trigger": "action",
        "enable": True,
        "data": [
            {
                "type": "if",
                "condition": "core.hasFlag('ch1_ended')",
                "true": [
                    "\t[法芙娜]倒在血泊中的法芙娜已经失去了呼吸，一切都无法挽回了……"
                ],
                "false": fafna_story
            }
        ]
    }
}

mt11_data = {
    "floorId": "MT11",
    "title": "厄泽城·法芙娜寓所",
    "name": "法芙娜寓所",
    "width": w58,
    "height": h58,
    "canFlyTo": False,
    "canUseQuickShop": True,
    "cannotViewMap": False,
    "defaultGround": "ground",
    "images": [
        {"name": "map058_bg.png", "canvas": "bg", "x": 0, "y": 0}
    ],
    "ratio": 1,
    "upFloor": [8, 11],
    "downFloor": [8, 11],
    "firstArrive": [{"type": "tip", "text": "进入【厄泽城·法芙娜寓所】"}],
    "eachArrive": [],
    "parallelDo": "",
    "events": mt11_events,
    "changeFloor": {
        "8,12": {"floorId": "MT10", "loc": [16, 7], "direction": "down"}
    },
    "beforeBattle": {},
    "afterBattle": {},
    "afterGetItem": {},
    "afterOpenDoor": {},
    "cannotMove": {},
    "map": map58
}

with open(os.path.join(MOTA_DIR, 'project', 'floors', 'MT11.js'), 'w', encoding='utf-8') as f:
    f.write('main.floors.MT11 =\n')
    json.dump(mt11_data, f, ensure_ascii=False, indent=4)
print("  [+] MT11.js 写入完成！")

# -------------------------------------------------------------
# 6. 更新 MT6.js (打通装备店 68,16 与酒馆 58,67)
# -------------------------------------------------------------
print("\n[6/7] 更新 MT6.js 与 MT7.js 出入口网络拓扑...")
mt6_path = os.path.join(MOTA_DIR, 'project', 'floors', 'MT6.js')
with open(mt6_path, 'r', encoding='utf-8') as f:
    mt6_text = f.read()

# 替换 68,16 (进入 MT8 落脚点 [5, 15])
new_68_16 = '''        "68,16": {
            "trigger": "action",
            "enable": true,
            "data": [
                {
                    "type": "playSound",
                    "name": "door.mp3"
                },
                {
                    "type": "changeFloor",
                    "floorId": "MT8",
                    "loc": [5, 15],
                    "direction": "up"
                }
            ]
        },'''

mt6_text = re.sub(
    r'"68,16":\s*\{\s*"trigger":\s*"action",[\s\S]*?"data":\s*\[[\s\S]*?\]\s*\},',
    new_68_16,
    mt6_text
)

# 替换 58,67 (进入 MT9 落脚点 [5, 14])
new_58_67 = '''        "58,67": {
            "trigger": "action",
            "enable": true,
            "data": [
                {
                    "type": "playSound",
                    "name": "door.mp3"
                },
                {
                    "type": "changeFloor",
                    "floorId": "MT9",
                    "loc": [5, 14],
                    "direction": "up"
                }
            ]
        },'''

mt6_text = re.sub(
    r'"58,67":\s*\{\s*"trigger":\s*"action",[\s\S]*?"data":\s*\[[\s\S]*?\]\s*\},',
    new_58_67,
    mt6_text
)

with open(mt6_path, 'w', encoding='utf-8') as f:
    f.write(mt6_text)
print("  [+] MT6.js 装备店与酒馆双向大门打通！")

# 更新 MT7.js (打通 23,30 到 MT10 回廊 [1, 8]，并更新 22,30 守卫)
mt7_path = os.path.join(MOTA_DIR, 'project', 'floors', 'MT7.js')
with open(mt7_path, 'r', encoding='utf-8') as f:
    mt7_text = f.read()

new_23_30 = '''        "23,30": {
            "trigger": "action",
            "enable": true,
            "data": [
                {
                    "type": "playSound",
                    "name": "door.mp3"
                },
                {
                    "type": "changeFloor",
                    "floorId": "MT10",
                    "loc": [1, 8],
                    "direction": "right"
                }
            ]
        },'''

mt7_text = re.sub(
    r'"23,30":\s*\{\s*"trigger":\s*"action",[\s\S]*?"data":\s*\[[\s\S]*?\]\s*\},',
    new_23_30,
    mt7_text
)

new_22_30 = '''        "22,30": {
            "trigger": "action",
            "enable": true,
            "data": [
                {
                    "type": "if",
                    "condition": "core.hasFlag('fafna_quest_done')",
                    "true": [
                        "\\t[重装佣兵,man]\\b[up,22,30]……原来是贾斯汀兄弟！既然执事大人准许，回廊里面请！"
                    ],
                    "false": [
                        "\\t[重装佣兵,man]\\b[up,22,30]这里闲人免进！后面的回廊通向公会重地与接待员寝居，没有许可不得入内！"
                    ]
                }
            ]
        },'''

mt7_text = re.sub(
    r'"22,30":\s*\{\s*"trigger":\s*"action",[\s\S]*?"data":\s*\[[\s\S]*?\]\s*\},',
    new_22_30,
    mt7_text
)

with open(mt7_path, 'w', encoding='utf-8') as f:
    f.write(mt7_text)
print("  [+] MT7.js 通往回廊的传送门打通！")

# -------------------------------------------------------------
# 7. 更新 data.js, items.js, plugins.js
# -------------------------------------------------------------
print("\n[7/7] 更新 project/data.js 注册全量新楼层与资源...")
data_path = os.path.join(MOTA_DIR, 'project', 'data.js')
with open(data_path, 'r', encoding='utf-8') as f:
    data_text = f.read()

# 注册 floorIds
for fl in ['MT8', 'MT9', 'MT10', 'MT11']:
    if f'"{fl}"' not in data_text:
        data_text = data_text.replace('"MT7"', f'"MT7",\n            "{fl}"')
        print(f"  [+] data.js 注册楼层: {fl}")

# 注册 images
for img in ['map018_bg.png', 'map020_bg.png', 'map048_bg.png', 'map058_bg.png', '轻骑护手.png', '骷髅盾.png']:
    if f'"{img}"' not in data_text:
        data_text = data_text.replace('"map019_bg.png",', f'"map019_bg.png",\n            "{img}",')
        print(f"  [+] data.js 注册图片: {img}")

with open(data_path, 'w', encoding='utf-8') as f:
    f.write(data_text)

# 注册 items.js 装备
items_path = os.path.join(MOTA_DIR, 'project', 'items.js')
with open(items_path, 'r', encoding='utf-8') as f:
    items_text = f.read()

new_equips = '''	"lightGauntlets": {
		"cls": "equips",
		"name": "轻骑护手",
		"text": "轻装骑兵配发的精钢护手。\\n攻击速度+15，敏捷+15。",
		"equip": {
			"type": 4,
			"value": {
				"atk": 5,
				"def": 2
			},
			"ybfh": {
				"atkSpeed": 15
			}
		}
	},
	"skullShield": {
		"cls": "equips",
		"name": "骷髅盾",
		"text": "镶嵌魔物颅骨的坚实重盾。\\n防御力+12，自带10%物理减伤。",
		"equip": {
			"type": 2,
			"value": {
				"def": 12
			},
			"ybfh": {
				"damageReduction": 0.1
			}
		}
	},
'''

if '"lightGauntlets"' not in items_text:
    items_text = items_text.replace('"mercenarySword": {', new_equips + '\t"mercenarySword": {')
    with open(items_path, 'w', encoding='utf-8') as f:
        f.write(items_text)
    print("  [+] items.js 成功注册【轻骑护手】与【骷髅盾】！")

# 注册 plugins.js 图标映射
plugins_path = os.path.join(MOTA_DIR, 'project', 'plugins.js')
with open(plugins_path, 'r', encoding='utf-8') as f:
    plugins_text = f.read()

new_icons = """			'lightGauntlets': '轻骑护手.png',
			'skullShield': '骷髅盾.png',
			'mercenarySword': '佣兵短剑.png',"""

if "'lightGauntlets'" not in plugins_text:
    plugins_text = plugins_text.replace("'mercenarySword': '佣兵短剑.png',", new_icons)
    with open(plugins_path, 'w', encoding='utf-8') as f:
        f.write(plugins_text)
    print("  [+] plugins.js 成功注册装备图标渲染映射！")

print("\n🎉 厄泽城全系室内场景与生活区 (MT8~MT11) 黄金居中总装完毕！")
