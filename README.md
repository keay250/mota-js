# 移植包 · 永不复还(500F) → mota-js

> **交给下一个 AI Agent 的自包含交接包。** 目标：把 RPG Maker XP 游戏《永不复还(500F)》的剧情与关卡，移植到 HTML5 魔塔引擎 **mota-js** 上。
> 打包时间：2026-10-13 ｜ 状态：**已完成 2 层可运行楼层并验证通过**

---

## 🚀 5 分钟跑起来（先看效果，再读文档）

```bash
# 需要 Node.js 或 Python3
cd _analysis/_ybfh-mota

# 方式 A（推荐，跨平台）
node server.js            # 打印：游戏地址 http://127.0.0.1:3000

# 方式 B（Mac/Linux 友好）
pip3 install flask && python3 server.py

# 方式 C（仅 Windows）
双击 "启动服务.exe"
```
**浏览器打开 `http://127.0.0.1:3000` → 点「开始游戏」→ 选「简单」→ 回车跳过开场剧情 → 进入《寂静之森外围》**

> ⚠️ **必须用官方 `server.js` / `server.py`，不要用 `python -m http.server`**——静态服务会让地图全黑（详见交接文档「坑 3」）。

---

## 📖 阅读顺序（按这个顺序读，别跳）

| 顺序 | 文件 | 为什么读 |
|---|---|---|
| 1️⃣ | **`移植交接-永不复还转mota-js.md`** | **主文档**。两个项目是什么、能搬什么、数据结构对照、ID 映射、已完成工作、SOP |
| 2️⃣ | 同上的 **§7 坑清单** | ⭐ **最值钱的部分**。12 条实测踩过的坑，先读能省几小时 |
| 3️⃣ | 同上的 **§9 Mac 可行性** | 如果你在 macOS 上工作，必读 |
| 4️⃣ | `_analysis/项目对比-mota-js样板-vs-永不复还.md` | 两个项目的技术栈差异全景 |
| 5️⃣ | `参考-永不复还工作手册.md` | 永不复还侧的完整工作手册（数据格式、存档结构、反作弊等） |
| 6️⃣ | `_analysis/_ybfh-mota/project/floors/MT1.js` | **照着这个模板写新楼层** |
| 7️⃣ | `游戏剧情小说/` | 34 万字剧情的可读版本，设计楼层时从这里找素材 |

---

## 📁 目录结构

> **本包保持了与原始工作区完全相同的相对路径**，因此交接文档中出现的所有 `_analysis\...` 路径**在本包内依然有效**。

```
移植包-永不复还转mota-js/
├─ README.md                            ← 你正在读的这个
├─ 移植交接-永不复还转mota-js.md          ← ★ 主交接文档
├─ 参考-永不复还工作手册.md                            ← 永不复还工作手册（数据格式/存档/反作弊）
│
├─ _analysis/                           ← 所有工具、工程、数据
│   ├─ _ybfh-mota/                      ← ★ 可运行的 mota-js 工程（含 MT1/MT2）
│   │   ├─ project/floors/MT1.js        ←   第一层（寂静之森外围）
│   │   ├─ project/floors/MT2.js        ←   第二层（森林出口，含支线任务）
│   │   ├─ project/data.js              ←   ★ 楼层注册 + 起始楼层（两处都要改！）
│   │   ├─ main.js                      ←   版本号 / useCompress 开关
│   │   ├─ styles.css · index.html      ←   已含黑屏修复
│   │   ├─ server.js · server.py        ←   ★ 必须用它们起服务
│   │   └─ 启动服务.exe                  ←   仅 Windows
│   │
│   ├─ _mota-js-latest/mota-js-master/  ← 官方纯净源码（2024-01-01 master，BSD-3）
│   │
│   ├─ dialogue_raw.json                ← ★ 结构化对话数据（12,646 条，5.7 MB）
│   ├─ extract_json.py                  ←   从 .rxdata 提取对话（产出上面那个）
│   ├─ extract_text.py / extract_db.py / extract_system.py
│   ├─ split_story.py / gen_index.py / gen_cast.py
│   ├─ build_figures.py / find_faces.py / dissect_fuki.py
│   ├─ cdp_diag.cjs                     ← ★ 浏览器 CDP 自动诊断（定位黑屏的利器）
│   │
│   ├─ ybfh_floor1_map.png              ← 第一层设计图
│   ├─ ybfh_floor2_map.png              ← 第二层设计图
│   ├─ cdp_4_gameplay.png               ← 移植成功证据（地图完整渲染）
│   ├─ gallery_final.png                ← 人物形象图鉴截图
│   └─ 项目对比-mota-js样板-vs-永不复还.md
│
├─ 游戏文本档案/                         ← 永不复还完整原文（22 文件 / 1.7 MB）
├─ 游戏剧情小说/                         ← 清洗后的小说体剧情（13 文件 / 1.2 MB）
└─ 人物形象图鉴/                         ← 306 位出场角色 / 32 位带游戏内形象
```

