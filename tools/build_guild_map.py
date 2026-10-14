# -*- coding: utf-8 -*-
"""
1:1 完整复刻《永不复还》厄泽城佣兵公会 (Map019 - 26x40)
生成内容：
1. 832x1280 真实背景大图 map019_bg.png (48-Autotile + Tileset 73 + NPC 行走图精准合成)
2. 26x40 碰撞与空气墙阻挡矩阵 (严格解析 Tilesets.rxdata 通行度与 NPC 阻挡)
3. 注入全量 NPC 与主线剧情（法芙娜、公会柜台领取拉瓦尔队长遗产 50 金币与封印之球、佣兵闲聊）
4. 在 MT6.js 中打通公会大门 (41, 24) ⇄ MT7 (15, 36) 双向传送
5. 在 project/data.js 中注册 MT7 楼层
"""

import os, json, struct, re, time
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
# 1. 渲染 26x40 背景大图 (map019_bg.png)
# -------------------------------------------------------------
print("\n[1/5] 正在渲染 26x40 (832x1280) 佣兵公会全景背景大图...")
t0 = time.time()

with open(os.path.join(RX_DATA_DIR, 'Tilesets.rxdata'), 'rb') as f:
    tilesets = load(f)

t73 = tilesets[73]
t_name = t73.attributes.get('@tileset_name').decode('utf-8')
at_names = [n.decode('utf-8') if n else '' for n in t73.attributes.get('@autotile_names')]

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

with open(os.path.join(RX_DATA_DIR, 'Map019.rxdata'), 'rb') as f:
    m = load(f)

w = m.attributes.get('@width') or m.attributes.get(b'@width')
h = m.attributes.get('@height') or m.attributes.get(b'@height')
tbl_data = m.attributes.get('@data')._private_data
tbl = struct.unpack(f'<{w*h*3}h', tbl_data[20:])

full_img = Image.new('RGBA', (w * 32, h * 32), (0, 0, 0, 0))
for layer in range(3):
    layer_offset = layer * (w * h)
    for y in range(h):
        for x in range(w):
            tid = tbl[layer_offset + y * w + x]
            t = render_tile(tid)
            if t:
                full_img.paste(t, (x * 32, y * 32), t)

# 合成 NPC 行走图到背景
events = m.attributes.get('@events', {})
dir_row_map = {2: 0, 4: 1, 6: 2, 8: 3}

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
        
        # 底部贴合到格子底部
        px = ex * 32 + (32 - cw) // 2
        py = (ey + 1) * 32 - ch
        full_img.paste(sub, (px, py), sub)
        print(f"  + 合成 NPC: {cname} at ({ex}, {ey}), 尺寸 ({cw}x{ch})")

bg_dest = os.path.join(MOTA_DIR, 'project', 'images', 'map019_bg.png')
full_img.save(bg_dest)
print(f"[*] 佣兵公会背景图渲染完成 ({full_img.size})，用时 {time.time() - t0:.2f}s，文件: {bg_dest}")

# -------------------------------------------------------------
# 2. 计算 26x40 通行度与空气墙矩阵
# -------------------------------------------------------------
print("\n[2/5] 正在提取 26x40 地图通行度与空气墙矩阵...")
p_data = t73.attributes['@passages']._private_data
flags = struct.unpack(f'<{len(p_data)//2 - 10}h', p_data[20:])

map_arr = [[0 for _ in range(w)] for _ in range(h)]

for y in range(h):
    for x in range(w):
        is_blocked = False
        for layer in [2, 1, 0]:
            tid = tbl[layer * (w * h) + y * w + x]
            if tid == 0:
                continue
            flag = flags[tid] if tid < len(flags) else 0
            if (flag & 0x10) != 0: # 通行于下层之上
                continue
            if (flag & 0x0f) != 0: # 存在阻挡
                is_blocked = True
                break
            else:
                break
        if is_blocked:
            map_arr[y][x] = 17 # 空气墙

