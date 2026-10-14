class Enemy_property
    #处理玩家的技能效果
  def rmcost(sp)
    return (sp*@actor.skillminus*1.000001).to_i
  end
  def my_skill(first=1)
    if @mfight[@mturn]>0
      checktarget
      return true if @ehp[@rtarget]<=0
      #装备技能
      if @mfightvalue[@mturn]==""
        case @mfight[@mturn]
        when 39 #持盾冲击
          spc=rmcost(12)
          return true if @spcost+spc>@actor.sp
          target=is_bkb?(@rtarget,true)
          return true if @ebkb[target]==1
          return false if @ebkb[target]>0
          @ehp[target]-=emagicdam(target,@oldmshield*25)
          exuanyun(target,1) #眩晕怪物
          enemy_magic_counter(target)
          @spcost+=spc
        when 56 #持盾猛击
          spc=rmcost(25)
          return true if @spcost+spc*first>@actor.sp
          target=is_bkb?(@rtarget,true)
          return true if @ebkb[target]==1
          return false if @ebkb[target]>0
          @ehp[target]-=emagicdam(target,@oldmshield*35)
          exuanyun(target,1) #眩晕怪物
          enemy_magic_counter(target)
          @spcost+=spc*first
          @mturn+=1
          if @mdcskill==1 #挑战头巾效果
            @mturn-=1;@mdcskill=0;my_skill(2)
            return true
          end
          return my_skill if @mturn<@mfight.size
        when 124 #赤红之怒
          spc=rmcost(50)
          return true if @spcost+spc*first>@actor.sp
          target=is_bkb?(@rtarget)
          return true if @ebkb[target]==1
          return false if @ebkb[target]>0
          for i in 0...@elist.size
            next if @ebkb[i]>0
            if @ehp[i]>0
              dam=emagicdam(target,@oldmshield*500)
              @ehp[i]-=dam
              self.edamage-=dam*0.5
              exuanyun(i,1) #眩晕怪物
              enemy_magic_counter(i)
            end
          end
          if first==1 #格挡翻倍只提供一次
            if @mdecdamage>=1000
              @mdebuff.push([5+1,5,24,0,true])
              @mdecdamage+=1000
            end
          end
          @spcost+=spc*first
          success_magic(spc*first)
          @mturn+=1
          if @mdcskill==1 #挑战头巾效果
            @mturn-=1;@mdcskill=0;my_skill(2)
            return true
          end
          return my_skill if @mturn<@mfight.size
        when 57,121,162,164 #红杖LV1
          case @mfight[@mturn]
          when 57
            sdam=5000;spc=rmcost(30)
          when 121
            sdam=50000;spc=rmcost(50)
          when 162
            sdam=800000;spc=rmcost(100)
          when 164
            sdam=500000;spc=rmcost(100)
          end
          return true if @spcost+spc*first>@actor.sp
          target=is_bkb?(@rtarget,true)
          return true if @ebkb[target]==1
          return false if @ebkb[target]>0
          if @mfight[@mturn]==162
            case first
            when 1
              @estatus[162]=target
            when 2
              exuanyun(target,1) if @estatus[162]==target
            end
          end
          val=$data_skills[@mfight[@mturn]].name.split("|")[1].to_f
          if val==0 #虚灵
            if mhavebuff?(6)==-1
              @mdebuff.push([4+1,6,24,0,true])
              @mcanattack=1 if @mcanattack<1 #无法攻击
              for q in 0...@elist.size
                @ecanattack[q]=1 if @ecanattack[q]<1 #迫使敌人无法攻击（无视魔免）
              end
              @mskilldef*=1.4 #受魔法伤害1.4倍
            end
            if ehavebuff?(target,164)==-1
              @edebuff[target].push([4,164,0.1,target,false])
              @enomagic[target]*=1.4
            end
            case $game_variables[154]
            when 1
              val=@actor.power1
            when 2
              val=@actor.power2
            when 3
              val=@actor.power3
            end
            damage=sdam*(1+val*0.001)
          else #大根
            damage=sdam+@actor.magicpower*val
          end
          @ehp[target]-=emagicdam(target,damage)
          enemy_magic_counter(target)
          @spcost+=spc*first
          success_magic(spc*first)
          @mturn+=1
          if @mdcskill==1 #挑战头巾效果
            @mturn-=1;@mdcskill=0;my_skill(2)
            return true
          end
          return my_skill if @mturn<@mfight.size
        when 123 #幽魂形态
          return true if @mbkb>0
          @mdebuff.push([4+1,4,24,0,true])
          @mcanattack=1 if @mcanattack<1 #无法攻击
          for q in 0...@elist.size
            @ecanattack[q]=1 if @ecanattack[q]<1 #迫使敌人无法攻击（无视魔免）
          end
          @mskilldef*=2 #受魔法伤害加倍
          @mturn+=1
          return my_skill if @mturn<@mfight.size
        when 151 #冰晶爆破
          return true if @mturnr>0 #仅限第一回合使用
          spc=rmcost(120)
          return true if @spcost+spc>@actor.sp
          target=is_bkb?(@rtarget)
          return true if @ebkb[target]==1
          return false if @ebkb[target]>0
          @estatus[151]=[]
          for q in 0...@elist.size
            next if @ebkb[q]>0 || @ehp[q]<=0
            #8回合 151号技能 15%HP 编号 非debuff
            @edebuff[q].push([8,151,0.1,q,true])
            @estatus[151][q]=1
            damage=120000+@actor.magicpower*$data_skills[@mfight[@mturn]].name.split("|")[1].to_f
            @ehp[target]-=emagicdam(target,damage)
            enemy_magic_counter(q)
          end
          @spcost+=spc
          success_magic(spc)
          @mturn+=1
          return my_skill if @mturn<@mfight.size
        when 152 #妖术
          spc=rmcost(50)
          return true if @spcost+spc*first>@actor.sp
          target=is_bkb?(@rtarget,true)
          return true if @ebkb[target]==1
          return false if @ebkb[target]>0
          target=is_sheep?(@rtarget,true)
          return true if target<0
          if @emirror[target]==nil #并非幻象
            exuanyun(target,3) #眩晕3回合
            epassbreak(target,3) #破坏被动3回合
          else
            @ehp[target]=0 #直接杀死幻象
          end
          @spcost+=spc*first
          success_magic(spc*first)
          @mturn+=1
          return my_skill if @mturn<@mfight.size
        when 163 #灵魂燃烧
          spc=rmcost(80)
          return true if @spcost+spc*first>@actor.sp
          target=is_bkb?(@rtarget,true)
          return true if @ebkb[target]==1
          return false if @ebkb[target]>0
          @ecanspell[target]=5 if @ecanspell[target]<5
          @edebuff[target].push([5,5,@ehp[target],target])
          @spcost+=spc*first
          success_magic(spc*first)
          enemy_magic_counter(target)
          @mturn+=1
          return my_skill if @mturn<@mfight.size
        when 165 #缴械
          spc=rmcost(100)
          return true if @spcost+spc*first>@actor.sp
          target=@rtarget
          @ecanattack[target]=5 if @ecanattack[target]<5
          if @ebkb[target]==0
            @edebuff[target].push([5,6,0,target])
            @enodamage[target]*=1.5
          end
          @spcost+=spc*first
          success_magic(spc*first)
          enemy_magic_counter(target)
          @mturn+=1
          return my_skill if @mturn<@mfight.size
        when 170 #灵魂撕裂
          spc=rmcost(120)
          return true if @spcost+spc*first>@actor.sp
          target=is_bkb?(@rtarget,true)
          return true if @ebkb[target]==1
          return false if @ebkb[target]>0
          @ecanspell[target]=5 if @ecanspell[target]<5
          @edebuff[target].push([5,7,@ehp[target],target])
          @enodamage[target]*=2.5/1.3
          @spcost+=spc*first
          success_magic(spc*first)
          enemy_magic_counter(target)
          @mturn+=1
          return my_skill if @mturn<@mfight.size
        when 173 #火焰气息
          spc=rmcost(60)
          return true if @spcost+spc*first>@actor.sp
          target=is_bkb?(@rtarget)
          return true if @ebkb[target]==1
          return false if @ebkb[target]>0
          for q in 0...@elist.size
            next if @ebkb[q]>0 || @ehp[q]<=0
            #8回合 151号技能 15%HP 编号 非debuff
            val=@ea[q]*0.1
            ck2=false
            for ck in @edebuff[q]
              if ck[1]==173
                ck[0]=2
                ck=true
                break
              end
            end
            if !ck
              @ea[q]-=val
              @edebuff[q].push([2,173,val,q])
            end
            damage=400000+@ma*0.5+@actor.magicpower*$data_skills[@mfight[@mturn]].name.split("|")[1].to_f
            @ehp[target]-=emagicdam(target,damage)
            enemy_magic_counter(q)
          end
          @spcost+=spc*first
          success_magic(spc*first)
          @mturn+=1
          if @mdcskill==1 #挑战头巾效果
            @mturn-=1;@mdcskill=0;my_skill(2)
            return true
          end
          return my_skill if @mturn<@mfight.size
        when 180 #灵魂爆发
          spc=rmcost(100)
          return true if @spcost+spc*first>@actor.sp
          return true if @soulcost+5>$game_variables[197]
          target=is_bkb?(@rtarget)
          return true if @ebkb[target]==1
          return false if @ebkb[target]>0
          for i in 0...@elist.size
            next if @ebkb[i]>0
            if @ehp[i]>0
              dam=emagicdam(target,@oldmshield*$game_variables[197]*25)
              @ehp[i]-=dam
              exuanyun(i,2) #眩晕怪物
              enemy_magic_counter(i)
            end
          end
          @spcost+=spc*first
          @soulcost+=5 if first==1
          success_magic(spc*first)
          @mturn+=1
          if @mdcskill==1 #挑战头巾效果
            @mturn-=1;@mdcskill=0;my_skill(2)
            return true
          end
          return my_skill if @mturn<@mfight.size
        when 201 #磐石聚心
          spc=rmcost(150)
          return true if @spcost+spc*first>@actor.sp
          val=@ma*0.1
          @ma-=val
          @md+=val
          @mofang+=@mmaxhp*0.03
          @spcost+=spc
          success_magic(spc)
          @mturn+=1
          return my_skill if @mturn<@mfight.size
        end
        return true
      end
      a=@mfightvalue[@mturn].split("-")
      #主动技能
      case @mfight[@mturn]
      when 28 #风暴之锤
        spc=rmcost(a[0].to_i)
        return true if @spcost+spc>@actor.sp
        target=is_bkb?(@rtarget,true)
        return true if @ebkb[target]==1
        return false if @ebkb[target]>0
        @mcanattack=1 if @mcanattack<1 #自我缴械，当前回合不作普通攻击
        @ehp[target]-=emagicdam(target,a[1].to_f)
        exuanyun(target,a[2].to_i) #眩晕怪物
        @spcost+=spc
      when 51 #毁灭阴影LV1
        if @mturnr==0
          max=1
        else
          max=3
        end
        spc=rmcost(a[1].to_i)
        for qp in max...4
          break if @spcost+spc>@actor.sp
          break if @soulcost+a[2].to_i>$game_variables[197]
          target=is_bkb?(@rtarget)
          break if @ebkb[target]==1
          return false if (@ebkb[target]>0 || @ehp[target]<=0) && qp==max
          break if @ebkb[target]>0 || @ehp[target]<=0
          damage=a[0].to_f+@actor.magicpower*$data_skills[51].name.split("|")[1].to_f
          count=0
          i=@elist.size-1
          while i>=0
            if @ehp[i]>0 && @ebkb[i]==0
              @ehp[i]-=emagicdam(i,damage)
              enemy_magic_counter(i)
              checktarget if @ehp[i]<=0
              count+=1
              break if count==3
            end
            i-=1
          end
          @spcost+=spc
          if qp==max
            @mcanattack=1 if @mcanattack<1 #自我缴械，当前回合不作普通攻击
            @soulcost+=a[2].to_i
          end
        end
      when 73 #毁灭阴影LV2
        if @mturnr==0 && first==1
          max=1
        else
          max=3
        end
        spc=rmcost(a[2].to_i)
        damage=a[0].to_f+@actor.magicpower*$data_skills[73].name.split("|")[1].to_f
        for qp in max...4
          break if @spcost+spc*first>@actor.sp
          break if @soulcost+a[3].to_i>$game_variables[197]
          target=is_bkb?(@rtarget)
          break if @ebkb[target]==1
          return false if (@ebkb[target]>0 || @ehp[target]<=0) && qp==max
          break if @ebkb[target]>0 || @ehp[target]<=0
          count=0
          i=@elist.size-1
          while i>=0
            if @ehp[i]>0 && @ebkb[i]==0
              @ehp[i]-=emagicdam(i,damage)
              enemy_magic_counter(i)
              @oldeshield[i]-=a[1].to_i
              @eshield[i]=@actor.rshield(@oldeshield[i])
              checktarget if @ehp[i]<=0
              count+=1
              break if count==3
            end
            i-=1
          end
          @spcost+=spc*first
          success_magic(spc*first)
          if qp==max
            @mcanattack=1 if @mcanattack<1 #自我缴械，当前回合不作普通攻击
            if first>1
              @soulcost+=2
            else
              @soulcost+=a[3].to_i
            end
          end
        end
        if @mdcskill==1 #挑战头巾效果
          @mdcskill=0;my_skill(2)
        end
      when 166 #毁灭阴影LV3
        break if @soulcost+a[3].to_i>$game_variables[197]
        max=a[4].to_i
        if @mdcskill==1 #挑战头巾效果
          @mdcskill=0;max+=1
        end
        spc=rmcost(a[2].to_i)
        damage=a[0].to_f
        #灵魂化的伤害增幅
        if $game_variables[266]>=3
          for k in 0...@actor.all_skill.size
            if $data_skills[@actor.all_skill[k]].name[0,12]=="魔王降临"
              damage*=(1+[$game_variables[197],@actor.soul_max_hard].min*$game_variables[180][k].split("-")[3].to_f/100)
            end
          end
        end
        damage+=@actor.magicpower*$data_skills[166].name.split("|")[1].to_f
        for qp in 0...max
          first+=1 if qp==a[4].to_i
          break if @spcost+spc*first>@actor.sp
          target=is_bkb?(@rtarget)
          break if @ebkb[target]>0 || @ehp[target]<=0
          count=0
          i=@elist.size-1
          while i>=0
            if @ehp[i]>0 && @ebkb[i]==0
              @ehp[i]-=emagicdam(i,damage)
              enemy_magic_counter(i)
              @oldeshield[i]-=a[1].to_i
              @eshield[i]=@actor.rshield(@oldeshield[i])
              checktarget if @ehp[i]<=0
              count+=1
              break if count==3
            end
            i-=1
          end
          @spcost+=spc*first
          success_magic(spc*first)
          if qp==0
            @soulcost+=a[3].to_i
          end
        end
      when 85,122 #爆破人形V1
        spc=rmcost(a[0].to_i)
        return true if @spcost+spc*first>@actor.sp
        mp=a[2].to_f+@actor.magicpower*$data_skills[85].name.split("|")[1].to_f
        @mdebuff.insert(0,[a[1].to_i+1,85,mp.to_s+"|"+self.edamage.to_s,mp*a[3].to_f/100,true])
        @estatus[85]=1 if !@havedamage
        @spcost+=spc*first
        success_magic(spc*first)
        if @mdcskill==1 #挑战头巾效果
          @mdcskill=0;my_skill(2)
        end
      when 161 #魂之挽歌
        spc=rmcost(a[0].to_i)
        return true if @spcost+spc>@actor.sp
        souc=@actor.soul_max_hard/2
        return true if @soulcost+souc>$game_variables[197]
        @mdebuff.push([a[1].to_i,@mfight[@mturn],[spc,souc],[a[2].to_f,a[3].to_i,a[4].to_f,a[5].to_f],true,true])
        @mcanspell=-1
        @mcanattack=-1 #负数表示蓄力状态
      end
    end
    return true
  end
  #玩家反击类技能
  def player_counter_skill(q)
    if have_skill(q,66) #最低伤害
      return 0
      #凤凰蛋不会攻击，哪来的反击
    end
    d=0
    #勇气之霎
    if @estatus[35]==nil #退化光环禁被动
      check=@actor.skills.index(27)
      if check && @mskill[check]==0 && @mcanattack==0 #勇气之霎
        @mskill[check]=1 #禁用
        value=[(@ma-@ed[@rtarget])*@enodamage[@rtarget]-@edecdamage[@rtarget],0].max*@mcrit*@eshield[@rtarget]
        value=[[value,@ehp[@rtarget]].min,0].max
        @ehp[@rtarget]-=value
        self.edamage+=counterskill(@rtarget)
        @ehp[@rtarget]+=@lsvar[@rtarget]
        self.edamage-=mrecover2(value)*$game_variables[180][check].to_f/100
      end
    end
    if @mequip.include?(50) && @ecanattack[q]==0 #先锋盾二阶的骨火
      d+=40*@ecombo[q]
    end
    if @etd !=nil #普攻部分追加效果
      if @mequip.include?(85) && @lighthammer<5 #漩涡闪电链
        if @ehp[q]>0 && @ebkb[q]==0
          if @lighthammer>0
            d+=emagicdam(q,1200*(0.8**@lighthammer)*[@mhitrate,0].max*enemy_miss(q)*@mcombo)
          end
          @lighthammer+=1
        end
      end
    end
    return d
  end
  def mcleardebuff
    for i in @mdebuff
      i[0]-=1
      if i[0]>=50 || i[0]<0
        p i
        exit
      end
      case i[1]
      when 4,6 #幽魂权杖
        if i[0]>0
          @mcanattack=1 if @mcanattack<1 #无法攻击
        end
        for q in 0...@elist.size
          @ecanattack[q]=1 if @ecanattack[q]<1 #迫使敌人无法攻击（无视魔免）
        end
      when 7 #刃甲
        b=0
        for q in 0...@elist.size
          b+=1 if @ehp[q]>0
        end
        if b>0
          val=(@alldamage-i[2])/b
          if val>0 
            @edamage+=val*2
          end
          savesk=@mskilldam
          @mskilldam=1
          for q in 0...@elist.size
            @ehp[q]-=emagicdam(q,val) if @ehp[q]>0
          end
          @mskilldam=savesk
        end
        c=0
        for q in 0...@elist.size
          c+=1 if @ehp[q]>0
        end
        if b>0 && c==0
          @turncount-=1
          if !$merit[124][0] && @turncount==0#刃甲成就
            ck=true
            for q in 0...@elist.size
              if emagicdam(q,val)<@ehp[q]
                ck=false;break
              end
            end
            if ck
              @afterevent.push([13])
            end
          end
        end
        i[2]=@alldamage
      when 8 #天赋-破甲熔炎
        @oldeshield[@rtarget]-=i[2]
        @eshield[@rtarget]=@actor.rshield(@oldeshield[@rtarget])
      when 10 #风暴
        self.edamage+=magicdam(i[3],i[2].split("-")[0].to_f)
      when 22 #雷霆之击
        self.edamage+=magicdam(i[3],i[2].to_f)
      when 47 #诅咒
        b=+i[2].split("-")[1].to_f
        a=[self.edamage+b-@zuzhou,0].max*i[2].split("-")[2].to_f/100
        @zuzhou=self.edamage
        self.edamage+=magicdam(i[3],a+b)
      when 62 #引燃
        self.edamage+=magicdam(i[3],i[2].split("-")[0].to_f)
      when 85 #爆破人形Lv1
        b=i[2].split("|")
        if self.edamage>b[1].to_f #判定是否造成了伤害
          if self.edamage-b[1].to_f>=b[0].to_f
            self.edamage-=b[0].to_f
            i[0]=0
            i[2]=nil #表示满足引爆条件
          else
            i[2]=(b[0].to_f-(self.edamage-b[1].to_f)).to_s+"|"+b[1]
            self.edamage=b[1].to_f
          end
        end
        if !ealive?
          i[0]=0
        end
      when 89 #冰封禁制
        self.edamage+=magicdam(i[3],i[2].split("-")[1].to_f)
      when 90 #极寒之触
        qq=i[3].to_i
        if @ehp[qq]>0 && @eatked
          a=i[2].split("-")
          self.edamage+=magicdam(i[3],a[1].to_f)
          @oldmcombo-=a[2].to_i
          @mcombo=Math.sqrt([@oldmcombo,0].max)/10.0
        end
      when 97 #严寒灼烧
        qq=i[3].to_i
        if @ehp[qq]>0 && @eatked
          a=i[2].split("-")
          self.edamage+=(@mhp-self.edamage)*a[1].to_f/100
        end
      when 98 #寒冬诅咒
        combo=Math.sqrt([@oldmcombo*2,0].max)/10.0
        if !check_player_ghost?
          self.edamage+=ephysicaldam(i[3],[@ma-@md,0].max*combo*[@mhitrate,0].max*@mcrit)
        end
      when 106 #阳炎之索
        self.edamage+=magicdam(i[3],i[2].split("-")[0].to_f)
      when 111 #风漩
        if @ehp[i[3]]<=0
          i[0]=0
        elsif i[0]>0
          @mcanspell=1 if @mcanspell<1
        end
      when 116 #决斗
        if @ehp[i[3]]<=0
          i[0]=0
        elsif i[0]>0
          @ecanspell[i[3]]=1 if @ecanspell[i[3]]<1
          @mcanspell=1 if @mcanspell<1
        end
      when 120 #地震
        a=i[2].split("-")
        qq=magicdam(i[3],a[0].to_i)
        if qq>0
          i[2]=(a[0].to_i*(1+a[1].to_f/100)).to_i.to_s+"-"+a[1]+"-"+a[2]
        end
        self.edamage+=qq
      when 147 #寄生种子
        a=i[2]
        a*=2 if $game_variables[1]==0
        @edamage+=a
        for q in 0...@elist.size
          if @ehp[q]>0
            if have_skill(q,3)
              @ehp[q]-=a
            else
              @ehp[q]+=erecover(q,a)
            end
          end
        end
      when 161 #魂之挽歌
        if @mcanspell>=0
          i[0]=0 #蓄力中断
          mskill_break
        else
          if i[0]==0
            if @spcost+i[2][0]<=@actor.sp && @soulcost+i[2][1]<=$game_variables[197]
              @spcost+=i[2][0]
              @soulcost+=i[2][1]
              val=$data_skills[@mfight[@mturn]].name.split("|")[1].to_f
              realdam=(i[3][0]+@actor.magicpower*val)*(1+i[2][1]*0.001)
              for q in 0...@elist.size
                if @ebkb[q]==0
                  @ehp[q]-=emagicdam(q,realdam)
                end
                enemy_magic_counter(q)
                @oldecombo[q]-=i[3][2]
                @ecombo[q]=Math.sqrt([@oldecombo[q],0].max)/10.0
                val=i[3][3]/100.0*@ea[q]
                @ea[q]-=val
                @edebuff[q].push([i[3][1]+1,4,[i[3][2],val],q])
              end
              @animation.push(60)
              success_magic(i[2][0])
            end
            @mcanspell=0
            @mcanattack=0
          end
        end
      when 190 #黑龙吐息
        @edamage+=(@mhp-@edamage)*i[2]
        @spcost+=(@actor.sp-@spcost)*i[2]
      when 215 #憎恶
        i[3][0]+=1
        if @abominate_list[i[3][1]]==i[3][0]
          i[3][1]+=1
          mxuanyun(1)
          self.edamage+=i[3][2].to_f+(@mhp-self.edamage)*i[3][3]
        end
      end
      if i[0]==0
        player_end_debuff(i)
      end
    end
    i=@mdebuff.size-1
    while i>=0
      if @mdebuff[i][0]==0
        @mdebuff.delete_at(i)
      end
      i-=1
    end
  end
  def player_end_debuff(i) #玩家buff结束效果
    case i[1]
    when 1 #相位鞋被动
      @mmiss/=0.76
      #还原闪避
    when 2 #先锋盾（巨岩）被动
      @md/=1.1
    when 3 #勇气勋章主动
      a=i[3]
      @oldmshield+=7
      self.mshield=@actor.rshield(@oldmshield)
      @oldeshield[a]+=7
      @eshield[a]=@actor.rshield(@oldeshield[a])
    when 4 #幽魂权杖
      @mskilldef/=2
    when 5 #赤红甲
      @mdecdamage-=1000
    when 6 #虚灵
      @mskilldef/=1.4
    when 9 #灵动迅捷
      @mmisszero+=1
      #还原闪避
    when 10 #风暴
      @oldmcombo+=i[2].split("-")[1].to_f
      @mcombo=Math.sqrt([@oldmcombo,0].max)/10.0
      #还原攻速
    when 15 #雷霆一击
      @oldmcombo+=i[2].split("-")[2].to_f
      @mcombo=Math.sqrt([@oldmcombo,0].max)/10.0
      #还原攻速
    when 25 #撕裂伤口
      @oldmcombo+=i[2].split("-")[1].to_f
      @mcombo=Math.sqrt([@oldmcombo,0].max)/10.0
      #还原攻速
      @evampire[i[3]]-=i[2].split("-")[2].to_f/100
      #还原吸血率
    when 58 #烈火精灵
      @oldmcombo+=i[2].split("-")[2].to_f
      @mcombo=Math.sqrt([@oldmcombo,0].max)/10.0
      #还原攻速
    when 62 #引燃
      @oldmcombo+=i[2].split("-")[1].to_f
      @mcombo=Math.sqrt([@oldmcombo,0].max)/10.0
      #还原攻速
    when 69 #伤残恐惧
      @mhitrate+=i[2].split("-")[0].to_f/100
      if @estatus[86]!=nil
        for qq in 0...@elist.size
          @emakedamage[qq]/=(1+@estatus[86]/100.0)
        end
      end
      #还原命中
    when 77 #恶念瞥视
      if @ehp[i[3]]>0
        @animation=@animation.uniq
        @nowin=0
        self.edamage=self.edamage.to_i
        @afterevent.push([2]) #战斗中止预定
        for j in 0...@elist.size
          @ehp[j]=0
          @emirror[j]="100-100"
        end   
        if self.edamage<0
          self.edamage=0
          @mhpre=0
        end
      end
    when 85 #爆破人形
      if i[2]==nil #满足引爆条件
        for j in 0...@elist.size
          if @ehp[j]>0 && @ebkb[j]==0
            @ehp[j]-=emagicdam(j,i[3])
          end
        end
      end
    when 88 #冰霜新星
      a=i[2].split("-")
      @oldmcombo+=a[2].to_i
      @mcombo=Math.sqrt([@oldmcombo,0].max)/10.0
      if a[3].to_i==100
        @mmisszero-=1
      else
        @mmiss=1-(1-@mmiss)/(1-a[3].to_f/100.0)
      end
    when 89,106 #冰封禁制
      @mmisszero-=1
    when 111 #风漩
      @mmisszero-=1
      if @ehp[i[3]]>0
        a=i[2].split("-")
        self.edamage+=magicdam(i[3],a[1].to_f)
      end
    when 116 #决斗
      @mmisszero-=1
      if @ehp[i[3]]>0
        v1=@estatus[116][0]-(@mhp-self.edamage).to_f/@mhp
        v2=@estatus[116][1]-@ehp[i[3]].to_f/@emaxhp[i[3]]
        a=i[2].split("-")
        if v1>v2
          @ea[i[3]]*=1+a[1].to_f/100
          @oldecombo[i[3]]+=a[2].to_i
          @ecombo[i[3]]=Math.sqrt([@oldecombo[i[3]],0].max)/10.0
        else
         # @ma*=1+a[1].to_f/100
        #  @oldmcombo+=a[2].to_i
         # @mcombo=Math.sqrt([@oldmcombo,0].max)/10.0
        end
      end
    when 120 #地震
      a=i[2].split("-")
      @oldmcombo+=a[2].to_i
      @mcombo=Math.sqrt([@oldmcombo,0].max)/10.0
      @mmisszero-=1
    when 126 #电磁脉冲
      a=i[2].split("-")
      self.edamage+=magicdam(i[3],a[1].to_f)
      val2=a[2].to_i*@mmagicdef[1]*@mskilldef
      val=[@actor.sp-@spcost,val2].min
      @spcost+=val
      
    when 140 #狂战怒吼 护甲提升
      @oldmcombo-=i[2]
      @mcombo=Math.sqrt([@oldmcombo,0].max)/10.0
    when 197 #阳炎冲击结算
      if @mbkb==0
        self.edamage+=i[2]
      end
    when 202 #巨浪结束
      @mmisszero-=1
      @oldmshield+=i[2]
      self.mshield=@actor.rshield(@oldmshield)
    end
  end
  #玩家第一回合行动（装备使用等）
  def player_first_active
    @first_sign=false
    if @mequip.include?(21) #相位鞋
      #持续3回合的增益buff，第五个参数确定是否为增益状态
      #主要针对在怪物回合数防御的要+1
      @mdebuff.push([3+1,1,24,0,true])
      @mmiss*=0.76
    end
    if @mequip.include?(33) #先锋盾（巨岩）
      @mdebuff.push([3+1,2,24,0,true])
      @md*=1.1
    end
    if @mequip.include?(42) && $game_variables[181][42]==-1 #勇气勋章
      @mdebuff.push([5+1,3,24,@rtarget,true])
      @oldmshield-=7
      self.mshield=@actor.rshield(@oldmshield)
      @oldeshield[@rtarget]-=7
      @eshield[@rtarget]=@actor.rshield(@oldeshield[@rtarget])
    end
    if @mequip.include?(86) && $game_variables[181][86]==-1 #炎阳纹章
      @oldmshield-=12
      self.mshield=@actor.rshield(@oldmshield)
      @mmiss/=0.75
      @oldeshield[@rtarget]-=12
      @emiss[@rtarget]/=0.75
      @eshield[@rtarget]=@actor.rshield(@oldeshield[@rtarget])
    end
    if @mequip.include?(64) && $game_variables[181][64]==-1 #挑战头巾
      @mdcskill=1
    end
    if @mequip.include?(89) && $game_variables[181][89]==-1 #洞察烟斗
      @mdcskill=1
    end
    if @mequip.include?(74) && $game_switches[159]
      @oldmcombo+=250
      @mcombo=Math.sqrt([@oldmcombo,0].max)/10.0
      @mmiss*=0.85
      @afterevent.push([6])
    end
    if @mequip.include?(115) #散夜对剑
      val=@actor.power1
      for q in 0...@elist.size
        @oldecombo[q]-=[val,@oldecombo[q]/2].min
        @ecombo[q]=Math.sqrt([@oldecombo[q],0].max)/10.0
      end
      @mhitrate*=1.15
    else
      if @mequip.include?(113) || @mequip.include?(125) #散华&天堂
        val=@actor.power1
        for q in 0...@elist.size
          if @ebkb[q]!=1
            @oldecombo[q]-=[val,@oldecombo[q]/2].min
            @ecombo[q]=Math.sqrt([@oldecombo[q],0].max)/10.0
          end
        end
      end
    end
    if @mequip.include?(125) #天堂之光
      for q in 0...@elist.size  
        if have_skill(q,3) && @ebkb[q]!=1 #亡灵协同 \v
          @ehp[q]-=@emaxhp[q]*0.3
        end
      end
    end
    if @mequip.include?(124) #刃甲
      @mdebuff.push([5+1,7,@alldamage,0,true])
    end
    if $game_variables[226]!=0 #天赋开启
      if $game_variables[226][23]!=nil #破甲熔炎
        if $game_variables[226][23]>0
          val=$game_variables[226][23]*0.5
          @oldeshield[@rtarget]-=val
          @eshield[@rtarget]=@actor.rshield(@oldeshield[@rtarget])
          @mdebuff.push([10-1,8,val,0,true])
        end
      end
    end
    #传奇附魔被动
    if $game_variables[237]!=0
      for j in $game_variables[237]
        case j[0]
        when 105 #灵动迅捷
          @mdebuff.push([1+1,9,0,0,true])
          @mmisszero-=1
        end
      end
    end
  end
  #玩家是否处于幽魂形态
  def check_player_ghost?
    for i in @mdebuff
      if i[1]==4 || i[1]==6
        return true
      end
    end
    return false
  end
  def enemy_magic_counter(q) #魔法反击类
    if have_skill(q,81) #魔法反制
      self.edamage+=magicdam(q,@eskill[q][81].to_i) #反制伤害
      mpurge
    end
  end
  def success_magic(spc) #一次成功的施法处理
    if @estatus[158]!=nil
      self.edamage+=magicdam(0,spc*@estatus[158])
    end
  end
  def mpurge #玩家被净化
    i=@mdebuff.size-1
    while i>=0
      i-=1
      if @mdebuff[i][4] && @mdebuff[i][5]==nil
        player_end_debuff(@mdebuff[i])
        @mdebuff.delete_at(i)
      end
    end
    if @afterevent.include?([6]) #净化战鼓效果
      @oldmcombo-=250
      @mcombo=Math.sqrt([@oldmcombo,0].max)/10.0
      @mmiss/=0.85
      @afterevent.delete([6])
    end
    if $game_variables[232]==0
    else
      @oldmcombo-=@actor.atkspeed-@actor.atkspeed(true)
      @mcombo=Math.sqrt([@oldmcombo,0].max)/10.0
      @mmiss/=(1-@actor.miss)/(1-@actor.miss(true))
      @mhitrate/=@actor.hitrate/@actor.hitrate(true) #命中及伤害系数
      @mskilldam/=@actor.skilldam/@actor.skilldam(true)
      @actor.del_all_buff
      if !@afterevent.include?([7])
        @afterevent.push([7])
      end
    end
  end
  def epurge(q) #怪物被净化
    i=@edebuff.size-1
    while i>=0
      i-=1
      if @edebuff[i][4]
        enemy_end_debuff(@edebuff[i])
        @edebuff.delete_at(i)
      end
    end
  end
  def eremove_debuff(q) #怪物驱散自身不良状态
    @ecanspell[q]=0 if @ecanspell[q]>0
    @ecanattack[q]=0 if @ecanattack[q]>0
    @epassbreak[q]=0 if @epassbreak[q]>0
    i=@edebuff[q].size-1
    while i>=0
      i-=1
      if !@edebuff[q][i][4]
        enemy_end_debuff(q,@edebuff[q][i])
        @edebuff[q].delete_at(i)
      end
    end
  end
  def mskill_break#玩家技能被打断
    @mcanspell=0 if @mcanspell==-1
    @mcanattack=0 if @mcanattack==-1
    sw=false
    while @mfight[@mturn]==0
      @mturn+=1
      sw=true
    end
    @mturn-=1 if sw
  end
end