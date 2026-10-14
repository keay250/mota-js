# -*- coding: utf-8 -*-
"""
端到端实机战斗开门测试：
模拟勇士通过真实 battleHero 打死最后一只守护怪，
验证 functions.js 的 afterBattle 能够自动触发 checkFloorSpecialDoors，
并在画面上自动移除机关门并弹出提示！
"""
import os, time
from playwright.sync_api import sync_playwright

SCREENSHOT_DIR = os.path.expanduser("~/.gemini/antigravity-cli/brain/48353322-df08-453c-af70-634f832f9ad4")

def run():
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page(viewport={"width": 1280, "height": 800})
        page.goto("http://127.0.0.1:3000/index.html")
        page.wait_for_timeout(1000)

        # 启动游戏
        page.evaluate("core.startGame('normal', 0, function() {});")
        page.wait_for_timeout(1500)

        # 传送至 MT4
        page.evaluate("""
            core.changeFloor('MT4', null, [11, 11], 'up', function() {
                core.clearRouteFolding();
            });
        """)
        page.wait_for_timeout(1000)

        # 给勇士超强属性保证一击必杀
        page.evaluate("""
            () => {
                core.status.hero.hp = 99999;
                core.status.hero.atk = 9999;
                core.status.hero.def = 9999;
                // 先除掉其中两只守护怪，保留最后一只 (12, 13)
                core.removeBlock(11, 12, 'MT4');
                core.removeBlock(13, 12, 'MT4');
            }
        """)
        page.wait_for_timeout(500)

        # 验证此时门依然关闭
        door_before = page.evaluate("core.getBlock(7, 4) != null;")
        print(f"[*] 击杀最后一只守护怪前，(7, 4) 机关门存在: {door_before}")
        assert door_before, "错误：门提前开启！"

        # 模拟玩家向 (12, 13) 的怪物发起真实战斗
        print("[*] 玩家向守护怪 (12, 13) 发起真实战斗...")
        page.evaluate("""
            () => {
                core.battle('zombie', 12, 13);
            }
        """)
        page.wait_for_timeout(2000)

        # 检查战斗后机关门是否自动消失且 flag 置为 true
        door_after = page.evaluate("""
            () => {
                return {
                    door74: core.getBlock(7, 4),
                    flag: core.hasFlag('mt4_doors_opened')
                };
            }
        """)
        print(f"[*] 真实战斗结束后状态: door(7,4)={door_after['door74']}, flag={door_after['flag']}")
        assert door_after['flag'] == True, "错误：战后 mt4_doors_opened 未置为 true！"
        assert door_after['door74'] is None, "错误：战后 (7, 4) 机关门未自动移除！"

        # 截取真实战后开门画面
        shot = os.path.join(SCREENSHOT_DIR, "real_battle_door_opened.png")
        page.screenshot(path=shot)
        print(f"[+] 真实战斗开门截图保存至: {shot}")

        print("\n==========================================")
        print("🎉 真实战斗触发机关门端到端验证 100% 成功！")
        print("==========================================")

        browser.close()

if __name__ == "__main__":
    run()
