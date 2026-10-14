class Enemy_property
  #--------------------------------------------------------------------------
  # ● 初始化状态
  #--------------------------------------------------------------------------
  def battle_init
    $nowbattle=true
    @actor=$game_actors[$game_variables[1]+1]
    @mofang=0
    if $game_variables[226]!=0#天赋开启 匙之力
      if $game_variables[226][6]<=6
        p=$game_variables[226][6]
      else
        p=10**($game_variables[226][6]-6)
      end
      @mofang+=$game_actors[$game_variables[1]+1].keys_number*p
      for ccc in @actor.states
        @mofang *= $data_states[ccc].int_rate / 100.0
      end
    end
    @table=[false,true,false,false,false,false,false]
    @animation=[]
    if @enemyid.is_a?(Integer)
      @elist=[@enemyid]
    else
      @elist=@enemyid
      @enemyid=@enemyid[0]
    end
    @emirror=[] #幻象标志记录
    @estatus=[] #判断是否赋予debuff
    @afterevent=[]
    #召唤技能
    q=0
    while q<@elist.size
      kk=0
      for i in $enemies_skills[@elist[q]]
          kk+=1 if $data_skills[i].description.split("\\v").size>1
          if $data_skills[i].scope==5 && @emirror[q]==nil #幻象不能用技能
            case i
            when 30,64 #通灵召唤/小队作战
              a=$data_enemies[@elist[q]].name.split(":")[kk]
              a=a.split("&")
              if i==64
                @elist.delete_at(q)
                q-=1
              end
              for j in a
                b=j.split("-")
                for k in 0...b[1].to_i
                  @elist.push(b[0].to_i)
                end
              end
            when 135 #结阵作战
              a=$data_enemies[@elist[q]].name.split(":")[kk]
              a=a.split("&")
              @elist.delete_at(q)
              q-=1
              count=0
              for j in a
                if count==0
                  @estatus[135]=j
                  count+=1
                  next
                end
                b=j.split("-")
                for k in 0...b[1].to_i
                  @elist.push(b[0].to_i)
                end
              end
            when 41 #惑幻
              a=$data_enemies[@elist[q]].name.split(":")[kk]
              a=a.split("-")
              for j in 0...a[0].to_i
                @emirror[@elist.size]=a[1]+"-"+a[2]
                @elist.push(@elist[q])
              end
            when 49 #倒影
              a=$data_enemies[@elist[q]].name.split(":")[kk]
              a=a.split("-")
              @emirror[@elist.size]="100-100"
              @elist.push(144)
            when 138 #神圣劝化
              if $game_variables[234][$game_map.map_id]!=nil
                @emirror[@elist.size]="100-100"
                @elist.push($game_variables[234][$game_map.map_id])
              end
            when 179 #分则能成
              a=$data_enemies[@elist[q]].name.split(":")[kk]
              @afterevent.push([11,a])
            end
          end
      end
      q+=1
    end
    @eskill=[]
    for i in 0...@elist.size
      @eskill[i]=[]
    end
    @mskill=[]
    @mlevel=@actor.level
    @spcost=0 #魔法消耗
    @soulcost=0 #灵魂消耗
    @mmaxhp=@actor.maxhp#基础勇生命
    @mhp=@actor.hp#基础勇生命
    @ma=@actor.str#基础勇攻
    @md=@actor.dex#基础勇防
    @mmd=@actor.int#基础勇魔防
    @mvampire=@actor.vampire
    @mbkb=0
    @mdcskill=0
    @elevel=[]
    @ea=[]
    @ed=[]
    @ehp=[]
    @emaxhp=[]
    @emakedamage=[]
    @eskilldamage=[]
    @enodamage=[]
    @edecdamage=[]
    @enomagic=[]
    @edecmagic=[]
    @evampire=[]
    @ecombo=[]
    @ecrit=[]
    @ecritvalue=[]
    @ehitrate=[]
    @emiss=[]
    @emisszero=[]
    @ebkb=[]
    @edead=[]
    @oldeshield=[]
    @eshield=[]
    for i in 0...@elist.size
      @elevel[i]=$data_enemies[@elist[i]].str#怪等级
      @ea[i]=$data_enemies[@elist[i]].atk#怪攻
      @ed[i]=$data_enemies[@elist[i]].pdef#怪防
      @ehp[i]=$data_enemies[@elist[i]].maxhp#怪生命
      @ecombo[i]=$data_enemies[@elist[i]].agi
      if @elevel[i]>=16
        @oldeshield[i]=$data_enemies[@elist[i]].eva
        @enomagic[i]=(100-$data_enemies[@elist[i]].mdef)/100.0  #怪物百分比减伤（魔法）
      else
        @oldeshield[i]=0
        @enomagic[i]=1
      end
      @oldeshield[i]-=@actor.armorbreak
      @eshield[i]=@actor.rshield(@oldeshield[i])
      @emaxhp[i]=@ehp[i]#怪生命
      @emakedamage[i]=1 #怪物造成伤害（物理）
      @eskilldamage[i]=1 #怪物造成伤害（魔法）
      @enodamage[i]=1  #怪物百分比减伤（物理）
      @edecdamage[i]=0 #怪物固定减伤（物理）
      @edecmagic[i]=0 #怪物固定减伤（魔法）
      @evampire[i]=0 #敌人吸血百分比
      @ecrit[i]=1
      @ecritvalue[i]=1
      @ehitrate[i]=1
      @emiss[i]=1
      @emisszero[i]=0
      @ebkb[i]=0  #是否魔免，0为不魔免，1为魔免，2为全能魔免（可净化）
      @edead[i]=false
      if @emirror[i]!=nil #幻象设置
        a=@emirror[i].split("-")
        @enodamage[i]*=a[1].to_f/100
        @enomagic[i]*=a[1].to_f/100.0
        @emakedamage[i]*=a[0].to_f/100
      end
    end
    @mcombo=@actor.atkspeed
    @mmiss=1-@actor.miss
    @mmisszero=0
    @mhpre=@actor.hprecover
    @mhprerate=1
    @msprerate=1
    @oldmshield=@actor.shield
    self.mshield=@actor.rshield
    @mphysicaldef=1 #受到物理伤害的系数
    @mdecdamage=@actor.defence #物理伤害格挡
    @mmagicdef=@actor.magicdef #魔抗（包括百分比和固定）
    @mskilldef=1 #受到魔法伤害的系数
    @mskilldam=@actor.skilldam #魔法伤害系数
    @mequip=@actor.equip_id
    if $game_variables[232]!=0
      @mallbuffsave=$game_variables[232].clone
    end
    @poison=0#$game_variables[192] #中毒效果
    @mcrit=1
    @mhitrate=@actor.hitrate #命中及伤害系数
    @kind=0#属性种数
    for i in 0...@actor.skills.size
      @mskill[i]=0
    end
    
    #部分天赋处理
    if $game_variables[226]!=0 #天赋开启
      #绝境挣扎
      if $game_variables[226][19]!=nil
        val=(1-$game_variables[226][19]*0.04)
        if $game_variables[226][19]==5
          if @actor.keys_number3
            @mphysicaldef*=val
            @mmagicdef[1]*=val
          end
        else
          if @actor.keys_number2
            @mphysicaldef*=val
            @mmagicdef[1]*=val
          end
        end
      end
      #虚弱抵抗
      if $game_variables[226][24]!=nil && $game_variables[226][24]>0
        if @actor.get_buff_time(9)>0
          val=(1-$game_variables[226][24]*0.03)
          @mphysicaldef*=val
          @mmagicdef[1]*=val
        end
      end
    end
    
    #怪物技能加载
    kk=[]
    zdskill=[]
    zdvalue=[]
    zdnum=[]
    @kind=[]
