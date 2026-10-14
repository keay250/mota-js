
#==============================================================================
# ☆★☆ Custom Save☆★☆
#------------------------------------------------------------------------------
# - FantasyDR
#------------------------------------------------------------------------------
# MSN: [email]FantasyDR_SJL@hotmail.com[/email]
#------------------------------------------------------------------------------
# - 2006.7.18
#------------------------------------------------------------------------------
# 自定义存档数据排列顺序并校验存档
#==============================================================================

#==============================================================================
# ■ Scene_File
#------------------------------------------------------------------------------
# 　存档画面及读档画面的超级类。
#==============================================================================

class Scene_File
#--------------------------------------------------------------------------
# ● 存档密钥，请定义成自己的密钥
#   密钥不同的存档将无法被读取
#--------------------------------------------------------------------------
SAVE_KEY = 20120430
#发布自己的魔塔游戏时，请一定要把上面的数字换掉
#--------------------------------------------------------------------------
# ● 常量 (存档页数)
#--------------------------------------------------------------------------
MaxPages = 500
EveryNum = 12 #一页存档数

 #--------------------------------------------------------------------------
 # ● 初始化对像
 #     help_text : 帮助窗口显示的字符串
 #--------------------------------------------------------------------------
 def initialize(help_text)
   @help_text = help_text
   @slots = MaxPages * EveryNum
 end
 #--------------------------------------------------------------------------
 # ● 主处理
 #--------------------------------------------------------------------------
 def main
   # 生成帮助窗口
   @help_window = Window_Help.new(160)
   @help_window.x=640
   @help_window.set_text(@help_text)
   @file_index = $game_temp.last_file_index
   # 生成存档文件窗口
   @savefile_windows = nil
   # 选择最后操作的文件
   load_window(@file_index / EveryNum * EveryNum)
      #make_filename(i)
   @savefile_windows.index=@file_index%12
   @savefile_windows.visible = true
   @savebitmap_windows = Window_SaveBitmap.new
   @savebitmap_windows.refresh(@file_index)
   @save_index=-1
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
     # 如果画面被切换的话就中断循环
     if $scene != self
       break
     end
   end
   
# 准备过渡
  Graphics.freeze
  # 释放窗口
  @help_window.dispose
  @savebitmap_windows.dispose
  @savefile_windows.dispose if @savefile_windows != nil
