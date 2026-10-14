# -*- coding: utf-8 -*-
"""
自动化验证脚本：【厄泽城·中心广场 (MT6)】端到端实机验证与截图
"""

import os, time, sys
from playwright.sync_api import sync_playwright

ARTIFACT_DIR = "/Users/zt-lin/.gemini/antigravity-cli/brain/48353322-df08-453c-af70-634f832f9ad4"

def main():
    print("[*] 正在启动 Playwright Chromium 测试端...")
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        context = browser.new_context(viewport={"width": 1024, "height": 768})
        page = context.new_page()

        console_errors = []
        page.on("console", lambda msg: console_errors.append(msg.text) if msg.type == "error" else None)

        print("[*] 正在访问 http://127.0.0.1:3000 ...")
        page.goto("http://127.0.0.1:3000", wait_until="networkidle")
        time.sleep(2.0)

        # 1. 直接以 Easy 难度启动游戏
        print("[*] 正在启动游戏 (Easy)...")
        page.evaluate("() => { core.startGame('Easy'); }")
        time.sleep(1.5)

        # 消耗初始开局对白
        for _ in range(30):
            page.keyboard.press("Space")
            time.sleep(0.05)
        time.sleep(0.5)

        # 2. 传送至 MT6 (厄泽城·中心广场)
        print("[*] 正在直接传送进入【厄泽城·中心广场 (MT6)】...")
        page.evaluate("""() => {
            core.changeFloor('MT6', null, {x: 1, y: 7, direction: 'right'});
        }""")
        time.sleep(1.5)

        # 检查当前楼层
        curr_floor = page.evaluate("() => core.status.floorId")
        print(f"[*] 当前楼层: {curr_floor}")
        assert curr_floor == "MT6", f"Expected MT6, got {curr_floor}"

        # 截取格瑞迪剧情对话
        dialogue_path = os.path.join(ARTIFACT_DIR, "compact_eze_dialogue.png")
        page.screenshot(path=dialogue_path)
        print(f"[*] 格瑞迪剧情对话截图已保存: {dialogue_path}")

        # 3. 按空格消耗对话直至恢复行动
        print("[*] 推进对话...")
        for _ in range(12):
            page.keyboard.press("Space")
            time.sleep(0.2)
        time.sleep(0.5)

        # 4. 截取厄泽城中心广场全景实机图
        canvas_path = os.path.join(ARTIFACT_DIR, "compact_eze_canvas.png")
        page.screenshot(path=canvas_path)
        print(f"[*] 厄泽城全景高清截图已保存: {canvas_path}")

        # 5. 测试交互：走向告示牌 (7, 5)，主角站在 (7, 6) 向上交互
        print("[*] 测试走到 (7, 6) 调查告示牌...")
        page.evaluate("""() => {
            core.setHeroLoc('x', 7);
            core.setHeroLoc('y', 6);
            core.setHeroLoc('direction', 'up');
            core.drawHero();
        }""")
        time.sleep(0.5)
        page.keyboard.press("ArrowUp")
        time.sleep(0.5)

        board_active = page.evaluate("() => core.status.event.id != null")
        print(f"[*] 告示牌事件激活状态: {board_active}")
        assert board_active, "告示牌事件应正常触发！"
        page.keyboard.press("Space")
        time.sleep(0.3)

        # 6. 测试装备商店大门交互 (10, 4)，主角站在 (10, 5) 向上交互
        print("[*] 走向装备商店大门 (10, 4)...")
        page.evaluate("""() => {
            core.setHeroLoc('x', 10);
            core.setHeroLoc('y', 5);
            core.setHeroLoc('direction', 'up');
            core.drawHero();
        }""")
        time.sleep(0.5)
        page.keyboard.press("ArrowUp")
        time.sleep(0.5)

        shop_active = page.evaluate("() => core.status.event.id != null")
        print(f"[*] 装备商店大门事件激活状态: {shop_active}")
        assert shop_active, "装备商店大门事件应正常触发！"
        page.keyboard.press("Space")
        time.sleep(0.3)

        # 7. 测试瑞格沃酒馆大门交互 (10, 9)，主角站在 (10, 8) 向下交互
        print("[*] 走向酒馆大门 (10, 9)...")
        page.evaluate("""() => {
            core.setHeroLoc('x', 10);
            core.setHeroLoc('y', 8);
            core.setHeroLoc('direction', 'down');
            core.drawHero();
        }""")
        time.sleep(0.5)
        page.keyboard.press("ArrowDown")
        time.sleep(0.5)

        tavern_active = page.evaluate("() => core.status.event.id != null")
        print(f"[*] 酒馆大门事件激活状态: {tavern_active}")
        assert tavern_active, "酒馆大门事件应正常触发！"
        page.keyboard.press("Space")
        time.sleep(0.3)

        # 8. 测试西城门退回 MT5 (0, 7)
        print("[*] 测试西城门退回 MT5 (0, 7)...")
        page.evaluate("""() => {
            core.setHeroLoc('x', 1);
            core.setHeroLoc('y', 7);
            core.setHeroLoc('direction', 'left');
            core.drawHero();
        }""")
        time.sleep(0.5)
        page.keyboard.press("ArrowLeft")
        time.sleep(1.0)

        back_floor = page.evaluate("() => core.status.floorId")
        print(f"[*] 退回楼层: {back_floor}")
        assert back_floor == "MT5", f"Expected MT5, got {back_floor}"

        # 9. 检查 console errors (忽略在线排行榜 upload.php 与 favicon)
        filtered_errors = [e for e in console_errors if not any(x in e.lower() for x in ["favicon", "upload.php", "status of 404"])]
        print(f"[*] 控制台错误数: {len(filtered_errors)}")
        if filtered_errors:
            print("Errors:", filtered_errors)
        assert len(filtered_errors) == 0, f"Found console errors: {filtered_errors}"

        browser.close()
        print("\n[SUCCESS] 厄泽城·中心广场 (MT6) 全链路验证 100% 通过！")

if __name__ == "__main__":
    main()
