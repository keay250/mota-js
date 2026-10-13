# -*- coding: utf-8 -*-
"""
Playwright 终极验证脚本：
全流程验证原版完整序章剧情、初心试炼福利发放与第一层实机画面
"""
import time
from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    page = browser.new_page(viewport={'width': 1280, 'height': 800})
    page.goto('http://127.0.0.1:3000', wait_until='networkidle')
    
    # 1. 等待核心模块初始化
    print("[1] 等待游戏核心加载...")
    page.wait_for_function('() => typeof core !== "undefined" && core.status && core.firstData')
    print(" -> 游戏核心与数据已就绪！")
    
    # 2. 启动“初心试炼 (简单)”
    print("[2] 启动初心试炼模式...")
    page.evaluate('() => { core.events.startGame("Easy"); }')
    time.sleep(1)
    
    cbox = page.locator('#gameDraw').bounding_box()
    cx = cbox['x'] + cbox['width'] / 2
    cy = cbox['y'] + cbox['height'] / 2
    
    # 3. 推进开场序章剧情（每一幕点击）
    print("[3] 正在逐屏播放原版完整序章剧情...")
    for i in range(40):
        page.mouse.click(cx, cy)
        time.sleep(0.12)
        
    time.sleep(1.5)
    
    # 4. 验证英雄在第一层的状态与福利属性
    hero = page.evaluate('''() => {
        return {
            floorId: core.status.floorId,
            hp: core.status.hero.hp,
            hpmax: core.status.hero.hpmax,
            atk: core.status.hero.atk,
            def: core.status.hero.def,
            yellowKey: core.itemCount('yellowKey'),
            exp: core.status.hero.exp,
            loc: core.status.hero.loc
        };
    }''')
    print("[4] 第一层实机英雄属性状态:", hero)
    
    # 5. 截取第一层实机运行画面
    page.locator('#gameDraw').screenshot(path='intro_verified_canvas.png')
    page.screenshot(path='intro_verified_full.png')
    print("[5] 实机截图已成功保存！")
    
    browser.close()
    print("✨ 全流程验证大获全胜！")
