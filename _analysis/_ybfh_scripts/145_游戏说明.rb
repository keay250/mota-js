class Scene_GameHelp
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
    # 生成任务内容窗口
    @list=["游戏简介","基本属性","战斗流程","技能施放","特殊技能","伤害类型",
    "装备效果","进阶属性","英雄三围","先手判定","游戏技巧"]
    @name_window = Window_GameHelpName.new(@list)
    @name_window.active=true
    @help_window = Window_GameHelp.new
    @help_window.active = true
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
    @name_window.dispose
    @help_window.dispose
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面
  #--------------------------------------------------------------------------
  def update
    # 刷新窗口
    @name_window.update
    @help_window.update
    update_task_names_window
  end
  #--------------------------------------------------------------------------
  # ● 刷新任务名称窗口
  #--------------------------------------------------------------------------
  def update_task_names_window
    # 按下 B 键的情况下
    if @save_index != @name_window.index
      @save_index = @name_window.index
      @help_window.set_text(@list[@name_window.index])
    end
    if Input.trigger?(Input::B)
      # 演奏取消 SE
      $game_system.se_play($data_system.cancel_se)
      $scene = Scene_Menu.new
      return
    end
    
  end
end

#==============================================================================
# ■ Window_HelpName
#------------------------------------------------------------------------------
# 　任务名称显示窗口。
#==============================================================================

class Window_GameHelpName < Window_Selectable
  #--------------------------------------------------------------------------
  # ● 初始化对像
  #--------------------------------------------------------------------------
  def initialize(item)
    super(0, 0, 240, 480)
    @items=item
    @item_max = @items.size
    self.contents = Bitmap.new(
    self.width - 32, @item_max == 0 ? 32 : @item_max * 32+32)
    refresh
    self.index = 0
  end
  #--------------------------------------------------------------------------
  # ● 刷新
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    for q in @items
      draw_item(q)
    end
 #   self.contents.font.color = system_color
 #   self.contents.draw_text(4, @items.size*32, self.contents.width - 8, 32, '按确定键翻页')
  end
  #--------------------------------------------------------------------------
  # ● 描绘项目
  #--------------------------------------------------------------------------
  def draw_item(item)
    text = item.clone
    x = 0
    y = @items.index(item) * 32
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
    # "\\C" 变为 "\001" 
    text.gsub!(/\\[Cc]\[([0-9]+)\]/) { "\001[#{$1}]" }
    # "\I" 变为 "\002" 
    text.gsub!(/\\[Ii]/) { "\002" }
    # "\P" 变为 "\003" 
    text.gsub!(/\\[Pp]/) { "\003" }
    # c 获取 1 个字 (如果不能取得文字就循环)
    while ((c = text.slice!(/./m)) != nil)
      # \\ 的情况下
      if c == "\000"
        # 还原为本来的文字
        c = "\\"
      end
      # \C[n] 的情况下
      if c == "\001"
        # 更改文字色
        text.sub!(/\[([0-9]+)\]/, "")
        color = $1.to_i
        if color >= 0 and color <= 7
          self.contents.font.color = text_color(color)
        elsif color == 8
          self.contents.font.color = disabled_color
        elsif color == 9
          self.contents.font.color = system_color
        end
        # 下面的文字
        next
      end
      # 图标的情况下
      if c == "\002"
        icon_name = ''
        while ((cha = text.slice!(/./m)) != ']')
          next if cha == '['
          icon_name += cha
        end
        icon = RPG::Cache.icon(icon_name)
        if x + icon.width > self.contents.width
          x = 0
          y += [32, min_y].max
          min_y = 0
        end
        self.contents.blt(x + 4, y + 4, icon, Rect.new(0, 0, 24, 24))
        x += 28
        next
      end
      # 图片的情况下
      if c == "\003"
        pic_name = ''
        while ((cha = text.slice!(/./m)) != ']')
          next if cha == '['
          pic_name += cha
        end
        pic = RPG::Cache.picture(pic_name)
        if x + pic.width > self.contents.width
          x = 0
          y += [32, min_y].max
          min_y = 0
        end
        self.contents.blt(x + 4, y, pic, Rect.new(0, 0, pic.width, pic.height))
        x += pic.width
        next
      end
      # 描绘文字
      self.contents.draw_text(54 + x, y, 40, 32, c)
      # x 为要描绘文字的加法运算
      x += self.contents.text_size(c).width
    end
  end
  #--------------------------------------------------------------------------
  # ● 获取任务
  #--------------------------------------------------------------------------
  def item
    return @items[self.index]
  end
