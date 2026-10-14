#==============================================================================
# ■ Scene_Menu
#------------------------------------------------------------------------------
# 　处理菜单画面的类。
#==============================================================================

class Scene_Menu
  #--------------------------------------------------------------------------
  # ● 初始化对像
  #     menu_index : 命令光标的初期位置
  #--------------------------------------------------------------------------
  def initialize(menu_index = 0)
    @menu_index = menu_index
  end
  #--------------------------------------------------------------------------
  # ● 主处理
  #--------------------------------------------------------------------------
  def main
    $right_back_spr=Sprite.new
    if $game_switches[140]
      $right_back_spr.bitmap=RPG::Cache.picture("nevermore")
    else
      $right_back_spr.bitmap=RPG::Cache.picture("sven")
    end
    $right_back_spr.x=640
    $right_back_spr.z=100
    # 生成命令窗口
 #   s1 = $data_system.words.item
 #   s2 = $data_system.words.skill
 #   s3 = $data_system.words.equip
 #   s4 = "状态"
    s1 = "敌物资料"
    s2 = "游戏选项"
    s3 = "存档"
    s4 = "读档"
    if true#$record != nil and $record.mode == "录制"
      s5 = "退回主界面"
    else
      s5 = "重新开始"
    end
    s6 = "系统设置"
    @command_window = Window_Command.new(160, [s1, s2 ,s3 ,s4 ,s5,s6])#, s3, s4, s5, s6])
    @command_window.index = @menu_index
    # 同伴人数为 0 的情况下
#    if $game_party.actors.size == 0
      # 物品、特技、装备、状态无效化
 #     @command_window.disable_item(0)