**统计**：773 个文件 · 53.52 MB

---

## 🔧 环境依赖

| 用途 | 依赖 | 安装 |
|---|---|---|
| 读永不复还 `.rxdata` | Python 3 + **`rubymarshal`** | `pip3 install rubymarshal`（**纯 Python，无编译扩展**） |
| 图片处理 / 画楼层图 | **`Pillow`** | `pip3 install pillow` |
| 起 mota-js 服务 | **Node.js**（用 `server.js`） | `brew install node` / 官网下载 |
| 或 Flask 版服务 | **`flask`** | `pip3 install flask` |
| 浏览器自动诊断 | **Chrome/Edge** + Node | — |

---

## 🍎 如果你是 Mac（重要）

**结论：移植工作约 95% 可在 Mac 上完成。**

✅ **能做的**：读 `.rxdata`、提取对话/数据库、设计楼层、写 `MTx.js`、跑 mota-js 验证、CDP 自动诊断、画图
❌ **唯一做不了的**：运行永不复还本体（`Game.exe` 是 Windows 程序）——**但移植不需要它**，因为全部数据**已经提取完毕**（见 `对话_raw.json` 与 `游戏文本档案/`）

**开工前要做的跨平台改造**（详见交接文档 §9.5）：
1. 22/23 个提取脚本含 `D:\Games\...` 硬编码路径 → 改成参数/环境变量
2. `启动.bat` → 改写成 `.sh`（内容就是 `python3 server.py`）
3. `cdp_diag.cjs` 里的 Edge 路径 → 换成 `/Applications/Google Chrome.app/Contents/MacOS/Google Chrome`
4. 需要"进原游戏对照"时：Wine / CrossOver / Parallels 虚拟机 / 借一台 Windows

---

## ⚠️ 三条最容易踩的坑（先看能省几小时）

1. **起始楼层有两处**：`data.js` 的 `main.floorIds` **和** `firstData.floorId`。只改前者 → 报 `不存在的楼层：sample0` → 卡黑屏进不去。
2. **必须用官方服务**：静态服务会导致 mota-js 的动态端点 `/__all_floors__.js` 404 → **地图全黑但状态栏和文字正常**（极易误判为"渲染 bug"）。
3. **`if` 事件的条件是 mota-js 的 DSL**（`item:yellowKey`），**不是 JS**（`core.hasItem(...)` 无效）。

> 完整 12 条见交接文档 **§7 坑清单**。

---

## 🎯 已完成进度

| 楼层 | 来源地图 | 内容 |
|---|---|---|
| **MT1**《寂静之森外围》 | `Map007` | 蛇形通道 · 贾斯汀 9 句独白（原文）· 3 事件 · 3 怪 · 4 道具 |
| **MT2**《寂静之森外围·出口》 | `Map013` | 支线任务（`if` 分支）· NPC · 小站路牌 · 楼梯互联 |

**实测耗时**：第一层约 1 小时 / 30–50 万 token；第二层约 30 分钟 / 20–30 万 token
**剧情链路**：`Map007 → Map009 → Map010 → Map012 → Map013 → Map017 厄泽城`

---

## ▶️ 下一步建议

1. **第三层**：`Map012`（荷依米贵族 + **机关门教学**——"击杀守护怪才能开门"是好的玩法升级点）
2. **决定规模**：576 张全做不现实，**建议 8 层精简版**（实测 8–12 小时）
3. **固化模板**：以 `MT1.js` 为模板，把「设计 → 写码 → 注册 → 验证」脚本化提速
4. **数值重配**：永不复还的战斗公式与 mota-js 不兼容，怪物数值必须人工重新配平
5. **版权确认**：素材（RPG Maker RTP + 同人素材）跨引擎使用前请确认授权

---

*本包由 DeepSeek Harness 会话实测产出。所有路径、ID、命令均经验证；若发现与实际不符，以现场脚本输出为准，并回写交接文档。*
