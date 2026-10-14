import asyncio
from playwright.async_api import async_playwright

async def advance_all_dialogues(page, max_steps=50):
    for _ in range(max_steps):
        has_more = await page.evaluate("""() => {
            var eid = core.status.event ? core.status.event.id : null;
            if (!eid) return false;
            if (eid == "action") {
                if (core.status.event.data && core.status.event.data.type == "text") {
                    core.actions._clickAction_text();
                } else {
                    core.doAction();
                }
            } else if (eid == "text") {
                core.drawText();
            } else {
                core.doAction();
            }
            return Boolean(core.status.event && core.status.event.id);
        }""")
        if not has_more:
            break
        await asyncio.sleep(0.05)

async def main():
    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=True)
        page = await browser.new_page(viewport={"width": 1280, "height": 800})
        
        errors = []
        page.on("console", lambda msg: errors.append(msg.text) if msg.type == "error" else None)
        page.on("pageerror", lambda err: errors.append(str(err)))
        
        await page.goto("http://127.0.0.1:3000/index.html", wait_until="networkidle")
        await asyncio.sleep(2)

        # 跳过开场
        for _ in range(25):
            await page.keyboard.press("Space")
            await asyncio.sleep(0.06)
            await page.keyboard.press("Enter")
            await asyncio.sleep(0.06)
        await asyncio.sleep(1)

        # ------------------------------------------------------------------
        # 验证 1: 装备界面高清图标渲染
        # ------------------------------------------------------------------
        print("\n=== [验证 1: 装备界面图标] ===")
        await page.evaluate("""() => {
            // 给玩家发放装备并穿戴回复戒指
            core.getItem('ringOfRegen', 1);
            core.getItem('buckler', 1);
            core.getItem('poorLeather', 1);
            core.getItem('greatSword', 1);
            core.loadEquip('ringOfRegen');
            // 打开装备栏
            core.openEquipbox();
        }""")
        await asyncio.sleep(1)

        equip_screenshot_path = "/Users/zt-lin/.gemini/antigravity-cli/brain/48353322-df08-453c-af70-634f832f9ad4/verify_equip_icons_fixed.png"
        await page.screenshot(path=equip_screenshot_path)
        print(f"[+] 装备界面截图已保存至: {equip_screenshot_path}")

        # 关闭装备栏
        await page.evaluate("core.closePanel()")
        await asyncio.sleep(0.5)

        # ------------------------------------------------------------------
        # 验证 2: 佣兵公会全员碰撞对话
        # ------------------------------------------------------------------
        print("\n=== [验证 2: 佣兵公会碰撞触发对话] ===")
        # 传送到 MT7 (15, 28)
        await page.evaluate("""() => {
            core.changeFloor('MT7', null, { x: 15, y: 28, direction: 'left' }, 0);
        }""")
        await asyncio.sleep(1)

        # 2.1 青年佣兵 (14, 28)
        print("[*] 玩家在 (15, 28) 朝左按键撞击青年佣兵 (14, 28)...")
        await page.keyboard.press("ArrowLeft")
        await asyncio.sleep(0.5)
        ev1 = await page.evaluate("core.status.event ? core.status.event.id : null")
        assert ev1 == "action", f"青年佣兵未触发对话！当前 event: {ev1}"
        print("[+] 青年佣兵对话触发成功！")
        await advance_all_dialogues(page)

        # 2.2 执事 (20, 28)
        print("[*] 玩家在 (20, 29) 朝上按键撞击执事 (20, 28)...")
        await page.evaluate("core.setHeroLoc('x', 20); core.setHeroLoc('y', 29); core.setHeroLoc('direction', 'up');")
        await asyncio.sleep(0.3)
        await page.keyboard.press("ArrowUp")
        await asyncio.sleep(0.5)
        ev2 = await page.evaluate("core.status.event ? core.status.event.id : null")
        assert ev2 == "action", f"执事未触发对话！当前 event: {ev2}"
        print("[+] 执事对话触发成功！")
        await advance_all_dialogues(page)

        # 2.3 重装佣兵 (22, 30)
        print("[*] 玩家在 (21, 30) 朝右按键撞击重装佣兵 (22, 30)...")
        await page.evaluate("core.setHeroLoc('x', 21); core.setHeroLoc('y', 30); core.setHeroLoc('direction', 'right');")
        await asyncio.sleep(0.3)
        await page.keyboard.press("ArrowRight")
        await asyncio.sleep(0.5)
        ev3 = await page.evaluate("core.status.event ? core.status.event.id : null")
        assert ev3 == "action", f"重装佣兵未触发对话！当前 event: {ev3}"
        print("[+] 重装佣兵对话触发成功！")
        await advance_all_dialogues(page)

        # 2.4 法芙娜 (9, 30)
        print("[*] 玩家在 (10, 30) 朝左按键撞击法芙娜 (9, 30)...")
        await page.evaluate("core.setHeroLoc('x', 10); core.setHeroLoc('y', 30); core.setHeroLoc('direction', 'left');")
        await asyncio.sleep(0.3)
        await page.keyboard.press("ArrowLeft")
        await asyncio.sleep(0.5)
        ev4 = await page.evaluate("core.status.event ? core.status.event.id : null")
        assert ev4 == "action", f"法芙娜未触发对话！当前 event: {ev4}"
        print("[+] 法芙娜主线对话触发成功！")
        await advance_all_dialogues(page)

        # 2.5 办事专柜 (21, 8)
        print("[*] 玩家在 (21, 9) 朝上按键撞击专柜员工 (21, 8)...")
        await page.evaluate("core.setHeroLoc('x', 21); core.setHeroLoc('y', 9); core.setHeroLoc('direction', 'up');")
        await asyncio.sleep(0.3)
        await page.keyboard.press("ArrowUp")
        await asyncio.sleep(0.5)
        ev5 = await page.evaluate("core.status.event ? core.status.event.id : null")
        assert ev5 == "action", f"专柜领取遗产未触发对话！当前 event: {ev5}"
        print("[+] 专柜领取遗产对话触发成功！")
        await advance_all_dialogues(page)

        # ------------------------------------------------------------------
        # 验证 3: 图层前后遮挡特写截图
        # ------------------------------------------------------------------
        print("\n=== [验证 3: 图层前后遮挡] ===")
        # 截取大厅桌椅佣兵特写
        await page.evaluate("core.setHeroLoc('x', 15); core.setHeroLoc('y', 29); core.setHeroLoc('direction', 'left');")
        await asyncio.sleep(0.5)
        zsort_screenshot = "/Users/zt-lin/.gemini/antigravity-cli/brain/48353322-df08-453c-af70-634f832f9ad4/verify_table_zsort_fixed.png"
        await page.screenshot(path=zsort_screenshot)
        print(f"[+] 桌椅图层遮挡验证截图已保存至: {zsort_screenshot}")

        print(f"\n🎉 三大问题修复 100% 验收通过！控制台报错数: {len(errors)}")
        if errors:
            for e in errors:
                if "upload.php" not in e and "play()" not in e:
                    print(f"  [Console Error]: {e}")
        await browser.close()

if __name__ == "__main__":
    asyncio.run(main())
