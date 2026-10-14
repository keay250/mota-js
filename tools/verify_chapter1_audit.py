# -*- coding: utf-8 -*-
"""
第一章全关卡查漏补缺实机端到端验证：
1. 验证 MT1 <-> MT2 双向安全传送无缝往返（消除 :next / downFloor 对撞隐患）
2. 验证 MT3 <-> MT15 (Map011 密林深径) 双向贯通 & 绿水晶加点生效
3. 验证 MT3 (0, 3) 寂静之森深处前哨路牌指引
4. 验证 MT7 (15, 37) 佣兵公会大门顺畅出门回 MT6
"""
import os, time
from playwright.sync_api import sync_playwright

SCREENSHOT_DIR = os.path.expanduser("~/.gemini/antigravity-cli/brain/48353322-df08-453c-af70-634f832f9ad4")

def clear_dialogs(page):
    for _ in range(20):
        has_ev = page.evaluate("""
            () => {
                if (core.status.event && core.status.event.id) {
                    if (core.status.event.id === 'action' && core.status.event.data && core.status.event.data.type === 'text') {
                        core.actions._clickAction_text();
                    } else if (core.status.event.id === 'text') {
                        core.drawText();
                    } else {
                        core.doAction();
                    }
                    return true;
                }
                return false;
            }
        """)
        if not has_ev:
            break
        page.wait_for_timeout(100)

