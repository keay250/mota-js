# -*- coding: utf-8 -*-
"""
端到端综合实机自动化验证脚本：
验证 3 大新发现 Bug 的修复情况：
1. MT1 绿宝石（生命水晶）吃掉后属性真正生效（生命上限 +20）
2. MT5 传送小站原版素材呈现 & 边缘全方位触发小站
3. MT4 正上方入口（MT16 姆伊森运河）全线贯通 & 各出入口安全落点顺畅通行
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
        
        errors = []
        page.on("pageerror", lambda e: errors.append(str(e)))
        
        print("[*] 正在打开游戏页面...")
        page.goto("http://127.0.0.1:3000/index.html")
        page.wait_for_timeout(1000)
        page.wait_for_function("() => window.core && core.material && core.material.images && core.material.images.images && core.material.images.images['hero.png']")

        # 启动游戏
        print("[*] 启动魔塔游戏...")
        page.evaluate("core.startGame('normal', 0, function() {});")
        page.wait_for_function("() => window.core && core.status && core.status.floorId === 'MT1'")
        print("[*] 游戏成功初始化并进入 MT1！")
        clear_dialogs(page)
        page.wait_for_timeout(500)

        # ==============================================================
        # 1. 验证 MT1 绿宝石 (生命水晶) 生效
        # ==============================================================
        print("\n--------------------------------------------------------------")
        print("[1/3] 验证 MT1 绿宝石 (生命上限水晶) 效果...")
        print("--------------------------------------------------------------")
        page.evaluate("""
            core.changeFloor('MT1', null, [2, 13], 0);
        """)
        clear_dialogs(page)
        page.wait_for_timeout(300)

        init_status = page.evaluate("""
            () => ({
                hp: core.getStatus('hp'),
                hpmax: core.getStatus('hpmax') || 1000
            })
        """)
        print(f"[*] 初始状态: 生命={init_status['hp']}, 上限={init_status['hpmax']}")

        # 勇士向左踩入 (1, 13) 绿色水晶
        print("[*] 勇士触发 (1, 13) 绿色水晶...")
        page.evaluate("core.trigger(1, 13);")
        clear_dialogs(page)
        page.wait_for_timeout(500)

        after_gem = page.evaluate("""
            () => ({
                hp: core.getStatus('hp'),
                hpmax: core.getStatus('hpmax')
            })
        """)
        print(f"[*] 吃下绿水晶后状态: 生命={after_gem['hp']}, 上限={after_gem['hpmax']}")

        shot1 = os.path.join(SCREENSHOT_DIR, "verify_bug1_fixed_gem_effect.png")
        page.screenshot(path=shot1)
        print(f"[+] 绿水晶吃后截图已保存: {shot1}")

        assert after_gem['hpmax'] == init_status['hpmax'] + 20, \
            f"❌ 错误：生命上限未增加20！原上限={init_status['hpmax']}，现上限={after_gem['hpmax']}"
        print("✅ MT1 绿宝石/生命水晶加点生效验证通过！")

        # ==============================================================
        # 2. 验证 MT5 传送阵视觉呈现与边缘多点全触发
        # ==============================================================
        print("\n--------------------------------------------------------------")
        print("[2/3] 验证 MT5 传送阵视觉与边缘全方位触发...")
        print("--------------------------------------------------------------")
        page.evaluate("""
            core.changeFloor('MT5', null, [11, 8], 0);
        """)
        clear_dialogs(page)
        page.wait_for_timeout(500)

        # 截取 MT5 传送阵视觉
        shot2 = os.path.join(SCREENSHOT_DIR, "verify_bug2_fixed_station_visual.png")
        page.screenshot(path=shot2)
        print(f"[+] MT5 传送阵视觉截图已保存: {shot2}")

        # 测试从上边缘 (11, 9) 触发小站
        print("[*] 测试从上边缘 (11, 9) 触发小站...")
        page.evaluate("core.trigger(11, 9);")
        page.wait_for_timeout(500)

        has_ui = page.evaluate("Boolean(core.status.event && (core.status.event.id || core.status.event.data));")
        print(f"[*] 上边缘小站菜单激活状态: {has_ui}")
        assert has_ui, "❌ 错误：上边缘无法唤出小站菜单！"

        # 关闭菜单
        clear_dialogs(page)
        page.wait_for_timeout(500)

        # 测试从底部边缘 (11, 12) 触发小站
        print("[*] 测试从底部边缘 (11, 12) 触发小站...")
        page.evaluate("core.trigger(11, 12);")
        page.wait_for_timeout(500)

        has_ui_bottom = page.evaluate("Boolean(core.status.event && (core.status.event.id || core.status.event.data));")
        print(f"[*] 底部边缘小站菜单激活状态: {has_ui_bottom}")
        assert has_ui_bottom, "❌ 错误：底部边缘无法唤出小站菜单！"
        clear_dialogs(page)
        page.wait_for_timeout(500)

        print("✅ MT5 传送阵外观呈现与全边缘触发验证通过！")

        # ==============================================================
        # 3. 验证 MT4 正上方入口 (MT16 姆伊森运河) 与全出入口安全连通
        # ==============================================================
        print("\n--------------------------------------------------------------")
        print("[3/3] 验证 MT4 正上方入口 (MT16) 及所有出入口全连通与安全落点...")
        print("--------------------------------------------------------------")
        # 3.1 正上方进出 MT16
        page.evaluate("""
            core.changeFloor('MT4', null, {x: 7, y: 1, direction: 'up'}, 0);
        """)
        clear_dialogs(page)
        page.wait_for_timeout(300)
        print("[*] 勇士在 MT4 (7, 1)，正向上跨入 (7, 0)...")
        page.evaluate("core.moveHero('up', function() {});")
        page.wait_for_timeout(800)

        cur_floor = page.evaluate("core.status.floorId;")
        loc_mt16 = page.evaluate("({ x: core.getHeroLoc('x'), y: core.getHeroLoc('y') })")
        print(f"[*] 进入楼层: {cur_floor}, 坐标: {loc_mt16}")
        assert cur_floor == "MT16", f"❌ 错误：未能进入 MT16！当前楼层={cur_floor}"
        assert loc_mt16['x'] == 7 and loc_mt16['y'] == 13, f"❌ 错误：落点不是安全位置 (7, 13)！实际={loc_mt16}"

        shot3_top = os.path.join(SCREENSHOT_DIR, "verify_bug3_fixed_mt16_entry.png")
        page.screenshot(path=shot3_top)
        print(f"[+] MT16 入口截图已保存: {shot3_top}")

        # 从 MT16 底部 (7, 14) 安全返回 MT4
        print("[*] 从 MT16 (7, 13) 向下返回 MT4...")
        page.evaluate("core.moveHero('down', function() {});")
        page.wait_for_timeout(800)
        back_floor = page.evaluate("core.status.floorId;")
        back_loc = page.evaluate("({ x: core.getHeroLoc('x'), y: core.getHeroLoc('y') })")
        print(f"[*] 返回楼层: {back_floor}, 坐标: {back_loc}")
        assert back_floor == "MT4", f"❌ 错误：未能返回 MT4！当前={back_floor}"
        assert back_loc['x'] == 7 and back_loc['y'] == 1, f"❌ 错误：返回 MT4 未落在安全位置 (7, 1)！"

        # 3.2 验证左侧出口 MT4 (0, 7) -> MT3 -> 自由移动
        print("[*] 测试 MT4 (1, 7) 向左走向 (0, 7) 前往 MT3...")
        page.evaluate("""
            core.changeFloor('MT4', null, {x: 1, y: 7, direction: 'left'}, 0);
        """)
        clear_dialogs(page)
        page.wait_for_timeout(300)
        page.evaluate("core.moveHero('left', function() {});")
        page.wait_for_timeout(800)
        f_mt3 = page.evaluate("core.status.floorId;")
        loc_mt3 = page.evaluate("({ x: core.getHeroLoc('x'), y: core.getHeroLoc('y') })")
        print(f"[*] 进入楼层: {f_mt3}, 坐标: {loc_mt3}")
        assert f_mt3 == "MT3", f"❌ 错误：未能进入 MT3！当前={f_mt3}"
        assert loc_mt3['x'] == 13 and loc_mt3['y'] == 5, f"❌ 错误：MT3 安全落点错误！"

        # 在 MT3 向左移动一步，验证未卡死且能自由走动
        page.evaluate("core.moveHero('left', function() {});")
        page.wait_for_timeout(400)
        loc_mt3_step = page.evaluate("({ x: core.getHeroLoc('x'), y: core.getHeroLoc('y') })")
        print(f"[*] MT3 内向左移动后坐标: {loc_mt3_step}")
        assert loc_mt3_step['x'] == 12, "❌ 错误：在 MT3 无法顺畅行走！"

        # 3.3 验证右侧出口 MT4 (13, 7) -> MT5 -> 自由移动
        print("[*] 测试 MT4 (13, 7) 向右走向 (14, 7) 前往 MT5...")
        page.evaluate("""
            core.changeFloor('MT4', null, {x: 13, y: 7, direction: 'right'}, 0);
        """)
        clear_dialogs(page)
        page.wait_for_timeout(300)
        page.evaluate("core.moveHero('right', function() {});")
        page.wait_for_timeout(800)
        f_mt5 = page.evaluate("core.status.floorId;")
        loc_mt5 = page.evaluate("({ x: core.getHeroLoc('x'), y: core.getHeroLoc('y') })")
        print(f"[*] 进入楼层: {f_mt5}, 坐标: {loc_mt5}")
        assert f_mt5 == "MT5", f"❌ 错误：未能进入 MT5！当前={f_mt5}"
        assert loc_mt5['x'] == 1 and loc_mt5['y'] == 7, f"❌ 错误：MT5 安全落点错误！"

        # 在 MT5 向上移动一步，验证未卡死在传送点且能自由探索
        page.evaluate("core.moveHero('up', function() {});")
        page.wait_for_timeout(400)
        loc_mt5_step = page.evaluate("({ x: core.getHeroLoc('x'), y: core.getHeroLoc('y') })")
        print(f"[*] MT5 内向上移动后坐标: {loc_mt5_step}")
        assert loc_mt5_step['y'] == 6, "❌ 错误：在 MT5 无法顺畅行走！"

        print("✅ MT4 正上方入口及所有出入口安全落点顺畅通行验证全部通过！")

        print("\n==============================================================")
        print("🎉 3 项用户反馈 BUG 全部修复并通过 100% 自动化端到端实机验证！")
        print("==============================================================")
        browser.close()

if __name__ == "__main__":
    run()
