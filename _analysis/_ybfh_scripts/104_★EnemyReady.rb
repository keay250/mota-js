module EnemyReady
 module_function
 def refresh
    if $game_variables[272] !=100
     if $game_variables[226]!=0
       $game_variables[272]=100
       for i in 0...$game_variables[272]+1
         if $game_variables[226][i]==nil
          $game_variables[226][i]=0
         end
       end
     end
   end
    $floorenemies=[]
    $game_variables[114]=[]
    $fleinfo=[]
    $fledam=[]
    $fleres=[]
    $flenum=[]
    $fleicon=[]
    $flespcost=[]
    $flesoulcost=[]
    $flehavedam=[]
    $supskill=[]
    $tuihua=false #退化光环
    $juewang=0 #绝望光环
    $jinmo=[1,0]
    $revenge=[] #复仇光环
    @allnum=[]
    $game_variables[51]=[]#隐性怪
    $game_variables[72]=[]#领域怪
    $game_variables[119]=[]#退敌怪
    $game_variables[129]=[]#精准射击怪
    $game_variables[121]=[]#夹击怪
    $jjc={}
    $game_variables[163]=0#亡灵协同
    $game_variables[190]=[]#猎手天赋
    $game_variables[142]=[]#警戒
    $game_variables[140]=[]#警戒范围
    $game_variables[139]=[]#范围光环合集
    $game_variables[211]={}#门的位置
    $game_variables[222]=[]#沙尘暴
    $game_variables[223]=[]#捕捉
    $game_variables[242]=[]#冻结事件
    $game_variables[280]=[]#追猎
    $game_switches[68]=false
    $event_damage={}
    if $sandstorm != nil
      for i in $sandstorm
        i.dispose
      end
    end
    $sandstorm=[]
    save_enemy=[]
    $game_variables[7]=0
    $game_map.events.each_value{ |value|
       @iid=value.id
       if (value.name[3,3]=="门" || value.name[6,3]=="门") && value.character_name!=""
         $game_variables[211][[value.x,value.y]]=1
       end
       if value.name[0,6]=="怪物" && value.character_name!=""
        @eid=value.name[6,value.name.length-6].to_i
        #获得怪物id
        new_enemy(@eid,@iid)
        #添加召唤列表
        if have_zhskill?(@eid)
          q=0
          elist=[@eid]
          while q<elist.size
            kk=0
            for i in 1...$data_enemies[elist[q]].element_ranks.xsize
              if $data_enemies[elist[q]].element_ranks[i]==1
                kk+=1 if $data_skills[i].description.split("\\v").size>1
                if $data_skills[i].scope==5
                  case i
                  when 30,64
                    a=$data_enemies[elist[q]].name.split(":")[kk]
                    a=a.split("&")
                    for j in a
                      b=j.split("-")
                      for k in 0...b[1].to_i
                        elist.push(b[0].to_i)
                        new_enemy(b[0].to_i,0)
                      end
                    end
                  when 135
                    a=$data_enemies[elist[q]].name.split(":")[kk]
                    a=a.split("&")
                    count=0
                    for j in a
                      if count==0
                        count+=1
                        next
                      end
                      b=j.split("-")
                      for k in 0...b[1].to_i
                        elist.push(b[0].to_i)
                        new_enemy(b[0].to_i,0)
                      end
                    end
                  when 49
                    elist.push(144)
                    new_enemy(144,0)
                  when 138
                    $game_variables[234]=[] if $game_variables[234]==0
                    a=$game_variables[234][$game_map.map_id]
                    $game_map.events[@iid].unerase
                    if a !=nil
                      elist.push(a)
                      save_enemy.push([a,@iid])
                    end
                  when 179
                    a=$data_enemies[elist[q]].name.split(":")[kk]
                    a=a.split("&")
                    for fl in a
                      new_enemy(fl.split("-")[1].to_i,0)
                    end
                  end
                end
              end
            end
            q+=1
          end
        end
      end
    }
    for i in save_enemy
      new_enemy(i[0],i[1],1)
    end
    $flenumCount=0
    for i in 0...$floorenemies.size
     s=@allnum.size
     @allnum.delete($floorenemies[i])
     $flenum[i]=s-@allnum.size
     $flenumCount+=$flenum[i]
    end
    @allnum=nil
    for i in 0...$floorenemies.size
