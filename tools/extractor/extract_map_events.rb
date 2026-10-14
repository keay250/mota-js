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
  class Map
    attr_accessor :tileset_id, :width, :height, :autoplay_bgm, :bgm, :autoplay_bgs, :bgs, :encounter_list, :encounter_step, :data, :events
  end
  class Event
    attr_accessor :id, :name, :x, :y, :pages
  end
  class Event::Page
    attr_accessor :condition, :graphic, :move_type, :move_speed, :move_frequency, :move_route, :walk_anime, :step_anime, :direction_fix, :through, :always_on_top, :trigger, :list
  end
  class Event::Page::Condition
    attr_accessor :switch1_valid, :switch2_valid, :variable_valid, :self_switch_valid, :switch1_id, :switch2_id, :variable_id, :variable_value, :self_switch_ch
  end
  class Event::Page::Graphic
    attr_accessor :tile_id, :character_name, :character_hue, :direction, :pattern, :opacity, :blend_type
  end
  class EventCommand
    attr_accessor :code, :indent, :parameters
  end
  class MoveRoute
    attr_accessor :repeat, :skippable, :list
  end
  class MoveCommand
    attr_accessor :code, :parameters
  end
end

def s(str)
  str ? str.dup.force_encoding("UTF-8").scrub : ""
end

SCRIPT_DIR = File.dirname(File.expand_path(__FILE__))
PROJ_DIR = File.expand_path("../..", SCRIPT_DIR)
DATA_DIR = File.expand_path("../Data", PROJ_DIR)
OUT_DIR = File.join(PROJ_DIR, "docs", "extracted_data", "maps")
FileUtils.mkdir_p(OUT_DIR)

# 载入真值库
$enemies_truth = JSON.parse(File.read(File.join(PROJ_DIR, "docs", "extracted_data", "enemies_truth_table.json"))) rescue {}
$switches_vars = JSON.parse(File.read(File.join(PROJ_DIR, "docs", "extracted_data", "switches_and_variables.json"))) rescue {}

# 怪物代号映射表 (根据原版战斗事件 CE1/Troops 绑定)
MONSTER_CODE_MAP = {
  "怪物002" => 2,   # 荷依米
  "怪物003" => 3,   # 软泥怪
  "怪物004" => 4,   # 幽林鬼火
  "怪物005" => 5,   # 荷依米战士
  "怪物006" => 6,   # 倍荷玛
  "怪物007" => 7,   # 复活的死者
  "怪物008" => 8,   # 倍荷玛战士
  "怪物009" => 9,   # 嗜血死者
  "怪物010" => 10,  # 寒冰软泥怪
  "怪物011" => 11,  # 荷依米贵族
  "怪物012" => 12,  # 丛林幽影
  "怪物013" => 13,  # 流浪法师
  "怪物015" => 15   # 倍荷玛拉
}

