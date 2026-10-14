#==============================================================================
# 本脚本来自www.66RPG.com，使用和转载请保留此信息
#==============================================================================


# 脚本使用设定：

#LEVEL_UP_POINT = 4  # 每升一级所增加的点数,已用80号变量替代
LEVEL_UP_VARIABLE = 81  # 储存角色点数的变量编号与角色id编号的差值
                         # 默认情况 ＝ 80，
                         # 则是数据库里1号角色的加点数存于81号变量
                         # 2号角色的加点数存于82号变量。
                         # 你可以直接操作变量赠与角色可分配点数

# 每增加一次点数，各项能力值的变化：357－410行
                        
# 使用方法介绍：

# 本脚本不会取代原升级功能 也就是说，默认的升级还在，但可以用这个功能手动追加点数。
# 如果你想纯粹使用手动加点(而升级不提升能力)，只要把数据库中角色升级能力，
# 1－99级全部等于一个相同数值就行了。

# 呼唤加点场景的方法：$scene = Scene_Lvup.new(角色编号，返回菜单编号)。
# 默认都是0号

# 加点场景中，page up，page down换人,如果想加点完毕后返回地图，
# 464行$scene = Scene_Menu.new(0)改为$scene = Scene_Map.new

# 推荐脚本搭配：魔法商店脚本，两者结合，制作自由型RPG

#==============================================================================
# ■ Window_Command
#------------------------------------------------------------------------------
# 　一般的命令选择行窗口。（追加定义）
#==============================================================================
class Window_Command < Window_Selectable
  #--------------------------------------------------------------------------
  # ● 项目有效化
  #     index : 项目编号
  #--------------------------------------------------------------------------
  def able_item(index)
    draw_item(index, normal_color)
  end
end
#==============================================================================
# ■ Game_Actor
#------------------------------------------------------------------------------
# 　处理角色的类。（再定义）
#==============================================================================
#class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # ● 更改 EXP
  #     exp : 新的 EXP
  #--------------------------------------------------------------------------
#  def exp=(exp)
#    @exp = [[exp, 9999999].min, 0].max
    # 升级
#    while @exp >= @exp_list[@level+1] and @exp_list[@level+1] > 0
#      @level += 1
      # 增加4点可自由分配的点数
#      $game_variables[self.id + LEVEL_UP_VARIABLE] += $game_variables[80]
      # 学会特技
#      for j in $data_classes[@class_id].learnings
#        if j.level == @level
#          learn_skill(j.skill_id)
#        end
#      end
#    end
    # 降级
#    while @exp < @exp_list[@level]
#      @level -= 1
#    end
    # 修正当前的 HP 与 SP 超过最大值
#    @hp = [@hp, self.maxhp].min
#    @sp = [@sp, self.maxsp].min
#  end
#end
#==============================================================================
# ■ Window_Base
#------------------------------------------------------------------------------
# 　游戏中全部窗口的超级类（追加定义）
#==============================================================================
class Window_Base < Window
  #--------------------------------------------------------------------------
  # ● 描绘 HP
  #     actor : 角色
  #     x     : 描画目标 X 坐标
  #     y     : 描画目标 Y 坐标
  #     width : 描画目标的宽
  #--------------------------------------------------------------------------
  def draw_actor_hp_lvup(actor, x, y)
    self.contents.font.color = system_color
    self.contents.draw_text(x , y, 96, 32, $data_system.words.hp)
    self.contents.font.color = normal_color
    if $temp_hp == 0
      self.contents.draw_text(x + 80 , y, 72, 32, actor.hp.to_s, 2)
    else
      hp = actor.hp + $temp_hp
      self.contents.draw_text(x + 80 , y, 72, 32, actor.hp.to_s ,2)
#      self.contents.draw_text(x + 155, y, 36, 32, "( ", 2)
      if $temp_hp >=0
        self.contents.font.color = text_color(3)
        bitmap = Bitmap.new("Graphics/Pictures/up.png")
        self.contents.blt(x + 155, y+6, bitmap, Rect.new(0, 0, 20, 20))