end
#--------------------------------------------------------------------------
# ● 刷新画面
#--------------------------------------------------------------------------
def update
  # 刷新窗口
  @help_window.update
  if @save_index != @file_index
    @save_index = @file_index
    @savebitmap_windows.refresh(@file_index)
  end
  @savebitmap_windows.opcupdate
   # 按下 C 键的情况下
   if Input.trigger?(Input::C)
     # 调用过程 on_decision (定义继承目标)
     on_decision(make_filename(@file_index))
     $game_temp.last_file_index = @file_index
     return
   end
   # 按下 B 键的情况下
   if Input.trigger?(Input::B)
   #  Screen::shot(1)
     # 调用过程 on_cancel (定义继承目标)
     on_cancel
     return
   end
   # 按下方向键下的情况下
   if Input.repeat?(Input::DOWN)
     # 演奏光标 SE
     $game_system.se_play($data_system.cursor_se)
     # 光标向下移动
     @file_index = (@file_index + 1) % @slots
     @savefile_windows.index=@file_index%12
     # 翻到下一页的情况下
     if @file_index % EveryNum == 0
       @savefile_windows.refresh(@file_index)
       @savefile_windows.index=0
     end
     return
   end
   # 按下方向键上的情况下
   if Input.repeat?(Input::UP)
     # 演奏光标 SE
     $game_system.se_play($data_system.cursor_se)
     # 光标向下移动
     @file_index = (@file_index + @slots - 1) % @slots
     @savefile_windows.index=@file_index%12
     # 翻到下一页的情况下
     if @file_index % EveryNum == 11
       @savefile_windows.refresh(@file_index)
       @savefile_windows.index=11
     end
     return
   end
   # 按下方向键左的情况下
   if Input.repeat?(Input::LEFT)
     # 演奏光标 SE
     $game_system.se_play($data_system.cursor_se)
     # 光标向下移动
     @file_index = (@file_index + @slots - 12) % @slots
     # 翻到下一页的情况下
     @savefile_windows.refresh(@file_index)
     return
   end
   # 按下方向键右的情况下
   if Input.repeat?(Input::RIGHT)
     # 演奏光标 SE
     $game_system.se_play($data_system.cursor_se)
     # 光标向下移动
     @file_index = (@file_index + 12) % @slots
     # 翻到下一页的情况下
     @savefile_windows.refresh(@file_index)
     return
   end
   if Kboard.repeat?($R_Key_SEP)
     # 演奏光标 SE
     $game_system.se_play($data_system.cursor_se)
     # 光标向下移动
     @file_index = (@file_index + @slots - 120) % @slots
     # 翻到下一页的情况下
     @savefile_windows.refresh(@file_index)
     return
   end
   # 按下方向键右的情况下
   if Kboard.repeat?($R_Key_DOTT)
     # 演奏光标 SE
     $game_system.se_play($data_system.cursor_se)
     # 光标向下移动
     @file_index = (@file_index + 120) % @slots
     # 翻到下一页的情况下
     @savefile_windows.refresh(@file_index)
     return
   end
 end
 #--------------------------------------------------------------------------
 # ● 生成文件名
 #     file_index : 文件名的索引 (0～n)
 #--------------------------------------------------------------------------
 def make_filename(file_index)
   return "Save/motaSave#{file_index + 1}.rxdata"
 end
 #--------------------------------------------------------------------------
 # ● 载入当前页存档
 #     避免因存档位过多造成的卡壳现象
 #--------------------------------------------------------------------------
 def load_window(i)
   if @savefile_windows != nil
     return
   else
     @savefile_windows = Window_SaveFile.new(i)
   end
 end
end

#==============================================================================
# ■ Scene_Load
#------------------------------------------------------------------------------
# 　处理读档画面的类。
#==============================================================================

class Scene_Load < Scene_File
#--------------------------------------------------------------------------
# ● 初始化对像
#--------------------------------------------------------------------------
def initialize()#save_max = SAVE_MAX)
  # 再生成临时对像
  $game_temp = Game_Temp.new
  # 选择存档时间最新的文件
  $game_temp.last_file_index = 0
  filename="Save/lastsave.rxdata"
  if FileTest.exist?(filename)
   file = File.open(filename,"r")
   $game_temp.last_file_index = Marshal.load(file)
   file.close
   super(" 读档界面")
   return
 end
  latest_time = Time.at(0)
  for i in 0..(MaxPages*12-1)
    filename = make_filename(i)
    if FileTest.exist?(filename)
    begin
      file = Zlib::GzipReader.open(filename)
    rescue
      next
    end
    if file.mtime > latest_time
      latest_time = file.mtime
      $game_temp.last_file_index = i
    end
    file.close
    end
  end
  super(" 读档界面")#,"读取",save_max)
end
#--------------------------------------------------------------------------
# ● 确定时的处理
#--------------------------------------------------------------------------
def on_decision(filename)
  # 文件不存在的情况下
  unless FileTest.exist?(filename)
    # 演奏冻结 SE
    $game_system.se_play($data_system.buzzer_se)
    return
  end
  # 演奏读档 SE
  $game_system.se_play($data_system.load_se)
  # 写入存档数据
  begin
    file = Zlib::GzipReader.open(filename)
    read_save_data(file)
  rescue
    # 演奏冻结 SE
    $game_system.se_play($data_system.buzzer_se)
    return
  end
  file.close
  # 还原 BGM、BGS
  $game_system.bgm_play($game_system.playing_bgm)
  $game_system.bgs_play($game_system.playing_bgs)
  # 刷新地图 (执行并行事件)
  $game_map.update
  # 切换到地图画面
  $scene = Scene_Map.new
