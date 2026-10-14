#==============================================================================
# 本脚本来自www.66RPG.com，使用和转载请保留此信息
#==============================================================================


#==============================================================================
# ■ Harts_Window_ItemTitle
#==============================================================================

class Harts_Window_ItemTitle < Window_Base
  def initialize
    super(0, 0, 160, 64)
    self.contents = Bitmap.new(width - 32, height - 32)
    self.contents.clear
    self.contents.font.color = normal_color
    self.contents.draw_text(4, 0, 120, 32, $data_system.words.item, 1)
  end
end

#==============================================================================
# ■ Harts_Window_ItemCommand
#==============================================================================

class Harts_Window_ItemCommand < Window_Selectable
  attr_accessor :commands
  #--------------------------------------------------------------------------
  # ● 初始化，生成commands窗口
  #--------------------------------------------------------------------------
  def initialize
    super(0, 64, 160, 352)
    @commands = []
    #————————生成commands窗口
    for i in 1...$data_items.size
      if $game_party.item_number(i) > 0
        push = true
        for com in @commands
          if com == $data_items[i].desc
            push = false
          end
        end
        if push == true
          @commands.push($data_items[i].desc)
        end
      end
    end
=begin
    for i in 1...$data_weapons.size
      if $game_party.weapon_number(i) > 0
        push = true
        for com in @commands
          if com == $data_weapons[i].desc
            push = false
          end
        end
        if push == true
          @commands.push($data_weapons[i].desc)
        end
      end
    end
    for i in 1...$data_armors.size
      if $game_party.armor_number(i) > 0
        push = true
        for com in @commands
          if com == $data_armors[i].desc
            push = false
          end
        end
        if push == true
          @commands.push($data_armors[i].desc)
        end
      end
    end
=end
    
    if @commands == []
      @commands.push("")#普通物品")
    end     
    @item_max = @commands.size
    self.contents = Bitmap.new(width - 32, @item_max * 32)
    refresh
    self.index = 0
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    for i in 0...@item_max
      draw_item(i, normal_color)
    end
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def draw_item(index, color)
    self.contents.font.color = color
    y = index * 32
    self.contents.draw_text(4, y, 128, 32, @commands[index])
  end
  #--------------------------------------------------------------------------
  # 只描绘原文字
  #--------------------------------------------------------------------------
  def update_help
    @help_window.set_text(@commands[self.index])
  end
end

#==============================================================================
# ■ Window_Item
#==============================================================================

class Harts_Window_ItemList < Window_Selectable
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def initialize
    super(160, 0, 480, 416)
    refresh
    self.index = 0
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def item
    return @data[self.index]
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def refresh
    if self.contents != nil
      self.contents.dispose
      self.contents = nil
    end
    @data = []
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def set_item(command)
    refresh
    for i in 1...$data_items.size
      if $game_party.item_number(i) > 0 and $data_items[i].desc == command
        @data.push($data_items[i])
      end
    end
    for i in 1...$data_weapons.size
      if $game_party.weapon_number(i) > 0 and $data_weapons[i].desc == command
        @data.push($data_weapons[i])
      end
    end
    for i in 1...$data_armors.size
      if $game_party.armor_number(i) > 0 and $data_armors[i].desc == command
        @data.push($data_armors[i])
      end
    end
    @item_max = @data.size
    if @item_max > 0
      self.contents = Bitmap.new(width - 32, row_max * 32)
      self.contents.clear
      for i in 0...@item_max
        draw_item(i)
      end
    end
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def item_number
    return @item_max
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def draw_item(index)
    item = @data[index]
    #—— 取得具体物品数量 ——
    case item
    when RPG::Item
      number = $game_party.item_number(item.id)
    when RPG::Weapon
      number = $game_party.weapon_number(item.id)
    when RPG::Armor
      number = $game_party.armor_number(item.id)
    end
    #—— 给出物品的颜色 ——
    if item.is_a?(RPG::Item)
      if $game_party.item_can_use?(item.id)
        self.contents.font.color = normal_color
      else
        self.contents.font.color = disabled_color 
      end
    else
      if item.is_a?(RPG::Weapon)#武器不能装备用灰色
        if $data_classes[$data_actors[$game_variables[1]+1].class_id].weapon_set.include?(item.id)
          self.contents.font.color = normal_color
        else
          self.contents.font.color = disabled_color 
         end
      end

      if item.is_a?(RPG::Armor)#防具不能装备用灰色
        if $data_classes[$data_actors[$game_variables[1]+1].class_id].armor_set.include?(item.id)
          self.contents.font.color = normal_color
        else
          self.contents.font.color = disabled_color 
         end
      end
    end

    x = 4
    y = index * 32
    bitmap = RPG::Cache.icon(item.icon_name)
    if bitmap.width>40
      bitmap = RPG::Cache.icon(item.icon_name+"物品")
    end
    opacity = self.contents.font.color == normal_color ? 255 : 128
    self.contents.blt(x, y , bitmap, Rect.new(0, 0, 32, 32), opacity)#物品图标用32*32
    str=item.name.clone
    str.gsub!(/\\[Vv]\[([0-9]+)\]/) { $game_variables[$1.to_i] }
    self.contents.draw_text(x + 40, y, 212, 32, str, 0)
    self.contents.draw_text(x + 240, y, 16, 32, "×", 1) if $game_party.item_number(item.id)>1
    self.contents.draw_text(x + 256, y, 24, 32, number.to_s, 2) if $game_party.item_number(item.id)>1
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def update_help
    @help_window.set_text(self.item == nil ? "" : self.item.description)
  end
end

#==============================================================================
# ■ Harts_Scene_Item
#==============================================================================

