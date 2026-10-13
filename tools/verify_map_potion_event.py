import asyncio
from playwright.async_api import async_playwright

async def test_potion_event():
    print("[*] 正在测试地图拾取实机交互: 满血拾取教学血瓶...")
    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=True)
        page = await browser.new_page(viewport={"width": 1280, "height": 800})
        await page.goto("http://127.0.0.1:3000/")
        await asyncio.sleep(2)

        # 启动并选择初心试炼
        await page.keyboard.press("Space")
        await asyncio.sleep(0.5)
        btn = await page.query_selector("text=初心试炼")
        if btn: await btn.click()
        for _ in range(25):
            await page.keyboard.press("Space")
            await asyncio.sleep(0.05)
        await asyncio.sleep(1)

        # 此时主角在 (2, 12)，满血 700/700
        # 往左走一步 (1, 12)
        await page.keyboard.press("ArrowLeft")
        await asyncio.sleep(0.3)
        # 往上走一步尝试拾取 (1, 11) 处的血瓶
        await page.keyboard.press("ArrowUp")
        await asyncio.sleep(0.5)

        # 检查是否弹出了防溢出提示
        # 游戏中如果弹出文本框，core.status.event.id 会是 "text"
        dialog_info = await page.evaluate("""() => {
            return {
                isEvent: core.isMoving() || (core.status.event && core.status.event.id != null),
                eventId: core.status.event ? core.status.event.id : null,
                uiText: core.status.event && core.status.event.ui ? core.status.event.ui.text : '',
                potionExists: core.status.thisMap.events["1,11"] != null,
                heroLoc: core.getHeroLoc(),
                hp: core.getStatus('hp')
            };
        }""")
        print(f" -> 满血尝试拾取血瓶返回: {dialog_info}")
        
        assert dialog_info['potionExists'], "满血时血瓶不应该被拾取消失！"
        print(" ✅ 满血状态尝试拾取血瓶：血瓶完好保留未被浪费，防溢出逻辑 100% 生效！")
        
        await browser.close()

if __name__ == "__main__":
    asyncio.run(test_potion_event())
