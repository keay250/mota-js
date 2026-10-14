#==============================================================================
# ■ Window_EquipItem
#------------------------------------------------------------------------------
# 　装备画面、显示浏览变更装备的候补物品的窗口。
#==============================================================================

class Window_EquipItem < Window_Selectable
  #--------------------------------------------------------------------------
  # ● 初始化对像
  #     actor      : 角色
  #     equip_type : 装备部位 (0～3)
  #--------------------------------------------------------------------------
  def initialize(actor, equip_type)
    super(0,0,240,452)#(0, 238, 440, 224)
    @actor = actor
    @equip_type = equip_type
    @save_text=nil
    @column_max = 1
    @spr=Sprite.new
    @spr.x=self.x
    @spr.y=self.y
    @spr.bitmap=Bitmap.new(self.width*2,self.height*2)
    @spr.z=100
    @spr.zoom_x=0.5
    @spr.zoom_y=0.5
    @spr2=Sprite.new
    @spr2.x=self.x+16
    @spr2.y=self.y+440
    @spr2.bitmap=Bitmap.new(300,32)
    @spr2.z=100
    @spr2.bitmap.font.size=20
    self.opacity =0
    self.back_opacity =0
    @back_window=Window_Base.new(0, 0, 240, 480)#(0, 238, 440, 224)
    @back_window.z=99
    refresh
    self.active = false
    self.index = -1
  end
  #--------------------------------------------------------------------------
  # ● 获取物品
  #--------------------------------------------------------------------------
  def item
    return @data[self.index]
  end
  def get_size
    return @data.size
  end
  def dispose
    super
    @spr.bitmap.dispose
    @spr.dispose
    @spr2.bitmap.dispose
    @spr2.dispose
    @back_window.dispose
  end
  def setsave(i)
    @save_text="#{i}号套装设定保存成功！"
    refresh
  end
  def update
    super
    refresh_icon
  end
  def refresh_icon
    if @save_top !=self.top_row
      @save_top=self.top_row
      @spr.bitmap.clear
      a=@save_top
      for i in a...[@item_max-3,a+13].min
        item = @data[i]
        x = 4 
        y = (i-a)  * 32
        bitmap = RPG::Cache.icon(item.icon_name)
        @spr.bitmap.blt(x*2+24, y*2+32 , bitmap, Rect.new(0, 0, 86, 64))
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新
  #--------------------------------------------------------------------------
  def refresh
    @spr2.bitmap.clear
    if self.contents != nil
      self.contents.dispose
      self.contents = nil
    end
    @data = []
    # 添加可以装备的武器
    if @equip_type >= 0
      #weapon_set = $data_classes[@actor.class_id].weapon_set
      for i in 1...$data_weapons.size
        if $game_party.weapon_number(i) > 0 #and weapon_set.include?(i)
          @data.push($data_weapons[i])
        end
      end
    end
    @data.sort!{ |a,b| a.price <=> b.price }    
    # 添加空白
    @data.push(nil)
    @data.push(nil)
    @data.push(nil)
    # 生成位图、描绘全部项目
    @item_max = @data.size
    self.contents = Bitmap.new(width - 32,row_max * 32)
    for i in 0...@item_max-3
      draw_item(i)
    end

    
    s = @data.size-3
    x_l = 4
    x_r = 4
    self.contents.font.size = 21
    str="[保存当前装备设定]"
    self.contents.font.color = Color.new(0,0,0,255)
    self.contents.draw_text(x_r-1, s*32-1, 208, 32, str)
    self.contents.draw_text(x_r-1, s*32+1, 208, 32, str)
    self.contents.draw_text(x_r+1, s*32-1, 208, 32, str)
    self.contents.draw_text(x_r+1, s*32+1, 208, 32, str)
    self.contents.font.color = normal_color
    self.contents.draw_text(x_r, s*32, 208, 32, str)
    s+=1
    str="[使用装备]"
    self.contents.font.color = Color.new(0,0,0,255)
    self.contents.draw_text(x_r-1, s*32-1, 128, 32, str)
    self.contents.draw_text(x_r-1, s*32+1, 128, 32, str)
    self.contents.draw_text(x_r+1, s*32-1, 128, 32, str)
    self.contents.draw_text(x_r+1, s*32+1, 128, 32, str)
    self.contents.font.color = normal_color
    self.contents.draw_text(x_r, s*32, 128, 32, str)
    s+=1
    str="[卸除装备]"
    self.contents.font.color = Color.new(0,0,0,255)
    self.contents.draw_text(x_r-1, s*32-1, 128, 32, str)
    self.contents.draw_text(x_r-1, s*32+1, 128, 32, str)
    self.contents.draw_text(x_r+1, s*32-1, 128, 32, str)
    self.contents.draw_text(x_r+1, s*32+1, 128, 32, str)
    self.contents.font.color = normal_color
    self.contents.draw_text(x_r, s*32, 128, 32, str)
    
    if @save_text==nil
      str=$ascii[$game_config.data("keyboard")[2]]
      @spr2.bitmap.draw_text(10,0,290,32, "按"+str+"+数字键保存套装")
    else
      @spr2.bitmap.draw_text(0,0,240,32, @save_text)
    end
    @save_top=-1
    refresh_icon
  end
  #--------------------------------------------------------------------------
  # ● 项目的描绘
  #     index : 项目符号
  #--------------------------------------------------------------------------
  def draw_item(index)
    item = @data[index]
    x = 4
    y = index  * 32
    case item
    when RPG::Weapon
      number = $game_party.weapon_number(item.id)
    when RPG::Armor
      number = $game_party.armor_number(item.id)
    end
   #self.contents.blt(x, y , bitmap, Rect.new(0, 0, 32,32))
    str=item.name.split(":")[0]
    text=TextStream.new
    text.open("Info/Equip/"+str)
    color=text.get_text(1)
    color.sub!(/\[([0-9]+)\]/, "")
    text.close
    self.contents.font.color=text_color($1.to_i)
    self.contents.draw_text(x + 42, y, 96, 32, str, 0)
    self.contents.font.color=normal_color
    self.contents.draw_text(x + 160, y, 24 , 32, "×", 1)
    self.contents.draw_text(x + 180, y, 24, 32, number.to_s, 2)
  end
  #--------------------------------------------------------------------------
  # ● 刷新帮助文本
  #--------------------------------------------------------------------------
  def update_help
    @help_window.set_text(self.item == nil ? "" : self.item.id)
  end
end
