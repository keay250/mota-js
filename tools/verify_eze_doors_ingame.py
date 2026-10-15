import asyncio
import os
from playwright.async_api import async_playwright

ARTIFACT_DIR = "/Users/zt-lin/.gemini/antigravity-cli/brain/48353322-df08-453c-af70-634f832f9ad4"

async def test_eze_doors():
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

        # Teleport to MT6 (Eze City) right in front of guild entrance (41, 27) facing up
        await page.evaluate("""() => {
            core.changeFloor('MT6', null, {x: 41, y: 27, direction: 'up'}, () => {});
        }""")
        await page.wait_for_timeout(1000)

        # Take screenshot of the game canvas in front of guild
        shot_path = os.path.join(ARTIFACT_DIR, "verify_ingame_guild_door.png")
        await page.screenshot(path=shot_path)
        print(f"Captured screenshot at {shot_path}")

        # Dismiss any text box if open, or wait
        await page.keyboard.press("Space")
        await page.wait_for_timeout(500)
        await page.keyboard.press("Enter")
        await page.wait_for_timeout(500)

        # Move up 3 steps into the door (41, 24)
        for _ in range(4):
            await page.keyboard.press("ArrowUp")
            await page.wait_for_timeout(300)

        await page.wait_for_timeout(1000)
        current_floor = await page.evaluate("() => core.status.floorId")
        hero_loc = await page.evaluate("() => ({x: core.getHeroLoc('x'), y: core.getHeroLoc('y')})")
        print(f"After walking into door: Floor = {current_floor}, HeroLoc = {hero_loc}")
        
        # If still in MT6 because of lock, trigger step via step/moveHero
        if current_floor != "MT7":
            await page.evaluate("""() => {
                core.moveHero('up', () => {});
            }""")
            await page.wait_for_timeout(1000)
            current_floor = await page.evaluate("() => core.status.floorId")

        # Take screenshot inside guild
        inside_shot = os.path.join(ARTIFACT_DIR, "verify_ingame_guild_inside.png")
        await page.screenshot(path=inside_shot)
        print(f"Captured inside screenshot at {inside_shot}")

        await browser.close()

if __name__ == "__main__":
    asyncio.run(test_eze_doors())