for q in 0...@elist.size
    zdskill[q]=[]
    zdvalue[q]=[]
    zdnum[q]=[]
    @kind[q]=0
    kk[q]=0
    for i in $enemies_skills[@elist[q]]

        @kind[q]+=1
        if $data_skills[i].scope==5
          if $data_skills[i].description.split("\\v").size>1
            kk[q]+=1
          end
        end
        if $data_skills[i].scope==3 || $data_skills[i].scope==4
          if $data_skills[i].description.split("\\v").size>1
             kk[q]+=1
            @eskill[q][i]=$data_enemies[@elist[q]].name.split(":")[kk[q]]
          else
            @eskill[q][i]=0
          end
        end
        if $data_skills[i].scope<=2
          if $data_skills[i].description.split("\\v").size>1
            kk[q]+=1
            s=$data_enemies[@elist[q]].name.split(":")[kk[q]]
            zdnum[q][zdskill[q].size]=s.split("&")[1]
            if zdnum[q][zdskill[q].size]==nil
              zdnum[q][zdskill[q].size]=999+zdskill[q].size
            else
              zdnum[q][zdskill[q].size]=zdnum[q][zdskill[q].size].to_i
            end
          else
            zdnum[q][zdskill[q].size]=999+zdskill[q].size
          end
          zdskill[q].push(i)
          if $data_skills[i].description.split("\\v").size>1
            zdvalue[q].push(s.split("&")[0]) 
          else
            zdvalue[q].push("")
          end
        end

    end
    for i in 0...zdskill[q].size
     for j in i...zdskill[q].size
      if zdnum[q][i]>zdnum[q][j]
       temp=zdnum[q][i]
       zdnum[q][i]=zdnum[q][j]
       zdnum[q][j]=temp
       temp=zdskill[q][i]
       zdskill[q][i]=zdskill[q][j]
       zdskill[q][j]=temp
       temp=zdvalue[q][i]
       zdvalue[q][i]=zdvalue[q][j]
       zdvalue[q][j]=temp
      end
     end
   end
 end
 @oldmcombo=@mcombo #老攻速
    @oldecombo=[]
    for q in 0...@elist.size
      @oldecombo[q]=@ecombo[q]
    end
    #以下是玩家被动
      if @mequip.include?(18) #寒铁钢爪
        for q in 0...@elist.size
          if @mlevel>=@elevel[q] && @elevel[q]<12
            @enodamage[q]*=1.4
          end
        end
      else
        if @mequip.include?(16) #压制之刃
          for q in 0...@elist.size
            if @mlevel>=@elevel[q] && @elevel[q]<12
              @enodamage[q]*=1.32
            end
          end
        end
      end
    if @mequip.include?(25) || @mequip.include?(31) #水晶剑
      @mcrit*=1.15
    end
    if @mequip.include?(51)#水晶剑二阶
      if $game_variables[181][51]==-1
        @mcrit*=2
        @ma-=1250
      else
        @mcrit*=1.2
      end
    end
    if @mequip.include?(63)#水晶剑（寒冰）
      @mcrit*=1.2
      for q in 0...@elist.size
        @oldecombo[q]-=30
        @ecombo[q]=Math.sqrt([@oldecombo[q],0].max)/10.0
      end
    end
    if @mequip.include?(131)#血棘
      @mcrit*=1.6
    end
    if @mequip.include?(89) || @mequip.include?(123)#洞察烟斗&紫苑
      for q in 0...@elist.size
        if @enomagic[q]<=1
          @enomagic[q]=1-(1-@enomagic[q])*0.7
        end
      end
    end
    if @mequip.include?(131)#血棘
      for q in 0...@elist.size
        if @enomagic[q]<=1
          @enomagic[q]=1-(1-@enomagic[q])*0.7
        end
      end
    end
    if $game_switches[183] #星界BUFF
      @mvampire=0
    end
    @firstmiss=[]
    @edamage=0
    @alldamage=0
    if $game_variables[232]!=0
      for j in $game_variables[232]
        if j[0]==4 #恢复神符
          self.edamage-=@actor.maxhp/10.0
          @spcost-=@actor.maxsp/10.0
          if @actor.sp-@spcost>@actor.maxsp
            @spcost+=@actor.sp-@spcost-@actor.maxsp
          end
        end
      end
    end
    @havedamage=false
    @eturn=[]
    @eturnr=[]
    @efight=[] #怪物行动列表
    @efightvalue=[] #怪物行动数值
    @ecanattack=[] #怪物是否被缴械标记（或者处于吟唱状态）
    @epassbreak=[]
    @ecanspell=[] #怪物是否被沉默被标记
    @edebuff=[]
    @lsvar=[]
    @epassskill=[] #可被破坏的怪物被动列表
    #以下是永久怪物被动        
  for q in 0...@elist.size  
    @edebuff[q]=[]
    @firstmiss[q]=0
    @epassskill[q]=[]
    @epassbreak[q]=0 #怪物是否被破坏标记（禁用部分被动）
    if have_skill(q,99) #镜像
      @ea[q]=@ma
      @ed[q]=@md
    end
    if have_skill(q,107) #无影拳 \v
      @oldecombo[q]-=$data_enemies[@elist[q]].agi-$game_actors[$game_variables[1]+1].atkspeed*@eskill[q][107].to_f
    end 
    if have_skill(q,3) #亡灵协同 \v
      @ehp[q]*=(1+@eskill[q][3].to_i*($game_variables[163]-1)/100.0)
      @emaxhp[q]=@ehp[q]
      for i in @mequip
        case i
        when 6
          @ea[q]-=5
        when 15
          @ea[q]-=50
        end
      end
      if $game_variables[226]!=0 #天赋开启
        if $game_variables[226][18]!=nil && !have_skill(q,18) #亡灵克星
          @emakedamage[q]*=(1-$game_variables[226][18]*0.05)
          @enodamage[q]*=(1+$game_variables[226][18]*0.05)
          self.edamage-=@actor.maxhp/200.0 if $game_variables[226][18]==6
        end
      end
    end
    if have_skill(q,4) #嗜血本能 \v
      enemy_new_pass(q,4)
    end
    if have_skill(q,5) #上位者威压 \v
      enemy_new_pass(q,5)
    end
    if have_skill(q,6) #闪避 \v
      enemy_new_pass(q,6)
    end
    if have_skill(q,54) #模糊 \v
      @emiss[q]*=(1-@eskill[q][54].to_f/100)
      @firstmiss[q]=2
    end
    if have_skill(q,14) #皮肤硬化 \v
      enemy_new_pass(q,14)
    end
    if have_skill(q,55) #幽魂形态 \v
      enemy_new_pass(q,55)
    end
    if have_skill(q,32) #魔法抗性 \v
      enemy_new_pass(q,32)
    end
    if have_skill(q,9) #领主光环 \v\v\v
      a=@eskill[q][9].split("-")
      b=(1-a[0].to_f/100.0)
      @ma*=b;@md*=b
      @oldmcombo-=a[1].to_f
      @enodamage[q]*=(1-a[2].to_f/100.0)
      @enomagic[q]*=(1-a[2].to_f/100.0)
    end
    if have_skill(q,13) #致命一击 \v\v
      a=@eskill[q][13].split("-")
      b=a[0].to_f/100
      a=a[1].to_f
      @ecrit[q]*=1+b*(a-1)
      @ecritvalue[q]*=a
    end
    if have_skill(q,18) #魔法免疫
      enemy_new_pass(q,18)
    end
    if have_skill(q,31) #混沌一击 \v\v
      a=@eskill[q][31].split("-")
      b=a[0].to_f/100
      a=a[1].to_f
      @ecrit[q]*=1+b*(a-1)
      @ecritvalue[q]*=a
    end
    if have_skill(q,21) #过载 \v\v\v
      a=@eskill[q][21].split("-")
      @oldecombo[q]+=a[1].to_f
      @enodamage[q]*=(1-a[2].to_f/100.0)
    end
    if have_skill(q,45) #剧毒皮肤 \v\v\v
      a=@eskill[q][45].split("-")
      @enodamage[q]*=(1-a[0].to_f/100.0)
      @enomagic[q]*=(1-a[0].to_f/100.0)
      @oldmcombo-=a[1].to_f
      @oldmshield-=a[2].to_f
      self.mshield=@actor.rshield(@oldmshield)
    end
    if have_skill(q,46) #龙裔血脉 \v\v\v
      enemy_new_pass(q,46)
    end
    if have_skill(q,68) #生命吸取 \v
      a=@eskill[q][68]
      @evampire[q]+=a.to_f/100.0
    end
    if have_skill(q,206) #恩赐解脱
      a=@eskill[q][206].split("-")
      @ecrit[q]=0
      @ecritvalue[q]=0
      @evampire[q]+=a[3].to_f/100
      @edebuff[q].push([a[2].to_i,206,q,a[3].to_f/100,false])
    else
      if have_skill(q,72) #剑舞 \v\v
        a=@eskill[q][72].split("-")
        b=a[0].to_f/100
        a=a[1].to_f
        if a*@ea[q]>@md
          save=@ea[q]
          @ea[q]=@md+([a*@ea[q]-@md,0].max)*b+([@ea[q]-@md,0].max)*(1-b)
          @ecritvalue[q]*=(save*a-@md)/(@ea[q]-@md)
        end
      end
    end
    if have_skill(q,86) #暗夜猎影 \v\v\v\v
      if $game_map.effect_surface.alpha>50
        a=@eskill[q][86].split("-")
        @ea[q]=(@ea[q]*(1+a[0].to_f/100)).to_i
        @ecombo[q]+=a[1].to_i
        @emiss[q]*=(1-a[2].to_f/100)
        @firstmiss[q]=1 if @firstmiss[q]<1
        @mturn=-1
        @estatus[86]=a[3].to_i
      end
    end
    if have_skill(q,104) #狂战士之血
      @evampire[q]+=@eskill[q][104].split("-")[2].to_f/100.0
      @estatus[104]=[] if @estatus[104]==nil
      @estatus[104][q]=@ehp[q]
    end
    if have_skill(q,153) #不朽之力 \v
      a=@eskill[q][153].split("-")
      if @eskill[q][26]==nil
        @eskill[q][26]=a[2].to_f
      else
        @eskill[q][26]=@eskill[q][26].to_f+a[2].to_f
      end
      if @eskill[q][149]==nil
        @eskill[q][149]=a[1].to_f
      else
        @eskill[q][149]=@eskill[q][149].to_f+a[1].to_f
      end
      enemy_new_pass(q,153)
    end
    if have_skill(q,155) #冰结领域解冻
      @afterevent.push([9,@eskill[q][155].split("-")])
    end
    if have_skill(q,157) #军团作战
      a=@eskill[q][157].split("-")
      @emakedamage[q]*=a[0].to_f
      b=a[1].to_f/100
      if @ma>@ea[q]
        @ea[q]+=(@ma-@ea[q])*b
      end
      if @md>@ed[q]
        @ed[q]+=(@md-@ed[q])*b
      end
    end
    if have_skill(q,191) #刚毅不屈
      a=@eskill[q][191].split("-")
      @eskill[q][191]=a[0]+"-"+@md.to_s
      @ed[q]+=@md*a[0].to_f/100
    end
    if have_skill(q,189) && @eid>0 #至死方休
      if $game_variables[281][$game_map.map_id]!=nil && $game_variables[281][$game_map.map_id][@eid]!=nil
        @emakedamage[q]*=$game_variables[281][$game_map.map_id][@eid][0]
        @eskilldamage[q]*=$game_variables[281][$game_map.map_id][@eid][0]
      end
    end
    if have_skill(q,203) #海妖外壳
      enemy_new_pass(q,203)
    end
    if have_skill(q,210) #回溯共鸣
      a=@eskill[q][210].split("-")
      b=$flenumCount-1
      @ea[q]*=(1+b*a[0].to_f/100)
      @ed[q]*=(1+b*a[1].to_f/100)
    end
    if have_skill(q,212) #认知干扰
      a=@eskill[q][212].split("-")
      @mphysicaldef*=(1+a[0].to_f/100.0)
      @mmagicdef[1]*=(1+a[0].to_f/100.0)
      @enodamage[q]*=(1+a[1].to_f/100.0)
      @enomagic[q]*=(1+a[1].to_f/100.0)
    end
    if have_skill(q,66) #最低伤害
      @ebkb[q]=1
    end
    if have_skill(q,70) #破甲熔炎 \v
      @edebuff[q].push([999,70,0,q,true])
    end 
    if have_skill(q,217) #怒意狂击
      @eskill[q][217]=@eskill[q][217].to_f
      if @estatus[217]==nil
        @estatus[217]=[]
      end
      @estatus[217][q]=0
    end
    if have_skill(q,223) #抗性穿透
      @emakedamage[q]/=@mshield
      @eskilldamage[q]/=@mmagicdef[1]
    end
    @ecombo[q]=Math.sqrt([@oldecombo[q],0].max)/10.0 #重定义攻速
    @eturn[q]=0
    @eturnr[q]=0
    @efight[q]=[] #怪物行动列表
    @efightvalue[q]=[] #怪物行动数值
    @ecanattack[q]=0 #怪物是否被缴械标记（或者处于吟唱状态）
    @ecanspell[q]=0 #怪物是否被沉默被标记
  end
  
  if @estatus[135]!=nil #结阵作战
    a=@estatus[135].split("-")
    b=@elist.size
    for qq in 0...3
      if a[qq][0,1]=="M"
        a[qq].slice!(0,1)
        a[qq]=-(a[qq].to_f)
      end
    end
    for q in 0...@elist.size
      @ehp[q]*=1+a[0].to_f*b/100
      @emaxhp[q]=@ehp[q]
      @ea[q]*=1+a[1].to_f*b/100
      @ed[q]*=1+a[2].to_f*b/100
    end
  end
    @mturn=0 if @mturn==nil
    @mturnr=0
    @mcombo=Math.sqrt([@oldmcombo,0].max)/10.0 #重定义攻速
    @mfight=[] #玩家行动列表
    @mfightvalue=[] #玩家行动数值
    @mcanattack=0 #玩家是否被缴械标记（或者处于吟唱状态）
    @mcanspell=0 #玩家是否被沉默被标记
    @mdebuff=[]
    
    #生成玩家行动列表
    sign=-1
    for i in 0...$game_variables[183].size
      if $game_variables[183][$game_variables[183].size-1-i]>0 && @actor.all_skill.include?($game_variables[183][$game_variables[183].size-1-i])
        sign=$game_variables[183].size-1-i
        break
      end
    end
    for i in 0...sign+1
      if $game_variables[183][i]>0 && !@actor.all_skill.include?($game_variables[183][i])
        @mfight.push(0)
        @mfightvalue.push("")
        next
      end
      @mfight.push($game_variables[183][i])
      for j in 0...@actor.skills.size
        if @actor.skills[j]==$game_variables[183][i]
          @mfightvalue.push($game_variables[180][j])
          break
        end
      end
      if $game_variables[183][i]==0 || @mfightvalue.size<=i
        @mfightvalue.push("")
      end
    end
    #玩家被动技能
    for i in $game_actors[$game_variables[1]+1].all_skill
      case i
      when 150 #神圣霜冻光环
        for q in 0...@elist.size
          @oldecombo[q]-=(@actor.power3*0.5).to_i
          @ecombo[q]=Math.sqrt([@oldecombo[q],0].max)/10.0 #重定义攻速
        end
      end
    end
    #传奇附魔被动
    if $game_variables[237]!=0
      for j in $game_variables[237]
        case j[0]
        when 201
          for q in 0...@elist.size 
            if @ebkb[q]!=1
              @ed[q]=(@ed[q]*0.98).to_i
            end
          end
        when 202
          for q in 0...@elist.size 
            if @ebkb[q]!=1
              @ea[q]=(@ea[q]*0.98).to_i
            end
          end
        when 203 #迈达斯的诱惑
          @mphysicaldef*=1.3
          @mskilldef*=1.3
        end
      end
    end
    #先手判定及先手技能部分
    tdcheck=true
    tdcheck2=false
    tdcheck2=true if $game_player.opacity<=200
    tdcheck2=true if @mequip.include?(68)
    tdcheck2=true if @mequip.include?(137) && $game_variables[181][137]==-1
    #是否发动跳刀
