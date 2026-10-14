class Game_Map 
  #--------------------------------------------------------------------------
  # ● 计算特定方向推移一个图块的 X 坐标（没有循环修正）
  #--------------------------------------------------------------------------
  def x_with_direction(x, d)
    x + (d == 6 ? 1 : d == 4 ? -1 : 0)
  end
  #--------------------------------------------------------------------------
  # ● 计算特定方向推移一个图块的 Y 坐标（没有循环修正）
  #--------------------------------------------------------------------------
  def y_with_direction(y, d)
    y + (d == 2 ? 1 : d == 8 ? -1 : 0)
  end
end
module EnemyReady
 module_function
 def hunter(id)
   ev=$game_map.events[id]
   return if $data_enemies[ev.name[6,ev.name.size-6].to_i].element_ranks[104]==1 #狂战士之血不接受支援
   for i in $game_variables[190]
     next if i==id
     value=$game_map.events[i]
     if value.x==ev.x || value.y==ev.y
        sw=false
        x=value.x
        y=value.y
        if value.x==ev.x
          dis=(value.y-ev.y).abs
          if value.y>ev.y
            direction=8
          else
            direction=2
          end
        end
        if value.y==ev.y
          dis=(value.x-ev.x).abs
          if value.x>ev.x
            direction=4
          else
            direction=6
          end
        end
        sw=nil
        loop do
            xx=x
            yy=y
            x = $game_map.x_with_direction(x, direction)
            y = $game_map.y_with_direction(y, direction)
            break if !$game_map.valid?(x, y)
            bit = (1 << (direction / 2 - 1)) & 0x0f
            for k in [2, 1]
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
            bit = (1 << ( ( 10 - direction ) / 2 - 1)) & 0x0f
            for k in [2, 1]
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
            break if sw==false
            if (x==ev.x && y==ev.y)
              sw=true
              break
            end
        end
        #可以移动到当前位置
        if sw
          a=RPG::MoveRoute.new
          a.list=[]
          a.list.push(RPG::MoveCommand.new(37,[]))
          a.list.push(RPG::MoveCommand.new(29,[5]))
          a.list.push(RPG::MoveCommand.new(30,[6]))
          for j in 0...dis
            a.list.push(RPG::MoveCommand.new(direction/2,[]))
          end
          a.list.push(RPG::MoveCommand.new(0,[]))
          a.repeat=false
          value.move_route_forcing=true
          value.force_move_route(a) 
          $game_switches[136]=true
          loop do
            if !value.move_route_forcing
              $mapdamage_obj.setvisible(value.id,false)
              if $game_variables[4].is_a?(Integer)
                a=$game_variables[4]
                $game_variables[4]=[]
                $game_variables[4].push(a)
              end
              $game_variables[4].push(value.event.name[6,value.event.name.length-6].to_i)
              list=[RPG::EventCommand.new(117,0,[13]),RPG::EventCommand.new()]
              interpreter=Interpreter.new
              interpreter.setup(list, value.id)
              interpreter.update
              $game_switches[136]=false
              break
            end
            Graphics.update
            # 刷新输入信息
            Input.update
            # 刷新画面
            $scene.get_spriteset.update
            $game_map.update
           # $game_system.map_interpreter.update
            $game_player.update
            # 系统 (计时器)、画面刷新
            $game_system.update
            $game_screen.update
          end
        end
     end
   end
 end
 def check_area(id)
   #光环检查
   this=$game_map.events[id]
   result=[]
    for i in $game_variables[139]
      value=$game_map.events[i[1].to_i]
      event = value.event
      if event.name[0,6]=="怪物" && value.character_name !="" && !value.erased?
        if (value.x-this.x).abs<=i[2]/2 && (value.y-this.y).abs<=i[3]/2
          result.push([i[0],i[4],id,value.id])
        end
      end
    end
    return result
  end
 def alert(id) #警戒
    #警戒怪
    result=[]
    eresult=[]
    rexy=[]   
    for i in 0...$game_variables[142].size
      if $game_variables[142][i]==id
        this=$game_map.events[$game_variables[142][i]]
        size=$game_variables[140][i]
        $game_map.events.each_value{|value|
          event = value.event
          if event.name[0,6]=="怪物" && value.character_name !="" && !value.erased? && value.id !=this.id
            if (value.x-this.x).abs+(value.y-this.y).abs<=size
              if $findpath.find_short_path(value.x,value.y,this.x,this.y,1) != []
                if $game_variables[4].is_a?(Integer)
                  b=$game_variables[4]
                  $game_variables[4]=[]
                  $game_variables[4].push(b)
                end
                $game_variables[4].push(value.event.name[6,value.event.name.length-6].to_i)
                result.push(value.name[6,value.name.length-6].to_i)
                eresult.push(value.id)
                rexy.push([value.x,value.y])
              end
            end
          end
        }
        break if eresult.size==0
        for j in eresult
          value=$game_map.events[j]
          a=RPG::MoveRoute.new
          a.list=[]
          a.list.push(RPG::MoveCommand.new(37,[]))
          a.list.push(RPG::MoveCommand.new(14,[this.x-value.x,this.y-value.y]))
          a.list.push(RPG::MoveCommand.new(29,[5]))
          a.list.push(RPG::MoveCommand.new(30,[6]))
          a.list.push(RPG::MoveCommand.new(38,[]))
          a.list.push(RPG::MoveCommand.new(0,[]))
          a.repeat=false
          value.move_route_forcing=true
          value.force_move_route(a) 
        end
        $game_switches[136]=true
        loop do
          if !value.move_route_forcing
            list=[RPG::EventCommand.new(117,0,[13]),RPG::EventCommand.new()]
            interpreter=Interpreter.new
            for j in 0...eresult.size
              if got_p(result[j],38) || $game_map.events[eresult[j]].erased?
                $game_map.events[eresult[j]].reborn(result[j])
                $game_map.events[eresult[j]].moveto(rexy[j][0],rexy[j][1])
              elsif got_p(result[j],65) && Enemy_property.new(result[j]).got_event.include?([1])
                $game_switches[32]=true
                $game_variables[212].push(eresult[j])
                $game_map.events[eresult[j]].moveto(rexy[j][0],rexy[j][1])
                interpreter.setup(list, eresult[j])
                interpreter.update
                $game_switches[32]=false
              else
                $game_switches[53]=true
                interpreter.setup(list, eresult[j])
                interpreter.update
                $game_switches[53]=false
              end
            end
            $game_switches[136]=false
            break
          end
          Graphics.update
          # 刷新输入信息
          Input.update
          # 刷新画面
          $scene.get_spriteset.update
          $game_map.update
          # $game_system.map_interpreter.update
          $game_player.update
          # 系统 (计时器)、画面刷新
          $game_system.update
          $game_screen.update
        end
      break
      end
    end
 end
 def hunter_damage
   result=[]
   eresult=[]
   for i in $game_variables[190]
     value=$game_map.events[i]
      for number in 1...5
        direction=number*2
        sw=nil
        x=value.x
        y=value.y
        loop do
            xx=x
            yy=y
            x = $game_map.x_with_direction(x, direction)
            y = $game_map.y_with_direction(y, direction)
            break if !$game_map.valid?(x, y)
            bit = (1 << (direction / 2 - 1)) & 0x0f
            for k in [2, 1]
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
            bit = (1 << ( ( 10 - direction ) / 2 - 1)) & 0x0f
            for k in [2, 1]
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
            break if sw==false
            a=$game_map.check_event(x, y)
            if a>0
              if $game_map.events[a].name[0,6]=="怪物"
                id=$game_map.events[a].name[6,$game_map.events[a].name.length-6].to_i
                next if $data_enemies[id].element_ranks[104]==1
                if result[a]==nil
                  result[a]=[id]
                  eresult[a]=[a]
                end
                result[a].push(value.name[6,value.name.length-6].to_i)
                eresult[a].push(value.id)
              end
            end
          end
        end
        
    end
    #警戒怪
    for i in 0...$game_variables[142].size
      this=$game_map.events[$game_variables[142][i]]
      a=this.id
      if result[a]==nil
        result[a]=[this.event.name[6,this.event.name.length-6].to_i]
        eresult[a]=[a]
      end
      size=$game_variables[140][i]
      $game_map.events.each_value{|value|
        event = value.event
        if event.name[0,6]=="怪物" && value.character_name !="" && !value.erased? && !eresult[a].include?(value.id)
          if (value.x-this.x).abs+(value.y-this.y).abs<=size
            if $findpath.find_short_path(value.x,value.y,this.x,this.y,1) != []
              result[a].push(value.name[6,value.name.length-6].to_i)
              eresult[a].push(value.id)
            end
          end
        end
      }
    end
    #光环处理
    for i in $game_variables[139]
      this=$game_map.events[i[1]]
      $game_map.events.each_value{|value|
        event = value.event
        if event.name[0,6]=="怪物" && value.character_name !=""# && !value.erased?
          if (value.x-this.x).abs<=i[2]/2 && (value.y-this.y).abs<=i[3]/2
            if result[value.id]==nil
              result[value.id]=[event.name[6,event.name.length-6].to_i]
              eresult[value.id]=[value.id]
            end
            if !result[value.id].include?("|")
              result[value.id].push("|") 
            end
            result[value.id].push([i[0],i[4],i[1],value.id])
          end
        end
      }
    end
   # p result
    return result
  end
end
class Game_Event
  def reborn(id)
    @event_id=@event.id
    for i in $game_variables[41][@map_id]
      if !i.is_a?(Integer)
        if i[0]==@event_id && i[1][0,6]=="重生"
        $game_variables[41][@map_id].delete(i)
        end
      end
    end
    a=got_p_value(id,38)
    str=a.split("-")[0]
    if $game_variables[41].include?(@map_id)==false
      $game_variables[41][@map_id]=[]
    end
    $game_variables[41][@map_id].insert 0,[@event_id,"重生"+a]
    $game_map.events[@event_id].name="怪物"+str
    a=a.split("-")[1]
    a=a.split("&")
    $game_map.events[@event_id].character_name=a[0].sub("+") {"-"}
    $game_map.events[@event_id].direction=a[1].to_i
    $game_map.events[@event_id].character_hue=a[2].to_i
    $game_map.events[@event_id].pattern=0
  end
end