# 将有 NPC 的格子加上阻挡，防止穿模
for eid, ev in events.items():
    attrs = ev.attributes
    ex = attrs.get('@x')
    ey = attrs.get('@y')
    pages = attrs.get('@pages', [])
    if pages and pages[0].attributes.get('@graphic') and pages[0].attributes.get('@graphic').attributes.get('@character_name'):
        map_arr[ey][ex] = 17

# 确保出入口通畅
map_arr[36][15] = 0 # 入口着地点
map_arr[37][15] = 0 # 大门出口

print(f"[*] 碰撞矩阵计算完成！阻挡格数: {sum(row.count(17) for row in map_arr)} / {w*h}")

# -------------------------------------------------------------
# 3. 构建 MT7.js (佣兵公会楼层数据与主线交互)
# -------------------------------------------------------------
print("\n[3/5] 正在装配 MT7.js 佣兵公会全量事件与剧情链路...")

events_dict = {
    # 1. 大门出口 (15, 37) -> 回到厄泽城 MT6 (41, 25)
    "15,37": {
        "trigger": "action",
        "enable": True,
        "data": [
            {
                "type": "playSound",
                "name": "door.mp3"
            },
            {
                "type": "changeFloor",
                "floorId": "MT6",
                "loc": [41, 25],
                "direction": "down"
            }
        ]
    },

    # 2. 法芙娜核心剧情 (9, 30) - 触发点在 (10, 30) 和 (9, 31)
    "10,30": {
        "trigger": "action",
        "enable": True,
        "data": [
            {
                "type": "playSound",
                "name": "cursor.mp3"
            },
            {
                "type": "if",
                "condition": "core.hasFlag('fafna_quest_done')",
                "true": [
                    "\t[法芙娜,woman]\b[up,9,30]贾斯汀，寂静之森深处非常危险，路上一定要多加小心啊！",
                    "\t[法芙娜,woman]\b[up,9,30]如果遇到难以应付的魔兽，千万别逞强，及时撤退回来，知道了吗？",
                    "\t[贾斯汀,hero]\b[up,hero]放心吧法芙娜，我一定会平安回来的！"
                ],
                "false": [
                    {
                        "type": "if",
                        "condition": "core.hasFlag('got_captain_legacy')",
                        "true": [
                            "\t[法芙娜,woman]\b[up,9,30]贾斯汀，东西取回来了吗？",
                            "\t[贾斯汀,hero]\b[up,hero]没什么值钱的东西，就一个样式古怪的装饰品小球【封印之球】。",
                            "\t[法芙娜,woman]\b[up,9,30]不是装备或者魔法道具吗？",
                            "\t[贾斯汀,hero]\b[up,hero]装备上去没有任何属性加成，只是个单纯的装饰品罢了。",
                            "\t[法芙娜,woman]\b[up,9,30]哦……也是呢，拉瓦尔大叔以前倒也偶尔买一些古怪的饰品……",
                            "\t[法芙娜,woman]\b[up,9,30]对了贾斯汀，关于寂静之森遗迹的事情，你有什么想法没？",
                            "\t[贾斯汀,hero]\b[up,hero]那不是我力所能及的事情，告示上都说了至少要有特级佣兵的实力才能前去。",
                            "\t[法芙娜,woman]\b[up,9,30]哎呀不要这么死板嘛！前两天不是有不少中等实力的小队遇难在森林里了吗？那些大佣兵团看不上的遗落物资……",
                            "\t[贾斯汀,hero]\b[up,hero]……对呀！这或许是一个机会！大部队在前面清扫魔兽，森林深处反而可能安全不少！",
                            "\t[贾斯汀,hero]\b[up,hero]可是发死人财什么的，总感觉有些愧疚……",
                            "\t[法芙娜,woman]\b[up,9,30]贾斯汀，有钱不是为了铺张浪费，而是要用来帮助更多的人！想想拉瓦尔大叔！不管是重建佣兵小队，还是抚养像我们一样的孤儿，都需要金钱的……还有比如在城里买一处房屋作为居所……",
                            "\t[贾斯汀,hero]\b[up,hero]啥？买房屋干啥？",
                            "\t[法芙娜,woman]\b[up,9,30]…………笨蛋！人家什么都没说，你一定是听错了！",
                            "\t[贾斯汀,hero]\b[up,hero]话说，通往寂静之森深处的要道上有公会的严密封锁线，我该怎么过去呢？",
                            "\t[法芙娜,woman]\b[up,9,30]啊，那个好办！怎么说我也是公会的接待员，搞一把通行钥匙还是没问题的！",
                            {
                                "type": "playSound",
                                "name": "item.mp3"
                            },
                            {
                                "type": "tip",
                                "text": "获得了【公会封锁线钥匙】！"
                            },
                            {
                                "type": "setValue",
                                "name": "item:yellowKey",
                                "value": "item:yellowKey+2"
                            },
                            {
                                "type": "setValue",
                                "name": "flag:fafna_quest_done",
                                "value": True
                            },
                            "\t[法芙娜,woman]\b[up,9,30]喏，有了这个就能通过封锁线了。路上千万小心啊，有危险就及时收手吧！",
                            "\t[贾斯汀,hero]\b[up,hero]嗯！真是太感谢你了，法芙娜，我一定会保重的！"
                        ],
                        "false": [
                            "\t[法芙娜,woman]\b[up,9,30]贾斯汀！你平安回来了呀！赞美全能之神，真是太好了！",
                            "\t[法芙娜,woman]\b[up,9,30]你知道吗，我在公会里看到你们“挽歌”小队的受损队徽时，整个人都吓坏了呢……",
                            "\t[贾斯汀,hero]\b[up,hero]真的……只有我一个人回来了吗。",
                            "\t[法芙娜,woman]\b[up,9,30]……贾斯汀，很抱歉。其他人生还的可能性，恐怕……",
                            "\t[贾斯汀,hero]\b[up,hero]拉瓦尔队长他对我那么好，在我还是个孤儿的时候就收养了我，教会我信奉全能之神，可是他……",
                            "\t[法芙娜,woman]\b[up,9,30]拉瓦尔大叔是个真正的高尚之人。正因为这样，贾斯汀你才更要振作起来，对得起大叔的养育之恩呀！",
                            "\t[贾斯汀,hero]\b[up,hero]嗯……我明白的！我会努力让“挽歌”小队的名字留存下去，成为厄泽城最强大的佣兵小队，完成队长的遗愿！",
                            "\t[法芙娜,woman]\b[up,9,30]……那个，贾斯汀。根据公会规定，小队至少要有三名中级佣兵或一名高级佣兵才能维持注册……所以，“挽歌”小队目前已经被判定解散了……",
                            "\t[贾斯汀,hero]\b[up,hero]……我知道的，法芙娜。这只是一时的，以后我一定会亲手重新建立起新的挽歌小队！",
                            "\t[法芙娜,woman]\b[up,9,30]对了！你是小队唯一的幸存者，先前拉瓦尔队长在公会办理过寄存财产，理应由你继承！你快去上方柜台找【公会员工】(21, 8)办理领取吧！",
                            "\t[贾斯汀,hero]\b[up,hero]好的，我这就去柜台取遗物，一会儿见！",
                            {
                                "type": "setValue",
                                "name": "flag:talked_fafna",
                                "value": True
                            }
                        ]
                    }
                ]
            }
        ]
    },

    # 3. 公会办事柜台 (21, 8) - 领取拉瓦尔队长遗产
    "21,9": {
        "trigger": "action",
        "enable": True,
        "data": [
            {
                "type": "playSound",
                "name": "cursor.mp3"
            },
            {
                "type": "if",
                "condition": "core.hasFlag('got_captain_legacy')",
                "true": [
                    "\t[公会员工,man]\b[up,21,8]你还有事吗？没事不要打扰我办公，后面还有好多佣兵排队呢。"
                ],
                "false": [
                    {
                        "type": "if",
                        "condition": "core.hasFlag('talked_fafna')",
                        "true": [
                            "\t[公会员工,man]\b[up,21,8]挽歌小队，贾斯汀是吧？",
                            "\t[公会员工,man]\b[up,21,8]嗯，挽歌小队目前已经被记录为解散状态。不过你的名字登记在小队候补队长一栏，按条例确实有资格领取小队寄存的财产。",
                            "\t[贾斯汀,hero]\b[up,hero]等等……小队候补队长？拉瓦尔队长居然把我的名字写在了候补队长上……",
                            "\t[公会员工,man]\b[up,21,8]别发愣了。挽歌小队寄存物品如下：金币 50 枚，未知装饰品一件。队长可真够拮据的。你稍等，这就差人去取。",
                            {
                                "type": "playSound",
                                "name": "coin.mp3"
                            },
                            {
                                "type": "setValue",
                                "name": "status:money",
                                "value": "status:money+50"
                            },
                            {
                                "type": "tip",
                                "text": "获得了金币 +50 与队长遗物【封印之球】！"
                            },
                            {
                                "type": "setValue",
                                "name": "flag:got_captain_legacy",
                                "value": True
                            },
                            "\t[贾斯汀,hero]\b[up,hero]（拉瓦尔大叔才不是小气，小队赚来的赏金大多都用来接济贫困的孤儿了……）",
                            "\t[贾斯汀,hero]\b[up,hero]谢谢您，赞美伟大的全能之神。",
                            "\t[公会员工,man]\b[up,21,8]赞美伟大的全能之神。拿了东西就快走吧，顺便记得回去找法芙娜知会一声。"
                        ],
                        "false": [
                            "\t[公会员工,man]\b[up,21,8]新来的？这里是公会财产核算与抚恤领取专柜，请先去接待处核实小队身份再来排队！"
                        ]
                    }
                ]
            }
        ]
    },

    # 4. 青年佣兵与伙伴 (14, 28) & (14, 30)
    "15,28": {
        "trigger": "action",
        "enable": True,
        "data": [
            "\t[青年佣兵,man]\b[up,14,28]听说城主府已经贴出巨额悬赏了，谁要是能在寂静之森遗迹带回神殿核心，就能直接册封贵族骑士！",
            "\t[伙伴佣兵,man]\b[up,14,30]省省吧兄弟，那地方连初阶魔导兽都成群结队，没点真本事去也是白白送死。"
        ]
    },

    # 5. 执事 (20, 28)
    "20,29": {
        "trigger": "action",
        "enable": True,
        "data": [
            "\t[公会执事,man]\b[up,20,28]全能之神在上，愿逝去佣兵的灵魂得到永恒的安宁。"
        ]
    },

    # 6. 重装佣兵 (22, 30)
    "21,30": {
        "trigger": "action",
        "enable": True,
        "data": [
            "\t[重装佣兵,man]\b[up,22,30]身上的甲胄哪怕厚一寸，在面对嗜血魔兽时就能多撑一个回合！工欲善其事，必先利其器啊！"
        ]
    },

    # 7. 红发佣兵 (11, 9)
    "11,10": {
        "trigger": "action",
        "enable": True,
        "data": [
            "\t[红发佣兵,man]\b[up,11,9]闪开，没看到本大爷正和调酒师商量委托酬劳吗？小鬼一边去！"
        ]
    },

    # 8. 城主府守卫 (16, 7)
    "16,8": {
        "trigger": "action",
        "enable": True,
        "data": [
            "\t[城主府守卫,man]\b[up,16,7]城主府正在紧急调动驻军驻扎城外防线，严防森林深处的异动波及到厄泽城主城区！"
        ]
    }
}