def parse_map(mid)
  map_file = File.join(DATA_DIR, sprintf("Map%03d.rxdata", mid))
  return nil unless File.exist?(map_file)

  map = File.open(map_file, "rb") { |f| Marshal.load(f) }
  
  result = {
    "map_id" => mid,
    "width" => map.width,
    "height" => map.height,
    "tileset_id" => map.tileset_id,
    "bgm" => map.bgm ? s(map.bgm.name) : "",
    "teleports" => [],
    "monsters" => [],
    "special_doors" => [],
    "normal_doors" => [],
    "pickups" => [],
    "npcs" => [],
    "other_events" => []
  }

  map.events.sort_by { |k, v| k }.each do |eid, ev|
    name = s(ev.name)
    x, y = ev.x, ev.y
    first_page = ev.pages[0]
    char_name = first_page ? s(first_page.graphic&.character_name) : ""
    tile_id = first_page ? first_page.graphic&.tile_id : 0

    # 1. 检查传送事件 (code 201)
    teleport_cmd = nil
    dialogue_lines = []
    has_battle = false
    scripts = []

    ev.pages.each do |p|
      next unless p.list
      p.list.each do |cmd|
        if cmd.code == 201 # 场所移动
          teleport_cmd = cmd.parameters
        elsif cmd.code == 101 # 对话第一行
          dialogue_lines << s(cmd.parameters[0])
        elsif cmd.code == 401 # 对话后续行
          dialogue_lines << s(cmd.parameters[0])
        elsif cmd.code == 117 && cmd.parameters[0] == 1 # CE1 战斗
          has_battle = true
        elsif [355, 655].include?(cmd.code) # 脚本指令
          scripts << s(cmd.parameters[0])
        end
      end
    end

    if teleport_cmd
      target_mid = teleport_cmd[1]
      target_x = teleport_cmd[2]
      target_y = teleport_cmd[3]
      result["teleports"] << {
        "event_id" => eid,
        "name" => name,
        "x" => x, "y" => y,
        "target_map_id" => target_mid,
        "target_x" => target_x,
        "target_y" => target_y
      }
      next
    end

    # 2. 检查怪物
    if name.start_with?("怪物") || has_battle
      monster_id = MONSTER_CODE_MAP[name]
      m_truth = monster_id ? $enemies_truth[monster_id.to_s] : nil
      result["monsters"] << {
        "event_id" => eid,
        "code_name" => name,
        "x" => x, "y" => y,
        "character" => char_name,
        "enemy_id" => monster_id,
        "real_name" => m_truth ? m_truth["name"] : name,
        "hp" => m_truth ? m_truth["hp"] : nil,
        "atk" => m_truth ? m_truth["atk"] : nil,
        "def" => m_truth ? m_truth["def"] : nil,
        "exp" => m_truth ? m_truth["exp"] : nil,
        "gold" => m_truth ? m_truth["gold"] : nil
      }
      next
    end

    # 3. 检查机关门
    if name =~ /机关门|铁门/ || (char_name =~ /door|gate/i && scripts.any? { |sc| sc =~ /@sw/ })
      # 解析守护区域坐标
      guard_area = nil
      full_script = scripts.join("\n")
      if full_script =~ /x1=(\d+);\s*y1=(\d+);\s*x2=(\d+);\s*y2=(\d+)/
        guard_area = {
          "x1" => $1.to_i, "y1" => $2.to_i,
          "x2" => $3.to_i, "y2" => $4.to_i
        }
      end
      result["special_doors"] << {
        "event_id" => eid,
        "name" => name,
        "x" => x, "y" => y,
        "character" => char_name,
        "guard_area" => guard_area,
        "raw_script" => full_script
      }
      next
    end

    # 4. 检查普通门
    if name =~ /^(黄门|蓝门|红门)$/ || char_name =~ /Door/i
      door_type = "yellow"
      door_type = "blue" if name =~ /蓝门/
      door_type = "red" if name =~ /红门/
      result["normal_doors"] << {
        "event_id" => eid,
        "type" => door_type,
        "name" => name,
        "x" => x, "y" => y
      }
      next
    end

    # 5. 检查拾取道具
    if name =~ /钥匙|血瓶|宝石|生命上限|金币/
      result["pickups"] << {
        "event_id" => eid,
        "name" => name,
        "x" => x, "y" => y,
        "character" => char_name
      }
      next
    end

    # 6. 检查 NPC 与剧情对话
    if !dialogue_lines.empty? || (!char_name.empty? && tile_id == 0)
      result["npcs"] << {
        "event_id" => eid,
        "name" => name,
        "x" => x, "y" => y,
        "character" => char_name,
        "dialogue" => dialogue_lines
      }
      next
    end

    # 其余事件
    result["other_events"] << {
      "event_id" => eid,
      "name" => name,
      "x" => x, "y" => y,
      "character" => char_name
    }
  end

  result
end

# 针对第一章核心区域地图进行全量解析
target_maps = [
  7, 9, 10, 11, 12, 13, # 寂静之森外围系列 (MT1~MT5 及外围总图)
  14, 16, 22, 29, 30,   # 姆伊森运河系列
  15, 21, 23, 24, 25, 26, # 寂静之森深处系列
  17, 18, 19, 20,       # 厄泽城主城、装备商店、佣兵公会、瑞格沃酒馆
  27, 28, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43 # 莱尼克之墓系列
]

puts "=== 开始深度解析第一章核心地图 (#{target_maps.size} 张) ==="
parsed_count = 0
target_maps.each do |mid|
  data = parse_map(mid)
  next unless data
  out_file = File.join(OUT_DIR, sprintf("map_%03d.json", mid))
  File.open(out_file, "w:utf-8") { |f| f.write(JSON.pretty_generate(data)) }
  puts sprintf("[+] Map%03d 导出成功 -> 怪物:%2d, 传送:%2d, 机关门:%2d, 道具:%2d, NPC:%2d",
    mid, data["monsters"].size, data["teleports"].size, data["special_doors"].size, data["pickups"].size, data["npcs"].size)
  parsed_count += 1
end

puts "\n🎉 共成功深度解析并导出 #{parsed_count} 张地图详细事件数据！"
