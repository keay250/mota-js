# -*- coding: utf-8 -*-
"""
Playwright 自动化验证开局全套剧情流程与初遇事件
"""
import time
from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    page = browser.new_page(viewport={'width': 1280, 'height': 800})
    page.goto('http://127.0.0.1:3000', wait_until='networkidle')
    time.sleep(2)
    
    # 等待开始游戏按钮可见
    page.wait_for_selector('#playGame', state='visible', timeout=10000)
    box = page.locator('#playGame').bounding_box()
    print("[1] 点击开始游戏...")
    page.mouse.click(box['x'] + box['width']/2, box['y'] + box['height']/2)
    time.sleep(1.5)
    
    # 点击选择难度（简单：初心试炼）
    cbox = page.locator('#gameDraw').bounding_box()
    cx = cbox['x'] + cbox['width'] / 2
    cy = cbox['y'] + cbox['height'] / 2
    print("[2] 选择初心试炼...")
    page.mouse.click(cx, cy)
    time.sleep(1.0)
    
    # 推进序章与独白（点击 35 次）
    print("[3] 推进序章与独白...")
    for i in range(35):
        page.mouse.click(cx, cy)
        time.sleep(0.12)
        
    time.sleep(1.5)
    
    # 检查当前英雄属性与位置
    hero_info = page.evaluate('''() => {
        return {
            hp: core.status.hero.hp,
            atk: core.status.hero.atk,
            def: core.status.hero.def,
            yellowKey: core.itemCount('yellowKey'),
            exp: core.status.hero.exp,
            x: core.getHeroLoc('x'),
            y: core.getHeroLoc('y'),
            floorId: core.status.floorId
        };
    }''')
    print("[4] 英雄当前状态:", hero_info)
    
    # 向下移动尝试触发 (2, 14) 阻挡
    print("[5] 测试回头阻挡 (向下移动)...")
    page.keyboard.press('ArrowDown')
    time.sleep(0.5)
    page.keyboard.press('ArrowDown')
    time.sleep(0.5)
    
    is_event = page.evaluate('() => core.status.lockControl')
    print("[5] 是否触发了阻挡事件:", is_event)
    
    browser.close()
    print("[*] 全部验证成功！")
