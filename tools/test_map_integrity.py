# -*- coding: utf-8 -*-
"""
test_map_integrity.py
全量地图碰撞、边界严密性与传送拓扑自动化断言工具 (Map Integrity Audit Test)
断言标准：
1. 楼层完整性：所有 registered floorId 均存在且 JSON 解析合法
2. 传送目标合法性：所有 changeFloor 目标楼层存在，且落点在地图有效宽高内
3. 传送落点安全性 (无阻挡/无踩怪)：所有传送落点 tile 必须为 0 (平地)，绝对不能是 17 (空气墙/实心墙) 或 >=200 (怪物贴脸)
4. 传送无对撞死循环：落点坐标自身不能是反向立即传送点
5. 边界防穿模与无黑边虚空漫游 (BFS 可达区边界闭环)：从全图任意合法入口/落脚点做 BFS 洪水填充，断言所有可到达坐标中，位于地图边缘 (x=0, x=w-1, y=0, y=h-1) 的格子必须具有对应的出口定义，杜绝半身穿模或走出屏幕
"""

import os, sys, json, re
from collections import deque

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MOTA_DIR = os.path.join(BASE_DIR, '_analysis', '_ybfh-mota')
FLOORS_DIR = os.path.join(MOTA_DIR, 'project', 'floors')
DATA_PATH = os.path.join(MOTA_DIR, 'project', 'data.js')

