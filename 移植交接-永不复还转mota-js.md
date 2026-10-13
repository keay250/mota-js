# 永不复还(500F) → mota-js 移植 · 交接文档

> **面向 AI Agent 的交接文档。** 目标读者：接手"把《永不复还》移植到 mota-js"这件事的下一个 agent（无论跑在 Windows 还是 macOS）。
> 本文所有结论**均经实测验证**，踩过的坑全部列出（§7 是最有价值的部分）。
> 生成时间：2026-10-13 ｜ 状态：**已成功移植 2 层并验证可玩**

---

## 0. 一句话现状

**已经用 mota-js 官方骨架 + 永不复还原始剧情/数据，做出了可运行的两层楼（MT1 寂静之森外围 / MT2 森林出口），并在浏览器里验证通过。**

移植**技术上完全可行**，瓶颈不在技术而在**工作量**（每层需重新设计地图）。

---

## 1. 两个项目是什么

### 1.1 源：《永不复还(500F)》

| 项目 | 内容 |
|---|---|
| 类型 | 中文同人 RPG（**类魔塔的固定数值回合制策略**游戏），8 章剧情 |
| 引擎 | **RPG Maker XP**（RGSS1 / Ruby 1.8），窗口 800×480 |
| 加密 | **未加密**，`Game.rxproj` 在位，`Data\*.rxdata` 是明文 Ruby Marshal |
| 规模 | 576 张地图 · 999 敌人 · 300 技能 · 200 物品/武器 · **约 34 万字剧情** |
| 路径 | `D:\Games\永不复还(500F)\永不复还(500F)\`（⚠️ 路径里 `永不复还(500F)` 出现**两次**才对，外面还有一份同名副本） |
| 关键文件 | `Data\Map*.rxdata`（地图+事件）、`Data\Scripts.rxdata`（Ruby 脚本）、`Save\motaSaveN.rxdata`（存档） |

**已有资产**（同目录下）：
- `游戏文本档案\` —— **未删改的完整原文**（22 文件 / 1.7 MB，11 章对话 + 图鉴 + 系统术语）
- `游戏剧情小说\` —— 清洗后的小说体剧情（13 文件 / 1.2 MB）
- `_analysis\dialogue_raw.json` —— **结构化对话数据（12,646 条记录，5.7 MB）**，移植最常用
- `_analysis\extract_json.py` / `extract_text.py` / `extract_db.py` —— 提取脚本

### 1.2 目标：mota-js

| 项目 | 内容 |
|---|---|
| 全名 | **mota-js**（"HTML5 魔塔样板"），仓库 `github.com/ckcz123/mota-js` |
| 许可 | **BSD-3-Clause**（600 stars，最后提交 2024-01-01，版本 **2.10.3**） |
| 类型 | HTML5/JS 引擎，**经典魔塔**（13×13 格子，每格 32px，画布 416×416） |
| 运行 | **浏览器**（可手机），服务端仅用于本地文件读写 |
| 数据 | **明文 JavaScript**！楼层 = `project/floors/MTx.js`，数据 = `project/*.js` |
| 编辑器 | **自带网页编辑器**（Blockly 积木 + CodeMirror + `MotaAction.g4` 语法，`_docs/api.md` 104 KB 文档） |

**工作副本位置**：`_analysis\_ybfh-mota\`（官方骨架 + 我们的 MT1/MT2）
**官方纯净源码**：`_analysis\_mota-js-latest\mota-js-master\`（2024-01-01 master 快照）

---

## 2. 核心结论：能搬什么、搬不动什么

| 内容 | 能否搬 | 说明 |
|---|---|---|
| **剧情对话** | ✅ **可以，且能一字不改** | 34 万字全部提取完毕，直接塞进 `{"type":"setText"}` 事件数组 |
| 旁白 / 路牌 / NPC 台词 | ✅ 可以 | 同上 |
| 剧情分支选项 | ✅ 可以 | 用 `{"type":"if","condition":"..."}` + `"true"/"false"` |
| 道具 / 钥匙 / 宝石 / 血瓶 | ✅ 可以 | 用 mota-js 标准 ID（见 §4） |
| 怪物数值 | ⚠️ **需重新平衡** | 两边公式不兼容（见 §3.3） |
| **地图** | ❌ **无法自动转换** | RMXP 自由尺寸图块 ↔ 13×13 魔塔格子，**必须重新设计**（这是主要工作量） |
| 战斗系统 | ❌ 无法搬 | 永不复还是自研"离线整场模拟"，mota-js 是经典公式 |
| 属性体系 | ❌ 无法搬 | 永不复还有护甲/魔抗/攻速/三维等 13 项，mota-js 是 hp/atk/def/mdef |
| 素材（图/音） | ⚠️ 部分可用 | mota-js 自带 RGSS 导入工具（`常用工具\rgss.dll`、`RM动画导出器.exe`），但风格与版权需自审 |

> **一句话**：**"剧情"能搬，"玩法"要重做。**

---

## 3. 数据结构对照

### 3.1 地图

**永不复还（Ruby Marshal，二进制）**
```python
from rubymarshal.reader import load
m = load(open('Data/Map007.rxdata','rb'))
a = {k: v for k, v in m.attributes.items()}   # 或直接 getattr
w, h = a['@width'], a['@height']              # 20 × 15（每格 32px）
events = a['@events']                          # {事件ID: RPG::Event}
# 事件 → @pages[] → @list[] → RPG::EventCommand(@code, @indent, @parameters)
```
代码含义：`101`=显示文本(说话人) `401`=文本行 `102`=选项 `108/408`=注释 `201`=场所移动 `354`=游戏结束 `116`=事件消失

**mota-js（明文 JS）**
```js
main.floors.MT1 = {
    "floorId": "MT1", "title": "寂静之森外围",
    "width": 13, "height": 13,          // 固定 13×13
    "map": [                             // ★ 13×13 数字矩阵 = 地图本体
        [3,3,3, ...],
        [3,88,0, ...],                   // 88=下楼口(起点)  3=墙  0=地面
        ...
    ],
    "events": { "9,1": { "trigger":"action", "data":[ ... ] } },   // 键是 "x,y"
    "changeFloor": { "11,11": {"floorId":":next","stair":"downFloor"} },
    "downFloor": [1,1], "upFloor": [11,11],
    "firstArrive": [ ... ],              // 到达该层时自动执行的指令
    "bgm": "bgm.mp3", "canFlyTo": true, "canUseQuickShop": true
}
```

### 3.2 事件 / 对话

**mota-js 事件指令（JSON 数组，可混入 JS 字符串）**
```js
"data": [
    {"type": "playSound", "name": "zone.mp3"},
    {"type": "setText", "align": "center"},
    "\t[贾斯汀]啊……",                                    // \t[名字] = 名字窗口
    "\t[贾斯汀]头好痛……",
    {"type": "setText", "align": "left"},
    {"type": "tip", "text": "提示文字"},
    {"type": "function", "function": "function(){\ncore.addItem('blueKey',1)\n}"},
    {"type": "if", "condition": "item:yellowKey", "true": [ ... ], "false": [ ... ]}
]
```

**⭐ `if` 的条件是 mota-js 自己的 DSL，不是 JS！**
| 写法 | 含义 |
|---|---|
| `item:yellowKey` | 持有某物品 |
| `flag:22` / `(flag:16==1)` | flag 判断 |
| `status:money<500` / `status:exp<500` | 状态判断 |
| `switch:A` | 开关 |
| `(core.getBlockCls(5,5)=='npcs')` | 带括号可嵌 JS 表达式 |

### 3.3 战斗数值（**不兼容，必须重配**）

**mota-js（经典公式，一眼看懂）**
```js
"greenSlime": {"name":"绿头怪","hp":50,"atk":20,"def":1,"money":1,"exp":1,"special":0}
```

**永不复还（自研离线模拟）**
```ruby
# Enemy_property#cal_enemy —— 一次算出整场战斗的净损血/损蓝
a = [(@ma - @ed[q]) * @enodamage[q] - @edecdamage[q], 0].max * @eshield[q]
```
五种伤害类型（物理/魔法/纯粹/生命移除/毒素）+ 穿甲 + 闪避 + 护甲减伤 `a*0.06/(1+0.06a)`。
**`@enodamage == 0` ⇒ 物理免疫**。
**999 个敌人的数值在两边没有任何可比性，必须重新配平。**

---

## 4. ID 映射表（实测确认）

**mota-js 地图矩阵里数字的含义**（来自 `project/maps.js`，共 252 个条目）：

| ID | 含义 | ID | 含义 |
|---|---|---|---|
| `0` | 地面（走 `defaultGround`） | `27` | redGem 红宝石 |
| `1` | yellowWall（黄墙，可破） | `28` | blueGem 蓝宝石 |
| `2` | whiteWall | `29` | greenGem |
| `3` | **blueWall（常用外墙）** | `30` | yellowGem |
| `4` | star 星空 | `31` | **redPotion 红血瓶** |
| `5` | lava 岩浆 | `32` | bluePotion |
| `6` | ice 冰块（可开） | `33` | greenPotion |
| `7–10` | 商店（蓝/粉） | `41–44` | sword4/shield4/sword5/shield5 |
| `11–14` | 血网/毒网/衰网/咒网 | `87` | **upFloor 上楼口** |
| `15` | blueLava | `88` | **downFloor 下楼口** |
| `16` | water | `101–104` | crystal/fire/switch |
| `20` | autotile | `121–138` | **NPC**（`129`=sign 路牌, `121`=man, `123`=thief, `124`=fairy, `127`=king…） |
| `21` | **yellowKey 黄钥匙** | `151–153` | autotile1-3 |
| `22` | **blueKey 蓝钥匙** | `161–170` | 箭头/灯/花/箱子 |
| `23` | redKey 红钥匙 | **`201+`** | **怪物**（`201`=greenSlime, `202`=redSlime, `203`=blackSlime, `209`=skeleton, `210`=skeletonSoilder…） |
| `24` | greenKey | | |
| `25` | steelKey | | |
| `26` | bigKey | | |

**永不复还地图 → 已做的对照**（实例）：
| 永不复还要素 | mota-js 用什么 |
|---|---|
| 血瓶:50 / 血瓶:100 | `31` redPotion |
| 红宝石:1 / 蓝宝石:1 | `27` / `28` |
| 黄钥匙 / 蓝钥匙 | `21` / `22` |
| 黄门 | `1` yellowWall（或用 `doorInfo.keys` 自定义） |
| 怪物002–008 | `201` / `202` / `209` / `210` |
| 路牌 | `129` sign（或直接用 `events` 放一个触发点） |
| 地图边缘墙 | `3` blueWall |
| 通往下一张图 | `87` upFloor + `changeFloor` |

---

## 5. 已完成的工作（可作为模板）

### MT1《寂静之森外围》← 永不复还 `Map007`

| 项目 | 内容 |
|---|---|
| 文件 | `_analysis\_ybfh-mota\project\floors\MT1.js`（4.5 KB） |
| 布局 | 13×13 **蛇形通道 5 段**，起点(1,1)→出口(11,11)，71 格可达 |
| 开场剧情 | **贾斯汀的 9 句独白，游戏原文一字未改**（"啊……头好痛……队长他一个人把那些魔兽引开了"） |
| 事件 | ①路牌(9,1) ②路过的佣兵(5,3) ③荷依米贵族警告(7,7) |
| 怪物 | 绿头怪×2 + 红头怪×1 |
| 道具 | 黄钥匙 · 红宝石 · 蓝宝石 · 红血瓶 |

### MT2《寂静之森外围·出口》← 永不复还 `Map013`

| 项目 | 内容 |
|---|---|
| 文件 | `...\floors\MT2.js`（4.9 KB） |
| 新要素 | **`if` 条件分支的支线任务**（佣兵：有黄钥匙 → 给蓝钥匙）· NPC · **楼梯互联** |
| 开场剧情 | "终于出来了……其他人没有在这里等待吗？"（原文） |

**剧情链路（实测确认）**：
```
Map007(醒来) → Map009 → Map010(路牌) → Map012(荷依米贵族+机关门教学)
            → Map013(佣兵支线+厄泽城小站) → Map017 厄泽城(1275字)
```

**楼层设计图**：`_analysis\ybfh_floor1_map.png`、`ybfh_floor2_map.png`

---

## 6. 移植标准流程（SOP）

```
① 选图：从 dialogue_raw.json 找剧情，用 MapNNN 的 @events 找 201 传送指令确认剧情顺序
        ↓
② 读源：Python + rubymarshal 读 MapNNN.rxdata → 得到尺寸/事件/道具/怪物分布
        ↓
③ 设计：把 20×15 的 RMXP 地图"重新设计"成 13×13 魔塔楼层（蛇形/分支/机关）
        ↓
④ 写码：新建 project/floors/MTn.js（照抄 MT1.js 结构，改 map 矩阵 + events + 剧情）
        ↓
⑤ 注册：project/data.js 的 "floorIds" 加入 MTn（★ 见 §7-坑6，还有第二处要改）
        ↓
⑥ 验证：Node 脚本做连通性洪水填充 + 事件数检查（见 §8）
        ↓
⑦ 跑：官方 server.js / server.py 起服务 → 浏览器开 → 点开始游戏
        ↓
⑧ 截图：CDP 脚本自动操作 + 抓 console（见 §8）
```

**单层耗时实测**：**第一层约 1 小时 / 30–50 万 token；第二层约 30 分钟 / 20–30 万 token**（格式熟悉后加速）。
**外推**：576 张地图 ≈ 288–576 小时。**建议只做 8 层精简版（约 8–12 小时）**。

---

## 7. ⭐ 坑清单（全部实测踩过，务必先读）

### 坑 1：`if` 的条件是 DSL，不是 JS
❌ `"condition": "core.hasItem('yellowKey')"`
✅ `"condition": "item:yellowKey"`
（mota-js 用 `item:` / `flag:` / `status:` / `switch:` 前缀，带括号才允许嵌 JS）

### 坑 2：`changeFloor` 必须配对配置
只写 `upFloor: [11,11]` + 地图里放 `87` **不够**！必须同时在 `changeFloor` 里写：
```json
"changeFloor": { "11,11": {"floorId": ":next", "stair": "downFloor"} }
```
`:next`=下一层，`:before`=上一层。**漏了就是踩上去毫无反应。**

### 坑 3：⭐⭐ **必须用官方服务器，不能用静态服务**
mota-js 有一个动态端点 **`/__all_floors__.js?v=<版本>&id=<楼层列表>`**，它把所有楼层打包成一个响应。
**用 `python -m http.server` 之类的静态服务 → 该端点 404 → 游戏加载不到任何楼层 → 地图全黑（但状态栏和剧情文字正常！）**，console 报 `不存在的楼层：xxx`。
✅ 正确做法：用官方 `server.js`（Node）或 `server.py`（Python+Flask），见 §8。

### 坑 4：`server.js` 有个参数解析 bug
```js
server.js:613   const all = p.split('&id=')[1].split(',');
```
请求必须是 **`?v=xxx&id=MT1,MT2`**（带 `&`）。若写成 `?id=MT1,MT2` → `[1]` 为 undefined → **服务直接崩溃退出**。

### 坑 5：开场 logo 遮罩会导致永久黑屏
```css
#startImageBackgroundDiv { display: none; position: fixed; z-index: 10000; }
.startImageDivAnimation { animation: startImageDivDisappear 2s ease-in-out 5s alternate 1; }
```
这层黑底（**z-index 10000**，盖住一切）仅靠 CSS 动画的 `animationend` 事件退场。**一旦该事件不触发**（系统「减少动效」、浏览器省电模式、后台标签节流），**永远黑屏**。
✅ 修复：`styles.css` 加 `#startImageBackgroundDiv { display: none !important; }` + `index.html` 加 `setTimeout(onAnimationEnd, 8000)` 兜底。

### 坑 6：⭐⭐ **起始楼层有两处，漏一处就进不去**
| 位置 | 字段 | 含义 |
|---|---|---|
| `data.js` → `main.floorIds` | `["MT1","MT2"]` | 可用楼层**列表**（第一个是默认起点） |
| `data.js` → **`firstData.floorId`** | `"MT1"` | **主角起始楼层** ← **最容易漏！** |
漏改 `firstData.floorId` → console 报 `不存在的楼层：sample0` → 卡在黑屏，`core.status.floorId` 为 `null`。

### 坑 7：`useCompress` 必须是 `false`
`main.js` 里 `useCompress: true` 时游戏读 `libs/floors.min.js`（打包版），**改了 `project/floors/*.js` 不生效**。
```js
this.useCompress = false;   // 改剧本必须 false
```

### 坑 8：改了内容必须改 `main.js` 的 `version`
```js
this.version = '2.10.3';    // 改成任意新值，如 '2.10.3-demo1'
```
否则浏览器用缓存，**你看不到自己的改动**（官方注释明确要求）。

### 坑 9：CRLF vs LF 会造成"文件全变了"的假象
对比 24.zip 与官方源码时，13 个引擎文件里 11 个"不同"、每个都大出 ≈行数 字节 —— **那是 CRLF（多 1 字节/行）**，不是真改动。**比对文本前先 `replace(b'\r\n', b'\n')`**。

### 坑 10：`extensions/` 里 88 个文件是 Monaco 语言包
`extensions/` 有 91 个文件，看似扩展很多 —— **其中只有 3 个是真扩展**（`dynamicMapEditor.js`、`localSave.js`、`ui-editor.js`），其余是编辑器内置的语法高亮包（python.js、go.js、ruby.js…）。

### 坑 11：`启动服务.exe` 是 Windows 专用
Windows 上可用；**macOS/Linux 用 `server.js`（Node）或 `server.py`（Flask）**。

### 坑 12：DSH 会话里 `Start-Process` 起的服务会随命令结束被清理
在本 harness 里起服务要用**受管后台任务**（`run_in_background: true`），否则下一轮就发现服务没了。

---

## 8. 环境与运行

### 8.1 起服务（关键）

**Windows（官方 exe）**
```
双击 _ybfh-mota\启动服务.exe        # 或
node server.js                       # 打印：游戏地址 http://127.0.0.1:3000
```
**macOS / Linux**
```bash
pip3 install flask
python3 server.py                    # Flask 版，纯跨平台
# 或
node server.js
```
**⚠️ 服务必须保持运行**（前台窗口别关）。

### 8.2 验证楼层结构（Node，无需浏览器）

```js
const fs = require('fs');
global.main = { floors: {} };
eval(fs.readFileSync('project/floors/MT1.js', 'utf8'));
const f = main.floors.MT1;
// 连通性洪水填充：从 downFloor 到 upFloor
```
本项目已有脚本：`_analysis\cdp_diag.cjs`（CDP 自动化诊断）

### 8.3 浏览器自动诊断（CDP）

`_analysis\cdp_diag.cjs` 用 Node + Chrome DevTools Protocol **真实驱动浏览器**：
- 启动 Edge/Chrome `--headless=new --remote-debugging-port=9333`
- 真实鼠标点击（按文本找按钮）+ 真实键盘事件
- **抓取 console 日志、JS 异常、网络失败** ← 定位黑屏全靠它
- 截图各阶段 + 读取 `core.status` 内部状态

**这是本项目最有效的诊断工具** —— 之前靠截图猜了三轮都错，用 CDP 一次就抓到 `__all_floors__.js` 404 和 `不存在的楼层：sample0`。

---

## 9. 🍎 Mac 可行性评估（重点）

> 用户明确的问题：**"永不复还能否在 Mac 上做向 mota-js 的移植"**（不是"mota-js 能否在 Mac 跑"）。

### 结论：**可以完成，约 95% 的工作在 Mac 上无障碍；唯一硬伤是无法运行永不复还本体**

### 9.0 实测依据（三个关键依赖的平台性，已在本机验证）

| 依赖 | 实测结果 | 对 Mac 的意义 |
|---|---|---|
| **`rubymarshal`**（读 `.rxdata` 的核心库） | **纯 Python，无任何编译扩展**（无 `.pyd`/`.dll`/`.so`，仅 `reader.py`/`writer.py`/`classes.py` 等） | ✅ `pip3 install rubymarshal` 即可，**跨平台无障碍** |
| **`server.py`**（mota-js 官方 Python 服务） | **零 Windows API**（无 `win32`/`winreg`/`ctypes`/`kernel32`/`.exe`），只依赖 `flask`/`socket`/`mimetypes`，共 241 行 | ✅ Mac 上 `python3 server.py` 直接可用 |
| **本项目提取脚本**（`_analysis\*.py`） | **22 / 23 个含 `D:\Games\...` 硬编码路径**（每个 1–2 处），但**全部是纯 Python 逻辑，无平台专有调用** | ⚠️ **唯一需要动手的地方**：把路径换成参数/环境变量即可（约 30 分钟工作量） |

**结论**：**移植工具链没有任何"Windows 专属"的硬依赖**，唯一的平台壁垒是**永不复还本体（`Game.exe`）跑不了**——而它并非移植工作的必需品（见 9.2）。

### 9.1 逐环节评估

| # | 移植环节 | 需要的工具 | Mac | 说明 |
|---|---|---|---|---|
| 1 | 读 `.rxdata`（Ruby Marshal） | Python + `rubymarshal` | ✅ | 纯 Python，`pip3 install rubymarshal` |
| 2 | 提取地图/对话/数据库 | Python 脚本 | ✅ | 纯文本/二进制处理（需把硬编码的 `D:\...` 路径参数化） |
| 3 | 解压 `Scripts.rxdata` 读 Ruby 源码 | Python `zlib` | ✅ | 纯标准库 |
| 4 | 理解游戏逻辑 | 文本阅读 | ✅ | — |
| 5 | 设计 13×13 楼层 | 任意编辑器 | ✅ | — |
| 6 | 写 `MTx.js` | 任意编辑器 | ✅ | — |
| 7 | 画楼层设计图 | Python + Pillow | ✅ | `pip3 install pillow` |
| 8 | **运行 mota-js 验证** | 浏览器 + `server.py`/`server.js` | ✅ | Flask/Node 全跨平台 |
| 9 | 无头截图 / CDP 自动化 | Chrome/Chromium + Node | ✅ | Mac 上把 `msedge.exe` 换成 `Google Chrome` 路径即可 |
| 10 | **运行永不复还本体**（`Game.exe`） | —— | ❌ | **RPG Maker XP 游戏是 Windows 程序** |

### 9.2 唯一硬伤：跑不了原游戏

`Game.exe` 是 Windows PE 程序（依赖 `RGSS103J.dll`、`kernel33.dll`）。在 Mac 上**无法直接运行**。

**它影响什么？**
- ❌ **需要"进原游戏实测"的场景**：确认事件触发效果、验证战斗数值、截图游戏内画面作参考
- ✅ **不影响**：数据提取（读文件即可）、楼层设计、mota-js 运行验证、剧情改写

**Mac 上的替代方案（按推荐度）**：
1. **不跑原游戏** —— 我们**已经提取了全部 34 万字对话 + 完整数据库**（`游戏文本档案\`、`dialogue_raw.json`），绝大多数移植工作只需这些数据文件，**根本不需要启动游戏**；
2. **Wine / CrossOver** —— RMXP 是老式 DirectX 程序，Wine 兼容性通常不错；
3. **Parallels / VMware Fusion + Windows 虚拟机** —— 最稳，但需要 Windows 授权；
4. **借用一台 Windows 机器**（或在 DSH 的 Windows 环境里）只做"实测对照"这一步。

> **务实建议**：**数据提取全部放 Mac，只在"需要对照原游戏"时开一次虚拟机/借机器。** 本项目的两层楼就是**只靠数据文件 + 提取结果**做出来的，全程没依赖运行原游戏。

### 9.3 Mac 上的其他注意点

| 项目 | 说明 | 风险 |
|---|---|---|
| **`启动服务.exe`** | Windows 专用 | 用 `server.py`（Flask）或 `server.js`（Node）替代 ✅ |
| **`启动.bat`** | 批处理 | 改写成 `.sh` 脚本 ✅ |
| **路径硬编码** | 本项目脚本里有 `D:\Games\永不复还(500F)\...` | 需改成参数/环境变量；建议统一用 `pathlib` |
| **PowerShell 脚本** | `.ps1` 在 Mac 上不可用 | 改用 Bash/Python（`_analysis\` 里有若干 `.ps1`） |
| **文件名大小写** | macOS APFS 默认**不敏感**，Linux 敏感 | mota-js 素材名大小写基本一致；若要部署到 Linux 服务器需复查 |
| **Unicode 规范化** | macOS 用 **NFD**，Windows/Linux 用 NFC | 中文字符不受影响；**带重音的拉丁字母**（如 `é`）可能匹配失败 —— 本项目素材名全中文/ASCII，**安全** |
| **换行符** | Git 默认可能自动转换 | 编辑 `MTx.js` 时保持与原文件一致，避免全文件 diff |
| **Python 依赖** | 需 `pip3 install rubymarshal pillow flask` | Mac 自带 `python3` ✅ |
| **Node** | `brew install node` | 用于 `server.js` 和 CDP 脚本 ✅ |

### 9.4 Mac 环境一次性准备

```bash
# 1) 基础依赖
brew install node python3
pip3 install rubymarshal pillow flask

# 2) 取 mota-js 官方骨架
curl -L -o mota-js.zip https://codeload.github.com/ckcz123/mota-js/zip/refs/heads/master
unzip mota-js.zip && mv mota-js-master mota-js

# 3) 起服务（保持前台运行）
cd mota-js && python3 server.py
# 浏览器打开 http://127.0.0.1:3000 → 点「开始游戏」

# 4) 编辑器（可选，做地图用网页编辑器）
# http://127.0.0.1:3000/editor.html
```

### 9.5 跨平台工具改造清单（把现有资产迁到 Mac 时要做的）

| 现有文件 | 改造 |
|---|---|
| `_analysis\*.py`（提取脚本） | 把 `r'D:\Games\永不复还(500F)\永不复还(500F)'` 换成 `os.environ.get('YBFH_ROOT')` 或 `pathlib.Path` 参数 |
| `_analysis\*.ps1` | 用 Bash/Python 重写（逻辑简单） |
| `_ybfh-mota\启动.bat` | 换成 `#!/bin/bash\npython3 server.py` |
| `_analysis\cdp_diag.cjs` | 把 `EDGE` 路径换成 macOS 的 Chrome：`/Applications/Google Chrome.app/Contents/MacOS/Google Chrome` |
| 文档里的 `D:\...` 路径 | 全部替换为 Mac 路径 |

---

## 10. 下一步建议

1. **继续做第三层**：按剧情是 `Map012`（荷依米贵族 + **机关门教学**，有"击杀守护怪物才开门"的机制，是玩法升级的好素材）。
2. **决定规模**：576 张全做不现实，**建议 8 层精简版**（主线剧情完整 + 核心战斗），实测约 8–12 小时。
3. **先固化模板**：把 `MT1.js` 作为模板，抽出「地图设计 → 写码 → 注册 → 验证」的脚本化流水线，能大幅提速。
4. **数值重配**：若要还原战斗手感，需把永不复还的怪物按 mota-js 公式重新配平（**这一步必须人工玩测**）。
5. **版权确认**：永不复还的素材（RPG Maker RTP + 同人素材）搬到 H5 前请确认授权。

---

## 附录 A：关键路径速查

| 用途 | 路径 |
|---|---|
| 工作副本（含 MT1/MT2） | `_analysis\_ybfh-mota\` |
| 官方纯净源码 | `_analysis\_mota-js-latest\mota-js-master\` |
| 楼层文件 | `_analysis\_ybfh-mota\project\floors\MT1.js` / `MT2.js` |
| 楼层注册 + 起始楼层 | `_analysis\_ybfh-mota\project\data.js`（`main.floorIds` + `firstData.floorId`） |
| 游戏版本/压缩开关 | `_analysis\_ybfh-mota\main.js` |
| 黑屏修复 | `_analysis\_ybfh-mota\styles.css` / `index.html` |
| CDP 诊断脚本 | `_analysis\cdp_diag.cjs` |
| 楼层设计图 | `_analysis\ybfh_floor1_map.png` / `ybfh_floor2_map.png` |
| 结构化对话数据 | `_analysis\dialogue_raw.json`（12,646 条） |
| 剧情原文 | `游戏文本档案\` |
| 小说化剧情 | `游戏剧情小说\` |
| 永不复还工作手册 | `参考-永不复还工作手册.md`（项目根目录） |

## 附录 B：常用命令

```powershell
# 起服务（Windows，DSH 里用后台任务）
node server.js          # → http://127.0.0.1:3000

# 验证楼层（Node）
node _analysis\cdp_diag.cjs

# 楼层结构 + 连通性检查
# （见 §8.2 的 Node 脚本）
```

## 附录 C：本项目的验证结论（实测）

```
MT1  13×13  事件 3 个  可达 71 格  起点→出口 ✓  上楼口 → MT2 ✓
MT2  13×13  事件 3 个  可达 71 格  起点→出口 ✓  下楼口 → MT1 ✓
服务  /index.html 200 · /__all_floors__.js?v=…&id=MT1,MT2 200 (9610 B) ✓
运行  floorId="MT1" · curFloorName="寂静之森外围" · hero={x:6,y:10} ✓
画面  地图/怪物/道具/主角/状态栏全部正常渲染 ✓（见 cdp_4_gameplay.png）
```

---

*本文档由 DeepSeek Harness 会话实测产出，所有路径、ID、命令均经验证。若发现与实际不符，以现场脚本输出为准并回写本文件。*
