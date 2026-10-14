# -*- coding: utf-8 -*-
"""
自动化验证脚本：【1:1 完整复刻厄泽城 (Map017 - 75x75)】实机端到端全景与交互测试
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

        # 1. 启动游戏
        print("[*] 启动游戏 (Easy)...")
        page.evaluate("() => { core.startGame('Easy'); }")
        time.sleep(1.5)

        for _ in range(30):
            page.keyboard.press("Space")
            time.sleep(0.05)
        time.sleep(0.5)

        # 2. 传送进入 1:1 厄泽城西城门 (6, 72)
        print("[*] 踏入 75x75 厄泽城西城门 (6, 72)...")
        page.evaluate("""() => {
            core.changeFloor('MT6', null, {x: 6, y: 72, direction: 'right'});
        }""")
        time.sleep(1.5)

        curr_floor = page.evaluate("() => core.status.floorId")
        bm_w = page.evaluate("() => core.bigmap.width")
        bm_h = page.evaluate("() => core.bigmap.height")
        print(f"[*] 当前楼层: {curr_floor}, 地图规格: {bm_w} x {bm_h}")
        assert curr_floor == "MT6", f"Expected MT6, got {curr_floor}"
        assert bm_w == 75 and bm_h == 75, f"Expected 75x75, got {bm_w}x{bm_h}"

        # 截取西城门入城全景
        gate_path = os.path.join(ARTIFACT_DIR, "1to1_eze_gate.png")
        page.screenshot(path=gate_path)
        print(f"[*] 西城门实机入城截图已保存: {gate_path}")

        # 3. 前往佣兵公会广场与格瑞迪 (41, 30) 向上交互
        print("[*] 移动至佣兵公会广场 (41, 30) 会面格瑞迪...")
        page.evaluate("""() => {
            core.setHeroLoc('x', 41);
            core.setHeroLoc('y', 30);
            core.setHeroLoc('direction', 'up');
            core.drawHero();
        }""")
        time.sleep(0.8)
        page.keyboard.press("ArrowUp")
        time.sleep(0.8)

        grady_path = os.path.join(ARTIFACT_DIR, "1to1_eze_grady.png")
        page.screenshot(path=grady_path)
        print(f"[*] 1:1 格瑞迪剧情对白截图已保存: {grady_path}")

        # 推进格瑞迪对话
        for _ in range(12):
            page.keyboard.press("Space")
            time.sleep(0.2)
        time.sleep(0.5)

        # 4. 调查佣兵公会大门 (41, 24)，主角站在 (41, 25) 向上交互
        print("[*] 调查佣兵公会大门 (41, 24)...")
        page.evaluate("""() => {
            core.setHeroLoc('x', 41);
            core.setHeroLoc('y', 25);
            core.setHeroLoc('direction', 'up');
            core.drawHero();
        }""")
        time.sleep(0.8)

        guild_path = os.path.join(ARTIFACT_DIR, "1to1_eze_guild.png")
        page.screenshot(path=guild_path)
        print(f"[*] 1:1 佣兵公会全景截图已保存: {guild_path}")

        page.keyboard.press("ArrowUp")
        time.sleep(0.5)
        guild_active = page.evaluate("() => core.status.event.id != null")
        print(f"[*] 佣兵公会大门事件激活: {guild_active}")
        assert guild_active, "佣兵公会大门应可交互！"
        page.keyboard.press("Space")
        time.sleep(0.3)

        # 5. 前往装备商店 (68, 16)，站在 (68, 17) 向上交互
        print("[*] 移动至东区装备商店 (68, 16)...")
        page.evaluate("""() => {
            core.setHeroLoc('x', 68);
            core.setHeroLoc('y', 17);
            core.setHeroLoc('direction', 'up');
            core.drawHero();
        }""")
        time.sleep(0.8)

        shop_path = os.path.join(ARTIFACT_DIR, "1to1_eze_shop.png")
        page.screenshot(path=shop_path)
        print(f"[*] 1:1 装备商店全景截图已保存: {shop_path}")

        page.keyboard.press("ArrowUp")
        time.sleep(0.5)
        shop_active = page.evaluate("() => core.status.event.id != null")
        print(f"[*] 装备商店大门事件激活: {shop_active}")
        assert shop_active, "装备商店大门应可交互！"
        page.keyboard.press("Space")
        time.sleep(0.3)

        # 6. 前往瑞格沃酒馆 (58, 67)，站在 (58, 68) 向上交互
        print("[*] 移动至南区瑞格沃酒馆 (58, 67)...")
        page.evaluate("""() => {
            core.setHeroLoc('x', 58);
            core.setHeroLoc('y', 68);
            core.setHeroLoc('direction', 'up');
            core.drawHero();
        }""")
        time.sleep(0.8)

        tavern_path = os.path.join(ARTIFACT_DIR, "1to1_eze_tavern.png")
        page.screenshot(path=tavern_path)
        print(f"[*] 1:1 瑞格沃酒馆全景截图已保存: {tavern_path}")

        page.keyboard.press("ArrowUp")
        time.sleep(0.5)
        tavern_active = page.evaluate("() => core.status.event.id != null")
        print(f"[*] 瑞格沃酒馆大门事件激活: {tavern_active}")
        assert tavern_active, "酒馆大门应可交互！"
        # 推进酒馆对话
        for _ in range(5):
            page.keyboard.press("Space")
            time.sleep(0.2)
        time.sleep(0.5)

        # 7. 测试西城门无缝退回 MT5 (5, 72)
        print("[*] 返回西城门 (6, 72) 并向左退出至 MT5...")
        page.evaluate("""() => {
            core.setHeroLoc('x', 6);
            core.setHeroLoc('y', 72);
            core.setHeroLoc('direction', 'left');
            core.drawHero();
        }""")
        time.sleep(0.5)
        page.keyboard.press("ArrowLeft")
        time.sleep(1.0)

        back_floor = page.evaluate("() => core.status.floorId")
        print(f"[*] 退回楼层: {back_floor}")
        assert back_floor == "MT5", f"Expected MT5, got {back_floor}"

        # 8. 检查控制台报错
        filtered_errors = [e for e in console_errors if not any(x in e.lower() for x in ["favicon", "upload.php", "status of 404"])]
        print(f"[*] 控制台错误数: {len(filtered_errors)}")
        if filtered_errors:
            print("Errors:", filtered_errors)
        assert len(filtered_errors) == 0, f"Found console errors: {filtered_errors}"

        browser.close()
        print("\n[SUCCESS] 《永不复还》1:1 厄泽城 (75x75) 端到端全景与交互验证 100% 通过！")

if __name__ == "__main__":
    main()