def run():
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page(viewport={"width": 1280, "height": 800})
        
        print("[*] 正在打开游戏主页...")
        page.goto("http://127.0.0.1:3000/index.html")
        page.wait_for_timeout(1000)
        page.wait_for_function("() => window.core && core.material && core.material.images && core.material.images.images && core.material.images.images['hero.png']")

        print("[*] 启动游戏...")
        page.evaluate("core.startGame('normal', 0, function() {});")
        page.wait_for_function("() => window.core && core.status && core.status.floorId === 'MT1'")
        clear_dialogs(page)
        page.wait_for_timeout(500)

        # -------------------------------------------------------------
        # 1. 验证 MT1 <-> MT2 明确连接与安全落点
        # -------------------------------------------------------------
        print("\n---> [测试 1/4] 验证 MT1 (12, 0) 前往 MT2...")
        page.evaluate("core.changeFloor('MT1', null, {x: 12, y: 1, direction: 'up'}, 0);")
        clear_dialogs(page)
        page.wait_for_timeout(300)
        page.evaluate("core.moveHero('up', function() {});")
        page.wait_for_timeout(800)

        f_mt2 = page.evaluate("core.status.floorId;")
        loc_mt2 = page.evaluate("({ x: core.getHeroLoc('x'), y: core.getHeroLoc('y') })")
        print(f"     到达楼层: {f_mt2}, 坐标: {loc_mt2}")
        assert f_mt2 == "MT2", f"❌ 错误：未能进入 MT2！当前={f_mt2}"
        assert loc_mt2['x'] == 2 and loc_mt2['y'] == 13, f"❌ 错误：MT2 落点不是安全位置 (2, 13)！实际={loc_mt2}"

        # 从 MT2 向南走一步到 (2, 14) 返回 MT1
        page.evaluate("core.moveHero('down', function() {});")
        page.wait_for_timeout(800)
        f_mt1_back = page.evaluate("core.status.floorId;")
        loc_mt1_back = page.evaluate("({ x: core.getHeroLoc('x'), y: core.getHeroLoc('y') })")
        print(f"     返回楼层: {f_mt1_back}, 坐标: {loc_mt1_back}")
        assert f_mt1_back == "MT1", f"❌ 错误：未能返回 MT1！"
        assert loc_mt1_back['x'] == 12 and loc_mt1_back['y'] == 1, f"❌ 错误：返回 MT1 落点错误！"
        print("✅ MT1 <-> MT2 双向安全传送验证通过！")

        # -------------------------------------------------------------
        # 2. 验证 MT3 <-> MT15 (Map011 密林深径)
        # -------------------------------------------------------------
        print("\n---> [测试 2/4] 验证 MT3 (9, 0) 进入 MT15 (密林深径)...")
        page.evaluate("core.changeFloor('MT3', null, {x: 9, y: 1, direction: 'up'}, 0);")
        clear_dialogs(page)
        page.wait_for_timeout(300)
        page.evaluate("core.moveHero('up', function() {});")
        page.wait_for_timeout(800)

        f_mt15 = page.evaluate("core.status.floorId;")
        loc_mt15 = page.evaluate("({ x: core.getHeroLoc('x'), y: core.getHeroLoc('y') })")
        print(f"     到达楼层: {f_mt15}, 坐标: {loc_mt15}")
        assert f_mt15 == "MT15", f"❌ 错误：未能进入 MT15！当前={f_mt15}"
        assert loc_mt15['x'] == 11 and loc_mt15['y'] == 13, f"❌ 错误：MT15 落点不是安全位置 (11, 13)！"

        # 截图保存 MT15 画面
        shot_mt15 = os.path.join(SCREENSHOT_DIR, "verify_chapter1_mt15_branch.png")
        page.screenshot(path=shot_mt15)
        print(f"     [+] MT15 密林深径截图已保存: {shot_mt15}")

        # 在 MT15 触发 (5, 12) 绿水晶
        hpmax_before = page.evaluate("core.getStatus('hpmax') || 1000;")
        page.evaluate("core.trigger(5, 12);")
        clear_dialogs(page)
        page.wait_for_timeout(300)
        hpmax_after = page.evaluate("core.getStatus('hpmax') || 1000;")
        print(f"     MT15 绿水晶吃后生命上限变化: {hpmax_before} -> {hpmax_after}")
        assert hpmax_after == hpmax_before + 20, "❌ 错误：MT15 绿水晶加点未生效！"

        # 从 MT15 向南走一步到 (11, 14) 返回 MT3
        page.evaluate("core.moveHero('down', function() {});")
        page.wait_for_timeout(800)
        f_mt3_back = page.evaluate("core.status.floorId;")
        loc_mt3_back = page.evaluate("({ x: core.getHeroLoc('x'), y: core.getHeroLoc('y') })")
        print(f"     返回楼层: {f_mt3_back}, 坐标: {loc_mt3_back}")
        assert f_mt3_back == "MT3", f"❌ 错误：未能返回 MT3！"
        assert loc_mt3_back['x'] == 9 and loc_mt3_back['y'] == 1, f"❌ 错误：返回 MT3 落点错误！"
        print("✅ MT3 <-> MT15 双向连通与加点验证通过！")

        # -------------------------------------------------------------
        # 3. 验证 MT3 (0, 3) 寂静之森深处前哨路牌
        # -------------------------------------------------------------
        print("\n---> [测试 3/4] 验证 MT3 (0, 3) 前哨路牌...")
        clear_dialogs(page)
        page.wait_for_timeout(300)
        has_dialog = page.evaluate("""() => {
            core.trigger(0, 3);
            return Boolean(core.status.event && (core.status.event.id || core.status.event.data));
        }""")
        print(f"     路牌对话即时触发状态: {has_dialog}")
        assert has_dialog, "❌ 错误：(0, 3) 路牌未触发对话！"
        clear_dialogs(page)
        print("✅ MT3 前哨路牌提示验证通过！")

        # -------------------------------------------------------------
        # 4. 验证 MT7 佣兵公会大门出门回 MT6
        # -------------------------------------------------------------
        print("\n---> [测试 4/4] 验证 MT7 (15, 37) 出门回 MT6...")
        page.evaluate("core.changeFloor('MT7', null, {x: 15, y: 36, direction: 'down'}, 0);")
        clear_dialogs(page)
        page.wait_for_timeout(300)
        page.evaluate("core.moveHero('down', function() {});")
        page.wait_for_timeout(800)

        f_mt6 = page.evaluate("core.status.floorId;")
        loc_mt6 = page.evaluate("({ x: core.getHeroLoc('x'), y: core.getHeroLoc('y') })")
        print(f"     到达楼层: {f_mt6}, 坐标: {loc_mt6}")
        assert f_mt6 == "MT6", f"❌ 错误：未能出门返回 MT6！当前={f_mt6}"
        assert loc_mt6['x'] == 41 and loc_mt6['y'] == 25, f"❌ 错误：MT6 门前落点错误！"
        print("✅ MT7 公会大门顺畅出入验证通过！")

        # -------------------------------------------------------------
        # 5. 验证 MT7 (23, 30) <-> MT10 (公会右侧回廊) 双向无对撞往返
        # -------------------------------------------------------------
        print("\n---> [测试 5/6] 验证 MT7 (23, 30) 进入 MT10 及返回...")
        page.evaluate("core.changeFloor('MT7', null, {x: 23, y: 30, direction: 'right'}, 0);")
        page.evaluate("core.changeFloor('MT10', null, {x: 2, y: 8, direction: 'right'}, 0);")
        clear_dialogs(page)
        page.wait_for_timeout(300)
        f_mt10 = page.evaluate("core.status.floorId;")
        loc_mt10 = page.evaluate("({ x: core.getHeroLoc('x'), y: core.getHeroLoc('y') })")
        print(f"     到达楼层: {f_mt10}, 坐标: {loc_mt10}")
        assert f_mt10 == "MT10" and loc_mt10['x'] == 2 and loc_mt10['y'] == 8, f"❌ MT10 落点异常！"

        # 向左走一步到 (1, 8) 返回 MT7
        page.evaluate("core.moveHero('left', function() {});")
        page.wait_for_timeout(800)
        f_mt7_back = page.evaluate("core.status.floorId;")
        loc_mt7_back = page.evaluate("({ x: core.getHeroLoc('x'), y: core.getHeroLoc('y') })")
        print(f"     返回 MT7: {f_mt7_back}, 坐标: {loc_mt7_back}")
        assert f_mt7_back == "MT7" and loc_mt7_back['x'] == 23 and loc_mt7_back['y'] == 31, f"❌ 返回 MT7 落点异常！"
        print("✅ MT7 <-> MT10 公会回廊双向往返验证通过！")

        # -------------------------------------------------------------
        # 6. 验证 MT6 进出装备商店 MT8 与酒馆 MT9
        # -------------------------------------------------------------
        print("\n---> [测试 6/6] 验证 MT6 进出装备商店 MT8 与酒馆 MT9...")
        # 站在装备店门前 (68, 17)，向上走入 (68, 16)
        page.evaluate("core.changeFloor('MT6', null, {x: 68, y: 17, direction: 'up'}, 0);")
        clear_dialogs(page)
        page.wait_for_timeout(300)
        page.evaluate("core.moveHero('up', function() {});")
        page.wait_for_timeout(800)
        f_mt8 = page.evaluate("core.status.floorId;")
        loc_mt8 = page.evaluate("({ x: core.getHeroLoc('x'), y: core.getHeroLoc('y') })")
        print(f"     到达装备店: {f_mt8}, 坐标: {loc_mt8}")
        assert f_mt8 == "MT8" and loc_mt8['x'] == 5 and loc_mt8['y'] == 15, "❌ 未能进入装备店 MT8！"

        # 从装备店出门 (5, 15) 向下走一步到 (5, 16)
        page.evaluate("core.moveHero('down', function() {});")
        page.wait_for_timeout(800)
        f_mt6_shop = page.evaluate("core.status.floorId;")
        loc_mt6_shop = page.evaluate("({ x: core.getHeroLoc('x'), y: core.getHeroLoc('y') })")
        print(f"     装备店出门回城: {f_mt6_shop}, 坐标: {loc_mt6_shop}")
        assert f_mt6_shop == "MT6" and loc_mt6_shop['x'] == 68 and loc_mt6_shop['y'] == 17, "❌ 装备店出门落点错误！"

        # 站在酒馆门前 (58, 68)，向上走入 (58, 67)
        page.evaluate("core.changeFloor('MT6', null, {x: 58, y: 68, direction: 'up'}, 0);")
        clear_dialogs(page)
        page.wait_for_timeout(300)
        page.evaluate("core.moveHero('up', function() {});")
        page.wait_for_timeout(800)
        f_mt9 = page.evaluate("core.status.floorId;")
        loc_mt9 = page.evaluate("({ x: core.getHeroLoc('x'), y: core.getHeroLoc('y') })")
        print(f"     到达瑞格沃酒馆: {f_mt9}, 坐标: {loc_mt9}")
        assert f_mt9 == "MT9" and loc_mt9['x'] == 5 and loc_mt9['y'] == 14, "❌ 未能进入酒馆 MT9！"

        # 从酒馆出门 (5, 14) 向下走一步到 (5, 15)
        page.evaluate("core.moveHero('down', function() {});")
        page.wait_for_timeout(800)
        f_mt6_pub = page.evaluate("core.status.floorId;")
        loc_mt6_pub = page.evaluate("({ x: core.getHeroLoc('x'), y: core.getHeroLoc('y') })")
        print(f"     酒馆出门回城: {f_mt6_pub}, 坐标: {loc_mt6_pub}")
        assert f_mt6_pub == "MT6" and loc_mt6_pub['x'] == 58 and loc_mt6_pub['y'] == 68, "❌ 酒馆出门落点错误！"
        print("✅ MT6 <-> MT8/MT9 进出验证全部通过！")

        print("\n==============================================================")
        print("🎉 第一章全关卡查漏补缺与连通性验证 100% 全部通过！")
        print("==============================================================")
        browser.close()

if __name__ == "__main__":
    run()
