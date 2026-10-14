#==============================================================================
# ■ Find_Path
#------------------------------------------------------------------------------
# 　寻路算法--完整鼠标系统（四方向）专用版
#   By whbm
#============================================================================== 
class Find_Path
#--------------------------------------------------------------------------
def initialize  #初始化
 @open_list = []
 @close_lise = []
 @path = []
end  #结束初始化
#--------------------------------------------------------------------------
def fp_passable?(x, y, d, tr_x = -2, tr_y = -2)  #开始判定通行
 #return false if (tr_x == @unable_xa or
  #               tr_x == @unable_xb or
   #              tr_y == @unable_ya or
    #             tr_y == @unable_yb)
  if [2, 4, 6, 8].include?(d)
    case @type
    when 0 #常规寻路
      if $game_player.passable?(x, y, d ,1)
        return true
      else
        return false
      end
    when 1 #警戒怪使用
      xx=x
      yy=y
      x = $game_map.x_with_direction(x, d)
      y = $game_map.y_with_direction(y, d)
      return ter_passabel?(xx,yy,x,y,d)
    when 2 #至死方休怪使用
      xx=x
      yy=y
      x = $game_map.x_with_direction(x, d)
      y = $game_map.y_with_direction(y, d)
      return false if !ter_passabel?(xx,yy,x,y,d)
      id=$game_map.check_event(x, y)
      if id !=0
        ev=$game_map.events[id]
        name=ev.event.name
        if name=="路障"
          return false
        end
        if name[3,3]=="门" || name[6,3]=="门"
          return false if !$game_self_switches[[$game_map.map_id,id,"A"]]
        end
      end
      return true
    end
 end
end  #结束判定通行
#--------------------------------------------------------------------------
def ter_passabel?(xx,yy,x,y,d) #地形通行判断
  return false if !$game_map.valid?(x, y)
  sw=true
  bit = (1 << (( 10 - d ) / 2 - 1)) & 0x0f
  for k in [2, 1,0]
    tile_id = $game_map.data[x, y, k]
    if tile_id == nil
      sw=false
    elsif $game_map.passages[tile_id] & bit != 0
      sw=false
    elsif $game_map.passages[tile_id] & 0x0f == 0x0f
      sw=false
    elsif $game_map.priorities[tile_id] == 0
      break
    end
  end
  bit = (1 << ( d / 2 - 1)) & 0x0f
  for k in [2, 1,0]
    tile_id = $game_map.data[xx, yy, k]
    if tile_id == nil
      sw=false
    elsif $game_map.passages[tile_id] & bit != 0
      sw=false
    elsif $game_map.passages[tile_id] & 0x0f == 0x0f
      sw=false
    elsif $game_map.priorities[tile_id] == 0
      break
    end
  end
  if $game_variables[211][[x,y]]==1
    sw=false
  end
  return sw
end
#--------------------------------------------------------------------------
def get_g(now_point)  #开始计算G值
 d = now_point[2]
 return 0 if d == 5
 father_point = get_father_point(now_point)
 g = father_point[3] + 10
 return g
end  #结束计算G值
#--------------------------------------------------------------------------
def get_h(now_point)  #开始计算H值
 now_x = now_point[0]
 now_y = now_point[1]
 #print @trg_x,now_x,@trg_y,now_y
 h = (@trg_x - now_x).abs + (@trg_y - now_y).abs
 return h * 10
end  #结束计算H值
#--------------------------------------------------------------------------
def get_f(now_point)  #开始计算F值
 f = now_point[3] + now_point[4]
 return f
end  #结束计算F值
#--------------------------------------------------------------------------
def get_point(x, y) #取已知坐标点
 if @open_list.size != 0
   @open_list.each do |point|
     if point[0] == x and point[1] == y
       return point
       break
     end
   end
 end
 if @close_list.size != 0
   @close_list.each do |point|
     if point[0] == x and point[1] == y
       return point
       break
     end
   end
 
 end
