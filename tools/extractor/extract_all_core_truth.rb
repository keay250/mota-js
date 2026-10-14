# -*- coding: utf-8 -*-
require "json"
require "fileutils"

# 桩类定义
class Tone; def self._load(s); s; end; end
class Color; def self._load(s); s; end; end
class Table; def self._load(s); s; end; end

module RPG
  class AudioFile
    attr_accessor :name, :volume, :pitch
  end
  class MapInfo
    attr_accessor :name, :parent_id, :order, :expanded, :scroll_x, :scroll_y
  end
  class System
    class Words
      attr_accessor :gold, :hp, :sp, :str, :dex, :agi, :int, :atk, :pdef, :mdef, :weapon, :armor1, :armor2, :armor3, :armor4, :attack, :skill, :guard, :item, :equip
    end
    class TestBattler
      attr_accessor :actor_id, :level, :weapon_id, :armor1_id, :armor2_id, :armor3_id, :armor4_id
    end
    attr_accessor :magic_number, :switches, :variables, :windowskin_name, :title_name, :gameover_name, :battle_transition, :title_bgm, :battle_bgm, :battle_end_me, :gameover_me, :cursor_se, :decision_se, :cancel_se, :buzzer_se, :equip_se, :shop_se, :save_se, :load_se, :battle_start_se, :escape_se, :actor_collapse_se, :enemy_collapse_se, :words, :test_battlers, :test_troop_id, :start_map_id, :start_x, :start_y, :battleback_name, :battler_name, :battler_hue, :edit_map_id
  end
  class Enemy
    class Action
      attr_accessor :kind, :basic, :skill_id, :condition_turn_a, :condition_turn_b, :condition_hp, :condition_level, :condition_switch_id, :rating
    end
    attr_accessor :id, :name, :battler_name, :battler_hue, :maxhp, :maxsp, :str, :dex, :agi, :int, :atk, :pdef, :mdef, :eva, :exp, :gold, :item_id, :weapon_id, :armor_id, :drop_prob, :actions
  end
  class Skill
    attr_accessor :id, :name, :description, :scope, :sp_cost, :power, :atk_f, :eva_f, :str_f, :dex_f, :agi_f, :int_f, :pdef_f, :mdef_f, :variance, :plus_state_set, :minus_state_set
  end
  class Item
    attr_accessor :id, :name, :description, :icon_name, :scope, :price, :consumable, :recover_hp_rate, :recover_hp, :recover_sp_rate, :recover_sp, :parameter_type, :parameter_points
  end
  class Weapon
    attr_accessor :id, :name, :description, :icon_name, :price, :atk, :pdef, :mdef, :str_plus, :dex_plus, :agi_plus, :int_plus, :element_set, :plus_state_set, :minus_state_set
  end
  class Armor
    attr_accessor :id, :name, :description, :icon_name, :kind, :auto_state_id, :price, :pdef, :mdef, :eva, :str_plus, :dex_plus, :agi_plus, :int_plus, :guard_element_set, :guard_state_set
  end
end

def s(str)
  str ? str.dup.force_encoding("UTF-8").scrub : ""
end

SCRIPT_DIR = File.dirname(File.expand_path(__FILE__))
PROJ_DIR = File.expand_path("../..", SCRIPT_DIR)
DATA_DIR = File.expand_path("../Data", PROJ_DIR)
OUT_DIR = File.join(PROJ_DIR, "docs", "extracted_data")
FileUtils.mkdir_p(OUT_DIR)

puts "[*] Project Dir: #{PROJ_DIR}"
puts "[*] Data Dir: #{DATA_DIR}"
puts "[*] Output Dir: #{OUT_DIR}"

# 1. 提取开关与变量字典
puts "\n[1/5] 提取系统开关与变量语义名录..."
sys = File.open(File.join(DATA_DIR, "System.rxdata"), "rb") { |f| Marshal.load(f) }
switches_dict = {}
sys.switches.each_with_index do |name, idx|
  next if idx == 0 || name.nil? || name.empty?
  switches_dict[idx] = s(name)
end
variables_dict = {}
sys.variables.each_with_index do |name, idx|
  next if idx == 0 || name.nil? || name.empty?
  variables_dict[idx] = s(name)
end
sys_out = {
  "total_switches" => sys.switches.size,
  "named_switches_count" => switches_dict.size,
  "switches" => switches_dict,
  "total_variables" => sys.variables.size,
  "named_variables_count" => variables_dict.size,
  "variables" => variables_dict
}
File.open(File.join(OUT_DIR, "switches_and_variables.json"), "w:utf-8") do |f|
  f.write(JSON.pretty_generate(sys_out))
end
puts "[+] switches_and_variables.json 生成完毕 (命名开关: #{switches_dict.size}, 命名变量: #{variables_dict.size})"

# 2. 提取全技能库
puts "\n[2/5] 提取全技能真值库..."
skills_raw = File.open(File.join(DATA_DIR, "Skills.rxdata"), "rb") { |f| Marshal.load(f) }
skills_dict = {}
skills_raw.compact.each do |sk|
  name = s(sk.name)
  next if name.empty?
  skills_dict[sk.id] = {
    "id" => sk.id,
    "name" => name,
    "description" => s(sk.description),
    "sp_cost" => sk.sp_cost,
    "power" => sk.power,
    "scope" => sk.scope,
    "plus_state_set" => sk.plus_state_set,
    "minus_state_set" => sk.minus_state_set
  }
end
File.open(File.join(OUT_DIR, "skills_truth_table.json"), "w:utf-8") do |f|
  f.write(JSON.pretty_generate(skills_dict))
end
puts "[+] skills_truth_table.json 生成完毕 (有效技能数: #{skills_dict.size})"

