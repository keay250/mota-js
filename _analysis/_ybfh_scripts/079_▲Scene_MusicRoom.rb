module RPG
  module Cache
    def self.musicover(filename)
      self.load_bitmap("Info/Music/", filename)
    end
  end
end
$music_list=[
    "魂之挽歌","寂静之森","厄泽城","姆伊森运河","突发危急","莱尼克之墓",
    "泰坦狩猎","虚幻之域","强者威慑","甲板死斗","坠入深渊","新的征程",
    "普利斯特王都","杜鲁德大草原","赏金首之战","流浪者之歌",
    "砂锁之地","雷霆高原","Wanted！","斯多姆祖境","转为黑暗的神殿",
    "恐怖利刃","无法忘记的人","归亡死域","弧光城","郊外平原","火焰长河",
    "暗影庇护所","异界杀阵","爱丽丝的城堡","悲哀的献祭","寒夜冰川",
    "傲洛斯神殿","苍白之巢","时之回廊","神威","西北荒原",
    "闪烁沙漠","古老的沙","风之部落","夜魇要塞","上路战场","下路战场",
    "生命之泉","妖精的小夜曲","绝望之塔","不朽山谷","伊人之泪",
    "无可奈何花落去","战争之火","绝对力量","领主王座","短暂的日常",
    "名为汪迪的勇者","魔巢的强者","通往上层的道路","天壤之巅",
    "魔王降临","鵐目山脉","返角要塞","星河旅者",
    "多兰大陆","遗忘的圣地","方界圣所","魅影杀劫",
    "真理之要塞下层","真理之要塞中层","少年王的秘闻",
    "真理之要塞上层","擎天之柱","诞生的觉悟","仙古的刻痕",
    "赤炼天盘下层","赤炼天盘上层","记忆伤痕",
    "远古殿堂","紫黑色紫炎之日","命运的相逢"
    ]
$music_list2=[
    "标题画面","寂静之森","厄泽城","姆伊森运河","BOSS战","莱尼克之墓",
    "莱尼克之墓BOSS","神秘之地","非生死BOSS战","她名为维巴罗莎","厄泽城事变","章节过场",
    "普利斯特王都","极速行驶的草原列车","赏金首1","流浪者之歌",
    "姆伊森核心","雷霆高原","赏金首2","玛荷托拉祖境","玛荷托拉祖境下层",
    "恐怖利刃","无法忘记的人","归亡死域","弧光城","郊外平原","火焰长河",
    "暗影庇护所","暗影庇护所BOSS","爱丽丝的城堡","爱丽丝的城堡BOSS","寒夜冰川",
    "傲洛斯神殿","苍白之巢","时之回廊1","神威","西北荒原",
    "闪烁沙漠","沙王","风之部落","位面战场","上路战场","下路战场",
    "妖精之泉","妖精之泉夜","绝望之塔","不朽山谷","不朽山谷终战1",
    "不朽山谷终战2","战争之火","传奇BOSS","领主王座","03. 50年の散歩",
    "天壤之塔下层","天壤之塔BOSS","天壤之塔上层","天壤之塔最上层",
    "魔王降临","异化世界-鵐目山脉","异化世界-返角要塞","崎岖星域",
    "多兰大陆","遗忘的方界圣地","方界圣所","方界圣所BOSS",
    "真理之要塞下层","真理之要塞中层","少年王的秘闻",
    "真理之要塞上层","超凡BOSS","诞生的觉悟","似是不太久远之前的事",
    "赤炼天盘下层","赤炼天盘上层","记忆伤痕",
    "远古殿堂","远古殿堂BOSS战","命运的相逢"
    
    ]