end
#--------------------------------------------------------------------------
# ● 取消时的处理
#--------------------------------------------------------------------------
def on_cancel
  # 演奏取消 SE
  $game_system.se_play($data_system.cancel_se)
  # 切换到标题画面
  $scene = Scene_Title.new
end
#--------------------------------------------------------------------------
# ● 读取存档数据
#   file : 读取用文件对像 (已经打开)
#--------------------------------------------------------------------------
def read_save_data(file)
  
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
  key = SAVE_KEY
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

#  $data_enemies = Marshal.load(Zlib::Inflate.inflate(strings[12]))
  # 魔法编号与保存时有差异的情况下
  # (加入编辑器的编辑过的数据)
  if $game_system.magic_number != $data_system.magic_number
    # 重新装载地图
    $game_map.setup($game_map.map_id)
    $game_player.center($game_player.x, $game_player.y)
  else
    if $data_mapname[$game_map.map_id].name[0,6]=="归亡"
      Monster.special_set(1)
    end
    if $data_mapname[$game_map.map_id].name[0,12]=="绝望之塔"
      Monster.special_set(3)
    end
  end
  # 刷新同伴成员
  $game_party.refresh
end
end


#==============================================================================
# ■ Scene_Load2
#------------------------------------------------------------------------------
# 　处理读档画面的类。
#==============================================================================

class Scene_Load2 < Scene_File
#--------------------------------------------------------------------------
# ● 初始化对像
#--------------------------------------------------------------------------
def initialize()#save_max = SAVE_MAX)
  # 再生成临时对像
  $game_temp = Game_Temp.new
  # 选择存档时间最新的文件
  $game_temp.last_file_index = 0
  filename="Save/lastsave.rxdata"
  if FileTest.exist?(filename)
   file = File.open(filename,"r")
   $game_temp.last_file_index = Marshal.load(file)
   file.close
   super(" 读档界面")
   return
  end
  latest_time = Time.at(0)
  for i in 0..(MaxPages*12-1)
    filename = make_filename(i)
    if FileTest.exist?(filename)
    begin
      file = Zlib::GzipReader.open(filename)
    rescue
      next
    end
    if file.mtime > latest_time
      latest_time = file.mtime
      $game_temp.last_file_index = i
    end
    file.close
    end
  end
  super(" 读档界面")#,"读取",save_max)
end
#--------------------------------------------------------------------------
# ● 确定时的处理
#--------------------------------------------------------------------------
def on_decision(filename)
  # 文件不存在的情况下
  unless FileTest.exist?(filename)
    # 演奏冻结 SE
    $game_system.se_play($data_system.buzzer_se)
    return
  end
  # 演奏读档 SE
  $game_system.se_play($data_system.load_se)
  # 写入存档数据
  begin
    file = Zlib::GzipReader.open(filename)
    read_save_data(file)
  rescue
    # 演奏冻结 SE
    $game_system.se_play($data_system.buzzer_se)
    return
  end
  file.close
  # 还原 BGM、BGS
  $game_system.bgm_play($game_system.playing_bgm)
  $game_system.bgs_play($game_system.playing_bgs)
  # 刷新地图 (执行并行事件)
  $game_map.update
  # 切换到地图画面
  $scene = Scene_Map.new
end
#--------------------------------------------------------------------------
# ● 取消时的处理
#--------------------------------------------------------------------------
def on_cancel
  # 演奏取消 SE
  $game_system.se_play($data_system.cancel_se)
  # 切换到标题画面
  $scene = Scene_Map.new
end
#--------------------------------------------------------------------------
# ● 读取存档数据
#   file : 读取用文件对像 (已经打开)
#--------------------------------------------------------------------------
def read_save_data(file)
  
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
  key = SAVE_KEY
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