# 3. 提取全怪物真值库
puts "\n[3/5] 提取全量怪物真值库 (关联数值、技能与行动)..."
enemies_raw = File.open(File.join(DATA_DIR, "Enemies.rxdata"), "rb") { |f| Marshal.load(f) }
enemies_dict = {}
enemies_raw.compact.each do |e|
  name = s(e.name)
  next if name.empty? || name == "系统保留"

  # 解析怪兽行动与技能
  actions_list = []
  if e.actions
    e.actions.each do |act|
      act_info = {
        "kind" => act.kind, # 0=基本, 1=技能
        "basic" => act.basic,
        "skill_id" => act.skill_id,
        "rating" => act.rating
      }
      if act.kind == 1 && skills_dict[act.skill_id]
        act_info["skill_name"] = skills_dict[act.skill_id]["name"]
        act_info["skill_desc"] = skills_dict[act.skill_id]["description"]
      end
      actions_list << act_info
    end
  end

  # 清洗名称（例如 "软泥怪:1" -> clean_name="软泥怪"）
  clean_name = name.split(":").first

  enemies_dict[e.id] = {
    "id" => e.id,
    "name" => name,
    "clean_name" => clean_name,
    "hp" => e.maxhp,
    "atk" => e.atk,
    "def" => e.pdef,
    "mdef" => e.mdef,
    "str" => e.str,
    "dex" => e.dex,
    "agi" => e.agi,
    "int" => e.int,
    "exp" => e.exp,
    "gold" => e.gold,
    "battler_name" => s(e.battler_name),
    "drop_item_id" => e.item_id,
    "drop_prob" => e.drop_prob,
    "actions" => actions_list
  }
end
File.open(File.join(OUT_DIR, "enemies_truth_table.json"), "w:utf-8") do |f|
  f.write(JSON.pretty_generate(enemies_dict))
end
puts "[+] enemies_truth_table.json 生成完毕 (有效怪物总数: #{enemies_dict.size})"

# 4. 提取全量道具与装备真值库
puts "\n[4/5] 提取全量道具与装备真值库..."
items_raw = File.open(File.join(DATA_DIR, "Items.rxdata"), "rb") { |f| Marshal.load(f) }
weapons_raw = File.open(File.join(DATA_DIR, "Weapons.rxdata"), "rb") { |f| Marshal.load(f) }
armors_raw = File.open(File.join(DATA_DIR, "Armors.rxdata"), "rb") { |f| Marshal.load(f) }

items_registry = {
  "items" => {},
  "weapons" => {},
  "armors" => {}
}

items_raw.compact.each do |it|
  name = s(it.name)
  next if name.empty?
  items_registry["items"][it.id] = {
    "id" => it.id,
    "name" => name,
    "description" => s(it.description),
    "icon_name" => s(it.icon_name),
    "price" => it.price,
    "consumable" => it.consumable,
    "recover_hp" => it.recover_hp,
    "recover_hp_rate" => it.recover_hp_rate,
    "recover_sp" => it.recover_sp,
    "recover_sp_rate" => it.recover_sp_rate,
    "parameter_type" => it.parameter_type,
    "parameter_points" => it.parameter_points
  }
end

weapons_raw.compact.each do |w|
  name = s(w.name)
  next if name.empty?
  items_registry["weapons"][w.id] = {
    "id" => w.id,
    "name" => name,
    "description" => s(w.description),
    "icon_name" => s(w.icon_name),
    "price" => w.price,
    "atk" => w.atk,
    "pdef" => w.pdef,
    "mdef" => w.mdef,
    "str_plus" => w.str_plus,
    "dex_plus" => w.dex_plus,
    "agi_plus" => w.agi_plus,
    "int_plus" => w.int_plus
  }
end

armors_raw.compact.each do |a|
  name = s(a.name)
  next if name.empty?
  items_registry["armors"][a.id] = {
    "id" => a.id,
    "name" => name,
    "description" => s(a.description),
    "icon_name" => s(a.icon_name),
    "kind" => a.kind, # 0=盾, 1=头盔, 2=铠甲, 3=饰品/饰物
    "price" => a.price,
    "pdef" => a.pdef,
    "mdef" => a.mdef,
    "eva" => a.eva,
    "str_plus" => a.str_plus,
    "dex_plus" => a.dex_plus,
    "agi_plus" => a.agi_plus,
    "int_plus" => a.int_plus
  }
end

File.open(File.join(OUT_DIR, "items_truth_table.json"), "w:utf-8") do |f|
  f.write(JSON.pretty_generate(items_registry))
end
puts "[+] items_truth_table.json 生成完毕 (道具: #{items_registry['items'].size}, 武器: #{items_registry['weapons'].size}, 防具: #{items_registry['armors'].size})"

# 5. 提取全地图树状目录
puts "\n[5/5] 提取全 576 张地图拓扑与目录清单..."
map_infos = File.open(File.join(DATA_DIR, "MapInfos.rxdata"), "rb") { |f| Marshal.load(f) }
maps_catalog = {}
map_infos.sort_by { |k, v| k }.each do |id, info|
  name = s(info.name)
  maps_catalog[id] = {
    "id" => id,
    "name" => name,
    "parent_id" => info.parent_id,
    "order" => info.order,
    "scroll_x" => info.scroll_x,
    "scroll_y" => info.scroll_y
  }
end
File.open(File.join(OUT_DIR, "maps_catalog.json"), "w:utf-8") do |f|
  f.write(JSON.pretty_generate(maps_catalog))
end
puts "[+] maps_catalog.json 生成完毕 (总地图数: #{maps_catalog.size})"

puts "\n🎉 Milestone 1 核心数据真值库全量提取完毕！"
