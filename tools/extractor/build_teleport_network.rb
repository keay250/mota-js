# -*- coding: utf-8 -*-
require "json"

SCRIPT_DIR = File.dirname(File.expand_path(__FILE__))
PROJ_DIR = File.expand_path("../..", SCRIPT_DIR)
MAPS_DIR = File.join(PROJ_DIR, "docs", "extracted_data", "maps")
MAP_CATALOG = JSON.parse(File.read(File.join(PROJ_DIR, "docs", "extracted_data", "maps_catalog.json")))

network = []

Dir.glob(File.join(MAPS_DIR, "map_*.json")).sort.each do |f|
  data = JSON.parse(File.read(f))
  mid = data["map_id"]
  m_name = MAP_CATALOG[mid.to_s] ? MAP_CATALOG[mid.to_s]["name"] : "未知地图"

  data["teleports"].each do |tp|
    target_mid = tp["target_map_id"]
    target_name = MAP_CATALOG[target_mid.to_s] ? MAP_CATALOG[target_mid.to_s]["name"] : "未知目标"
    network << {
      "from_map_id" => mid,
      "from_map_name" => m_name,
      "from_pos" => [tp["x"], tp["y"]],
      "to_map_id" => target_mid,
      "to_map_name" => target_name,
      "to_pos" => [tp["target_x"], tp["target_y"]],
      "event_name" => tp["name"]
    }
  end
end

out_path = File.join(PROJ_DIR, "docs", "extracted_data", "teleport_network.json")
File.open(out_path, "w:utf-8") { |f| f.write(JSON.pretty_generate(network)) }
puts "=== 传送网络拓扑构建完成 (共 #{network.size} 条跨图传送链接) -> #{out_path} ==="
network.first(15).each do |link|
  puts "  Map#{link['from_map_id']} (#{link['from_map_name']}) [#{link['from_pos'].join(',')}] -> Map#{link['to_map_id']} (#{link['to_map_name']}) [#{link['to_pos'].join(',')}]"
end
