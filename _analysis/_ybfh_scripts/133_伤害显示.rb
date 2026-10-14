# 显伤脚本 By 正灌
#1.执行效率大概是传统显伤数十倍
#2.能够自动判断埋伏怪之类的情况
#3.支持怪物移动显伤跟随平滑移动
#4.支持大地图（超过13*13）显伤
#5.切换地图时显伤跟随平滑渐变

MAX_EVENT_SIZE=249  #最大事件数，默认13*13=169

#虚弱之诏用倍率
$rate_list_3=[1]
for i in 1..30
  $rate_list_3[i]=$rate_list_3[i-1]*0.97
end

class Map_damage
  
  attr_accessor :canvas, :refresh_on_step
  #初始化
  def initialize
    @canvas=[]
    for i in 1...MAX_EVENT_SIZE+1
      @canvas[i]=Sprite.new($mainviewport)
      @canvas[i].bitmap=Bitmap.new(42,36)
      @canvas[i].z=42
    end
    @refresh_on_step = false
    @save_count=0
    @colordata=[
      Color.new(0,0,0),Color.new(0, 255, 0),Color.new(255, 255, 255),
      Color.new(255, 255, 0),Color.new(255, 127, 0),Color.new(255, 0, 0),
      Color.new(128, 255, 255, 255),Color.new(6,6,6,155),Color.new(255, 255, 255,0),
      Color.new(255,24,224, 255),Color.new(25,25,25,100),Color.new(210, 255, 30),
      Color.new(0, 255, 255),Color.new(0, 0, 255)
    ]
    @tonedata=[
      Tone.new(255,0,255),Tone.new(85,85,85),Tone.new(35,35,255)
    ]
    @buff_bitmap=RPG::Cache.picture("buff")
    @player_buff=Sprite.new($mainviewport)
    @player_buff.bitmap=Bitmap.new(1,1)
    @player_buff.z=40
  end
  def getcolor(i)
    return @colordata[i]
  end
  def gettone(i)
    return @tonedata[i]
  end
  def dispose
    for i in 1...MAX_EVENT_SIZE+1
      @canvas[i].bitmap.dispose
      @canvas[i].dispose
    end
    @player_buff.dispose
  end

  # 这里设置启用前提条件（怪物手册等等），必须返回true（启用）或false（禁用）
  def enable?
    # 怪物手册（4号物品）持有时启用
    return $game_party.item_number(4) != 0
  end
  def clear
    for i in 1...MAX_EVENT_SIZE+1
      @canvas[i].visible=false
    end
  end
  
  def resetxy(id,x,y,z)
    @canvas[id].x=x-17
    @canvas[id].y=y-34
    @canvas[id].z=1000#z+32
   # @canvas[id].visible=false
  #  @canvas[id].ox = $game_screen.shake
  end
  def resetbuff(x,y,z)
    @player_buff.x=x
    @player_buff.y=y-46
    @player_buff.z=888#z+32
  end
  def setvisible(id,sw)
    @canvas[id].visible=sw
  end

  # 这里设置显示前提条件（潜伏怪、机关不显示等等），e是EnemyDate类的实例，必须返回true（显示）或false（不显示）
  def render?(id, x, y, eid)
    old = false
    # 兼容性测试
    test = got_p(id,1) rescue old = true
    if old
      if got_p(id,1000)
        # 有潜伏怪则每步刷新
        @refresh_on_step = true
        if $game_party.item_number($game_variables[79]) == 0
          return false # 潜伏怪不显示伤害(持有反潜伏的79号物品后显示）
        elsif !((x-$game_player.x).abs+(y-$game_player.y).abs <= $game_variables[84])
          return false
        end
      end
      norevive = false
      iserase = $game_map.events[eid].iserase rescue norevive = true
      if !norevive
        if got_p(id,1001) and iserase # 重生怪打败后暂时不显示伤害
          return false
        end
      end
    else
      # 兼容性测试
      special = true
      prop = got_p(id,1002) rescue special = false
      return false if prop and special # 特殊战斗怪不显示
      
      if got_p(id,1005)
        # 有潜伏怪则每步刷新
        @refresh_on_step = true
        if $game_party.item_number($game_variables[79]) == 0
          return false # 潜伏怪不显示伤害(持有反潜伏的物品后显示）
        elsif !((x-$game_player.x).abs+(y-$game_player.y).abs<=$game_variables[84])
          return false
        end
      end
      
      if got_p(id,1020) and $game_map.events[eid].iserase # 重生怪打败后暂时不显示伤害
        return false
      end
    end
    return true
  end

  # 这里设置不同伤害的不同颜色，damage是敌人伤害，必须返回Color类的实例（用Color.new生成）
  def color?(damage)
    hp = $game_actors[$game_variables[1] + 1].hp # 勇士生命
    ratio = 1.0 * damage / hp
    if ratio <= 0 # 无伤害
      return @colordata[1] # 绿
    elsif ratio < 1.0 / 3.0 # 伤害小于勇士血量1/3
      return @colordata[2] # 白
    elsif ratio < 2.0 / 3.0 # 伤害在勇士血量1/3到2/3之间
      return @colordata[3] # 黄
    elsif ratio < 1.0 # 伤害在勇士血量2/3到1之间
      return @colordata[4] # 橙
    elsif damage != 9999999 # 伤害大于等于勇士血量
      return @colordata[5] # 红
    else # 无敌怪且无十字架
      return @colordata[0] # 黑
    end
  end

  # 刷新。手动刷新也用这个方法
  def refresh
    return if @save_count==Graphics.frame_count 
    #BUFF显示
    actor=$game_actors[$game_variables[1]+1]
    @player_buff.bitmap.clear
    buff=actor.buff
    if buff.size>0
      l=buff.size
      @player_buff.bitmap=Bitmap.new([l,3].min*16,(l+2)/3*32)
      @player_buff.bitmap.font.size=12
      @player_buff.ox=@player_buff.bitmap.width/2
      @player_buff.oy=@player_buff.bitmap.height
      j=0
      for i in buff
        @player_buff.bitmap.blt(j%3*16,@player_buff.oy-j/3*32-30,@buff_bitmap,Rect.new((i[0]-1)%10*16,(i[0]-1)/10*16,16,16))
        if i[1]>0
          x=j%3*16-8;y=@player_buff.oy-j/3*32-24
          @player_buff.bitmap.font.color = @colordata[0]
          @player_buff.bitmap.draw_text(x-1,y,32,32,i[1].to_s,1)
          @player_buff.bitmap.draw_text(x+1,y,32,32,i[1].to_s,1)
          @player_buff.bitmap.draw_text(x,y+1,32,32,i[1].to_s,1)
          @player_buff.bitmap.draw_text(x,y-1,32,32,i[1].to_s,1)
          @player_buff.bitmap.font.color = @colordata[2]
          @player_buff.bitmap.draw_text(x,y,32,32,i[1].to_s,1)
        end
        if i[2]!=nil && i[2]>0
          str=i[2].to_s
          str+="层" if i[2]<10
          x=j%3*16-8;y=@player_buff.oy-j/3*32-24
          @player_buff.bitmap.font.color = @colordata[0]
          @player_buff.bitmap.draw_text(x-1,y,32,32,str,1)
          @player_buff.bitmap.draw_text(x+1,y,32,32,str,1)
          @player_buff.bitmap.draw_text(x,y+1,32,32,str,1)
          @player_buff.bitmap.draw_text(x,y-1,32,32,str,1)
          @player_buff.bitmap.font.color = @colordata[3]
          @player_buff.bitmap.draw_text(x,y,32,32,str,1)
        end
        j+=1
      end
    else
      @player_buff.bitmap=Bitmap.new(1,1)
    end
    return if $game_switches[153]
    @save_count=Graphics.frame_count 
    EnemyReady.refresh
    if enable?
      @refresh_on_step = false
      clear
      result=EnemyReady.hunter_damage
      dam_list={}
      @dam_bitmap={}#显伤缓存
      $game_map.events.each_value{ |value|
        event = value.event
        name = event.name
        if result[event.id]!=nil #有猎手怪或光环
          if dam_list[result[event.id]] !=nil
            damage=dam_list[result[event.id]].clone
          else
            sign=result[event.id].index("|") 
            if sign==nil
              e=Enemy_property.new(result[event.id],event.id)
            else
              e=Enemy_property.new(result[event.id][0,sign],event.id,result[event.id][sign+1,result[event.id].size-sign-1])
            end
            damage=[]
            damage.push(e.got_damage)
            damage.push(e.got_nowin)
            damage.push(e.got_spcost)
            damage.push(e.got_soulcost)
            damage.push(e.have_damage)
            dam_list[result[event.id]]=damage.clone
          end
        else
          damage=nil
        end
        if name[0, 6] == "怪物" && value.character_name !="" && value.opacity>0
          draw_by_id(name[6, name.length - 6].to_i, event.x, event.y, event.id,damage)
        end
      }
    end
  end

  def draw_by_id(id, x, y, eid,info)
    # 获得Enemy_property对象
    return if !render?(id, x, y, eid)
    # 获得伤害字符串
    if info==nil
      j=0
      for i in $floorenemies
        if i==id
          damage = $fledam[j]
          res = $fleres[j]
          spcost = $flespcost[j]
          soulcost = $flesoulcost[j]
          havedam = $flehavedam[j]
          $event_damage[eid]=damage
          break
        end
        j+=1
      end
    else
      damage=info[0]
      res=info[1]
      spcost=info[2]
      soulcost=info[3]
      havedam=info[4]
      $event_damage[eid]=damage
    end
    spcosts=spcost.to_s
    
    if res == 1
      damage_s = "????"
    elsif res == 2
      damage_s = "?????"
    else
       def fucki(i)
          return "0" if i==0
          len=(i.to_s).length
          len2=(i.abs.to_s).length
          if len2>4 && len2%4==2
            len=[(len-2)/4,0].max
            t=i.abs/i
            return (i.abs/(10**(len*4-1))/10.0*t).to_s+$shuwei2[len+$game_variables[400]]
          end
          len=[(len-2)/4,0].max
          t=i.abs/i
          return (i.abs/(10**(len*4))*t).to_s+$shuwei2[len+$game_variables[400]]
        end

      damage_s = fucki(damage)   
    end
    #判断是否已有缓存
    @canvas[eid].visible=true
    if @dam_bitmap[[damage_s,spcosts]] != nil
      @canvas[eid].bitmap=@dam_bitmap[[damage_s,spcosts]].clone
      return
    end
    
    @canvas[eid].bitmap.clear
    t = @canvas[eid].bitmap
    if havedam || ($game_variables[229]==0 && $game_variables[257]==0)
      main_color = color?(damage)
    else
      main_color = @colordata[11]
    end
    t.font.name = "Arial Black" # 字体随便换
    t.font.size = 12 # 字体大小不能太大
    t.font.color = @colordata[0]
    lth=damage_s.length
    t.draw_text(2,25, 12 * lth, 12, damage_s)
    t.draw_text(0,25, 12 * lth, 12, damage_s)
    t.draw_text(2,27, 12 * lth, 12, damage_s)
    t.draw_text(0,27, 12 * lth, 12, damage_s)
    t.font.color = main_color
    t.draw_text(1,26 ,12 * lth, 12, damage_s)
    if spcost !=0
      spcost=spcost.to_s
      lth=spcost.length
      t.font.color=@colordata[0]
      t.draw_text(2,0, 12 * lth, 12, spcost)
      t.draw_text(0,0, 12 * lth, 12, spcost)
      t.draw_text(2,2, 12 * lth, 12, spcost)
      t.draw_text(0,2, 12 * lth, 12, spcost)
      t.font.color = @colordata[6]
      t.draw_text(1,1 ,12 * lth, 12, spcost)
    end
    if soulcost !=0
      soulcost=soulcost.to_s
      lth=soulcost.length
      yy=0
      if spcost.size+lth>=6
        t.font.size = 10
        yy+=8
      end
      t.font.color=@colordata[0]
      t.draw_text(19+14-12 * lth,yy, 12 * lth, 12, soulcost,2)
      t.draw_text(17+14-12 * lth,yy, 12 * lth, 12, soulcost,2)
      t.draw_text(19+14-12  * lth,yy+2, 12 * lth, 12, soulcost,2)
      t.draw_text(17+14-12 * lth,yy+2, 12 * lth, 12, soulcost,2)
      t.font.color = @colordata[9]
      t.draw_text(18+14-12 * lth,yy+1 ,12 * lth, 12, soulcost,2)
    end
    @dam_bitmap[[damage_s,spcost]]=t
  end

