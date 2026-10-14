def check_monster_clear(l,r,del=[],del2=[])
  nocheck={}#赦免列表
  nocheck[[148,4]]=1
  nocheck[[99,7]]=1
  nocheck[[99,8]]=1
  nocheck[[85,8]]=1
  nocheck[[56,120]]=1
  nocheck[[65,115]]=1
  nocheck[[279,11]]=1
  str=[]
  for i in 0...8
    str[i]=""
  end
  count=0
  for t in l...r+1
    next if del.include?(t)
    if t%30==0
      Graphics.update
    end
    j=t
    map=nil
    if $new_map[j]==nil
      number=sprintf("Data/Map%03d.rxdata", j)
      if FileTest.exist?(number)
        map = load_data(number)
      end
    else
      map=$new_map[j].clone
    end
    if map !=nil
      events={}
      for i in map.events.keys
        events[i] = Game_Event.new(j, map.events[i] ,true)
      end
     # p events.size
      reborn=[]
      if $game_variables[41][t]!=nil
        for i in $game_variables[41][t]
          if !i.is_a?(Integer)
            if i[1][0,6]=="重生"
              str2=i[1].split("-")[0]
              reborn[i[0]]="怪物"+str2[6,str2.size-6]
            end
          end
        end
      end
      events.each_value{|value|
        event = value.event
        name=event.name
        name=reborn[value.id] if reborn[value.id]!=nil
        if name[0,6]=="怪物" && value.character_name !="" && !$game_self_switches[[j,event.id,"A"]] && nocheck[[j,event.id]]==nil
          if $data_enemies[name[6,name.length-6].to_i].exp>0
            next if del2.include?(name[6,name.length-6].to_i)
            if count<32
              if $game_switches[64]
                ss="第"+$data_mapname[j].name.split(":")[1]+"层"
              else
                ss=$data_mapname[j].name
              end
              str[count/4]+=ss+":"+$data_enemies[name[6,name.length-6].to_i].name.split(":")[0]+"\n"
            else
             # break
            end
            count+=1
          end
        end
      }
    end
  end
  if count>32
    $game_temp.message_text="当前未击杀怪物较多，总计"+count.to_s+"个，建议自行检查。"
  elsif count==0
    $game_temp.message_text="当前没有遗漏怪物，请继续前进吧。"
    $game_switches[170]=true
  else
    final=[]
    final.push(RPG::EventCommand.new(101,0,[]))
    final.push(RPG::EventCommand.new(101,0,["当前遗漏怪物总计"+count.to_s+"个"]))
    for i in 0...(count+3)/4
      final.push(RPG::EventCommand.new(101,0,[str[i]]))
    end
    b=RPG::EventCommand.new(354,0,[])
    final.push(b)
    $game_system.map_interpreter.setup(final, 0)
  end
  return count
end
def check_gem_clear(l,r,del=[])
  nocheck={}#赦免列表
  str=[]
  for i in 0...8
    str[i]=""
  end
  count=0
  for t in l...r+1
    next if del.include?(t)
    if t%30==0
      Graphics.update
    end
    j=t
    map=nil
    if $new_map[j]==nil
      number=sprintf("Data/Map%03d.rxdata", j)
      if FileTest.exist?(number)
        map = load_data(number)
      end
    else
      map=$new_map[j].clone
    end
    if map !=nil
      events={}
      for i in map.events.keys
        events[i] = Game_Event.new(j, map.events[i] ,true)
      end
      events.each_value{|value|
        event = value.event
        name=event.name
        if name[3,6]=="宝石" && value.character_name !="" && !$game_self_switches[[j,event.id,"A"]] && nocheck[[j,event.id]]==nil
          if count<32
            if $game_switches[64]
              ss="第"+$data_mapname[j].name.split(":")[1]+"层"
            else
              ss=$data_mapname[j].name
            end
            str[count/4]+=ss+":"+name.split(":")[0]+name.split(":")[1]+"点\n"
          end
          count+=1
        end
      }
    end
  end
  events={}
  if count>32
    $game_temp.message_text="当前未拾取能力较多，总计"+count.to_s+"个，建议自行检查。"
  elsif count==0
    $game_temp.message_text="当前没有遗漏能力，请继续前进吧。"
    $game_switches[170]=true
  else
    final=[]
    final.push(RPG::EventCommand.new(101,0,[]))
    final.push(RPG::EventCommand.new(101,0,["当前遗漏能力总计"+count.to_s+"个"]))
    for i in 0...(count+3)/4
      final.push(RPG::EventCommand.new(101,0,[str[i]]))
    end
    b=RPG::EventCommand.new(354,0,[])
    final.push(b)
    $game_system.map_interpreter.setup(final, 0)
  end
  return count
end



def check_hp_clear(l,r,del=[])
  nocheck={}#赦免列表
  str=[]
  for i in 0...8
    str[i]=""
  end
  count=0
  for t in l...r+1
    next if del.include?(t)
    if t%30==0
      Graphics.update
    end
    j=t
    map=nil
    if $new_map[j]==nil
      number=sprintf("Data/Map%03d.rxdata", j)
      if FileTest.exist?(number)
        map = load_data(number)
      end
    else
      map=$new_map[j].clone
    end
    if map !=nil
      events={}
      for i in map.events.keys
        events[i] = Game_Event.new(j, map.events[i])
      end
      events.each_value{|value|
        event = value.event
        name=event.name
        if name[0,6]=="血瓶" && $game_self_switches[[j,event.id,"A"]]
          count+=name.split(":")[1].to_i
        end
      }
    end
  end
  return count
end