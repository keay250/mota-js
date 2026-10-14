#==============================================================================
# ■ 多选项脚本
#------------------------------------------------------------------------------
#    v 1.0 by enghao_lim
#    理论性无限突破四个选项的脚本
#------------------------------------------------------------------------------
#
# 使用方法：
# 
#  1. 在事件里使用【脚本】：多选项(选项数组,取消时执行的选项)
#     
# 	选项数组例子：@c = ["选项一","选项二"..."选项100"]
# 	所有选项必须是文字，即被 "" 符包括。
# 	
# 	取消时执行的选项：代表 ESC （也就是B键） 按下时执行的选项
# 	不填写 或 为0 时，代表选项不可被取消。
# 	此值不可大过选项的数量，否者会出错。
# 	
#  2. 使用条件分歧：选项场合(选项编号）来执行选中选项后执行的事件。
#     具体请看范例。
# 
#  3. for 脚本党：
#     获取 被选中的选项 的 index ：$game_temp.choice_result
# 	
#  4. 范例里已经有各种 多选项 的利用方法，自个儿都觉得多选项也挺好用的。
#  
#  5. 如有神马 bug ，请通知我，谢谢，感谢阅读。
#
#==============================================================================

#==============================================================================
# ■ Game_Temp
#------------------------------------------------------------------------------
# 　临时资料记录器。
#==============================================================================
class Game_Temp
  #--------------------------------------------------------------------------
  # ● 读写器
  #--------------------------------------------------------------------------
  attr_accessor :choice_result
  attr_accessor :choice_last
  #--------------------------------------------------------------------------
  # ● 初始化
  #--------------------------------------------------------------------------
  alias initialize0 initialize
  def initialize
    initialize0
    @choice_result = -1
    @choice_last = -1
  end
end

#==============================================================================
# ■ Interpreter
#------------------------------------------------------------------------------
# 　事件处理器。
#==============================================================================
class Interpreter
  #--------------------------------------------------------------------------
  # ● 多选项
  #--------------------------------------------------------------------------
  def Newchoice(choice,mode =0, cancel = 0)
    cancel = cancel == "取消" ? choice.size + 1 : cancel
    MultiChoice(choice,mode,cancel)
  end
  #--------------------------------------------------------------------------
  # ● 获取选择的选项
  #--------------------------------------------------------------------------
  def Cresult(n)
    if n == "取消"
      return ($game_temp.choice_last + 1) == $game_temp.choice_result
    end
    return $game_temp.choice_result == (n - 1)
  end
  #--------------------------------------------------------------------------
  # ● 多选项执行
  #--------------------------------------------------------------------------
  def MultiChoice(choice,mode = 0,cancel = 0)
    # 设置信息结束后待机和返回调用标志
    @message_waiting = true
    $game_temp.message_proc = Proc.new { @message_waiting = false }
    # 设置选项设置
    $game_temp.choice_max = choice.size
    $game_temp.choice_last = choice.size - 1
    $game_temp.choice_cancel_type = cancel
    $game_temp.choice_start = 0
    $game_temp.message_text = ""
    $new_choice=choice
    $new_choice_mode=mode
    if mode==1
      $game_temp.message_text+="小站：\n请选择传送目标地点\n"
      $game_temp.choice_start=2
    end
    if mode==2
      $game_temp.message_text+=$game_map.events[$game_system.map_interpreter.get_event_id].name+"：\n请选择任务\n"
      $game_temp.choice_start=2
    end
    if mode==3
      $game_temp.message_text+=$game_map.events[$game_system.map_interpreter.get_event_id].name+"：\n根据你的身份，可以使用军功兑换如下事物\n"
      $game_temp.choice_start=2
    end
    $game_temp.choice_proc = Proc.new { |n| $game_temp.choice_result = n }
    # 设置选择选项
    for c in choice
      $game_temp.message_text += c + "\n"
    end
  end
  
end

#==============================================================================
# ■ Window_Message
#------------------------------------------------------------------------------
# 　对话框。
#==============================================================================
class Window_Message < Window_Selectable
  #--------------------------------------------------------------------------
  # ● 重置窗口
  #--------------------------------------------------------------------------
  alias reset_window_0 reset_window
  def reset_window(width = nil, height = nil)
    if $game_system.message_frame == 0
      self.opacity = 255
    else
      self.opacity = 0
    end
    
    self.back_opacity = FUKI::MES_OPACITY
    if $game_temp.choice_max <=4
     # @item_max=4
      reset_window_0(width, height)
    else
      # 还原 ox 和 oy
      self.ox = self.oy = 0
      # 重新生成 bitmap
      self.contents.dispose
      self.contents = Bitmap.new(self.width-32,[$game_temp.choice_max,1].max*32)
    end
    if $game_system.message_frame == 1
   #   self.contents.fill_rect(Rect.new(0,0,self.contents.width,self.contents.height),Color.new(0,0,0,125))
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新光标矩形
  #--------------------------------------------------------------------------
  alias update_cursor_rect_0 update_cursor_rect
  def update_cursor_rect
    if $game_temp.choice_max <=4
      update_cursor_rect_0
    else
      if @save_index !=@index && @index >= 0
        mid=@item_max/2
        if @save_index==@item_max-1 && @index==0
          @start_index=0
        elsif @save_index==0 && @index==@item_max-1
          @start_index=$game_temp.choice_max-@item_max
        else
          a=@start_index
          @start_index=[[@index+@start_index-mid,$game_temp.choice_max-@item_max].min,0].max
          @index=@index+a-@start_index
        end
        @save_index=@index
        if @start_index != a
          $game_temp.message_text = ""
          if $new_choice_mode==1
            $game_temp.message_text+="请选择传送目标地点\n"
          end
          if $new_choice_mode==2
            $game_temp.message_text+="请选择任务\n"
          end
          if $new_choice_mode==3
            $game_temp.message_text+="根据你的身份，可以使用军功兑换如下事物\n"
          end
          for i in @start_index...$new_choice.size
            $game_temp.message_text += $new_choice[i] + "\n"
          end
          for i in 1...@start_index
            $game_temp.message_text += $new_choice[i] + "\n"
          end
          self.contents.clear
          @dx = @dy = 0
          @cursor_width = 0
          while $game_temp.message_text != ""
            draw_massage
          end
        end
      end
      if @index >= 0
        n = $game_temp.choice_start + @index -1
        self.cursor_rect.set(8, n * 32, @cursor_width, 32)
      else
        self.cursor_rect.empty
      end
    end
  end
  def get_now_start
  end
end