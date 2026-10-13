const { chromium } = require('playwright');
const path = require('path');

async function main() {
    console.log('Launching headless browser...');
    const browser = await chromium.launch({ headless: true });
    const page = await browser.newPage({ viewport: { width: 1280, height: 800 } });

    console.log('Navigating to http://127.0.0.1:3000 ...');
    await page.goto('http://127.0.0.1:3000', { waitUntil: 'networkidle' });

    console.log('Page loaded. Checking title and start panel...');
    await page.waitForTimeout(1000);

    // Click "开始游戏" (playGame) button
    const playBtn = page.locator('#playGame');
    if (await playBtn.isVisible()) {
        console.log('Clicking playGame button...');
        await playBtn.click();
    } else {
        console.log('playGame button not visible, clicking body or key...');
        await page.keyboard.press('Space');
    }

    // Wait for difficulty selection or start
    await page.waitForTimeout(1500);

    // Click "简单" (difficulty 1) if present
    const easyBtn = page.locator('.levelChooseButton').first();
    if (await easyBtn.isVisible()) {
        console.log('Selecting Easy difficulty...');
        await easyBtn.click();
        await page.waitForTimeout(1500);
    }

    // Dismiss start dialogues by pressing Space or Enter multiple times
    console.log('Dismissing opening dialogues...');
    for (let i = 0; i < 15; i++) {
        await page.keyboard.press('Space');
        await page.waitForTimeout(200);
    }

    await page.waitForTimeout(1000);

    // Take screenshot of the game
    const outputPath = path.resolve(__dirname, '../gameplay_preview.png');
    await page.screenshot({ path: outputPath });
    console.log(`Screenshot saved to: ${outputPath}`);

    // Also take screenshot of just the gameGroup
    const gameGroup = page.locator('#gameGroup');
    if (await gameGroup.isVisible()) {
        const gameGroupPath = path.resolve(__dirname, '../gamegroup_preview.png');
        await gameGroup.screenshot({ path: gameGroupPath });
        console.log(`GameGroup screenshot saved to: ${gameGroupPath}`);
    }

    await browser.close();
    console.log('Done!');
}

main().catch(err => {
    console.error('Error during screenshot:', err);
    process.exit(1);
});