#      @command_window.disable_item(1)
#      @command_window.disable_item(2)
#      @command_window.disable_item(3)
#    end
    # 禁止存档的情况下
    if $game_system.save_disabled
      # 存档无效
      @command_window.disable_item(2)
    end

    # 生成游戏时间窗口
    @playtime_window = Window_PlayTime.new
    @playtime_window.x = 0
    @playtime_window.y = 224

    # 生成步数窗口
    @steps_window = Window_Steps.new
    @steps_window.x = 0
    @steps_window.y = 320

    # 生成版本窗口
    @gold_window = Window_Version.new
    @gold_window.x = 0
    @gold_window.y = 416
     

    # 生成怪物状态窗口
    @enemy_window = Window_EnemyDate.new
    @enemy_window.x = 160
    @enemy_window.y = 0
    
    # 生成游戏选项窗口
    s=["物品使用","角色装备","角色技能","套装设定","情报信息","游戏说明"]
    s.insert(3,"角色天赋") if $game_switches[161]
    @command_window2 = Window_Command.new(160, s)
    @command_window2.index = @menu_index
    @command_window2.active=false
    @command_window2.visible=false
    @command_window2.x=140
    @command_window2.y=32
    @command_window2.z=@enemy_window.z+1000

    # 执行过渡
    Graphics.transition
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
    @command_window2.dispose
    @playtime_window.dispose
    @steps_window.dispose
    @gold_window.dispose
    @enemy_window.dispose
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面
  #--------------------------------------------------------------------------
  def update
    # 刷新窗口
    @command_window.update
    @command_window2.update
    @playtime_window.update
    @steps_window.update
    @gold_window.update
    @enemy_window.update
    # 命令窗口被激活的情况下: 调用 update_command
    if @command_window.active
      update_command
      return
    end
    if @command_window2.active
      update_command2
      return
    end
    if @command_window3 !=nil
      if @command_window3.active
        @command_window3.update
      end
      if @statu_window.active
        @statu_window.update
      end
      if !@statu_window.active && @command_window3.active && Input.trigger?(Input::B)
        $game_system.se_play($data_system.cancel_se)
        @statu_window.dispose
        @command_window3.dispose
        @command_window3=nil
        @command_window.active=true
        return 
      end
      if !@statu_window.active && !@command_window3.active
        @command_window3.active=true
        @command_window3.refresh
      end
      if !@statu_window.active
        if Input.trigger?(Input::C)
          command_game_set
        end
      end
      return
    end
    # 状态窗口被激活的情况下: 调用 update_status
    if @enemy_window.active
      update_status
      return
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面 (命令窗口被激活的情况下)
  #--------------------------------------------------------------------------
  def update_command
    # 按下 B 键的情况下
    if Input.trigger?(Input::B)
      # 演奏取消 SE
      $game_system.se_play($data_system.cancel_se)
      # 切换的地图画面
      $scene = Scene_Map.new
      return
    end
    # 按下 C 键的情况下
    if Input.trigger?(Input::C)
      # 同伴人数为 0、存档、游戏结束以外的场合
      if $game_party.actors.size == 0 and @command_window.index < 4
        # 演奏冻结 SE
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      # 命令窗口的光标位置分支
      case @command_window.index
      when 0
        if $floorenemies==[]#没有怪物数据不能进入详细怪物菜单
        # 演奏冻结 SE
          $game_system.se_play($data_system.buzzer_se)
          return
        end
        $game_system.se_play($data_system.decision_se)
        # 激活状态窗口
        @command_window.active = false
        @enemy_window.active = true
        @enemy_window.index = 0
        
      when 1  # 游戏选项
        @command_window2.active=true
        @command_window2.visible=true
        @command_window.active=false
        @command_window2.index=0
      
      when 2  # 存档
        if $game_system.save_disabled
          # 演奏冻结 SE
          $game_system.se_play($data_system.buzzer_se)
          return
        end
        # 演奏确定 SE
        $game_system.se_play($data_system.decision_se)
        # 切换到存档画面
        $scene = Scene_Save.new
     
      when 3  # 读档
        # 演奏确定 SE
        $game_system.se_play($data_system.decision_se)
        # 切换到存档画面
        $scene = Scene_Load2.new
      
      when 4  #重新开始
        if true#$record != nil and $record.mode == "录制"
          # 演奏确定 SE
          $game_system.se_play($data_system.decision_se)
          # 淡入淡出 BGM、BGS、ME
          Audio.bgm_fade(800)
          Audio.bgs_fade(800)
          Audio.me_fade(800)
          # 切换到标题画面
          $scene = Scene_Title.new
        else
                    
        # 游戏重新开始
        # 载入数据库
        $data_mapname       = load_data("Data/MapInfos.rxdata")
        $data_actors        = load_data("Data/Actors.rxdata")
        $data_classes       = load_data("Data/Classes.rxdata")
        $data_skills        = load_data("Data/Skills.rxdata")
        $data_items         = load_data("Data/Items.rxdata")
        $data_weapons       = load_data("Data/Weapons.rxdata")
        $data_armors        = load_data("Data/Armors.rxdata")
        $data_enemies       = load_data("Data/Enemies.rxdata")
        $data_troops        = load_data("Data/Troops.rxdata")
        $data_states        = load_data("Data/States.rxdata")
        $data_animations    = load_data("Data/Animations.rxdata")
        $data_tilesets      = load_data("Data/Tilesets.rxdata")
        $data_common_events = load_data("Data/CommonEvents.rxdata")
        $data_system        = load_data("Data/System.rxdata")
        # 生成系统对像
        $game_system = Game_System.new
      
        # 停止 BGM
        Audio.bgm_stop
        # 重置测量游戏时间用的画面计数器
        Graphics.frame_count = 0
        # 生成各种游戏对像
        $game_temp          = Game_Temp.new
        $game_system        = Game_System.new
        $game_switches      = Game_Switches.new
        $game_variables     = Game_Variables.new
        $game_self_switches = Game_SelfSwitches.new
        $game_screen        = Game_Screen.new
        $game_actors        = Game_Actors.new
        $game_party         = Game_Party.new
        $game_troop         = Game_Troop.new
        $game_map           = Game_Map.new
        $game_player        = Game_Player.new
        # 设置初期同伴位置
        $game_party.setup_starting_members
        # 设置初期位置的地图
        $game_map.setup($data_system.start_map_id)
        # 主角向初期位置移动
        $game_player.moveto($data_system.start_x, $data_system.start_y)
        # 刷新主角
        $game_player.refresh
        # 执行地图设置的 BGM 与 BGS 的自动切换
        $game_map.autoplay
        # 刷新地图 (执行并行事件)
        $game_map.update
        # 切换地图画面
        $movedevents={}
        $scene = Scene_Map.new
        end
         
      when 5  
        # 演奏确定 SE
        $game_system.se_play($data_system.decision_se)
        s=["行走速度","音乐音量","音效音量","光效等级","关闭渐变","小键盘ON","开门提示","版本检测","按键设置","保存退出"]
        @command_window3 = Window_Command.new(130,s)
        @command_window3.x=140
        @command_window3.y=120
        @statu_window = Window_ConfigSet.new
        @statu_window.active=false
        @statu_window.visible=false
        @command_window.active=false
        @command_window3.z=@enemy_window.z+1000
        @statu_window.z=@enemy_window.z+1000

      end
      return
    end
  end
  def update_command2
    # 按下 B 键的情况下
    if Input.trigger?(Input::B)
      # 演奏取消 SE
      $game_system.se_play($data_system.cancel_se)
      # 切换的地图画面
      @command_window2.active=false
      @command_window2.visible=false
      @command_window.active=true
      return
    end
    # 按下 C 键的情况下
    if Input.trigger?(Input::C)
      # 命令窗口的光标位置分支
      a=@command_window2.index
      a+=1 if !$game_switches[161] && a>=3
      case a
      when 0
        $game_system.se_play($data_system.decision_se)
        $scene = Scene_Item.new
      when 1
        $game_system.se_play($data_system.decision_se)
        $scene = Scene_Equip.new
      when 2
        $game_system.se_play($data_system.decision_se)
        $scene = Scene_EnemyView.new(1)
      when 3
        if $game_actors[1].level>=300
          Audio.se_play("Audio/SE/057-Wrong01") 
          return
        end
        $game_system.se_play($data_system.decision_se)
        $scene = Scene_Genius.new
      when 4
        $game_system.se_play($data_system.decision_se)
        $scene = Scene_Suit.new
      when 5
        $game_system.se_play($data_system.decision_se)
        $scene = Scene_Task.new
      when 6
        $game_system.se_play($data_system.decision_se)
        $scene = Scene_GameHelp.new
      end
      return
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面 (状态窗口被激活的情况下)
  #--------------------------------------------------------------------------
  def update_status
    # 按下 B 键的情况下
    if Input.trigger?(Input::B)
      # 演奏取消 SE
      $game_system.se_play($data_system.cancel_se)
      # 激活命令窗口
      @command_window.active = true
      @enemy_window.active = false
      @enemy_window.index = -1
      return
    end
    # 按下 C 键的情况下
    if Input.trigger?(Input::C)
      if $floorenemies!=[] and $game_party.item_number(4)>0
        $game_variables[13]=@enemy_window.index
        $scene=Scene_EnemyView.new
      end
      return
    end
  end
  #--------------------------------------------------------------------------
  # ● 详细设置
  #--------------------------------------------------------------------------
  def command_game_set
    @command_window3.active=false
    @statu_window.active=true
    @statu_window.y=120+@command_window3.index*34
    case @command_window3.index
    when 0
      @statu_window.start($game_config.data("speed"),2,0,10,@command_window3.index)
    when 1
      @statu_window.start($game_config.data("bgm"),3,0,100,@command_window3.index)
    when 2
      @statu_window.start($game_config.data("se"),3,0,100,@command_window3.index)
    when 3
      @statu_window.start($game_config.data("effect"),1,0,1,@command_window3.index)
    when 4
      @statu_window.start($game_config.data("jianbian"),1,0,1,@command_window3.index)
    when 5
      @statu_window.start($game_config.data("numlock"),1,0,1,@command_window3.index)
    when 6
      @statu_window.start($game_config.data("doorcheck"),1,0,1,@command_window3.index)
    when 7
      @statu_window.start($game_config.data("versionCheck"),1,0,1,@command_window3.index)
    when 8
      @statu_window.start($game_config.data("keyboard"),0,0,0,@command_window3.index)
    when 9
      @statu_window.dispose
      @command_window3.dispose
      @command_window3=nil
      @command_window.active=true
      return 
    end
    @statu_window.visible=true
  end
end
