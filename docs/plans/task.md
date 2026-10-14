# 原版资产自动化全量提取与数据规划工程任务清单

## 目标
从原版工程 (`../Data/*.rxdata` 及 `../Graphics/`) 中自动化提取全量核心数据资产（怪物真值表、道具装备表、全地图事件拓扑、机关门与NPC对话），建立标准结构化数据规划库 (`docs/extracted_data/`)，为接下来的高质量流水线移植提供权威事实依据。

## 里程碑计划

- [x] **Milestone 1: 基础字典与怪物真值库提取**
  - [x] 提取原版系统开关（Switches）与变量（Variables）语义字典 -> `switches_and_variables.json` (172个开关, 283个变量)
  - [x] 提取全量怪物数据（Enemies.rxdata）与技能（Skills.rxdata）映射 -> `enemies_truth_table.json` (803个怪物形态)
  - [x] 提取全量道具、武器、防具数据（Items/Weapons/Armors.rxdata） -> `items_truth_table.json` (117道具, 138武器, 1防具)
  - [x] 提取全量技能数据（Skills.rxdata） -> `skills_truth_table.json` (225个技能)

- [x] **Milestone 2: 全地图目录与传送拓扑提取**
  - [x] 解析 MapInfos.rxdata，构建全 576 张地图的层次结构与章节归属 -> `maps_catalog.json`
  - [x] 提取核心地图（第一章/寂静之森/厄泽城/运河/莱尼克之墓）的出入口传送阵与楼梯拓扑 -> `teleport_network.json` (86条跨图链接)

- [x] **Milestone 3: 地图事件与机关门深度解析器**
  - [x] 编写事件解析器，提取地图中所有怪物坐标、NPC事件/对话、机关门触发条件、宝箱掉落 -> `map_events/<map_id>.json`
  - [x] 批量生成第一章 36 张核心地图的结构化事件真值表 (`docs/extracted_data/maps/map_*.json`)

- [x] **Milestone 4: 规划与校验报告生成**
  - [x] 对比当前已移植的楼层（MT1~MT5、Eze城等），生成差异与遗漏审计报告 -> `docs/extracted_data/AUDIT_AND_PLANNING_REPORT.md`
  - [ ] 提交并推送到 GitHub 远程仓库
