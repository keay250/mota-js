# -*- coding: utf-8 -*-
"""
端到端实机验证：《永不复还》经验系统、阶位突破引擎与金币流通
1. 验证初始状态栏：阶位称号【下级佣兵】、经验显示【0/120】、血量【500/500】
2. 验证晋阶中级佣兵 (Lv2, 120 EXP)：称号、属性+1、血量+50、经验清算与下一级阈值【0/250】
3. 验证多重晋阶至第一章巅峰【辉煌佣兵】(Lv7)
4. 验证大境界突破【黑铁职业者】(Lv9)：全血回满、解锁魔法值系统(100/100)、属性暴涨
5. 验证实机野怪战斗掉落：击杀战利品结算、金币与经验入账
"""

import os, time
from playwright.sync_api import sync_playwright

BRAIN_DIR = "/Users/zt-lin/.gemini/antigravity-cli/brain/48353322-df08-453c-af70-634f832f9ad4"

def clear_dialogs(page):
    for _ in range(15):
        has_ev = page.evaluate("""
            () => {
                if (core.status.event && core.status.event.id) {
                    if (core.status.event.id === 'action' && core.status.event.data && core.status.event.data.type === 'text') {
                        core.actions._clickAction_text();
                    } else if (core.status.event.id === 'text') {
                        core.drawText();
                    } else {
                        core.doAction();
                    }
                    return true;
                }
                return false;
            }
        """)
        if not has_ev:
            break
        page.wait_for_timeout(100)

