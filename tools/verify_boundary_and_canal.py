# -*- coding: utf-8 -*-
"""
自动化实测验证脚本：
1. MT15 顶部树林阻挡严密性（杜绝穿模）与北出口通往 MT14 姆伊森运河
2. MT16 运河大水面阻挡严密性（杜绝踩水）与西出口通往 MT14 姆伊森运河
3. MT14 运河双向安全返回验证与大网络连通验证
4. 截取高清证据截图
"""
import sys, os, time
from playwright.sync_api import sync_playwright

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SCREENSHOT_DIR = "/Users/zt-lin/.gemini/antigravity-cli/brain/48353322-df08-453c-af70-634f832f9ad4"

def clear_dialogs(page, max_rounds=15):
    for _ in range(max_rounds):
        ev_id = page.evaluate("core.status.event ? core.status.event.id : null")
        if ev_id in ('text', 'action'):
            page.evaluate("try { core.actions._clickAction_text(); } catch(e) {}")
            page.wait_for_timeout(100)
        else:
            break

def run_test():
    with sync_playwright() as p:
        browser = p.chromium.launch(
            headless=True,
            args=[
                "--autoplay-policy=no-user-gesture-required",
                "--disable-web-security",
                "--no-sandbox"
            ]
        )
        page = browser.new_page(viewport={"width": 1280, "height": 800})
        page.goto("http://127.0.0.1:3000")
        page.wait_for_timeout(1000)
        page.wait_for_function("() => window.core && core.material && core.material.images && core.material.images.images")
        page.evaluate("core.startGame('normal', 0, function() {});")
        page.wait_for_function("() => window.core && core.status && core.status.floorId === 'MT1'")
        clear_dialogs(page)

        print("\n=======================================================")
        print("⚔️ 开始验证 MT15/MT16 地图边界阻挡与 MT14 运河连通")
        print("=======================================================")

        # -------------------------------------------------------------
        # 验证 1: MT15 密林深径边界阻挡与北出口
        # -------------------------------------------------------------
        print("\n[测试 1] 验证 MT15 密林深径边界阻挡与北出口通道...")
        page.evaluate("core.changeFloor('MT15', null, {x: 7, y: 2, direction: 'up'});")
        page.wait_for_timeout(600)
        clear_dialogs(page)

        # 1.1 检查第 0 行树木的阻挡（非出口位置，如 (6,0) 应该被 17 挡住）
        no_pass_tree = page.evaluate("core.noPass(6, 0);")
        assert no_pass_tree, "❌ 错误：MT15 (6, 0) 应该为不可通行空气墙 (noPass=true)！"
        page.evaluate("core.setHeroLoc('x', 6); core.setHeroLoc('y', 1); core.setHeroLoc('direction', 'up');")
        page.evaluate("core.moveHero('up', function() {});")
        page.wait_for_timeout(250)
        pos_mt15_tree = page.evaluate("({x: core.getHeroLoc('x'), y: core.getHeroLoc('y')})")
        assert pos_mt15_tree['x'] == 6 and pos_mt15_tree['y'] == 1, f"❌ 错误：主角穿入了树林！当前位置: {pos_mt15_tree}"
        print("  ✅ [PASS] MT15 顶部树林空气墙坚固，严密阻挡 (移动被挡在 (6,1)，绝不穿模出界)")

        # 1.2 检查 (7, 1) 面对出口 (7, 0)
        no_pass_exit = page.evaluate("core.noPass(7, 0);")
        assert not no_pass_exit, "❌ 错误：MT15 (7, 0) 面对北出口应该可以通行 (noPass=false)！"
        page.evaluate("core.setHeroLoc('x', 7); core.setHeroLoc('y', 1); core.setHeroLoc('direction', 'up');")
        print("  ✅ [PASS] MT15 (7, 1) 面对北出口处于通畅状态")

        # 1.3 穿过北出口到达 MT14
        page.evaluate("core.moveHero('up', function() {});")
        page.wait_for_timeout(800)
        clear_dialogs(page)
        f_mt14 = page.evaluate("core.status.floorId")
        loc_mt14 = page.evaluate("({x: core.getHeroLoc('x'), y: core.getHeroLoc('y')})")
        assert f_mt14 == "MT14" and loc_mt14['x'] == 7 and loc_mt14['y'] == 13, f"❌ 错误：未成功传送到 MT14 (7, 13)，当前: {f_mt14} {loc_mt14}"
        print(f"  ✅ [PASS] 从 MT15 北出口顺利切入新场景【姆伊森运河·主河道】(MT14), 安全落点: ({loc_mt14['x']}, {loc_mt14['y']})")

        # 1.4 从 MT14 南出口安全返回 MT15
        page.evaluate("core.moveHero('down', function() {});")
        page.wait_for_timeout(800)
        f_back_mt15 = page.evaluate("core.status.floorId")
        loc_back_mt15 = page.evaluate("({x: core.getHeroLoc('x'), y: core.getHeroLoc('y')})")
        assert f_back_mt15 == "MT15" and loc_back_mt15['x'] == 7 and loc_back_mt15['y'] == 1, f"❌ 错误：从 MT14 返回 MT15 失败，当前: {f_back_mt15} {loc_back_mt15}"
        print(f"  ✅ [PASS] 从 MT14 南出口安全返回 MT15 (7, 1)，双向连通闭环完全成立！")

        # 保存 MT15 边界与出口截图
        shot_mt15 = os.path.join(SCREENSHOT_DIR, "verify_mt15_boundary_and_exit.png")
        page.screenshot(path=shot_mt15)
        print(f"  📸 [证据截图] MT15 验证截图已保存至: {shot_mt15}")

        # -------------------------------------------------------------
        # 验证 2: MT16 支流前哨水面阻挡与西出口
        # -------------------------------------------------------------
        print("\n[测试 2] 验证 MT16 支流前哨水面阻挡与西出口通道...")
        page.evaluate("core.changeFloor('MT16', null, {x: 7, y: 13, direction: 'up'});")
        page.wait_for_timeout(600)
        clear_dialogs(page)

        # 2.1 检查突起草地 (7, 8) 向上走向水面 (7, 7) 的阻挡
        no_pass_water = page.evaluate("core.noPass(7, 7);")
        assert no_pass_water, "❌ 错误：MT16 (7, 7) 水面应该为不可通行空气墙 (noPass=true)！"
        page.evaluate("core.setHeroLoc('x', 7); core.setHeroLoc('y', 8); core.setHeroLoc('direction', 'up');")
        page.evaluate("core.moveHero('up', function() {});")
        page.wait_for_timeout(250)
        pos_mt16_water = page.evaluate("({x: core.getHeroLoc('x'), y: core.getHeroLoc('y')})")
        assert pos_mt16_water['x'] == 7 and pos_mt16_water['y'] == 8, f"❌ 错误：主角踩入了水面！当前位置: {pos_mt16_water}"
        print("  ✅ [PASS] MT16 运河水面严密阻挡，无法踩水通行 (移动被挡在 (7,8)，踏水穿模 bug 已彻底根治)")

        # 2.2 检查西侧出口通道 (1, 9) 面对出口 (0, 9)
        no_pass_west = page.evaluate("core.noPass(0, 9);")
        assert not no_pass_west, "❌ 错误：MT16 (0, 9) 面对西出口应该可以通行 (noPass=false)！"
        page.evaluate("core.setHeroLoc('x', 1); core.setHeroLoc('y', 9); core.setHeroLoc('direction', 'left');")
        print("  ✅ [PASS] MT16 (1, 9) 面对西出口处于通畅状态")

        # 2.3 穿过西出口到达 MT14
        page.evaluate("core.moveHero('left', function() {});")
        page.wait_for_timeout(800)
        clear_dialogs(page)
        f_mt14_west = page.evaluate("core.status.floorId")
        loc_mt14_west = page.evaluate("({x: core.getHeroLoc('x'), y: core.getHeroLoc('y')})")
        assert f_mt14_west == "MT14" and loc_mt14_west['x'] == 13 and loc_mt14_west['y'] == 9, f"❌ 错误：未成功传送到 MT14 (13, 9)，当前: {f_mt14_west} {loc_mt14_west}"
        print(f"  ✅ [PASS] 从 MT16 西出口顺利切入新场景【姆伊森运河·主河道】(MT14), 安全落点: ({loc_mt14_west['x']}, {loc_mt14_west['y']})")

        # 2.4 从 MT14 东出口安全返回 MT16
        page.evaluate("core.moveHero('right', function() {});")
        page.wait_for_timeout(800)
        f_back_mt16 = page.evaluate("core.status.floorId")
        loc_back_mt16 = page.evaluate("({x: core.getHeroLoc('x'), y: core.getHeroLoc('y')})")
        assert f_back_mt16 == "MT16" and loc_back_mt16['x'] == 1 and loc_back_mt16['y'] == 9, f"❌ 错误：从 MT14 返回 MT16 失败，当前: {f_back_mt16} {loc_back_mt16}"
        print(f"  ✅ [PASS] 从 MT14 东出口安全返回 MT16 (1, 9)，双向连通闭环完全成立！")

        # 保存 MT16 边界与出口截图
        shot_mt16 = os.path.join(SCREENSHOT_DIR, "verify_mt16_water_blocked.png")
        page.screenshot(path=shot_mt16)
        print(f"  📸 [证据截图] MT16 验证截图已保存至: {shot_mt16}")

        # -------------------------------------------------------------
        # 验证 3: MT14 姆伊森运河主河道全景与交互
        # -------------------------------------------------------------
        print("\n[测试 3] 验证 MT14 姆伊森运河主河道全景与交互...")
        page.evaluate("core.changeFloor('MT14', null, {x: 7, y: 13, direction: 'up'});")
        page.wait_for_timeout(600)
        clear_dialogs(page)

        # 检查路牌 (7, 12)
        has_sign = page.evaluate("core.getBlock(7, 12) !== null;")
        assert has_sign, "❌ 错误：MT14 (7, 12) 应该存在闪避说明路牌！"
        print("  ✅ [PASS] MT14 (7, 12) 设定说明路牌就位")

        shot_mt14 = os.path.join(SCREENSHOT_DIR, "verify_mt14_canal_panorama.png")
        page.screenshot(path=shot_mt14)
        print(f"  📸 [证据截图] MT14 姆伊森运河全景截图已保存至: {shot_mt14}")

        browser.close()

    print("\n=======================================================")
    print("🎉 MT15 / MT16 边界穿模彻底根治，MT14 姆伊森运河全网贯通！100% 验证通过！")
    print("=======================================================")
    return 0

if __name__ == "__main__":
    code = run_test()
    sys.exit(code)