def audit_all_maps(verbose=True):
    errors = []
    passed = 0
    total = 0

    def assert_test(cond, name, fail_detail=""):
        nonlocal passed, total
        total += 1
        if cond:
            passed += 1
            if verbose:
                print(f"  ✅ [PASS] {name}")
        else:
            errors.append(f"{name}: {fail_detail}")
            print(f"  ❌ [FAIL] {name} -> {fail_detail}")

    if verbose:
        print("==================================================================================")
        print("🔍 开始执行全量地图碰撞、边界严密性与传送拓扑审计 (Map Integrity Audit)...")
        print("==================================================================================")

    # 1. 读取 data.js
    with open(DATA_PATH, 'r', encoding='utf-8') as f:
        text = f.read()
    m = re.search(r'\"floorIds\":\s*(\[[^\]]+\])', text)
    assert_test(bool(m), "读取 project/data.js 注册楼层列表")
    if not m:
        return 1, ["无法解析 data.js floorIds"]
    floor_ids = json.loads(m.group(1))

    # 2. 读取各楼层
    floors = {}
    for fid in floor_ids:
        fpath = os.path.join(FLOORS_DIR, f'{fid}.js')
        assert_test(os.path.exists(fpath), f"楼层文件存在校验: {fid}.js")
        if not os.path.exists(fpath):
            continue
        with open(fpath, 'r', encoding='utf-8') as f:
            content = f.read()
        m_floor = re.search(r'main\.floors\.\w+\s*=\s*(\{[\s\S]*\})', content)
        assert_test(bool(m_floor), f"楼层结构合规校验: {fid}.js")
        if m_floor:
            floors[fid] = json.loads(m_floor.group(1))

    # 3. 收集所有入口与落脚点
    entry_points = {fid: set() for fid in floor_ids}
    entry_points['MT1'].add((2, 13)) # 初始主角出生点

    # 4. 拓扑与落点安全校验
    for from_id, fl in floors.items():
        w, h = fl.get('width', 15), fl.get('height', 15)
        cf = fl.get('changeFloor', {})
        events = fl.get('events', {})

        # 检查 changeFloor
        for coord_str, target in cf.items():
            from_x, from_y = map(int, coord_str.split(','))
            to_id = target.get('floorId')
            loc = target.get('loc')
            assert_test(to_id in floors, f"[{from_id}] 传送点 ({from_x},{from_y}) -> 目标楼层 [{to_id}] 存在性")
            if to_id not in floors:
                continue
            t_floor = floors[to_id]
            t_w, t_h = t_floor.get('width', 15), t_floor.get('height', 15)
            to_x, to_y = loc if loc else [0, 0]
            assert_test(0 <= to_x < t_w and 0 <= to_y < t_h,
                        f"[{from_id}] -> [{to_id}] 落点坐标界限校验 ({to_x},{to_y})")

            # 落点 tile 必须为 0 (平地)，不能是 17 (墙) 或 >=200 (怪)
            t_grid = t_floor.get('map', [])
            tile_val = t_grid[to_y][to_x] if (0 <= to_y < len(t_grid) and 0 <= to_x < len(t_grid[0])) else -1
            is_safe = (tile_val == 0)
            fail_desc = f"落点阻挡！tile={tile_val}" + (" (实心/空气墙)" if tile_val == 17 else (" (怪物贴脸)" if tile_val >= 200 else ""))
            assert_test(is_safe, f"[{from_id}] -> [{to_id}] 落点 ({to_x},{to_y}) 净空安全性 (无空气墙/无踩怪)", fail_desc)

            # 落点不能直接对撞反向立即传送
            t_cf = t_floor.get('changeFloor', {})
            key = f"{to_x},{to_y}"
            assert_test(key not in t_cf, f"[{from_id}] -> [{to_id}] 落点 ({to_x},{to_y}) 防对撞死循环校验")

            entry_points[to_id].add((to_x, to_y))

        # 检查 events 中的 changeFloor
        for coord_str, evt in events.items():
            evt_str = json.dumps(evt)
            for match in re.finditer(r'\"type\":\s*\"changeFloor\",\s*\"floorId\":\s*\"(\w+)\",\s*\"loc\":\s*\[(\d+),\s*(\d+)\]', evt_str):
                to_id, to_x, to_y = match.group(1), int(match.group(2)), int(match.group(3))
                if to_id in floors:
                    t_floor = floors[to_id]
                    t_grid = t_floor.get('map', [])
                    tile_val = t_grid[to_y][to_x] if (0 <= to_y < len(t_grid) and 0 <= to_x < len(t_grid[0])) else -1
                    is_safe = (tile_val == 0)
                    assert_test(is_safe, f"事件传送 [{from_id}] -> [{to_id}] 落点 ({to_x},{to_y}) 净空安全性")
                    entry_points[to_id].add((to_x, to_y))

    # 5. BFS 边界防穿模与黑边虚空隔离审计
    for fid in floor_ids:
        if fid not in floors:
            continue
        fl = floors[fid]
        w, h = fl.get('width', 15), fl.get('height', 15)
        grid = fl.get('map', [])
        cf = fl.get('changeFloor', {})
        events = fl.get('events', {})

        boundary_exits = set()
        for coord_str in cf.keys():
            x, y = map(int, coord_str.split(','))
            boundary_exits.add((x, y))
        for coord_str, evt in events.items():
            if 'changeFloor' in json.dumps(evt):
                x, y = map(int, coord_str.split(','))
                boundary_exits.add((x, y))

        # 从所有合法落脚点做 BFS
        reachable = set()
        queue = deque()
        for sx, sy in entry_points[fid]:
            if 0 <= sx < w and 0 <= sy < h and grid[sy][sx] == 0:
                reachable.add((sx, sy))
                queue.append((sx, sy))

        while queue:
            cx, cy = queue.popleft()
            for dx, dy in [(0, 1), (0, -1), (1, 0), (-1, 0)]:
                nx, ny = cx + dx, cy + dy
                if 0 <= nx < w and 0 <= ny < h:
                    if (nx, ny) not in reachable and grid[ny][nx] == 0:
                        reachable.add((nx, ny))
                        queue.append((nx, ny))

        # 断言：可达区域内，边界上的坐标必须全是出口定义，不得出现裸露开孔
        boundary_leaks = []
        for rx, ry in reachable:
            if rx == 0 or rx == w - 1 or ry == 0 or ry == h - 1:
                if (rx, ry) not in boundary_exits:
                    boundary_leaks.append((rx, ry))

        leak_desc = f"发现 {len(boundary_leaks)} 处裸露边界坐标: {boundary_leaks[:5]}" if boundary_leaks else ""
        assert_test(len(boundary_leaks) == 0, f"[{fid}] ({fl.get('title')}) 边界阻挡严密性 (0穿模/0黑边溢出)", leak_desc)

    if verbose:
        print("----------------------------------------------------------------------------------")
        print(f"📊 地图完整性与边界审计总结: 共 {total} 项检查, 通过: {passed}, 失败: {len(errors)}")
        print("==================================================================================")

    return (0 if len(errors) == 0 else 1), errors

if __name__ == "__main__":
    code, errs = audit_all_maps(verbose=True)
    sys.exit(code)