end

# 追加定义Window_PlayerDate类，能力改变时刷新
class Window_PlayerDate
  alias :old_refresh :refresh
  def refresh
    $mapdamage_obj.refresh
    old_refresh
  end
end
class Window_PlayerDate2
  alias :old_refresh :refresh
  def refresh
    $mapdamage_obj.refresh if !$game_switches[188]
    old_refresh
  end
end

# 追加定义Game_Party类
class Game_Party
  
  alias :old_gain_item :gain_item
  alias :old_increase_steps :increase_steps
  
  # 获得怪物手册或反潜伏物品或反无敌物品时刷新
  def gain_item(item_id, n)
    old_gain_item(item_id, n)
    if item_id == 4 or item_id == $game_variables[79] or item_id == $game_variables[71]
      $mapdamage_obj.refresh if $mapdamage_obj != nil
    end
  end
  
  # 若有潜伏怪则每步刷新
  def increase_steps
    old_increase_steps
    if $mapdamage_obj != nil and $mapdamage_obj.refresh_on_step
      $mapdamage_obj.refresh
    end
  end
  
end

class Game_Map
  def refresh
    # 地图 ID 有效
    if @map_id > 0
      check=false
      # 刷新全部的地图事件
      for event in @events.values
        check=true if event.refresh==true && event.event.name[0,6] == "怪物"
      end
      $mapdamage_obj.refresh if check
      # 刷新全部的公共事件
      for common_event in @common_events.values
        common_event.refresh
      end
    end
    # 清除刷新要求标志
    @need_refresh = false
  end
