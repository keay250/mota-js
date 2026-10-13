# -*- coding: utf-8 -*-
"""建立「剧情人物 ↔ 游戏形象」对应表，并导出裁剪后的小图。

数据源：
  - 说话人：_analysis/dialogue_raw.json（对话记录）
  - 形象：Graphics/Characters 里的中文名文件（人物行走图/立绘）
        + Graphics/Pictures 里的立绘（nevermore.png 等）
流程：匹配 → 裁剪标准行走图的第一帧 → 输出 sprites/ 与 figures.json
"""
import os, sys, json, re
from collections import Counter
from PIL import Image

ROOT = r'D:\Games\永不复还(500F)\永不复还(500F)'
OUT = os.path.join(ROOT, '人物形象图鉴')
SPR = os.path.join(OUT, 'sprites')
os.makedirs(SPR, exist_ok=True)

# ---------------- 1. 说话人统计 ----------------
recs = json.load(open(os.path.join(ROOT, '_analysis', 'dialogue_raw.json'), encoding='utf-8'))

CTRL = re.compile(r'\\[a-z]')
def looks_like_text(s):
    if not s: return True
    if CTRL.search(s): return True
    if len(s) > 12: return True
    if re.search(r'[，。！？、；：]', s): return True
    if re.search(r'价格|购买|出售|需要|消耗|存档|设置|菜单|按.*键|点击|积分|模式|说明|提示|注意|商店|装置|系统', s): return True
    return False

cnt = Counter()
for r in recs:
    if r['kind'] != 'dialog': continue
    s = (r['speaker'] or '').strip()
    if not s: continue
    s = re.sub(r'^\d+\s*[-－]\s*', '', s)      # 去掉引擎槽位编号
    s = s.strip()
    if looks_like_text(s): continue
    cnt[s] += 1

print('有效说话人:', len(cnt))

# ---------------- 2. 图片索引 ----------------
def strip_prefix(n):
    n = re.sub(r'^(RTP风格-|KN_HoK科技风格\s*|第七章-|第八章-)', '', n)
    return n.strip(' ()（）').strip()

img_index = {}          # 规范化名字 -> 相对路径
raw_index = {}          # 原始 base -> 相对路径
for sub in ('Characters', 'Pictures', 'Battlers'):
    d = os.path.join(ROOT, 'Graphics', sub)
    if not os.path.isdir(d): continue
    for f in os.listdir(d):
        if not f.lower().endswith(('.png', '.jpg', '.jpeg')): continue
        base = os.path.splitext(f)[0]
        if not re.search(r'[\u4e00-\u9fff]', base): continue
        rel = f'Graphics/{sub}/{f}'
        raw_index.setdefault(base, rel)
        img_index.setdefault(strip_prefix(base), rel)

print('图片索引: 原始', len(raw_index), ' 规范化', len(img_index))

# 手工别名（游戏里的名字与文件名对不上时）
ALIAS = {
    '奈文摩尔': 'nevermore',      # Pictures/nevermore.png（唯一真正的立绘）
    '主角': None,
}

# ---------------- 3. 匹配 + 裁剪 ----------------
SKIP_AS_MONSTER = re.compile(
    r'战兵|法兵|甲兵|炮灰|粘液|凝聚物|巨人|骷髅|僵尸|虫|蛇|蝠|哈比|食人魔|龙人|地龙|骨龙|银龙|角龙|'
    r'寓鸟|陆战师|影武者|秘术师|武士|士兵|守卫|卫兵|盔甲|傀儡|石像|魔神像|传送|装置|大船|大地图|数字|光标|挂牌')

figures = []
for name, c in cnt.most_common():
    src = None
    if name in raw_index: src = raw_index[name]
    elif name in img_index: src = img_index[name]
    elif name in ALIAS and ALIAS[name]:
        a = ALIAS[name]
        for k, v in raw_index.items():
            if k.lower() == a.lower(): src = v; break
    if not src:
        continue
    figures.append({'name': name, 'lines': c, 'src': src})

print('匹配到形象的人物:', len(figures))

manifest = []
for fig in figures:
    src = fig['src']
    abs_path = os.path.join(ROOT, src.replace('/', os.sep))
    try:
        im = Image.open(abs_path).convert('RGBA')
    except Exception as e:
        print('  跳过', src, e); continue
    w, h = im.size
    kind = 'full'
    crop = im
    # 标准行走图 128x192 -> 取左上角第一帧（32x48，站立朝下）
    if w == 128 and h == 192:
        crop = im.crop((0, 0, 32, 48))
        kind = 'frame'
    elif w == 128 and h == 128:
        crop = im.crop((0, 0, 32, 32))
        kind = 'frame'
    # 放大 3 倍便于观看
    scale = 3
    crop = crop.resize((crop.width * scale, crop.height * scale), Image.NEAREST)
    safe = re.sub(r'[\\/:*?"<>|]', '_', fig['name'])
    out_name = safe + '.png'
    crop.save(os.path.join(SPR, out_name))
    manifest.append({'name': fig['name'], 'lines': fig['lines'], 'file': 'sprites/' + out_name,
                     'src': src, 'kind': kind, 'ow': w, 'oh': h,
                     'monsterish': bool(SKIP_AS_MONSTER.search(fig['name']))})

manifest.sort(key=lambda x: -x['lines'])
json.dump(manifest, open(os.path.join(OUT, 'figures.json'), 'w', encoding='utf-8'),
          ensure_ascii=False, indent=1)

print()
print('=== 生成形象卡片:', len(manifest), '===');
for m in manifest[:45]:
    tag = ' [疑似怪物]' if m['monsterish'] else ''
    print(f"  {m['lines']:>5} 句  {m['name']:<14} <- {m['src']} ({m['kind']}){tag}")
print(f'  ... 其余 {max(0, len(manifest)-45)} 个')
print()
print('输出目录:', OUT)
