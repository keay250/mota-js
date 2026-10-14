#==============================================================================
# ■ Game_Character (分割定义 1)
#------------------------------------------------------------------------------
# 　处理角色的类。本类作为 Game_Player 类与 Game_Event
# 类的超级类使用。
#==============================================================================

class Game_Character
  #--------------------------------------------------------------------------
  # ● 定义实例变量
  #--------------------------------------------------------------------------
  attr_reader   :id                       # ID
  attr_reader   :x                        # 地图 X 坐标 (理论坐标)
  attr_reader   :y                        # 地图 Y 坐标 (理论坐标)
  attr_reader   :real_x                   # 地图 X 坐标 (实际坐标 * 128)
  attr_reader   :real_y                   # 地图 Y 坐标 (实际坐标 * 128)
  attr_reader   :tile_id                  # 元件 ID  (0 为无效)
  attr_accessor   :character_name           # 角色 文件名
  attr_reader   :character_hue            # 角色 色相
  attr_reader   :opacity                  # 不透明度
  attr_reader   :blend_type               # 合成方式
  attr_reader   :direction                # 朝向
  attr_reader   :pattern                  # 图案
  attr_accessor   :move_route_forcing       # 移动路线强制标志
  attr_reader   :through                  # 穿透
  attr_accessor :animation_id             # 动画 ID
  attr_accessor :transparent              # 透明状态
  attr_accessor :talk                     # 显示准备
  attr_accessor :word                     # 显示内容
  attr_accessor   :trg_x #寻路追踪
  attr_accessor   :trg_y #寻路追踪
  attr_accessor   :path #记录路径
  #--------------------------------------------------------------------------
  # ● 初始化对像
  #--------------------------------------------------------------------------
  def initialize
    @id = 0
    @x = 0
    @y = 0
    @real_x = 0
    @real_y = 0
    @tile_id = 0
    @character_name = ""
    @character_hue = 0
    @opacity = 255
    @blend_type = 0
    @direction = 2
    @pattern = 0
    @move_route_forcing = false
    @through = false
    @animation_id = 0
    @transparent = false
    @original_direction = 2
    @original_pattern = 0
    @move_type = 0
    @move_speed = 4
    @move_frequency = 6
    @move_route = nil
    @move_route_index = 0
    @original_move_route = nil
    @original_move_route_index = 0
    @walk_anime = true
    @step_anime = false
    @direction_fix = false
    @always_on_top = false
    @anime_count = 0
    @stop_count = 0
    @jump_count = 0
    @jump_peak = 0
    @wait_count = 0
    @locked = false
    @prelock_direction = 0
    @talk = false
    @word = ""
  end
  def setsw(s1=false,s2=false,s3=false)
    @walk_anime = s1
    @step_anime = s2
    @direction_fix = s3
  end
  def set_direction(i)
    @direction=i
  end
  def set_xy(x,y)
   @x=x
   @y=y
  end
  def set_opacity(i)
    @opacity=i
  end
  #--------------------------------------------------------------------------
  # ● 移动中判定
  #--------------------------------------------------------------------------
  def moving?
    # 如果在移动中理论坐标与实际坐标不同
    return (@real_x != @x * 128 or @real_y != @y * 128)
  end
  #--------------------------------------------------------------------------
  # ● 跳跃中判定
  #--------------------------------------------------------------------------
  def jumping?
    # 如果跳跃中跳跃点数比 0 大
    return @jump_count > 0
  end
  def setspeed(i)
    @move_speed=i
  end
  def getspeed
    return @move_speed
  end
  def setmovetype(i)
    @move_type=i
  end

  #--------------------------------------------------------------------------
  # ● 矫正姿势
  #--------------------------------------------------------------------------
  def straighten
    # 移动时动画以及停止动画为 ON 的情况下
    if @walk_anime or @step_anime
      # 设置图形为 0
      @pattern = 0
    end
    # 清除动画计数
    @anime_count = 0
    # 清除被锁定的向前朝向
    @prelock_direction = 0
  end
  #--------------------------------------------------------------------------
  # ● 强制移动路线
  #     move_route : 新的移动路线
  #--------------------------------------------------------------------------
  def force_move_route(move_route)
    # 保存原来的移动路线
    if @original_move_route == nil
      @original_move_route = @move_route
      @original_move_route_index = @move_route_index
    end
    # 更改移动路线
    @move_route = move_route
    @move_route_index = 0
    # 设置强制移动路线标志
    @move_route_forcing = true
    # 清除被锁定的向前朝向
    @prelock_direction = 0
    # 清除等待计数
    @wait_count = 0
    # 自定义移动
    move_type_custom
  end
  #--------------------------------------------------------------------------
  # ● 可以通行判定
  #     x : X 坐标
  #     y : Y 坐标
  #     d : 方向 (0,2,4,6,8)  ※ 0 = 全方向不能通行的情况判定 (跳跃用)
  #--------------------------------------------------------------------------
  def passable?(x, y, d , mode = 0)
    # 求得新的坐标
    new_x = x + (d == 6 ? 1 : d == 4 ? -1 : 0)
    new_y = y + (d == 2 ? 1 : d == 8 ? -1 : 0)
    
  
    