class Scene_Item
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def main
    @itemtitle_window = Harts_Window_ItemTitle.new
    @itemcommand_window = Harts_Window_ItemCommand.new
    @command_index = @itemcommand_window.index
    @itemlist_window = Harts_Window_ItemList.new
    @itemlist_window.active = false
    @help_window = Window_Help.new
    @help_window.x = 0
    @help_window.y = 416
    @itemcommand_window.help_window = @help_window
    @itemlist_window.help_window = @help_window
    @target_window = Window_Target.new
    @target_window.visible = false
    @target_window.active = false
    @itemlist_window.set_item(@itemcommand_window.commands[@command_index])
    Graphics.transition
    loop do
      Graphics.update
      Input.update
      update
      if $scene != self
        break
      end
    end
    Graphics.freeze
    @itemtitle_window.dispose
    @itemcommand_window.dispose
    @itemlist_window.dispose
    @help_window.dispose
    @target_window.dispose
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def update
    @itemtitle_window.update
    @itemcommand_window.update
    @itemlist_window.update
    @help_window.update
    @target_window.update
    if @command_index != @itemcommand_window.index
      @command_index = @itemcommand_window.index
      @itemlist_window.set_item(@itemcommand_window.commands[@command_index])
    end
    if @itemcommand_window.active
      update_itemcommand
      return
    end
    if @itemlist_window.active
      update_itemlist
      return
    end
    if @target_window.active
      update_target
      return
    end
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def update_itemcommand
    if Input.trigger?(Input::B)
      $game_system.se_play($data_system.cancel_se)
      $scene = Scene_Map.new
#      $scene = Scene_Menu.new(1)
      return
    end
    if Input.trigger?(Input::C)
      if @itemlist_window.item_number == 0
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      $game_system.se_play($data_system.decision_se)
      @itemcommand_window.active = false
      @itemlist_window.active = true
      @itemlist_window.index = 0
      return
    end
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def update_itemlist
    if Input.trigger?(Input::B)
      $game_system.se_play($data_system.cancel_se)
      @itemcommand_window.active = true
      @itemlist_window.active = false
      @itemlist_window.index = 0
      @itemcommand_window.index = @command_index
      return
    end
    if Input.trigger?(Input::C)
      @item = @itemlist_window.item

      
      target_actor = $game_party.actors[0]#@item_target_window_equip.index]
      if target_actor.equippable?(@item)# and $game_party.item_can_equip?(target_actor,@item)
        $scene = Scene_Equip.new
      end
#      unless @item.is_a?(RPG::Item)
#        $game_system.se_play($data_system.buzzer_se)
#        return
#      end
      unless $game_party.item_can_use?(@item.id)
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      $game_system.se_play($data_system.decision_se)
      if @item.scope >= 3
        @itemlist_window.active = false
        @target_window.x = 304
        @target_window.visible = true
        @target_window.active = true
        if @item.scope == 4 || @item.scope == 6
          @target_window.index = -1
        else
          @target_window.index = 0
        end
      else
        if @item.common_event_id > 0
          
          #      #下一句在使用物品时获得物品id
          $game_variables[20] = @item.id
          
          $game_temp.common_event_id = @item.common_event_id
          $game_system.se_play(@item.menu_se)
            if @item.consumable
              $game_party.lose_item(@item.id, 1)
              @itemlist_window.draw_item(@itemlist_window.index)
            end
          $scene = Scene_Map.new
          return
        end
      end
      return
    end
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def update_target
    if Input.trigger?(Input::B)
      $game_system.se_play($data_system.cancel_se)
      unless $game_party.item_can_use?(@item.id)
        @itemlist_window.refresh
      end
      @itemlist_window.active = true
      @target_window.visible = false
      @target_window.active = false
      @itemlist_window.set_item(@itemcommand_window.commands[@command_index])
      return
    end
    if Input.trigger?(Input::C)
      if $game_party.item_number(@item.id) == 0
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      if @target_window.index == -1
        used = false
        for i in $game_party.actors
          used |= i.item_effect(@item)
        end
      end
      if @target_window.index >= 0
        target = $game_party.actors[@target_window.index]
        used = target.item_effect(@item)
      end
      if used
        $game_system.se_play(@item.menu_se)
        if @item.consumable
          $game_party.lose_item(@item.id, 1)
          @itemlist_window.draw_item(@itemlist_window.index)
          @itemlist_window.set_item(@itemcommand_window.commands[@command_index])
        end
        @target_window.refresh
        if $game_party.all_dead?
          $scene = Scene_Gameover.new
          return
        end
        if @item.common_event_id > 0
          $game_temp.common_event_id = @item.common_event_id
          $scene = Scene_Map.new
          return
        end
      end
      unless used
        $game_system.se_play($data_system.buzzer_se)
      end
    return
    end
  end
end

#==============================================================================
# ■ RPG追加定义，使用@符号分类
#==============================================================================

module RPG
  class Weapon
    def description
      description = @description.split(/@/)[0]
      return description != nil ? description : ''
    end
    def desc
      desc = @description.split(/@/)[1]
      return desc != nil ? desc : "普通物品"
    end
  end
  class Item
    def description
      description = @description.split(/@/)[0]
      return description != nil ? description : ''
    end
    def desc
      desc = @description.split(/@/)[1]
      return desc != nil ? desc : "普通物品"
    end
  end
  class Armor
    def description
      description = @description.split(/@/)[0]
      return description != nil ? description : ''
    end
    def desc
      desc = @description.split(/@/)[1]
      return desc != nil ? desc : "普通物品"
    end
  end
end

#==============================================================================
# 本脚本来自www.66RPG.com，使用和转载请保留此信息
#==============================================================================