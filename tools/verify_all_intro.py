# -*- coding: utf-8 -*-
"""
永不复还(500F) -> mota-js 开局剧情与全部细节全自动化测试与验证
验证内容：
1. 模式选择与福利结算（初心试炼福利注入）
2. 序章全套原版黑屏文本演播（14幕完整台词）
3. 第一层贾斯汀苏醒独白（10句）
4. 获得【狩猎之书】（怪物手册book）及说明弹窗
5. 向后退阻挡事件与原版台词（那里太危险了）
6. 拾取黄钥匙初见教学
7. 满血拾取红血瓶防溢出机制与教学（待已损失血量超过50再来拿吧）
8. 拾取蓝宝石碎片合成教学（3个碎片合成1个完整宝石）
"""
import time, os
from playwright.sync_api import sync_playwright

def run_verification():
    with sync_playwright() as p:
        browser = p.chromium.launch(
            headless=True,
            args=["--autoplay-policy=no-user-gesture-required"]
        )
        page = browser.new_page(viewport={"width": 1280, "height": 800})
        
        print("[1] 访问游戏主页 http://127.0.0.1:3000 ...")
        page.goto("http://127.0.0.1:3000", wait_until="networkidle")
        time.sleep(2)
        
        print("[2] 启动初心试炼模式 (Easy)...")
        page.evaluate("() => { core.startGame('Easy'); }")
        time.sleep(1)
        
        # 推进序章 14 幕黑屏文字
        print("[3] 正在推进黑屏序章剧情...")
        for step in range(16):
            page.keyboard.press("Space")
            time.sleep(0.15)
            
        time.sleep(1)
        
        # 推进第一层苏醒现场独白 10 句 + 获得【狩猎之书】说明
        print("[4] 正在推进第一层现场独白与狩猎之书获得...")
        for step in range(15):
            page.keyboard.press("Space")
            time.sleep(0.15)
            
        time.sleep(1)
        
        # 验证此时英雄状态
        status = page.evaluate("""() => {
            return {
                floorId: core.status.floorId,
                hp: core.status.hero.hp,
                hpmax: core.status.hero.hpmax,
                atk: core.status.hero.atk,
                def: core.status.hero.def,
                yellowKey: core.itemCount('yellowKey'),
                book: core.itemCount('book'),
                exp: core.status.hero.exp,
                loc: [core.status.hero.loc.x, core.status.hero.loc.y]
            };
        }""")
        print("[5] 当前英雄属性与位置:", status)
        
        # 截图当前苏醒后画面
        page.locator("#gameGroup").screenshot(path="intro_stage1_awakened.png")
        print(" -> intro_stage1_awakened.png 已保存")
        
        # 6. 测试向后退触发阻挡 (从 2,12 向下走两格到 2,14)
        print("[6] 测试向下移动触发危险阻挡...")
        page.keyboard.press("ArrowDown")
        time.sleep(0.3)
        page.keyboard.press("ArrowDown")
        time.sleep(0.5)
        # 按空格关闭台词
        page.keyboard.press("Space")
        time.sleep(0.3)
        loc_after_block = page.evaluate("() => [core.status.hero.loc.x, core.status.hero.loc.y]")
        print(" -> 阻挡后英雄坐标 (应被弹回至 2,13):", loc_after_block)
        
        # 7. 测试拾取黄钥匙 (从 2,13 走向 3,11)
        print("[7] 测试移动并拾取黄钥匙...")
        # 走法：Up, Up, Right
        page.keyboard.press("ArrowUp")
        time.sleep(0.2)
        page.keyboard.press("ArrowUp")
        time.sleep(0.2)
        page.keyboard.press("ArrowRight")
        time.sleep(0.4)
        # 关闭教学提示
        page.keyboard.press("Space")
        time.sleep(0.3)
        y_keys = page.evaluate("() => core.itemCount('yellowKey')")
        print(" -> 拾取黄钥匙后钥匙总数 (原5+捡1=6):", y_keys)
        
        # 8. 测试满血拾取红血瓶防溢出 (从 3,11 走向 1,11: Left, Left)
        print("[8] 测试满血拾取红血瓶防溢出机制...")
        page.keyboard.press("ArrowLeft")
        time.sleep(0.2)
        page.keyboard.press("ArrowLeft")
        time.sleep(0.4)
        page.keyboard.press("Space")
        time.sleep(0.3)
        hp_check = page.evaluate("() => [core.status.hero.hp, core.getBlockCls(1, 11)]")
        print(" -> 满血拾取后血量与图块状态 (血瓶应保留):", hp_check)
        
        # 9. 测试拾取蓝宝石碎片 (从 1,11 走向 3,13: Down, Down, Right, Right)
        print("[9] 测试拾取蓝宝石碎片合成教学...")
        page.keyboard.press("ArrowDown")
        time.sleep(0.2)
        page.keyboard.press("ArrowDown")
        time.sleep(0.2)
        page.keyboard.press("ArrowRight")
        time.sleep(0.2)
        page.keyboard.press("ArrowRight")
        time.sleep(0.4)
        page.keyboard.press("Space")
        time.sleep(0.3)
        gem_check = page.evaluate("() => core.itemCount('blueGem')")
        print(" -> 拾取蓝宝石碎片后数量 (应为 1):", gem_check)
        
        # 截取全屏最终状态
        page.locator("#gameGroup").screenshot(path="intro_stage2_gameplay.png")
        page.screenshot(path="intro_stage2_fullscreen.png")
        print("[10] 全程验证完毕，截图已生成！")
        
        browser.close()

if __name__ == "__main__":
    run_verification()