#1不能向下、2不能向左、4不能向右、8不能向上
###以下增加图块中箭头方向的指向功能###箭头画在第3层

    @tu_id=$game_map.data[x,y,2]
    if $game_map.have_an_event?(x,y)
      @iid=$game_map.check_event(x,y)
      @tu_id=$game_map.events[@iid].tile_id
    end#if表示事件采用图片时的情况
    
    @tunew_id=$game_map.data[new_x,new_y,2]
    if $game_map.have_an_event?(new_x,new_y)
      @iid=$game_map.check_event(new_x,new_y)
      @tunew_id=$game_map.events[@iid].tile_id
    end#if表示事件采用图片时的情况
=begin
    v=$game_variables[85]
    if @tu_id==v[9]#当前坐标为黑框时
      if d==2 and (@tunew_id==v[0] or @tunew_id==v[4])
        return false#向上同时新坐标为向下箭头那么也不能出去
      end
      if d==8 and (@tunew_id==v[1] or @tunew_id==v[5])
        return false#向下新坐标为向上箭头
      end
      if d==6 and (@tunew_id==v[2] or @tunew_id==v[6])
        return false#向右新坐标为向左箭头
      end
      if d==4 and (@tunew_id==v[3] or @tunew_id==v[7])
        return false#向左新坐标为向右箭头
      end
      $data_tilesets[1].passages[@tu_id]=0#将黑框通行设为全向
    end

    case @tunew_id
      when v[0]#新坐标为向上箭头
        if d!=2#主角不是向下的情况
          if ((@tu_id==v[0] or @tu_id==v[4]) and d!=8) or ((@tu_id==v[1] or @tu_id==v[5]) and d!=2) or ((@tu_id==v[2] or @tu_id==v[6]) and d!=4)  or ((@tu_id==v[3] or @tu_id==v[7]) and d!=6)
            return false#当前坐标也为向上箭头且主角不是向上前进
          else
            return true
          end
        else
          return false
        end
      when v[1]#新坐标为向下箭头
        if d!=8#主角不是向上的情况
          if ((@tu_id==v[0] or @tu_id==v[4]) and d!=8) or ((@tu_id==v[1] or @tu_id==v[5]) and d!=2) or ((@tu_id==v[2] or @tu_id==v[6]) and d!=4)  or ((@tu_id==v[3] or @tu_id==v[7]) and d!=6)
            return false#当前坐标也为向下箭头且主角不是向下前进
          else
            return true
          end
        else
          return false
        end
      when v[2]#新坐标为向左箭头
        if d!=6#主角不是向右的情况
          if ((@tu_id==v[0] or @tu_id==v[4]) and d!=8) or ((@tu_id==v[1] or @tu_id==v[5]) and d!=2) or ((@tu_id==v[2] or @tu_id==v[6]) and d!=4)  or ((@tu_id==v[3] or @tu_id==v[7]) and d!=6)
            return false#当前坐标也为向左箭头且主角不是向左前进
          else
            return true
          end
        else
          return false
        end
      when v[3]#新坐标为向右箭头
        if d!=4#主角不是向左的情况
          if ((@tu_id==v[0] or @tu_id==v[4]) and d!=8) or ((@tu_id==v[1] or @tu_id==v[5]) and d!=2) or ((@tu_id==v[2] or @tu_id==v[6]) and d!=4)  or ((@tu_id==v[3] or @tu_id==v[7]) and d!=6)
            return false#当前坐标也为向右箭头且主角不是向右前进
          else
            return true
          end
        else
          return false
        end
      #以下四个为可以两两交换的箭头标记
      when v[4]#新坐标为向上箭头
        if d!=2#主角不是向下的情况
          if ((@tu_id==v[0] or @tu_id==v[4]) and d!=8) or ((@tu_id==v[1] or @tu_id==v[5]) and d!=2) or ((@tu_id==v[2] or @tu_id==v[6]) and d!=4)  or ((@tu_id==v[3] or @tu_id==v[7]) and d!=6)
            return false#当前坐标也为向上箭头且主角不是向上前进
          else
            return true
          end
        else
          return false
        end
      when v[5]#新坐标为向下箭头
        if d!=8#主角不是向上的情况
          if ((@tu_id==v[0] or @tu_id==v[4]) and d!=8) or ((@tu_id==v[1] or @tu_id==v[5]) and d!=2) or ((@tu_id==v[2] or @tu_id==v[6]) and d!=4)  or ((@tu_id==v[3] or @tu_id==v[7]) and d!=6)
            return false#当前坐标也为向下箭头且主角不是向下前进
          else
            return true
          end
        else
          return false
        end
      when v[6]#新坐标为向左箭头
        if d!=6#主角不是向右的情况
          if ((@tu_id==v[0] or @tu_id==v[4]) and d!=8) or ((@tu_id==v[1] or @tu_id==v[5]) and d!=2) or ((@tu_id==v[2] or @tu_id==v[6]) and d!=4)  or ((@tu_id==v[3] or @tu_id==v[7]) and d!=6)
            return false#当前坐标也为向左箭头且主角不是向左前进
          else
            return true
          end
        else
          return false
        end
      when v[7]#新坐标为向右箭头
        if d!=4#主角不是向左的情况
          if ((@tu_id==v[0] or @tu_id==v[4]) and d!=8) or ((@tu_id==v[1] or @tu_id==v[5]) and d!=2) or ((@tu_id==v[2] or @tu_id==v[6]) and d!=4)  or ((@tu_id==v[3] or @tu_id==v[7]) and d!=6)
            return false#当前坐标也为向右箭头且主角不是向右前进
          else
            return true
          end
        else
          return false
        end
    ###上一段在踩上箭头后设置通行只可沿箭头方向前进###
     #使用楼层范围变量来定位
     when v[8]#菱形标志，双箭头转换
        for i in $game_variables[90][0]...$game_variables[90][0]+$game_variables[90][1]
          for j in $game_variables[90][2]...$game_variables[90][2]+$game_variables[90][3]
            case $game_map.data[i,j,2]
              when v[4]
                $game_map.data[i,j,2]=v[5]
              when v[5]
                $game_map.data[i,j,2]=v[4]
              when v[6]
                $game_map.data[i,j,2]=v[7]
              when v[7]
                $game_map.data[i,j,2]=v[6]
            end
          end
        end

      when v[9]#黑框不可进入，但可以出去
        #$data_tilesets[1].passages[@tunew_id]=15
        return false#新坐标为黑框则不能通行
    end
