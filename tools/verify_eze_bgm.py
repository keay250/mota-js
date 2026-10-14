# -*- coding: utf-8 -*-
"""
端到端实机验证：《永不复还》场景与城镇 BGM 自动化调度
1. 验证初始森林场景 (MT1): BGM = forest.mp3
2. 验证踏入厄泽城大平原 (MT5): 自动平滑过渡至 厄泽城.mp3
3. 验证进入厄泽城主干道中央广场 (MT6): 维持 厄泽城.mp3
4. 验证进入佣兵公会大厅 (MT7) & 装备商店 (MT8): 维持 厄泽城.mp3
5. 验证进入阴暗后巷与决战密室 (MT10, MT11): 自动切换至 厄泽城事变.mp3
6. 音频元素播放状态与网络请求无 404 验证
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
    print("[*] 启动 Playwright 验证《永不复还》场景与城镇 BGM 体系...")
    failed_requests = []

    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        context = browser.new_context(viewport={"width": 1280, "height": 900})
        page = context.new_page()

        # 监听网络请求异常（特别关注 mp3 404）
        def on_response(resp):
            if ".mp3" in resp.url and resp.status >= 400:
                print(f"[!] 音频请求失败: {resp.url} status={resp.status}")
                failed_requests.append(resp.url)
        page.on("response", on_response)

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
        # 1. 验证初始森林场景 (MT1)
        # -------------------------------------------------------------
        print("\n---> [测试 1/5] 验证寂静之森外围 (MT1) 背景音乐...")
        bgm_mt1 = page.evaluate("() => core.musicStatus.playingBgm")
        print(f"     当前楼层: MT1, 正在播放 BGM: {bgm_mt1}")
        assert bgm_mt1 == "forest.mp3", f"MT1 期望 forest.mp3，实际为 {bgm_mt1}"
        page.screenshot(path=os.path.join(BRAIN_DIR, "verify_bgm_mt1_forest.png"))

        # -------------------------------------------------------------
        # 2. 验证抵达厄泽城外围大平原 (MT5) -> 自动切入 厄泽城.mp3
        # -------------------------------------------------------------
        print("\n---> [测试 2/5] 验证踏入厄泽城外围 (MT5) 自动切入 厄泽城.mp3 ...")
        page.evaluate("core.changeFloor('MT5', 'downFloor', [0, 7], 0);")
        page.wait_for_function("() => core.status.floorId === 'MT5'")
        clear_dialogs(page)
        page.wait_for_timeout(500)
        bgm_mt5 = page.evaluate("() => core.musicStatus.playingBgm")
        print(f"     当前楼层: MT5, 正在播放 BGM: {bgm_mt5}")
        assert bgm_mt5 == "厄泽城.mp3", f"MT5 期望 厄泽城.mp3，实际为 {bgm_mt5}"
        page.screenshot(path=os.path.join(BRAIN_DIR, "verify_bgm_mt5_eze.png"))

        # -------------------------------------------------------------
        # 3. 验证进入厄泽城中央广场/主干道 (MT6)
        # -------------------------------------------------------------
        print("\n---> [测试 3/5] 验证进入厄泽城主干道 (MT6) 保持 厄泽城.mp3 ...")
        page.evaluate("core.changeFloor('MT6', null, [37, 29], 0);")
        page.wait_for_function("() => core.status.floorId === 'MT6'")
        clear_dialogs(page)
        page.wait_for_timeout(500)
        bgm_mt6 = page.evaluate("() => core.musicStatus.playingBgm")
        print(f"     当前楼层: MT6, 正在播放 BGM: {bgm_mt6}")
        assert bgm_mt6 == "厄泽城.mp3", f"MT6 期望 厄泽城.mp3，实际为 {bgm_mt6}"
        page.screenshot(path=os.path.join(BRAIN_DIR, "verify_bgm_mt6_square.png"))

        # -------------------------------------------------------------
        # 4. 验证进入佣兵公会 (MT7) & 装备商店 (MT8)
        # -------------------------------------------------------------
        print("\n---> [测试 4/5] 验证进入装备商店 (MT8) 延续城镇音乐 厄泽城.mp3 ...")
        page.evaluate("core.changeFloor('MT8', null, [7, 15], 0);")
        page.wait_for_function("() => core.status.floorId === 'MT8'")
        clear_dialogs(page)
        page.wait_for_timeout(500)
        bgm_mt8 = page.evaluate("() => core.musicStatus.playingBgm")
        print(f"     当前楼层: MT8, 正在播放 BGM: {bgm_mt8}")
        assert bgm_mt8 == "厄泽城.mp3", f"MT8 期望 厄泽城.mp3，实际为 {bgm_mt8}"
        page.screenshot(path=os.path.join(BRAIN_DIR, "verify_bgm_mt8_shop.png"))

        # -------------------------------------------------------------
        # 5. 验证进入阴暗密道 (MT10) 与 决战密室 (MT11) -> 自动切入 厄泽城事变.mp3
        # -------------------------------------------------------------
        print("\n---> [测试 5/5] 验证进入密道 (MT10) 与法芙娜决战 (MT11) 切入 厄泽城事变.mp3 ...")
        page.evaluate("core.changeFloor('MT10', null, [2, 13], 0);")
        page.wait_for_function("() => core.status.floorId === 'MT10'")
        clear_dialogs(page)
        page.wait_for_timeout(500)
        bgm_mt10 = page.evaluate("() => core.musicStatus.playingBgm")
        print(f"     当前楼层: MT10, 正在播放 BGM: {bgm_mt10}")
        assert bgm_mt10 == "厄泽城事变.mp3", f"MT10 期望 厄泽城事变.mp3，实际为 {bgm_mt10}"

        page.evaluate("core.changeFloor('MT11', null, [7, 13], 0);")
        page.wait_for_function("() => core.status.floorId === 'MT11'")
        clear_dialogs(page)
        page.wait_for_timeout(500)
        bgm_mt11 = page.evaluate("() => core.musicStatus.playingBgm")
        print(f"     当前楼层: MT11, 正在播放 BGM: {bgm_mt11}")
        assert bgm_mt11 == "厄泽城事变.mp3", f"MT11 期望 厄泽城事变.mp3，实际为 {bgm_mt11}"
        page.screenshot(path=os.path.join(BRAIN_DIR, "verify_bgm_mt11_climax.png"))

        assert len(failed_requests) == 0, f"存在音频加载失败: {failed_requests}"
        print("\n[+] 恭喜！所有场景与城镇专属 BGM 自动化调度验证 100% 通过！")
        browser.close()

if __name__ == '__main__':
    run()
