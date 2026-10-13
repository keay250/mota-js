# 项目对比：`24.zip`（mota-js 魔塔） vs 永不复还(500F)（RPG Maker XP）

> 生成时间：2026-10-12 ｜ 分析方法：直接读取 zip 内文件，未解压、未改动原包

---

## 一句话结论

**两者不是"同一个游戏的不同版本"，而是两个世代、两套引擎、两种游戏形态的项目。**

- `24.zip` = **HTML5 魔塔**（`mota-js` 样板），数据是**明文 JavaScript**，浏览器运行，自带网页编辑器。
- 永不复还(500F) = **RPG Maker XP 剧情 RPG**（类魔塔战斗），数据是 **Marshal 二进制**，桌面 exe 运行，需逆向才能改。

---

## 一、基本身份

| | **24.zip** | **永不复还(500F)** |
|---|---|---|
| 引擎 | **mota-js**（HTML5 / 原生 JS） | **RPG Maker XP**（RGSS1 / Ruby 1.8） |
| 形态 | 网页游戏（可上手机） | Windows 桌面程序（800×480 窗口） |
| 入口 | `dist/index.html` | `Game.exe` |
| 类型 | **纯正魔塔**（13×13 格子、楼梯上下层） | **剧情向 RPG**（8 章 34 万字剧情 + 类魔塔战斗） |
| 体积 | **7.7 MB**（素材仅 2.1 MB） | **约 364 MB** |
| 版本线索 | `24新版V1.2.1`（作者路径），正在"翻新" | 1.05（`Game.rxproj`） |
| 编辑器 | **自带网页编辑器**（`127.0.0.1:1055/editor.html`） | RPG Maker XP（外部 IDE） |

---

## 二、技术栈：世代差异

| 维度 | 24.zip | 永不复还 |
|---|---|---|
| 语言 | JavaScript | Ruby 1.8 |
| 渲染 | Canvas 2D（13×13 × 32px = 416×416） | RGSS 图形层（800×480） |
| 数据格式 | **明文 `.js`** | **Marshal 4.8 二进制**（`.rxdata`） |
| 压缩/编码 | LZ-String（存档）、无（数据） | zlib + gzip + CRC32（存档） |
| 存档 | `_saves/24_saveN`，**1–3 KB** | `Save/motaSaveN.rxdata`，**150–430 KB** |
| 依赖 | lodash / localforage / corejs / zip.js | RGSS103J.dll、kernel33.dll |
| 语法工具 | **MotaAction.g4**（ANTLR 语法）+ 解析器 | 无（Ruby 直解释） |

---

## 三、数据结构对比（最关键的差异）

### 3.1 楼层/地图

**24.zip —— 一层一个 JS 文件，直接读改：**

```js
// dist/project/floors/MT1.js
main.floors.MT1 = {
    "floorId": "MT1", "title": "第 1 层", "width": 13, "height": 13,
    "events": {
        "2,11": {
            "trigger": "action",
            "data": [
                { "type": "playSound", "name": "constants.mp3" },
                { "type": "function", "function": "function(){\ncore.addItem('book',1)\n}" },
                { "type": "setText", "align": "center" },
                "\t[圣光徽]该宝物可以查看怪物的基本情况。使用时按下键盘上的X键即可查看。",
                { "type": "hide", "remove": true }
            ]
        }
    },
    "changeFloor": { "1,1": { "floorId": ":next", ... } }
}
```

**永不复还 —— 二进制，得先写解析器：**

```python
m = load(open('Data/Map001.rxdata','rb'))     # 需要 rubymarshal
events = A(m)['@events']
for cmd in A(page)['@list']:
    if A(cmd)['@code'] == 101:  ...           # 对话
    if A(cmd)['@code'] == 401:  ...           # 文本行
```

| | 24.zip | 永不复还 |
|---|---|---|
| 地图单位 | **楼层**（13×13 固定格子） | **地图**（自由尺寸，RMXP 图块） |
| 数量 | 38 个楼层文件，**注册 27 层** | **576 张**地图 |
| 坐标 | `"x,y"` 字符串键 | RMXP 事件 ID + 像素坐标 |
| 通行/图块 | `setBlock` 指令动态改 | 图块通行度 + 事件页开关 |

### 3.2 事件/对话

| | 24.zip | 永不复还 |
|---|---|---|
| 载体 | **JSON 数组**（可含 JS 函数） | 事件指令码（101/401/355/655…） |
| 对话 | 数组里的**纯字符串** | `101` + `401` 序列 |
| 逻辑 | `{"type":"if"}` / `{"type":"while"}` / `{"type":"function"}` | `111` 条件 / `112` 循环 / `355` 脚本 |
| 可读性 | ⭐⭐⭐⭐⭐ 打开就能看懂 | ⭐⭐ 需工具+经验 |

**24.zip 的事件指令分布（前几名）**：
`playSound` 209 · `setValue` 122 · `hide` 45 · `break` 31 · `if` 24 · `setBlock` 24 · `function` 17 · `setText` 15 · `openShop` 11 · `choices` 7 · `win` 6

### 3.3 战斗数值

**24.zip（经典魔塔公式，一看就懂）：**
```js
"greenSlime": { "name":"绿头怪", "hp":50, "atk":20, "def":1, "money":1, "exp":1, "special":0 }
```

