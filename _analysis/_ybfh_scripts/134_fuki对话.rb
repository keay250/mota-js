#==============================================================================
#
#    呼出对话框　ver. 1.31 By パラ犬（日）
#　　来自 http://rpg.para.s3p.net/
#
#　　汉化修改　66RPG bbschat(2006.1.5)
#    来自 http://www.66RPG.com/
#
#    脚本更新：by KKME◎66RPG.com，2007年2月
#
#==============================================================================
#    ●准备工作-窗口Skin
#
#    首先，确认自己使用的对话框窗口Skin，（数据库-系统-窗口外观图形）
#    然后根据该窗口Skin制作对话框尾部使用的两个箭头图形
#    尾部箭头图形命名方式：“窗口skin名-top”，“窗口skin名-under”
#    将该图形文件存放在“Graphics/Windowskins”文件夹下。
#
#    本演示游戏内置2套窗口和箭头图形，
#    一套是游戏默认的“001-Blue01”，一套是定制的“fk”
#    玩家可以根据自己的需要参照样本定制自己的呼出对话框窗口Skin。
#
#  ★●使用方法 edit by KKME◎66RPG.com
#
#    方法一：传统方法：输入脚本：chat(事件编号, "角色姓名")。这样就可以正常显示。
#            这种方法虽然使用麻烦，但是有时候也会用到（比如不显示姓名的对话）。这种方法比方法二优先度高。
#            当不需要这种对话功能时候，直接输入一个脚本：chat，就能全部清空。
#
#    方法二：新方法：直接输入对话，会自动读取人名。
#            举例：首先将事件NPC命名，比如命名为“王小二”
#            则输入对话：
#               王小二：
#               今天天气真好啊。
#    这样就能直接将对话显示在这个NPC头上。如果姓名是我方队员则可自动显示在主角头上。
#    这种方法对于我方队员的情况支持 \n[1]这样的效果。如
#               \n[1]：
#               明天听说要下雨。
#    也能正确显示。对于一般的游戏制作这样已经足够了，如果还有特殊需求——小生是
#    知道有可能需要什么特殊需求的：），其实也设置了接口可以满足，不过需要你自己研究一下。
#            
#
#  ★●角色名字窗口使用角色图片的方法（汉化特别追加功能，原脚本只能使用文字）
#    
#    如果能在对应文件夹中找到文件名和角色名字相同的图片，    
#    则角色名字窗口显示角色头像图片，角色图片最好能包括角色的名字。
#    默认头像图片保存目录为“Graphics/Heads/”，玩家可自行修改。
#
#    如果不想使用角色名字直接作为头像文件名。可以使用下面在 Game_Temp 类里增加的namebmp属性。
#    重新设定角色名字与文件名的对应关系。
#
#  KKME注：这里修改了原有算法，可以支持中文名。小生以为不再需要Game_Temp类了。
#          这里小生知道也会有特殊需求，也是设置好接口了的。如果需要再自己研究或问我吧。不然说多了容易误导。  
#
#    ●信息表示速度的变更方法
#
#    在事件命令行使用［脚本］将数值代入［$mes_speed］
#    速度为 0 即瞬间显示全部信息，数字越大，信息表示速度越慢。
#   （举例：$mes_speed=1）
#
#    ●其他设置
#
#    请参照下面的注释
#==============================================================================

module FUKI

  # 头像图片保存目录的设定
  HEAD_PIC_DIR = "Graphics/Heads/"

  # 是否显示尾部图标
  TAIL_SHOW = false#true
  BOOK_SIZE=12
  # Skin的设定
  # 使用数据库默认窗口Skin情况下这里使用[""]
  FUKI_SKIN_NAME = ""   # 呼出对话框用Skin
  NAME_SKIN_NAME = ""   # 角色名字窗口用Skin
  FUKI_SKIN_NAME2 = "say"
  
  # 字体大小
  MES_FONT_SIZE = 22    # 呼出对话框
  NAME_FONT_SIZE = 14   # 角色名字窗口
  
  # 字体颜色
  #（设定为 Color.new(0, 0, 0, 0) 表示使用普通文字色）
  FUKI_COLOR = Color.new(255, 255, 255, 255)  # 呼出对话框
  NAME_COLOR = Color.new(255, 255, 255, 255)  # 角色名字窗口
  
  # 窗口透明度
  # 如修改窗口透明度请同时修改尾部箭头图形内部的透明度
  FUKI_OPACITY = 200    # 呼出对话框
  MES_OPACITY = 200     # 默认信息窗口
  NAME_OPACITY = 200    # 角色名字窗口
  
  # 角色名字窗口的相对位置
  NAME_SHIFT_X = 0      # 横坐标
  NAME_SHIFT_Y = 4    # 纵坐标
  
  # 窗口表示时是否根据画面大小自动检查窗口出现的位置，
  # 自动改变位置（ true / false ）
  # 设置成 true 在某些变态情况下可能出现箭头图标颠倒的问题 <- bbschat <= KKME
  POS_FIX = true

  # 在画面最边缘表示时的稍微挪动
  # 使用圆形Skin的角和方框的角重合的情况下为 true
  CORNER_SHIFT = false
  SHIFT_PIXEL = 4   # true 时挪动的象素
  
  # 角色高度尺寸
  CHARACTOR_HEIGHT = 32
  # 呼出对话框的相对位置（纵坐标）
  POP_SHIFT_TOP = 0         # 表示位置为上的时候
  POP_SHIFT_UNDER = 0       # 表示位置为下的时候
  
  # 信息的表示速度（数字越小速度越快，0为瞬间表示）
  # 游戏中 可随时用数字代入 $mes_speed 来改变消息表示速度。
  MES_SPEED = 0
