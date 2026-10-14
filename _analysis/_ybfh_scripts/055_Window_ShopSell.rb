#==============================================================================
# ■ Window_ShopSell
#------------------------------------------------------------------------------
# 　商店画面、浏览显示可以卖掉的商品的窗口。
#==============================================================================

class Window_ShopSell < Window_Selectable
  #--------------------------------------------------------------------------
  # ● 初始化对像
  #--------------------------------------------------------------------------
  def initialize
    super(0, 128, 576, 352)
    @column_max = 2
    @spr=Sprite.new
    @spr.x=self.x
    @spr.y=self.y
    @spr.bitmap=Bitmap.new(self.width*2,self.height*2)
    @spr.z=100
    @spr.zoom_x=0.5
    @spr.zoom_y=0.5
    refresh
    self.index = 0
  end
  def dispose
    super
    @spr.bitmap.dispose
    @spr.dispose
  end
  def visible=(i)
    super
    @spr.visible=i
  end
  #--------------------------------------------------------------------------
  # ● 获取物品
  #--------------------------------------------------------------------------
  def item
    return @data[self.index]
  end
  #--------------------------------------------------------------------------
  # ● 刷新
  #--------------------------------------------------------------------------
  def refresh
    if self.contents != nil
      self.contents.dispose
      self.contents = nil
    end
    @spr.bitmap.clear
    @data = []
    for i in 1...$data_items.size
      if $game_party.item_number(i) > 0 && i !=102
        @data.push($data_items[i])
      end
    end
    for i in 1...$data_weapons.size
      j=0
      j=1 if $game_variables[181][i]!=nil && $game_variables[181][i]>0 && i !=52
      if $game_party.weapon_number(i) > j
        @data.push($data_weapons[i])
      end
    end
    # 如果项目数不是 0 就生成位图、描绘全部项目
    @item_max = @data.size
    if @item_max > 0
      self.contents = Bitmap.new(width - 32, row_max * 32)
      for i in 0...@item_max
        draw_item(i)
      end
    end
  end
  def update
    super
    refresh_icon
  end
  def refresh_icon
    if @save_si !=@data.size || @save_top !=self.top_row
      @save_si=@data.size
      @save_top=self.top_row
      @spr.bitmap.clear
      a=@save_top
      for i in 0...@item_max
        item = @data[i]
        index = i
        x = 4 + index % 2 * (256 + 32)
        y = (index / 2-@save_top) * 32
        break if y>=320
        rect = Rect.new(x, y, self.width / @column_max - 32, 32)
        bitmap = RPG::Cache.icon(item.icon_name)
        if item.price > 0
          self.contents.font.color = normal_color
        else
          self.contents.font.color = disabled_color
        end
        opacity = self.contents.font.color == normal_color ? 255 : 128
        if item.is_a?(RPG::Weapon) || bitmap.width>40
          @spr.bitmap.blt(x*2+24,y*2+32, bitmap, Rect.new(0, 0, 86, 64),opacity)
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 描绘项目
  #     index : 项目标号
  #--------------------------------------------------------------------------
  def draw_item(index)
    item = @data[index]
    case item
    when RPG::Item
      number = $game_party.item_number(item.id)
    when RPG::Weapon
      number = $game_party.weapon_number(item.id)
      number-=1 if $game_variables[181][item.id]!=nil && $game_variables[181][item.id]>0 && item.id !=52
    when RPG::Armor
      number = $game_party.armor_number(item.id)
    end
    # 可以卖掉的显示为普通文字颜色、除此之外设置成无效文字颜色
    if item.price > 0
      self.contents.font.color = normal_color
    else
      self.contents.font.color = disabled_color
    end
    x = 4 + index % 2 * (256 + 32)
    y = index / 2 * 32
    rect = Rect.new(x, y, self.width / @column_max - 32, 32)
    self.contents.fill_rect(rect, Color.new(0, 0, 0, 0))
    bitmap = RPG::Cache.icon(item.icon_name)
    opacity = self.contents.font.color == normal_color ? 255 : 128
    if item.is_a?(RPG::Weapon) || bitmap.width>40
      @spr.bitmap.blt(x*2+24,y*2+32, bitmap, Rect.new(0, 0, 86, 64),opacity) if y<320
    else
      self.contents.blt(x, y , bitmap, Rect.new(0, 0, 32, 32), opacity)#物品图标用32*32
    end
    str=item.name.split(":")[0]
    str=item.name.split(":")[0]
    if item.is_a?(RPG::Weapon) && self.contents.font.color !=disabled_color  
      text=TextStream.new
      text.open("Info/Equip/"+str)
      color=text.get_text(1)
      color.sub!(/\[([0-9]+)\]/, "")
      text.close
      self.contents.font.color=text_color($1.to_i)
    end
    self.contents.draw_text(x + 40, y, 212, 32, str, 0)
    self.contents.font.color=normal_color
    self.contents.draw_text(x + 208, y, 16, 32, ":", 1)
    self.contents.draw_text(x + 224, y, 24, 32, number.to_s, 2)
  end
  #--------------------------------------------------------------------------
  # ● 刷新帮助文本
  #--------------------------------------------------------------------------
  def update_help
    case item  
    when RPG::Item  
     @help_window.set_text(item == nil ? "" : item.description)
    when RPG::Weapon
      @help_window.set_text("")
    end
  end
end
