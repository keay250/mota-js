#==============================================================================
# ■ Window_Flytofloor
#------------------------------------------------------------------------------
# 　楼层转换窗口
#==============================================================================

class Window_Flytofloor < Window_Selectable
  #--------------------------------------------------------------------------
  # ● 初始化对像
  #--------------------------------------------------------------------------
  def initialize
    super(0, 64, 640, 416)
    @column_max = 4
    self.index = 0
    refresh
    # 战斗中的情况下将窗口移至中央并将其半透明化
    if $game_temp.in_battle
      self.y = 64
      self.height = 256
      self.back_opacity = 160
    end
  end
  #--------------------------------------------------------------------------
  # ● 获取物品
  #--------------------------------------------------------------------------
  def item
    return @data[self.index]
  end
  #--------------------------------------------------------------------------
  # ● 刷新
  #--------------------------------------------------------------------------
  def refresh
    if self.contents != nil
      self.contents.dispose
      self.contents = nil
    end
    @data = []
    # 添加物品
    h = -1
    for i in 0...$game_variables[18][$game_variables[3]].size
      k = $game_variables[18][$game_variables[3]][i]
      if !@data.include?(k)
        h += 1
        self.index = h if $game_variables[2] == k
        @data.push(k)
      end
    end
    # 如果项目数不是 0 就生成位图、重新描绘全部项目
    @item_max = @data.size
    if @item_max > 0
      self.contents = Bitmap.new(width - 32, row_max * 32)
      for i in 0...@item_max
        draw_item(i)
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 描绘项目
  #     index : 项目编号
  #--------------------------------------------------------------------------
  def draw_item(index)
    item = @data[index]
    x = 4 + index % 4 * (128 + 32)
    y = index / 4 * 32
    rect = Rect.new(x, y, self.width / @column_max - 32, 32)
    self.contents.fill_rect(rect, Color.new(0, 0, 0, 0))
    bitmap = RPG::Cache.picture($game_variables[3].to_s)
    src_rect = Rect.new(0, 0, bitmap.width, bitmap.height)
    self.contents.blt(x, y, bitmap, src_rect)
    self.contents.draw_text(x + 32, y, 160, 32, "第"+item.to_s+"层", 0)
  end
  #--------------------------------------------------------------------------
  # ● 刷新帮助文本
  #--------------------------------------------------------------------------
  def update_help
    @help_window.set_text("请选择你要到达的楼层。")
  end
end
