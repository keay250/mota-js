# -*- coding: utf-8 -*-
"""生成「00-章节与地图总览.md」与「README.md」。"""
import os, sys, json, glob, re

ROOT = r'D:\Games\永不复还(500F)\永不复还(500F)'
OUTDIR = os.path.join(ROOT, '游戏文本档案')
STATS = os.path.join(ROOT, '_analysis', 'text_stats.json')

data = json.load(open(STATS, encoding='utf-8'))
stats = {s['map']: s for s in data['stats'] if 'chars' in s}
infos = {int(k): v for k, v in data['infos'].items()}
grand = data['grand']

CHAP_RE = re.compile(r'第[一二三四五六七八九十]+章')

# ---------------- 00 总览 ----------------
L = ['# 章节与地图总览', '',
     f'游戏共 **{len(infos)} 张地图**；其中 {len(stats)} 张含对话文本，'
     f'合计 **{grand["lines"]:,} 行 / {grand["chars"]:,} 字**。', '',
     '---', '', '## 一、地图树', '']

roots = sorted([k for k, v in infos.items() if not v['parent']])
seen = set()
def walk(node, depth):
    if node in seen: return
    seen.add(node)
    info = infos.get(node)
    if not info: return
    st = stats.get(node)
    mark = ''
    if st:
        mark = f'  · *{st["chars"]:,} 字*'
    L.append('  ' * depth + f'- **[{node}] {info["name"]}**{mark}')
    kids = sorted([k for k, x in infos.items() if x['parent'] == node],
                  key=lambda k: (infos[k]['order'], k))
    for c in kids:
        walk(c, depth + 1)

for r in roots:
    walk(r, 0)
for k in sorted(infos.keys()):
    if k not in seen:
        walk(k, 0)

L += ['', '---', '', '## 二、文本量最大的 40 张地图', '',
      '| 地图 | 名称 | 字数 | 文本行 | 含文本事件 |', '|---|---|---|---|---|']
for s in sorted(stats.values(), key=lambda s: -s['chars'])[:40]:
    L.append(f'| Map{s["map"]:03d} | {s["name"]} | {s["chars"]:,} | {s["lines"]:,} | {s["text_events"]} |')

L += ['', '---', '', '## 三、各章节地图数', '',
      '| 章节 | 有文本地图数 | 字数 |', '|---|---|---|']
chap_txt = {}
for k, info in infos.items():
    if CHAP_RE.search(info['name']):
        chap_txt[k] = {'name': info['name'], 'maps': 0, 'chars': 0}

def chap_of(mid):
    cur, g = mid, 0
    while cur and g < 40:
        i = infos.get(cur)
        if not i: return None
        if CHAP_RE.search(i['name']): return cur
        cur = i['parent']; g += 1
    return None

for mid, st in stats.items():
    c = chap_of(mid)
    if c in chap_txt:
        chap_txt[c]['maps'] += 1
        chap_txt[c]['chars'] += st['chars']
for k, v in sorted(chap_txt.items(), key=lambda kv: infos[kv[0]]['order']):
    L.append(f'| {v["name"]} | {v["maps"]} | {v["chars"]:,} |')

open(os.path.join(OUTDIR, '00-章节与地图总览.md'), 'w', encoding='utf-8').write('\n'.join(L))
print('写出 00-章节与地图总览.md', len(L), '行')

# ---------------- README ----------------
files = []
for p in sorted(glob.glob(os.path.join(OUTDIR, '*.md'))):
    n = os.path.basename(p)
    if n == 'README.md': continue
    files.append((n, os.path.getsize(p)))

R = ['''# 永不复还(500F) · 游戏文本档案

> 从游戏数据文件里**完整提取**的全部文本：剧情对话、物品装备、技能、敌人、系统术语。
> 生成时间：2026-10-10 ｜ 生成方式：解析 `Data\\*.rxdata`（Ruby Marshal 4.8）
''', '---', '', '## 一、包含什么', '',
      '| 文件 | 内容 |', '|---|---|']

