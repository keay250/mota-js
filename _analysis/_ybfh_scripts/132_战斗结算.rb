module NMBattle
  module_function
  #战斗结算
  def Total(eid,battler)
    for i in $game_variables[193]
      case i[0]
      when 1 #重生
        $game_switches[32]=true
        $game_variables[212].push(eid)
      when 2 #中止战斗
        $game_switches[53]=true
        $game_variables[184]=[]
      end
    end
    q=0
    $game_variables[224]=battler.got_mirror
    for i in $game_variables[184]
      if $game_variables[224][q]!=nil
        q+=1;next
      end
      gd=$data_enemies[i].gold
      if $game_party.item_number(20)>0 #幸运金币
        gd*=2
      end
      k=0 #额外获得金钱系数
      #天赋判断
      if $game_variables[226]!=0
        k+=$game_variables[226][5]*0.01 #财富增殖
      end
      #附魔判断
      if $game_actors[1].equip_id.include?($game_variables[231]) && $game_variables[231]>0 #夜魔祭品
        if $game_variables[237]!=0
          for t in $game_variables[237]
            case t[0]
            when 12
              k+=0.01
            when 203
              k+=0.05
            end
          end
        end
      end
      gd+=(gd*k).to_i
      if $game_switches[65] #作弊模式
        gd*=2
      end
      ex=$data_enemies[i].exp
      $game_actors[$game_variables[1]+1].exp+=ex
      $game_party.gain_gold(gd)
      q+=1
    end
    #神圣劝化
    if $game_variables[184].size==1
      enemy=$data_enemies[$game_variables[184][0]]
      if enemy.maxhp>100 && !battler.got_p(138) && enemy.dex<=999
        $game_variables[234]=[] if $game_variables[234]==0
        $game_variables[234][$game_map.map_id]=$game_variables[184][0]
      end
    end
  end
end