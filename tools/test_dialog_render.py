import asyncio
from playwright.async_api import async_playwright

async def main():
    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=True)
        page = await browser.new_page(viewport={"width": 1280, "height": 800})
        await page.goto("http://127.0.0.1:3000/index.html", wait_until="networkidle")
        await asyncio.sleep(2)

        for _ in range(25):
            await page.keyboard.press("Space")
            await asyncio.sleep(0.1)
            await page.keyboard.press("Enter")
            await asyncio.sleep(0.1)
        await asyncio.sleep(1)

        # 测试 1: 底部 RPG 对话框（带头像和姓名框）
        await page.evaluate("""() => {
            if (core.status.lockControl) core.unlockControl();
            if (core.status.event && core.status.event.id) core.clearRouteFolding();
            core.ui.drawTextBox("\\t[贾斯汀,hero]头好痛……我刚刚是透支体力昏过去了么。\\n队长呢？其他人呢？");
        }""")
        await asyncio.sleep(1.5)
        await page.screenshot(path="/Users/zt-lin/.gemini/antigravity-cli/brain/48353322-df08-453c-af70-634f832f9ad4/dialog_test_bottom.png")
        print("Bottom dialog saved!")

        # 测试 2: 人物头顶气泡对话框（Fuki 模式）
        await page.evaluate("""() => {
            core.ui.drawTextBox("\\t[贾斯汀,hero]\\b[up,hero]头好痛……我刚刚是透支体力昏过去了么。\\n队长呢？其他人呢？");
        }""")
        await asyncio.sleep(1.5)
        await page.screenshot(path="/Users/zt-lin/.gemini/antigravity-cli/brain/48353322-df08-453c-af70-634f832f9ad4/dialog_test_bubble.png")
        print("Bubble dialog saved!")

        await browser.close()

if __name__ == "__main__":
    asyncio.run(main())
