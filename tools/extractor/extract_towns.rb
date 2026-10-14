# -*- coding: utf-8 -*-
require "json"
require "fileutils"

# 桩类定义
class Tone; def self._load(s); s; end; end
class Color; def self._load(s); s; end; end
class Table; def self._load(s); s; end; end

module RPG
  class AudioFile; attr_accessor :name, :volume, :pitch; end
  class Map; attr_accessor :tileset_id, :width, :height, :autoplay_bgm, :bgm, :autoplay_bgs, :bgs, :encounter_list, :encounter_step, :data, :events; end
  class Event; attr_accessor :id, :name, :x, :y, :pages; end
  class Event::Page; attr_accessor :condition, :graphic, :move_type, :move_speed, :move_frequency, :move_route, :walk_anime, :step_anime, :direction_fix, :through, :always_on_top, :trigger, :list; end
  class Event::Page::Condition; attr_accessor :switch1_valid, :switch2_valid, :variable_valid, :self_switch_valid, :switch1_id, :switch2_id, :variable_id, :variable_value, :self_switch_ch; end
  class Event::Page::Graphic; attr_accessor :tile_id, :character_name, :character_hue, :direction, :pattern, :opacity, :blend_type; end
  class EventCommand; attr_accessor :code, :indent, :parameters; end
  class MoveRoute; attr_accessor :repeat, :skippable, :list; end
  class MoveCommand; attr_accessor :code, :parameters; end
end

def s(str)
  str ? str.dup.force_encoding("UTF-8").scrub : ""
end

SCRIPT_DIR = File.dirname(File.expand_path(__FILE__))
PROJ_DIR = File.expand_path("../..", SCRIPT_DIR)
DATA_DIR = File.expand_path("../Data", PROJ_DIR)
OUT_DIR = File.join(PROJ_DIR, "docs", "extracted_data", "towns")
FileUtils.mkdir_p(OUT_DIR)

# 载入公共真值字典
MAP_CATALOG = JSON.parse(File.read(File.join(PROJ_DIR, "docs", "extracted_data", "maps_catalog.json"))) rescue {}
ITEMS_TRUTH = JSON.parse(File.read(File.join(PROJ_DIR, "docs", "extracted_data", "items_truth_table.json"))) rescue {}
SWITCHES_VARS = JSON.parse(File.read(File.join(PROJ_DIR, "docs", "extracted_data", "switches_and_variables.json"))) rescue {}

# 重点城镇与室内地图清单
TOWN_MAPS = [
  # 厄泽城大系 (第一章核心枢纽)
  {"mid" => 17, "group" => "厄泽城大系", "role" => "厄泽城主城 (75x75)"},
  {"mid" => 18, "group" => "厄泽城大系", "role" => "装备商店"},
  {"mid" => 19, "group" => "厄泽城大系", "role" => "佣兵公会"},
  {"mid" => 20, "group" => "厄泽城大系", "role" => "瑞格沃酒馆"},
  {"mid" => 48, "group" => "厄泽城大系", "role" => "公会右侧回廊"},
  {"mid" => 58, "group" => "厄泽城大系", "role" => "屋内 (法芙娜寓所)"},
  {"mid" => 59, "group" => "厄泽城大系", "role" => "厄泽城码头"},
  {"mid" => 60, "group" => "厄泽城大系", "role" => "去往王都的船"},
  {"mid" => 56, "group" => "厄泽城大系", "role" => "商船甲板"},
  {"mid" => 57, "group" => "厄泽城大系", "role" => "船舱内部"},

  # 普利斯特王都大系 (第二章核心王城)
  {"mid" => 61, "group" => "普利斯特王都大系", "role" => "王都港口"},
  {"mid" => 62, "group" => "普利斯特王都大系", "role" => "王都北区"},
  {"mid" => 63, "group" => "普利斯特王都大系", "role" => "普利斯特王都核心城区 (93x45)"},
  {"mid" => 64, "group" => "普利斯特王都大系", "role" => "装备&&合成商店"},
  {"mid" => 66, "group" => "普利斯特王都大系", "role" => "王都佣兵公会"},

  # 边境商队与营地
  {"mid" => 85, "group" => "边境营地与商会", "role" => "沙漠商人营地"},
  {"mid" => 86, "group" => "边境营地与商会", "role" => "营地主帐篷"},

  # 弧光城大系
  {"mid" => 143, "group" => "弧光城大系", "role" => "弧光城"},
  {"mid" => 147, "group" => "弧光城大系", "role" => "装备商店"},
  {"mid" => 148, "group" => "弧光城大系", "role" => "魔法商店"},
  {"mid" => 149, "group" => "弧光城大系", "role" => "狩猎会所"},

  # 荒原集镇
  {"mid" => 269, "group" => "荒原集镇大系", "role" => "荒原集镇"},
  {"mid" => 270, "group" => "荒原集镇大系", "role" => "荒原道具店"},
  {"mid" => 271, "group" => "荒原集镇大系", "role" => "荒原装备店"}
]