#=begin
      result=[]
      savech={}
      for qi in $game_variables[139]
        if $data_enemies[$floorenemies[i]].element_ranks[qi[0]]==1
          next if savech[qi[0]]!=nil
          savech[qi[0]]=1
          result.push([qi[0],qi[4]])
        end
      end
#=end
     e=Enemy_property.new($floorenemies[i],0,result)
   #  e=Enemy_property.new($floorenemies[i])
     $fleinfo[i]=e
     $fledam[i]=e.got_damage
    end

    for i in 0...$floorenemies.size#怪物伤害排序
     for j in i...$floorenemies.size
      if $fledam[i]>$fledam[j]
       temp=$fledam[i]
       temp2=$floorenemies[i]
       $fledam[i]=$fledam[j]
       $floorenemies[i]=$floorenemies[j]
       $fledam[j]=temp
       $floorenemies[j]=temp2
       temp=$fleres[i]
       temp2=$flenum[i]
       temp=$fleinfo[i]
       $fleinfo[i]=$fleinfo[j]
       $flenum[i]=$flenum[j]
       $fleinfo[j]=temp
       temp=$fleicon[i]
       $fleicon[i]=$fleicon[j]
       $fleicon[j]=temp
       $flenum[j]=temp2
      end
     end
   end
   for i in 0...$floorenemies.size
     $fleres[i]=$fleinfo[i].got_nowin
     $flespcost[i]=$fleinfo[i].got_spcost
     $flesoulcost[i]=$fleinfo[i].got_soulcost
     $flehavedam[i]=$fleinfo[i].have_damage
   end
  end
  
  def new_enemy(i,id,mode=0)
    @allnum.push(i)
    actor=$game_actors[$game_variables[1]+1]
    if $floorenemies.include?(i)==false
      $floorenemies[$game_variables[7]]=i
        a=$data_enemies[i].battler_name
        if a !="" || id==0
          $fleicon[$game_variables[7]]=nil
        else
          a=$game_map.events[id]
          $fleicon[$game_variables[7]]=[a.character_name,a.character_hue,a.direction,a.pattern]
        end

      $game_variables[7]+=1

      if i==144 #倒影
        $data_enemies[i].name=actor.name
        if actor.level>=16
          $data_enemies[i].name+=":"+(actor.miss*100).to_s
          $data_enemies[i].element_ranks[6]=1
          $enemies_skills[i]=[6]
        else
          $data_enemies[i].element_ranks[6]=0
          $enemies_skills[i]=[]
        end
        $data_enemies[i].battler_name=actor.name
        $data_enemies[i].battler_hue=actor.battler_hue
        $data_enemies[i].str=actor.level
        a=$tuihua
        $tuihua=true
        $data_enemies[i].atk=actor.str
        $tuihua=a
        $data_enemies[i].pdef=actor.dex
        $data_enemies[i].maxhp=actor.hp
        if $game_variables[177]>=1
          $data_enemies[i].maxhp/=2
        end
        $data_enemies[i].agi=actor.atkspeed
        $data_enemies[i].eva=actor.shield
        $data_enemies[i].mdef=(1-actor.magicdef[1])*100
      end
    end
    

    if id>0
      if !actor.check_buff(6) && !actor.check_buff(7)
        if got_p(i,8) || got_p(i,105) || got_p(i,145) || got_p(i,176) || 
          got_p(i,204) || got_p(i,205)
          $game_variables[129].push(id)
        end#记录本层所有的精准射击怪
        if got_p(i,42)
          $game_variables[190].push(id)
        end#记录本层所有的猎手天赋怪
        if got_p(i,188)
          $game_variables[223].push(id)
          $game_variables[280].push(id)
        end#记录本层所有的猎手天赋怪
        if got_p(i,189) && mode==0
          $game_switches[68]=true
          $game_switches[67]=true
          $game_variables[281]={} if $game_variables[281]==0
          $game_variables[281][$game_map.map_id]={} if $game_variables[281][$game_map.map_id]==nil
          $game_variables[281][$game_map.map_id][id]=[1,got_p_value(i,189).to_f/100] if $game_variables[281][$game_map.map_id][id]==nil
        end#记录本层所有的至死方休怪
        if got_p(i,52)
         $game_variables[119].push(id)
        end#记录本层所有的阻击怪
        if got_p(i,53)
          $game_variables[121].push(id)
          ev=$game_map.events[id]
          val=got_p_value(i,53).to_i
          if $jjc[[ev.x,ev.y]]==nil
            $jjc[[ev.x,ev.y]]=val
            spr=Sprite_JLight.new(id,0,0)
            spr.bitmap=RPG::Cache.picture("light")
            spr.src_rect=Rect.new(0,0,32,68)
            spr.blend_type=0
            spr.opacity=255
            spr.tone=$mapdamage_obj.gettone(0)
            spr.z=1
            spr.ox=16;spr.oy=34
            x=ev.x-2;y=ev.y
            
            if $jjc[[x,y]]==val && $game_map.passable?(x+1,y,4)
              spr.angle=90
              $sandstorm.push(spr_clone3(spr,0-32-38,0))
            end
            x=ev.x+2;y=ev.y
            if $jjc[[x,y]]==val && $game_map.passable?(x-1,y,6)
              spr.angle=90
              $sandstorm.push(spr_clone3(spr,0+32-38,0))
            end
            x=ev.x;y=ev.y-2
            if $jjc[[x,y]]==val && $game_map.passable?(x,y+1,2)
              spr.angle=0
              $sandstorm.push(spr_clone3(spr,0-16,0-48-32))
            end
            x=ev.x;y=ev.y+2
            if $jjc[[x,y]]==val && $game_map.passable?(x,y-1,8)
              spr.angle=0
              $sandstorm.push(spr_clone3(spr,0-16,0-48+32))
            end
            spr.dispose
          else
            $jjc[[ev.x,ev.y]]+=val
          end
        end#记录本层所有的夹击怪
        if got_p(i,207)
          a=got_p_value(i,207).split("-")
          w=a[0].to_i-1
          h=a[1].to_i-1
          val=a[2].to_i
          xx=$game_map.events[id].x-w/2
          yy=$game_map.events[id].y-h/2
          $game_map.events.each_value{ |ev|
            if ev.name[0,6]=="怪物" && ev.character_name !=""
              if ev.x>=xx && ev.x<=xx+w && ev.y>=yy && ev.y<=yy+h
                $game_variables[121].push(ev.id)
                if $jjc[[ev.x,ev.y]]==nil
                  $jjc[[ev.x,ev.y]]=val
                  spr=Sprite_JLight.new(ev.id,0,0)
                  spr.bitmap=RPG::Cache.picture("light")
                  spr.src_rect=Rect.new(0,0,32,68)
                  spr.blend_type=0
                  spr.opacity=255
                  spr.tone=$mapdamage_obj.gettone(0)
                  spr.z=1
                  spr.ox=16;spr.oy=34
                  x=ev.x-2;y=ev.y
                  if $jjc[[x,y]]==val && $game_map.passable?(x+1,y,4)
                    spr.angle=90
                    $sandstorm.push(spr_clone3(spr,0-32-38,0))
                  end
                  x=ev.x+2;y=ev.y
                  if $jjc[[x,y]]==val && $game_map.passable?(x-1,y,6)
                    spr.angle=90
                    $sandstorm.push(spr_clone3(spr,0+32-38,0))
                  end
                  x=ev.x;y=ev.y-2
                  if $jjc[[x,y]]==val && $game_map.passable?(x,y+1,2)
                    spr.angle=0
                    $sandstorm.push(spr_clone3(spr,0-16,0-48-32))
                  end
                  x=ev.x;y=ev.y+2
                  if $jjc[[x,y]]==val && $game_map.passable?(x,y-1,8)
                    spr.angle=0
                    $sandstorm.push(spr_clone3(spr,0-16,0-48+32))
                  end
                  spr.dispose
                else
                  $jjc[[ev.x,ev.y]]+=val
                end
              end
            end
          }
        end#幻末之墙
        if got_p(i,59)
         $game_variables[142].push(id)
         $game_variables[140].push(got_p_value(i,59).to_i)
        end#记录本层所有的警戒怪及其范围
        if got_p(i,114) #潜影
          if !$game_switches[158]
            $game_variables[223].push(id)
            xx=($game_map.events[id].x-$game_player.x).abs
            yy=($game_map.events[id].y-$game_player.y).abs
            if xx+yy>1 && $game_map.events[id].opacity>0
              $game_map.events[id].erase
            end
          else
           $game_map.events[id].unerase
          end
        end
      else #截止到这里潜伏状态下不会触发
        if got_p(i,114) #潜影
          if !$game_switches[158]
            $game_map.events[id].erase
          else
             $game_map.events[id].unerase
          end
        end
        if got_p(i,177)
          spr=Sprite_Eye.new(id,0,18)
          spr.bitmap=RPG::Cache.picture("eyes")
          spr.z=41
          spr.zoom_x=0.8;spr.zoom_y=0.8
          spr.ox=16;spr.oy=16
           
          a=got_p_value(i,177)
          a=a.split("-")
          this=$game_map.events[id]
          $game_map.events.each_value{ |value|
            ev2=value.event
            if ev2.name[0,6]=="怪物" && value.character_name !=""
              if (value.x-this.x).abs<=a[0].to_i/2 && (value.y-this.y).abs<=a[1].to_i/2
                if !$game_variables[223].include?(ev2.id)
                  $game_variables[223].push(ev2.id) 
                  spr.event_id=value.id
                  $sandstorm.push(spr_clone5(spr,0,0))
                end
              end
            end
          }
          spr.dispose
        end
     end #真视效果专打隐身
     if $game_switches[166] #妖精之泉夜间
        if i==394 || i==419
        $game_map.events[id].erase
        end
      end

      if got_p(i,155) #冻结之域
          a=got_p_value(i,155).split("-")
          $game_variables[72].push([id,1,[a[0].to_i,a[1].to_i],a[2].to_f])
          ev=$game_map.events[id]
          w=a[0].to_i/2
          h=a[1].to_i/2
          x1=ev.x-w
          x2=ev.x+(a[0].to_i-1-w)
          y1=ev.y-h
          y2=ev.y+(a[1].to_i-1-h)
          $game_map.events.each_value{ |ev2|
            next if $game_variables[242].include?(ev2.id)
            new_x=ev2.x
            new_y=ev2.y
            if new_x>=x1 && new_x<=x2 && new_y>=y1 && new_y<=y2
              if ev2.name[0,6]=="血瓶" || ev2.name[0,6]=="魔法" || ev2.name[3,6]=="钥匙" ||
                 ev2.name[3,6]=="宝石" || ev2.name[3,3]=="门" || ev2.name[0,6]=="生命"
                
                spr=Sprite_Ice.new(ev2.id,0,0)
                spr.bitmap=RPG::Cache.picture("ice")
                spr.opacity=255
                spr.ox=24;spr.oy=24
                if ev2.name[3,3]!="门"
                  spr.z=1
                  spr.tone=$mapdamage_obj.gettone(1)
                  spr.src_rect=Rect.new(ev2.id%3*48+48,0,48,48)
                  ev2.erase
                else
                  spr.opacity=125
                 # spr.tone=$mapdamage_obj.gettone(2)
                  spr.z=ev2.screen_z+1
                  spr.src_rect=Rect.new(0,0,48,48)
                end
                $sandstorm.push(spr_clone4(spr,-24,-42))
                spr.dispose
                $game_variables[242].push(ev2.id)
              end
            end
          }
      end
     if got_p(i,112) #沙尘暴
       $game_variables[222].push(id)
       if !$game_switches[158]
         $game_map.events[id].erase
       else
         $game_map.events[id].unerase
       end
       l=got_p_value(i,112).split("-")[0].to_i
     #  ev=$game_map.events[id]
       spr=Sprite_Sandstorm.new(id,0,0)
       spr.bitmap=RPG::Cache.picture("sandstorm")
       spr.opacity=90
       spr.z=41
       spr.ox=48;spr.oy=48
       case l
       when 1
         $sandstorm.push(spr_clone2(spr,0,0))
       when 2
         $sandstorm.push(spr_clone2(spr,0,-32))
         $sandstorm.push(spr_clone2(spr,0,32))
         $sandstorm.push(spr_clone2(spr,-32,0))
         $sandstorm.push(spr_clone2(spr,32,0))
      when 4
         $sandstorm.push(spr_clone2(spr,0,-32))
         $sandstorm.push(spr_clone2(spr,0,32))
         $sandstorm.push(spr_clone2(spr,-32,0))
         $sandstorm.push(spr_clone2(spr,32,0))
         $sandstorm.push(spr_clone2(spr,0,-96))
         $sandstorm.push(spr_clone2(spr,0,96))
         $sandstorm.push(spr_clone2(spr,-96,0))
         $sandstorm.push(spr_clone2(spr,96,0))
         $sandstorm.push(spr_clone2(spr,-32,-64))
         $sandstorm.push(spr_clone2(spr,-32,64))
         $sandstorm.push(spr_clone2(spr,32,-64))
         $sandstorm.push(spr_clone2(spr,32,64))
         $sandstorm.push(spr_clone2(spr,-64,-32))
         $sandstorm.push(spr_clone2(spr,-64,32))
         $sandstorm.push(spr_clone2(spr,64,-32))
         $sandstorm.push(spr_clone2(spr,64,32))
       end
       spr.dispose
      end
      if got_p(i,213)
        val=got_p_value(i,213).split("-")
        w=val[0].to_i/2
        h=val[1].to_i/2
        ev=$game_map.events[id]
        check=false
        $game_map.events.each_value{ |oev|
          next if oev.id==id
          if (oev.x-ev.x).abs<=w && (oev.y-ev.y).abs<=h
            if oev.name[0,6]=="怪物" && oev.character_name!=""
              check=true
              break
            end
          end
        }
        if !check
          $game_variables[139].push([213,id,1,1,i.to_s+"-"+val[2]+"-"+val[3]])
        end
      end#傲慢之心判定
      
      areasup(i,id,100)#神力图腾
      areasup(i,id,101)#守护图腾
      areasup(i,id,102)#治愈图腾
      areasup(i,id,103)#破甲光环
      areasup(i,id,110)#风之守护
      areasup(i,id,128)#荆棘光环
      areasup(i,id,133)#霜冻光环
      areasup(i,id,136)#血战誓约
      areasup(i,id,144)#竭心光环
      areasup(i,id,159)#能源之岚
      areasup(i,id,177)#真视领域
      areasup(i,id,178)#镜壁领域
      areasup(i,id,184)#焚灭之域
      areasup(i,id,189)#至死方休
      areasup(i,id,194)#强体光环
      areasup(i,id,196)#震荡领域
      areasup(i,id,197)#阳炎冲击
      areasup(i,id,219)#不朽之域
    end
    if got_p(i,3) #亡灵协同
      $game_variables[163]+=1
    end
    pushsup(i,33) #洗礼
    pushsup(i,34) #驱逐
    pushsup(i,35) #退化光环
    pushsup(i,67) #绝望光环
    pushsup(i,71) #复仇光环
    pushsup(i,91) #精气光环
    pushsup(i,92) #奥术光环
    pushsup(i,148) #活体护甲
    pushsup(i,156) #禁魔光环
    pushsup(i,158) #幽冥守卫
    pushsup(i,198) #壮烈成仁
    pushsup(i,210) #回溯共鸣
  end
  def pushsup(i,kind,id=0)
    if got_p(i,kind)
      if kind==71
        $revenge=got_p_value(i,71)
        return
      end
      if kind==35
        $tuihua=true
      end
      if kind==67
        actor=$game_actors[$game_variables[1]+1]
        $juewang=[$juewang,actor.shield*got_p_value(i,67).split("-")[0].to_f/100].max
        if $game_variables[177]==2
          $juewang/=2
        end
      end
      if kind==156 #禁魔光环
        $jinmo[0]+=got_p_value(i,156).split("-")[1].to_f/100
      end
      if kind==158 #幽冥守卫
        $jinmo[1]-=got_p_value(i,158).split("-")[0].to_f if $jinmo[1]==0
      end
      kk=0
      for q in $enemies_skills[i]
          kk+=1 if $data_skills[q].description.split("\\v").size>1
          if q==kind      
            if kind==92#奥术光环叠加
              check=false
              for sk in $supskill
                if sk[0]==kind
                  sk[1]=(sk[1].to_i+$data_enemies[i].name.split(":")[kk].split("&")[0].to_i).to_s
                  check=true
                  break
                end
              end
              next if check
            end
            #更强的光环取代原有同类光环
            if $data_skills[q].scope==4
              for sk in $supskill
                if sk[0]==kind && sk[1].split("-")[0].to_f<$data_enemies[i].name.split(":")[kk].split("-")[0].to_f
                  $supskill.delete(sk)
                end
              end
            end
            $supskill.push([kind,$data_enemies[i].name.split(":")[kk].split("&")[0]])
            break
          end
      end
    end
  end
  def areasup(i,id,kind)
    if got_p(i,kind)
      a=got_p_value(i,kind)
      b=a.clone
      a=a.split("-")
      if $data_skills[kind].scope==4
        l=a[0].size+a[1].size+2
        $game_variables[139].push([kind,id,a[0].to_i,a[1].to_i,b[l,b.size-l]])
      else
        $game_variables[139].push([kind,id,1,1,b])
      end
    end
  end
  def have_zhskill?(id)
    c=[30,49,64,135,138,179]
    for i in c
      if $data_enemies[id].element_ranks[i]==1
        return true
      end
    end
    return false
  end
  def battle1
    $game_map.events.each_value{ |ev|
      i=ev.id
      x=(ev.x-$game_player.x).abs
      y=(ev.y-$game_player.y).abs
      if x+y<=1
        save_d=$game_player.direction
        sx = $game_map.events[i].x - $game_player.x
        sy = $game_map.events[i].y - $game_player.y
        if sx.abs > sy.abs
          sx < 0 ? $game_player.turn_left : $game_player.turn_right
        else
          sy < 0 ? $game_player.turn_up : $game_player.turn_down
        end
        x2=$game_map.events[i].x
        y2=$game_map.events[i].y
        d=$game_player.direction
        if !$game_map.passable?(x2,y2, 10-d)
          $game_player.set_direction(save_d)
          next
        end
        x2 = $game_map.x_with_direction(x2, 10-d)
        y2 = $game_map.y_with_direction(y2, 10-d)
        if !$game_map.passable?(x2,y2, d)
          $game_player.set_direction(save_d)
          next
        end
        event=ev.event
        if event.name[0,6]=="怪物" && !$game_self_switches[[$game_map.map_id,event.id,"A"]]
          $game_map.events[i].unerase
          $game_map.events[i].start
          Graphics.update
          Input.update
          $scene.update
          while $game_system.map_interpreter.running?
            break if $game_actors[$game_variables[1]+1].hp<=0
            Graphics.update
            Input.update
            $scene.update
          end
        else
          $game_player.set_direction(save_d)
          next
        end
      end
    }
  end
end

