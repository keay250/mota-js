# -*- coding: utf-8 -*-
"""提取数据库侧文本：物品 / 装备 / 技能 / 敌人 / 角色 / 公共事件 / 系统术语。
装备名会被解码成人话（利用 AGENTS.md §3.3 的词条表）。
"""
import os, sys, re, glob
sys.path.insert(0, r'D:\Games\永不复还(500F)\永不复还(500F)\_analysis')
from rubymarshal.reader import load

ROOT = r'D:\Games\永不复还(500F)\永不复还(500F)'
DATA = os.path.join(ROOT, 'Data')
OUTDIR = os.path.join(ROOT, '游戏文本档案')
os.makedirs(OUTDIR, exist_ok=True)

def A(o):
    a = getattr(o, 'attributes', None)
    return a if isinstance(a, dict) else {}

def dec(v):
    if isinstance(v, bytes):
        return v.decode('utf-8', 'replace')
    return v if isinstance(v, str) else str(v)

def loaddb(name):
    p = os.path.join(DATA, name)
    if not os.path.exists(p): return None
    try:
        return load(open(p, 'rb'))
    except Exception as e:
        print(f'  !! {name} 读取失败: {e}')
        return None

# 装备名词条（AGENTS.md §3.3）
TOKENS = {
    'BA': '穿甲', 'BL': '吸血倍率', 'GD': '防御', 'MA': '主属性',
    'MD': '魔抗', 'MH': '生命上限', 'MI': '闪避', 'MP': '法术能量',
    'MS': '魔法上限', 'SD': '技能伤害', 'SK': '全技能', 'SM': '技能消耗减少',
    'SR': '回蓝速度', 'A': '回血速度', 'C': '攻速', 'D': '护甲',
}

def decode_equip(name):
    parts = name.split(':')
    base, mods = parts[0], []
    for p in parts[1:]:
        hit = None
        for l in (2, 1):
            t = p[:l]
            if t in TOKENS:
                hit = (TOKENS[t], p[l:])
                break
        mods.append(hit if hit else ('?', p))
    return base, mods

def fmt_mods(mods):
    if not mods: return '—'
    return '、'.join(f'{k} {v}' if k != '?' else f'未知词条 `{v}`' for k, v in mods)

W = []
def w(s=''):
    W.append(s)

# ---------------------------------------------------------------- 物品
d = loaddb('Items.rxdata')
if d:
    w('# 物品图鉴')
    w('')
    w(f'*共 {len([x for x in d if x is not None])} 条*')
    w('')
    w('| ID | 名称 | 描述 |')
    w('|---|---|---|')
    for i, it in enumerate(d):
        if it is None: continue
        a = A(it)
        nm = dec(a.get('@name', ''))
        ds = dec(a.get('@description', '')).replace('\n', ' ')
        if not nm and not ds: continue
        w(f'| {i} | {nm or "—"} | {ds or "—"} |')
    w('')
    open(os.path.join(OUTDIR, '90-物品图鉴.md'), 'w', encoding='utf-8').write('\n'.join(W))
    print('  90-物品图鉴.md', len(W), '行')
    W.clear()

# ---------------------------------------------------------------- 装备
for fname, out, title in (('Weapons.rxdata', '91-装备图鉴.md', '装备图鉴（武器表）'),
                          ('Armors.rxdata', '91b-防具图鉴.md', '防具图鉴')):
    d = loaddb(fname)
    if not d: continue
    W.append(f'# {title}')
    W.append('')
    W.append(f'*共 {len([x for x in d if x is not None])} 条。装备名里的词条已解码为效果（词条表见 `AGENTS.md` §3.3）*')
    W.append('')
    W.append('| ID | 名称 | 效果 | 价格 | 攻击 | 力量 | 说明 |')
    W.append('|---|---|---|---|---|---|---|')
    rows = []
    for i, it in enumerate(d):
        if it is None: continue
        a = A(it)
        raw = dec(a.get('@name', ''))
        if not raw: continue
        base, mods = decode_equip(raw)
        desc = dec(a.get('@description', '')).replace('\n', ' ')
        rows.append((i, base, fmt_mods(mods), raw, a.get('@price'), a.get('@atk'),
                     a.get('@str_plus'), desc))
    for i, base, eff, raw, price, atk, sp, desc in rows:
        star = ' ★' if i in (130, 132) else ''
        w(f'| {i} | {base}{star} | {eff} | {price} | {atk} | {sp} | {desc or "—"} |')
    W.append('')
    W.append('## 原始名对照（含完整词条）')
    W.append('')
    for i, base, eff, raw, *_ in rows:
        if raw != base:
            w(f'- `{i}` `{raw}` → **{eff}**')
    W.append('')
    open(os.path.join(OUTDIR, out), 'w', encoding='utf-8').write('\n'.join(W))
    print(f'  {out}', len(W), '行')
    W.clear()

