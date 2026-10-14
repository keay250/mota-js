# -*- coding: utf-8 -*-
"""
全楼层怪物贴图与数值只读交叉审计脚本
对比范围：MT1, MT2, MT3, MT4, MT5, MT6
严格对比：原版 Enemies.rxdata 与 MapXXX.rxdata 事件 ⇄ mota-js project/floors 与 enemys.js
"""

import os, json
from rubymarshal.reader import load

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RX_DATA_DIR = os.path.join(os.path.dirname(BASE_DIR), 'Data')
MOTA_DIR = os.path.join(BASE_DIR, '_analysis', '_ybfh-mota', 'project')

with open(os.path.join(RX_DATA_DIR, 'Enemies.rxdata'), 'rb') as f:
    rx_enemies = load(f)

with open(os.path.join(MOTA_DIR, 'enemys.js'), 'r', encoding='utf-8') as f:
    txt = f.read()
s = txt.find('{')
e = txt.rfind('}') + 1
mota_enemys = json.loads(txt[s:e])

with open(os.path.join(MOTA_DIR, 'maps.js'), 'r', encoding='utf-8') as f:
    maps_txt = f.read()
s = maps_txt.find('{')
e = maps_txt.rfind('}') + 1
maps_data = json.loads(maps_txt[s:e])

tile_to_enemy = {}
for tid, val in maps_data.items():
    if isinstance(val, dict) and val.get('cls') == 'enemys':
        tile_to_enemy[int(tid)] = val.get('id')

floor_map_pairs = [
    ('MT1', 7, '寂静之森 1F (Map007)'),
    ('MT2', 9, '寂静之森 2F (Map009)'),
    ('MT3', 10, '寂静之森外围 3F (Map010)'),
    ('MT4', 12, '寂静之森外围 4F (Map012)'),
    ('MT5', 13, '寂静之森外围 5F·厄泽城外 (Map013)'),
    ('MT6', 17, '厄泽城主城区 1:1 (Map017)')
]