def parse_town_map(info)
  mid = info["mid"]
  p = File.join(DATA_DIR, sprintf("Map%03d.rxdata", mid))
  return nil unless File.exist?(p)

  map = File.open(p, "rb") { |f| Marshal.load(f) }
  m_name = MAP_CATALOG[mid.to_s] ? MAP_CATALOG[mid.to_s]["name"] : "未知城镇"

  town_data = {
    "map_id" => mid,
    "name" => m_name,
    "group" => info["group"],
    "role" => info["role"],
    "width" => map.width,
    "height" => map.height,
    "tileset_id" => map.tileset_id,
    "bgm" => map.bgm ? s(map.bgm.name) : "",
    "doorways" => [],      # 建筑与传送出入口
    "shops" => [],         # 商店交易柜台
    "npcs" => [],          # 具有对话或任务的NPC
    "bulletins" => [],     # 告示牌/路牌
    "interactables" => [], # 宝箱/隐藏物资/调查点
    "events_count" => map.events.size
  }

  map.events.sort_by { |k, v| k }.each do |eid, ev|
    name = s(ev.name)
    x, y = ev.x, ev.y
    first_page = ev.pages[0]
    char_name = first_page ? s(first_page.graphic&.character_name) : ""
    tile_id = first_page ? first_page.graphic&.tile_id : 0

    # 1. 传送出入口 (code 201)
    teleport_param = nil
    shop_goods = []
    dialogues_by_page = []
    is_bulletin = (name =~ /路牌|告示|牌子/ || char_name =~ /Bulletin/i)

    ev.pages.each_with_index do |page, pidx|
      cond = page.condition
      cond_info = {}
      if cond
        cond_info["switch1"] = cond.switch1_valid ? cond.switch1_id : nil
        cond_info["switch2"] = cond.switch2_valid ? cond.switch2_id : nil
        cond_info["variable"] = cond.variable_valid ? { "id" => cond.variable_id, "val" => cond.variable_value } : nil
        cond_info["self_switch"] = cond.self_switch_valid ? s(cond.self_switch_ch) : nil
      end

      page_dialogue = []
      current_msg = []
      choices = []

      next unless page.list
      page.list.each do |cmd|
        if cmd.code == 201 # 场所移动
          teleport_param = cmd.parameters
        elsif cmd.code == 101 # 对话开始
          current_msg << s(cmd.parameters[0])
        elsif cmd.code == 401 # 对话续行
          current_msg << s(cmd.parameters[0])
        elsif cmd.code == 102 # 选项分支
          choices = cmd.parameters[0].map { |c| s(c) }
        elsif cmd.code == 302 # 商店处理 (goods)
          # cmd.parameters: [goods_type, item_id, price, ...]
          # RMXP 302 parameters 通常记录售卖项目
          goods_type = cmd.parameters[0] # 0=道具, 1=武器, 2=防具
          goods_id = cmd.parameters[1]
          shop_goods << {
            "type" => goods_type,
            "item_id" => goods_id
          }
        elsif cmd.code == 605 # 商店货物续项
          goods_type = cmd.parameters[0]
          goods_id = cmd.parameters[1]
          shop_goods << {
            "type" => goods_type,
            "item_id" => goods_id
          }
        end
      end

      if !current_msg.empty? || !choices.empty?
        dialogues_by_page << {
          "page" => pidx,
          "condition" => cond_info,
          "text" => current_msg.join("\n"),
          "choices" => choices
        }
      end
    end

    # 分类收录判定
    # 如果事件有行走图或者有剧情对话，优先作为 NPC 处理（即使剧情最终触发了地图转场）！
    is_real_npc = (!char_name.empty? && tile_id == 0) || !dialogues_by_page.empty?

    if is_real_npc && !name.start_with?("EV") && !is_bulletin && shop_goods.empty?
      npc_info = {
        "event_id" => eid,
        "name" => name,
        "x" => x, "y" => y,
        "character" => char_name,
        "dialogue_tree" => dialogues_by_page
      }
      if teleport_param
        npc_info["trigger_teleport"] = {
          "to_map_id" => teleport_param[1],
          "to_map_name" => MAP_CATALOG[teleport_param[1].to_s] ? MAP_CATALOG[teleport_param[1].to_s]["name"] : "目标地图",
          "to_pos" => [teleport_param[2], teleport_param[3]]
        }
      end
      town_data["npcs"] << npc_info
      next
    end

    if teleport_param
      target_mid = teleport_param[1]
      target_name = MAP_CATALOG[target_mid.to_s] ? MAP_CATALOG[target_mid.to_s]["name"] : "目标地图"
      town_data["doorways"] << {
        "event_id" => eid,
        "name" => name,
        "x" => x, "y" => y,
        "to_map_id" => target_mid,
        "to_map_name" => target_name,
        "to_pos" => [teleport_param[2], teleport_param[3]]
      }
      next
    end

    if !shop_goods.empty?
      # 解析商品真实名称与价格
      enriched_goods = shop_goods.map do |g|
        g_type = g["type"]
        g_id = g["item_id"]
        item_entry = nil
        if g_type == 0 && ITEMS_TRUTH["items"]
          item_entry = ITEMS_TRUTH["items"][g_id.to_s]
        elsif g_type == 1 && ITEMS_TRUTH["weapons"]
          item_entry = ITEMS_TRUTH["weapons"][g_id.to_s]
        elsif g_type == 2 && ITEMS_TRUTH["armors"]
          item_entry = ITEMS_TRUTH["armors"][g_id.to_s]
        end
        {
          "type" => g_type,
          "item_id" => g_id,
          "name" => item_entry ? item_entry["name"] : "未知商品(ID:#{g_id})",
          "price" => item_entry ? item_entry["price"] : 0,
          "icon" => item_entry ? item_entry["icon_name"] : ""
        }
      end
      town_data["shops"] << {
        "event_id" => eid,
        "name" => name,
        "x" => x, "y" => y,
        "character" => char_name,
        "goods" => enriched_goods,
        "dialogues" => dialogues_by_page
      }
      next
    end

    if is_bulletin
      town_data["bulletins"] << {
        "event_id" => eid,
        "name" => name,
        "x" => x, "y" => y,
        "content" => dialogues_by_page.map { |d| d["text"] }.join("\n")
      }
      next
    end

    if !dialogues_by_page.empty? || (!char_name.empty? && tile_id == 0)
      town_data["npcs"] << {
        "event_id" => eid,
        "name" => name,
        "x" => x, "y" => y,
        "character" => char_name,
        "dialogue_tree" => dialogues_by_page
      }
      next
    end

    # 宝箱、调查点与杂项
    if name =~ /箱|瓶|石|物|药|床|水|桶|罐/
      town_data["interactables"] << {
        "event_id" => eid,
        "name" => name,
        "x" => x, "y" => y,
        "character" => char_name
      }
    end
  end

  town_data
