import asyncio
import os
from playwright.async_api import async_playwright

ARTIFACT_DIR = "/Users/zt-lin/.gemini/antigravity-cli/brain/48353322-df08-453c-af70-634f832f9ad4"

async def test_fafna_actions():
    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=True)
        page = await browser.new_page()
        await page.goto("http://127.0.0.1:3000", wait_until="networkidle")
        await page.wait_for_timeout(2000)

        # Start game
        await page.evaluate("""() => {
            core.startGame('normal', 0, () => {});
        }""")
        await page.wait_for_timeout(1000)

        # Teleport to MT7 in front of Fafna (9, 31) facing up towards (9, 30)
        print("Teleporting to MT7 in front of Fafna (9, 31)...")
        await page.evaluate("""() => {
            core.changeFloor('MT7', null, {x: 9, y: 31, direction: 'up'}, () => {});
        }""")
        await page.wait_for_timeout(1000)

        # Trigger jump on Fafna (9, 30) to test jumpBlock API
        print("Testing jumpBlock on (9, 30)...")
        jump_result = await page.evaluate("""() => {
            return new Promise((resolve) => {
                core.jumpBlock(9, 30, 9, 30, 300, true, () => {
                    resolve(true);
                });
            });
        }""")
        print(f"jumpBlock execution result: {jump_result}")

        shot_path = os.path.join(ARTIFACT_DIR, "verify_fafna_jump_action.png")
        await page.screenshot(path=shot_path)
        print(f"Captured screen at: {shot_path}")

        await browser.close()

if __name__ == "__main__":
    asyncio.run(test_fafna_actions())