#  $data_enemies = Marshal.load(Zlib::Inflate.inflate(strings[12]))

  
  # 魔法编号与保存时有差异的情况下
  # (加入编辑器的编辑过的数据)
  if $game_system.magic_number != $data_system.magic_number
    # 重新装载地图
    $game_map.setup($game_map.map_id)
    $game_player.center($game_player.x, $game_player.y)
  else
    if $data_mapname[$game_map.map_id].name[0,6]=="归亡"
      Monster.special_set(1)
    end
    if $data_mapname[$game_map.map_id].name[0,12]=="绝望之塔"
      Monster.special_set(3)
    end
  end
  # 刷新同伴成员
  $game_party.refresh
end
end


#==============================================================================
# 自定义存档菜单
#==============================================================================

#==============================================================================
# ■ Scene_Save
#------------------------------------------------------------------------------
# 　处理存档画面的类。
#==============================================================================

class Scene_Save < Scene_File
#--------------------------------------------------------------------------
# ● 初始化对像
#--------------------------------------------------------------------------
def initialize()#save_max = SAVE_MAX)
  super(" 存档界面")#,"存入",save_max)
end
#--------------------------------------------------------------------------
# ● 确定时的处理
#--------------------------------------------------------------------------
def on_decision(filename)
  # 演奏存档 SE
  $game_system.se_play($data_system.save_se)
  # 写入存档数据
  file = Zlib::GzipWriter.open(filename,9)
  write_save_data(file)
  file.close
  filename="Save/lastsave.rxdata"
  file = File.open(filename,"wb")
  Marshal.dump(@file_index,file)
  file.close
  # 如果被事件调用
  if $game_temp.save_calling
    # 清除存档调用标志
    $game_temp.save_calling = false
    # 切换到地图画面
    $scene = Scene_Map.new
    return
  end
  # 切换到地图画面
  $save_id=@file_index+1
  $scene = Scene_Map.new
    
end
#--------------------------------------------------------------------------
# ● 取消时的处理
#--------------------------------------------------------------------------
def on_cancel
  # 演奏取消 SE
  $game_system.se_play($data_system.cancel_se)
  # 如果被事件调用
  if $game_temp.save_calling
    # 清除存档调用标志
    $game_temp.save_calling = false
    # 切换到地图画面
    $scene = Scene_Map.new
    return
  end
  # 切换到地图画面
  $scene = Scene_Map.new
end
#--------------------------------------------------------------------------
# ● 写入存档数据
#   file : 写入用文件对像 (已经打开)
#--------------------------------------------------------------------------
def write_save_data(file)  
  # 生成描绘存档文件用的角色图形
  characters = []
  for i in 0...$game_party.actors.size
    actor = $game_party.actors[i]
    characters.push([actor.character_name, actor.character_hue,actor.id])
  end

  strings = []
 # $snap_bitmap=nil
  Marshal.dump($snap_bitmap,file)#自己加的用来显示难度和楼层的
  
  # 写入描绘存档文件用的角色数据
  Marshal.dump(characters,file)
  # 写入测量游戏时间用画面计数
  Marshal.dump(Graphics.frame_count,file)
  # 增加 1 次存档次数
  $game_system.save_count += 1
  # 保存魔法编号
  # (将编辑器保存的值以随机值替换)
  $game_system.magic_number = $data_system.magic_number
 
  # 写入各种游戏对像
  $game_switches[4]=true#楼层第一次刷新的开关打开以便读档后刷新
  
  strings.push(Zlib::Deflate.deflate(Marshal.dump($game_system)))
  strings.push(Zlib::Deflate.deflate(Marshal.dump($game_variables)))
  strings.push(Zlib::Deflate.deflate(Marshal.dump($game_self_switches)))
  strings.push(Zlib::Deflate.deflate(Marshal.dump($game_switches)))
  strings.push(Zlib::Deflate.deflate(Marshal.dump($game_troop)))
  strings.push(Zlib::Deflate.deflate(Marshal.dump($game_map)))
  strings.push(Zlib::Deflate.deflate(Marshal.dump($game_player)))
  strings.push(Zlib::Deflate.deflate(Marshal.dump($game_screen)))
  strings.push(Zlib::Deflate.deflate(Marshal.dump($game_actors)))
  strings.push(Zlib::Deflate.deflate(Marshal.dump($game_party)))
  strings.push(Zlib::Deflate.deflate(Marshal.dump($floorenemies)))
  strings.push(Zlib::Deflate.deflate(Marshal.dump($fledam)))
  strings.push(Zlib::Deflate.deflate(Marshal.dump($movedevents)))
  strings.push(Zlib::Deflate.deflate(Marshal.dump($new_map)))

  
  
  # 计算校验值
  crcs = []
  key = SAVE_KEY
  strings.each do |i|
    key = Zlib.crc32(i,key)
    crcs.push(key)
  end
  Marshal.dump(crcs,file)
  Marshal.dump(strings,file)
