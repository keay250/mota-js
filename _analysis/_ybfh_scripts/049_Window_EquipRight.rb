#==============================================================================
# ■ Window_EquipRight
#------------------------------------------------------------------------------
# 　装备画面、显示角色现在装备的物品的窗口。
#==============================================================================

class Window_EquipRight < Window_Selectable
  #--------------------------------------------------------------------------
  # ● 初始化对像
  #     actor : 角色
  #--------------------------------------------------------------------------
  def initialize(actor)
    super(240, 0, 336, 240)
    self.contents = Bitmap.new(width - 32, height - 32)
    @bscheck = -1
    if $game_variables[285]!=0
      @bscheck=($game_actors[$game_variables[1]+1].get_buff_time(10)-1)/5
    end
    @actor = actor
    refresh
    self.index = @bscheck + 1
  end
  #--------------------------------------------------------------------------
  # ● 获取物品
  #--------------------------------------------------------------------------
  def item
    return @data[self.index]
  end
  def draw_item_name(item, x, y ,index)
    if item == nil
      return
    end
    
    bitmap = RPG::Cache.icon(item.icon_name)
    self.contents.blt(x-43, y-50 , bitmap, Rect.new(0, 0, 86, 64), opacity)

    self.contents.font.color = normal_color
    self.contents.font.size=16
    if $game_variables[181][item.id]!=nil && $game_variables[181][item.id]!=0 && !@check_cn.include?(item.id)
      @check_cn.push(item.id)
      if $game_variables[181][item.id]==-1
        str="开启"
      else
        str=$game_variables[181][item.id].to_s
      end
      self.contents.font.color = text_color(12)
      self.contents.draw_text(x+7, y-11+1, 32, 32, str,2)
      self.contents.draw_text(x+7, y-11-1, 32, 32, str,2)
      self.contents.draw_text(x+7+1, y-11, 32, 32, str,2)
      self.contents.draw_text(x+7-1, y-11, 32, 32, str,2)
      self.contents.font.color = normal_color
      self.contents.draw_text(x+7, y-11, 32, 32, str,2)
    end
    if item.id==39 && $game_switches[142]
      self.contents.font.color = text_color(12)
      self.contents.draw_text(x-23, y-11+1, 62, 32, "冷却中",2)
      self.contents.draw_text(x-23, y-11-1, 62, 32, "冷却中",2)
      self.contents.draw_text(x-23+1, y-11, 62, 32, "冷却中",2)
      self.contents.draw_text(x-23-1, y-11, 62, 32, "冷却中",2)
      self.contents.font.color = normal_color
      self.contents.draw_text(x-23, y-11, 62, 32, "冷却中",2)
    end
    if item.id==74 && $game_switches[159]
      str="开启"
      self.contents.font.color = text_color(12)
      self.contents.draw_text(x-40, y-11+1, 32, 32, str,2)
      self.contents.draw_text(x-40, y-11-1, 32, 32, str,2)
      self.contents.draw_text(x-40+1, y-11, 32, 32, str,2)
      self.contents.draw_text(x-40-1, y-11, 32, 32, str,2)
      self.contents.font.color = normal_color
      self.contents.draw_text(x-40, y-11, 32, 32, str,2)
    end
    
    #闭锁效果
    if $game_variables[285]!=0 && index<=@bscheck
      bitmap = RPG::Cache.icon("装备-闭锁")
      self.contents.blt(x-43, y-50 , bitmap, Rect.new(0, 0, 86, 64), opacity)
    end
    
    str=item.name.split(":")[0]
    text=TextStream.new
    text.open("Info/Equip/"+str)
    color=text.get_text(1)
    color.sub!(/\[([0-9]+)\]/, "")
    text.close
    self.contents.font.color=text_color($1.to_i)
    self.contents.draw_text(x-48, y+11, 100, 32, str,1)
  end
  #--------------------------------------------------------------------------
  # ● 更新光标举行
  #--------------------------------------------------------------------------
  def update
   # super
    # 可以移动光标的情况下
    if self.active and @item_max > 0 and @index >= 0
      # 方向键下被按下的情况下
      if Input.repeat?(Input::DOWN)
        # 列数不是 1 并且方向键的下的按下状态不是重复的情况、
        # 或光标位置在(项目数-列数)之前的情况下
        if @index<3 && @index+3<$game_variables[159]
          # 光标向下移动
          $game_system.se_play($data_system.cursor_se)
          @index = @index + 3
        end
      end
      # 方向键上被按下的情况下
      if Input.repeat?(Input::UP)
        # 列数不是 1 并且方向键的下的按下状态不是重复的情况、
        # 或光标位置在列之后的情况下
        if @index>=3
          # 光标向上移动
          $game_system.se_play($data_system.cursor_se)
          @index = @index - 3
        end
      end
      # 方向键右被按下的情况下
      if Input.repeat?(Input::RIGHT)
        # 列数为 2 以上并且、光标位置在(项目数 - 1)之前的情况下
        if @index%3 != 2 && @index+1<$game_variables[159]
          # 光标向右移动
          $game_system.se_play($data_system.cursor_se)
          @index += 1
        end
      end
      # 方向键左被按下的情况下
      if Input.repeat?(Input::LEFT)
        # 列数为 2 以上并且、光标位置在 0 之后的情况下
        if @index%3 != 0
          # 光标向左移动
          $game_system.se_play($data_system.cursor_se)
          @index -= 1
        end
      end
    end
    #闭锁判断
    if @index<@bscheck+1
      @index=@bscheck+1
    end
    # 刷新帮助文本 (update_help 定义了继承目标)
    if self.active and @help_window != nil
      update_help
    end
    # 刷新光标矩形
    update_cursor_rect
  end
  def update_cursor_rect
    # 光标位置不满 0 的情况下
    if @index < 0
      self.cursor_rect.empty
      return
    end
    # 更新国标矩形
    self.cursor_rect.set(@index%3*104-4, @index/3*97+3, 104, 100)
  end
  #--------------------------------------------------------------------------
  # ● 刷新
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    @data = []
    for j in 0...$game_variables[159]
      i=@actor.equip_id[j]
      if i==nil
        @data.push(nil)
      else
        @data.push($data_weapons[i])
      end
    end
    @item_max = @data.size
    self.contents.font.color = system_color
    @check_cn=[]

    for i in 0...6
      if i<$game_variables[159]
        #闭锁判断
        ritem=@data[i]
        if $game_variables[285]!=0 && i<=@bscheck
          ritem=$data_weapons[$game_variables[285][i]]
        end
        draw_item_name(ritem, i%3*104+49, i/3*97+60, i)
      else
        draw_item_name($data_weapons[58], i%3*104+49, i/3*97+60 ,i)
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新帮助文本
  #--------------------------------------------------------------------------
  def update_help
    @help_window.set_text(self.item == nil ? "" : self.item.id)
  end
end
