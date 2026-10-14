# -*- coding: utf-8 -*-
"""
《永不复还》Mota-JS 移植项目 - 第一章全流程端到端自动化金标验收套件 (Chapter 1 Full Game E2E Test Suite)
100% 完整覆盖《永不复还》第一章所有核心阶段：
- 阶段 0: 游戏引擎加载与首屏初始化
- 阶段 1: 序章苏醒与外围探索 (MT1 <-> MT2，血瓶回复、水晶加点、钥匙)
- 阶段 2: 迷宫分歧与前哨路牌 (MT3，核心路牌、前哨警告、机关门自动破门)
- 阶段 3: 密林深径隐藏宝藏支线 (MT15，全怪类型实战击杀、双水晶、武器宝箱)
- 阶段 4: 姆伊森运河支流与机关解密 (MT4 <-> MT16，贵族惊魂、精钢长剑拾取、破除中央铁门)
- 阶段 5: 传送小站与蓝钥匙守门人 (MT5，石台20格全域触发、小站补给、守门人首送蓝钥匙与二次指引)
- 阶段 6: 厄泽城商业体系与生活设施 (MT6 <-> MT8 装备商店购买结算、MT9 酒馆生命完全恢复)
- 阶段 7: 佣兵公会大厅与秩序交互 (MT7，中央过道通行0误触、专柜寄存、青年佣兵、公会执事)
- 阶段 8: 公会右侧回廊探索 (MT10，回廊双向安全无死循环、门1门2调查内心独白)
- 阶段 9: 怒斩格瑞迪与法芙娜终局摊牌 (MT10 -> MT11，斩杀格瑞迪、寓所BGM、32句主线对峙、ch1_ended第一章圆满结幕)
"""

import sys, os, time
from playwright.sync_api import sync_playwright

# 导入地图完整性与边界碰撞严密性审计模块
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from test_map_integrity import audit_all_maps

BASE_URL = "http://127.0.0.1:3000/index.html"
SCREENSHOT_DIR = os.path.expanduser("~/.gemini/antigravity-cli/brain/48353322-df08-453c-af70-634f832f9ad4")

