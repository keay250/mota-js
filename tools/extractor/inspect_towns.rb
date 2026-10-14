# -*- coding: utf-8 -*-
require "json"

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
MAP_CATALOG = JSON.parse(File.read(File.join(PROJ_DIR, "docs", "extracted_data", "maps_catalog.json")))

town_mids = [17, 18, 19, 20, 48, 58, 59, 60, 61, 62, 63, 64, 66, 85, 86, 143, 147, 148, 149, 269, 270, 271]

puts "=== 城镇与建筑地图事件与功能探测 ==="
town_mids.each do |mid|
  p = File.join(DATA_DIR, sprintf("Map%03d.rxdata", mid))
  next unless File.exist?(p)
  map = File.open(p, "rb") { |f| Marshal.load(f) }
  
  ev_types = Hash.new(0)
  npc_names = []
  shops = []

  map.events.each do |eid, ev|
    name = s(ev.name)
    has_msg = false
    ev.pages.each do |page|
      next unless page.list
      page.list.each do |cmd|
        ev_types["shop"] += 1 if [302, 605].include?(cmd.code)
        ev_types["msg"] += 1 if [101].include?(cmd.code)
        ev_types["transfer"] += 1 if [201].include?(cmd.code)
        has_msg = true if [101, 102].include?(cmd.code)
      end
    end
    npc_names << name if has_msg && !name.start_with?("EV")
  end

  m_name = MAP_CATALOG[mid.to_s] ? MAP_CATALOG[mid.to_s]["name"] : ""
  puts sprintf("Map%03d (%-16s, %2dx%2d): 事件=%2d, 对话指令=%2d, 商店指令=%2d, 传送=%2d | 核心NPC: %s",
    mid, m_name, map.width, map.height, map.events.size, ev_types["msg"], ev_types["shop"], ev_types["transfer"],
    npc_names.uniq.first(5).join(", "))
end