###以上增加图块中箭头方向的指向功能###箭头画在第3层

=end

    
    # 坐标在地图以外的情况
   # unless $game_map.valid?(new_x, new_y)
      # 不能通行
  #    return false
 #   end
    # 穿透是 ON 的情况下
    if @through
      # 可以通行
      return true
    end
    # 移动者的元件无法来到指定方向的情况下
    unless $game_map.passable?(x, y, d, self)
      # 通行不可
      return false
    end
    # 从指定方向不能进入到移动处的元件的情况下
    unless $game_map.passable?(new_x, new_y, 10 - d)
      # 不能通行
      return false
    end
    # 循环全部事件
    for event in $game_map.events.values
      # 事件坐标于移动目标坐标一致的情况下
      if event.x == new_x and event.y == new_y && event.name !="dead"
        # 穿透为 ON
        unless event.through
          # 自己就是事件的情况下
        #  if self != $game_player
            # 不能通行
         #   return false
        #  end
          # 自己是主角、对方的图形是角色的情况下
          if event.character_name != ""
            # 不能通行
            return false
          end
        end
      end
    end
    # 主角的坐标与移动目标坐标一致的情况下
    if $game_player.x == new_x and $game_player.y == new_y
      # 穿透为 ON
      unless $game_player.through
        # 自己的图形是角色的情况下
        if @character_name != ""
          # 不能通行
          return false
        end
      end
    end
    # 可以通行
    return true
  end
  #--------------------------------------------------------------------------
  # ● 锁定
  #--------------------------------------------------------------------------
  def lock
    # 如果已经被锁定的情况下
    if @locked
      # 过程结束
      return
    end
    # 保存锁定前的朝向
    @prelock_direction = @direction
    # 保存主角的朝向
    turn_toward_player
    # 设置锁定中标志
    @locked = true
  end
  #--------------------------------------------------------------------------
  # ● 锁定中判定
  #--------------------------------------------------------------------------
  def lock?
    return @locked
  end
  #--------------------------------------------------------------------------
  # ● 解除锁定
  #--------------------------------------------------------------------------
  def unlock
    # 没有锁定的情况下
    unless @locked
      # 过程结束
      return
    end
    # 清除锁定中标志
    @locked = false
    # 没有固定朝向的情况下
    unless @direction_fix
      # 如果保存了锁定前的方向
      if @prelock_direction != 0
        # 还原为锁定前的方向
        @direction = @prelock_direction
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 移动到指定位置
  #     x : X 坐标
  #     y : Y 坐标
  #--------------------------------------------------------------------------
  def moveto(x, y)
    @x = x % $game_map.width
    @y = y % $game_map.height
    @real_x = @x * 128
    @real_y = @y * 128
    @prelock_direction = 0
  end
  def newmoveto(x, y)
    @x = x
    @y = y
    @real_x = @x * 128
    @real_y = @y * 128
    @prelock_direction = 0
  end
  #--------------------------------------------------------------------------
  # ● 获取画面 X 坐标
  #--------------------------------------------------------------------------
  def screen_x
    # 通过实际坐标和地图的显示位置来求得画面坐标
    return (@real_x - $game_map.display_x + 3) / 4 + 16
  end
  #--------------------------------------------------------------------------
  # ● 获取画面 Y 坐标
  #--------------------------------------------------------------------------
  def screen_y
    # 通过实际坐标和地图的显示位置来求得画面坐标
    y = (@real_y - $game_map.display_y + 3) / 4 + 32
    # 取跳跃计数小的 Y 坐标
    if @jump_count >= @jump_peak
      n = @jump_count - @jump_peak
    else
      n = @jump_peak - @jump_count
    end
    return y - (@jump_peak * @jump_peak - n * n) / 2
  end
  #--------------------------------------------------------------------------
  # ● 获取画面 Z 坐标
  #     height : 角色的高度
  #--------------------------------------------------------------------------
  def screen_z(height = 0)
    # 在最前显示的标志为 ON 的情况下
    if @always_on_top
      # 无条件设置为 999
      return 999
    end
    # 通过实际坐标和地图的显示位置来求得画面坐标
    z = (@real_y - $game_map.display_y + 3) / 4 + 32
    # 元件的情况下
    if @tile_id > 0
      # 元件的优先不足 * 32 
      return z + $game_map.priorities[@tile_id] * 32
    # 角色的场合
    else
      # 如果高度超过 32 就判定为满足 31
      return z + ((height > 32) ? 31 : 0)
    end
  end
  #--------------------------------------------------------------------------
  # ● 取得茂密
  #--------------------------------------------------------------------------
  def bush_depth
    # 是元件、并且在最前显示为 ON 的情况下
    if @tile_id > 0 or @always_on_top
      return 0
    end
    # 以跳跃中以外要是繁茂处属性的元件为 12，除此之外为 0
    if @jump_count == 0 and $game_map.bush?(@x, @y)
      return 12
    else
      return 0
    end
  end
  #--------------------------------------------------------------------------
  # ● 取得地形标记
  #--------------------------------------------------------------------------
  def terrain_tag
    return $game_map.terrain_tag(@x, @y)
  end
end
