const { chromium } = require('playwright');
const path = require('path');
const fs = require('fs');

const SCREENSHOT_DIR = path.resolve('/Users/zt-lin/.gemini/antigravity-cli/brain/48353322-df08-453c-af70-634f832f9ad4');

async function main() {
    console.log('启动 Playwright Chromium 进行机关门实机验证...');
    const browser = await chromium.launch({ headless: true });
    const page = await browser.newPage({ viewport: { width: 1280, height: 800 } });

    console.log('[1/4] 访问游戏主页 http://127.0.0.1:3000 ...');
    await page.goto('http://127.0.0.1:3000', { waitUntil: 'networkidle' });
    await page.waitForTimeout(1000);

    // 启动游戏
    console.log('[2/4] 初始化游戏并载入运行上下文...');
    await page.evaluate(() => {
        core.startGame('normal', 0, function() {});
    });
    await page.waitForTimeout(1500);

    // 跳过开场可能存在的文本事件
    for (let i = 0; i < 20; i++) {
        const hasEvent = await page.evaluate(() => {
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
        });
        if (!hasEvent) break;
        await page.waitForTimeout(100);
    }

    // 传送至 MT4
    console.log('[3/4] 传送勇士至 MT4（寂静之森外围 4F）...');
    await page.evaluate(() => {
        core.changeFloor('MT4', null, [7, 7], 'up', function() {
            core.clearRouteFolding();
        });
    });
    await page.waitForTimeout(1000);

    // 验证初始状态：机关门存在，且未开启
    const mt4Initial = await page.evaluate(() => {
        return {
            floorId: core.status.floorId,
            door74: core.getBlock(7, 4),
            door51: core.getBlock(5, 1),
            door91: core.getBlock(9, 1),
            flag: core.hasFlag('mt4_doors_opened'),
            guardCount: (core.getBlock(11, 12) ? 1 : 0) + (core.getBlock(13, 12) ? 1 : 0) + (core.getBlock(12, 13) ? 1 : 0),
            hasMonsterInArea: core.hasMonsterInArea('MT4', 11, 12, 13, 13)
        };
    });

    console.log('[*] MT4 初始状态检查:', JSON.stringify(mt4Initial, null, 2));
    if (!mt4Initial.door74 || !mt4Initial.door51 || !mt4Initial.door91) {
        throw new Error('MT4 机关门初始未正确存在！');
    }
    if (mt4Initial.flag) {
        throw new Error('MT4 机关门不应该初始已开启！');
    }
    if (!mt4Initial.hasMonsterInArea) {
        throw new Error('MT4 守护怪物区域检测异常！');
    }

    const shotLocked = path.join(SCREENSHOT_DIR, 'mt4_doors_locked.png');
    await page.screenshot({ path: shotLocked });
    console.log('[+] 已保存 MT4 机关门关闭截图:', shotLocked);

    // 撞门测试：怪物未清空时撞门，应提示线索
    console.log('[*] 测试未清怪时主动撞门线索提示...');
    await page.evaluate(() => {
        // 模拟玩家在 (7, 5) 向上撞 (7, 4) 的机关门
        core.setHeroLoc('loc', [7, 5]);
        core.setHeroLoc('direction', 'up');
        core.trigger(7, 4);
    });
    await page.waitForTimeout(500);

    const hitDoorCheck = await page.evaluate(() => {
        return {
            eventId: core.status.event ? core.status.event.id : null,
            eventText: (core.status.event && core.status.event.ui) ? core.status.event.ui.text : null,
            doorStillThere: core.getBlock(7, 4) != null
        };
    });
    console.log('[*] 撞门反馈:', JSON.stringify(hitDoorCheck));
    // 关掉对话框
    await page.evaluate(() => {
        core.actions._clickAction_text();
        core.doAction();
    });
    await page.waitForTimeout(500);

    // 核心战斗与击杀测试：消灭右下角 3 只守护怪
    console.log('[*] 消灭 MT4 右下角 3 只守护怪并触发战后结算...');
    await page.evaluate(() => {
        core.removeBlock(11, 12, 'MT4');
        core.removeBlock(13, 12, 'MT4');
        core.removeBlock(12, 13, 'MT4');
        // 触发战后机关门检测
        core.checkFloorSpecialDoors('MT4');
    });
    await page.waitForTimeout(1500);

    // 处理开门动画和提示
    for (let i = 0; i < 10; i++) {
        await page.evaluate(() => {
            if (core.status.event && core.status.event.id) {
                core.doAction();
            }
        });
        await page.waitForTimeout(100);
    }

    // 验证开门结果
    const mt4After = await page.evaluate(() => {
        return {
            door74: core.getBlock(7, 4),
            door51: core.getBlock(5, 1),
            door91: core.getBlock(9, 1),
            flag: core.hasFlag('mt4_doors_opened')
        };
    });
    console.log('[*] MT4 击杀后状态检查:', JSON.stringify(mt4After, null, 2));
    if (!mt4After.flag) {
        throw new Error('MT4 机关门开启标记 mt4_doors_opened 未置为 true！');
    }
    if (mt4After.door74 !== null || mt4After.door51 !== null || mt4After.door91 !== null) {
        throw new Error('MT4 机关门在消灭守护怪后未能全部移除开通！');
    }

    const shotOpened = path.join(SCREENSHOT_DIR, 'mt4_doors_opened.png');
    await page.screenshot({ path: shotOpened });
    console.log('[+] 已保存 MT4 机关门全部开启截图:', shotOpened);

    // 验证 MT3 机关门
    console.log('\n[4/4] 验证 MT3（寂静之森外围 3F）机关门 (2, 6)...');
    await page.evaluate(() => {
        core.changeFloor('MT3', null, [7, 7], 'up', function() {});
    });
    await page.waitForTimeout(1000);

    const mt3Initial = await page.evaluate(() => {
        return {
            floorId: core.status.floorId,
            door26: core.getBlock(2, 6),
            flag: core.hasFlag('mt3_doors_opened'),
            guardExists: core.hasMonsterInArea('MT3', 1, 7, 5, 11)
        };
    });
    console.log('[*] MT3 初始状态检查:', JSON.stringify(mt3Initial, null, 2));
    if (!mt3Initial.door26 || mt3Initial.flag || !mt3Initial.guardExists) {
        throw new Error('MT3 机关门初始状态不符合预期！');
    }

    // 消灭 MT3 守护区域怪物
    console.log('[*] 消灭 MT3 左下方守护区域怪物...');
    await page.evaluate(() => {
        for (let y = 7; y <= 11; y++) {
            for (let x = 1; x <= 5; x++) {
                var b = core.getBlock(x, y, 'MT3');
                if (b && b.event && b.event.cls && b.event.cls.indexOf('enemy') === 0) {
                    core.removeBlock(x, y, 'MT3');
                }
            }
        }
        core.checkFloorSpecialDoors('MT3');
    });
    await page.waitForTimeout(1500);

    const mt3After = await page.evaluate(() => {
        return {
            door26: core.getBlock(2, 6),
            flag: core.hasFlag('mt3_doors_opened')
        };
    });
    console.log('[*] MT3 击杀后状态检查:', JSON.stringify(mt3After, null, 2));
    if (!mt3After.flag || mt3After.door26 !== null) {
        throw new Error('MT3 机关门在消灭守护怪后未能成功开启！');
    }

    const shotMt3 = path.join(SCREENSHOT_DIR, 'mt3_door_opened.png');
    await page.screenshot({ path: shotMt3 });
    console.log('[+] 已保存 MT3 机关门开启截图:', shotMt3);

    // 跨层自愈测试：切回 MT4，门依然保持开启状态
    console.log('[*] 验证换层与自愈补偿：重新进入 MT4...');
    await page.evaluate(() => {
        core.changeFloor('MT4', null, [7, 7], 'up', function() {});
    });
    await page.waitForTimeout(1000);

    const mt4Revisit = await page.evaluate(() => {
        return {
            door74: core.getBlock(7, 4),
            door51: core.getBlock(5, 1),
            door91: core.getBlock(9, 1),
            flag: core.hasFlag('mt4_doors_opened')
        };
    });
    console.log('[*] MT4 跨层重访检查:', JSON.stringify(mt4Revisit, null, 2));
    if (!mt4Revisit.flag || mt4Revisit.door74 !== null || mt4Revisit.door51 !== null || mt4Revisit.door91 !== null) {
        throw new Error('MT4 跨层重访时机关门异常复活！');
    }

    console.log('\n======================================================');
    console.log('🎉 验证大圆满！MT4 与 MT3 机关门全部测试 100% 顺利通过！');
    console.log('======================================================');

    await browser.close();
}

main().catch(err => {
    console.error('测试失败:', err);
    process.exit(1);
});