DESC = {
    '00': '**章节与地图总览** —— 576 张地图的完整树、文本量排行',
    '01': '第一章：厄泽往事',
    '02': '第二章：王都崛起',
    '03': '第三章：地狱涅槃',
    '04': '第四章：苍白之影',
    '05': '第五章：魔王降临',
    '06': '第六章：位面战场',
    '07': '第六章结尾',
    '08': '第七章：传奇岁月',
    '09': '第七章结尾',
    '10': '第八章：真理要塞',
    '90': '物品图鉴（200 条，含描述）',
    '91': '装备图鉴（武器表 200 条，**装备名已解码为效果**）',
    '91b': '防具图鉴（本作装备基本都放在武器表，此表几乎是空的）',
    '92': '技能图鉴（300 条）',
    '93': '敌人图鉴（999 条，含属性）',
    '94': '角色 / 职业 / 状态',
    '95': '公共事件文本（商店、系统提示等）',
    '96': '**系统术语 · 元素 · 开关名 · 变量名**（开关与变量名直接揭示了作者的设计意图）',
    '99': '附录：系统与模板地图',
}
for n, sz in files:
    key = n.split('-')[0]
    R.append(f'| [{n}](<{n}>) | {DESC.get(key, "")} ｜ {sz/1024:.1f} KB |')

total = sum(sz for _, sz in files)
R += ['', f'合计 **{len(files)} 个文件 / {total/1024:.0f} KB**。', '',
      '---', '', '## 二、阅读提示', '',
      '### 2.1 对话的排版约定', '',
      '```markdown',
      '### 事件11「EV011」页1',
      '',
      '**贾斯汀：**          ← 说话人（取自「显示文章」的立绘参数）',
      '',
      '> 啊……              ← 对白正文，一行一个引用块',
      '>',
      '> 头好痛……',
      '```',
      '',
      '- 同一「事件 + 页码」下的连续对白已合并到一个小节。',
      '- 连续同一说话人只标注一次名字。',
      '- `<details>` 折叠块里是**脚本内嵌文本**与**作者注释**（原作者的开发笔记）。',
      '',
      '### 2.2 RMXP 消息控制符（原文保留，未翻译）', '',
      '| 控制符 | 含义 |', '|---|---|',
      '| `\\c[n]` | 文字颜色切换 |',
      '| `\\v[n]` | 插入变量 n 的当前值 |',
      '| `\\n[n]` | 插入角色 n 的名字 |',
      '| `\\s[n]` | 等待 n/10 秒 |',
      '| `\\|` `\\.` `\\!` | 等待 1 秒 / 0.25 秒 / 按键 |',
      '| `\\>` `\\<` | 瞬间显示 / 恢复正常速度 |',
      '| `\\^` | 不等待输入直接继续 |',
      '| `\\\\` | 反斜杠本身 |',
      '',
      '### 2.3 装备名的解码规则', '',
      '装备名形如 `静谧之鞋:MI10:D4:A15`，冒号分隔的每一段是「词条 + 数值」。',
      '16 个词条的含义见根目录 [`AGENTS.md`](../AGENTS.md) §3.3；装备图鉴里已经全部翻译成人话。',
      '',
      '---', '', '## 三、重新生成 / 二次开发', '',
      '```powershell',
      '$env:PYTHONIOENCODING=\'utf-8\'',
      '$py = \'C:\\Users\\Administrator\\.dsh\\dsh-runtimes\\dsh-primary-runtime\\dependencies\\python\\python.exe\'',
      '',
      '# 章节对话',
      '& $py "D:\\Games\\永不复还(500F)\\永不复还(500F)\\_analysis\\extract_text.py"',
      '# 数据库文本（物品/装备/技能/敌人/公共事件）',
      '& $py "D:\\Games\\永不复还(500F)\\永不复还(500F)\\_analysis\\extract_db.py"',
      '# 系统术语 / 开关 / 变量',
      '& $py "D:\\Games\\永不复还(500F)\\永不复还(500F)\\_analysis\\extract_system.py"',
      '# 本索引',
      '& $py "D:\\Games\\永不复还(500F)\\永不复还(500F)\\_analysis\\gen_index.py"',
      '```',
      '',
      '---', '', '## 四、已知限制', '',
      '1. 提取范围是**事件指令里的文本**（显示文章 / 滚动文本 / 选项 / 注释 / 脚本内嵌）。',
      '   脚本中**动态拼接**的字符串（如 `"第" + n.to_s + "章"`）无法静态还原。',
      '2. 图片里的文字（部分 UI 提示）不在数据文件中，无法提取。',
      '3. 战斗动画名、音效名等资源名未纳入（不是剧情文本）。',
      '4. 变量/开关在对话中显示为 `\\v[n]`，档案中保留原样、未代入运行时数值。',
      '']
open(os.path.join(OUTDIR, 'README.md'), 'w', encoding='utf-8').write('\n'.join(R))
print('写出 README.md', len(R), '行')
