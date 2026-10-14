class Window_SetMag < Window_Base
  attr_reader   :index                    # 光标位置
  def initialize(data)
    super(0,80,576,400)
    self.contents = Bitmap.new(width - 32, height - 32)
    @index=0
    @data=data
    @length=data.size
    refresh
  end  
  #--------------------------------------------------------------------------
  # ● 自定义光标
  #--------------------------------------------------------------------------
  def update
    super
    if Input.repeat?(Input::RIGHT)
      @index=(@index+1)%@length
    end
    if Input.repeat?(Input::LEFT)
      @index=(@index+@length-1)%@length
    end
    if Input.repeat?(Input::UP)
      @index=(@index+@length-6)%@length
    end
    if Input.repeat?(Input::DOWN) 
       @index=(@index+6)%@length
    end
    x=24+@index%6*80
    y=16+@index/6*40
    self.cursor_rect.set(x,y,64,32)
  #  self.oy = [[@index[0] * 80-240,0].max,@maxlen*80].min
    # 更新国标矩形
   # if @index[0]==@maxlen+1
    #  self.cursor_rect.set((@index[1]-1)/2*130+94,@index[0]*80+40-self.oy, 110,32)
    #else
     # self.cursor_rect.set(@index[1]*64+64-2,@index[0]*80+16-self.oy-2, 48+4,64+4)
    #end
  end
  #--------------------------------------------------------------------------
  # ● 设置文本
  #     text  : 窗口显示的字符串
  #     align : 对齐方式 (0..左对齐、1..中间对齐、2..右对齐)
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
     self.contents.font.color = system_color
    for i in 0...@data.size
      x=16+i%6*80
      y=16+i/6*40
      s=@data[i][1].split("：")[0]
      self.contents.draw_text(x,y, 80, 32,s[7,s.size-7],1)
    end
    num_txt=["一","二","三","四","五","六"]
    self.contents.font.color = system_color
    if $game_variables[230]==0
      size=0
    else
      size=$game_variables[230].size
    end
    if size==0
      self.contents.draw_text(138,300,300,32,"当前没有进行任何附魔",1)
    end
    for i in 0...size
      x=16+i/3*256;y=270+i%3*32
      self.contents.font.color = system_color
      self.contents.draw_text(x,y,160,32,"第#{num_txt[i]}条附魔：")
      self.contents.font.color =normal_color
      self.contents.draw_text(x+128,y,160,32,$game_variables[230][i][1][0,13])
    end
  end
end
class Window_SetMagHelp < Window_Base
  def initialize
    super(0,0,576,80)
    self.contents = Bitmap.new(width - 32, height - 32)
  end  
  def set_text(text)
    self.contents.clear
    x=0;y=10
    self.contents.draw_text(x,y, 544,32,text,1)
  end
