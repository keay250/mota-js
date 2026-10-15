import asyncio
import os
from playwright.async_api import async_playwright

ARTIFACT_DIR = "/Users/zt-lin/.gemini/antigravity-cli/brain/48353322-df08-453c-af70-634f832f9ad4"

async def test_q():
    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=True)
        page = await browser.new_page()
        await page.goto("http://127.0.0.1:3000", wait_until="networkidle")
        await page.wait_for_timeout(2000)

        # Start game normal
        await page.evaluate("""() => {
            core.startGame('normal', 0, () => {});
        }""")
        await page.wait_for_timeout(1000)

        # Clear hero bag equips to simulate clean state, then add mercenarySword
        await page.evaluate("""() => {
            core.status.hero.items.equips = {};
            core.status.hero.equipment = [];
            core.addItem('mercenarySword', 1);
        }""")
        
        has_sword = await page.evaluate("() => core.hasItem('mercenarySword')")
        equips = await page.evaluate("() => core.status.hero.items.equips")
        print(f"Has mercenarySword in equips: {has_sword}, equips: {equips}")

        # Press Q
        await page.keyboard.press("KeyQ")
        await page.wait_for_timeout(800)
        shot1 = os.path.join(ARTIFACT_DIR, "test_q_equipbox_clean.png")
        await page.screenshot(path=shot1)
        print(f"Captured Q screen: {shot1}")

        # In equipbox, what is current UI state?
        ui_state = await page.evaluate("() => core.status.event.id")
        print(f"UI state: {ui_state}")

        # Press Enter / Space on slot 0
        await page.keyboard.press("Enter")
        await page.wait_for_timeout(500)
        shot2 = os.path.join(ARTIFACT_DIR, "test_q_slot0_selected.png")
        await page.screenshot(path=shot2)
        print(f"Captured slot0 selected screen: {shot2}")

        # Press Enter to equip mercenarySword
        await page.keyboard.press("Enter")
        await page.wait_for_timeout(500)
        shot3 = os.path.join(ARTIFACT_DIR, "test_q_after_equip.png")
        await page.screenshot(path=shot3)
        print(f"Captured after equip screen: {shot3}")

        equipment_now = await page.evaluate("() => core.status.hero.equipment")
        atk_now = await page.evaluate("() => core.getRealStatus('atk')")
        print(f"Hero equipment now: {equipment_now}, ATK: {atk_now}")

        await browser.close()

if __name__ == "__main__":
    asyncio.run(test_q())
