class Tone; def self._load(s); s; end; end
class Color; def self._load(s); s; end; end
module RPG
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
  class AudioFile
    attr_accessor :name, :volume, :pitch
  end
end
class Table
  def self._load(s)
    s
  end
end

def s(str)
  str ? str.dup.force_encoding("UTF-8").scrub : ""
end

target_map = ARGV[0] || "../Data/Map012.rxdata"
map = File.open(target_map, "rb") { |f| Marshal.load(f) }
puts "=== #{target_map} Loaded! Width=#{map.width}, Height=#{map.height}, Events=#{map.events.size} ==="

map.events.sort_by { |k, v| k }.each do |id, ev|
  name = s(ev.name)
  char = s(ev.pages[0]&.graphic&.character_name)
  tile = ev.pages[0]&.graphic&.tile_id
  
  has_door_or_content = false
  if name =~ /门|机关|怪|EV|铁/i || char =~ /door|gate|iron/i || ev.pages.size > 1
    has_door_or_content = true
  end
  
  if has_door_or_content
    puts "Event #{id}: (#{ev.x}, #{ev.y}) name=#{name} char=#{char} tile=#{tile} pages=#{ev.pages.size}"
    ev.pages.each_with_index do |page, pidx|
      cond = page.condition
      cond_s = []
      cond_s << "sw1=#{cond.switch1_id}" if cond.switch1_valid
      cond_s << "sw2=#{cond.switch2_id}" if cond.switch2_valid
      cond_s << "var#{cond.variable_id}>=#{cond.variable_value}" if cond.variable_valid
      cond_s << "self=#{s(cond.self_switch_ch)}" if cond.self_switch_valid
      
      triggers = ["action", "touch_hero", "touch_event", "autorun", "parallel"]
      trig_name = triggers[page.trigger] || page.trigger
      puts "  Page #{pidx}: trigger=#{trig_name} cond=#{cond_s.inspect} char=#{s(page.graphic.character_name)}"
      
      if page.list
        page.list.each do |cmd|
          if [111, 117, 121, 122, 123, 201, 208, 209, 250, 355, 655, 101, 102].include?(cmd.code)
            params = cmd.parameters.map { |p| p.is_a?(String) ? s(p) : p }
            puts "    code #{cmd.code}: #{params.inspect}"
          end
        end
      end
    end
  end
end
