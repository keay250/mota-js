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
end

def s(str)
  str ? str.dup.force_encoding("UTF-8").scrub : ""
end

sys = File.open("../Data/System.rxdata", "rb") { |f| Marshal.load(f) }
puts "=== 原版系统开关与变量概览 ==="
valid_sw = sys.switches.each_with_index.select { |name, idx| name && !name.empty? }
valid_var = sys.variables.each_with_index.select { |name, idx| name && !name.empty? }
puts "开关总数: #{sys.switches.size}, 命名开关数: #{valid_sw.size}"
puts "变量总数: #{sys.variables.size}, 命名变量数: #{valid_var.size}"
puts "部分核心开关前 15 项:"
valid_sw[0..15].each { |name, idx| puts "  开关[#{idx}]: #{s(name)}" }

map_infos = File.open("../Data/MapInfos.rxdata", "rb") { |f| Marshal.load(f) }
puts "\n=== 原版地图总览 (共 #{map_infos.size} 个地图) ==="
map_infos.sort_by { |k, v| k }.each do |id, info|
  pad_id = sprintf("%03d", id)
  puts "Map#{pad_id}: #{s(info.name)} (parent=#{info.parent_id})"
end