for q in 0...@elist.size  
    next if @emirror[q]!=nil  #幻象不能用主动技能
    #生成怪物行动列表
    for i in 0...zdskill[q].size
      @efight[q].push(zdskill[q][i])
      @efightvalue[q].push(zdvalue[q][i])
      case zdskill[q][i]
      when 7#奥术飞弹（连续三回合）
        @efight[q].push(zdskill[q][i]);@efightvalue[q].push(zdvalue[q][i])
        @efight[q].push(zdskill[q][i]);@efightvalue[q].push(zdvalue[q][i])
      when 12#炎爆术（连续七回合）
        for j in 0...6
          @efight[q].push(zdskill[q][i]);@efightvalue[q].push(zdvalue[q][i])
        end
      when 16#烈焰之拳
        for j in 0...zdvalue[q][i].split("-")[0].to_i-1
          @efight[q].push(zdskill[q][i]);@efightvalue[q].push(zdvalue[q][i])
        end
      when 24#凤凰冲击
        if @actor.check_buff(6) || (@actor.check_buff(7) && @mequip.include?(128))
          @efight[q].delete_at(@efight[q].size-1)
          @efightvalue[q].delete_at(@efightvalue[q].size-1)
          next
        end
        if tdcheck2
          @efight[q].delete_at(@efight[q].size-1)
          @efightvalue[q].delete_at(@efightvalue[q].size-1)
          tdcheck=false;next
        end
        @mturn=-1 #怪物夺取先手
        self.edamage+=magicdam(q,zdvalue[q][i].to_i)
        @efight[q].delete_at(@efight[q].size-1)
        @efightvalue[q].delete_at(@efight[q].size-1)
      when 36#突进
        if @actor.check_buff(6) || (@actor.check_buff(7) && @mequip.include?(128))
          @efight[q].delete_at(@efight[q].size-1)
          @efightvalue[q].delete_at(@efightvalue[q].size-1)
          next
        end
        if tdcheck2
          @efight[q].delete_at(@efight[q].size-1)
          @efightvalue[q].delete_at(@efightvalue[q].size-1)
          tdcheck=false;next
        end
        @mturn=-1 #怪物夺取先手
        mxuanyun(@efightvalue[q][@eturn[q]].to_i) #眩晕玩家
        @efight[q].delete_at(@efight[q].size-1)
        @efightvalue[q].delete_at(@efight[q].size-1)
      when 58#烈火精灵
        for j in 0...zdvalue[q][i].split("-")[0].to_i-1
          @efight[q].push(zdskill[q][i]);@efightvalue[q].push(zdvalue[q][i])
        end
      when 60#嗜血术
        @efightvalue[q][@efightvalue[q].size-1]+="-"+(@elist.size-1).to_s
        for j in 0...@elist.size-1
          @efight[q].push(zdskill[q][i]);@efightvalue[q].push(zdvalue[q][i]+"-"+(@elist.size-2-j).to_s)
        end
      when 79,181#法力虚空 法力黑洞
        a=@efight[q][@efight[q].size-1]
        b=@efightvalue[q][@efightvalue[q].size-1]
        @efight[q].delete_at(@efight[q].size-1)
        @efightvalue[q].delete_at(@efightvalue[q].size-1)
        for j in 0...b.split("-")[2].to_i-1
          @efight[q].push(0);@efightvalue[q].push("")
        end
        @efight[q].push(a);@efightvalue[q].push(b)
      when 220#九阳踏天
        a=@efight[q][@efight[q].size-1]
        b=@efightvalue[q][@efightvalue[q].size-1]
        @efight[q].delete_at(@efight[q].size-1)
        @efightvalue[q].delete_at(@efightvalue[q].size-1)
        for j in 0...b.split("-")[3].to_i-1
          @efight[q].push(0);@efightvalue[q].push("")
        end
        @efight[q].push(a);@efightvalue[q].push(b)
      when 222 #命源逆转
        a=@efight[q][@efight[q].size-1]
        b=@efightvalue[q][@efightvalue[q].size-1]
        @efight[q].delete_at(@efight[q].size-1)
        @efightvalue[q].delete_at(@efightvalue[q].size-1)
        for j in 0...b.split("-")[1].to_i-1
          @efight[q].push(0);@efightvalue[q].push("")
        end
        @efight[q].push(a);@efightvalue[q].push(b)
      when 172#战场轰炸
        a=@efight[q][@efight[q].size-1]
        b=@efightvalue[q][@efightvalue[q].size-1]
        @efight[q].delete_at(@efight[q].size-1)
        @efightvalue[q].delete_at(@efightvalue[q].size-1)
        @efight[q].push(0);@efightvalue[q].push("")
        @efight[q].push(a);@efightvalue[q].push(b)
      when 87#霜冻护甲
        @efightvalue[q][@efightvalue[q].size-1]+="-"+(@elist.size-1).to_s
        for j in 0...@elist.size-1
          @efight[q].push(zdskill[q][i]);@efightvalue[q].push(zdvalue[q][i]+"-"+(@elist.size-2-j).to_s)
        end
      when 94#掘地穿刺
        if @actor.check_buff(6) || (@actor.check_buff(7) && @mequip.include?(128))
          @efight[q].delete_at(@efight[q].size-1)
          @efightvalue[q].delete_at(@efightvalue[q].size-1)
          next
        end
        if tdcheck2
          @efight[q].delete_at(@efight[q].size-1)
          @efightvalue[q].delete_at(@efightvalue[q].size-1)
          tdcheck=false;next
        end
        a=@efightvalue[q][@eturn[q]].split("-")
        @mturn=-1 #怪物夺取先手
        self.edamage+=magicdam(q,a[1].to_f)
        mxuanyun(a[0].to_i) #眩晕玩家
        @efight[q].delete_at(@efight[q].size-1)
        @efightvalue[q].delete_at(@efight[q].size-1)
      when 208#月神之箭
        a=@efightvalue[q][@eturn[q]].split("-")
        if tdcheck2
          tdcheck=false
        else
          @mturn=-1 #怪物夺取先手
          self.edamage+=magicdam(q,a[1].to_f)
          mxuanyun(a[0].to_i) #眩晕玩家
          @efight[q].delete_at(@efight[q].size-1)
          @efightvalue[q].delete_at(@efightvalue[q].size-1)
        end
      when 211#命运之笔
        a=@efightvalue[q][@efightvalue[q].size-1].split("-")
        for j in 0...a[0].to_i-1
          @efight[q].push(zdskill[q][i]);@efightvalue[q].push(zdvalue[q][i])
        end
      end
    end
    @efight[q][0]=0 if @efight[q].size==0 #怪物第一回合预处理
  end
  #绝对先手
  for q in 0...@elist.size  
    if have_skill(q,114) #潜影
      if !$game_switches[158]
        @mturn=-1 #夺取先手
      end
    end
  end

  if @mturn<0
    for q in 0...@elist.size  
      if have_skill(q,115) #暗杀
        #暗杀执行
        a=@eskill[q][115].to_f
        @ea[q]*=a
        self.edamage+=eturn_damage(q)
        @ea[q]/=a
      end
    end
  else
    #如果装备跳刀且从始至终确保先手
    if @mequip.include?(68) && tdcheck
      for q in 0...@elist.size  
        #持续时间，技能编号，技能数值，来源（0为无来源或来自于玩家），是否为增益状态
        @edebuff[q].push([1,1,0,0])
        @enodamage[q]*=2
      end
    end
    if @mequip.include?(137) && $game_variables[181][137]==-1 #折跃匕首
      @oldmshield-=15
      self.mshield=@actor.rshield(@oldmshield)
      @mmiss/=0.75
      @edebuff[q].push([1,8,0,0])
      @enodamage[q]*=2
      @enomagic[q]*=1.2
    end
  end
    @first_sign=true
    @turncount=0 #记录回合数
    @mfight[0]=0 if true && @mfight.size==0 #为玩家添加空位，确保先手
    @rtarget=@elist.size-1
    @target=@elist[@rtarget]
    checktarget
    area_skill
    support_skill(zdskill,zdvalue)
    if $game_switches[166] #妖精之泉效果
      for q in 0...@elist.size
        @emaxhp[q]*=1.2
        @ehp[q]*=1.2
      end
    end
    #开关光环/被动技能
    if $game_switches[69]
      case $game_variables[284]
      when 200 #业火的杀戮
        @ma*=1.05
        @md*=0.95
        if @ebkb[@rtarget]==0
          @edamage-=mrecover(@ehp[@rtarget]*0.05)
          @ehp[@rtarget]*=0.95
        end
        @mhprerate=0
        @msprerate=0
      end
    end 
    #诡计之雾的破隐一击效果
    if @actor.check_buff(6)
      @oldeshield[@rtarget]-=@actor.armorbreak
      @eshield[@rtarget]=@actor.rshield(@oldeshield[@rtarget])
    end
    if @actor.check_buff(7) && @mturn>=0
      #白银之锋的破隐一击效果
      if @mequip.include?(136) 
        savema=@ma
        @ma=@ma*3
        self.edamage+=counterskill(@rtarget)
        @ehp[@rtarget]+=@lsvar[@rtarget]
        dam=[mturn_damage(@rtarget),@ehp[@rtarget]].min
        @ehp[@rtarget]-=dam
        @edamage-=mrecover2(@mvampire*(dam-mtd_extra(@rtarget))) if @mvampire>0
        @ma=savema
        epassbreak(@rtarget,4) #破坏被动4回合
      #影刃的破隐一击效果
      elsif @mequip.include?(128) 
        savema=@ma
        @ma=[@ma*5,8000000].min
        self.edamage+=counterskill(@rtarget)
        @ehp[@rtarget]+=@lsvar[@rtarget]
        dam=[mturn_damage(@rtarget),@ehp[@rtarget]].min
        @ehp[@rtarget]-=dam
        @edamage-=mrecover2(@mvampire*(dam-mtd_extra(@rtarget))) if @mvampire>0
        @ma=savema
      end
      if @ehp[@rtarget]<=0
        enemy_dead(@rtarget)
      end
    end
end
 end