end
class Scene_SetMag
  def initialize(qid=0)
    @qid=qid
    @limit=[$game_variables[283],2].max
  end
  def main
    @data=[]
    @data.push([1,"魔纹-强力：基础攻击力提升2%"])
    @data.push([2,"魔纹-巨岩：基础防御力提升2%"])
    @data.push([3,"魔纹-贯通：攻击时无视敌人6点护甲"])
    @data.push([4,"魔纹-疾风：攻击速度提升250%"])
    @data.push([5,"魔纹-坚甲：额外提升自身6点护甲"])
    @data.push([6,"魔纹-回春：额外提升自身力量800%的生命回复"])
    @data.push([7,"魔纹-奥术：所有魔法伤害提升12.5%"])
    @data.push([8,"魔纹-循环：所有魔法消耗减少7.5%"])
    @data.push([9,"魔纹-能源：额外提升自身智力0.1%的法力回复"])
    @data.push([10,"魔纹-智慧：额外提升自身4%智力"])
    @data.push([11,"魔纹-灵动：额外提升自身4%闪避"])
    @data.push([12,"魔纹-财富：战斗后额外获得2%金钱"])
    
    @spcdata={}
    @spcdata[[3,1]]=[101,"魔纹-压碎打击：基础攻击力提升2.5%，攻击时无视敌人7点护甲，同时每次攻击附加目标当前护甲*30的物理伤害"]
    @spcdata[[5,2]]=[102,"魔纹-坚不可摧：基础防御力提升2.5%，额外提升自身7点护甲，每次受到普通攻击时都能格挡最多500点物理伤害"]
    @spcdata[[6,9]]=[103,"魔纹-生生不息：额外提升自身力量1000%的生命回复与智力0.15%的法力回复，同时每次战斗额外获得2点灵魂"]
    @spcdata[[7,10]]=[104,"魔纹-奥术贤者：所有魔法伤害提升12.5%，额外提升自身5%智力，并减少10%魔法消耗"]
    @spcdata[[4,11]]=[105,"魔纹-灵动迅捷：攻击速度提升300%，额外提升自身5%闪避，且战斗开始首回合必定闪避"]
    @spcdata[[7,10]]=[104,"魔纹-奥术贤者：所有魔法伤害提升12.5%，额外提升自身5%智力，并减少10%魔法消耗"]
    
    
    @spcdata[[3,3,3]]=[201,"魔纹-三重穿透强化：攻击时无视敌人20点护甲，并在战斗开始时减少所有敌人2%的防御力（对魔法免疫无效）"]
    @spcdata[[5,5,5]]=[202,"魔纹-三重磐石强化：提升自身20点护甲，并在战斗开始时减少所有敌人2%的攻击力（对魔法免疫无效）"]
    @spcdata[[12,12,12]]=[203,"魔纹-迈达斯的诱惑：战斗后额外获得10%金钱，但所受物理与魔法伤害增加30%"]
    @main_window=Window_SetMag.new(@data)
    @help_window=Window_SetMagHelp.new
    @item_window = Window_EquipHelp.new
    @item_window.set_text(@qid)
    @saveindex=nil
    Graphics.transition
    # 主循环
    loop do
      # 刷新游戏画面
      Graphics.update
      # 刷新输入信息
      Input.update
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
    @main_window.dispose
    @help_window.dispose
    @item_window.dispose
  end
  def update
    @main_window.update
    @item_window.update
    if Input.trigger?(Input::C)
      if $game_variables[230]==0
        $game_variables[230]=[]
      else
        if $game_variables[230].size>=@limit
          count=0
          for k in $game_variables[230]
            count+=1 if k[0]==12
          end
          if count>=3
            get_achievement(225) #要钱不要命
          end
          $scene = Scene_Map.new
          return
        end
      end
      $game_variables[230].push(@data[@main_window.index])
      make_mag
      $game_system.se_play($data_system.equip_se)
      @main_window.refresh
      @item_window.set_text("")
      @item_window.set_text(@qid)
    end
    if @saveindex !=@main_window.index
      @saveindex=@main_window.index
      @help_window.set_text(@data[@saveindex][1])
    end
    if Input.trigger?(Input::B)
      if $game_variables[230]==0
        $scene = Scene_Map.new
        return
      else
        Audio.se_play("Audio/SE/008-System08") 
        $game_variables[230].delete_at($game_variables[230].size-1)
        $game_variables[230]=0 if $game_variables[230].size==0
        make_mag
        @main_window.refresh
        @item_window.set_text("")
        @item_window.set_text(@qid)
      end
    end
    
  end
  def make_mag #实际附魔转换
    if $game_variables[230]==0
      $game_variables[237]=0
    else
      $game_variables[237]=[]
      kind=[]
      for i in 0...$game_variables[230].size
        kind.push($game_variables[230][i][0])
      end
      if $game_variables[230].size==1
        for i in 0...$game_variables[230].size
          $game_variables[237].push($game_variables[230][i])
        end
      end
      if $game_variables[230].size==2
        zh0=[kind[0],kind[1]]
        if @spcdata[zh0]!=nil
          $game_variables[237].push(@spcdata[zh0])
        else
          for i in 0...$game_variables[230].size
            $game_variables[237].push($game_variables[230][i])
          end
        end
      end
      if $game_variables[230].size==3
        zh0=[kind[0],kind[1],kind[2]]
        zh1=[kind[0],kind[1]]
        zh2=[kind[1],kind[2]]
        if @spcdata[zh0]!=nil
          $game_variables[237].push(@spcdata[zh0])
        elsif @spcdata[zh1]!=nil
          $game_variables[237].push(@spcdata[zh1])
          $game_variables[237].push($game_variables[230][2])
        elsif @spcdata[zh2]!=nil
          $game_variables[237].push($game_variables[230][0])
          $game_variables[237].push(@spcdata[zh2])
        else
          for i in 0...$game_variables[230].size
            $game_variables[237].push($game_variables[230][i])
          end
        end
      end
    end
   # p $game_variables[237]
  end
end


