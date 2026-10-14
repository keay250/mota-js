#==============================================================================
# ■ Window_Base
#------------------------------------------------------------------------------
# 　游戏中全部窗口的超级类。
#==============================================================================

class Window_Base < Window
#--------------------------------------------------------------------------
  # ● 获取行高
  #--------------------------------------------------------------------------
  def line_height
    return 24
  end
  #--------------------------------------------------------------------------
  # ● 获取标准的边距尺寸
  #--------------------------------------------------------------------------
  def standard_padding
    return 12
  end
  #--------------------------------------------------------------------------
  # ● 获取文字颜色
  #     n : 文字颜色编号（0..31）
  #--------------------------------------------------------------------------
  def get_color(n)
    @secskin.get_pixel(64 + (n % 8) * 8, 96 + (n / 8) * 8)
  end
  def change_color(color)
    contents.font.color=color
  end
  #--------------------------------------------------------------------------
  # ● 获取各种文字颜色
  #--------------------------------------------------------------------------
  def crisis_color;      get_color(17);  end;    # 危险
  def knockout_color;    get_color(18);  end;    # 无法战斗
  def gauge_back_color;  get_color(19);  end;    # 值槽背景
  def hp_gauge_color1;   get_color(20);  end;    # HP 值槽 1
  def hp_gauge_color2;   get_color(21);  end;    # HP 值槽 2
  def mp_gauge_color1;   get_color(22);  end;    # MP 值槽 1
  def mp_gauge_color2;   get_color(23);  end;    # MP 值槽 2
  def mp_cost_color;     get_color(23);  end;    # 消费 TP
  def power_up_color;    get_color(24);  end;    # 能力值提升（更换装备时）
  def power_down_color;  get_color(25);  end;    # 能力值降低（更换装备时）
  def tp_gauge_color1;   get_color(28);  end;    # TP 值槽 1
  def tp_gauge_color2;   get_color(29);  end;    # TP 值槽 2
  def tp_cost_color;     get_color(29);  end;    # 消费 TP
  #--------------------------------------------------------------------------
  # ● 绘制值槽
  #     rate   : 比率（1.0 为满值）
  #     color1 : 渐变色的左端
  #     color2 : 渐变色的右端
  #--------------------------------------------------------------------------
  def draw_gauge(x, y, width, rate, color1, color2,f)
    fill_w = (width * rate).to_i
    gauge_y = y + line_height - 28
    contents.fill_rect(x, gauge_y, width, 18, gauge_back_color)
    a=[color1.red,color1.blue,color1.green,color2.red,color2.blue,color2.green]
    for i in 0...3
      a[i]=(a[i+3]-a[i]).to_f/f
    end
    ol=width/f.to_f
  #  for i in 0...18
  #    contents.fill_rect(x, gauge_y+i, fill_w, 1, color1)
    for i in 0...f
      l=ol
      break if i*ol>=fill_w
      if (i+1)*ol>fill_w && i*ol<fill_w
        l=ol-((i+1)*ol-fill_w)
      end
      contents.fill_rect(x+i*ol, gauge_y, l, 18, color1)
      color1.red+=a[0]
      color1.blue+=a[1]
      color1.green+=a[2]
    end
  end
  #--------------------------------------------------------------------------
  # ● 绘制图标
  #     enabled : 有效的标志。false 的时候使用半透明效果绘制
  #--------------------------------------------------------------------------
  def draw_icon(icon_index, x, y, enabled = true)
    bitmap = Cache.system("Iconset")
    rect = Rect.new(icon_index % 16 * 24, icon_index / 16 * 24, 24, 24)
    self.contents.blt(x, y, bitmap, rect, enabled ? 255 : translucent_alpha)
  end
  #--------------------------------------------------------------------------
  # ● 绘制角色肖像图
  #     enabled : 有效的标志。false 的时候使用半透明效果绘制
  #--------------------------------------------------------------------------
  def draw_face(face_name, face_index, x, y, enabled = true)
    bitmap = Cache.face(face_name)
    rect = Rect.new(face_index % 4 * 96, face_index / 4 * 96, 96, 96)
    self.contents.blt(x, y, bitmap, rect, enabled ? 255 : translucent_alpha)
    bitmap.dispose
  end
  #--------------------------------------------------------------------------
  # ● 绘制人物行走图
  #--------------------------------------------------------------------------
  def draw_character(character_name, character_index, x, y)
    return unless character_name
    bitmap = Cache.character(character_name)
    sign = character_name[/^[\!\$]./]
    if sign && sign.include?('$')
      cw = bitmap.width / 3
      ch = bitmap.height / 4
    else
      cw = bitmap.width / 12
      ch = bitmap.height / 8
    end
    n = character_index
    src_rect = Rect.new((n%4*3+1)*cw, (n/4*4)*ch, cw, ch)
    self.contents.blt(x - cw / 2, y - ch, bitmap, src_rect)
  end
  #--------------------------------------------------------------------------
  # ● 获取 MP 的文字颜色
  #--------------------------------------------------------------------------
  def mp_color(actor)
    return crisis_color if actor.mp < actor.mmp / 4
    return normal_color
  end
  #--------------------------------------------------------------------------
  # ● 获取 TP 的文字颜色
  #--------------------------------------------------------------------------
  def tp_color(actor)
    return normal_color
  end
  #--------------------------------------------------------------------------
  # ● 绘制角色肖像图
  #--------------------------------------------------------------------------
  def draw_actor_face(actor, x, y, enabled = true)
    draw_face(actor.face_name, actor.face_index, x, y, enabled)
  end
  #--------------------------------------------------------------------------
  # ● 绘制职业
  #--------------------------------------------------------------------------
  def draw_actor_class(actor, x, y, width = 112)
    change_color(normal_color)
    self.contents.draw_text(x, y, width, line_height, actor.class.name)
  end
  #--------------------------------------------------------------------------
  # ● 绘制称号
  #--------------------------------------------------------------------------
  def draw_actor_nickname(actor, x, y, width = 180)
    change_color(normal_color)
    self.contents.draw_text(x, y, width, line_height, actor.nickname)
  end
  #--------------------------------------------------------------------------
  # ● 绘制强化／弱化状态的图标
  #--------------------------------------------------------------------------
  def draw_actor_icons(actor, x, y, width = 96)
    icons = (actor.state_icons + actor.buff_icons)[0, width / 24]
    icons.each_with_index {|n, i| draw_icon(n, x + 24 * i, y) }
  end
  #--------------------------------------------------------------------------
  # ● 以 当前值／最大值 这样的分数形式绘制当前值和最大值
  #     current : 当前值
  #     max     : 最大值
  #     color1  : 当前值的颜色
  #     color2  : 最大值的颜色
  #--------------------------------------------------------------------------
  def draw_current_and_max_values(x, y, width, current, max, color1, color2)
    change_color(color1)
    xr = x + width
    if width < 96
      self.contents.draw_text(xr - 140, y, 142, line_height, current, 2)
    else
      self.contents.draw_text(xr - 210, y, 142, line_height, current, 2)
      change_color(color2)
      self.contents.draw_text(xr - 200, y, 142, line_height, "/", 2)
      self.contents.draw_text(xr - 142, y, 142, line_height, max, 2)
    end
  end
  def draw_current_and_rate(x, y, width, current, max, color1, color2)
    rate=current*100.0/max
    current=sprintf("%.1f",rate)+"%"
    change_color(color1)
    xr = x + width
    if width < 96
      self.contents.draw_text(xr - 140, y, 142, line_height, current, 2)
    else
      self.contents.draw_text(xr - 182, y, 142, line_height, current, 2)
      change_color(color2)
      self.contents.draw_text(xr - 170, y, 142, line_height, "/", 2)
      self.contents.draw_text(xr - 124, y, 142, line_height, "100%", 2)
    end
  end
  def draw_text_ex(x,y,w,h,text,color,mode=0)
    self.contents.font.color=gauge_back_color
    self.contents.draw_text(x-1,y,w,h,text,mode)
    self.contents.draw_text(x+1,y,w,h,text,mode)
    self.contents.draw_text(x,y-1,w,h,text,mode)
    self.contents.draw_text(x,y+1,w,h,text,mode)
    self.contents.font.color = color
    self.contents.draw_text(x,y,w,h,text,mode)
  end
  #--------------------------------------------------------------------------
  # ● 绘制 MP 
  #--------------------------------------------------------------------------
  def draw_actor_mp(actor, x, y, width = 124)
    draw_gauge(x-20, y, width+20, actor.mp_rate, mp_gauge_color1, mp_gauge_color2)
    change_color(system_color)
    self.contents.draw_text(x-20, y, 50, line_height, Vocab::mp_a)
    draw_current_and_max_values(x, y, width, actor.mp, actor.mmp,
      mp_color(actor), normal_color)
  end
  #--------------------------------------------------------------------------
  # ● 绘制 TP 
  #--------------------------------------------------------------------------
  def draw_actor_tp(actor, x, y, width = 124)
    draw_gauge(x, y, width, actor.tp_rate, tp_gauge_color1, tp_gauge_color2)
    change_color(system_color)
    self.contents.draw_text(x, y, 30, line_height, Vocab::tp_a)
    change_color(tp_color(actor))
    self.contents.draw_text(x + width - 42, y, 42, line_height, actor.tp.to_i, 2)
  end
  #--------------------------------------------------------------------------
  # ● 绘制简单的状态
  #--------------------------------------------------------------------------
  def draw_actor_simple_status(actor, x, y)
    draw_actor_name(actor, x, y)
    draw_actor_level(actor, x, y + line_height * 1)
   # draw_actor_icons(actor, x, y + line_height * 2)
    draw_actor_class(actor, x + 150, y)
    draw_actor_hp(actor, x + 130, y + line_height * 1)
    draw_actor_param(actor,x, y + line_height * 2, 2,-80)
    draw_actor_param(actor,x+90, y + line_height * 2, 3,-80)
    draw_actor_param(actor,x+180, y + line_height * 2, 7,-80)
  end
  #--------------------------------------------------------------------------
  # ● 绘制能力值
  #--------------------------------------------------------------------------
  def draw_actor_param(actor, x, y, param_id,newdis=0)
    change_color(system_color)
    self.contents.draw_text(x, y, 120, line_height, Vocab::param(param_id))
    change_color(normal_color)
    self.contents.draw_text(x + 120+newdis, y, 36, line_height, actor.param(param_id), 2)
  end
  #--------------------------------------------------------------------------
  # ● 绘制物品名称
  #     enabled : 有效的标志。false 的时候使用半透明效果绘制
  #--------------------------------------------------------------------------
  def draw_item_name(item, x, y, enabled = true, width = 192)
    return unless item
    draw_icon(item.icon_index, x, y, enabled)
    change_color(normal_color, enabled)
    self.contents.draw_text(x + 24, y, width, line_height, item.name)
  end
  #--------------------------------------------------------------------------
  # ● 绘制货币数值（持有金钱之类的）
  #--------------------------------------------------------------------------
  def draw_currency_value(value, unit, x, y, width)
    cx = text_size(unit).width
    change_color(normal_color)
    self.contents.draw_text(x, y, width - cx - 2, line_height, value, 2)
    change_color(system_color)
    self.contents.draw_text(x, y, width, line_height, unit, 2)
  end
  #--------------------------------------------------------------------------
  # ● 获取能力值变化的绘制色
  #--------------------------------------------------------------------------
  def param_change_color(change)
    return power_up_color   if change > 0
    return power_down_color if change < 0
    return normal_color
  end
end