mt7_data = {
    "floorId": "MT7",
    "title": "厄泽城·佣兵公会",
    "name": "佣兵公会",
    "width": w,
    "height": h,
    "canFlyTo": False,
    "canUseQuickShop": True,
    "cannotMoveInFacing": False,
    "upFloor": [15, 36],
    "downFloor": [15, 36],
    "images": [
        {
            "name": "map019_bg.png",
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
            "name": "door.mp3"
        },
        {
            "type": "tip",
            "text": "进入【厄泽城·佣兵公会大厅】"
        }
    ],
    "eachArrive": [],
    "parallelDo": "",
    "events": events_dict,
    "changeFloor": {},
    "beforeBattle": {},
    "afterBattle": {},
    "afterGetItem": {},
    "afterOpenDoor": {},
    "cannotMove": {},
    "map": map_arr
}

mt7_path = os.path.join(MOTA_DIR, 'project', 'floors', 'MT7.js')
with open(mt7_path, 'w', encoding='utf-8') as f:
    f.write('main.floors.MT7 =\n')
    json.dump(mt7_data, f, ensure_ascii=False, indent=4)

print(f"[*] MT7.js 编写完成！事件数量: {len(events_dict)}")

# -------------------------------------------------------------
# 4. 更新 MT6.js: 将 (41, 24) 改为进入 MT7 传送门
# -------------------------------------------------------------
print("\n[4/5] 正在更新 MT6.js 佣兵公会大门交互...")
mt6_path = os.path.join(MOTA_DIR, 'project', 'floors', 'MT6.js')
with open(mt6_path, 'r', encoding='utf-8') as f:
    mt6_text = f.read()

