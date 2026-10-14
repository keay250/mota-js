class Window_Suit < Window_Base
  #--------------------------------------------------------------------------
  # ● 初始化对像
  #--------------------------------------------------------------------------
  attr_reader   :index                    # 光标位置
  def initialize(kind = 0)
    super(0,0,640,480)
    self.contents = Bitmap.new(width - 32, height - 32)
    @kind=kind
    @spr=[]
    for i in 0...10
      @spr[i]=Sprite.new
      @spr[i].bitmap=Bitmap.new(550,128)
      @spr[i].x=i/5*320+16
      @spr[i].y=i%5*90+56
      @spr[i].zoom_x=0.5
      @spr[i].zoom_y=@spr[i].zoom_x
      @spr[i].z=self.z
    end
    refresh
    @index=0
    @item_max=10
  end  
  def dispose
    super
    for i in 0...10
      @spr[i].bitmap.dispose
      @spr[i].dispose
    end
  end
  #--------------------------------------------------------------------------
  # ● 自定义光标
  #--------------------------------------------------------------------------
  def update
    super
    if Input.repeat?(Input::RIGHT)
      $game_system.se_play($data_system.cursor_se)
      @index=(@index+5)%10
    end
    if Input.repeat?(Input::LEFT)
      $game_system.se_play($data_system.cursor_se)
      @index=(@index-5)%10
    end
    if Input.repeat?(Input::UP)
      $game_system.se_play($data_system.cursor_se)
      @index=(@index-1)%10
    end
    if Input.repeat?(Input::DOWN)
      $game_system.se_play($data_system.cursor_se)
      @index=(@index+1)%10
    end
    # 更新国标矩形
    self.cursor_rect.set(@index/5*320 ,@index%5*90, 288,80)
  end
  #--------------------------------------------------------------------------
  # ● 设置文本
  #     text  : 窗口显示的字符串
  #     align : 对齐方式 (0..左对齐、1..中间对齐、2..右对齐)
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    for i in 0...10
      @spr[i].bitmap.clear
    end
    if @kind==0
      if $game_variables[174]==0
        self.active=false
        self.contents.draw_text(120,180,400,32,"当前角色还没有设定过任何套装！", 1)
        str=$ascii[$game_config.data("keyboard")[2]]
        self.contents.draw_text(120,212,400,32,"在装备界面按"+str+"+数字键保存套装设定", 1)
        self.contents.draw_text(70,244,500,32,"或在装备界面中选择“保存当前装备设定”", 1)
        return
      end
      if $game_variables[174][$game_variables[1]]==nil
        self.active=false
        self.contents.draw_text(120,180,400,32,"当前角色还没有设定过任何套装！", 1)
        str=$ascii[$game_config.data("keyboard")[2]]
        self.contents.draw_text(120,212,400,32,"在装备界面按"+str+"+数字键保存套装设定", 1)
        self.contents.draw_text(70,244,500,32,"或在装备界面中选择“保存当前装备设定”", 1)
        return
      end
    else
      if $game_variables[174]==0
        $game_variables[174]=[]
      end
      if $game_variables[174][$game_variables[1]]==nil
        $game_variables[174][$game_variables[1]]=[]
      end
    end
    kk=[1,2,3,4,5,6,7,8,9,0]
    self.contents.font.color=system_color
    for i in 0...10
      self.contents.draw_text(i/5*320,i%5*90,180,32,"第#{kk[i]}号套装", 0)
      k=0
      if $game_variables[174][$game_variables[1]][kk[i]]!=nil
      for j in $game_variables[174][$game_variables[1]][kk[i]]
        if j!=nil && j!=0
          bitmap = RPG::Cache.icon($data_weapons[j].icon_name)
          @spr[i].bitmap.blt(k*94,0 , bitmap, Rect.new(0, 0, 86, 64))
          k+=1
        end
      end
      end
    end
  end
end

class Scene_Suit
  def initialize(kind = 0)
    @kind=kind
  end
  def main
    $right_back_spr=Sprite.new
    if $game_switches[140]
      $right_back_spr.bitmap=RPG::Cache.picture("nevermore")
    else
      $right_back_spr.bitmap=RPG::Cache.picture("sven")
    end
    $right_back_spr.x=640
    $right_back_spr.z=100
    @suit_window=Window_Suit.new(@kind)
    Graphics.transition
    # 主循环
    loop do
      # 刷新游戏画面
      Graphics.update
      # 刷新输入信息
      Input.update
      if @suit_window.active
        @suit_window.update
      end
      # 刷新画面
      update
      # 如果画面切换的话的就中断循环
      if $scene != self
        break
      end
    end
    # 准备过渡
    Graphics.freeze
    # 释放窗口
    @suit_window.dispose
  end
  def update
    if Kboard.trigger?($game_config.data("keyboard")[1]) || Input.trigger?(Input::B)
      $game_system.se_play($data_system.cancel_se)
      $scene = Scene_Map.new
    end
    if Input.trigger?(Input::C) 
      if !@suit_window.active
        $game_system.se_play($data_system.cancel_se)
        $scene = Scene_Map.new
      else
        if @kind==0
          # 使用装备
          kk=[1,2,3,4,5,6,7,8,9,0]
          $game_variables[12]=kk[@suit_window.index]
          $game_temp.common_event_id = 40
          $scene = Scene_Map.new
          return
        end
        if @kind==1
          # 演奏装备 SE
          $game_system.se_play($data_system.equip_se)
          # 设定套装
          kk=[1,2,3,4,5,6,7,8,9,0]
          $game_variables[174][$game_variables[1]][kk[@suit_window.index]]=$game_actors[$game_variables[1]+1].equip_id.clone
          @suit_window.refresh
        end
      end
      
    end
  end
end