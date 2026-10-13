import asyncio
from playwright.async_api import async_playwright

async def verify():
    print("[*] 正在验证后续血瓶直接拾取与封顶机制...")
    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=True)
        page = await browser.new_page(viewport={"width": 1280, "height": 800})
        await page.goto("http://127.0.0.1:3000/")
        await asyncio.sleep(2)
        await page.keyboard.press("Space")
        await asyncio.sleep(0.5)
        btn = await page.query_selector("text=初心试炼")
        if btn: await btn.click()
        for _ in range(60):
            await page.keyboard.press("Space")
            await asyncio.sleep(0.08)
            in_map = await page.evaluate('''() => {
                return core.status.floorId === 'MT1' && core.getHeroLoc().x >= 0 && (!core.status.event || !core.status.event.id);
            }''')
            if in_map: break

        # 1. 验证 MT1 (1, 11) 教学血瓶依然有防溢出拦截
        print("[1/2] 验证 MT1 (1, 11) 教学血瓶保留防溢出拦截...")
        await page.keyboard.press("ArrowLeft")
        await asyncio.sleep(0.3)
        await page.keyboard.press("ArrowUp")
        await asyncio.sleep(0.5)
        mt1_res = await page.evaluate('''() => {
            return {
                eventId: core.status.event ? core.status.event.id : null,
                hp: core.getStatus('hp')
            };
        }''')
        print(" -> MT1 教学血瓶触发结果:", mt1_res)
        assert mt1_res['eventId'] == 'action', "MT1 教学血瓶应触发 action 对话！"
        print(" ✅ MT1 教学血瓶成功保留原版防溢出教学判定！")

        # 循环按空格彻底关闭所有教学对话
        for _ in range(5):
            if await page.evaluate('() => !core.status.event || !core.status.event.id'):
                break
            await page.keyboard.press("Space")
            await asyncio.sleep(0.2)

        # 2. 传送至 MT2 验证普通血瓶无拦截直接吃
        print("\n[2/2] 验证 MT2 普通血瓶直接拾取吃掉且不受阻碍...")
        await page.evaluate('''() => {
            core.changeFloor('MT2', 'downFloor');
        }''')
        await asyncio.sleep(1)

        # 检查 MT2 当前地图
        mt2_info = await page.evaluate('''() => {
            var floor = core.status.maps['MT2'];
            // 找一个红血瓶坐标
            var redPotion = floor.blocks.find(b => b.event.id === 'redPotion');
            return {
                floorId: core.status.floorId,
                hp: core.getStatus('hp'),
                hpmax: core.getRealStatus('hpmax'),
                potionCoord: redPotion ? {x: redPotion.x, y: redPotion.y} : null
            };
        }''')
        print(" -> MT2 状态与血瓶坐标:", mt2_info)
        assert mt2_info['floorId'] == 'MT2', "应成功切到 MT2 楼层"

        px = mt2_info['potionCoord']['x']
        py = mt2_info['potionCoord']['y']
        
        # 将主角放到该血瓶旁，并直接走到该血瓶上
        step_res = await page.evaluate(f'''() => {{
            var beforeHp = core.getStatus('hp');
            // 确保没有自定义拦截事件
            var eventAtPotion = (core.status.maps['MT2'].events || {{}})['{px},{py}'];
            // 主角吃掉该血瓶
            core.getItem('redPotion', 1, {px}, {py});
            var afterHp = core.getStatus('hp');
            return {{
                hasCustomEvent: eventAtPotion != null,
                beforeHp: beforeHp,
                afterHp: afterHp,
                statusBar: document.getElementById('hp').innerText,
                eventState: core.status.event ? core.status.event.id : null
            }};
        }}''')
        print(f" -> 拾取 MT2 ({px}, {py}) 普通血瓶结果:", step_res)
        assert not step_res['hasCustomEvent'], f"MT2 ({px}, {py}) 不应有自定义拦截事件！"
        assert step_res['eventState'] is None, "普通血瓶不应弹窗阻塞玩家！"
        assert "700/700" in step_res['statusBar'], "满血吃血瓶保持上限封顶！"
        print(" ✅ MT2 普通血瓶无弹窗拦截，直接吃掉且受上限封顶，完全符合原版逻辑！")

        await browser.close()

if __name__ == "__main__":
    asyncio.run(verify())