# 替换 41,24 占位事件为双向传送门
old_41_24 = '''        "41,24": {
            "trigger": "action",
            "enable": true,
            "data": [
                {
                    "type": "playSound",
                    "name": "door.mp3"
                },
                "\\t[佣兵公会]沉重的橡木大门半掩着，里面传来冒险者们喧闹的交谈声与接取委托的争辩声。",
                "\\t[公会接待员]年轻的佣兵，辛苦了！目前公会正在清点寂静之森战役的抚恤金与委托清单，稍后开放大厅进入！"
            ]
        },'''

new_41_24 = '''        "41,24": {
            "trigger": "action",
            "enable": true,
            "data": [
                {
                    "type": "playSound",
                    "name": "door.mp3"
                },
                {
                    "type": "changeFloor",
                    "floorId": "MT7",
                    "loc": [15, 36],
                    "direction": "up"
                }
            ]
        },'''

if old_41_24 in mt6_text:
    mt6_text = mt6_text.replace(old_41_24, new_41_24)
    with open(mt6_path, 'w', encoding='utf-8') as f:
        f.write(mt6_text)
    print("  [+] MT6 (41, 24) 成功升级为通往 MT7 的双向传送大门！")
else:
    print("  [!] 未匹配到旧 41,24，尝试正则安全替换...")
    mt6_text = re.sub(
        r'"41,24":\s*\{\s*"trigger":\s*"action",[\s\S]*?"data":\s*\[[\s\S]*?\]\s*\},',
        new_41_24,
        mt6_text
    )
    with open(mt6_path, 'w', encoding='utf-8') as f:
        f.write(mt6_text)
    print("  [+] MT6 (41, 24) 正则替换完成！")

# -------------------------------------------------------------
# 5. 更新 project/data.js: 注册 MT7 楼层
# -------------------------------------------------------------
print("\n[5/5] 正在检查 project/data.js 注册 MT7 楼层...")
data_path = os.path.join(MOTA_DIR, 'project', 'data.js')
with open(data_path, 'r', encoding='utf-8') as f:
    data_text = f.read()

if '"MT7"' not in data_text:
    data_text = data_text.replace('"MT6"', '"MT6",\n        "MT7"')
    with open(data_path, 'w', encoding='utf-8') as f:
        f.write(data_text)
    print("  [+] project/data.js 成功注册 MT7 楼层！")
else:
    print("  [*] MT7 已在 project/data.js 中注册。")

print("\n🎉 全部步骤执行完毕！佣兵公会室内地图与全量主线剧情已成功交付！")