end


#==============================================================================
# 初始化两个变量，不要动（by KKME◎66RPG.com）
#==============================================================================
$mes_name = ""
$mes_id   = nil


#==============================================================================
# 方便用户同时设置2个常用参数而使用的函数
#==============================================================================
def chat(id = nil,name = "")
  $mes_id = id
  $mes_name = name 
end

#==============================================================================
# □ Game_Temp
#==============================================================================

class Game_Temp
  attr_accessor  :namebmp              #保存头像图片的Hash表
  alias initialize_fuki initialize
  def initialize
    initialize_fuki
    # 如果不想使用角色名字直接作为头像文件名
    # 可在这里重新设定角色名字与文件名的对应关系
    @namebmp ={"玩家"=>"维斯特"}
  end
end

#==============================================================================
# □ Window_Message
#==============================================================================

class Window_Message < Window_Selectable

  #--------------------------------------------------------------------------
  # ● 初始化状态
  #--------------------------------------------------------------------------
  def initialize
    super(135, 304, 500, 160)
    self.contents = Bitmap.new(width - 32, height - 32)
    self.visible = false
    self.z = 9998
    @fade_in = false
    @fade_out = false
    @contents_showing = false
    @cursor_width = 0
    @kkme_name = ""
    self.active = false
    self.index = -1      
    @save_index=@index
    @start_index=0
    @w = 0
    @h = 0
    @wait = 0
    @dx = 0
    @dy = 0
    $mes_speed = FUKI::MES_SPEED
  end
  
  #--------------------------------------------------------------------------
  # ○ 决定窗口尺寸并生成窗口
  #--------------------------------------------------------------------------
  def refresh_create
    @kkme_name = ""
    begin
      @kkme_name = $game_temp.message_text.split("：")[0] if $game_temp.message_text.split("：")[1] != nil
      $game_temp.message_text = $game_temp.message_text[@kkme_name.size + 4,$game_temp.message_text.size] if @kkme_name != ""
    rescue
    end
    self.contents.clear
    self.contents.font.color = normal_color
    self.contents.font.size = FUKI::MES_FONT_SIZE
    # 取得窗口尺寸
    get_windowsize
    w = @w + 32 + 8
    h = @h +26 #* (self.contents.font.size + 10) + 26
    # 生成呼出窗口
    set_fukidasi(self.x, self.y, w, h)
    # 生成角色名字窗口
    set_namewindow
    # 初始化信息表示使用的变量
    @dx = @dy = 0
    @cursor_width = 0
    @contents_drawing = true
    # 瞬间表示的情况下
    if $mes_speed == 0
      # 循环信息描绘处理
      while $game_temp.message_text != ""
        draw_massage
      end
      draw_opt_text
      @contents_showing_end = true
      @contents_drawing = false
    else
      # 一个一个描绘文字
      refresh_drawtext
    end
  end
  
  #--------------------------------------------------------------------------
  # ○ 一个一个描绘文字
  #--------------------------------------------------------------------------
  def refresh_drawtext
    if $game_temp.message_text != nil
      if @wait > 0
        @wait -= 1
      elsif @wait == 0
        # 描绘处理
        draw_massage
        @wait = $mes_speed
      end
    end
    # 描绘结束
    if $game_temp.message_text == ""
      draw_opt_text
      @contents_showing_end = true
      @contents_drawing = false
    end
  end
  
  #--------------------------------------------------------------------------
  # ○ 取得窗口尺寸
  #--------------------------------------------------------------------------
  def get_windowsize
    x = y = 0
    @h = @w = 0 
    @cursor_width = 0
    self.contents.font.size = FUKI::MES_FONT_SIZE
    # 有选择项的话，处理字的缩进
    if $game_temp.choice_start == 0
      x = 16
    end
    # 有等待显示的文字的情况下
    if $game_temp.message_text != nil
    text = $game_temp.message_text.clone
      # 限制文字处理
      begin
        last_text = text.clone
        text.gsub!(/\\[Vv]\[([0-9]+)\]/) { $game_variables[$1.to_i] }
      end until text == last_text
      text.gsub!(/\\[Nn]\[([0-9]+)\]/) do
        $game_actors[$1.to_i] != nil ? $game_actors[$1.to_i].name : ""
      end
      # 为了方便、将 "\\\\" 变换为 "\000" 
      text.gsub!(/\\\\/) { "\000" }
      # "\\C" 变为 "\001"、"\\G" 变为 "\002"
      text.gsub!(/\\[Cc]\[([0-9]+)\]/) { "\001[#{$1}]" }
      text.gsub!(/\\[Gg]/) { "\002" }
      text.gsub!(/\\[Ii]\[([0-9]+)\]/) { "\003[#{$1}]"+$data_items[$1.to_i].name}
      text.gsub!(/\\[Ww]\[([0-9]+)\]/) { "\004[#{$1}]"+$data_weapons[$1.to_i].name}
      text.gsub!(/\\[Ss]\[([0-9]+)\]/) { "\005[#{$1}]"}
      text.gsub!(/\\[Tt][Xx][Tt]\[(\w+)\]/){"\006[#{$1}]"}
      # c 获取 1 个字 (如果不能取得文字就循环)
      while ((c = text.slice!(/./m)) != nil)
        # \\ 的情况下
        if c == "\000"
          # 还原为本来的文字
          c = "\\"
        end
        # \C[n] 或者 \G 的情况下
        if c == "\001" or c == "\002"
          # 下面的文字
          text.sub!(/\[([0-9]+)\]/, "")
          next
        end
        if c == "\003"
          # 取得物品ID
          text.sub!(/\[([0-9]+)\]/, "")
          icon = RPG::Cache.icon($data_items[$1.to_i].icon_name)
          x+=icon.width
        end
        if c== "\005" #改变字号
          text.sub!(/\[([0-9]+)\]/, "")
          self.contents.font.size+= $1.to_i
        end
        if c== "\006" #显示大量文本
          text=text.split("]")[0]
          text=text[1,text.size-1]
          @ts = TextStream.new
          @ts.open(text)
          $game_temp.message_text=""+@ts.get_text(999)
          $game_temp.message_text=$game_temp.message_text[3,$game_temp.message_text.size-3]
          text=$game_temp.message_text.clone
        end
        # 另起一行文字的情况下
        if c == "\n"
          # y 累加 1
          y += 1
          # 取得纵横尺寸
          @h = y * (self.contents.font.size+10)
          @w = x > @w ? x : @w
          if y >= $game_temp.choice_start
            @w = x + 8 > @w ? x + 8 : @w
          end
          x = 0
          # 移动到选择项的下一行
          if y >= $game_temp.choice_start
            x = 8
          end
          if y>=FUKI::BOOK_SIZE
            $game_variables[106]=text.clone
            break
          end
          # 下面的文字
          next
        end
        # x 为要描绘文字的宽度加法运算
        x += self.contents.text_size(c).width
      end
    end
    # 输入数值的情况
    if $game_temp.num_input_variable_id > 0
      digits_max = $game_temp.num_input_digits_max
      number = $game_variables[$game_temp.num_input_variable_id]
      @h += 1 * (self.contents.font.size+10)
      x = digits_max * self.contents.font.size + 16
      @w = x > @w ? x : @w
    end
  end

  #--------------------------------------------------------------------------
  # ○ 描绘信息处理
  #--------------------------------------------------------------------------
  def draw_massage
    # 有等待显示的文字的情况下
    if $game_temp.message_text != nil
      text = $game_temp.message_text
  
      # 限制文字处理
      begin
        last_text = text.clone
        text.gsub!(/\\[Vv]\[([0-9]+)\]/) { $game_variables[$1.to_i] }
      end until text == last_text
      text.gsub!(/\\[Nn]\[([0-9]+)\]/) do
        $game_actors[$1.to_i] != nil ? $game_actors[$1.to_i].name : ""
      end    
      # "\\/" 删除行尾换行符号
    #  text.gsub!(/\\\/\n/) {""}
      # 去掉不在行尾的"\\/"符号,防止出错
   #   text.gsub!(/\\\//) {""}
      # 为了方便、将 "\\\\" 变换为 "\000" 
      text.gsub!(/\\\\/) { "\000" }
      # "\\C" 变为 "\001"、"\\G" 变为 "\002"
      text.gsub!(/\\[Cc]\[([0-9]+)\]/) { "\001[#{$1}]" }
      text.gsub!(/\\[Gg]/) { "\002" }
      text.gsub!(/\\[Ii]\[([0-9]+)\]/) { "\003[#{$1}]"+$data_items[$1.to_i].name}
      text.gsub!(/\\[Ww]\[([0-9]+)\]/) { "\004[#{$1}]"+$data_weapons[$1.to_i].name.split(":")[0]}
      text.gsub!(/\\[Ss]\[([0-9]+)\]/) { "\005[#{$1}]"}
      # c 获取 1 个字
      if ((c = text.slice!(/./m)) != nil)
        # 选择项的情况
        if @dy >= $game_temp.choice_start - (@kkme_name !=nil && @kkme_name !="" ? 1 : 0 )
          # 处理字的缩进
          @dx = 8
          # 描绘文字
          self.contents.draw_text(4 + @dx, 32 * @dy, 40, 32, c)
          # x 为要描绘文字宽度的加法运算
          @dx += self.contents.text_size(c).width
          # 循环
          while ((c = text.slice!(/./m)) != "\n")
            # 描绘文字
            self.contents.draw_text(4 + @dx, 32 * @dy, 40, 32, c)
            # x 为要描绘文字宽度的加法运算
            @dx += self.contents.text_size(c).width
          end
          if c == "\n"
            # 更新光标宽度
            @cursor_width = [@cursor_width, @dx].max
            # dy 累加 1
            @dy += 1
            @dx = 0
          end
          return
        end
        # \\ 的情况下
        if c == "\000"
          # 还原为本来的文字
          c = "\\"
        end
        #\C[n] 的情况下
        if c == "\001"
          # 更改文字色
          text.sub!(/\[([0-9]+)\]/, "")
          color = $1.to_i
          if color >= 0 and color <= 12
            self.contents.font.color = text_color(color)
          end
          return
        end
        # \G 的情况下
        if c == "\002"
          # 生成金钱窗口
          if @gold_window == nil
            @gold_window = Window_Gold.new
            @gold_window.x = 640 - @gold_window.width
            if $game_temp.in_battle
              @gold_window.y = 192
            else
              @gold_window.y = self.y >= 128 ? 32 : 384
            end
            @gold_window.opacity = self.opacity
            @gold_window.back_opacity = self.back_opacity
          end
        end
        @height = 32
        if c == "\003"
          # 取得物品ID
          text.sub!(/\[([0-9]+)\]/, "")
          icon = RPG::Cache.icon($data_items[$1.to_i].icon_name)
          self.contents.blt(@dx+4,@dy*@height+(@height-32)/2,icon,Rect.new(0, 0, icon.width,icon.height))
          @dx+=8+icon.width
          return 
        end
        # 显示武器图标（因为类似物品图标显示，所以省略注释）
        if c == "\004"
          # 取得物品ID
          text.sub!(/\[([0-9]+)\]/, "")
          icon = RPG::Cache.icon($data_weapons[$1.to_i].icon_name)
          self.contents.blt(@dx+4,@dy*@height+(@height-32)/2,icon,Rect.new(0, 0, icon.width,icon.height))
          @dx+=8+icon.width
          return 
        end
        if c== "\005" #改变字号
          text.sub!(/\[([0-9]+)\]/, "")
          self.contents.font.size+= $1.to_i#FUKI::MES_FONT_SIZE
          return
        end
        # 另起一行文字的情况下
        if c == "\n"
          # dy 累加 1
          @dy += 1
          @dx = 0
          if @dy>=FUKI::BOOK_SIZE
            $game_temp.message_text=""
          end
          return "lend"
        end
        # 描绘文字
      #  self.contents.font.size = FUKI::MES_FONT_SIZE
        font_size = self.contents.font.size
        self.contents.draw_text(4+@dx, (font_size+10)*@dy, font_size, font_size, c)
        # dx 为要描绘文字的宽度加法运算
        @dx += self.contents.text_size(c).width
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # ○ 选择项和输入数值的情况下
  #--------------------------------------------------------------------------
  def draw_opt_text
    # 选择项的情况下
    if $game_temp.choice_max > 0
      if $game_temp.choice_max>4
        @item_max=(self.height-56)/32
      else
        @item_max=$game_temp.choice_max
      end
      self.active = true
      self.index = 0
    end
    # 输入数值的情况下
    if $game_temp.num_input_variable_id > 0
      a=$game_temp.num_input_start
      if get_character_KKME==nil
        a+=1
      end
      digits_max = $game_temp.num_input_digits_max
      number = $game_variables[$game_temp.num_input_variable_id]
      @input_number_window = Window_InputNumber.new(digits_max)
      @input_number_window.number = number
      @input_number_window.x = self.x + 8
      @input_number_window.y = self.y + a * 32-32
    end
  end
  
  #--------------------------------------------------------------------------
  # ○ 设置呼出对话框
  #--------------------------------------------------------------------------
  def set_fukidasi(x, y, width, height)
    begin
      # 不显示暂停标志
      self.pause = false
      # 取得对话框位置
      pos = get_fuki_pos(width, height)
      x = pos[0]
      y = pos[1]
      width=pos[2]
      height=pos[3]
 #     p @item_max,$game_temp.choice_max
      skin = FUKI::FUKI_SKIN_NAME != "" ? FUKI::FUKI_SKIN_NAME : $game_system.windowskin_name
      if $game_switches[180] && $mes_name==$game_actors[1].name
        skin="001-Blue02"
      else
        skin="001-Blue01"
      end
      self.windowskin = RPG::Cache.windowskin(skin)
      self.x = x
      self.y = y
      self.height = height
      self.width = width
      self.contents.dispose
      self.contents = Bitmap.new(width - 32, height - 32)
      self.back_opacity = FUKI::FUKI_OPACITY
      self.opacity = 255
      self.contents.clear
      self.contents.font.color = normal_color
      self.contents.font.size = FUKI::MES_FONT_SIZE
      # 描绘尾部图标
      if $game_system.message_frame == 0
        # 取得位置
        tale_pos = get_tale_pos
        @tale = Sprite.new
        # 是否显示尾部图标 <- bbschat
        if FUKI::TAIL_SHOW == true
          case @message_position
            when 0  # 上
              @tale.bitmap = RPG::Cache.windowskin(skin + "-top")
              @tale.x = tale_pos[0]
              @tale.y = tale_pos[1]
              @tale.z = self.z + 1
            when 1  # 中
              @tale.dispose
              @tale = nil
            when 2  # 下
              @tale.bitmap = RPG::Cache.windowskin(skin + "-under")
              @tale.x = tale_pos[0]
              @tale.y = tale_pos[1]
              @tale.z = self.z + 1
          end
        end
      end
    rescue
  #    del_fukidasi
   #   reset_window(width, height)
    end
  end
  #--------------------------------------------------------------------------
  # ○ 新功能：根据输入文章计算呼出对话框的位置
  #--------------------------------------------------------------------------
  def get_character_KKME
    if @kkme_name == "" or @kkme_name == nil
      return nil
    else
      @kkme_name.gsub!(/\\[Nn]\[([0-9]+)\]/) do
      $game_actors[$1.to_i] != nil ? $game_actors[$1.to_i].name : ""
    end
      a=@kkme_name.split("-")
      if a.size>1
        if a[0].to_i==0
          $mes_name = a[1]
          return $game_player
        else
          $mes_name = a[1]
          return $game_map.events[a[0].to_i]
        end
      end
      $mes_name = @kkme_name
      for actor in $game_party.actors
        if actor.name == @kkme_name
          return $game_player
        end
      end
      for ev in $game_map.events.values
        if ev.name == @kkme_name
          return ev
        end
      end
      return nil
    end
  end
    
  
  #--------------------------------------------------------------------------
  # ○ 计算呼出对话框的位置
  #--------------------------------------------------------------------------
  def get_fuki_pos(width, height)
    # 取得角色
    if $mes_id != nil
      @character = get_character($mes_id)
    else
      @character = get_character_KKME
    end
    if @character == nil
      # 角色不存在的情况下使用默认信息框
      del_fukidasi
 reset_window(width, height)
    if $game_variables[101]==1
      @message_position=2
      x=140
      y=30
      width=520
      height=416
      self.width= width 
      self.height=height
      return [x,y,width,height]
    end
      return
    end
   
    # 纪录文章显示位置
    
    # 如果选择自动修正，则如果文章会显示到画面外则自动改变窗口的尺寸（高度）
      # 处理坐标
      x = ( @character.real_x - $game_map.display_x + 64 ) * 32 / 128 - (width / 2)
      # 为尽量显示在画面内而移动横坐标
      if x + width > 800
        x = 800 - width
      elsif x < 0
        x = 0
      end
      # 决定窗口位置
      case $game_system.message_position
      when 0  # 上
        y = (@character.real_y - $game_map.display_y + 64) * 32 / 128 - height - FUKI::CHARACTOR_HEIGHT + FUKI::POP_SHIFT_TOP
      when 1  # 中
        y = (480 - height) / 2
        x = (640 - width) / 2
      when 2  # 下
        y =  (@character.real_y - $game_map.display_y + 64) * 32 / 128 + 32 + FUKI::POP_SHIFT_UNDER
      end 
      @message_position = $game_system.message_position
      if FUKI::POS_FIX
        case @message_position
        when 0  # 上
          if y <= 0
            @message_position = 2
            y =  (@character.real_y - $game_map.display_y + 64) * 32 / 128 + 32 + FUKI::POP_SHIFT_UNDER
          end
        when 2  # 下
          if y + height >= 480
            @message_position = 0
            y = (@character.real_y - $game_map.display_y + 64) * 32 / 128 - height - FUKI::CHARACTOR_HEIGHT + FUKI::POP_SHIFT_TOP
            if y<32
              y=32
            end
          end
        end
        case @message_position
        when 0  # 上
          if y <= 0
            @message_position = 2
            y =  (@character.real_y - $game_map.display_y + 64) * 32 / 128 + 32 + FUKI::POP_SHIFT_UNDER
            height=(480-y)/32*32
          end
        when 2  # 下
          if y + height >= 480
            @message_position = 0
            y = (@character.real_y - $game_map.display_y + 64) * 32 / 128 - height - FUKI::CHARACTOR_HEIGHT + FUKI::POP_SHIFT_TOP
            height=(480-y)/32*32
          end
        end
      end
    return [x,y,width,height]
    
  end
  
  #--------------------------------------------------------------------------
  # ○ 计算尾部图标的位置
  #--------------------------------------------------------------------------
  def get_tale_pos
    case @message_position
      when 0  # 上
        # 处理坐标
        x = ( @character.real_x - $game_map.display_x + 64 ) * 32 / 128 - 16
        # 画面边缘的话则移动位置
        if FUKI::CORNER_SHIFT
          if x == 0
            x = FUKI::SHIFT_PIXEL
          elsif x == 640 - 32
            x = 640 - 32 - FUKI::SHIFT_PIXEL
          end
        end
        y = self.y + self.height - 16
      when 1  # 中
        x = nil
        y = nil
      when 2  # 下
        # 处理坐标
        x = ( @character.real_x - $game_map.display_x + 64 ) * 32 / 128 - 16
        # 画面边缘的话则移动位置
        if FUKI::CORNER_SHIFT
          if x == 0
            x = FUKI::SHIFT_PIXEL
          elsif @tale.x == 640 - 32
            x = 640 - 32 - FUKI::SHIFT_PIXEL
          end
        end
        y = self.y - 16
    end
    return [x,y]
  end

  #--------------------------------------------------------------------------
  # ○ 计算名字窗口的位置
  #--------------------------------------------------------------------------
  def get_name_pos
    case @face_pic_txt
      when 0  # 文字
        x = self.x + FUKI::NAME_SHIFT_X
        y = self.y - FUKI::NAME_FONT_SIZE - 16 + FUKI::NAME_SHIFT_Y
      when 1  # 图片
        if self.x >= @pic_width + 5
          # 默认头像显示在对话框左边
          x = self.x-@pic_width-5
        else
          # 对话框左边放不下时头像显示在右边
          x = self.x + self.width
        end
        y = self.y+self.height/2 - (@pic_height + 5)/2
      end

    return [x,y]
  end
  
  #--------------------------------------------------------------------------
  # ○ 设置角色名字窗口
  #--------------------------------------------------------------------------
  def set_namewindow
    
    # $mes_name为空时不显示角色名字窗口
    if $mes_name == nil or $mes_name == ""
      return
    else
      # 设定变量
      mes_name = $mes_name
     # skin = FUKI::NAME_SKIN_NAME != "" ? FUKI::NAME_SKIN_NAME : $game_system.windowskin_name
      
      #判断名称是否有对应的图片"Graphics/heads/" +
      if $game_temp.namebmp[mes_name] == nil then
        sFile = "Graphics/heads/" + mes_name + ".png"
      else
        sFile = "Graphics/heads/" + $game_temp.namebmp[mes_name] + ".png"
      end
      
      #if FileTest.exist?(sFile) == true then
      begin
        @face_pic_txt = 1                       #名字窗口使用头像<- bbschat
        
        # 生成头像
        bmp = Bitmap.new(sFile)
        @pic_width = bmp.width 
        @pic_height = bmp.height
        
        if self.x >= @pic_width + 5
          # 默认头像显示在对话框左边
          name_x = self.x-@pic_width-5
        else
          # 对话框左边放不下时头像显示在右边
          name_x = self.x + self.width
        end
        name_y = self.y+self.height/2 - (@pic_height + 5)/2
        
        
        # 生成角色头像窗口
        @name_win = Window_Base.new(name_x, name_y, @pic_width + 5, @pic_height + 5)
        
        skin = FUKI::FUKI_SKIN_NAME != "" ? FUKI::FUKI_SKIN_NAME : $game_system.windowskin_name
        if $game_switches[180] && $mes_name==$game_actors[1].name
          skin="001-Blue02"
        else
          skin="001-Blue01"
        end
        @name_win.windowskin = RPG::Cache.windowskin(skin)
        @name_win.back_opacity =255   
        @name_win.opacity = 255
        @name_win.z = self.z + 1
       
        @name_contents = Sprite.new
        @name_contents.opacity = 255
        @name_contents.x = name_x + 2
        @name_contents.y = name_y + 2
        @name_contents.bitmap = bmp
        #@name_contents.z = @name_win.z + 2     #这个用了似乎效果不好<- bbschat
        
      rescue
       @face_pic_txt = 0                       #名字窗口使用文字<- bbschat

        # 生成名字
        name_width = mes_name.size / 2 * FUKI::NAME_FONT_SIZE
        name_height = FUKI::NAME_FONT_SIZE
        name_x = self.x + FUKI::NAME_SHIFT_X
        name_y = self.y - name_height - 16 + FUKI::NAME_SHIFT_Y

        # 生成角色名字窗口（只有边框）
        @name_win = Window_Base.new(name_x, name_y, name_width + 16, name_height + 16)
        skin = FUKI::FUKI_SKIN_NAME != "" ? FUKI::FUKI_SKIN_NAME : $game_system.windowskin_name
        if $game_switches[180] && $mes_name==$game_actors[1].name
          skin="001-Blue02"
        else
          skin="001-Blue01"
        end
        @name_win.windowskin = RPG::Cache.windowskin(skin)
        @name_win.back_opacity = FUKI::NAME_OPACITY
        @name_win.z = self.z + 1
        
        # 为了使空白比Windows类限定的更小使用双重结构
        @name_contents = Sprite.new
        @name_contents.x = name_x + 12
        @name_contents.y = name_y + 8
        @name_contents.bitmap = Bitmap.new(name_width, name_height)
        @name_contents.z = @name_win.z + 2
        
        # 设定文字色
        nil_color = Color.new(0,0,0,0)
        if FUKI::NAME_COLOR != nil_color
          @name_contents.bitmap.font.color = FUKI::NAME_COLOR
        else
          @name_contents.bitmap.font.color = normal_color
        end
        @name_contents.bitmap.font.size = FUKI::NAME_FONT_SIZE
        # 调整窗口尺寸
        rect = @name_contents.bitmap.text_size(mes_name)
        @name_win.width = rect.width + 32
        # 描画名字
        @name_contents.bitmap.draw_text(rect, mes_name)
        
      end
    end

  end
  
  #--------------------------------------------------------------------------
  # ○ 释放呼出对话框和角色名字窗口
  #--------------------------------------------------------------------------
  def del_fukidasi
    if @tale != nil
      @tale.dispose
      @tale = nil
    end
    if @name_win != nil
      @name_win.dispose
      @name_win = nil
      @name_contents.dispose
      @name_contents = nil
    end
    self.opacity = 0
    self.x = 160
    self.x = 116 if $game_switches[Playerdate_SWITCH]
    self.width = 520
    self.height = 160
    self.contents.dispose
    self.contents = Bitmap.new(width - 32, height - 32)
    self.pause = true
  end
  
  #--------------------------------------------------------------------------
  # ○ 取得角色
  #     parameter : 参数
  #--------------------------------------------------------------------------
  def get_character(parameter)
    # 参数分歧
    case parameter
    when -1  # 玩家
      return $game_player
    when 0   # 该事件
      events = $game_map.events
      return events == nil ? nil : events[$active_event_id]
    else     # 特定事件
      events = $game_map.events
      return events == nil ? nil : events[parameter]
    end
  end
  
  #--------------------------------------------------------------------------
  # ● 设定窗口位置和不透明度
  #--------------------------------------------------------------------------
  def reset_window(width = nil, height = nil)
    if $game_temp.in_battle
      self.y = 16
    else
      case $game_system.message_position
      when 0  # 上
        self.y = 16
      when 1  # 中
        if height != nil and width != nil
          self.y = (480 - height) / 2 - 32
          self.x = (480 - width) / 2+160
         # self.x = (480 - width) / 2+160 if $game_switches[Playerdate_SWITCH]
          self.width = width
          self.height = height
          self.contents.dispose
          self.contents = Bitmap.new(width - 32, height - 32)
        else
          self.y = 160
        end
      when 2  # 下
        self.y = 304
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # ● 刷新画面
  #--------------------------------------------------------------------------
  def update
    super
    # 呼出模式下跟随事件移动
    if @tale != nil
      pos = get_fuki_pos(self.width, self.height)
      self.x = pos[0]
      self.y = pos[1]
      tale_pos = get_tale_pos
      @tale.x = tale_pos[0]
      @tale.y = tale_pos[1]
      
      if @name_win != nil
        name_pos = get_name_pos
        @name_win.x = name_pos[0]
        @name_win.y = name_pos[1]
        case @face_pic_txt
          when 0  # 文字
            @name_contents.x = @name_win.x + 12
            @name_contents.y = @name_win.y + 8
          when 1  # 图片
            @name_contents.x = @name_win.x + 2
            @name_contents.y = @name_win.y + 2
          end
      end
    end
    
    # 渐变的情况下
    if @fade_in
      self.contents_opacity += 24
      if @name_win != nil
        @name_win.opacity += 10
      end
      if @tale != nil
        @tale.opacity += 24
      end
      if @input_number_window != nil
        @input_number_window.contents_opacity += 24
      end
      if self.contents_opacity == 255 || ($game_temp.choice_max==0 && Kboard.press?($game_config.data("keyboard")[7]))
        self.contents_opacity=255
        if @input_number_window != nil
          @input_number_window.contents_opacity=255
         end
        @fade_in = false
      end
      return
    end
    # 显示信息中的情况下
    if @contents_drawing
      refresh_drawtext
      return
    end
    # 输入数值的情况下
    if @input_number_window != nil
      @input_number_window.update
      # 确定
      if Input.trigger?(Input::C)
        $game_system.se_play($data_system.decision_se)
        $game_variables[$game_temp.num_input_variable_id] =
          @input_number_window.number
        $game_map.need_refresh = true
        # 释放输入数值窗口
        @input_number_window.dispose
        @input_number_window = nil
        terminate_message
        del_fukidasi
      end
      return
    end
    # 显示信息结束的情况下
    if @contents_showing_end
      # 不是显示选择项且不是呼出对话模式则显示暂停标志
      if $game_temp.choice_max == 0 and @tale == nil
        self.pause = true
      else
        self.pause = false
      end
      # 取消
      if Input.trigger?(Input::B)
        if $game_temp.choice_max > 0 and $game_temp.choice_cancel_type > 0
          $game_system.se_play($data_system.cancel_se)
          $game_temp.choice_proc.call($game_temp.choice_cancel_type - 1)
          terminate_message
          del_fukidasi
        end
      end
      # 确定
      if Input.trigger?(Input::C) || ($game_temp.choice_max==0 && Kboard.press?($game_config.data("keyboard")[7]))
        if $game_temp.choice_max > 0
          $game_system.se_play($data_system.decision_se)
          if $game_temp.choice_max>4
            $game_temp.choice_proc.call(self.index+@start_index)
          else
            $game_temp.choice_proc.call(self.index)
          end
        end
        terminate_message
        # 释放呼出窗口
        del_fukidasi
      end
      return
    end
    # 在渐变以外的状态下有等待显示的信息与选择项的场合
    if @fade_out == false and $game_temp.message_text != nil
      @contents_showing = true
      $game_temp.message_window_showing = true
      #reset_window
      refresh_create
      if @name_win != nil
        @name_win.opacity = 255
      end
      if @tale != nil
        @tale.opacity = 0
      end
      Graphics.frame_reset
      self.visible = true
      self.contents_opacity = 0
      if @input_number_window != nil
        @input_number_window.contents_opacity = 0
      end
      @fade_in = true
      return
    end
    # 没有可以显示的信息、但是窗口为可见的情况下
    if self.visible
      @fade_out = true
      self.opacity -= 48
      if @name_win != nil
        @name_win.opacity -= 48
      end
      if @tale != nil
        @tale.opacity -= 48
      end
      if self.opacity == 0
        self.visible = false
        @fade_out = false
        $game_temp.message_window_showing = false
        del_fukidasi
      end
      return
    end
  end
  
  #--------------------------------------------------------------------------
  # ● 释放
  #--------------------------------------------------------------------------
  def dispose
    terminate_message
    $game_temp.message_window_showing = false
    if @input_number_window != nil
      @input_number_window.dispose
    end
    super
  end
  
  #--------------------------------------------------------------------------
  # ● 信息结束处理
  #--------------------------------------------------------------------------
  def terminate_message
    self.active = false
    self.pause = false
    self.index = -1
    self.contents.clear
    # 清除显示中标志
    self.windowskin=RPG::Cache.windowskin("001-Blue01")
    @contents_showing = false
    @contents_showing_end = false
    unless @kkme_name == "" or @kkme_name == nil
      $mes_name = ""
      @kkme_name = ""
    end
    # 呼叫信息调用
    if $game_temp.message_proc != nil
      $game_temp.message_proc.call
    end
    # 清除文章、选择项、输入数值的相关变量
    $game_temp.message_text = nil
    if $game_variables[106]!=0
      $game_temp.message_text=$game_variables[106].clone
      $game_variables[106]=0
    end
    $game_temp.message_proc = nil
    $game_temp.choice_start = 99
    $game_temp.choice_max = 0
    $game_temp.choice_cancel_type = 0
    $game_temp.choice_proc = nil
    $game_temp.num_input_start = 99
    $game_temp.num_input_variable_id = 0
    $game_temp.num_input_digits_max = 0
    # 释放金钱窗口
    if @gold_window != nil
      @gold_window.dispose
      @gold_window = nil
    end
  end
  
  #--------------------------------------------------------------------------
  # ● 刷新光标矩形
  #--------------------------------------------------------------------------
  def update_cursor_rect
    if @index >= 0
      n = $game_temp.choice_start + @index
      n-=1 if @kkme_name !=""
      self.cursor_rect.set(8, n * 32, @cursor_width, 32)
    else
      self.cursor_rect.empty
    end
  end
  #--------------------------------------------------------------------------
  # ● 取得普通文字色
  #--------------------------------------------------------------------------
  def normal_color
    nil_color = Color.new(0,0,0,0)
    if FUKI::FUKI_COLOR != nil_color
      color = FUKI::FUKI_COLOR
    else
      color = super
    end
    return color
  end
