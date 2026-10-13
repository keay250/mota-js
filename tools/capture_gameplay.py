# -*- coding: utf-8 -*-
"""
Playwright 自动化截图脚本（通过 evaluate 直接调用 core 接口）：
"""
import time
from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    page = browser.new_page(viewport={"width": 1280, "height": 800})
    
    print("[*] 正在访问 http://127.0.0.1:3000 ...")
    page.goto("http://127.0.0.1:3000", wait_until="networkidle")
    time.sleep(2)
    
    # 打印游戏版本和加载状态
    version = page.evaluate("() => main.version")
    print(f"[*] 当前客户端版本: {version}")
    
    # 直接调用 core 启动游戏
    print("[*] 正在调用 core.startGame('Easy') 启动游戏...")
    page.evaluate("() => { core.startGame('Easy'); }")
    time.sleep(1.5)
    
    # 按空格跳过开场剧情
    print("[*] 跳过剧情...")
    for _ in range(15):
        page.keyboard.press("Space")
        time.sleep(0.15)
        
    time.sleep(1.0)
    
    # 截取全屏和游戏核心区域
    page.screenshot(path="preview_game_full.png")
    print("[*] preview_game_full.png 已生成")
    
    game_group = page.locator("#gameGroup")
    if game_group.is_visible():
        game_group.screenshot(path="preview_game_group.png")
        print("[*] preview_game_group.png 已生成")
        
    browser.close()
    print("[*] 测试完成！")