end

# 追加定义Game_Event类，提供是否擦除的获取器
class Game_Event
  def iserase
    return @erased
  end
  def refresh
    # 初始化本地变量 new_page
    new_page = nil
    # 无法暂时小时的情况下
    unless @erased
      # 从编号大的事件页按顺序调查
      for page in @event.pages.reverse
        # 可以参考事件条件 c
        c = page.condition
        # 确认开关条件 1 
        if c.switch1_valid
          if $game_switches[c.switch1_id] == false
            next
          end
        end
        # 确认开关条件 2 
        if c.switch2_valid
          if $game_switches[c.switch2_id] == false
            next
          end
        end
        # 确认变量条件
        if c.variable_valid
          if $game_variables[c.variable_id] < c.variable_value
            next
          end
        end
        # 确认独立开关条件
        if c.self_switch_valid
          key = [@map_id, @event.id, c.self_switch_ch]
          if $game_self_switches[key] != true
            next
          end
        end
        # 设置本地变量 new_page
        new_page = page
        # 放弃循环
        break
      end
    end
    # 与上次同一事件页的情况下
    if new_page == @page
      # 过程结束
      return
    end
    setup_page(new_page)
    if @erased# && @event.name[0,6]=="怪物"
      for page in @event.pages.reverse
        # 可以参考事件条件 c
        c = page.condition
        # 确认开关条件 1 
        if c.switch1_valid
          if $game_switches[c.switch1_id] == false
            next
          end
        end
        # 确认开关条件 2 
        if c.switch2_valid
          if $game_switches[c.switch2_id] == false
            next
          end
        end
        # 确认变量条件
        if c.variable_valid
          if $game_variables[c.variable_id] < c.variable_value
            next
          end
        end
        # 确认独立开关条件
        if c.self_switch_valid
          key = [@map_id, @event.id, c.self_switch_ch]
          if $game_self_switches[key] != true
            next
          end
        end
        break
      end
      @character_name = page.graphic.character_name
      @character_hue = page.graphic.character_hue
      @direction = page.graphic.direction
      @original_direction = @direction
      @prelock_direction = 0
      @pattern = page.graphic.pattern
      @original_pattern = @pattern
      page.graphic.opacity
      @opacity = page.graphic.opacity/2
      @blend_type = page.graphic.blend_type
    end
    return true
  end
  def setup_page(new_page)
    # @page 设置为现在的事件页
    @page = new_page
    # 清除启动中标志
    clear_starting
    # 没有满足条件的页面的时候
    if @page == nil
      # 设置各实例变量
      @tile_id = 0
      @character_name = ""
      @character_hue = 0
      @move_type = 0
      @through = true
      @trigger = nil
      @list = nil
      @interpreter = nil
      # 过程结束
      return
    end
    # 设置各实例变量
    @tile_id = @page.graphic.tile_id
    @character_name = @page.graphic.character_name
    @character_hue = @page.graphic.character_hue
    if @original_direction != @page.graphic.direction
      @direction = @page.graphic.direction
      @original_direction = @direction
      @prelock_direction = 0
    end
    if @original_pattern != @page.graphic.pattern
      @pattern = @page.graphic.pattern
      @original_pattern = @pattern
    end
    @opacity = @page.graphic.opacity
    @blend_type = @page.graphic.blend_type
    @move_type = @page.move_type
    @move_speed = @page.move_speed
    @move_frequency = @page.move_frequency
    @move_route = @page.move_route
    @move_route_index = 0
    @move_route_forcing = false
    @walk_anime = @page.walk_anime
    @step_anime = @page.step_anime
    @direction_fix = @page.direction_fix
    @through = @page.through
    @always_on_top = @page.always_on_top
    @trigger = @page.trigger
    @list = @page.list
    @interpreter = nil
    # 目标是 [并行处理] 的情况下
    if @trigger == 4
      # 生成并行处理用解释器
      @interpreter = Interpreter.new
    end
    # 自动事件启动判定
    check_event_trigger_auto
  end
