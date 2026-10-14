#==============================================================================
# ■ Scene_Title
#------------------------------------------------------------------------------
# 　处理标题画面的类。
#==============================================================================

class Scene_Title
  #--------------------------------------------------------------------------
  # ● 住处理
  #--------------------------------------------------------------------------
  def main
    # 战斗测试的情况下
    if $BTEST
      battle_test
      return
    end
    
    if $right_back_spr !=nil
      $right_back_spr.dispose
      $right_back_spr=nil
    end
    $mapdamage_obj=nil
    $sandstorm=nil
    # 载入数据库
    $data_mapname       = load_data("Data/MapInfos.rxdata")
    $data_actors        = load_data("Data/Actors.rxdata")
    $data_classes       = load_data("Data/Classes.rxdata")
    $data_skills        = load_data("Data/Skills.rxdata")
    $data_items         = load_data("Data/Items.rxdata")
    $data_weapons       = load_data("Data/Weapons.rxdata")
    $data_armors        = load_data("Data/Armors.rxdata")
    $data_enemies       = load_data("Data/Enemies.rxdata")
    Monster.Load
    $data_troops        = load_data("Data/Troops.rxdata")
    $data_states        = load_data("Data/States.rxdata")
    $data_animations    = load_data("Data/Animations.rxdata")
    $data_tilesets      = load_data("Data/Tilesets.rxdata")
    $data_common_events = load_data("Data/CommonEvents.rxdata")
    $data_system        = load_data("Data/System.rxdata")
    # 生成系统对像
    $game_system = Game_System.new
    # 生成标题图形
=begin
      c=[]
      b=[]
  for i in 1...150
    c[i]=0
    b[i]=i
  end
  for i in $data_enemies
    next if i==nil
    for j in 1...150
      c[j]+=1 if i.element_ranks[j]==1
    end
  end
  for i in 1...150
    for j in 1...150
      if c[i]>c[j]
      t=c[i]
      c[i]=c[j]
      c[j]=t
      t=b[i]
      b[i]=b[j]
      b[j]=t
      end
    end
  end
  s=""
  for i in 1..10
    s+=$data_skills[b[i]].name.split(":")[0]+":"+c[i].to_s+"种怪物 "
  end
  p s
