import asyncio
import os
from playwright.async_api import async_playwright

SCREENSHOT_PATH = os.path.expanduser(
    "~/.gemini/antigravity-cli/brain/48353322-df08-453c-af70-634f832f9ad4/hp_system_verified.png"
)

async def test_hp_system():
    print("[*] 正在启动 Playwright 无头浏览器验证 HP/HPMAX 底层体系...")
    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=True)
        page = await browser.new_page(viewport={"width": 1280, "height": 800})
        
        url = "http://127.0.0.1:3000/"
        print(f"[*] 导航至: {url}")
        await page.goto(url)
        await page.wait_for_load_state("networkidle")
        await asyncio.sleep(2)

        # 1. 快速跳过标题与开局
        print("[1/5] 跳过标题与开局动画...")
        await page.keyboard.press("Space")
        await asyncio.sleep(0.5)
        
        # 此时应该弹出难度选择框，点击初心试炼 (Easy)
        easy_btn = await page.query_selector("text=初心试炼")
        if easy_btn:
            print(" -> 发现难度选择【初心试炼】，正在点击选择...")
            await easy_btn.click()
            await asyncio.sleep(0.5)
        else:
            await page.keyboard.press("Space")
            await asyncio.sleep(0.5)

        # 连续按 Space/Enter 跳过开场福利提示和序章对白
        print("[2/5] 跳过开场剧情对话...")
        for _ in range(25):
            await page.keyboard.press("Space")
            await asyncio.sleep(0.1)

        await asyncio.sleep(1)

        # 2. 检查初始血量和状态栏显示
        print("\n[3/5] 验证开局生命值与状态栏显示...")
        hp_info = await page.evaluate("""() => {
            return {
                hp: core.getStatus('hp'),
                hpmax: core.getRealStatus('hpmax'),
                statusBarHp: document.getElementById('hp') ? document.getElementById('hp').innerText : '',
                statusBarMana: document.getElementById('mana') ? document.getElementById('mana').innerText : ''
            };
        }""")
        print(f" -> 引擎内部状态: hp={hp_info['hp']}, hpmax={hp_info['hpmax']}")
        print(f" -> 状态栏显示: #hp='{hp_info['statusBarHp']}'")

        assert hp_info['hp'] == 700, f"期望初始血量 700，实际 {hp_info['hp']}"
        assert hp_info['hpmax'] == 700, f"期望初始上限 700，实际 {hp_info['hpmax']}"
        assert "700/700" in hp_info['statusBarHp'], f"期望状态栏显示 700/700，实际 '{hp_info['statusBarHp']}'"
        print(" ✅ 开局 700/700 状态栏与底层数值验证 100% 吻合！")

        # 3. 验证生命上限水晶机制 (core.addMaxHp)
        print("\n[4/5] 验证生命上限提升与等比例血量机制...")
        # 情况 A: 满血吃绿水晶 (+20 hpmax)
        res_a = await page.evaluate("""() => {
            core.addMaxHp(20);
            return {
                hp: core.getStatus('hp'),
                hpmax: core.getRealStatus('hpmax'),
                statusBarHp: document.getElementById('hp').innerText
            };
        }""")
        print(f" -> 满血+20上限: hp={res_a['hp']}, hpmax={res_a['hpmax']}, bar='{res_a['statusBarHp']}'")
        assert res_a['hp'] == 720 and res_a['hpmax'] == 720, "满血+20应为 720/720"
        assert "720/720" in res_a['statusBarHp']
        print(" ✅ 满血状态 +20 上限同步升满 720/720 验证通过！")

        # 情况 B: 残血吃绿水晶 (例如受到伤害掉至 360/720，即 50% 比例，再吃 +20 上限)
        res_b = await page.evaluate("""() => {
            core.status.hero.hp = 360; // 50% 血量
            core.updateStatusBar();
            core.addMaxHp(20); // 上限变为 740, 50% 应为 370
            return {
                hp: core.getStatus('hp'),
                hpmax: core.getRealStatus('hpmax'),
                statusBarHp: document.getElementById('hp').innerText
            };
        }""")
        print(f" -> 残血50%+20上限: hp={res_b['hp']}, hpmax={res_b['hpmax']}, bar='{res_b['statusBarHp']}'")
        assert res_b['hpmax'] == 740, "上限应为 740"
        assert res_b['hp'] == 370, f"50%残血比例等比提升应为 370，实际 {res_b['hp']}"
        assert "370/740" in res_b['statusBarHp']
        print(" ✅ 残血状态等比例提升生命值 370/740 验证通过！")

        # 4. 验证血瓶防溢出机制 (core.addHp)
        print("\n[5/5] 验证血瓶防溢出机制...")
        # 此时 370/740，喝蓝血瓶(+100) -> 470/740
        res_c = await page.evaluate("""() => {
            core.addHp(100);
            return {
                hp: core.getStatus('hp'),
                hpmax: core.getRealStatus('hpmax'),
                statusBarHp: document.getElementById('hp').innerText
            };
        }""")
        print(f" -> 喝+100蓝血瓶: hp={res_c['hp']}, hpmax={res_c['hpmax']}, bar='{res_c['statusBarHp']}'")
        assert res_c['hp'] == 470
        assert "470/740" in res_c['statusBarHp']

        # 假如此时加 500 血，不能突破 740 上限
        res_d = await page.evaluate("""() => {
            core.addHp(500); // 470 + 500 = 970 > 740
            return {
                hp: core.getStatus('hp'),
                hpmax: core.getRealStatus('hpmax'),
                statusBarHp: document.getElementById('hp').innerText
            };
        }""")
        print(f" -> 溢出治疗(+500): hp={res_d['hp']}, hpmax={res_d['hpmax']}, bar='{res_d['statusBarHp']}'")
        assert res_d['hp'] == 740, f"血量应被封顶为 740，实际 {res_d['hp']}"
        assert "740/740" in res_d['statusBarHp']
        print(" ✅ 溢出治疗严格封顶防溢出 740/740 验证通过！")

        # 5. 截图保存为 Artifact
        await page.screenshot(path=SCREENSHOT_PATH)
        print(f"\n[+] 实机运行检验截图已成功写入: {SCREENSHOT_PATH}")
        await browser.close()

if __name__ == "__main__":
    asyncio.run(test_hp_system())