for fid, mid, desc in floor_map_pairs:
    print('\n' + '='*85)
    print(f'【楼层审计】{fid} ⇄ 原版 {desc}')
    print('='*85)
    
    mota_floor_file = os.path.join(MOTA_DIR, 'floors', f'{fid}.js')
    if not os.path.exists(mota_floor_file):
        print(f'  [!] 文件不存在: {mota_floor_file}')
        continue
    with open(mota_floor_file, 'r', encoding='utf-8') as f:
        f_txt = f.read()
    s = f_txt.find('{')
    e = f_txt.rfind('}') + 1
    mota_fobj = json.loads(f_txt[s:e])
    maze = mota_fobj.get('map', [])
    
    rx_map_file = os.path.join(RX_DATA_DIR, f'Map{mid:03d}.rxdata')
    if not os.path.exists(rx_map_file):
        print(f'  [!] 原版地图不存在: {rx_map_file}')
        continue
    with open(rx_map_file, 'rb') as f:
        rx_mobj = load(f)
    events = rx_mobj.attributes.get('@events', {})
    
    x_offset = 5 if mid in [7, 9, 10, 12, 13] else 0
    y_offset = 0
        
    rx_loc_events = {}
    for eid, ev in events.items():
        ex = ev.attributes.get('@x', 0)
        ey = ev.attributes.get('@y', 0)
        rx_loc_events[(ex, ey)] = ev
        
    mota_enemies_found = []
    h = len(maze)
    w = len(maze[0]) if h > 0 else 0
    for y in range(h):
        for x in range(w):
            tid = maze[y][x]
            if tid in tile_to_enemy:
                mota_en_id = tile_to_enemy[tid]
                mota_en_info = mota_enemys.get(mota_en_id, {})
                
                orig_x = x + x_offset
                orig_y = y + y_offset
                rx_ev = rx_loc_events.get((orig_x, orig_y))
                
                rx_ev_name = '无对应事件'
                rx_char = 'None'
                rx_hue = 0
                rx_en_id = None
                rx_en_name = 'None'
                rx_stats = {}
                
                if rx_ev:
                    n = rx_ev.attributes.get('@name', '')
                    if isinstance(n, bytes): n = n.decode('utf-8', 'ignore')
                    rx_ev_name = n
                    p0 = rx_ev.attributes.get('@pages', [])[0]
                    g = p0.attributes.get('@graphic')
                    c = g.attributes.get('@character_name', '')
                    if isinstance(c, bytes): c = c.decode('utf-8', 'ignore')
                    rx_char = c
                    rx_hue = g.attributes.get('@character_hue', 0)
                    
                    if rx_ev_name.startswith('怪物'):
                        try:
                            rx_en_id = int(rx_ev_name.replace('怪物', '').split(':')[0])
                            r_attrs = rx_enemies[rx_en_id].attributes
                            rn = r_attrs.get('@name', '')
                            if isinstance(rn, bytes): rn = rn.decode('utf-8', 'ignore')
                            rx_en_name = rn
                            rx_stats = {
                                'hp': r_attrs.get('@maxhp', 0),
                                'atk': r_attrs.get('@atk', 0),
                                'def': r_attrs.get('@pdef', 0),
                                'exp': r_attrs.get('@exp', 0),
                                'gold': r_attrs.get('@gold', 0)
                            }
                        except Exception as ex:
                            pass
                            
                mota_enemies_found.append({
                    'loc': (x, y),
                    'orig_loc': (orig_x, orig_y),
                    'tile': tid,
                    'mota_id': mota_en_id,
                    'mota_name': mota_en_info.get('name', 'Unknown'),
                    'mota_stats': {
                        'hp': mota_en_info.get('hp', 0),
                        'atk': mota_en_info.get('atk', 0),
                        'def': mota_en_info.get('def', 0),
                        'exp': mota_en_info.get('exp', 0),
                        'gold': mota_en_info.get('money', 0)
                    },
                    'rx_ev_name': rx_ev_name,
                    'rx_en_id': rx_en_id,
                    'rx_en_name': rx_en_name,
                    'rx_stats': rx_stats,
                    'rx_char': rx_char,
                    'rx_hue': rx_hue
                })
                
    print(f'  本层怪物总数: {len(mota_enemies_found)} 只')
    
    by_type = {}
    for item in mota_enemies_found:
        key = (item['tile'], item['mota_id'], item['rx_en_id'])
        if key not in by_type:
            by_type[key] = []
        by_type[key].append(item)
        
    for key, items in by_type.items():
        it = items[0]
        cnt = len(items)
        locs_list = ["(%d,%d)" % (p["loc"][0], p["loc"][1]) for p in items[:3]]
        locs = ', '.join(locs_list) + ('...' if cnt > 3 else '')
        
        stat_match = True
        diff_str = ''
        if it['rx_stats']:
            ms = it['mota_stats']
            rs = it['rx_stats']
            diffs = []
            if ms['hp'] != rs['hp']: diffs.append(f'HP:{ms["hp"]}!={rs["hp"]}')
            if ms['atk'] != rs['atk']: diffs.append(f'ATK:{ms["atk"]}!={rs["atk"]}')
            if ms['def'] != rs['def']: diffs.append(f'DEF:{ms["def"]}!={rs["def"]}')
            if ms['exp'] != rs['exp']: diffs.append(f'EXP:{ms["exp"]}!={rs["exp"]}')
            if ms['gold'] != rs['gold']: diffs.append(f'GOLD:{ms["gold"]}!={rs["gold"]}')
            if diffs:
                stat_match = False
                diff_str = ' ⚠️ 【数值不符】: ' + ', '.join(diffs)
            else:
                diff_str = ' ✅ 【数值完全一致】'
        else:
            diff_str = ' ❓ 原版非怪物事件'
            
        print(f'  • [x{cnt:02d}只] mota图块 {it["tile"]} ({it["mota_id"]}: \"{it["mota_name"]}\") ⇄ 原版 ID {it["rx_en_id"]}: \"{it["rx_en_name"]}\"')
        print(f'      原版行走图: {it["rx_char"]}(hue={it["rx_hue"]}) | 坐标示例: {locs}')
        print(f'      数值对比: mota={it["mota_stats"]} vs 原版={it["rx_stats"]}{diff_str}')