class Scene_Title #成就
  def music_room
    @music_list=$music_list.clone
    for i in 0...$music_list2.size
      if $music_unlock[i]==nil
        @music_list[i]="？？？"
      end
    end
    @play_check=false
    @command_music = Window_Command.new(180, @music_list, 1, 1)
    @command_music.back_opacity = 0
    @command_music.opacity = 0
    @command_music.contents_opacity = 0
    @command_music.x = 70
    @command_music.y = 73
    @command_music.active=true
    @command_music.height=352
    @save_musicindex=@some_index[1]
    @command_music.oy=@some_index[2]
    @command_music.index=@some_index[1]
    @music_title=Sprite.new
    @music_title.bitmap=RPG::Cache.title("title")
    @music_title.src_rect=Rect.new(329,276+3*73,222,38)
    @music_title.ox=111
    @music_title.oy=19
    @music_title.x=400
    @music_title.y=40
    @music_title.opacity=0
    
    @music_cover=Sprite.new
    @music_cover.bitmap=RPG::Cache.musicover(@music_list[@command_music.index])
    @music_cover.x=370
    @music_cover.y=80
    @music_cover.opacity=0
    
    @musictext_window = Window_MusicText.new
    @musictext_window.back_opacity = 0
    @musictext_window.opacity = 0
    @musictext_window.contents_opacity = 0
    @musictext_window.set_text(@music_list[@command_music.index])
    
    @index_text=Sprite.new
    @index_text.bitmap=Bitmap.new(180,40)
    @index_text.x=@command_music.x
    @index_text.y=418
    @index_text.opacity=0
    draw_index_text
    for i in 0...15
      normal_update
      @index_text.opacity+=17
      @music_cover.opacity+=17
      @musictext_window.contents_opacity+=17
      @music_title.opacity+=17
      @command_music.opacity+=17
      @command_music.contents_opacity+=17
    end
    
    loop do
      normal_update
      if Input.trigger?(Input::B)
        @command_music.dispose
        @musictext_window.dispose
        @music_title.dispose
        @music_cover.dispose
        @index_text.dispose
        for i in 0...3
          @choice[i].visible=true
        end
        for i in 0...15
          normal_update
          @sprop1-=17
          @sprop2-=17
        end
        @command_window1.active=true
        Audio.bgm_play_nolock("Audio/BGM/标题画面")
        return
      end
      @command_music.update
      if @save_musicindex !=  @command_music.index
        @play_check=false
        @save_musicindex=@command_music.index
        @music_cover.bitmap=RPG::Cache.musicover(@music_list[@command_music.index])
        @musictext_window.set_text(@music_list[@command_music.index])
        draw_index_text
      end
      if Input.trigger?(Input::LEFT)
        if @command_music.index==0
          @command_music.index=@music_list.size-1
        else
          @command_music.oy-=320
          @command_music.index-=10
          @command_music.oy=[0,@command_music.oy].max
          if @command_music.index<0
            @command_music.index=0
          end
        end
      end
      if Input.trigger?(Input::RIGHT)
        if @command_music.index==@music_list.size-1
          @command_music.index=0
        else
          @command_music.oy+=320
          @command_music.index+=10
          #@command_music.oy=[@command_music.oy,(@music_list.size-10)*32].min
          if @command_music.index>=@music_list.size
            @command_music.index=@music_list.size-1
          end
        end
      end
      if Input.trigger?(Input::C)
        if @music_list[@command_music.index]=="？？？"
          if !@play_check
            @play_check=true
            @musictext_window.set_text("未知曲目确认")
          else
            play_music
          end
        else
          play_music
        end
      end
    end
  end
  def play_music
    @some_index[1]=@command_music.index
    @some_index[2]=@command_music.oy
    $game_config.wdata("someindex",[@some_index[0],@command_music.index,@command_music.oy])
    $game_config.write_config!()
    Audio.bgm_play_nolock("Audio/BGM/"+$music_list2[@command_music.index])
  end
  def draw_index_text
    @index_text.bitmap.clear
    index=(@command_music.index+1).to_s+"/"+$music_list2.size.to_s
    @index_text.bitmap.draw_text(0,0,180,40,index,1)
  end
end