end

puts "=== 开始全量采集核心城镇与室内建筑资产 (#{TOWN_MAPS.size} 张) ==="
parsed_towns = []
TOWN_MAPS.each do |info|
  data = parse_town_map(info)
  next unless data
  out_file = File.join(OUT_DIR, sprintf("town_%03d.json", data["map_id"]))
  File.open(out_file, "w:utf-8") { |f| f.write(JSON.pretty_generate(data)) }

  puts sprintf("[+] Map%03d (%-14s) 采集成功 -> 出入口:%2d, 商店:%2d, NPC:%2d, 告示牌:%2d",
    data["map_id"], data["name"], data["doorways"].size, data["shops"].size, data["npcs"].size, data["bulletins"].size)
  parsed_towns << {
    "map_id" => data["map_id"],
    "name" => data["name"],
    "group" => data["group"],
    "role" => data["role"],
    "width" => data["width"],
    "height" => data["height"],
    "doorways_count" => data["doorways"].size,
    "shops_count" => data["shops"].size,
    "npcs_count" => data["npcs"].size,
    "bulletins_count" => data["bulletins"].size
  }
end

# 导出全城镇总览看板
overview_file = File.join(OUT_DIR, "towns_manifest.json")
File.open(overview_file, "w:utf-8") { |f| f.write(JSON.pretty_generate(parsed_towns)) }

puts "\n🎉 城镇与室内专属资产库全量采集完毕！总览已保存至: #{overview_file}"