=end
  
    viewport1 = Viewport.new(160,0,640,480)
    viewport2 = Viewport.new(0,0,160,480)
    @back1 = Plane.new(viewport1)
    @back1.bitmap=RPG::Cache.title("StarlitSky")
    @back2 = Plane.new(viewport2)
    @back2.bitmap=RPG::Cache.title("StarlitSky")
    @back1.ox=160
    @back1.opacity=@back2.opacity=155
    @sprite = Sprite.new
    @bitmap=RPG::Cache.title("title")
    @sprite.bitmap=Bitmap.new(800,480)
    @sprite.bitmap.blt(200,13,@bitmap,Rect.new(0,0,397,167))
    @sprite.bitmap.blt(245,180,@bitmap,Rect.new(0,167,308,313))
    @sprite.blend_type=1
    # 生成命令窗口
    s1 = "新游戏"
    s2 = "继续"
    s3 = "退出"
    @command_window1 = Window_Command.new(192, [s1, s2, s3])
    @command_window1.back_opacity = 160
    @command_window1.x = 0#400 - @command_window.width / 2
    @command_window1.y = -200#288
    s1 = "初心试炼"
    s2 = "冒险篇章"
    s3 = "传奇史诗"
    @command_window2 = Window_Command.new(192, [s1, s2, s3])
    @command_window2.back_opacity = 160
    @command_window2.x = 0
    @command_window2.y = -200
    @command_window2.active=false
    @list=[
      "第一章：厄泽往事","第二章：王都崛起","第三章：地狱涅槃",
      "第四章：苍白之影","第五章：魔王降临","第六章：位面战场",
      "第七章：传奇岁月","第八章：真理要塞","第九章：圣域之路",
      "第十章：仙道之遗","第十一章：主宰博弈","第十二章：神灵陨落",
      "第十三章：浩瀚虚空","第十四章：癫狂之月","第十五章：天穹守望",
      "终结之章：造物永恒"
    ]
    @command_window3 = Window_Command.new(450, @list, 2)
    @command_window3.back_opacity = 0
    @command_window3.opacity = 0
    @command_window3.contents_opacity = 0
    @command_window3.x = 400 - @command_window3.width / 2
    @command_window3.y = 80
    @command_window3.active=false
    # 判定继续的有效性
    # 存档文件一个也不存在的时候也调查
    # 有効为 @continue_enabled 为 true、無効为 false
    @continue_enabled = false
    for i in 0..2000
      if FileTest.exist?("Save/MotaSave#{i+1}.rxdata")
         @continue_enabled = true
      end
    end
    @some_index=$game_config.data("someindex")
    @second_index=@some_index[0]
    @choice=[]
    for i in 0...3
      a=Sprite.new
      a.bitmap=RPG::Cache.title("title")
      case i
      when 0
        a.src_rect=Rect.new(329,276,222,38)
      when 1
        set_chose1_rect(a)
      when 2
        a.src_rect=Rect.new(329,276+1*73,222,38)
      end
      a.ox=111
      a.oy=19
      a.x=400
      a.y=276+i*58
      a.blend_type=2
      @choice.push(a)
    end
    if @continue_enabled
      @choice[2].blend_type=0
    else
      @choice[0].blend_type=0
    end
    # 继续为有效的情况下、光标停止在继续上
    # 无效的情况下、继续的文字显示为灰色
    if @continue_enabled
      @command_window1.index = 2
    else
      @command_window1.disable_item(2)
    end
    #第二行选项箭头
    @arrow=[]
    for i in 0...2
      @arrow[i]=Sprite.new
      @arrow[i].bitmap=RPG::Cache.title("title")
      @arrow[i].src_rect=Rect.new(312+i*20,172,16,28)
      @arrow[i].x=260+i*265
      @arrow[i].y=320
      @arrow[i].z=1001
      @arrow[i].visible=false
    end
    # 演奏标题 BGM
    $game_system.bgm_play($data_system.title_bgm)
    # 停止演奏 ME、BGS
    Audio.me_stop
    Audio.bgs_stop
    # 执行过渡
    #Graphics.transition(30, "Graphics/Transitions/GrassTransition")
    Graphics.transition
    # 主循环
    @time=0
    @sprop1=0
    @sprop2=0
    loop do
      normal_update
      update
      # 如果画面被切换就中断循环
      if $scene != self
        break
      end
    end
    # 装备过渡
    Graphics.freeze
    # 释放命令窗口
    @command_window1.dispose
    @command_window2.dispose
    @command_window3.dispose
    # 释放标题图形
    @sprite.bitmap.dispose
    @sprite.dispose
    @back1.dispose
    @back2.dispose
    for i in 0...3
      @choice[i].dispose
    end
    for i in 0...2
      @arrow[i].dispose
    end
  end
  def normal_update
    if @command_window1.active
      for i in 0...3
        if i==@command_window1.index
          @choice[i].blend_type=0
          @choice[i].zoom_x+=0.01 if @choice[i].zoom_x<1.12
          @choice[i].zoom_y=@choice[i].zoom_x
        else
          @choice[i].blend_type=2
          @choice[i].zoom_x-=0.01 if @choice[i].zoom_x>1.0
          @choice[i].zoom_y=@choice[i].zoom_x
        end
        @choice[i].opacity=255-@sprop1
      end
    end
    if @command_window2.active
      for i in 0...3
        if i==@command_window2.index
          @choice[i].blend_type=0
          @choice[i].zoom_x+=0.02 if @choice[i].zoom_x<0.9
          @choice[i].zoom_y=@choice[i].zoom_x
        else
          @choice[i].blend_type=2
          @choice[i].zoom_x-=0.02 if @choice[i].zoom_x>0.7
          @choice[i].zoom_y=@choice[i].zoom_x
        end
        @choice[i].opacity=255-@sprop1
      end
    end
    for i in 0...3
      @choice[i].opacity=255-@sprop1
    end
    @back1.oy+=2
    @back2.oy+=2
    @time+=1
    a=255-((@time+140)%280-140).abs/3-rand(12)-@sprop2
    a=0 if a<0
    @sprite.opacity=a
    Graphics.update
    # 刷新输入信息
    Input.update
  end
  def set_chose1_rect(spr)
    spr.src_rect=Rect.new(329,276+(2+@second_index)*73,222,38)
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面
  #--------------------------------------------------------------------------
  def update
    # 刷新命令窗口
    @command_window1.update
    @command_window2.update
    @command_window3.update
    # 按下 C 键的情况下
    if @command_window1.active
      if Input.trigger?(Input::LEFT)
        @second_index-=1
        @second_index=1 if @second_index<0
        Graphics.freeze
        $game_config.wdata("someindex",[@second_index,@some_index[1],@some_index[2]])
        $game_config.write_config!()
        set_chose1_rect(@choice[1])
        Graphics.transition
      end
      if Input.trigger?(Input::RIGHT)
        @second_index+=1
        @second_index=0 if @second_index>1
        Graphics.freeze
        $game_config.wdata("someindex",[@second_index,@some_index[1],@some_index[2]])
        $game_config.write_config!()
        set_chose1_rect(@choice[1])
        Graphics.transition
      end
      arrow_time=(Graphics.frame_count%48-24).abs/8
      if @command_window1.index==1
        @arrow[0].visible=true
        @arrow[0].ox=-arrow_time+1
        @arrow[1].visible=true
        @arrow[1].ox=arrow_time-2
      else
        @arrow[0].visible=false
        @arrow[1].visible=false
      end
      if Input.trigger?(Input::C)
        case @command_window1.index
        when 0  # 新游戏
          @command_window1.active=false
          for i in 0...15
            normal_update
            @sprop1+=17
          end
          for i in 0...3
            @choice[i].zoom_x=0.7
            @choice[i].zoom_y=@choice[i].zoom_x
            @choice[i].src_rect=Rect.new(418,18+i*73,206,68)
            @choice[i].blend_type=2
            @choice[i].oy=32
          end
          @choice[@command_window2.index].blend_type=0
          for i in 0...15
            normal_update
            @sprop1-=17
          end
          @command_window2.active=true
        when 1  # 特殊选项
          @command_window1.active=false
          @arrow[0].visible=false
          @arrow[1].visible=false
          for i in 0...15
            normal_update
            @sprop1+=17
            @sprop2+=17
          end
          for i in 0...3
            @choice[i].visible=false
          end
          case @second_index
          when 0 #成就
            merit
          when 1 #音乐室
            music_room
          end
        when 2  # 继续
          command_continue
        end
      end
    end
    if @command_window2.active
      if Kboard.trigger?($R_Key_T) #作弊模式
        $game_system.se_play($data_system.decision_se)
        # 停止 BGM
        Audio.bgm_fade(600)
        @command_window3.active=false
        for j in 0...17
          @command_window3.contents_opacity-=15
          @sprop1+=15
          normal_update
        end
        command_new_game
        return
      end
      if Input.trigger?(Input::C)
        @command_window2.active=false
        for j in 0...15
          normal_update
          for i in 0...3
            if i != @command_window2.index
              @choice[i].opacity-=17
            end
          end  
          @sprop2+=17
        end
        for i in 0...3
          if i != @command_window2.index
            @choice[i].visible=false
          end
        end
        while @choice[@command_window2.index].y<420
          normal_update
          @choice[@command_window2.index].y+=10
        end
        str=["Easy","Normal","Hard"]
        list=@list.clone
        for i in 1...list.size
          if !FileTest.exist?("Save/AutoSave#{i}-#{str[@command_window2.index]}.rxdata")
            list[i]="第 ？章：等待开启"
          end
        end
        @command_window3.set_commands(list)
        @command_window3.refresh
        for i in 1...list.size
          if list[i][4,3]=="？"
            @command_window3.disable_item(i)
          end
        end
        for j in 0...15
          @command_window3.contents_opacity+=17
          normal_update
        end
        @command_window3.active=true
      end
      if Input.trigger?(Input::B)
        @command_window2.active=false
        for i in 0...15
          normal_update
          @sprop1+=17
        end
        for i in 0...3
          @choice[i].zoom_x=1.0
          @choice[i].zoom_y=@choice[i].zoom_x
          case i
          when 0
            @choice[i].src_rect=Rect.new(329,276,222,38)
          when 1
            @choice[i].src_rect=Rect.new(329,276+2*73,222,38)
          when 2
            @choice[i].src_rect=Rect.new(329,276+1*73,222,38)
          end
          @choice[i].blend_type=2
          @choice[i].oy=19
        end
        @choice[@command_window1.index].blend_type=0
        for i in 0...15
          normal_update
          @sprop1-=17
        end
        @command_window1.active=true
      end
    end
    if @command_window3.active
      if Input.trigger?(Input::C)
        a=@command_window3.index/2+@command_window3.index%2*8
        str=["Easy","Normal","Hard"]
        filename="Save/AutoSave#{a}-#{str[@command_window2.index]}.rxdata"
        if @command_window3.index>0 && !FileTest.exist?(filename)
          $game_system.se_play($data_system.buzzer_se)
          return
        end
        $game_system.se_play($data_system.decision_se)
        # 停止 BGM
        Audio.bgm_fade(600)
        @command_window3.active=false
        for j in 0...17
          @command_window3.contents_opacity-=15
          @sprop1+=15
          normal_update
        end
        if @command_window3.index==0
          command_new_game
          return
        end
        $game_temp = Game_Temp.new
        # 重置测量游戏时间用的画面计数器
        Graphics.frame_count = 0
        file = Zlib::GzipReader.open(filename)
        $desc=Marshal.load(file)  
        # 读取描绘存档文件用的角色数据
        characters = Marshal.load(file)
        # 读取测量游戏时间用画面计数
        Graphics.frame_count = Marshal.load(file)
        # 读取校验
        crcs = Marshal.load(file)
        # 读取文档字串
        strings = Marshal.load(file)
        # 校验检测
        key = 20120430#SAVE_KEY
        strings.each_index do |i|
          key = Zlib.crc32(strings[i],key)
          unless crcs[i] == key
          file.close
          raise "file check error"
          return
          end
        end
        # 读取各种游戏对像
        $game_system = Marshal.load(Zlib::Inflate.inflate(strings[0]))
        $game_variables = Marshal.load(Zlib::Inflate.inflate(strings[1]))
        $game_self_switches = Marshal.load(Zlib::Inflate.inflate(strings[2]))
        $game_switches = Marshal.load(Zlib::Inflate.inflate(strings[3]))
        $game_troop = Marshal.load(Zlib::Inflate.inflate(strings[4]))
        $game_map = Marshal.load(Zlib::Inflate.inflate(strings[5]))
        $game_player = Marshal.load(Zlib::Inflate.inflate(strings[6]))
        $game_screen = Marshal.load(Zlib::Inflate.inflate(strings[7]))
        $game_actors = Marshal.load(Zlib::Inflate.inflate(strings[8]))
        $game_party = Marshal.load(Zlib::Inflate.inflate(strings[9]))
        $floorenemies = Marshal.load(Zlib::Inflate.inflate(strings[10]))
        $fledam = Marshal.load(Zlib::Inflate.inflate(strings[11]))
        $movedevents = Marshal.load(Zlib::Inflate.inflate(strings[12]))
        if strings.size>13
          $new_map = Marshal.load(Zlib::Inflate.inflate(strings[13]))
        else
          $new_map=[]
        end
        file.close
        if $game_system.magic_number != $data_system.magic_number
          # 重新装载地图
          $game_map.setup($game_map.map_id)
          $game_player.center($game_player.x, $game_player.y)
        end
        # 刷新同伴成员
        $game_party.refresh
        # 还原 BGM、BGS
        $game_system.bgm_play($game_system.playing_bgm)
        $game_system.bgs_play($game_system.playing_bgs)
        # 刷新地图 (执行并行事件)
        $game_map.update
        # 切换到地图画面
        $scene = Scene_Map.new
      end
      if Input.trigger?(Input::B)
        @command_window3.active=false
        for j in 0...15
          @command_window3.contents_opacity-=17
          normal_update
        end
        while @choice[@command_window2.index].y>276+@command_window2.index*58
          normal_update
          @choice[@command_window2.index].y-=10
        end
        for i in 0...3
          if i != @command_window2.index
            @choice[i].visible=true
          end
        end
        for j in 0...15
          normal_update
          for i in 0...3
            if i != @command_window2.index
              @choice[i].opacity+=17
            end
          end
          @sprop2-=17
        end
        @command_window2.active=true
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 命令 : 新游戏
  #--------------------------------------------------------------------------
  def command_new_game
    # 重置测量游戏时间用的画面计数器
    Graphics.frame_count = 0
    $movedevents={}
    $new_map=[]
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
    $game_variables[177]=2-@command_window2.index
    if @command_window2.active
      $game_switches[65]=true
      $game_variables[177]=2
    end
    $juewang=0
    $jinmo=[1,0]
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
    $scene = Scene_Map.new
  end
  #--------------------------------------------------------------------------
  # ● 命令 : 继续
  #--------------------------------------------------------------------------
  def command_continue
    # 继续无效的情况下
    unless @continue_enabled
      # 演奏无效 SE
      $game_system.se_play($data_system.buzzer_se)
      return
    end
    # 演奏确定 SE
    $game_system.se_play($data_system.decision_se)
    # 切换到读档画面
    $scene = Scene_Load.new
  end
  #--------------------------------------------------------------------------
  # ● 命令 : 退出
  #--------------------------------------------------------------------------
  def command_shutdown
    # 演奏确定 SE
    $game_system.se_play($data_system.decision_se)
    # BGM、BGS、ME 的淡入淡出
    Audio.bgm_fade(800)
    Audio.bgs_fade(800)
    Audio.me_fade(800)
    # 退出
    $scene = nil
  end
  #--------------------------------------------------------------------------
  # ● 战斗测试
  #--------------------------------------------------------------------------
  def battle_test
    # 载入数据库 (战斗测试用)
    $data_actors        = load_data("Data/BT_Actors.rxdata")
    $data_classes       = load_data("Data/BT_Classes.rxdata")
    $data_skills        = load_data("Data/BT_Skills.rxdata")
    $data_items         = load_data("Data/BT_Items.rxdata")
    $data_weapons       = load_data("Data/BT_Weapons.rxdata")
    $data_armors        = load_data("Data/BT_Armors.rxdata")
    $data_enemies       = load_data("Data/BT_Enemies.rxdata")
    $data_troops        = load_data("Data/BT_Troops.rxdata")
    $data_states        = load_data("Data/BT_States.rxdata")
    $data_animations    = load_data("Data/BT_Animations.rxdata")
    $data_tilesets      = load_data("Data/BT_Tilesets.rxdata")
    $data_common_events = load_data("Data/BT_CommonEvents.rxdata")
    $data_system        = load_data("Data/BT_System.rxdata")
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
    # 设置战斗测试用同伴
    $game_party.setup_battle_test_members
    # 设置队伍 ID、可以逃走标志、战斗背景
    $game_temp.battle_troop_id = $data_system.test_troop_id
    $game_temp.battle_can_escape = true
    $game_map.battleback_name = $data_system.battleback_name
    # 演奏战斗开始 BGM
    $game_system.se_play($data_system.battle_start_se)
    # 演奏战斗 BGM
    $game_system.bgm_play($game_system.battle_bgm)
    # 切换到战斗画面
    $scene = Scene_Battle.new
  end
end
