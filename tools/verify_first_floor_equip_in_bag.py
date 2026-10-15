import asyncio
import os
from playwright.async_api import async_playwright

ARTIFACT_DIR = "/Users/zt-lin/.gemini/antigravity-cli/brain/48353322-df08-453c-af70-634f832f9ad4"

async def test_first_floor_equip():
    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=True)
        page = await browser.new_page()
        await page.goto("http://127.0.0.1:3000", wait_until="networkidle")
        await page.wait_for_timeout(2000)

        # 1. Start Game
        print("Starting game in normal mode...")
        await page.evaluate("""() => {
            core.startGame('normal', 0, () => {});
        }""")
        await page.wait_for_timeout(1000)

        # Skip prologue texts
        for _ in range(12):
            await page.keyboard.press("Space")
            await page.wait_for_timeout(200)

        # Verify initial clean state
        initial_equips = await page.evaluate("() => core.status.hero.items.equips")
        initial_equipment = await page.evaluate("() => core.status.hero.equipment")
        initial_atk = await page.evaluate("() => core.getRealStatus('atk')")
        print(f"Initial Hero Equips Bag: {initial_equips}")
        print(f"Initial Equipment: {initial_equipment}")
        print(f"Initial ATK: {initial_atk}")

        assert len(initial_equipment) == 0, f"Expected empty equipment, got {initial_equipment}"
        assert len(initial_equips) == 0, f"Expected empty equips bag, got {initial_equips}"
        assert initial_atk == 12, f"Expected 12 ATK, got {initial_atk}"

        # 2. Teleport to (3, 2) facing up, right in front of chest at (3, 1)
        print("Teleporting to (3, 2) in front of chest...")
        await page.evaluate("""() => {
            core.setHeroLoc('x', 3);
            core.setHeroLoc('y', 2);
            core.setHeroLoc('direction', 'up');
            core.drawHero();
        }""")
        await page.wait_for_timeout(500)

        # Step up into chest (3, 1)
        print("Stepping up to open chest...")
        await page.keyboard.press("ArrowUp")
        await page.wait_for_timeout(500)

        # Dismiss dialogue
        for _ in range(4):
            await page.keyboard.press("Space")
            await page.wait_for_timeout(300)

        # Verify chest opened and weapon acquired
        has_sword_equipped = await page.evaluate("() => core.hasEquip('mercenarySword')")
        equipment_after = await page.evaluate("() => core.status.hero.equipment")
        equips_bag_after = await page.evaluate("() => core.status.hero.items.equips")
        atk_after = await page.evaluate("() => core.getRealStatus('atk')")

        print(f"After chest: hasEquip('mercenarySword') = {has_sword_equipped}")
        print(f"After chest: Equipment = {equipment_after}")
        print(f"After chest: Equips Bag = {equips_bag_after}")
        print(f"After chest: ATK = {atk_after}")

        assert has_sword_equipped == True, "Hero must have mercenarySword equipped!"
        assert "mercenarySword" in equipment_after, f"mercenarySword must be equipped! Got: {equipment_after}"
        assert atk_after == 27, f"Expected 27 ATK (12+15), got {atk_after}"

        # 3. Press Q to open equipbox
        print("Pressing Q to open equipbox...")
        await page.keyboard.press("KeyQ")
        await page.wait_for_timeout(800)
        shot_q1 = os.path.join(ARTIFACT_DIR, "verify_first_floor_equip_q_screen.png")
        await page.screenshot(path=shot_q1)
        print(f"Captured Q screen with sword: {shot_q1}")

        # 4. Test Unload Equip
        print("Testing unload equip...")
        await page.evaluate("() => core.unloadEquip(0)")
        await page.wait_for_timeout(500)
        equipment_unloaded = await page.evaluate("() => core.status.hero.equipment")
        equips_bag_unloaded = await page.evaluate("() => core.status.hero.items.equips")
        atk_unloaded = await page.evaluate("() => core.getRealStatus('atk')")

        print(f"After unload: Equipment = {equipment_unloaded}")
        print(f"After unload: Equips Bag = {equips_bag_unloaded}")
        print(f"After unload: ATK = {atk_unloaded}")

        assert equipment_unloaded[0] is None, f"Equipment slot 0 should be None after unload, got {equipment_unloaded}"
        assert equips_bag_unloaded.get("mercenarySword") == 1, "mercenarySword must be back in bag"
        assert atk_unloaded == 12, "ATK should return to 12"

        shot_q2 = os.path.join(ARTIFACT_DIR, "verify_first_floor_equip_unloaded_screen.png")
        await page.screenshot(path=shot_q2)
        print(f"Captured Q screen after unload: {shot_q2}")

        # 5. Test Load Equip again
        print("Testing load equip again...")
        await page.evaluate("() => core.loadEquip('mercenarySword')")
        await page.wait_for_timeout(500)
        atk_reloaded = await page.evaluate("() => core.getRealStatus('atk')")
        equipment_reloaded = await page.evaluate("() => core.status.hero.equipment")
        print(f"After re-load: Equipment = {equipment_reloaded}, ATK = {atk_reloaded}")

        assert "mercenarySword" in equipment_reloaded, "mercenarySword should be equipped again"
        assert atk_reloaded == 27, "ATK should be 27 again"

        # Close equipbox
        await page.keyboard.press("KeyQ")
        await page.wait_for_timeout(500)

        await browser.close()
        print("🎉 All assertions in test_first_floor_equip passed flawlessly!")

if __name__ == "__main__":
    asyncio.run(test_first_floor_equip())