end  #结束取已知坐标点
#--------------------------------------------------------------------------
def get_father_point(now_point)  #取已知点的父节点
 d = now_point[2]
 return now_point if d == 5
 x = now_point[0] + (d == 6 ? 1 : (d == 4 ? -1 : 0))
 y = now_point[1] + (d == 2 ? 1 : (d == 8 ? -1 : 0))
   return get_point(x, y)
end  #结束取已知点的父节点
#--------------------------------------------------------------------------
def new_point(x, y, d)  #开始建立新节点
 point = [x, y, d]
 point.push get_g(point)
 point.push get_h(point)
 point.push get_f(point)
 return point
end  #结束建立新节点
#--------------------------------------------------------------------------
def get_direction(self_x, self_y, trg_x, trg_y)
  if trg_x > self_x
    if trg_y - self_y > -  ( trg_x - self_x ) and
      trg_y - self_y < ( trg_x - self_x )
      return 6
    end
    if trg_y - self_y > ( trg_x - self_x )
      return 2
    end
    if trg_y - self_y < - ( trg_x - self_x )
      return 8
    end
  end
  if trg_x < self_x
    if trg_y - self_y > - ( self_x - trg_x ) and
      trg_y - self_y < ( self_x - trg_x )
      return 4
    end
    if trg_y - self_y > ( self_x - trg_x )
      return 2
    end
    if trg_y - self_y < - ( self_x - trg_x )
      return 8
    end
  end
end
#--------------------------------------------------------------------------
def get_d_x_y(x, y, d)
  d_x = x + (d == 6 ? 1 : (d == 4 ? -1 : 0))
  d_y = y + (d == 2 ? 1 : (d == 8 ? -1 : 0))
  return d_x, d_y
end
#--------------------------------------------------------------------------
def find_short_path_other(self_x, self_y, trg_x, trg_y, 
                          real_self_x, real_self_y, real_trg_x, real_trg_y)
  @self_x = self_x
  @self_y = self_y
  @now_x = self_x
  @now_y = self_y
  @trg_x = trg_x
  @trg_y = trg_y
  @path = []
  direction = get_direction(self_x, self_y, trg_x, trg_y)#(real_self_x, real_self_y, real_trg_x, real_trg_y)
  @now_trg_x, @now_trg_y = get_d_x_y(@self_x, @self_y, direction)
  while fp_passable?(@now_x, @now_y, direction)
      @path.push direction
      @now_x = @now_trg_x
      @now_y = @now_trg_y
      @now_trg_x, @now_trg_y = get_d_x_y(@now_x, @now_y, direction)
  end
  return @path
end
#--------------------------------------------------------------------------
def find_short_path(self_x, self_y, trg_x, trg_y,
                    type=0)  #开始搜索路径
  
# return find_short_path_other(self_x, self_y, trg_x, trg_y, 
 #                             real_self_x, real_self_y, real_trg_x, real_trg_y) if not
  #                (fp_passable?(trg_x, trg_y + 1, 8) or
   #                fp_passable?(trg_x + 1, trg_y, 4) or
    #               fp_passable?(trg_x - 1, trg_y, 6) or
     #              fp_passable?(trg_x, trg_y - 1, 2)) and @goal_type != 1
                   
                   
  #根据屏幕限定搜索面积..加速
 @unable_xa = $game_map.display_x / 128 - 1
 @unable_ya = $game_map.display_y / 128 - 1
 @unable_xb = $game_map.display_x / 128 + 20
 @unable_yb = $game_map.display_y / 128 + 20
 
 
 @self_x = self_x
 @self_y = self_y
 @now_x = self_x
 @now_y = self_y
 @trg_x = trg_x
 @trg_y = trg_y
 @type = type
 @open_list = []
 @close_list = []
 #准备搜索
 #print @self_x,@self_y
 @now_point = new_point(@self_x, @self_y, 5) #令起始点为当前点
 @open_list.push @now_point #将当前点加入关闭列表
 #开始搜索
 begin
 loop do
   check_trg = check_around_point(@now_point)
   if check_trg == true
     @path = get_path     
     break
   end
   @now_point = get_lowest_f_point
   if @now_point == [] or @now_point == nil
     @path = []
     break
   end
 end