end

# 追加定义Sprite_Character类
class Sprite_Character < RPG::Sprite
  alias :old_update :update
  def update
    old_update
    if $mapdamage_obj !=nil
    if self != $game_player && @character.id>0
  #    $mapdamage_obj.canvas[@character.id].tone = $game_screen.tone
      $mapdamage_obj.resetxy(@character.id,self.x,self.y,self.z)
    end
    if self.character==$game_player
      $mapdamage_obj.resetbuff(self.x,self.y,self.z)
    end
    end
  end
end

# 追加定义Scene_Map类
class Scene_Map

  # 地图初始化时初始化并刷新
  def initialize
    
    #$mapdamage_obj.refresh
  end
  
  # 场所移动时刷新
  def transfer_player
    # 清除主角场所移动调试标志
    $game_temp.player_transferring = false
    # 移动目标与现在的地图有差异的情况下
    if $game_switches[147] || $game_map.map_id != $game_temp.player_new_map_id
      # 设置新地图
      $game_switches[147]=false
      $game_map.setup($game_temp.player_new_map_id)
    end
    # 设置主角位置
    $game_player.moveto($game_temp.player_new_x, $game_temp.player_new_y)
    # 设置主角朝向
    case $game_temp.player_new_direction
    when 2  # 下
      $game_player.turn_down
    when 4  # 左
      $game_player.turn_left
    when 6  # 右
      $game_player.turn_right
    when 8  # 上
      $game_player.turn_up
    end
    # 矫正主角姿势
    $game_player.straighten
    # 刷新地图 (执行并行事件)
    $game_map.update
    # 在生成活动块
    $mapdamage_obj.dispose
    $mapdamage_obj=nil
    @spriteset.dispose
    @spriteset = Spriteset_Map.new
    $mapdamage_obj = Map_damage.new
    # 处理过渡中的情况下
    $mapdamage_obj.refresh_on_step = false
    if $game_switches[Playerdate_SWITCH]
     @Playerdate_window .visible = true
     @Playerdate_window .refresh
     @Playerdate_window2 .visible = true
     @Playerdate_window2 .refresh
     @Playerdate_window2 .sprvi(true)
   end
   @spriteset.update
   # $mapdamage_obj.refresh 
    if $game_temp.transition_processing
      # 清除过渡处理中标志
      $game_temp.transition_processing = false
      # 执行过渡
      Graphics.transition(20)
    end
    # 执行地图设置的 BGM、BGS 的自动切换
    $game_map.autoplay
    # 设置画面
    Graphics.frame_reset
    # 刷新输入信息
    Input.update
  end

end

# 追加定义Scene_Title类，返回标题画面时去除所有伤害显示
class Scene_Title
  
  def initialize
    $mapdamage_obj.clear if $mapdamage_obj != nil && !$mapdamage_obj.canvas[1].disposed? 
  end
  
end

# 追加定义Interpreter类
class Interpreter
  
  alias :old_command_117 :command_117
  alias :old_command_end :command_end
  
  def command_117
    @common_event_id = @parameters[0]
    old_command_117
  end
  def command_end
    old_command_end
    return if @common_event_id == nil or $mapdamage_obj == nil
    # 战斗事件结束后刷新
    if @common_event_id == 1
      #$mapdamage_obj.refresh
    end
    # 结局判定后清除
    if @common_event_id == 12
      $mapdamage_obj.clear
    end
    @common_event_id = 0
  end
  
end

def value_in?(a,b,c)
  return true if a>=b && a<=c
end