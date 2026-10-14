#==============================================================================
# ■ Game_Player
#------------------------------------------------------------------------------
# 　处理主角的类。事件启动的判定、以及地图的滚动等功能。
# 本类的实例请参考 $game_player。
#==============================================================================

class Game_Player < Game_Character
  #--------------------------------------------------------------------------
  # ● 恒量
  #--------------------------------------------------------------------------
  CENTER_X = (320 - 16) * 4   # 画面中央的 X 坐标 * 4
  CENTER_Y = (240 - 16) * 4   # 画面中央的 Y 坐标 * 4
  #--------------------------------------------------------------------------
  # ● 可以通行判定
  #     x : X 坐标
  #     y : Y 坐标
  #     d : 方向 (0,2,4,6,8)  ※ 0 = 全方向不能通行的情况判定 (跳跃用)
  #--------------------------------------------------------------------------
  def passable?(x, y, d, mode = 0)
    # 求得新的坐标
    new_x = x + (d == 6 ? 1 : d == 4 ? -1 : 0)
    new_y = y + (d == 2 ? 1 : d == 8 ? -1 : 0)

  
   # $game_temp.common_event_id =20#潜伏怪显示
=begin
    if $game_switches[40]#角色间无法通过
      for i in 0...$game_variables[73].size
#      p $game_variables[73][i][0]
        if new_x==$game_variables[73][i][0] and new_y==$game_variables[73][i][1]
          return false
        end
      end
    end
