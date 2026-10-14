#==============================================================================
# ■ Window_Command
#------------------------------------------------------------------------------
# 　一般的命令选择行窗口。
#==============================================================================

class Window_Command < Window_Selectable
  #--------------------------------------------------------------------------
  # ● 初始化对像
  #     width    : 窗口的宽
  #     commands : 命令字符串序列
  #--------------------------------------------------------------------------
  def initialize(width, commands , column_max=1 , align = 0)
    # 由命令的个数计算出窗口的高
    super(0, 0, width -32 + column_max*32, (commands.size-column_max%2+1) * 32 / column_max + 32)
    @column_max=column_max
    @item_max = commands.size
    @commands = commands
    @align = align
    self.contents = Bitmap.new(width -64 + column_max*32, (commands.size-column_max%2+1) * 32 / column_max)
    refresh
    self.index = 0
  end
  #--------------------------------------------------------------------------
  # ● 刷新
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    for i in 0...@item_max
      draw_item(i, normal_color)
    end
  end
  #--------------------------------------------------------------------------
  # ● 描绘项目
  #     index : 项目编号
  #     color : 文字色
  #--------------------------------------------------------------------------
  def draw_item(index, color)
    a=index / ((@item_max+1) / @column_max)
    b=index % ((@item_max+1) / @column_max)
    self.contents.font.color = color
    rect = Rect.new(4 + a * (self.width / @column_max), 32 * b, self.contents.width - 8, 32)
    self.contents.fill_rect(rect, Color.new(0, 0, 0, 0))
    self.contents.draw_text(rect, @commands[index],@align)
  end
  #--------------------------------------------------------------------------
  # ● 项目无效化
  #     index : 项目编号
  #--------------------------------------------------------------------------
  def disable_item(index)
    draw_item(index, disabled_color)
  end
  def set_commands(commands)
    @commands=commands
  end
end