#        self.contents.draw_text(x + 155, y, 36, 32, " +",2)
#      else
#        self.contents.font.color = text_color(9)
#        self.contents.draw_text(x + 155, y, 36, 32, " -",2)
      end
      self.contents.draw_text(x + 190, y, 72, 32, hp.to_s, 2)
      self.contents.draw_text(x + 265, y, 80, 32, "(+"+$temp_hp.to_s+")", 0)
      self.contents.font.color = normal_color
#      self.contents.draw_text(x + 215, y, 36, 32, ")", 2)
    end
  end
  #--------------------------------------------------------------------------
  # ● 描绘 SP
  #     actor : 角色
  #     x     : 描画目标 X 坐标
  #     y     : 描画目标 Y 坐标
  #     width : 描画目标的宽
  #--------------------------------------------------------------------------
  def draw_actor_sp_lvup(actor, x, y)
    self.contents.font.color = system_color
    self.contents.draw_text(x , y, 96, 32, "最大" + $data_system.words.sp)
    if $temp_sp == 0
      self.contents.font.color = normal_color
      self.contents.draw_text(x + 120 , y, 48, 32, actor.maxsp.to_s, 2)
    else
      maxsp = actor.maxsp + $temp_sp
      self.contents.font.color = Color.new(255, 128, 128, 255)
      self.contents.draw_text(x + 120 , y, 48, 32, maxsp.to_s ,2)
      self.contents.font.color = normal_color     
      self.contents.draw_text(x + 155, y, 36, 32, "( ", 2)
      if $temp_sp >=0
        self.contents.font.color = Color.new(255, 128, 128, 255)
        self.contents.draw_text(x + 155, y, 36, 32, " +",2)
      else
        self.contents.font.color = Color.new(255,255,0,255)
        self.contents.draw_text(x + 155, y, 36, 32, " -",2)
      end
      self.contents.draw_text(x + 200, y, 36, 32, $temp_sp.to_s, 2)
      self.contents.font.color = normal_color
      self.contents.draw_text(x + 215, y, 36, 32, ")", 2)
    end
  end
  #--------------------------------------------------------------------------
  # ● 描绘能力值
  #     actor : 角色
  #     x     : 描画目标 X 坐标
  #     y     : 描画目标 Y 坐标
  #     type  : 能力值种类 (0～4)
  #--------------------------------------------------------------------------
  def draw_actor_lvup(actor, x, y, type)   

    # 定义数字颜色
    lvup = normal_color
    upcolor = text_color(3)
    self.contents.font.color = normal_color   
    case type
    when 0
      parameter_name = $data_system.words.str
      parameter_value = actor.str
      parameter_value_temp = parameter_value + $temp_str
      if $temp_str != 0
        lvup = upcolor
#        self.contents.draw_text(x + 256, y, 16, 32, "(")
        if $temp_str >= 0
          self.contents.font.color = lvup
          bitmap = Bitmap.new("Graphics/Pictures/up.png")
          self.contents.blt(x + 155, y+6, bitmap, Rect.new(0, 0, 20, 20))

#          self.contents.draw_text(x + 272, y, 80, 32, "+",0)
#        else
#          self.contents.font.color = Color.new(255,255,0,255)
#          self.contents.draw_text(x + 272, y, 80, 32, "-",0)
        end       
        self.contents.draw_text(x + 190, y, 72, 32, parameter_value_temp.abs.to_s,2)
        self.contents.draw_text(x + 265, y, 56, 32, "(+"+$temp_str.to_s+")", 0)
        self.contents.font.color = normal_color
#        self.contents.draw_text(x + 272, y, 80, 32, ")", 2)
      end
    when 1
      parameter_name = $data_system.words.dex
      parameter_value = actor.dex
      parameter_value_temp = parameter_value + $temp_dex
      if $temp_dex != 0
        lvup = upcolor
