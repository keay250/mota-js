#==============================================================================
# ☆★☆ 提取放置物脚本（强化） ☆★☆  
#------------------------------------------------------------------------------
# - 美兽
# - 2007.4.12
#------------------------------------------------------------------------------
#  爱护环境，人人有责，现实中切勿乱丢垃圾。
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
#  脚本原理：
#  是从仓库地图中提取事件，将其拷贝放入指定的位置，
#  依此达成随时随地生成新事件的功能，如此可节省大量用RGSS编写事件所消耗的体力，很多地方写的
#  很保守，尽量减少冲突几率。。
#  此为强化版，可实现新事件的保存，但代价是冲突的随之增大，若只想单纯实现ARPG
#  一类的物品掉落，场所移动后便清除，请使用简洁版。
#------------------------------------------------------------------------------
=begin 
                                Note：
  
一：生成物品主方法：
    Drop_Item.make_events(map_id,event_id,item_x,item_y,save=false) 
    map_id ： 仓库地图的ID。
    event_id ： 仓库中对应事件的ID。
    item_x、item_y ：新事件的X与Y坐标
    save : 是否存储标志;
           默认为false，即不存储，场所移动等转换场景后事件会消失;
           true 为存储，取档、关机、登火星，返回后事件仍存在。
           
二：删除事件方法：
    事件名若包含"delete"字段，则执行完毕会立即自我清除;
    注：任何事件皆如此。

三：必掌握语句：
    $game_map.events[@event_id]
    $game_player
    事件的脚本使用，表示“本事件”和“角色”，主要为取得事件的坐标，
    取得“本事件”X与Y坐标：$game_map.events[@event_id].event.x
                            $game_map.events[@event_id].event.y 
    取得“角色”X与Y坐标：$game_player.x
                          $game_player.y                           
    例如，在某事件左侧生成2号地图的2号事件并永久存储,写法如下。
    x = $game_map.events[@event_id].event.x
    y = $game_map.events[@event_id].event.y 
    Drop_Item.make_events(2,2,x-1,y,true)

四：备注：
    此脚本用法十分灵活，种植、建设、舍弃、掉宝等功能都可用以达成。    

=end
#==============================================================================


module Drop_Item
  
  def self.make_events(map_id,event_id,item_x,item_y,save=false) 
    return if item_x<0 || item_y<0 || item_x>=$game_map.width || item_y>=$game_map.height
    return if item_x==$game_player.x && item_y==$game_player.y
     return if !$game_player.passable?(item_x,item_y,0)
      if $new_map[map_id]==nil
        @map = load_data(sprintf("Data/Map%03d.rxdata", map_id))
      else
        @map= $new_map[map_id]
      end
      if $new_map[$game_map.map_id]==nil
        @map2 = load_data(sprintf("Data/Map%03d.rxdata", $game_map.map_id))
      else
        @map2= $new_map[$game_map.map_id]
      end
      nid=$game_map.map_id
      ev=@map.events[event_id].clone
        for i in 1...163
          if $game_map.events[i]==nil
            mid=i
            break
          end
        end    
        ev.id=mid
        ev.x=item_x
        ev.y=item_y
        $game_map.events[mid] = Game_Event.new(mid,ev)
        if save
          @map2.events[mid]=ev.clone
          $new_map[$game_map.map_id]=@map2
        end  
      end
end  