rescue Hangup
  retry
 end
 return @path
end  #结束搜索路径
#--------------------------------------------------------------------------
def find_player_short_path(trg_x, trg_y,
                           real_trg_x, real_trg_y)  #寻找角色的最短路径
 self_x = $game_player.x
 self_y = $game_player.y
 real_self_x = $game_player.screen_x
 real_self_y = $game_player.screen_y
 @goal_type, event = $game_map.check_event_custom_exist(real_trg_x, real_trg_y)
 if @goal_type == 1
   trg_x = event.x
   trg_y = event.y
 end
 return find_short_path(self_x, self_y, trg_x, trg_y, 
                        real_self_x, real_self_y, real_trg_x, real_trg_y)
end  #结束角色的寻找路径
#--------------------------------------------------------------------------
def get_path  #取得最终的路径
 path = []
 now_point = @open_list[@open_list.size - 1]
 path.push(10 - now_point[2])
 last_point = now_point
 loop do
   now_point = get_father_point(now_point)
   break if now_point[2] == 5
   path.push(10 - now_point[2])
 end
 return path.reverse
end  #结束取得最终的路径
#--------------------------------------------------------------------------
def get_lowest_f_point  #开始取得最低F值的点
 if @open_list == []
   return []
 end
 last_lowest_f_point = @open_list[0]
 @open_list.each do |point|
   last_lowest_f_point = point if point[5] < last_lowest_f_point[5]
 end
 return last_lowest_f_point
end  #结束取得最低F值点
#--------------------------------------------------------------------------
def check_around_point(point)  #开始检查已知点的八方节点
 for d in [2, 4, 6, 8] #[1, 2, 3, 4, 6, 7, 8, 9]
    x = point[0] + ((d == 9 or d == 6 or d == 3) ? 1 : ((d == 7 or d == 4 or d == 1) ? -1 : 0))
    y = point[1] + ((d == 1 or d == 2 or d == 3) ? 1 : ((d == 7 or d == 8 or d == 9) ? -1 : 0))
   if in_close_list?(x, y) #在关闭列表中
     next
   elsif in_open_list?(x, y) #在开启列表中
     get_new_g_point = new_point(x, y, 10 - d)
     get_last_g_point = get_point(x, y)
     if get_new_g_point[3] >= get_last_g_point[3]
       next
     else
       #如果改变父节点是新G值更小则确定改变
       @open_list[@open_list.index(get_last_g_point)] = get_new_g_point
     end
   else
     if x == @trg_x and y == @trg_y
       #x == @trg_x and y == @trg_y  && fp_passable?(point[0], point[1], d, x, y)
       @open_list.push new_point(x, y, 10 - d)
       return true 
     end
     if fp_passable?(point[0], point[1], d, x, y)
       # 如果不在开启列表中、且不在关闭列表中、且通行则添加它到新八周节点
       @open_list.push new_point(x, y, 10 - d)
       #如果将目标点添加到了开启列表中就返回true
       return true if @goal_type == 1 and [1, 0, -1].include?(x - @trg_x) and [1, 0, -1].include?(y - @trg_y)
     end
   end
 end
 #此刻没有找到目标点并将当前点加入关闭列表并在开启列表中删除
 @close_list.push point
 @open_list.delete(point)
 #此刻没找到目标点并返回false
 return false
end  #结束计算已知点的八方节点
#--------------------------------------------------------------------------
def in_open_list?(x, y)  #开始检查谋点是否在开启列表中
 @open_list.each do |point|
   return true if point[0] == x and point[1] == y
 end
 return false
end  #结束检查谋点是否在开启列表中
#--------------------------------------------------------------------------
def in_close_list?(x, y)  #开始检查谋点是否在关闭列表中
 @close_list.each do |point|
   return true if point[0] == x and point[1] == y
 end
 return false
end  #结束检查谋点是否在关闭列表中
#--------------------------------------------------------------------------
end
$findpath=Find_Path.new