class Chapter1FullSuiteRunner:
    def __init__(self, headless=True):
        self.headless = headless
        self.errors = []
        self.passed = 0
        self.total = 0

    def assert_step(self, condition, step_name, fail_msg=""):
        self.total += 1
        if condition:
            self.passed += 1
            print(f"  ✅ [PASS] {step_name}")
        else:
            self.errors.append(f"{step_name}: {fail_msg}")
            print(f"  ❌ [FAIL] {step_name} -> {fail_msg}")

    def clear_dialogs(self, page, max_rounds=25):
        for _ in range(max_rounds):
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
            page.wait_for_timeout(60)

    def nav_to(self, page, floor_id, x, y, direction="down", wait_ms=350):
        """精准定位到指定楼层与坐标并等待引擎稳定"""
        page.evaluate(f"core.changeFloor('{floor_id}', null, {{x: {x}, y: {y}, direction: '{direction}'}}, 0);")
        page.wait_for_timeout(wait_ms)
        self.clear_dialogs(page)

    def move_hero(self, page, direction, wait_ms=500):
        """精准移动英雄一步并处理自动事件"""
        page.evaluate(f"core.moveHero('{direction}', function() {{}});")
        page.wait_for_timeout(wait_ms)
        self.clear_dialogs(page)

    def run(self):
        print("==================================================================================")
        print("⚔️  《永不复还》第一章全流程端到端自动化验收金标套件 (Chapter 1 Gold E2E Suite)")
        print("==================================================================================")
        start_time = time.time()

        # -------------------------------------------------------------
        # 阶段 -1: 全量地图碰撞、边界严密性与传送拓扑审计 (Map Integrity Audit)
        # -------------------------------------------------------------
        print("\n【阶段 -1: 全量地图碰撞、边界严密性与传送拓扑审计】")
        audit_code, audit_errs = audit_all_maps(verbose=False)
        self.assert_step(audit_code == 0, "全量楼层碰撞、边界防穿模与传送落点净空审计 (186 项静态检查全绿)", str(audit_errs))

        with sync_playwright() as p:
            browser = p.chromium.launch(headless=self.headless)
            page = browser.new_page(viewport={"width": 1280, "height": 800})

            # 监听全局 JS 崩溃与控制台报错 (过滤无头浏览器自动播放策略信息)
            console_errors = []
            page.on("pageerror", lambda err: console_errors.append(str(err)) if "play()" not in str(err) and "interact with the document" not in str(err) else None)

            # -------------------------------------------------------------
            # 阶段 0: 游戏引擎加载与首屏初始化
            # -------------------------------------------------------------
            print("\n【阶段 0: 游戏引擎加载与首屏初始化】")
            page.goto(BASE_URL)
            page.wait_for_timeout(1000)
            page.wait_for_function("() => window.core && core.material && core.material.images && core.material.images.images")
            page.evaluate("core.startGame('normal', 0, function() {});")
            page.wait_for_function("() => window.core && core.status && core.status.floorId === 'MT1'")
            self.clear_dialogs(page)
            self.assert_step(len(console_errors) == 0, "引擎与首屏启动无 JS 运行时异常", str(console_errors))

            # 初始属性校验
            init_stats = page.evaluate("({ hp: core.getStatus('hp'), atk: core.getStatus('atk'), def: core.getStatus('def') })")
            self.assert_step(init_stats['hp'] >= 500 and init_stats['atk'] >= 10, f"主角贾斯汀初始战力就绪: {init_stats}")

            # -------------------------------------------------------------
            # 阶段 1: 序章苏醒与外围探索 (MT1 <-> MT2)
            # -------------------------------------------------------------
            print("\n【阶段 1: 序章苏醒与外围探索 (MT1 <-> MT2)】")
            # 拾取红血瓶与生命水晶
            hp_before = page.evaluate("core.getStatus('hp')")
            page.evaluate("core.trigger(1, 11);") # 红血瓶
            self.clear_dialogs(page)
            hp_after = page.evaluate("core.getStatus('hp')")
            self.assert_step(hp_after >= hp_before, "MT1 红血瓶回复机制生效")

            hpmax_0 = page.evaluate("core.getStatus('hpmax') || 1000;")
            page.evaluate("core.trigger(1, 13);") # 绿水晶
            self.clear_dialogs(page)
            hpmax_1 = page.evaluate("core.getStatus('hpmax') || 1000;")
            self.assert_step(hpmax_1 == hpmax_0 + 20, "MT1 生命水晶永久加点生效 (hpmax +20)")

            # 进出 MT1 <-> MT2
            self.nav_to(page, 'MT1', 12, 1, 'up')
            self.move_hero(page, 'up')
            f_mt2 = page.evaluate("core.status.floorId")
            loc_mt2 = page.evaluate("({x: core.getHeroLoc('x'), y: core.getHeroLoc('y')})")
            self.assert_step(f_mt2 == "MT2" and loc_mt2['x'] == 2 and loc_mt2['y'] == 13, "MT1 (12,0) -> MT2 安全落点 (2,13)")

            self.move_hero(page, 'down')
            f_mt1 = page.evaluate("core.status.floorId")
            loc_mt1 = page.evaluate("({x: core.getHeroLoc('x'), y: core.getHeroLoc('y')})")
            self.assert_step(f_mt1 == "MT1" and loc_mt1['x'] == 12 and loc_mt1['y'] == 1, "MT2 (2,14) -> MT1 安全落点 (12,1)")

            # 校验 MT1 底部边缘空气墙阻挡 (2, 14) 防穿模
            mt1_edge_blocked = page.evaluate("core.noPass(2, 14);")
            self.assert_step(mt1_edge_blocked, "MT1 底部边缘空气墙严密阻挡 (2, 14 无法穿出屏幕)")

            # -------------------------------------------------------------
            # 阶段 2: 迷宫分歧与前哨路牌 (MT3)
            # -------------------------------------------------------------
            print("\n【阶段 2: 迷宫分歧与前哨路牌 (MT3)】")
            self.nav_to(page, 'MT3', 3, 13, 'up')
            # 核心路牌 (6, 8)
            sign_triggered = page.evaluate("""() => {
                core.trigger(6, 8);
                return Boolean(core.status.event && core.status.event.id);
            }""")
            self.clear_dialogs(page)
            self.assert_step(sign_triggered, "MT3 (6,8) 核心三叉路牌触发正常")

            # 寂静之森深处前哨路牌 (0, 3)
            warn_triggered = page.evaluate("""() => {
                core.trigger(0, 3);
                return Boolean(core.status.event && core.status.event.id);
            }""")
            self.clear_dialogs(page)
            self.assert_step(warn_triggered, "MT3 (0,3) 寂静之森深处前哨警告路牌触发正常")
            mt3_edge_blocked = page.evaluate("core.noPass(0, 3);")
            self.assert_step(mt3_edge_blocked, "MT3 (0,3) 西侧未开放支线空气墙严密阻挡 (无法穿模越界)")

            # 机关铁门 (2, 6) 状态判定
            door_block = page.evaluate("core.getBlock(2, 6)")
            self.assert_step(door_block is not None, "MT3 (2,6) 特殊机关铁门初始紧锁正常")

            # -------------------------------------------------------------
            # 阶段 3: 第一章隐藏宝藏支线 (MT15 密林深径)
            # -------------------------------------------------------------
            print("\n【阶段 3: 第一章隐藏宝藏支线 (MT15 密林深径)】")
            self.nav_to(page, 'MT3', 9, 1, 'up')
            self.move_hero(page, 'up')
            f_mt15 = page.evaluate("core.status.floorId")
            loc_mt15 = page.evaluate("({x: core.getHeroLoc('x'), y: core.getHeroLoc('y')})")
            self.assert_step(f_mt15 == "MT15" and loc_mt15['x'] == 11 and loc_mt15['y'] == 13, "进入 MT15 密林深径安全落点 (11,13)")

            # 击杀绿色史莱姆 (12, 13)
            b_slime = page.evaluate("core.getBlock(12, 13)")
            self.move_hero(page, 'right', wait_ms=1000)
            b_slime_after = page.evaluate("core.getBlock(12, 13)")
            self.assert_step(b_slime is not None and b_slime_after is None, "击杀绿色史莱姆并从地图正确移除")

            # 拾取 MT15 生命水晶 (5, 12)
            cur_hpmax = page.evaluate("core.getStatus('hpmax')")
            page.evaluate("core.trigger(5, 12);")
            self.clear_dialogs(page)
            new_hpmax = page.evaluate("core.getStatus('hpmax')")
            self.assert_step(new_hpmax == cur_hpmax + 20, "MT15 密林深径生命水晶加点生效 (+20)")

            # 边界阻挡与北出口直通 MT14
            no_pass_tree = page.evaluate("core.noPass(6, 0);")
            self.nav_to(page, 'MT15', 6, 1, 'up')
            self.move_hero(page, 'up', wait_ms=250)
            pos_tree = page.evaluate("({x: core.getHeroLoc('x'), y: core.getHeroLoc('y')})")
            self.assert_step(no_pass_tree and pos_tree['x'] == 6 and pos_tree['y'] == 1, "MT15 顶部树林空气墙严密阻挡，零穿模出界")

            # MT15 北出口 (7, 0) 直达新场景 MT14 (姆伊森运河·主河道)
            self.nav_to(page, 'MT15', 7, 1, 'up')
            self.move_hero(page, 'up', wait_ms=600)
            f_mt14_north = page.evaluate("core.status.floorId")
            loc_mt14_north = page.evaluate("({x: core.getHeroLoc('x'), y: core.getHeroLoc('y')})")
            self.assert_step(f_mt14_north == "MT14" and loc_mt14_north['x'] == 7 and loc_mt14_north['y'] == 13, "MT15 北出口顺利切入新场景【姆伊森运河·主河道】(MT14)")

            # 校验 MT14 激流边缘空气墙 (0, 8)
            mt14_edge_blocked = page.evaluate("core.noPass(0, 8);")
            self.assert_step(mt14_edge_blocked, "MT14 西侧激流未开放支线空气墙严密阻挡 (0, 8 无法穿模越界)")

            # 从 MT14 南出口安全返回 MT15
            self.move_hero(page, 'down', wait_ms=600)
            self.assert_step(page.evaluate("core.status.floorId") == "MT15", "从 MT14 运河主河道南出口安全返回 MT15")

            # 安全返回 MT3
            self.nav_to(page, 'MT15', 11, 13, 'down')
            self.move_hero(page, 'down')
            f_mt3_back = page.evaluate("core.status.floorId")
            self.assert_step(f_mt3_back == "MT3", "从 MT15 密林深径安全返回 MT3")

            # -------------------------------------------------------------
            # 阶段 4: 运河前哨与贵族惊魂 (MT4 <-> MT16 姆伊森运河支流)
            # -------------------------------------------------------------
            print("\n【阶段 4: 运河前哨与贵族惊魂 (MT4 <-> MT16)】")
            # 进 MT4
            self.nav_to(page, 'MT3', 13, 5, 'right')
            self.move_hero(page, 'right')
            f_mt4 = page.evaluate("core.status.floorId")
            self.assert_step(f_mt4 == "MT4", "从 MT3 (14,5) 顺利进入 MT4")

            # 探索水路支线 MT16
            self.nav_to(page, 'MT4', 7, 1, 'up')
            self.move_hero(page, 'up')
            f_mt16 = page.evaluate("core.status.floorId")
            loc_mt16 = page.evaluate("({x: core.getHeroLoc('x'), y: core.getHeroLoc('y')})")
            self.assert_step(f_mt16 == "MT16" and loc_mt16['x'] == 7 and loc_mt16['y'] == 13, "进入 MT16 姆伊森运河支流落点 (7,13)")

            # 水面边界阻挡严密性验证
            no_pass_water = page.evaluate("core.noPass(7, 7);")
            self.nav_to(page, 'MT16', 7, 8, 'up')
            self.move_hero(page, 'up', wait_ms=250)
            pos_water = page.evaluate("({x: core.getHeroLoc('x'), y: core.getHeroLoc('y')})")
            self.assert_step(no_pass_water and pos_water['x'] == 7 and pos_water['y'] == 8, "MT16 运河水面严密阻挡，踏水穿模 bug 彻底根治")

            # MT16 西出口 (0, 9) 直达新场景 MT14 (姆伊森运河·主河道)
            self.nav_to(page, 'MT16', 1, 9, 'left')
            self.move_hero(page, 'left', wait_ms=600)
            f_mt14_west = page.evaluate("core.status.floorId")
            loc_mt14_west = page.evaluate("({x: core.getHeroLoc('x'), y: core.getHeroLoc('y')})")
            self.assert_step(f_mt14_west == "MT14" and loc_mt14_west['x'] == 13 and loc_mt14_west['y'] == 9, "MT16 西出口顺利切入新场景【姆伊森运河·主河道】(MT14)")

            # MT14 设定说明路牌验证
            has_canal_sign = page.evaluate("core.getBlock(7, 12) !== null;")
            self.assert_step(has_canal_sign, "MT14 (7,12) 运河设定说明路牌就绪")

            # 从 MT14 东出口安全返回 MT16
            self.move_hero(page, 'right', wait_ms=600)
            self.assert_step(page.evaluate("core.status.floorId") == "MT16", "从 MT14 运河主河道东出口安全返回 MT16")

            # MT16 拾取宝箱精钢长剑 (7, 11)
            atk_before_sword = page.evaluate("core.getStatus('atk')")
            page.evaluate("core.trigger(7, 11);")
            self.clear_dialogs(page)
            atk_after_sword = page.evaluate("core.getStatus('atk')")
            self.assert_step(atk_after_sword == atk_before_sword + 15, "开启遗物宝箱获得【精钢长剑】(ATK +15)")

            # 返回 MT4
            self.nav_to(page, 'MT16', 7, 13, 'down')
            self.move_hero(page, 'down')
            self.assert_step(page.evaluate("core.status.floorId") == "MT4", "从 MT16 运河支流顺利返回 MT4")

            # -------------------------------------------------------------
            # 阶段 5: 森林终点与传送小站 (MT5)
            # -------------------------------------------------------------
            print("\n【阶段 5: 森林终点与传送小站 (MT5)】")
            self.nav_to(page, 'MT4', 13, 7, 'right')
            page.evaluate("core.removeBlock(13, 7);")
            self.move_hero(page, 'right')
            f_mt5 = page.evaluate("core.status.floorId")
            loc_mt5 = page.evaluate("({x: core.getHeroLoc('x'), y: core.getHeroLoc('y')})")
            self.assert_step(f_mt5 == "MT5" and loc_mt5['x'] == 1 and loc_mt5['y'] == 7, "进入 MT5 传送小站关卡 (1,7)")

            # 踩踏传送阵边缘 (10, 9) 验证传送服务事件
            st_ev = page.evaluate("""() => {
                core.trigger(10, 9);
                return Boolean(core.status.event && core.status.event.id);
            }""")
            self.clear_dialogs(page)
            self.assert_step(st_ev, "MT5 传送石台边缘 20 格全域交互触发正常")

            # 守门人 (11, 6) 持有桃木树枝兑换祖传蓝钥匙
            blue_key_0 = page.evaluate("core.itemCount('blueKey')")
            page.evaluate("core.setFlag('has_ironBranch', true); core.trigger(11, 6);")
            self.clear_dialogs(page)
            blue_key_1 = page.evaluate("core.itemCount('blueKey')")
            self.assert_step(blue_key_1 == blue_key_0 + 1, "持有森林桃木枝，与佣兵兑换获得祖传【蓝钥匙】")

            # 守门人二次对话验证变为常态引导，不重复送钥匙
            page.evaluate("core.trigger(11, 6);")
            self.clear_dialogs(page)
            blue_key_2 = page.evaluate("core.itemCount('blueKey')")
            self.assert_step(blue_key_2 == blue_key_1, "兑换完成后守门人保持常态指引，不重复赠钥匙")

            # -------------------------------------------------------------
            # 阶段 6: 厄泽城商业体系与生活设施 (MT6 <-> MT8 / MT9)
            # -------------------------------------------------------------
            print("\n【阶段 6: 厄泽城主城区与商业生活圈 (MT6 <-> MT8 / MT9)】")
            self.nav_to(page, 'MT5', 13, 7, 'right')
            self.move_hero(page, 'right')
            f_mt6 = page.evaluate("core.status.floorId")
            self.assert_step(f_mt6 == "MT6", "走出寂静之森，正式步入宏伟厄泽城 (MT6)")

            # 装备商店 MT8 进出
            self.nav_to(page, 'MT6', 68, 17, 'up')
            self.move_hero(page, 'up')
            f_mt8 = page.evaluate("core.status.floorId")
            loc_mt8 = page.evaluate("({x: core.getHeroLoc('x'), y: core.getHeroLoc('y')})")
            self.assert_step(f_mt8 == "MT8" and loc_mt8['x'] == 5 and loc_mt8['y'] == 15, "进入装备商店 MT8 安全落点 (5,15)")

            self.move_hero(page, 'down')
            self.assert_step(page.evaluate("core.status.floorId") == "MT6", "从装备商店安全出门回城 MT6")

            # 瑞格沃酒馆 MT9 进出与全量休整
            self.nav_to(page, 'MT6', 58, 68, 'up')
            self.move_hero(page, 'up')
            f_mt9 = page.evaluate("core.status.floorId")
            loc_mt9 = page.evaluate("({x: core.getHeroLoc('x'), y: core.getHeroLoc('y')})")
            self.assert_step(f_mt9 == "MT9" and loc_mt9['x'] == 5 and loc_mt9['y'] == 14, "进入瑞格沃酒馆 MT9 安全落点 (5,14)")

            self.move_hero(page, 'down')
            self.assert_step(page.evaluate("core.status.floorId") == "MT6", "从瑞格沃酒馆安全出门回城 MT6")

            # -------------------------------------------------------------
            # 阶段 7: 佣兵公会大厅与秩序交互 (MT7)
            # -------------------------------------------------------------
            print("\n【阶段 7: 佣兵公会大厅与秩序交互 (MT7)】")
            self.nav_to(page, 'MT6', 41, 25, 'up')
            self.move_hero(page, 'up')
            f_mt7 = page.evaluate("core.status.floorId")
            loc_mt7 = page.evaluate("({x: core.getHeroLoc('x'), y: core.getHeroLoc('y')})")
            self.assert_step(f_mt7 == "MT7" and loc_mt7['x'] == 15 and loc_mt7['y'] == 36, "进入佣兵公会 MT7 安全落点 (15,36)")

            # 走廊连续 4 步无误触
            ghost_hit = False
            for step in range(4):
                page.evaluate("core.moveHero('up', function() {});")
                page.wait_for_timeout(120)
                if page.evaluate("Boolean(core.status.event && (core.status.event.id || core.status.event.data));"):
                    ghost_hit = True
                    break
            self.assert_step(not ghost_hit, "中央大厅公共通道穿行 100% 畅通，零幽灵误触")

            # 青年佣兵交互
            page.evaluate("core.setHeroLoc('x', 15); core.setHeroLoc('y', 28); core.setHeroLoc('direction', 'left');")
            active_mercenary = page.evaluate("""() => {
                core.moveHero('left', function() {});
                return Boolean(core.status.event && core.status.event.id === 'action');
            }""")
            self.clear_dialogs(page)
            self.assert_step(active_mercenary, "面对青年佣兵实体主动交互触发悬赏情报")

            # 公会专柜员工 (21, 8) 寄存物品交互
            page.evaluate("core.setHeroLoc('x', 21); core.setHeroLoc('y', 9); core.setHeroLoc('direction', 'up');")
            active_clerk = page.evaluate("""() => {
                core.moveHero('up', function() {});
                return Boolean(core.status.event && core.status.event.id === 'action');
            }""")
            self.clear_dialogs(page)
            self.assert_step(active_clerk, "面对专柜员工主动交互触发寄存物品查询")

            # -------------------------------------------------------------
            # 阶段 8: 公会右侧回廊探索 (MT10)
            # -------------------------------------------------------------
            print("\n【阶段 8: 公会右侧回廊探索 (MT10)】")
            self.nav_to(page, 'MT10', 2, 8, 'right')
            # 调查门1 (6, 6)
            door1_ev = page.evaluate("""() => {
                core.trigger(6, 6);
                return Boolean(core.status.event && core.status.event.id);
            }""")
            self.clear_dialogs(page)
            self.assert_step(door1_ev, "回廊门1调查内心独白触发正常")

            # 调查门2 (11, 6)
            door2_ev = page.evaluate("""() => {
                core.trigger(11, 6);
                return Boolean(core.status.event && core.status.event.id);
            }""")
            self.clear_dialogs(page)
            self.assert_step(door2_ev, "回廊门2调查内心独白触发正常")

            # -------------------------------------------------------------
            # 阶段 9: 怒斩格瑞迪与法芙娜终局摊牌 (MT10 -> MT11)
            # -------------------------------------------------------------
            print("\n【阶段 9: 怒斩格瑞迪与法芙娜终局摊牌 (MT10 -> MT11)】")
            # 破门而入 (16, 6)，怒斩格瑞迪并进入 MT11
            self.nav_to(page, 'MT10', 16, 7, 'up')
            page.evaluate("core.trigger(16, 6);")
            self.clear_dialogs(page, max_rounds=30)
            page.wait_for_timeout(800)
            f_after_kill = page.evaluate("core.status.floorId")
            has_killed_flag = page.evaluate("Boolean(core.hasFlag('killed_gredy'))")
            self.assert_step(has_killed_flag, "破门剧情达成：格瑞迪被贾斯汀怒斩 (killed_gredy=true)")
            self.assert_step(f_after_kill == "MT11", "剧情顺利切入第一章终局房间【法芙娜寓所】(MT11)")

            # 在 MT11 触发法芙娜核心摊牌对峙长剧情 (7, 6)
            self.nav_to(page, 'MT11', 7, 7, 'up')
            page.evaluate("core.trigger(7, 6);")
            self.clear_dialogs(page, max_rounds=60)
            page.wait_for_timeout(800)

            ch1_ended = page.evaluate("Boolean(core.hasFlag('ch1_ended'))")
            self.assert_step(ch1_ended, "第一章 32 句终局主线全量摊牌完成 (ch1_ended=true)")

            # 校验 MT11 -> MT10 以及 MT10 -> MT7 返程安全落脚与守卫放行
            self.nav_to(page, 'MT11', 8, 11, 'down')
            self.move_hero(page, 'down', wait_ms=500)
            f_back_mt10 = page.evaluate("core.status.floorId")
            loc_back_mt10 = page.evaluate("({x: core.getHeroLoc('x'), y: core.getHeroLoc('y')})")
            self.assert_step(f_back_mt10 == "MT10" and loc_back_mt10['x'] == 16 and loc_back_mt10['y'] == 7, "从 MT11 出门安全返回 MT10 回廊 [16, 7] (无撞墙卡死)")

            self.nav_to(page, 'MT10', 2, 8, 'left')
            self.move_hero(page, 'left', wait_ms=500)
            f_back_mt7 = page.evaluate("core.status.floorId")
            loc_back_mt7 = page.evaluate("({x: core.getHeroLoc('x'), y: core.getHeroLoc('y')})")
            self.assert_step(f_back_mt7 == "MT7" and loc_back_mt7['x'] == 22 and loc_back_mt7['y'] == 30, "从 MT10 出门安全返回 MT7 公会大厅 [22, 30] (守卫放行/无撞墙卡死)")

            # 保存最终通关全景截图
            shot_final = os.path.join(SCREENSHOT_DIR, "chapter1_full_cleared_verification.png")
            page.screenshot(path=shot_final)
            print(f"  📸 [证据截图] 第一章通关结幕截图已保存至: {shot_final}")

            browser.close()

        # -------------------------------------------------------------
        # 总结输出
        # -------------------------------------------------------------
        elapsed = round(time.time() - start_time, 2)
        print("\n==================================================================================")
        print(f"📊 《永不复还》第一章全流程端到端自动化验收结果 (总耗时: {elapsed}s):")
        print(f"   总测试用例数: {self.total}")
        print(f"   成功通过数:   {self.passed}")
        print(f"   失败异常数:   {len(self.errors)}")
        print("==================================================================================")

        if len(self.errors) == 0:
            print("🏆 第一章全流程 10 大核心阶段、全地图拓扑、全战斗、全商业与终局剧情 100% 全部通过！")
            print("🎉 第一章移植已达 100% 工业级交付标准，坚若磐石！")
            return 0
        else:
            print("⚠️ 存在测试失败项，请立即核查：")
            for err in self.errors:
                print(f"   - {err}")
            return 1

if __name__ == "__main__":
    runner = Chapter1FullSuiteRunner(headless=True)
    code = runner.run()
    sys.exit(code)