end


#==============================================================================
# ■ Window_InputNumber
#==============================================================================

class Window_InputNumber < Window_Base
  #--------------------------------------------------------------------------
  # ● 初始化对像
  #     digits_max : 位数
  #--------------------------------------------------------------------------
  def initialize(digits_max)
    @digits_max = digits_max
    @number = 0
    # 从数字的幅度计算(假定与 0～9 等幅)光标的幅度
    dummy_bitmap = Bitmap.new(32, 32)
    dummy_bitmap.font.size = FUKI::MES_FONT_SIZE
    @cursor_width = dummy_bitmap.text_size("0").width + 8
    dummy_bitmap.dispose
    super(0, 0, @cursor_width * @digits_max + 32, 64)
    self.contents = Bitmap.new(width - 32, height - 32)
    self.contents.font.size = FUKI::MES_FONT_SIZE
    self.z += 9999
    self.opacity = 0
    @index = 0
    refresh
    update_cursor_rect
  end
end

#===========================================================================
# Game_Map，把events变量公开
#===========================================================================
class Game_Map
  attr_reader   :events
end

#===========================================================================
# 便于返回姓名
#===========================================================================
class Game_Event < Game_Character
  def name
    return @event.name
  end
  def name=(na)
    @event.name = na
  end
end

#===========================================================================
# 增加变量$active_event_id，用于在“本事件”显示对话
#===========================================================================
class Interpreter
 #--------------------------------------------------------------------------
 # ● 设置事件
 #     event_id : 事件 ID
 #--------------------------------------------------------------------------
 alias setup_fuki setup
 def setup(list, event_id)
   setup_fuki(list, event_id)
   # 如果不是战斗中
   if !($game_temp.in_battle)
     # 记录事件 ID
     $active_event_id = event_id
   end
 end
end