end
end
class Scene_Map
def game_auto_save(filename)
  return if $game_switches[65]
  @spriteset.dispose_lights_ex
  str=["Hard","Normal","Easy"]
  filename="Save/"+filename+"-"+str[$game_variables[177]]+".rxdata"
  file = Zlib::GzipWriter.open(filename,9)
  # 生成描绘存档文件用的角色图形
  characters = []
  for i in 0...$game_party.actors.size
    actor = $game_party.actors[i]
    characters.push([actor.character_name, actor.character_hue,actor.id])
  end

  strings = []
  
  Marshal.dump($snap_bitmap,file)
  
  # 写入描绘存档文件用的角色数据
  Marshal.dump(characters,file)
  # 写入测量游戏时间用画面计数
  Marshal.dump(Graphics.frame_count,file)
  # 增加 1 次存档次数
  $game_system.save_count += 1
  # 保存魔法编号
  # (将编辑器保存的值以随机值替换)
  $game_system.magic_number = $data_system.magic_number
 
  # 写入各种游戏对像
  $game_switches[4]=true
  
  strings.push(Zlib::Deflate.deflate(Marshal.dump($game_system)))
  strings.push(Zlib::Deflate.deflate(Marshal.dump($game_variables)))
  strings.push(Zlib::Deflate.deflate(Marshal.dump($game_self_switches)))
  strings.push(Zlib::Deflate.deflate(Marshal.dump($game_switches)))
  strings.push(Zlib::Deflate.deflate(Marshal.dump($game_troop)))
  strings.push(Zlib::Deflate.deflate(Marshal.dump($game_map)))
  strings.push(Zlib::Deflate.deflate(Marshal.dump($game_player)))
  strings.push(Zlib::Deflate.deflate(Marshal.dump($game_screen)))
  strings.push(Zlib::Deflate.deflate(Marshal.dump($game_actors)))
  strings.push(Zlib::Deflate.deflate(Marshal.dump($game_party)))
  strings.push(Zlib::Deflate.deflate(Marshal.dump($floorenemies)))
  strings.push(Zlib::Deflate.deflate(Marshal.dump($fledam)))
  strings.push(Zlib::Deflate.deflate(Marshal.dump($movedevents)))
  strings.push(Zlib::Deflate.deflate(Marshal.dump($new_map)))
#  strings.push(Zlib::Deflate.deflate(Marshal.dump($data_enemies)))
  
  
  # 计算校验值
  crcs = []
  key = 20120430#SAVE_KEY
  strings.each do |i|
    key = Zlib.crc32(i,key)
    crcs.push(key)
  end
  Marshal.dump(crcs,file)
  Marshal.dump(strings,file)
  file.close
  @spriteset.setup_lights_ex
end
end
