import time
import os
from playwright.sync_api import sync_playwright

def test_equip_and_ui():
    artifacts_dir = "/Users/zt-lin/.gemini/antigravity-cli/brain/48353322-df08-453c-af70-634f832f9ad4"
    os.makedirs(artifacts_dir, exist_ok=True)
    
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page(viewport={"width": 1280, "height": 800})
        
        console_errors = []
        def is_ignorable(txt):
            return "play()" in txt or "interact with the document" in txt or "404" in txt or "upload.php" in txt

        page.on("console", lambda msg: console_errors.append(msg.text) if msg.type == "error" and not is_ignorable(msg.text) else None)
        page.on("pageerror", lambda exc: console_errors.append(str(exc)) if not is_ignorable(str(exc)) else None)
        
        print("Navigating to http://127.0.0.1:3000 ...")
        page.goto("http://127.0.0.1:3000")
        page.wait_for_load_state("networkidle")
        time.sleep(2)
        
        # 1. Start Game
        print("Starting game...")
        page.evaluate("core.startGame('Easy', 0, [])")
        time.sleep(2)
        
        # Skip dialogues
        for _ in range(8):
            page.keyboard.press("Space")
            time.sleep(0.3)
            
        print("In game, verifying initial status bar...")
        shot1 = os.path.join(artifacts_dir, "ybfh_dark_ui_initial.png")
        page.screenshot(path=shot1)
        print(f"Saved initial screen to {shot1}")
        
        # Verify initial stats (Easy mode grants +1 atk, +1 def)
        initial_atk = page.evaluate("core.getRealStatus('atk')")
        initial_def = page.evaluate("core.getRealStatus('def')")
        print(f"Initial stats: ATK={initial_atk}, DEF={initial_def}")
        assert initial_atk == 13, f"Expected 13, got {initial_atk}"
        assert initial_def == 3, f"Expected 3, got {initial_def}"
        
        # Add test equips for UI testing
        page.evaluate("""
            core.addItem('crystalSword', 1);
            core.addItem('buckler', 1);
            core.addItem('ringOfRegen', 1);
        """)
        has_crystal = page.evaluate("core.hasItem('crystalSword')")
        print(f"Bag has crystalSword: {has_crystal}")
        assert has_crystal, "crystalSword should be in hero bag!"
        
        # 2. Test Key 'Q': Open Equipbox
        print("Testing Key 'Q' (Equipbox)...")
        page.keyboard.press("KeyQ")
        time.sleep(0.8)
        shot_q = os.path.join(artifacts_dir, "ybfh_equipbox_opened.png")
        page.screenshot(path=shot_q)
        print(f"Saved equipbox screenshot to {shot_q}")
        page.keyboard.press("Escape")
        time.sleep(0.5)
        
        # 3. Equip Crystal Sword & Buckler & Ring of Regen
        print("Equipping crystalSword, buckler, ringOfRegen...")
        page.evaluate("""
            core.loadEquip('crystalSword');
            core.loadEquip('buckler');
            core.loadEquip('ringOfRegen');
        """)
        time.sleep(1)
        
        new_atk = page.evaluate("core.getRealStatus('atk')")
        new_def = page.evaluate("core.getRealStatus('def')")
        props = page.evaluate("core.plugin.getHeroEquipProps()")
        print(f"After Equip: ATK={new_atk} (Expected 188), DEF={new_def} (Expected 9)")
        print(f"Equip Props: {props}")
        assert new_atk == 188, f"Expected 188 ATK with Crystal Sword, got {new_atk}"
        assert new_def == 9, f"Expected 9 DEF with Buckler, got {new_def}"
        assert abs(props['critExp'] - 1.15) < 0.01, f"Expected 1.15 critExp, got {props['critExp']}"
        assert abs(props['damageReduction'] - 0.05) < 0.01, f"Expected 0.05 damageReduction, got {props['damageReduction']}"
        assert props['hpRecover'] == 15, f"Expected 15 hpRecover, got {props['hpRecover']}"
        
        shot_equipped = os.path.join(artifacts_dir, "ybfh_equipped_crystal_sword.png")
        page.screenshot(path=shot_equipped)
        print(f"Saved equipped screen to {shot_equipped}")
        
        # 4. Test Key 'N': Task panel (Verify restart bomb is eliminated!)
        print("Testing Key 'N' (Task panel)...")
        page.keyboard.press("KeyN")
        time.sleep(0.8)
        shot_n = os.path.join(artifacts_dir, "ybfh_task_panel.png")
        page.screenshot(path=shot_n)
        print(f"Saved task panel screenshot to {shot_n}")
        page.keyboard.press("Space")
        time.sleep(0.5)
        
        # 5. Test Key 'D': Skill panel
        print("Testing Key 'D' (Skill panel)...")
        page.keyboard.press("KeyD")
        time.sleep(0.8)
        shot_d = os.path.join(artifacts_dir, "ybfh_skill_panel.png")
        page.screenshot(path=shot_d)
        print(f"Saved skill panel screenshot to {shot_d}")
        page.keyboard.press("Space")
        time.sleep(0.5)
        
        # 6. Test Key 'A': Suit panel
        print("Testing Key 'A' (Suit panel)...")
        page.keyboard.press("KeyA")
        time.sleep(0.8)
        shot_a = os.path.join(artifacts_dir, "ybfh_suit_panel.png")
        page.screenshot(path=shot_a)
        print(f"Saved suit panel screenshot to {shot_a}")
        page.keyboard.press("Space")
        time.sleep(0.5)
        
        # Check console errors
        print(f"Total console errors: {len(console_errors)}")
        if console_errors:
            print("Errors found:", console_errors)
        assert len(console_errors) == 0, f"Found console errors: {console_errors}"
        
        print("ALL TESTS PASSED WITH 100% SUCCESS!")
        browser.close()

if __name__ == "__main__":
    test_equip_and_ui()