**永不复还（自研"离线战斗模拟"）：**
```ruby
# Enemy_property#cal_enemy —— 一次性算出整场战斗的净损血/损蓝
a = [(@ma - @ed[q]) * @enodamage[q] - @edecdamage[q], 0].max * @eshield[q]
```
> 永不复还的伤害体系复杂得多：区分物理/魔法/纯粹/生命移除/毒素五类，还有穿甲、闪避、护甲减伤公式 `a*0.06/(1+0.06a)`。

---

## 四、内容规模对比

| 项目 | 24.zip | 永不复还(500F) | 倍数 |
|---|---:|---:|---:|
| 楼层/地图 | 27 层（38 个文件） | **576 张** | ~21× |
| 敌人 | 66 种 | **999 种** | ~15× |
| 物品/常量 | 87 条 | 200 物品 + 200 武器 + 22 防具 | ~5× |
| **剧情文本** | **1,322 字** | **约 340,000 字** | **~257×** |
| 事件指令种类 | 15+ 种 | 30+ 种（RMXP 指令集） | — |
| 素材体积 | 2.1 MB | **约 364 MB** | ~170× |
| 脚本代码 | plugins.js 197 KB + functions.js 59 KB | Scripts.rxdata 400 KB（166 段） | — |
| 存档数量 | 21 个 | 142+ 个 | — |

**注**：24.zip 的文本量只有 1.3 KB，说明它是**几乎没有剧情的纯玩法魔塔**，且**处于翻新/半成品状态**（38 个楼层文件只注册了 27 层）。

---

## 五、可修改性对比（对"改游戏"这件事）

| 想做的事 | 24.zip | 永不复还 |
|---|---|---|
| 加一件装备 | 直接编辑 `items.js` 加一行 | 需改存档（Marshal 字节手术）+ 可能改数据库 |
| 加一个楼层 | 新写 `MTxx.js`，在 `data.js` 注册 | 用 RMXP 编辑器或手写 Marshal |
| 改一句对白 | 文本就在 JS 数组里，直接改 | 需解析 101/401 指令 |
| 加一段剧情逻辑 | 写 `{"type":"function","function":"..."}` 内联 JS | 必须注入新脚本段（且**必须插在 Main 之前**） |
| 加个系统（如属性面板） | 写插件挂到 `plugins.js` | 注入 Ruby 段 + `alias` 原方法 |
| 改数值平衡 | 改 `enemys.js` 的数字 | 改 `Enemies.rxdata`（Marshal） |
| 需要的前置知识 | JS/JSON | Ruby + Marshal 二进制 + 字节级操作 |

**结论**：
- **24.zip 的改造门槛低一个数量级** —— 数据即源码，编辑器自带，改完刷新浏览器即可。
- **永不复还的改造成本高**，但它的"剧情 + 复杂战斗公式"也带来了更大的改造空间（本项目的属性面板、存档补装备都是这么来的）。

---

## 六、24.zip 里的开发痕迹（有意思的细节）

| 发现 | 说明 |
|---|---|
| `dist/project/floors/.vs/floors/CopilotIndices/` | 作者用 **Visual Studio + GitHub Copilot** 编辑楼层代码，留下了 AI 索引数据库（CodeChunks.db / SemanticSymbols.db） |
| `dist/project/floors/copy_layers_21_30.py` | 作者写的 Python 脚本，**批量把 MT1–MT10 复制成 MT21–MT30**（改 floorId/title 文本） |
| 源路径 `d:\新建文件夹 (5)\翻新\24翻新\翻新！\24新版V1.2.1\` | 典型的手工翻新工程目录 |
| `sample0/1/2.js` | 样板示例楼层（未注册到 floorIds） |
| `dist/_saves/.exported`、`template_save1/111` | 存档模板与导出标记 |
| `dist/常用工具/` 里的 `rgss.dll`、`RM动画导出器.exe` | **mota-js 自带 RGSS 解析工具** —— 能把 RPG Maker 的素材/动画导入到 H5 项目 |
| `dist/_docs/` 完整文档 | api.md 104 KB、element.md 69 KB、instruction.md 81 KB —— 官方文档齐全 |

> 有意思的是：**mota-js 提供了"从 RPG Maker 导入素材"的工具**，而永不复还正是 RPG Maker XP 项目 —— 理论上可以把永不复还的素材/动画搬进 mota-js，但两边的**战斗系统与剧情系统差异太大，无法直接移植**。

---

## 七、总结：两者能否互相借鉴？

| 问题 | 回答 |
|---|---|
| 是同一个游戏吗？ | ❌ 不是。一个是剧情 RPG，一个是纯魔塔。 |
| 引擎/技术栈相同吗？ | ❌ 完全不同世代：Ruby 桌面引擎 vs JS Web 引擎。 |
| 数据能互相导入吗？ | ❌ 格式完全不兼容（Marshal 二进制 ↔ 明文 JS）。 |
| 素材能复用吗？ | ⚠️ 部分可以（mota-js 自带 RGSS 导入工具），但版权与风格需自行确认。 |
| 修改方法能复用吗？ | ❌ 永不复还的那套工具（`save_patcher.py`、Marshal 解析、脚本注入）对 24.zip **完全无效**；反过来也一样。 |
| 哪个更好上手？ | **24.zip 容易得多**（改 JS 就行）；永不复还的门槛在"逆向"二字。 |

---

*报告由 DeepSeek Harness 会话生成，所有数据来自对 `D:\Desktops\24.zip` 的直接读取（未解压、未修改）。*