#        self.contents.draw_text(x + 256, y, 16, 32, "(")
        if $temp_dex >= 0
          self.contents.font.color = lvup
          bitmap = Bitmap.new("Graphics/Pictures/up.png")
          self.contents.blt(x + 155, y+6, bitmap, Rect.new(0, 0, 20, 20))
#          self.contents.draw_text(x + 272, y, 80, 32, "+",0)
#        else
#          self.contents.font.color = Color.new(255,255,0,255)
#          self.contents.draw_text(x + 272, y, 80, 32, "-",0)
        end       
        self.contents.draw_text(x + 190, y, 72, 32, parameter_value_temp.abs.to_s,2)
        self.contents.draw_text(x + 265, y, 56, 32, "(+"+$temp_dex.to_s+")", 0)
        self.contents.font.color = normal_color
#        self.contents.draw_text(x + 272, y, 80, 32, ")", 2)
      end
    when 2
      parameter_name = $data_system.words.int
      parameter_value = actor.int
      parameter_value_temp = parameter_value + $temp_int
      if $temp_int != 0
        lvup = upcolor
#        self.contents.draw_text(x + 256, y, 16, 32, "(")
        if $temp_int >= 0
          self.contents.font.color = lvup
          bitmap = Bitmap.new("Graphics/Pictures/up.png")
          self.contents.blt(x + 155, y+6, bitmap, Rect.new(0, 0, 20, 20))
#          self.contents.draw_text(x + 272, y, 80, 32, "+",0)
#        else
#          self.contents.font.color = Color.new(255,255,0,255)
#          self.contents.draw_text(x + 272, y, 80, 32, "-",0)
        end       
        self.contents.draw_text(x + 190, y, 72, 32, parameter_value_temp.abs.to_s,2)
        self.contents.draw_text(x + 265, y, 56, 32, "(+"+$temp_int.to_s+")", 0)
        self.contents.font.color = normal_color
#        self.contents.draw_text(x + 272, y, 80, 32, ")", 2)
      end
    when 3
      parameter_name = $data_system.words.agi
      parameter_value = actor.agi
      parameter_value_temp = parameter_value + $temp_agi
      if $temp_agi != 0
        lvup = upcolor
#        self.contents.draw_text(x + 256, y, 16, 32, "(")
        if $temp_agi >= 0
          self.contents.font.color = lvup
          bitmap = Bitmap.new("Graphics/Pictures/up.png")
          self.contents.blt(x + 155, y+6, bitmap, Rect.new(0, 0, 20, 20))
#          self.contents.draw_text(x + 272, y, 80, 32, "+",0)
#        else
#          self.contents.font.color = Color.new(255,255,0,255)
#          self.contents.draw_text(x + 272, y, 80, 32, "-",0)
        end       
        self.contents.draw_text(x + 190, y, 72, 32, parameter_value_temp.abs.to_s,2)
        self.contents.draw_text(x + 265, y, 56, 32, "(+"+$temp_agi.to_s+")", 0)
        self.contents.font.color = normal_color
#        self.contents.draw_text(x + 272, y, 80, 32, ")", 2)
      end
    when 4
      parameter_name = "剩余点数"
      self.contents.font.color = system_color 
      self.contents.draw_text(x, y, 120, 32, parameter_name)
      parameter_value = $point
      if $point != 0
        lvup = upcolor
      end
      if $temp_point!= 0
        self.contents.font.color = text_color(9)
        bitmap = Bitmap.new("Graphics/Pictures/down.png")
        self.contents.blt(x + 155, y+6, bitmap, Rect.new(0, 0, 20, 20))
#        self.contents.draw_text(x + 190, y, 72, 32, $temp_point.abs.to_s,2)
        self.contents.draw_text(x + 170, y, 56, 32, "(-"+$temp_point.to_s+")", 0)
      else
        self.contents.font.color = normal_color
      end

    end   
    self.contents.font.color = system_color if type != 4 
    self.contents.draw_text(x, y, 120, 32, parameter_name) if type!= 4
    self.contents.font.color = normal_color if type != 4
    self.contents.draw_text(x +87, y, 65, 32, parameter_value.to_s,2)   
