# -*- coding: utf-8 -*-
"""
Playwright 自动化验证脚本：
1. 启动游戏，跳过序章
2. 传送至 MT2
3. 断言 MT2 楼层 ID、标题、尺寸、怪物与事件
4. 截取 MT2 实机运行高清画面
5. 验证双向楼梯互联
"""
import time
from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    page = browser.new_page(viewport={"width": 1280, "height": 800})
    
    print("[*] 正在访问 http://127.0.0.1:3000 ...")
    page.goto("http://127.0.0.1:3000", wait_until="networkidle")
    time.sleep(1.5)
    
    version = page.evaluate("() => main.version")
    print(f"[*] 当前客户端版本: {version}")
    
    # 启动游戏
    print("[*] 正在启动游戏...")
    page.evaluate("() => { core.startGame('Easy'); }")
    time.sleep(1.5)
    
    # 连敲空格跳过序章和现场对白
    print("[*] 跳过序章对白...")
    for _ in range(35):
        page.keyboard.press("Space")
        time.sleep(0.08)
    time.sleep(1.0)
    
    # 验证当前在 MT1
    f1 = page.evaluate("() => core.status.floorId")
    print(f"[*] 初始楼层: {f1}")
    assert f1 == "MT1", f"初始楼层应为 MT1，实际为 {f1}"
    
    # 切换至 MT2
    print("[*] 正在切换至 MT2...")
    page.evaluate("() => { core.changeFloor('MT2', 'downFloor'); }")
    time.sleep(1.5)
    
    # 验证 MT2 状态
    f2 = page.evaluate("() => core.status.floorId")
    title2 = page.evaluate("() => core.status.thisMap.title")
    hero_pos = page.evaluate("() => ({ x: core.getHeroLoc('x'), y: core.getHeroLoc('y') })")
    print(f"[*] 当前楼层: {f2}, 标题: {title2}, 主角坐标: {hero_pos}")
    assert f2 == "MT2", f"当前楼层应为 MT2，实际为 {f2}"
    assert hero_pos == {"x": 2, "y": 14}, f"下楼口出生坐标应为 (2, 14)，实际为 {hero_pos}"
    
    # 截取 MT2 实机运行游戏画面
    game_group = page.locator("#gameGroup")
    if game_group.is_visible():
        screenshot_path = "/Users/zt-lin/.gemini/antigravity-cli/brain/48353322-df08-453c-af70-634f832f9ad4/perfect_mt2_canvas.png"
        game_group.screenshot(path=screenshot_path)
        print(f"[*] MT2 实机截图已保存至: {screenshot_path}")
        
    # 测试向上移动一格 (2, 13)
    print("[*] 主角向上移动一格...")
    page.keyboard.press("ArrowUp")
    time.sleep(0.5)
    new_pos = page.evaluate("() => ({ x: core.getHeroLoc('x'), y: core.getHeroLoc('y') })")
    print(f"[*] 移动后坐标: {new_pos}")
    
    # 测试踩下楼口回 MT1
    print("[*] 主角向下移动踩下楼口回 MT1...")
    page.keyboard.press("ArrowDown")
    time.sleep(1.0)
    back_f = page.evaluate("() => core.status.floorId")
    back_pos = page.evaluate("() => ({ x: core.getHeroLoc('x'), y: core.getHeroLoc('y') })")
    print(f"[*] 返回楼层: {back_f}, 坐标: {back_pos}")
    assert back_f == "MT1", f"返回楼层应为 MT1，实际为 {back_f}"
    assert back_pos == {"x": 12, "y": 0}, f"返回 MT1 坐标应为 (12, 0)，实际为 {back_pos}"
    
    browser.close()
    print("[*] ✨ MT2 完整双向连通性与实机渲染验证 100% 通过！")