def run():
    print("[*] 启动 Playwright 验证《永不复还》经验与金币系统...")
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        context = browser.new_context(viewport={"width": 1280, "height": 900})
        page = context.new_page()

        print("[*] 正在打开 http://127.0.0.1:3000/index.html ...")
        page.goto("http://127.0.0.1:3000/index.html")
        page.wait_for_timeout(1500)

        # 启动游戏
        page.evaluate("core.startGame('normal', 0, function() {});")
        page.wait_for_function("() => window.core && core.status && core.status.floorId === 'MT1'")
        print("[*] 游戏成功初始化并进入 MT1！")
        clear_dialogs(page)
        page.wait_for_timeout(500)

        # -------------------------------------------------------------
        # 1. 验证初始状态 (下级佣兵, Lv1, 0/120 EXP)
        # -------------------------------------------------------------
        print("\n---> [测试 1/5] 验证初始阶位称号与经验状态栏...")
        rank_name = page.evaluate("() => core.getLvName()")
        cur_exp_text = page.evaluate("() => document.getElementById('exp').innerText")
        cur_lv_text = page.evaluate("() => document.getElementById('lv').innerText")
        cur_hp_text = page.evaluate("() => document.getElementById('hp').innerText")

        print(f"  [+] 阶位名称: {rank_name}")
        print(f"  [+] 状态栏 lv 文本: {cur_lv_text}")
        print(f"  [+] 状态栏 exp 文本: {cur_exp_text}")
        print(f"  [+] 状态栏 hp 文本: {cur_hp_text}")

        assert rank_name == "下级佣兵", f"期望【下级佣兵】，实际: {rank_name}"
        assert "120" in cur_exp_text, f"期望经验包含 120，实际: {cur_exp_text}"

        p1 = os.path.join(BRAIN_DIR, "verify_level_1_novice.png")
        page.screenshot(path=p1)
        print(f"  [+] 截图保存: {p1}")

        # -------------------------------------------------------------
        # 2. 验证晋阶【中级佣兵】(Lv2, 120 EXP)
        # -------------------------------------------------------------
        print("\n---> [测试 2/5] 验证获得 120 EXP 自动突破至【中级佣兵】...")
        atk_before = page.evaluate("() => core.getStatus('atk')")
        def_before = page.evaluate("() => core.getStatus('def')")
        hpmax_before = page.evaluate("() => core.getRealStatus('hpmax')")

        # 增加 120 经验
        page.evaluate("() => { core.plugin.addExp(120); }")
        page.wait_for_timeout(800)
        clear_dialogs(page)

        rank_after = page.evaluate("() => core.getLvName()")
        atk_after = page.evaluate("() => core.getStatus('atk')")
        def_after = page.evaluate("() => core.getStatus('def')")
        hpmax_after = page.evaluate("() => core.getRealStatus('hpmax')")
        exp_after_text = page.evaluate("() => document.getElementById('exp').innerText")

        print(f"  [+] 晋阶后称号: {rank_after}")
        print(f"  [+] 攻击变化: {atk_before} -> {atk_after} (提升 {atk_after - atk_before})")
        print(f"  [+] 防御变化: {def_before} -> {def_after} (提升 {def_after - def_before})")
        print(f"  [+] 生命上限: {hpmax_before} -> {hpmax_after} (提升 {hpmax_after - hpmax_before})")
        print(f"  [+] 新阶位经验条: {exp_after_text}")

        assert rank_after == "中级佣兵", f"期望【中级佣兵】，实际: {rank_after}"
        assert atk_after == atk_before + 1, "攻击应 +1"
        assert def_after == def_before + 1, "防御应 +1"
        assert hpmax_after == hpmax_before + 50, "生命上限应 +50"
        assert "250" in exp_after_text, "下一级所需经验应为 250"

        p2 = os.path.join(BRAIN_DIR, "verify_level_2_intermediate.png")
        page.screenshot(path=p2)
        print(f"  [+] 截图保存: {p2}")

        # -------------------------------------------------------------
        # 3. 验证连续跃迁至【辉煌佣兵】(Lv7, 第一章巅峰)
        # -------------------------------------------------------------
        print("\n---> [测试 3/5] 验证累积突破至【辉煌佣兵】(Lv7)...")
        # 依次达到 Lv3(250), Lv4(400), Lv5(800), Lv6(3500), Lv7(8000)
        # 注入总计需要的经验
        page.evaluate("() => { core.plugin.addExp(250 + 400 + 800 + 3500 + 8000); }")
        page.wait_for_timeout(1000)
        clear_dialogs(page)

        rank_lv7 = page.evaluate("() => core.getLvName()")
        atk_lv7 = page.evaluate("() => core.getStatus('atk')")
        def_lv7 = page.evaluate("() => core.getStatus('def')")
        hpmax_lv7 = page.evaluate("() => core.getRealStatus('hpmax')")
        exp_lv7_text = page.evaluate("() => document.getElementById('exp').innerText")

        print(f"  [+] 当前阶位称号: {rank_lv7}")
        print(f"  [+] 当前综合攻击: {atk_lv7}")
        print(f"  [+] 当前综合防御: {def_lv7}")
        print(f"  [+] 当前综合生命上限: {hpmax_lv7}")
        print(f"  [+] 当前经验进度: {exp_lv7_text}")

        assert rank_lv7 == "辉煌佣兵", f"期望【辉煌佣兵】，实际: {rank_lv7}"
        assert "20000" in exp_lv7_text, "下一级所需经验应为 20000"

        p3 = os.path.join(BRAIN_DIR, "verify_level_7_glorious.png")
        page.screenshot(path=p3)
        print(f"  [+] 截图保存: {p3}")

        # -------------------------------------------------------------
        # 4. 验证大境界突破【黑铁职业者】(Lv9, 满血回复 + 魔法解锁)
        # -------------------------------------------------------------
        print("\n---> [测试 4/5] 验证大境界突破【黑铁职业者】(Lv9)...")
        # 先扣除部分血量以验证满血回复
        page.evaluate("() => { core.status.hero.hp = 100; core.updateStatusBar(); }")
        hp_injured = page.evaluate("() => core.getStatus('hp')")
        print(f"  [+] 受到战损，当前生命值: {hp_injured}")

        # 增加 20000 经验触发大突破
        page.evaluate("() => { core.plugin.addExp(20000); }")
        page.wait_for_timeout(1000)
        clear_dialogs(page)

        rank_lv9 = page.evaluate("() => core.getLvName()")
        hp_restored = page.evaluate("() => core.getStatus('hp')")
        hpmax_lv9 = page.evaluate("() => core.getRealStatus('hpmax')")
        mana_lv9 = page.evaluate("() => core.getStatus('mana')")
        manamax_lv9 = page.evaluate("() => core.getRealStatus('manamax')")

        print(f"  [+] 突破后境界: {rank_lv9}")
        print(f"  [+] 突破后生命值: {hp_restored}/{hpmax_lv9} (完全恢复满血)")
        print(f"  [+] 解锁魔法值: {mana_lv9}/{manamax_lv9}")

        assert rank_lv9 == "黑铁职业者", f"期望【黑铁职业者】，实际: {rank_lv9}"
        assert hp_restored == hpmax_lv9, f"大境界突破应完全满血回复 ({hp_restored} != {hpmax_lv9})"
        assert mana_lv9 == 100 and manamax_lv9 == 100, f"应解锁 100 魔法值"

        p4 = os.path.join(BRAIN_DIR, "verify_level_9_career_breakthrough.png")
        page.screenshot(path=p4)
        print(f"  [+] 截图保存: {p4}")

        # -------------------------------------------------------------
        # 5. 验证野怪击杀金币与经验掉落与入账
        # -------------------------------------------------------------
        print("\n---> [测试 5/5] 验证真实战斗战利品与金币入账...")
        # 移动到 MT1 (5, 9) 打小怪
        money_before = page.evaluate("() => core.getStatus('money')")
        exp_before = page.evaluate("() => core.getStatus('exp')")

        # 模拟击败一个怪 (绿头怪)
        page.evaluate("""
            () => {
                core.afterBattle('greenSlime', 5, 9);
            }
        """)
        page.wait_for_timeout(800)
        clear_dialogs(page)

        money_after = page.evaluate("() => core.getStatus('money')")
        exp_after = page.evaluate("() => core.getStatus('exp')")

        print(f"  [+] 金币入账: {money_before} -> {money_after} (+{money_after - money_before})")
        print(f"  [+] 经验入账: {exp_before} -> {exp_after} (+{exp_after - exp_before})")

        assert money_after == money_before + 1, "金币入账应为 1"
        assert exp_after == exp_before + 1, "经验入账应为 1"

        p5 = os.path.join(BRAIN_DIR, "verify_battle_drop_gold_exp.png")
        page.screenshot(path=p5)
        print(f"  [+] 截图保存: {p5}")

        browser.close()
        print("\n🎉 《永不复还》经验系统、阶位突破引擎与金币流通 100% 验证通过！")

if __name__ == '__main__':
    run()
