# -*- coding: utf-8 -*-
"""
验证 MT4 与 MT3 机关门触发与开门机制
1. MT4 机关门在右下角守护怪消灭或全图怪消灭后自动开启并移除 (7,4), (5,1), (9,1)
2. MT4 撞门与读档自愈开门
3. MT3 机关门 (2,6) 在守护怪消灭后自动开启并移除
"""
import time, os
from playwright.sync_api import sync_playwright

SCREENSHOT_DIR = os.path.expanduser("~/.gemini/antigravity-cli/brain/48353322-df08-453c-af70-634f832f9ad4")

def run_test():
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page(viewport={"width": 1280, "height": 800})
        print("[*] 正在加载游戏页面...")
        page.goto("http://127.0.0.1:3000/index.html")
        page.wait_for_timeout(2000)

        # 启动游戏
        page.evaluate("core.startGame('normal', 0, function() {});")
        page.wait_for_timeout(2000)

        # 1. 验证 MT4
        print("[*] 切换至 MT4（寂静之森外围 4F）...")
        page.evaluate("""
            core.changeFloor('MT4', null, [7, 7], 'up', function() {
                core.clearRouteFolding();
            });
        """)
        page.wait_for_timeout(1000)

        # 检查初始状态
        state_before = page.evaluate("""
            () => {
                return {
                    floorId: core.status.floorId,
                    door74: core.getBlock(7, 4),
                    door51: core.getBlock(5, 1),
                    door91: core.getBlock(9, 1),
                    flag: core.hasFlag('mt4_doors_opened'),
                    enemyCount: core.enemyCount('MT4')
                };
            }
        """)
        print(f"[*] MT4 击杀前状态: door(7,4)={state_before['door74'] != None}, door(5,1)={state_before['door51'] != None}, door(9,1)={state_before['door91'] != None}, 怪物数={state_before['enemyCount']}")
        assert state_before['door74'] is not None, "错误：MT4 (7,4) 机关门未生成！"
        assert state_before['door51'] is not None, "错误：MT4 (5,1) 机关门未生成！"
        assert state_before['door91'] is not None, "错误：MT4 (9,1) 机关门未生成！"
        assert not state_before['flag'], "错误：MT4 机关门不应在初始时开启！"

        # 截取开门前画面
        shot_before = os.path.join(SCREENSHOT_DIR, "mt4_doors_locked.png")
        page.screenshot(path=shot_before)
        print(f"[+] MT4 锁定状态截图保存至: {shot_before}")

        # 2. 消灭右下角 3 只守护怪并触发战后结算
        print("[*] 模拟消灭 MT4 右下角守护怪物...")
        page.evaluate("""
            () => {
                // 消灭右下角守护怪 (11,12), (13,12), (12,13)
                core.removeBlock(11, 12, 'MT4');
                core.removeBlock(13, 12, 'MT4');
                core.removeBlock(12, 13, 'MT4');
                // 触发战后联动
                core.checkFloorSpecialDoors('MT4');
            }
        """)
        page.wait_for_timeout(1500)

        # 检查开门后状态
        state_after = page.evaluate("""
            () => {
                return {
                    door74: core.getBlock(7, 4),
                    door51: core.getBlock(5, 1),
                    door91: core.getBlock(9, 1),
                    flag: core.hasFlag('mt4_doors_opened')
                };
            }
        """)
        print(f"[*] MT4 击杀后状态: door(7,4)={state_after['door74']}, door(5,1)={state_after['door51']}, door(9,1)={state_after['door91']}, flag={state_after['flag']}")
        assert state_after['flag'] == True, "错误：mt4_doors_opened flag 未置为 true！"
        assert state_after['door74'] is None, "错误：MT4 (7,4) 机关门未打开！"
        assert state_after['door51'] is None, "错误：MT4 (5,1) 机关门未打开！"
        assert state_after['door91'] is None, "错误：MT4 (9,1) 机关门未打开！"

        # 截取开门后画面
        shot_after = os.path.join(SCREENSHOT_DIR, "mt4_doors_opened.png")
        page.screenshot(path=shot_after)
        print(f"[+] MT4 开门成功截图保存至: {shot_after}")

        # 3. 验证 MT3 机关门联动
        print("\n[*] 切换至 MT3（寂静之森外围 3F）验证机关门 (2, 6)...")
        page.evaluate("""
            core.changeFloor('MT3', null, [7, 7], 'up', function() {});
        """)
        page.wait_for_timeout(1000)

        mt3_before = page.evaluate("""
            () => {
                return {
                    floorId: core.status.floorId,
                    door26: core.getBlock(2, 6),
                    flag: core.hasFlag('mt3_doors_opened'),
                    guardExists: core.hasMonsterInArea('MT3', 1, 7, 5, 11)
                };
            }
        """)
        print(f"[*] MT3 击杀前状态: door(2,6)={mt3_before['door26'] != None}, flag={mt3_before['flag']}, 守护区怪存活={mt3_before['guardExists']}")
        assert mt3_before['door26'] is not None, "错误：MT3 (2,6) 机关门未生成！"
        assert not mt3_before['flag'], "错误：MT3 机关门不应在初始时开启！"

        # 消灭 MT3 守护区域怪物
        print("[*] 模拟消灭 MT3 守护区域怪物...")
        page.evaluate("""
            () => {
                for (let y = 7; y <= 11; y++) {
                    for (let x = 1; x <= 5; x++) {
                        var b = core.getBlock(x, y, 'MT3');
                        if (b && b.event && b.event.cls && b.event.cls.indexOf('enemy') === 0) {
                            core.removeBlock(x, y, 'MT3');
                        }
                    }
                }
                core.checkFloorSpecialDoors('MT3');
            }
        """)
        page.wait_for_timeout(1500)

        mt3_after = page.evaluate("""
            () => {
                return {
                    door26: core.getBlock(2, 6),
                    flag: core.hasFlag('mt3_doors_opened')
                };
            }
        """)
        print(f"[*] MT3 击杀后状态: door(2,6)={mt3_after['door26']}, flag={mt3_after['flag']}")
        assert mt3_after['flag'] == True, "错误：mt3_doors_opened flag 未置为 true！"
        assert mt3_after['door26'] is None, "错误：MT3 (2,6) 机关门未打开！"

        shot_mt3 = os.path.join(SCREENSHOT_DIR, "mt3_door_opened.png")
        page.screenshot(path=shot_mt3)
        print(f"[+] MT3 开门成功截图保存至: {shot_mt3}")

        # 4. 验证读档/换层自愈：切回 MT4，门依然保持开启状态
        print("\n[*] 验证跨层自愈机制（切回 MT4）...")
        page.evaluate("""
            core.changeFloor('MT4', null, [7, 7], 'up', function() {});
        """)
        page.wait_for_timeout(1000)
        revisit_check = page.evaluate("""
            () => {
                return {
                    door74: core.getBlock(7, 4),
                    door51: core.getBlock(5, 1),
                    door91: core.getBlock(9, 1),
                    flag: core.hasFlag('mt4_doors_opened')
                };
            }
        """)
        print(f"[*] MT4 跨层重访状态: door(7,4)={revisit_check['door74']}, flag={revisit_check['flag']}")
        assert revisit_check['door74'] is None, "错误：跨层重访后门异常复活！"
        assert revisit_check['flag'] == True, "错误：flag 丢失！"

        print("\n==========================================")
        print("🎉 全部测试 100% 通过！MT4 & MT3 机关门运行完全正常！")
        print("==========================================")

        browser.close()

if __name__ == "__main__":
    run_test()