#    if type != 4
#      self.contents.draw_text(x + 150, y, 36, 32, "→")
#    end 
#    self.contents.font.color = lvup
#    self.contents.draw_text(x + 180, y, 60, 32, parameter_value_temp.to_s)
    self.contents.font.color = normal_color       
  end
end
#==============================================================================
# ■ Window_lvup
#------------------------------------------------------------------------------
# 　显示升级状态窗口。
#==============================================================================
class Window_Lvup < Window_Base
  #--------------------------------------------------------------------------
  # ● 初始化对像
  #     actor : 角色
  #--------------------------------------------------------------------------
  def initialize(actor)
    super(0, 0, 512, 320)
    self.contents = Bitmap.new(width - 32, height - 32)
    @actor = actor
    refresh
  end 
  #--------------------------------------------------------------------------
  # ● 刷新
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    y=32
    y=40 if !$game_switches[19] or !$game_switches[27]
    draw_actor_graphic(@actor, 40, 90)
    draw_actor_name(@actor, 15, 5)
#    draw_actor_class(@actor, 4 + 144, 0)
    draw_actor_level(@actor, 96, 5)
#    draw_actor_state(@actor, 96, 64)   
    draw_actor_hp_lvup(@actor, 96, y*2)
#    draw_actor_sp_lvup(@actor, 96+128, 64)
    draw_actor_lvup(@actor, 96, y*3, 0)
    draw_actor_lvup(@actor, 96, y*4, 1)
    draw_actor_lvup(@actor, 96, y*6, 3) if $game_switches[27] and $game_switches[19]
    draw_actor_lvup(@actor, 96, y*5, 3) if $game_switches[27] and !$game_switches[19]
    
    draw_actor_lvup(@actor, 96, y*5, 2) if $game_switches[19]
    draw_actor_lvup(@actor, 96, 256, 4)
  end
end
#==============================================================================
# ■ Window_Help
#------------------------------------------------------------------------------
# 　特技及物品的说明、角色的状态显示的窗口。
#==============================================================================
class Window_Lvup_Help < Window_Base
  #--------------------------------------------------------------------------
  # ● 初始化对像
  #--------------------------------------------------------------------------
  def initialize
    super(0, 320, 640, 160)
    self.contents = Bitmap.new(width - 32, height - 32)
    @test = "" #——这个东西用来检测，节约内存专用
  end 
  #--------------------------------------------------------------------------
  # ● 设置文本
  #--------------------------------------------------------------------------
  def lvup_text(text1, text2 = nil, text3 = nil, text4 = nil)
    if @test != text1
      @test = text1
    else
      return
    end   
    self.contents.clear
#    self.contents.font.size -= 4
    self.contents.font.color = normal_color
    self.contents.draw_text(4, 0, self.width - 40, 32, text1)
    if text2 != nil
      self.contents.draw_text(4 , 64, self.width - 40, 32, text2)
    end
#    self.contents.font.size += 4
    if text3 != nil
      self.contents.font.color = text_color(3)
      self.contents.draw_text(120 , 64, self.width - 40, 32, text3)
    end
    if text4 != nil
      self.contents.draw_text(4 , 96, self.width - 40, 32, text4)
    end
#    self.contents.font.size += 4
  end
