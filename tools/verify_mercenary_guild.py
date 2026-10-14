import asyncio
from playwright.async_api import async_playwright

async def advance_all_dialogues(page, max_steps=60):
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
        await asyncio.sleep(0.06)

async def main():
    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=True)
        page = await browser.new_page(viewport={"width": 1280, "height": 800})
        
        errors = []
        page.on("console", lambda msg: errors.append(msg.text) if msg.type == "error" else None)
        page.on("pageerror", lambda err: errors.append(str(err)))
        page.on("response", lambda res: print(f"  [404 NOT FOUND]: {res.url}") if res.status == 404 and "upload.php" not in res.url else None)
        
        await page.goto("http://127.0.0.1:3000/index.html", wait_until="networkidle")
        await asyncio.sleep(2)

        # 跳过开局
        for _ in range(25):
            await page.keyboard.press("Space")
            await asyncio.sleep(0.08)
            await page.keyboard.press("Enter")
            await asyncio.sleep(0.08)
        await asyncio.sleep(1)

        print("[*] 正在传送到厄泽城主城区 MT6 (41, 25)...")
        await page.evaluate("""() => {
            if (core.status.lockControl) core.unlockControl();
            if (core.status.event && core.status.event.id) core.clearRouteFolding();
            core.changeFloor('MT6', null, { x: 41, y: 25, direction: 'up' }, 0);
        }""")
        await asyncio.sleep(1.5)

        # 触发 (41, 24) 推开公会大门
        print("[*] 触发 (41, 24) 推门进入佣兵公会...")
        await page.evaluate("""() => {
            core.insertAction(core.floors['MT6'].events['41,24'].data);
        }""")
        await asyncio.sleep(1.5)

        cur_floor = await page.evaluate("core.status.floorId")
        hero_loc = await page.evaluate("[core.getHeroLoc('x'), core.getHeroLoc('y')]")
        print(f"[+] 当前楼层: {cur_floor}, 坐标: {hero_loc}")
        assert cur_floor == "MT7" and hero_loc == [15, 36], f"未能正确进入 MT7 (15, 36)，当前为: {cur_floor} {hero_loc}"

        # 截取进入公会大厅实机截图
        await page.screenshot(path="/Users/zt-lin/.gemini/antigravity-cli/brain/48353322-df08-453c-af70-634f832f9ad4/guild_hall_entered.png")
        print("[+] 公会大厅全景已保存至 guild_hall_entered.png")

        # 触发法芙娜对话 (10, 30)
        print("[*] 走近法芙娜并触发主线对话...")
        await page.evaluate("""() => {
            core.setHeroLoc('x', 10);
            core.setHeroLoc('y', 30);
            core.insertAction(core.floors['MT7'].events['10,30'].data);
        }""")
        await asyncio.sleep(0.8)

        await page.screenshot(path="/Users/zt-lin/.gemini/antigravity-cli/brain/48353322-df08-453c-af70-634f832f9ad4/guild_fafna_dialogue.png")
        print("[+] 法芙娜主线对话已保存至 guild_fafna_dialogue.png")

        # 跳过法芙娜第一次对话
        await advance_all_dialogues(page)
        talked = await page.evaluate("core.hasFlag('talked_fafna')")
        print(f"[+] 法芙娜对话完成，flag:talked_fafna = {talked}")
        assert talked, "法芙娜对话后未正确设置 talked_fafna flag！"

        # 触发公会员工领取遗产
        print("[*] 走向公会柜台 (21, 9) 领取拉瓦尔队长遗产...")
        money_before = await page.evaluate("core.getStatus('money')")
        await page.evaluate("""() => {
            core.setHeroLoc('x', 21);
            core.setHeroLoc('y', 9);
            core.insertAction(core.floors['MT7'].events['21,9'].data);
        }""")
        await asyncio.sleep(0.8)
        await page.screenshot(path="/Users/zt-lin/.gemini/antigravity-cli/brain/48353322-df08-453c-af70-634f832f9ad4/guild_legacy_claimed.png")
        print("[+] 队长遗产领取对话已保存至 guild_legacy_claimed.png")

        # 跳过领取对话
        await advance_all_dialogues(page)
        got_legacy = await page.evaluate("core.hasFlag('got_captain_legacy')")
        money_after = await page.evaluate("core.getStatus('money')")
        print(f"[+] 队长遗产领取完成，got_captain_legacy = {got_legacy}, 金币: {money_before} -> {money_after}")
        assert got_legacy and money_after == money_before + 50, f"遗产领取异常: legacy={got_legacy}, money={money_after}"

        # 再次找法芙娜对话，领取公会封锁线钥匙
        print("[*] 再次找法芙娜对话，获取公会封锁线钥匙...")
        keys_before = await page.evaluate("core.itemCount('yellowKey')")
        await page.evaluate("""() => {
            core.setHeroLoc('x', 10);
            core.setHeroLoc('y', 30);
            core.insertAction(core.floors['MT7'].events['10,30'].data);
        }""")
        await asyncio.sleep(0.8)
        await page.screenshot(path="/Users/zt-lin/.gemini/antigravity-cli/brain/48353322-df08-453c-af70-634f832f9ad4/guild_key_reward.png")
        print("[+] 法芙娜赠送封锁线钥匙对话已保存至 guild_key_reward.png")

        # 跳过对话
        await advance_all_dialogues(page)
        quest_done = await page.evaluate("core.hasFlag('fafna_quest_done')")
        keys_after = await page.evaluate("core.itemCount('yellowKey')")
        print(f"[+] 法芙娜剧情全部完成，fafna_quest_done = {quest_done}, 黄钥匙: {keys_before} -> {keys_after}")
        assert quest_done and keys_after == keys_before + 2, f"钥匙获取异常: quest={quest_done}, keys={keys_after}"

        # 测试走出大门
        print("[*] 走到大门 (15, 37) 走回厄泽城主城区...")
        await page.evaluate("""() => {
            core.setHeroLoc('x', 15);
            core.setHeroLoc('y', 37);
            core.insertAction(core.floors['MT7'].events['15,37'].data);
        }""")
        await asyncio.sleep(1.5)
        back_floor = await page.evaluate("core.status.floorId")
        back_loc = await page.evaluate("[core.getHeroLoc('x'), core.getHeroLoc('y')]")
        print(f"[+] 成功走回城区！当前楼层: {back_floor}, 坐标: {back_loc}")
        assert back_floor == "MT6" and back_loc == [41, 25], f"未能正确回到 MT6 (41, 25)，实际为 {back_floor} {back_loc}"

        print(f"\n🎉 佣兵公会全部剧情与大门传送验收 100% 通过！错误日志数: {len(errors)}")
        if errors:
            for err in errors:
                print(f"  [Console Error]: {err}")
        await browser.close()

if __name__ == "__main__":
    asyncio.run(main())
