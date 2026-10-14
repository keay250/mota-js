#==============================================================================
# ■ Config
#------------------------------------------------------------------------------
# 　灵感来源于TimPKS
#==============================================================================


class Config
  #--------------------------------------------------------------------------
  # ● 初始化对像
  #     filename : 文件名
  #     gen      : 创造
  #--------------------------------------------------------------------------
  def initialize(filename,check)
    if check
      #创造配置档
      file = Zlib::GzipWriter.open(filename,9)
      Marshal.dump({"bgm"=>100,"se"=>100,"effect"=>1,"jianbian"=>0,"numlock"=>0,
      "speed"=>10,"doorcheck"=>0,"versionCheck"=>1,"someindex"=>[0,0,0],
      "keyboard"=>[0x51,0x41,0x57,0x44,0x53,0x45,0x4E,0x11,0x08]},file)
      file.close
    end
    file = Zlib::GzipReader.open(filename)
    read_config(file)
    file.close
    @fn=filename
  end
  #--------------------------------------------------------------------------
  # ● 读配置档
  #--------------------------------------------------------------------------
  def read_config(file)
    @table=Marshal.load(file)
  end
  #--------------------------------------------------------------------------
  # ● 读配置档2
  #--------------------------------------------------------------------------
  def read_config!()
    file = Zlib::GzipReader.open(@fn)
    @table=Marshal.load(file)
    file.close
  end
  #--------------------------------------------------------------------------
  # ● 写配置档
  #--------------------------------------------------------------------------
  def write_config(file)
    Marshal.dump(@table,file)
  end
  #--------------------------------------------------------------------------
  # ● 写配置档2
  #--------------------------------------------------------------------------
  def write_config!()
    file = Zlib::GzipWriter.open(@fn,9)
    Marshal.dump(@table,file)
    file.close
    read_config!()
  end
  #--------------------------------------------------------------------------
  # ● 读/写配置
  #-------------------------------------------------------------------------- 
  def data(id)
    return @table[id]
  end
  def wdata(id,val)
    @table[id]=val
  end
end

if $newaudio==nil
  $newaudio=Audio.clone
  def Audio.bgm_play(filename,volume=100,pitch=100)
    volume=(volume*$game_config.data("bgm")/100.0).to_i
    $last_bgm=[filename,volume,pitch]
    name=filename.split("/")
    name=name[name.size-1]
    for i in 0...$music_list2.size
      if $music_list2[i] == name && $music_unlock[i] == nil
        $music_unlock[i]=true
        save_data($music_unlock, "Save/MusicUnlock.rxdata")
      end
    end
    return $newaudio.bgm_play(filename,volume,pitch)
  end
  def Audio.bgm_play_nolock(filename,volume=100,pitch=100)
    volume=(volume*$game_config.data("bgm")/100.0).to_i
    return $newaudio.bgm_play(filename,volume,pitch)
  end 
  def Audio.bgs_play(filename,volume=100,pitch=100)
    volume=(volume*$game_config.data("se")/100.0).to_i
    return $newaudio.bgs_play(filename,volume,pitch)
  end
  
  def Audio.me_play(filename,volume=100,pitch=100)
    volume=(volume*$game_config.data("se")/100.0).to_i
    return $newaudio.me_play(filename,volume,pitch)
  end
  
  def Audio.se_play(filename,volume=100,pitch=100)
    volume=(volume*$game_config.data("se")/100.0).to_i
    return $newaudio.se_play(filename,volume,pitch)
  end
  $game_config=Config.new("Config.dat",!FileTest.exist?("Config.dat"))
  unless FileTest.exist?("Save/Merit.rxdata")
    c = []
    for i in 0..300
      c.push([false,0])
    end
    c.push([0,0,0,0])
    save_data(c, "Save/Merit.rxdata")
  end
  $merit=load_data("Save/Merit.rxdata")
  unless FileTest.exist?("Save/MusicUnlock.rxdata")
    c = [true]
    save_data(c, "Save/MusicUnlock.rxdata")
  end
  $music_unlock=load_data("Save/MusicUnlock.rxdata")
  
 end 
  class Integer
    def to_b
      !self.zero?
    end
  end
  
