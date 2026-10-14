# -*- coding: utf-8 -*-
"""
生成全城镇与室内建筑专项采集与移植规划报告
"""
import os, json

BASE_DIR = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
TOWNS_DIR = os.path.join(BASE_DIR, "docs", "extracted_data", "towns")

def main():
    manifest_path = os.path.join(TOWNS_DIR, "towns_manifest.json")
    if not os.path.exists(manifest_path):
        print("[-] 未找到 towns_manifest.json")
        return

    with open(manifest_path, "r", encoding="utf-8") as f:
        manifest = json.load(f)

    report = []
    report.append("# 《永不复还》全城镇与室内生活区专项采集与规划报告\n")
    report.append(f"**生成时间**: 2026-10-14  ")
    report.append(f"**数据来源**: 原版 `Data/*.rxdata` (城镇、公会、商店、酒馆、码头、营地等)  ")
    report.append(f"**采集产物路径**: `docs/extracted_data/towns/`  \n")
    report.append("---\n")

    report.append("## 1. 城镇与生活区全景看板\n")
    report.append(f"| 区域大系 | 地图ID | 建筑/区域名称 | 尺寸 | 出入口数 | 商店数 | NPC人数 | 告示牌 |")
    report.append(f"| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |")

    total_npcs = 0
    total_shops = 0
    total_doorways = 0

    for item in manifest:
        mid = item["map_id"]
        total_npcs += item["npcs_count"]
        total_shops += item["shops_count"]
        total_doorways += item["doorways_count"]
        report.append(f"| **{item['group']}** | Map{mid:03d} | {item['name']} ({item['role']}) | {item['width']}x{item['height']} | {item['doorways_count']} | {item['shops_count']} | {item['npcs_count']} | {item['bulletins_count']} |")

    report.append(f"\n> **统计汇总**: 本次共深度采集 **{len(manifest)}** 张城镇与生活区地图，包含 **{total_npcs}** 个独立 NPC / 剧情事件、**{total_shops}** 组系统级商业交易柜台，以及 **{total_doorways}** 处建筑内外互联出入口！\n")
    report.append("\n---\n")

    report.append("## 2. 商业体系与商店交易详单 (Shops Truth Table)\n")
    # 遍历所有含有 shops 的 json
    for item in manifest:
        if item["shops_count"] == 0:
            continue
        mid = item["map_id"]
        town_json_path = os.path.join(TOWNS_DIR, f"town_{mid:03d}.json")
        if not os.path.exists(town_json_path):
            continue
        with open(town_json_path, "r", encoding="utf-8") as f:
            t_data = json.load(f)

        report.append(f"### 🏪 Map{mid:03d} 【{t_data['name']}】({t_data['role']})\n")
        for sh in t_data.get("shops", []):
            report.append(f"- **店主/柜台**: `{sh['name']}` (点位: `({sh['x']}, {sh['y']})`, 行走图: `{sh['character']}`)")
            report.append("  | 货品类型 | 物品名称 | 售价 (金币) | 图标资源 |")
            report.append("  | :--- | :--- | :--- | :--- |")
            for g in sh.get("goods", []):
                t_label = "道具" if g["type"] == 0 else ("武器" if g["type"] == 1 else "防具")
                report.append(f"  | {t_label} | **{g['name']}** | {g['price']} G | `{g['icon']}` |")
            report.append("\n")

    report.append("---\n")
    report.append("## 3. 核心城镇出入口与建筑网络拓扑 (Town Portal Network)\n")
    report.append("彻底理清玩家在城市街道与各室内建筑之间的双向传送点：\n")
    report.append("| 起始地图 | 起始点位 | 目标建筑/场景 | 落地目标坐标 | 传送门名称 |")
    report.append("| :--- | :--- | :--- | :--- | :--- |")
    for item in manifest:
        mid = item["map_id"]
        town_json_path = os.path.join(TOWNS_DIR, f"town_{mid:03d}.json")
        if not os.path.exists(town_json_path):
            continue
        with open(town_json_path, "r", encoding="utf-8") as f:
            t_data = json.load(f)
        for dw in t_data.get("doorways", []):
            report.append(f"| Map{mid:03d} {t_data['name']} | `({dw['x']}, {dw['y']})` | Map{dw['to_map_id']:03d} **{dw['to_map_name']}** | `({dw['to_pos'][0]}, {dw['to_pos'][1]})` | `{dw['name']}` |")

    report.append("\n---\n")
    report.append("## 4. 关键剧情 NPC 与任务线索一览 (Key Story NPCs)\n")
    key_npcs = [
        {"mid": 17, "name": "格瑞迪", "desc": "厄泽城主线引导人"},
        {"mid": 19, "name": "执事", "desc": "佣兵公会任务委托核心负责人"},
        {"mid": 19, "name": "重装佣兵", "desc": "阻挡玩家进入公会深处的卫兵"},
        {"mid": 20, "name": "老板娘", "desc": "瑞格沃酒馆情报与剧情互动"},
        {"mid": 58, "name": "法芙娜", "desc": "全作核心女主角，触发第一章大转场前往王都"},
        {"mid": 64, "name": "铁匠学徒", "desc": "普利斯特王都装备锻造与高级合成"},
        {"mid": 66, "name": "职业者接待员", "desc": "王都佣兵公会进阶职业考核与任务"}
    ]
    report.append("| 所属地图 | NPC 姓名 | 角色定位与剧情任务关联 |")
    report.append("| :--- | :--- | :--- |")
    for kn in key_npcs:
        report.append(f"| Map{kn['mid']:03d} | **{kn['name']}** | {kn['desc']} |")

    report.append("\n---\n")
    report.append("## 5. 城镇系统在 Mota-js 中的落地架构设计\n")
    report.append("1. **大地图视口架构**：厄泽城 (75x75) 与王都 (93x45) 超出魔塔默认 15x15 视口，采用魔塔动态摄像机跟随（`core.setViewport` / `bigmap` 模式），保持宏伟的城市探索感。")
    report.append("2. **统一商店面板插件**：基于提取的 `shops` 货品真值，直接对接魔塔的自定义商店插件 (`quickShop` / `customShop`)，支持买卖与神装锻造。")
    report.append("3. **NPC 气泡与立绘对话系统**：基于提取的 `dialogue_tree`，实现多轮推进、选择支判定以及剧情任务开关无缝衔接。")

    out_file = os.path.join(TOWNS_DIR, "TOWNS_PLANNING_REPORT.md")
    with open(out_file, "w", encoding="utf-8") as f:
        f.write("\n".join(report))
    print(f"[+] 城镇规划报告已生成至: {out_file}")

if __name__ == "__main__":
    main()