# ---------------------------------------------------------------- 技能
d = loaddb('Skills.rxdata')
if d:
    w('# 技能图鉴')
    w('')
    w(f'*共 {len([x for x in d if x is not None])} 条*')
    w('')
    w('| ID | 名称 | 消耗SP | 威力 | 描述 |')
    w('|---|---|---|---|---|')
    for i, it in enumerate(d):
        if it is None: continue
        a = A(it)
        nm = dec(a.get('@name', ''))
        if not nm: continue
        ds = dec(a.get('@description', '')).replace('\n', ' ')
        w(f'| {i} | {nm} | {a.get("@sp_cost")} | {a.get("@power")} | {ds or "—"} |')
    w('')
    open(os.path.join(OUTDIR, '92-技能图鉴.md'), 'w', encoding='utf-8').write('\n'.join(W))
    print('  92-技能图鉴.md', len(W), '行')
    W.clear()

# ---------------------------------------------------------------- 敌人
d = loaddb('Enemies.rxdata')
if d:
    w('# 敌人图鉴')
    w('')
    w(f'*共 {len([x for x in d if x is not None])} 条*')
    w('')
    w('| ID | 名称 | HP | SP | 攻击 | 防御 | 魔防 | 敏捷 | 经验 | 金钱 |')
    w('|---|---|---|---|---|---|---|---|---|---|')
    for i, it in enumerate(d):
        if it is None: continue
        a = A(it)
        nm = dec(a.get('@name', ''))
        if not nm: continue
        w(f'| {i} | {nm} | {a.get("@maxhp")} | {a.get("@maxsp")} | {a.get("@atk")} | '
          f'{a.get("@pdef")} | {a.get("@mdef")} | {a.get("@agi")} | {a.get("@exp")} | {a.get("@gold")} |')
    w('')
    open(os.path.join(OUTDIR, '93-敌人图鉴.md'), 'w', encoding='utf-8').write('\n'.join(W))
    print('  93-敌人图鉴.md', len(W), '行')
    W.clear()

# ---------------------------------------------------------------- 角色 / 职业 / 状态
w('# 角色 · 职业 · 状态')
w('')
for fname, title in (('Actors.rxdata', '角色'), ('Classes.rxdata', '职业'), ('States.rxdata', '状态')):
    d = loaddb(fname)
    if not d: continue
    w(f'## {title}')
    w('')
    for i, it in enumerate(d):
        if it is None: continue
        a = A(it)
        nm = dec(a.get('@name', ''))
        if not nm: continue
        extra = []
        for f, lab in (('@description', '说明'), ('@parameter_names', ''), ('@str_plus', '力量+'),
                       ('@dex_plus', '敏捷+'), ('@agi_plus', '速度+'), ('@int_plus', '智力+')):
            v = a.get(f)
            if v and not isinstance(v, list):
                extra.append(f'{lab}{dec(v)}')
        w(f'- **{i} · {nm}**' + (' ｜ ' + '、'.join(extra) if extra else ''))
    w('')
open(os.path.join(OUTDIR, '94-角色职业状态.md'), 'w', encoding='utf-8').write('\n'.join(W))
print('  94-角色职业状态.md', len(W), '行')
W.clear()

# ---------------------------------------------------------------- 公共事件
d = loaddb('CommonEvents.rxdata')
if d:
    w('# 公共事件文本')
    w('')
    CN = re.compile(r'[\u4e00-\u9fff]')
    for i, it in enumerate(d):
        if it is None: continue
        a = A(it)
        nm = dec(a.get('@name', ''))
        cmds = [A(c) for c in (a.get('@list') or [])]
        blocks, k = [], 0
        while k < len(cmds):
            c = cmds[k]
            if c.get('@code') == 101:
                blk = []
                k += 1
                while k < len(cmds) and cmds[k].get('@code') == 401:
                    blk.append(dec((cmds[k].get('@parameters') or [''])[0]))
                    k += 1
                if any(x.strip() for x in blk):
                    blocks.append(blk)
                continue
            k += 1
        if not blocks and not (nm and CN.search(nm)):
            continue
        w(f'## [{i}] {nm or "(未命名公共事件)"}')
        w('')
        for b in blocks:
            for line in b:
                w(f'> {line}')
            w('>')
            if W and W[-1] == '>': W.pop()
            w('')
    open(os.path.join(OUTDIR, '95-公共事件文本.md'), 'w', encoding='utf-8').write('\n'.join(W))
    print('  95-公共事件文本.md', len(W), '行')
    W.clear()

# ---------------------------------------------------------------- 系统术语
d = loaddb('System.rxdata')
if d:
    a = A(d)
    w('# 系统术语与菜单文本')
    w('')
    terms = a.get('@terms')
    if isinstance(terms, dict):
        w('## 术语')
        w('')
        for k, v in terms.items():
            w(f'- `{k}` = {dec(v)}')
        w('')
    words = a.get('@words')
    if isinstance(words, dict):
        w('## 菜单词条')
        w('')
        for k, v in words.items():
            w(f'- `{k}` = {dec(v)}')
        w('')
    for f, lab in (('@game_title', '游戏标题'), ('@currency_unit', '货币单位')):
        if a.get(f):
            w(f'- **{lab}**：{dec(a.get(f))}')
    w('')
    open(os.path.join(OUTDIR, '96-系统术语.md'), 'w', encoding='utf-8').write('\n'.join(W))
    print('  96-系统术语.md', len(W), '行')

print('数据库文本提取完成')