#==============================================================================
# ■ Scene_Config
#------------------------------------------------------------------------------
# 　游戏设置画面
#==============================================================================
class Window_ConfigSet < Window_Base
  def initialize
    super(290,200,80,54)
  #  contents.font.size=17
    @number = 0
    @digits_max = 1
    @max=0
    @min=0
    @index = 0
    @kind=0
    @spuse=0
    @str=["打开装备栏","查看套装","套装切换","查看技能","技能组合","装备使用","查看任务","跳过对话","撤销误开门"]
    self.active=false
  end
  def start(x,num,min,max,kind)
    @last_index=0
    @digits_max = num
    @kind=kind
    @number = x
    @max=max
    @min=min
    @index = 0
    @spuse = $game_config.data("fullscreen")
    if @digits_max==0
      self.y=120
      self.width=272
      self.height=320
    else
      self.width=32+@digits_max*18
      self.height=54
    end
    self.contents = Bitmap.new(width - 32, height - 32)
    refresh
    self.active=true
  end
  #--------------------------------------------------------------------------
  # ● 光标向右移动
  #     wrap : 允许循环
  #--------------------------------------------------------------------------
  def cursor_right(wrap)
    if @index < @digits_max - 1 || wrap
      @index = (@index + 1) % @digits_max
    end
  end
  #--------------------------------------------------------------------------
  # ● 光标向左移动
  #     wrap : 允许循环
  #--------------------------------------------------------------------------
  def cursor_left(wrap)
    if @index > 0 || wrap
      @index = (@index + @digits_max - 1) % @digits_max
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新画面
  #--------------------------------------------------------------------------
  def update
    super
    if @digits_max==0
      @last_index = @index
      if Input.repeat?(Input::UP)
        if @index==0
          @index=@str.size-1
        else
          @index-=1
        end
      end
      if Input.repeat?(Input::DOWN)
        if @index==@str.size-1
          @index=0
        else
          @index+=1
        end
      end
      $game_system.se_play($data_system.cursor_se) if @index != @last_index
      if Input.trigger?(Input::C)
        refresh(true)
        for i in 1...112
            if Kboard.trigger?(i)
            end
        end
        sw=false
        loop do
          Graphics.update
          for i in 1...112
            if Kboard.trigger?(i) && $ascii[i]!=nil
              @number[@index]=i
              $game_config.wdata("keyboard",@number)
              refresh
              sw=true
              break
            end
          end
          break if sw
        end
        Input.update
      end
      return process_ok if Input.trigger?(Input::B)
    else
      process_cursor_move
      process_digit_change
      process_handling
    end
    update_cursor(@index)
  end
  #--------------------------------------------------------------------------
  # ● 处理光标的移动
  #--------------------------------------------------------------------------
  def process_cursor_move
    return unless active
    @last_index = @index
    cursor_right(Input.trigger?(Input::RIGHT)) if Input.repeat?(Input::RIGHT)
    cursor_left (Input.trigger?(Input::LEFT))  if Input.repeat?(Input::LEFT)
    $game_system.se_play($data_system.cursor_se) if @index != @last_index
  end
  #--------------------------------------------------------------------------
  # ● 处理数字的更改
  #--------------------------------------------------------------------------
  def process_digit_change
    return unless active
    if Input.repeat?(Input::UP) || Input.repeat?(Input::DOWN)
      $game_system.se_play($data_system.cursor_se)
      place = 10 ** (@digits_max - 1 - @index)
      n = @number / place % 10
      @number -= n * place
      n = (n + 1) % 10 if Input.repeat?(Input::UP)
      n = (n + 9) % 10 if Input.repeat?(Input::DOWN)
      @number += n * place
      if @number>@max
        @number=@max
      end
      if @number<@min
        @number=@min
      end
      case @kind
      when 0
        $game_config.wdata("speed",@number)
      when 1
        $game_config.wdata("bgm",@number)
        Audio.bgm_play($last_bgm[0])
      when 2
        $game_config.wdata("se",@number)
        $game_system.se_play($data_system.equip_se)
      when 3
        $game_config.wdata("effect",@number)
      when 4
        $game_config.wdata("jianbian",@number)
      when 5
        $game_config.wdata("numlock",@number)
      when 6
        $game_config.wdata("doorcheck",@number)
      when 7
        $game_config.wdata("versionCheck",@number)
      end
      refresh
    end
  end
  #--------------------------------------------------------------------------
  # ● “确定”和“取消”的处理
  #--------------------------------------------------------------------------
  def process_handling
    return unless active
    return process_ok if Input.trigger?(Input::C)
    return process_ok if Input.trigger?(Input::B)
  end
  def process_ok
    $game_system.se_play($data_system.decision_se) 
    $game_config.write_config!()
    Input.update
    self.active=false
    self.visible=false
  end
  #--------------------------------------------------------------------------
  # ● 刷新
  #--------------------------------------------------------------------------
  def refresh(change=false)
    self.contents.clear
    if @digits_max==0 #按键设置
      self.contents.font.color=system_color
      for i in 0...@str.size
        self.contents.draw_text(0,i*32,120,32, @str[i], 0)
      end
      self.contents.font.color=normal_color
      for i in 0...@str.size
        if change && @index==i
          self.contents.draw_text(116,i*32,120,32, "请输入按键", 2)
        else
          s=$ascii[@number[i]]
          if i==2 || i==4 || i==5
            s+="+数字键"
          end
          self.contents.draw_text(116,i*32,120,32, s, 2)
        end
      end
    else #其他设置
      self.contents.font.color=normal_color
      s = sprintf("%0*d", @digits_max, @number)
      @digits_max.times do |i|
        rect = Rect.new(i * 18, 0, 20, 20)
        rect.x += 1
        self.contents.draw_text(rect, s[i,1], 1)
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新光标
  #--------------------------------------------------------------------------
  def update_cursor(index)
    if @digits_max==0
      self.cursor_rect.set(0, @index*32, 240, 32)
    else
      self.cursor_rect.set(index * 18, 0, 20, 20)
    end
  end
end