end

class Window_GameHelp < Window_Base
  #--------------------------------------------------------------------------
  # ● 初始化对像
  #--------------------------------------------------------------------------
  def initialize
    super(240, 0, 400,480)
    self.contents = Bitmap.new(1,1)
  end
  #--------------------------------------------------------------------------
  # ● 设置文本
  #     text  : 窗口显示的字符串
  #     align : 对齐方式 (0..左对齐、1..中间对齐、2..右对齐)
  #--------------------------------------------------------------------------
  def set_text(text, align = 0)
    # 如果文本和对齐方式的至少一方与上次的不同
    if text != @text or align != @align
      # 再描绘文本
      self.contents.clear
      if text !=""
        self.contents.font.color = normal_color
        self.contents.font.size=16
        self.contents.clear
        self.contents = Bitmap.new(400-32,480-32)
      #  self.contents.draw_text(4, 0, self.width - 40, 32, text, align)
        line=0
        a=text
        ma=TextStream.new
        if ma.open("Info/Help/"+a)
          linel=0
          maxlinel=0
          loop do
            maxlinel=self.contents.font.size
            s=ma.get_text(1).split("\n")[0]
            s=s[3,s.size-3] if line==0
            if s=="\\~\\/[END]"
              break
            end
            pos=0
            posl=0
            case align
            when 0
              stpos=0
            when 2
              ss=s+""
              ss.gsub!(/\[([0-9]+)\]/, "")
              ss.gsub!(/\\([A-Z])/, "")
              stpos=174+176-self.contents.text_size(ss[0,ss.size]).width
            end
            loop do
              break if s==nil
              while s[pos,1]=="\\"
                kind=s[pos+1,1]
                s=s[0,pos]+s[pos+2,s.size-pos-2]
                num=s.sub!(/\[([0-9]+)\]/, "")
                case kind
                when "C"
                  self.contents.font.color = text_color($1.to_i)
                when "S"
                  self.contents.font.size=$1.to_i
                when "A"
                  align=$1.to_i
                  case align
                  when 0
                    stpos=0
                  when 2
                    ss=s+""
                    ss.gsub!(/\[([0-9]+)\]/, "")
                    ss.gsub!(/\\([A-Z])/, "")
                    stpos=189+176-self.contents.text_size(ss[0,ss.size]).width
                  end
                when "N"
                  posl=0
                  line+=1
                  linel+=maxlinel
                end
              end
              if s[pos]!=nil
                if s[pos]<128
                  self.contents.draw_text(posl+stpos,linel, self.contents.font.size,self.contents.font.size, s[pos,1], align)
                  posl+=self.contents.text_size(s[pos,1]).width
                  if self.contents.text_size(s[pos,1]).height>maxlinel
                    maxlinel=self.contents.text_size(s[pos,1]).height
                  end
                  pos+=1
                else
                  self.contents.draw_text(posl+stpos,linel, self.contents.font.size,self.contents.font.size, s[pos,3], align)
                  posl+=self.contents.text_size(s[pos,3]).width
                  if self.contents.text_size(s[pos,3]).height>maxlinel
                    maxlinel=self.contents.text_size(s[pos,3]).height
                  end
                  pos+=3
                end
              else
                pos+=1
              end
              if s[pos,2]!="\\N" && posl>180+176
                posl=0
                line+=1
                linel+=maxlinel
              end
              break if pos>s.size
            end
            line+=1
            linel+=maxlinel
          end

        end
      end
      @text = text
      @align = align
      @actor = nil
    end
    self.visible = true
  end
end