=end

    # 坐标在地图外的情况下
    unless $game_map.valid?(new_x, new_y)
      # 不能通行
      return false
    end
    # 调试模式为 ON 并且 按下 CTRL 键的情况下
    if $DEBUG and Input.press?(Input::CTRL) and mode==0
      # 可以通行
      return true
    end
    super
  end
  #--------------------------------------------------------------------------
  # ● 像通到画面中央一样的设置地图的显示位置
  #--------------------------------------------------------------------------
  def center(x, y)
    max_x = ($game_map.width - 20) * 128
    max_y = ($game_map.height - 15) * 128
    $game_map.display_x = [0, [x * 128 - CENTER_X - 320, max_x].min].max
    $game_map.display_y = [0, [y * 128 - CENTER_Y, max_y].min].max
  end
  #--------------------------------------------------------------------------
  # ● 向指定的位置移动
  #     x : X 座標
  #     y : Y 座標
  #--------------------------------------------------------------------------
  def moveto(x, y)
    super
    # 自连接
    center(x, y)
    # 生成遇敌计数
    make_encounter_count
  end
  #--------------------------------------------------------------------------
  # ● 增加步数
  #--------------------------------------------------------------------------
  def increase_steps
    super
    $game_variables[268]=0
    # 不是强制移动路线的场合
    unless @move_route_forcing
      # 增加步数
      $game_party.increase_steps
    if $DEBUG and Input.press?(Input::CTRL)
      return
    end
    flag=0
    new_x=$game_player.x
    new_y=$game_player.y
    for i in $game_variables[72] #领域
      check=false
      ev=$game_map.events[i[0]]
      case i[1]
      when 1 #矩形领域
        w=i[2][0]/2
        h=i[2][1]/2
        x1=ev.x-w
        x2=ev.x+(i[2][0]-1-w)
        y1=ev.y-h
        y2=ev.y+(i[2][1]-1-h)
        if new_x>=x1 && new_x<=x2 && new_y>=y1 && new_y<=y2
          check=true
          aid=41
        end
      end
      if check
        damage=got_magicdam(i[3])
        if damage>0
          $game_actors[$game_variables[1]+1].hp-=damage.to_i
          hp=$game_actors[$game_variables[1]+1].hp
          mhp=$game_actors[$game_variables[1]+1].maxhp
          $game_actors[$game_variables[1]+1].hprate=hp.to_f/mhp
          $game_player.animation_id=aid
          if $game_actors[$game_variables[1]+1].hp<=0
            $game_variables[19]=1
            $game_temp.common_event_id =12#生命小于0，调用1号结局
          end
        end
      end
    end
    
     for i in 0...$game_variables[129].size
      xx=$game_map.events[$game_variables[129][i]].x-new_x#).abs
      yy=$game_map.events[$game_variables[129][i]].y-new_y#).abs
      xxx=xx.abs
      yyy=yy.abs
      if (xx==0 or yy==0)
        sw=true
        if xx==0
          if yy>0
            d=8
          else
            d=2
          end
        end
        if yy==0
          if xx>0
            d=4
          else
            d=6
          end
        end
        x=$game_map.events[$game_variables[129][i]].x
        y=$game_map.events[$game_variables[129][i]].y
        if x!=new_x || y !=new_y
          case d
          when 2
            y+=1
          when 4
            x-=1
          when 6
            x+=1
          when 8
            y-=1
          end
          while x != new_x || y != new_y
            xx=x
            yy=y
            case d
            when 2
              yy+=1
            when 4
              xx-=1
            when 6
              xx+=1
            when 8
              yy-=1
            end
            bit = (1 << (d / 2 - 1)) & 0x0f
            for k in [2, 1]
              if xx==0
                tile_id = $game_map.data[x, y, k]
              else
                tile_id = $game_map.data[x, y, k]
              end
              if tile_id == nil
                sw=false
              elsif $game_map.terrain_tags[tile_id]>0
                sw=true
                break
              elsif $game_map.passages[tile_id] & bit != 0
                sw=false
              elsif $game_map.passages[tile_id] & 0x0f == 0x0f
                sw=false
              elsif $game_map.priorities[tile_id] == 0
                break
              end
            end
            bit = (1 << ( ( 10 - d ) / 2 - 1)) & 0x0f
            for k in [2, 1]
              if xx==0
                tile_id = $game_map.data[xx, yy, k]
              else
                tile_id = $game_map.data[xx, yy, k]
              end
              if $game_map.terrain_tags[tile_id]>0
                sw=true
                break
              end
              if tile_id == nil
                sw=false
              elsif $game_map.terrain_tags[tile_id]>0
                sw=true
                break
              elsif $game_map.passages[tile_id] & bit != 0
                sw=false
              elsif $game_map.passages[tile_id] & 0x0f == 0x0f
                sw=false
              elsif $game_map.priorities[tile_id] == 0
                break
              end
            end
            x=xx
            y=yy
            break if !sw
          end
          
        end
        if sw
          na=$game_map.events[$game_variables[129][i]].event.name
          ee=na[6,na.length-6].to_i
          md=$game_actors[$game_variables[1]+1].dex
          shield=$game_actors[$game_variables[1]+1].prshield
          mmiss=1-$game_actors[$game_variables[1]+1].miss
          if got_p(ee,105) #致命射击
            mmiss=1
            shield=$game_actors[$game_variables[1]+1].shield
            shield=$game_actors[$game_variables[1]+1].prshield(shield*(1-got_p_value(ee,105).to_f/100))
          end
          ea=$data_enemies[ee].atk
          ecombo=$data_enemies[ee].agi
          ecombo=Math.sqrt(ecombo)/10.0
          damage=([ea-md,0].max*ecombo*shield*mmiss)
          if got_p(ee,157) #军团作战 \v
            damage*=got_p_value(ee,157).split("-")[0].to_f
          end
          if got_p(ee,26) #元素冲击 \v
            damage+=got_magicdam(got_p_value(ee,26).to_f)*ecombo
          end
          if got_p(ee,29) #粹毒攻击 \v
            d=[got_p_value(ee,29).to_i,0].max*ecombo*shield*mmiss
            if $game_variables[226]!=0 && $game_variables[226][4]>0
              d*=1-$game_variables[226][4]*0.1
            end
            damage+=d
          end
          if got_p(ee,78) #法力损毁攻击 \v\v
            a=got_p_value(ee,78).split("-")
            b=[a[0].to_i*ecombo*mmiss,$game_actors[$game_variables[1]+1].sp].min
            if b>0
              damage+=b*a[1].to_f*shield
              $game_actors[$game_variables[1]+1].sp-= b.to_i
              sp=$game_actors[$game_variables[1]+1].sp
              msp=$game_actors[$game_variables[1]+1].maxsp
              $game_actors[$game_variables[1]+1].sprate=sp.to_f/msp
            end
          end
          aid=2
          if got_p(ee,145) #强力击 \v
            $game_variables[235]=[] if $game_variables[235]==0
            damage=0
            if $game_variables[235][$game_variables[129][i]]
            else
              if xxx==0
                l=yyy-1
              else
                l=xxx-1
              end
              a=got_p_value(ee,145).split("-")
              damage+=got_magicdam(a[1].to_f*(1+a[2].to_f/100*l))
              $game_variables[235][$game_variables[129][i]]=true
              aid=39
            end
          end
          if got_p(ee,176) #激光 \v
            $game_variables[235]=[] if $game_variables[235]==0
            damage=0
            if $game_variables[235][$game_variables[129][i]]
            else
              if xxx==0
                l=yyy-1
              else
                l=xxx-1
              end
              a=got_p_value(ee,176).split("-")
              damage+=a[0].to_f*(a[2].to_f/100)
              $game_variables[235][$game_variables[129][i]]=true
              aid=65
            end
          end
          if got_p(ee,204) #幽冥射击
            damage=0
            a=got_p_value(ee,204).split("-")
            damage+=ea*shield/100.0*a[0].to_f
            actor=$game_actors[$game_variables[1]+1]
            if $game_variables[226]!=0 && $game_variables[226][4]>=7
            else
              actor.add_buff_ex(8,a[1].to_i-1,nil,nil,true)
              aid=81
            end
          end
          if got_p(ee,205) #诅咒之矢
            damage=0
            a=got_p_value(ee,205).split("-")
            damage+=got_magicdam(ea)/100.0*a[0].to_f
            actor=$game_actors[$game_variables[1]+1]
            if $game_variables[226]!=0 && $game_variables[226][24]>=7
            else
              actor.add_buff_ex(9,a[1].to_i-1,nil,nil,true)
              aid=82
              if actor.get_buff_time(9)>30
                get_achievement(227) #功力尽失
              end
            end
          end
          if damage>0
            $game_actors[$game_variables[1]+1].hp-=damage.to_i
            hp=$game_actors[$game_variables[1]+1].hp
            mhp=$game_actors[$game_variables[1]+1].maxhp
            $game_actors[$game_variables[1]+1].hprate=hp.to_f/mhp
            $game_player.animation_id=aid
            if $game_actors[$game_variables[1]+1].hp<=0
              $game_variables[19]=1
              $game_temp.common_event_id =12#生命小于0，调用1号结局
            end
          end
          
        else
          na=$game_map.events[$game_variables[129][i]].event.name
          ee=na[6,na.length-6].to_i
          if $data_enemies[ee].element_ranks[145]==1 #强力击
            $game_variables[235]=[] if $game_variables[235]==0
            $game_variables[235][$game_variables[129][i]]=nil
          end 
          if $data_enemies[ee].element_ranks[176]==1 #激光
            $game_variables[235]=[] if $game_variables[235]==0
            $game_variables[235][$game_variables[129][i]]=nil
          end 
        end
        
      else
        na=$game_map.events[$game_variables[129][i]].event.name
        ee=na[6,na.length-6].to_i
        if $data_enemies[ee].element_ranks[145]==1 #强力击
          $game_variables[235]=[] if $game_variables[235]==0
          $game_variables[235][$game_variables[129][i]]=nil
        end   
        if $data_enemies[ee].element_ranks[176]==1  #激光
          $game_variables[235]=[] if $game_variables[235]==0
          $game_variables[235][$game_variables[129][i]]=nil
        end 
      end
    end #精准射击怪
    
    
    for i in $game_variables[280]
      ev=$game_map.events[i]
      xx=ev.x-new_x
      yy=ev.y-new_y
      if (xx==0 or yy==0)
        sw=true
        if xx==0
          if yy>0
            d=8
          else
            d=2
          end
        end
        if yy==0
          if xx>0
            d=4
          else
            d=6
          end
        end
        x=ev.x
        y=ev.y
        sw=true
        while x != new_x || y != new_y
            xx=x
            yy=y
            case d
            when 2
              yy+=1
            when 4
              xx-=1
            when 6
              xx+=1
            when 8
              yy-=1
            end
            bit = (1 << (d / 2 - 1)) & 0x0f
            for k in [2, 1]
              if xx==0
                tile_id = $game_map.data[x, y, k]
              else
                tile_id = $game_map.data[x, y, k]
              end
              if tile_id == nil
                sw=false
              elsif $game_map.terrain_tags[tile_id]>0
                sw=true
                break
              elsif $game_map.passages[tile_id] & bit != 0
                sw=false
              elsif $game_map.passages[tile_id] & 0x0f == 0x0f
                sw=false
              elsif $game_map.priorities[tile_id] == 0
                break
              end
            end
            bit = (1 << ( ( 10 - d ) / 2 - 1)) & 0x0f
            for k in [2, 1]
              if xx==0
                tile_id = $game_map.data[xx, yy, k]
              else
                tile_id = $game_map.data[xx, yy, k]
              end
              if $game_map.terrain_tags[tile_id]>0
                sw=true
                break
              end
              if tile_id == nil
                sw=false
              elsif $game_map.terrain_tags[tile_id]>0
                sw=true
                break
              elsif $game_map.passages[tile_id] & bit != 0
                sw=false
              elsif $game_map.passages[tile_id] & 0x0f == 0x0f
                sw=false
              elsif $game_map.priorities[tile_id] == 0
                break
              end
            end
            x=xx
            y=yy
            break if !sw
          end

        if sw
         # ev.setspeed(@move_speed)
          $game_switches[66]=true
          $game_switches[10]=false
          $game_switches[63]=false
          case d
          when 2
            ev.move_down
          when 4
            ev.move_left
          when 6
            ev.move_right
          when 8
            ev.move_up
          end
          if ev.moving?
            $game_switches[56]=true
            if $movedevents.include?($game_map.map_id)==false
              $movedevents[$game_map.map_id]=[]
            end
            $movedevents[$game_map.map_id][ev.id]=$game_map.he_at(ev.id)
          end
          while ev.moving?
            break if $game_actors[$game_variables[1]+1].hp<=0
            break if $game_switches[63]
            Graphics.update
            Input.update
            $scene.update
          end
          xx=ev.x-new_x
          yy=ev.y-new_y
          if xx.abs+yy.abs<=1
            case d
            when 2
              turn_up
            when 4
              turn_right
            when 6
              turn_left
            when 8
              turn_down
            end
            $game_switches[61]=true
            ev.unerase
            ev.start
            Graphics.update
            Input.update
            $scene.update
            $game_switches[63]=false
            while $game_system.map_interpreter.running?
              break if $game_actors[$game_variables[1]+1].hp<=0
              break if $game_switches[63]
              Graphics.update
              Input.update
              $scene.update
            end
          end
          $game_switches[61]=false
          $game_switches[10]=true
          $game_switches[66]=false
        end
      end
    end #追猎
    if $game_switches[68] && $game_switches[67]
      check=false
      if $game_variables[281][$game_map.map_id]==nil
        $game_switches[68]=false
        $game_switches[67]=false
      end
      if $game_switches[68] && $game_switches[67]
      for i in $game_variables[281][$game_map.map_id].keys
        break if $game_actors[1].check_buff(6) || $game_actors[1].check_buff(7)
        next if $game_map.events[i].character_name ==""
        ev=$game_map.events[i]
        this=$game_player
        path=$findpath.find_short_path(ev.x,ev.y,this.x,this.y,2)
        if path != []
          check=true
          ev.through=true
          xx=ev.x-this.x
          yy=ev.y-this.y
          if xx.abs+yy.abs>1
            save_speed = ev.getspeed
            ev.setspeed(@move_speed)
            case path[0]
            when 2
              ev.move_down
            when 4
              ev.move_left
            when 6
              ev.move_right
            when 8
              ev.move_up
            end
            if ev.moving?
              $game_switches[56]=true
              if $movedevents.include?($game_map.map_id)==false
                $movedevents[$game_map.map_id]=[]
              end
              $movedevents[$game_map.map_id][ev.id]=$game_map.he_at(ev.id)
            end
            $game_switches[66]=true
            $game_switches[10]=false
            $game_switches[63]=false
            j=$game_variables[281][$game_map.map_id][i]
            j[0]+=j[1]
            while ev.moving?
              break if $game_actors[$game_variables[1]+1].hp<=0
              break if $game_switches[63]
              Graphics.update
              Input.update
              $scene.update
            end
            ev.setspeed(save_speed)
          end
          xx=ev.x-this.x
          yy=ev.y-this.y
          if xx.abs+yy.abs<=1
            $game_switches[61]=true
            ev.unerase
            ev.start
            Graphics.update
            Input.update
            $scene.update
            $game_switches[63]=false
            while $game_system.map_interpreter.running?
              break if $game_actors[$game_variables[1]+1].hp<=0
              break if $game_switches[63]
              Graphics.update
              Input.update
              $scene.update
            end
            $game_switches[61]=false
          end
          $game_switches[10]=true
          $game_switches[66]=false
        end
        ev.through=false
      end
      end
      if !check
        $game_switches[67]=false
      end
    end #致死方休
    
  zuji=$game_variables[119].clone
  if $game_variables[121].size>=2 && $game_party.item_number(45)==0
    px=$game_player.x
    py=$game_player.y
    c=[-5,-4,-3,-2]
    s=[]
    for ev in $game_variables[121]#$game_map.events.values
      event=$game_map.events[ev]
      if (event.x-px).abs+(event.y-py).abs==1 && event.character_name!="" && event.name[0,6]=="怪物"
        if event.x<px
          c[0]=$jjc[[event.x,event.y]]
          s[0]=event.id
        end
        if event.x>px
          c[2]=$jjc[[event.x,event.y]]
          s[2]=event.id
        end
        if event.y<py
          c[1]=$jjc[[event.x,event.y]]
          s[1]=event.id
        end
        if event.y>py
          c[3]=$jjc[[event.x,event.y]]
          s[3]=event.id
        end
      end
    end
    i=0
    val=-1
    while i<=1
      if c[i]==c[i+2]
        zuji.delete(s[i])
        zuji.delete(s[i+2])
        val=1-c[i]/100.0
        get_achievement(209) if $game_actors[$game_variables[1]+1].hp==1 #一除以二
        $game_actors[$game_variables[1]+1].hp=($game_actors[$game_variables[1]+1].hp*val).to_i
        hp=$game_actors[$game_variables[1]+1].hp
        mhp=$game_actors[$game_variables[1]+1].maxhp
        $game_actors[$game_variables[1]+1].hprate=hp.to_f/mhp
        end
      i+=1
    end
    if val>=0
      $game_player.animation_id=2#显示动画2
      if $game_actors[$game_variables[1]+1].hp<=0
        $game_variables[19]=1
        $game_temp.common_event_id =12#生命小于0，调用1号结局
      end
    end
  end#夹击怪

  for i in 0...zuji.size
      xx=($game_map.events[zuji[i]].x-$game_player.x).abs
      yy=($game_map.events[zuji[i]].y-$game_player.y).abs
      kx=$game_map.events[zuji[i]].x
      ky=$game_map.events[zuji[i]].y
      px=$game_player.x
      py=$game_player.y
      na=$game_map.events[zuji[i]].event.name
      ee=na[6,na.length-6].to_i
      if (xx==1 and yy<1) or (xx<1 and yy==1)
        $game_actors[$game_variables[1]+1].hp-=got_magicdam(got_p_value(ee,52).to_i).to_i
        hp=$game_actors[$game_variables[1]+1].hp
        mhp=$game_actors[$game_variables[1]+1].maxhp
        $game_actors[$game_variables[1]+1].hprate=hp.to_f/mhp
        $game_player.animation_id=2#显示动画2
        if $game_actors[$game_variables[1]+1].hp<=0
          $game_variables[19]=1
          $game_temp.common_event_id = 12#生命小于0，调用1号结局
        else
          $game_map.events[zuji[i]].through=true
          $game_map.events[zuji[i]].setspeed(@move_speed)
          if py-ky>0 && $game_player.passable?(kx,ky,8)
            $game_map.events[zuji[i]].move_up
          end
          if ky-py>0 && $game_player.passable?(kx,ky,2)
            $game_map.events[zuji[i]].move_down
          end
          if px-kx>0 && $game_player.passable?(kx,ky,4)
            $game_map.events[zuji[i]].move_left
          end
          if kx-px>0 && $game_player.passable?(kx,ky,6)
            $game_map.events[zuji[i]].move_right
          end
          $game_map.events[zuji[i]].through=false
          all=$game_map.events[zuji[i]].event.id
          if $movedevents.include?($game_map.map_id)==false
            $movedevents[$game_map.map_id]=[]
          end
          $movedevents[$game_map.map_id][all]=$game_map.he_at(all)
        end
      end
    end#阻击怪
    
    for i in $game_variables[222] #沙尘暴
      xx=($game_map.events[i].x-$game_player.x).abs
      yy=($game_map.events[i].y-$game_player.y).abs
      na=$game_map.events[i].event.name
      ee=na[6,na.length-6].to_i
      a=got_p_value(ee,112).split("-")
      if xx+yy<=a[0].to_i
        if !$game_switches[158] && $event_damage[i]>$game_actors[$game_variables[1]+1].hp
          $game_map.events[i].unerase
          value=$game_map.events[i]
          movelist=RPG::MoveRoute.new
          movelist.list=[]
          movelist.list.push(RPG::MoveCommand.new(37,[]))
          movelist.list.push(RPG::MoveCommand.new(14,[$game_player.x-value.x,$game_player.y-value.y]))
          movelist.list.push(RPG::MoveCommand.new(29,[5]))
          movelist.list.push(RPG::MoveCommand.new(30,[6]))
          movelist.list.push(RPG::MoveCommand.new(38,[]))
          movelist.list.push(RPG::MoveCommand.new(0,[]))
          movelist.repeat=false
          value.move_route_forcing=true
          value.force_move_route(movelist) 
          Input.update
          $game_switches[66]=true
          $game_switches[10]=false
          for time in 0...20
            Graphics.update
            $game_map.update
            $game_player.update
            $scene.get_spriteset.update
          end
          $game_switches[61]=true
          $game_map.events[i].start
          $game_system.map_interpreter.update
          next
        end
        $game_actors[$game_variables[1]+1].hp-=got_magicdam(a[1].to_i).to_i
        hp=$game_actors[$game_variables[1]+1].hp
        mhp=$game_actors[$game_variables[1]+1].maxhp
        $game_actors[$game_variables[1]+1].hprate=hp.to_f/mhp
        $game_player.animation_id=2#显示动画2
        if $game_actors[$game_variables[1]+1].hp<=0
          $game_variables[19]=1
          $game_temp.common_event_id = 12#生命小于0，调用1号结局
        end
      end
    end
    for i in $game_variables[223] #捕捉怪
      xx=($game_map.events[i].x-$game_player.x).abs
      yy=($game_map.events[i].y-$game_player.y).abs
      if xx+yy<=1
        if xx+yy==1
          save_d=@direction
          sx = $game_map.events[i].x - $game_player.x
          sy = $game_map.events[i].y - $game_player.y
          if sx.abs > sy.abs
            sx < 0 ? $game_player.turn_left : $game_player.turn_right
          else
            sy < 0 ? $game_player.turn_up : $game_player.turn_down
          end
          x2=$game_map.events[i].x
          y2=$game_map.events[i].y
          d=@direction
          if !$game_map.passable?(x2,y2, 10-d)
            @direction=save_d
            next
          end
          x2 = $game_map.x_with_direction(x2, 10-d)
          y2 = $game_map.y_with_direction(y2, 10-d)
          if !$game_map.passable?(x2,y2, d)
            @direction=save_d
            next
          end
        end
        $game_switches[18]=true
        $game_map.events[i].unerase
        $game_map.events[i].start
        Graphics.update
        Input.update
        $scene.update
        $game_switches[66]=true
        $game_switches[63]=false
        while $game_system.map_interpreter.running?
          break if $game_actors[$game_variables[1]+1].hp<=0
          break if $game_switches[63]
          Graphics.update
          Input.update
          $scene.update
        end
        $game_switches[66]=false
      end
    end
    
    if $game_variables[213]==0
      $game_variables[213]=[]
      $game_variables[213][0]=1
    end
    $game_variables[213][$game_variables[213][0]]=[$game_map.map_id,$game_player.x,$game_player.y,$game_player.direction]
    $game_variables[213][0]+=1
    if $game_variables[213][0]>=21
      $game_variables[213][0]=1
    end
 #     # 步数是偶数的情况下
  #    if $game_party.steps % 2 == 0
   #     # 检查连续伤害
   #     $game_party.check_map_slip_damage
   #   end
   end
  end
  #--------------------------------------------------------------------------
  # ● 获取遇敌计数
  #--------------------------------------------------------------------------
  def encounter_count
    return @encounter_count
  end
  #--------------------------------------------------------------------------
  # ● 生成遇敌计数
  #--------------------------------------------------------------------------
  def make_encounter_count
    # 两种颜色震动的图像
    if $game_map.map_id != 0
      n = $game_map.encounter_step
      @encounter_count = rand(n) + rand(n) + 1
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新
  #--------------------------------------------------------------------------
  def refresh
    # 同伴人数为 0 的情况下
    if $game_party.actors.size == 0
      # 清除角色的文件名及对像
      @character_name = ""
      @character_hue = 0
      # 分支结束
      return
    end
    # 获取带头的角色
    actor = $game_party.actors[0]
    # 设置角色的文件名及对像
    @character_name = actor.character_name
    @character_hue = actor.character_hue
    # 初始化不透明度和合成方式子
    @opacity = 255
    @blend_type = 0
  end
  #--------------------------------------------------------------------------
  # ● 同位置的事件启动判定
  #--------------------------------------------------------------------------
  def check_event_trigger_here(triggers)
    result = false
    # 事件执行中的情况下
    if $game_system.map_interpreter.running?
      return result
    end
    # 全部事件的循环
    for event in $game_map.events.values
      # 事件坐标与目标一致的情况下
      if event.x == @x and event.y == @y and triggers.include?(event.trigger)
        # 跳跃中以外的情况下、启动判定是同位置的事件
        if not event.jumping? and event.over_trigger?
          event.start
          result = true
        end
      end
    end
    return result
  end
  #--------------------------------------------------------------------------
  # ● 正面事件的启动判定
  #--------------------------------------------------------------------------
  def check_event_trigger_there(triggers)
    result = false
    # 事件执行中的情况下
    if $game_system.map_interpreter.running?
      return result
    end
    # 计算正面坐标
    new_x = @x + (@direction == 6 ? 1 : @direction == 4 ? -1 : 0)
    new_y = @y + (@direction == 2 ? 1 : @direction == 8 ? -1 : 0)
    # 全部事件的循环
    for event in $game_map.events.values
      # 事件坐标与目标一致的情况下
      if event.x == new_x and event.y == new_y #and
       # triggers.include?(event.trigger)# || Kboard.trigger?($R_Key_RETURN) || Kboard.trigger?($R_Key_SPACE)#[1,2].include?(event.trigger)
        # 跳跃中以外的情况下、启动判定是正面的事件
        if not event.jumping? and not event.over_trigger? and event.trigger != 4
          event.start
          result = true
        end
      end
    end
    # 找不到符合条件的事件的情况下
    if result == false
      # 正面的元件是计数器的情况下
      if $game_map.counter?(new_x, new_y)
        # 计算 1 元件里侧的坐标
        new_x += (@direction == 6 ? 1 : @direction == 4 ? -1 : 0)
        new_y += (@direction == 2 ? 1 : @direction == 8 ? -1 : 0)
        # 全事件的循环
        for event in $game_map.events.values
          # 事件坐标与目标一致的情况下
          if event.x == new_x and event.y == new_y and
             triggers.include?(event.trigger)
            # 跳跃中以外的情况下、启动判定是正面的事件
            if not event.jumping? and not event.over_trigger?
              event.start
              result = true
            end
          end
        end
      end
    end
    return result
  end
  #--------------------------------------------------------------------------
  # ● 接触事件启动判定
  #--------------------------------------------------------------------------
  def check_event_trigger_touch(x, y)
    result = false
    # 事件执行中的情况下
    if $game_system.map_interpreter.running?
      return result
    end
    # 全事件的循环
    for event in $game_map.events.values
      # 事件坐标与目标一致的情况下
      if event.x == x and event.y == y and [1,2].include?(event.trigger)
        # 跳跃中以外的情况下、启动判定是正面的事件
        if not event.jumping? and not event.over_trigger?
          if event.name[0,6]=="怪物"
            if $game_variables[232]!=0 && $game_actors[$game_variables[1]+1].check_buff(6)
              $game_temp.common_event_id=43
              return false
            end
          end
          event.start
          result = true
        end
      end
    end
    return result
  end
  #--------------------------------------------------------------------------
  # ● 画面更新
  #--------------------------------------------------------------------------
  def update
    # 本地变量记录移动信息
    last_moving = moving?
    # 移动中、事件执行中、强制移动路线中、
    # 信息窗口一个也不显示的时候
    unless moving? or $game_system.map_interpreter.running? or
           @move_route_forcing or $game_temp.message_window_showing
      # 如果方向键被按下、主角就朝那个方向移动
      if $game_switches[62]
        EnemyReady.battle1
        $game_switches[62]=false
      end
      if $game_switches[18]#按下快捷键后不能走动
        return
      end
      if $game_switches[66]#按下快捷键后不能走动
        return
      end
      if $game_switches[172]#特殊BOSS战施法中
        return
      end
  if $game_config.data("numlock")==1
      check=0
      if Kboard.press?($R_Key_DOWN)
        check=1;dir=2
      end
      if Kboard.press?($R_Key_LEFT)
        check+=1;dir=4
      end
      if Kboard.press?($R_Key_RIGHT) 
        check+=1;dir=6
      end
      if Kboard.press?($R_Key_UP)
        check+=1;dir=8
      end
      if check==1
        $game_switches[49]=false#为了确保在移动中无法打开菜单
        case dir
        when 2
          move_down
        when 4
          move_left
        when 6
          move_right
        when 8
          move_up
        end
      end
  else
      case Input.dir4
      when 2
        $game_switches[49]=false#为了确保在移动中无法打开菜单
        #$game_switches[10]=false
        move_down
      when 4
        $game_switches[49]=false#为了确保在移动中无法打开菜单
        #$game_switches[10]=false
        move_left
      when 6
        $game_switches[49]=false#为了确保在移动中无法打开菜单
        #$game_switches[10]=false
        move_right
      when 8
        $game_switches[49]=false#为了确保在移动中无法打开菜单
        #$game_switches[10]=false
        move_up
      end
  end
    end
    # 本地变量记忆坐标
    last_real_x = @real_x
    last_real_y = @real_y
    super
    # 角色向下移动、画面上的位置在中央下方的情况下
    if @real_y > last_real_y and @real_y - $game_map.display_y > CENTER_Y
      # 画面向下卷动
      $game_map.scroll_down(@real_y - last_real_y)
    end
    # 角色向左移动、画面上的位置在中央左方的情况下
    if @real_x < last_real_x and @real_x - $game_map.display_x < CENTER_X+320
      # 画面向左卷动
      $game_map.scroll_left(last_real_x - @real_x)
    end
    # 角色向右移动、画面上的位置在中央右方的情况下
    if @real_x > last_real_x and @real_x - $game_map.display_x > CENTER_X+336
      # 画面向右卷动
      $game_map.scroll_right(@real_x - last_real_x)
    end
    # 角色向上移动、画面上的位置在中央上方的情况下
    if @real_y < last_real_y and @real_y - $game_map.display_y < CENTER_Y
      # 画面向上卷动
      $game_map.scroll_up(last_real_y - @real_y)
    end
    # 不在移动中的情况下
    unless moving?
      # 上次主角移动中的情况
      if last_moving
        # 与同位置的事件接触就判定为事件启动
        result = check_event_trigger_here([1,2])
        # 没有可以启动的事件的情况下
        if result == false
          # 调试模式为 ON 并且按下 CTRL 键的情况下除外
          unless $DEBUG and Input.press?(Input::CTRL) and $game_switches[47]==true
            # 遇敌计数下降
            if @encounter_count > 0
              @encounter_count -= 1
            end
          end

        end
      end
      # 按下 C 键的情况下
      if Input.trigger?(Input::C) && !$game_temp.message_window_showing
        # 判定为同位置以及正面的事件启动
        check_event_trigger_here([0])
#        check_event_trigger_there([0,1,2])
        check_event_trigger_there([0])
      end
      #$game_switches[10]=true#移动中也不能按快捷键
      $game_switches[49]=true#处理完事件才算移动完毕   

    end
  end
end
