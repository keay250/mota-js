class Game_Map
  def Cheking_Door(id)
    sx=$game_player.x
    sy=$game_player.y
    ev=$game_map.events[id]
    a=[1,0,-1,0]
    b=[0,1,0,-1]
    c=[6,2,4,8]
    data=$game_map.data
    $game_switches[185]=true
    for i in 0...4
      tx=ev.x+a[i]
      ty=ev.y+b[i]
      if tx !=sx || ty !=sy
        sw=true
          bit = (1 << (c[i] / 2 - 1)) & 0x0f
          for k in [2, 1, 0]
            tile_id = data[sx, sy, k]
            if tile_id == nil
              sw=false
            elsif @passages[tile_id] & bit != 0
              sw=false
            elsif @passages[tile_id] & 0x0f == 0x0f
              sw=false
            elsif @priorities[tile_id] == 0
              break
            end
          end
          bit = (1 << ((10-c[i]) / 2 - 1)) & 0x0f
          for k in [2, 1, 0]
            tile_id = data[tx, ty, k]
            if tile_id == nil
              sw=false
            elsif @passages[tile_id] & bit != 0
              sw=false
            elsif @passages[tile_id] & 0x0f == 0x0f
              sw=false
            elsif @priorities[tile_id] == 0
              break
            end
          end
        if sw
          if $findpath.find_short_path(sx,sy,tx,ty,1) != []
          else
            $game_switches[185]=false
            return true
          end
        end
      end
    end
    return true
  end
end