end
#==============================================================================
# ■ Scene_lvup
#------------------------------------------------------------------------------
# 　处理升级画面的类。
#==============================================================================
class Scene_Lvup
  #--------------------------------------------------------------------------
  # ● 初始化对像
  #     actor_index : 角色索引
  #     menu_index : 选项起始位置
  #--------------------------------------------------------------------------
  def initialize(actor_index = 0 , menu_index = 0)
    @actor_index = actor_index
    @menu_index = menu_index
  end
  #--------------------------------------------------------------------------
  # ● 主处理
  #--------------------------------------------------------------------------
  def main
    s1 = "增加"+$data_system.words.hp
    s2 = "增加"+$data_system.words.str
    s3 = "增加"+$data_system.words.dex
    s4 = "增加"+$data_system.words.int 
    s5 = "增加"+$data_system.words.agi 
    s6 = "确认加点"
    s7 = "点数重置"
    @command_window = Window_Command.new(128, [s1, s2, s3, s4, s5, s6, s7])
    @command_window.index = @menu_index
    # 获取角色
    @actor = $game_party.actors[@actor_index]
    # 将角色的剩余点数带入
    $point = $game_variables[LEVEL_UP_VARIABLE][@actor.id-1]
    # 初始化临时量
    $temp_str = 0
    $temp_dex = 0
    $temp_agi = 0
    $temp_int = 0
    $temp_hp = 0
    $temp_sp = 0
    $temp_point = 0
    #=========================================================================
    # 特别提示：这些设置也可以使用小数，但是可能出现0值意外错误
    #  (各种编程语言都有这种意外)，建议还是使用整数，正负不限
    #=========================================================================
    # 每提升一次力量，提升多少附加能力
    #=========================================================================
    @str_hp = 0     # 每提升一次力量附加提升多少HP
    @str_sp = 0     # 每提升一次力量附加提升多少SP
    @str_dex = 0    # 每提升一次力量附加提升多少灵巧
    @str_agi = 0    # 每提升一次力量附加提升多少速度
    @str_int = 0    # 每提升一次力量附加提升多少魔力
    @str_str = 1    # 每提升一次力量附加提升多少力量
    #=========================================================================
    # 每提升一次灵巧，提升多少附加能力
    #=========================================================================
    @dex_hp = 0     # 每提升一次灵巧附加提升多少HP
    @dex_sp = 0     # 每提升一次灵巧附加提升多少SP
    @dex_str = 0    # 每提升一次灵巧附加提升多少力量
    @dex_agi = 0    # 每提升一次灵巧附加提升多少速度
    @dex_int = 0    # 每提升一次灵巧附加提升多少魔力
    @dex_dex = 2    # 每提升一次灵巧附加提升多少灵巧
    #=========================================================================
    # 每提升一次速度，提升多少附加能力
    #=========================================================================
    @agi_hp = 0     # 每提升一次速度附加提升多少HP
    @agi_sp = 0     # 每提升一次速度附加提升多少SP
    @agi_str = 0    # 每提升一次速度附加提升多少力量
    @agi_dex = 0    # 每提升一次速度附加提升多少灵巧
    @agi_int = 0    # 每提升一次速度附加提升多少魔力
    @agi_agi = 1    # 每提升一次速度附加提升多少速度
    #=========================================================================
    # 每提升一次魔力，提升多少附加能力
    #=========================================================================
    @int_hp = 0     # 每提升一次魔力附加提升多少HP
    @int_sp = 0    # 每提升一次魔力附加提升多少SP
    @int_str = 0   # 每提升一次魔力附加提升多少力量
    @int_dex = 0   # 每提升一次魔力附加提升多少灵巧
    @int_agi = 0   # 每提升一次魔力附加提升多少速度
    @int_int = 5   # 每提升一次魔力附加提升多少魔力
    #=========================================================================
    # 每提升一次体力，提升多少附加能力
    #=========================================================================
    @hp = 125       # 每提升一次体力提升多少HP
    @sp = 0       # 每提升一次体力提升多少SP
    @hp_str = 0   # 每提升一次体力提升多少力量
    @hp_dex = 0   # 每提升一次体力提升多少速度
    @hp_agi = 0   # 每提升一次体力提升多少灵巧
    @hp_int = 0   # 每提升一次体力提升多少魔力   
    # 定义说明文字
    @text_hp_sc =  "可以增加角色的生命"
    @text_str_sc = "可以提高角色的攻击"
    @text_dex_sc = "可以提高角色的防御"
    @text_agi_sc = "可以提高角色的速度"
    @text_int_sc = "可以提高角色的魔防"
    @text_save = "保存分配情况并返回游戏"
    @text_reset= "重新分配能力点数"
    @text_2 = "每增加1点，"
    @text_hp  = $data_system.words.hp  + "值"
    @text_sp  = $data_system.words.sp  + "值"
    @text_str = $data_system.words.str + "值"
    @text_dex = $data_system.words.dex + "值"
    @text_agi = $data_system.words.agi + "值"
    @text_int = $data_system.words.int + "值"
    s_disable
    # 生成状态窗口
    @lvup_window = Window_Lvup.new(@actor)
    @lvup_window.x = 128
    @lvup_window.y = 0   
    # 生成帮助窗口并初始化帮助文本
    @help_window = Window_Lvup_Help.new   
    # 执行过渡
    Graphics.transition#(40, "Graphics/Transitions/" + $data_system.battle_transition)
    # 主循环
    loop do
      # 刷新游戏画面
      Graphics.update
      # 刷新输入信息
      Input.update
      # 刷新画面
      update
      # 如果切换画面就中断循环
      if $scene != self
        break
      end
    end
    # 准备过渡
    Graphics.freeze
    # 释放窗口
    @command_window.dispose
    @lvup_window.dispose
    @help_window.dispose
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面
  #--------------------------------------------------------------------------
  def update
    # 刷新窗口
    @command_window.update
    # 选项明暗判断（因为太消耗资源，所以屏蔽掉了）
    s_disable
    @lvup_window.update
    #=============================================================
    # 按下 B 键的情况下
    #=============================================================
    if Input.trigger?(Input::B)
      # 演奏取消 SE
      $game_system.se_play($data_system.cancel_se)
      # 切换到地图画面
      $scene = Scene_Map.new
      return
    end
    #=============================================================
    # 按下 C 键的情况下
    #=============================================================
    if Input.trigger?(Input::C)     
      if @command_window.index == 5
          # 演奏确定 SE
        $game_system.se_play($data_system.decision_se)
        # 将角色的剩余点数带回
        $game_variables[LEVEL_UP_VARIABLE][@actor.id-1] = $point
        # 将角色点数实际加上
        @actor.str += $temp_str
        @actor.dex += $temp_dex
        @actor.agi += $temp_agi
        @actor.int += $temp_int
        @actor.hp  += $temp_hp
        @actor.maxsp += $temp_sp
        # 切换到地图画面
        $scene = Scene_Map.new
        return
      end
      if @command_window.index == 6
          # 演奏确定 SE
        $game_system.se_play($data_system.cancel_se)
          # 将角色的剩余点数带入
        $point = $game_variables[LEVEL_UP_VARIABLE][@actor.id-1]
          # 初始化临时量
        $temp_str = 0
        $temp_dex = 0
        $temp_agi = 0
        $temp_int = 0
        $temp_hp = 0
        $temp_sp = 0
        $temp_point = 0
        @lvup_window.refresh
        return
      end
      if $point == 0
        # 演奏冻结 SE
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      case @command_window.index
      when 0
        # 演奏确定 SE
        $game_system.se_play($data_system.decision_se)
        $temp_hp += @hp
        $temp_sp += @sp
        $temp_str += @hp_str
        $temp_dex += @hp_dex
        $temp_agi += @hp_agi
        $temp_int += @hp_int
        $temp_point += 1
        $point -= 1
        @lvup_window.refresh
        s_disable
        return
      when 1
        # 演奏确定 SE
        $game_system.se_play($data_system.decision_se)
        $temp_str += @str_str
        $temp_hp += @str_hp
        $temp_sp += @str_sp
        $temp_dex += @str_dex
        $temp_agi += @str_agi
        $temp_int += @str_int
        $temp_point += 1
        $point -= 1
        @lvup_window.refresh
        s_disable
        return
      when 2
        # 演奏确定 SE
        $game_system.se_play($data_system.decision_se)
        $temp_dex += @dex_dex
        $temp_hp += @dex_hp
        $temp_sp += @dex_sp
        $temp_str += @dex_str
        $temp_agi += @dex_agi
        $temp_int += @dex_int
        $temp_point += 1
        $point -= 1
        @lvup_window.refresh
        s_disable
        return
      when 4
        if !$game_switches[27]
          # 演奏冻结 SE
          $game_system.se_play($data_system.buzzer_se)
          return
        end
        # 演奏确定 SE
        $game_system.se_play($data_system.decision_se)
        $temp_agi += @agi_agi
        $temp_hp += @agi_hp
        $temp_sp += @agi_sp
        $temp_str += @agi_str
        $temp_dex += @agi_dex
        $temp_int += @agi_int
        $temp_point += 1
        $point -= 1
        @lvup_window.refresh
        s_disable
        return
      when 3
        if !$game_switches[19]
          # 演奏冻结 SE
          $game_system.se_play($data_system.buzzer_se)
          return
        end

        # 演奏确定 SE
        $game_system.se_play($data_system.decision_se)
        $temp_int += @int_int
        $temp_hp += @int_hp
        $temp_sp += @int_sp
        $temp_str += @int_str
        $temp_dex += @int_dex
        $temp_agi += @int_agi
        $temp_point += 1
        $point -= 1
        @lvup_window.refresh
        s_disable
        return
      end
    end
    #=============================================================
    # 什么都没有按下的情况
    #=============================================================
    case @command_window.index   
    when 0  # 增加体力
      temptext1 = @text_hp + "+"+ @hp.to_s + "点   " 
      @help_window.lvup_text(@text_hp_sc , @text_2 , temptext1)
    when 1  # 增加力量
      temptext1 = @text_str + "+"+ @str_str.to_s + "点   " 
      @help_window.lvup_text(@text_str_sc , @text_2 , temptext1)
    when 2  # 增加灵巧
      temptext1 = @text_dex + "+"+ @dex_dex.to_s + "点"
      @help_window.lvup_text(@text_dex_sc , @text_2 , temptext1)
    when 4  # 增加速度
      temptext1 = @text_agi + "+"+ @agi_agi.to_s + "点   " 
      @help_window.lvup_text(@text_agi_sc , @text_2 , temptext1)
    when 3  # 增加魔力
      temptext1 = @text_int + "+"+ @int_int.to_s + "点"
      @help_window.lvup_text(@text_int_sc , @text_2 , temptext1)
    when 5 # 保存设定
      @help_window.lvup_text(@text_save)
    when 6 # 点数重置
      @help_window.lvup_text(@text_reset)    
    end
    #=============================================================
    # 按下R与L换人的情况
    #=============================================================     
    if Input.trigger?(Input::R)
      # 演奏光标 SE
      $game_system.se_play($data_system.cursor_se)
      # 移至下一位角色
      @actor_index += 1
      @actor_index %= $game_party.actors.size
      # 切换到别的状态画面
      $scene = Scene_Lvup.new(@actor_index , @command_window.index)
      return
    end
    # 按下 L 键的情况下
    if Input.trigger?(Input::L)
      # 演奏光标 SE
      $game_system.se_play($data_system.cursor_se)
      # 移至上一位角色
      @actor_index += $game_party.actors.size - 1
      @actor_index %= $game_party.actors.size
      # 切换到别的状态画面
      $scene = Scene_Lvup.new(@actor_index , @command_window.index)
      return
    end
  end 
  #--------------------------------------------------------------------------
  # ● 选项明暗判断
  #--------------------------------------------------------------------------
  def s_disable
    # 判断剩余点数是否为0，如果为0，那么增加选项表示为暗色
    if $point == 0
      @command_window.disable_item(0)
      @command_window.disable_item(1)
      @command_window.disable_item(2)
      @command_window.disable_item(3)
      @command_window.disable_item(4)
    else
      @command_window.able_item(0)
      @command_window.able_item(1)     
      @command_window.able_item(2)
      @command_window.able_item(3)
      @command_window.able_item(4)
      @command_window.disable_item(3) if !$game_switches[19]
      @command_window.disable_item(4) if !$game_switches[27]
    end
  end
end

#==============================================================================
# 本脚本来自www.66RPG.com，使用和转载请保留此信息
#============================================================================== 