#==============================================================================
# ■ Window_ShopBuy
#------------------------------------------------------------------------------
# 　商店画面、浏览显示可以购买的商品的窗口。
#==============================================================================

class Window_ShopBuy < Window_Selectable
  #--------------------------------------------------------------------------
  # ● 初始化对像
  #     shop_goods : 商品
  #--------------------------------------------------------------------------
  def initialize(shop_goods)
    super(0, 128, 368, 352)
    @shop_goods = shop_goods
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
    for goods_item in @shop_goods
      case goods_item[0]
      when 0
        item = $data_items[goods_item[1]]
      when 1
        item = $data_weapons[goods_item[1]]
      when 2
        item = $data_armors[goods_item[1]]
      end
      if item != nil
        @data.push(item)
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
  #--------------------------------------------------------------------------
  # ● 描绘羡慕
  #     index : 项目编号
  #--------------------------------------------------------------------------
  def draw_item(index)
    item = @data[index]
    # 获取物品所持数
    case item
    when RPG::Item
      number = $game_party.item_number(item.id)
    when RPG::Weapon
      number = $game_party.weapon_number(item.id)
    when RPG::Armor
      number = $game_party.armor_number(item.id)
    end
    # 价格在所持金以下、并且所持数不是 99 的情况下为普通文字颜色
    # 除此之外的情况设置为无效文字色
    if item.price <= $game_party.gold and number < 99
      self.contents.font.color = normal_color
    else
      self.contents.font.color = disabled_color
    end
    x = 4
    y = index * 32
    rect = Rect.new(x, y, self.width - 32, 32)
    self.contents.fill_rect(rect, Color.new(0, 0, 0, 0))
    bitmap = RPG::Cache.icon(item.icon_name)
    opacity = self.contents.font.color == normal_color ? 255 : 128
    if item.is_a?(RPG::Weapon)
      @spr.bitmap.blt(x*2+24,y*2+32, bitmap, Rect.new(0, 0, 86, 64))
    else
      self.contents.blt(x, y , bitmap, Rect.new(0, 0, 32, 32), opacity)#物品图标用32*32
    end
    self.contents.draw_text(x + 44, y, 212, 32, item.name.split(":")[0], 0)
         
    self.contents.font.color = normal_color if item.price <= $game_party.gold and number < 99
    self.contents.draw_text(x + 200, y, 65, 32, item.price.to_s ,2)

    if item.price <= $game_party.gold and number < 99
      self.contents.font.color = normal_color
    else
      self.contents.font.color = disabled_color
    end

    self.contents.draw_text(x + 270, y, 60, 32,$data_system.words.gold+"/个", 0)
  end
  #--------------------------------------------------------------------------
  # ● 刷新帮助文本
  #--------------------------------------------------------------------------
  def update_help
    @help_window.set_text(self.item == nil ? "" : self.item.description)
  end
end
