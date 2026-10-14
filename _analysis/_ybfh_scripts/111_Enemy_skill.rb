class Enemy_property
  #处理怪物的技能效果
  def enemy_skill(q,first=0)
    if @efight[q][@eturn[q]]>0 && first==0
      if have_skill(q,23) #静电场
        self.edamage+=(@mhp-self.edamage)*@eskill[q][23].to_f/100 #纯粹伤害
      end
      if have_skill(q,63) #多重施法
        for i in 0...@eskill[q][63].to_i-1
          enemy_skill(q,i+1)
        end
      end
      if have_skill(q,117) #超负荷
        a=@eskill[q][117].split("-")
        @estatus[117]=[] if @estatus[117]==nil
        @estatus[117][q]=a[0].to_f if @estatus[117][q]==nil
        self.edamage+=magicdam(q,@estatus[117][q])
        @estatus[117][q]*=1+a[1].to_f/100
      end
    end
    #0表示第一回合的普攻，不作处理
    case @efight[q][@eturn[q]]
    when 7 #奥术飞弹
      @ecanattack[q]=1 if @ecanattack[q]<1 #自我缴械，当前回合不作普通攻击
      if first==0
        self.edamage+=magicdam(q,@efightvalue[q][@eturn[q]].to_i)
      else
        self.edamage+=@efightvalue[q][@eturn[q]].to_i
        self.edamage+=@efightvalue[q][@eturn[q]].to_i-magicdam(q,@efightvalue[q][@eturn[q]].to_i) if first==1
      end
    when 10 #风暴
      @mdebuff.push([5,@efight[q][@eturn[q]],@efightvalue[q][@eturn[q]],q]) #持续5回合的debuff
      @oldmcombo-=@efightvalue[q][@eturn[q]].split("-")[1].to_f
      @mcombo=Math.sqrt([@oldmcombo,0].max)/10.0
    when 12 #炎爆术
      @ecanattack[q]=1 if @ecanattack[q]<1 #自我缴械，当前回合不作普通攻击
      self.edamage+=magicdam(q,@efightvalue[q][@eturn[q]].to_i)
      if @eskill[q][12]!=nil
        if @eskill[q][12]<=0
          @eskill[q][12]=5
          mxuanyun(1) #眩晕玩家
        end
        @eskill[q][12]-=1
      end
      if first>0
        if @eskill[q][12]==nil
          @eskill[q][12]=5
          @eskill[q][12]-=1
        end
      end
    when 15 #雷霆一击
      @mdebuff.push([@efightvalue[q][@eturn[q]].split("-")[1].to_i,@efight[q][@eturn[q]],@efightvalue[q][@eturn[q]],q]) #持续5回合的debuff
      self.edamage+=magicdam(q,@efightvalue[q][@eturn[q]].split("-")[0].to_f)
      @oldmcombo-=@efightvalue[q][@eturn[q]].split("-")[2].to_f
      @mcombo=Math.sqrt([@oldmcombo,0].max)/10.0
    when 16 #烈焰之拳
      self.edamage+=magicdam(q,@efightvalue[q][@eturn[q]].split("-")[1].to_i)*@ecombo[q]*player_miss(q)
    when 19,125 #次级沟壑
      @ecanattack[q]=1 if @ecanattack[q]<1 #自我缴械，当前回合不作普通攻击
      mxuanyun(@efightvalue[q][@eturn[q]].split("-")[1].to_i) #眩晕玩家
      self.edamage+=magicdam(q,@efightvalue[q][@eturn[q]].split("-")[0].to_i)
      @afterevent.push([4]) #战后处理
    when 22 #雷霆之击
      @ecanattack[q]=1 if @ecanattack[q]<1 #自我缴械，当前回合不作普通攻击
      @mdebuff.push([4,@efight[q][@eturn[q]],@efightvalue[q][@eturn[q]],q]) #持续5回合的debuff
    when 25 #撕裂伤口
      @mdebuff.push([@efightvalue[q][@eturn[q]].split("-")[0].to_i,@efight[q][@eturn[q]],@efightvalue[q][@eturn[q]],q]) #持续\v回合的debuff
      @oldmcombo-=@efightvalue[q][@eturn[q]].split("-")[1].to_f
      @mcombo=Math.sqrt([@oldmcombo,0].max)/10.0
      @evampire[q]+=@efightvalue[q][@eturn[q]].split("-")[2].to_f/100
    when 33 #洗礼
      @ecanattack[q]=1 if @ecanattack[q]<1 #自我缴械，当前回合不作普通攻击
      @ehp[q]+=erecover(q,@efightvalue[q][@eturn[q]].split("-")[0].to_f)
      self.edamage+=@efightvalue[q][@eturn[q]].split("-")[1].to_f
    when 34 #驱逐
      @ecanattack[q]=1 if @ecanattack[q]<1 #自我缴械，当前回合不作普通攻击
      @edebuff[q].push([@efightvalue[q][@eturn[q]].to_i,@efight[q][@eturn[q]],0,q,true])
      @ebkb[q]=2 if @ebkb[q]!=1 #不会覆盖真实魔免
    when 40 #重音击
      @ecanattack[q]=1 if @ecanattack[q]<1 #自我缴械，当前回合不作普通攻击
      a=0
      $game_map.events.each_value{ |value|
        if value.character_name!=""
          a+=1
        end
      }
      self.edamage+=magicdam(q,@efightvalue[q][@eturn[q]].to_i*a)
    when 43 #轰雷
      self.edamage+=magicdam(q,@efightvalue[q][@eturn[q]].split("-")[0].to_i)
      val=@efightvalue[q][@eturn[q]].split("-")[1].to_i
      mjiaoxie(val)
    when 44 #法力燃烧
      val2=@efightvalue[q][@eturn[q]].split("-")[0].to_i
      val=[@actor.sp-@spcost,val2].min
      if have_skill(q,63) && val>0
        @ehp[@rtarget]+=val*@efightvalue[q][@eturn[q]].split("-")[1].to_f/2
      end
      @spcost+=val
      self.edamage+=magicdam(q,(val2-val)*@efightvalue[q][@eturn[q]].split("-")[1].to_i)
    when 47 #诅咒
      @zuzhou=self.edamage
      @mdebuff.push([@efightvalue[q][@eturn[q]].split("-")[0].to_i,@efight[q][@eturn[q]],@efightvalue[q][@eturn[q]],q])
    when 48 #幽冥剧毒
      @ecanattack[q]=1 if @ecanattack[q]<1
      a=@efightvalue[q][@eturn[q]].split("-")
      self.edamage+=poison_damage(q,a[0].to_i)
      d=a[1].to_i
      if $game_variables[226]!=0 && $game_variables[226][4]>3
        d*=1-($game_variables[226][4]-3)*0.25
      end
      @poison+=d.to_i
      if have_skill(q,142) && d>0 #毒素烙印
        check=false
        for i in @afterevent
          if i[0]==8
            i[1]+=@eskill[q][142].to_i
            check=true;break
          end
        end
        if !check
          @afterevent.push([8,@eskill[q][142].to_i]) #战后处理
        end
      end
      if d>0
        @afterevent.push([0,d]) #战后处理
      end
    when 58 #烈火精灵
      a=@efightvalue[q][@eturn[q]].split("-")
      @mdebuff.push([4,@efight[q][@eturn[q]],@efightvalue[q][@eturn[q]],q]) #持续4回合的debuff
      self.edamage+=magicdam(q,a[1].to_i)
      @oldmcombo-=a[2].to_f
      @mcombo=Math.sqrt([@oldmcombo,0].max)/10.0
    when 60 #嗜血术
      @estatus[60]=[] if @estatus[60]==nil
      a=@efightvalue[q][@eturn[q]].split("-")
      i=a[2].to_i
      while @ehp[i]<=0 || @estatus[60][i]!=nil
        @eturn[q]+=1
        break if @efight[q][@eturn[q]] != 60
        a=@efightvalue[q][@eturn[q]].split("-")
        i=a[2].to_i
      end
      if @efight[q][@eturn[q]]!=60
        enemy_skill(q,1) if @efight[q][@eturn[q]]!=nil
      else
        @ecanattack[q]=1 if @ecanattack[q]<1
        @oldecombo[i]+=a[0].to_i
        @ecombo[i]=Math.sqrt([@oldecombo[i],0].max)/10.0
        @evampire[i]+=a[1].to_f/100
        @estatus[60][i]=0 #表示已经有BUFF
      end
    when 61 #火焰爆轰
      a=@efightvalue[q][@eturn[q]].split("-")
      @ecanattack[q]=1 if @ecanattack[q]<1 #自我缴械，当前回合不作普通攻击
      mxuanyun(a[1].to_i) #眩晕玩家
      self.edamage+=magicdam(q,a[0].to_i*(1.2**first)) #受到多重强化，伤害递增20%
    when 62 #引燃
      a=@efightvalue[q][@eturn[q]].split("-")
      @mdebuff.push([a[2].to_i,@efight[q][@eturn[q]],@efightvalue[q][@eturn[q]],q]) #持续\v回合的debuff
      @oldmcombo-=a[1].to_f
      @mcombo=Math.sqrt([@oldmcombo,0].max)/10.0
    when 69 #伤残恐惧
      a=@efightvalue[q][@eturn[q]].split("-")
      @mdebuff.push([a[1].to_i,@efight[q][@eturn[q]],@efightvalue[q][@eturn[q]],q]) #持续\v回合的debuff
      @mhitrate-=a[0].to_f/100
      mchenmo(a[1].to_i)
      if @estatus[86]!=nil
        for qq in 0...@elist.size
          @emakedamage[qq]*=(1+@estatus[86]/100.0)
        end
      end
    when 76 #守护天使
      @ecanattack[q]=1 if @ecanattack[q]<1 #自我缴械，当前回合不作普通攻击
      a=@efightvalue[q][@eturn[q]].split("-")
      for i in 0...@elist.size
        if @ehp[i]>0
          @edebuff[i].push([a[0].to_i,@efight[q][@eturn[q]],q,a[1].to_f/100,true]) #全体物免BUFF
          @edecdamage[i]+=@actor.str*100
        end
      end
      for i in @eturn[q]+1...@efight[q].size
        if @efight[q][i]==33
          a=@efightvalue[q][i].split("-")
          for j in 0...@elist.size
            if @ehp[j]>0
              @ehp[j]+=a[0].to_f
              self.edamage+=a[1].to_f
            end
          end
          @efight[q].delete_at(i)
          @efightvalue[q].delete_at(i)
          break
        end
      end
    when 77 #恶念瞥视
      a=@efightvalue[q][@eturn[q]].split("-")
      @mdebuff.push([a[0].to_i,@efight[q][@eturn[q]],@efightvalue[q][@eturn[q]],q]) #持续\v回合的debuff
      @afterevent.push([3,a[1].to_i]) #恶念瞥视
    when 79 #法力虚空
      a=@efightvalue[q][@eturn[q]].split("-")
      mxuanyun(a[0].to_i) #眩晕玩家
      self.edamage+=(@actor.maxsp-(@actor.sp-@spcost))*a[1].to_f
    when 181 #法力黑洞
      a=@efightvalue[q][@eturn[q]].split("-")
      mxuanyun(a[0].to_i) #眩晕玩家
      self.edamage+=(@actor.maxsp-@actor.sp+@spcost)/@actor.maxsp.to_f*a[1].to_f*@actor.maxhp
    when 80 #伪无敌斩
      a=@efightvalue[q][@eturn[q]].split("-")
      @edebuff[q].push([a[0].to_i+1,@efight[q][@eturn[q]],q,a[1].to_i,true])
      @ecanspell[q]=-1
      @ecanattack[q]=-1 if @ecanattack[q]==0#负数表示蓄力状态
    when 160 #无敌斩
      a=@efightvalue[q][@eturn[q]].split("-")
      if have_skill(q,72) #剑舞 \v\v
        b=@eskill[q][72].split("-")[1].to_f
      else
        b=1
      end
      c=1
      if have_skill(q,13) #致命一击 \v\v
        c*=@eskill[q][13].split("-")[1].to_f
      end
      if have_skill(q,31) #混沌一击 \v\v
        c*=@eskill[q][31].split("-")[1].to_f
      end
      if check_player_ghost?
        c*=a[2].to_f/100
      end
      for i in 0...a[0].to_i
        d=[[ephysicaldam(q,$data_enemies[@elist[q]].atk*b-@md),0].max-@mdecdamage,0].max*@emakedamage[q]
        self.edamage+=d*c
        @oldmshield-=a[1].to_f
        self.mshield=@actor.rshield(@oldmshield)
      end
    when 84 #死亡
      @ecanattack[q]=1 if @ecanattack[q]<1 #自我缴械，当前回合不作普通攻击
      a=@efightvalue[q][@eturn[q]].split("-")
      self.edamage+=magicdam(q,a[0].to_f)
      value=@actor.hp
      rate=a[1].to_i
      count=0
      for j in 1...a[1].length+1
        if a[1][a[1].length-j]==48
          count+=1
        else
          break
        end
      end
      count=10**count
      value/=count
      rate/=count
      if (value).to_i%rate==0
        self.edamage+=magicdam(q,@mmaxhp*a[2].to_f/100)
      end
    when 87 #霜冻护甲
      @estatus[87]=[] if @estatus[87]==nil
      a=@efightvalue[q][@eturn[q]].split("-")
      i=a[2].to_i
      while @ehp[i]<=0 || @estatus[87][i]!=nil
        @eturn[q]+=1
        break if @efight[q][@eturn[q]] != 87
        a=@efightvalue[q][@eturn[q]].split("-")
        i=a[2].to_i
      end
      if @efight[q][@eturn[q]]!=87
        enemy_skill(q,1) if @efight[q][@eturn[q]]!=nil
      else
        @ecanattack[q]=1 if @ecanattack[q]<1
        @oldeshield[i]+=a[0].to_i
        @eshield[i]=@actor.rshield(@oldeshield[i])
        @estatus[87][i]=a[1].to_i  #表示已经有BUFF
      end
    when 88 #冰霜新星
      a=@efightvalue[q][@eturn[q]].split("-")
      @mdebuff.push([a[0].to_i,@efight[q][@eturn[q]],@efightvalue[q][@eturn[q]],q])
      @oldmcombo-=a[2].to_i
      @mcombo=Math.sqrt([@oldmcombo,0].max)/10.0
      self.edamage+=magicdam(q,a[1].to_f)
      if a[3].to_i==100
        @mmisszero+=1
      else
        @mmiss=1-(1-@mmiss)*(1-a[3].to_f/100.0)
      end
    when 89 #冰封禁制
      a=@efightvalue[q][@eturn[q]].split("-")
      @mdebuff.push([a[0].to_i,@efight[q][@eturn[q]],@efightvalue[q][@eturn[q]],q])
      mjiaoxie(a[0].to_i)
      @mmisszero+=1
    when 90 #极寒之触
      a=@efightvalue[q][@eturn[q]].split("-")
      @mdebuff.push([a[0].to_i,@efight[q][@eturn[q]],@efightvalue[q][@eturn[q]],q])
    when 93 #极寒领域
      a=@efightvalue[q][@eturn[q]].split("-")
      @edebuff[q].push([a[0].to_i,@efight[q][@eturn[q]],q,@efightvalue[q][@eturn[q]],true])
      @oldmcombo-=a[1].to_i
      @mcombo=Math.sqrt([@oldmcombo,0].max)/10.0
      @ecanspell[q]=-1
      @ecanattack[q]=-1 #负数表示蓄力状态
    when 95 #灵魂汲取
      a=@efightvalue[q][@eturn[q]].to_i
      if @soulcost+a>$game_variables[197]
        self.edamage+=@mmaxhp*3
        @afterevent.push([5])
      else
        @soulcost+=a
      end
    when 97 #严寒灼烧
      a=@efightvalue[q][@eturn[q]].split("-")
      @mdebuff.push([a[0].to_i,@efight[q][@eturn[q]],@efightvalue[q][@eturn[q]],q])
    when 98 #寒冬诅咒
      a=@efightvalue[q][@eturn[q]].split("-")
      @mdebuff.push([a[0].to_i,@efight[q][@eturn[q]],@efightvalue[q][@eturn[q]],q])
      mxuanyun(a[0].to_i)
    when 106 #阳炎之索
      a=@efightvalue[q][@eturn[q]].split("-")
      @mdebuff.push([a[1].to_i,@efight[q][@eturn[q]],@efightvalue[q][@eturn[q]],q])
      mjiaoxie(a[1].to_i)
      @mmisszero+=1
    when 108 #火焰壁垒
      a=@efightvalue[q][@eturn[q]].split("-")
      @estatus[108]=[] if @estatus[108]==nil
      @estatus[108][q]=[a[1].to_i,a[0].to_i]
      @eskill[q][108]=1
    when 111 #风漩
      a=@efightvalue[q][@eturn[q]].split("-")
      @mdebuff.push([a[0].to_i,@efight[q][@eturn[q]],@efightvalue[q][@eturn[q]],q])
      @mcanspell=1 if @mcanspell<1
      @mmisszero+=1
    when 116 #决斗
      a=@efightvalue[q][@eturn[q]].split("-")
      @estatus[116]=[(@mhp-self.edamage).to_f/@mhp,@ehp[q].to_f/@emaxhp[q]]
      @mdebuff.push([a[0].to_i,@efight[q][@eturn[q]],@efightvalue[q][@eturn[q]],q])
      @ecanspell[q]=1 if @ecanspell[q]<1
      @mcanspell=1 if @mcanspell<1
      @mmisszero+=1
    when 118 #飓风
      a=@efightvalue[q][@eturn[q]].split("-")
      @estatus[118]=[] if @estatus[118]==nil
      @estatus[118][q]=[a[0].to_i,a[1].to_i]
      @oldmcombo-=a[1].to_i
      @mcombo=Math.sqrt([@oldmcombo,0].max)/10.0
      @mmisszero+=1
      @ecanspell[q]=-1
      @ecanattack[q]=-1 #负数表示蓄力状态
      @eskill[q][118]=1
    when 120 #地震
      a=@efightvalue[q][@eturn[q]].split("-")
      @edebuff[q].push([a[0].to_i+1,@efight[q][@eturn[q]],q,@efightvalue[q][@eturn[q]],true])
      @ecanspell[q]=-1
      @ecanattack[q]=-1 #负数表示蓄力状态
    when 126 #电磁脉冲
      a=@efightvalue[q][@eturn[q]].split("-")
      @mdebuff.push([a[0].to_i,@efight[q][@eturn[q]],@efightvalue[q][@eturn[q]],q])
    when 127 #超震声波
      a=@efightvalue[q][@eturn[q]].split("-")
      self.edamage+=magicdam(q,a[0].to_f)
      mxuanyun(a[1].to_i)
    when 134 #神龙摆尾
      a=@efightvalue[q][@eturn[q]].split("-")
      mxuanyun(a[0].to_i) #眩晕玩家
      val=1-a[2].to_f/100
      @enodamage[q]*=val
      @edebuff[q].push([a[1].to_i+1,@efight[q][@eturn[q]],q,val,true])
    when 137 #绝对净化
      mpurge
      @eturn[q]+=1
      enemy_skill(q) if @eturn[q]<@efight[q].size
    when 140 #狂战怒吼
      a=@efightvalue[q][@eturn[q]].split("-")
      val=a[0].to_i
      @mcanspell=val if @mcanspell<a[0].to_i
      val=@oldmcombo*(a[1].to_i-1)
      @oldmcombo+=val
      @mcombo=Math.sqrt([@oldmcombo,0].max)/10.0
      @mdebuff.push([a[0].to_i,@efight[q][@eturn[q]],val,q,true])
      val=$data_enemies[@elist[q]].eva*(a[2].to_i-1)
      @oldeshield[q]+=val
      @eshield[q]=@actor.rshield(@oldeshield[q])
      @edebuff[q].push([a[0].to_i+1,@efight[q][@eturn[q]],q,val,true])
      @rtarget=q
    when 143 #致命连接
      a=@efightvalue[q][@eturn[q]].split("-")
      @edebuff[@rtarget].push([a[0].to_i+1,@efight[q][@eturn[q]],[@alldamage,@ehp[@rtarget]],a[1].to_f/100,true])
      @eskill[@rtarget][143]=1
      @estatus[143]=@ehp[@rtarget]
    when 145 #强力击
      a=@efightvalue[q][@eturn[q]].split("-")
      @edebuff[q].push([a[0].to_i+1,@efight[q][@eturn[q]],q,[a[1].to_f,a[3].to_f],true])
      @ecanspell[q]=-1
      @ecanattack[q]=-1 #负数表示蓄力状态
    when 146 #风行
      a=@efightvalue[q][@eturn[q]].split("-")
      @edebuff[q].push([a[0].to_i+1,@efight[q][@eturn[q]],q,a[1].to_f,true])
      @emisszero[q]-=1
      @oldecombo[q]+=a[1].to_f
      @ecombo[q]=Math.sqrt([@oldecombo[q],0].max)/10.0
    when 147 #寄生种子
      a=@efightvalue[q][@eturn[q]].split("-")
      @mdebuff.push([a[0].to_i,@efight[q][@eturn[q]],a[1].to_f,q])
    when 148 #活体护甲
      a=@efightvalue[q][@eturn[q]].split("-")
      q=@rtarget
      save=q
      while q>=0
        if ehavebuff?(q,148)==-1
          @ecanattack[q]=1 if @ecanattack[q]<1
          @oldeshield[q]+=a[1].to_i
          @eshield[q]=@actor.rshield(@oldeshield[q])
          @ed[q]+=a[2].to_f/@eshield[q]
          @edebuff[q].push([a[0].to_i+1,@efight[q][@eturn[q]],q,[a[1].to_i,a[2].to_f/@eshield[q],a[3].to_f/100],true])
          break
        end
        q-=1
        q=@elist.size-1 if q==-1
        break if q==save
      end
    when 171 #自杀攻击
      a=@efightvalue[q][@eturn[q]].split("-")
      @ecanspell[q]=a[0].to_i
      @ecanattack[q]=a[0].to_i
      @edebuff[q].push([a[0].to_i+1,@efight[q][@eturn[q]],q,[a[1].to_f,a[2].to_f],false])
    when 172 #战场轰炸
      a=@efightvalue[q][@eturn[q]].split("-")
      @ecanspell[q]=a[0].to_i
      @ecanattack[q]=a[0].to_i
      @edebuff[q].push([a[0].to_i,@efight[q][@eturn[q]],q,a,false])
    when 174 #追踪导弹
      a=@efightvalue[q][@eturn[q]].split("-")
      if @actor.hprate>=@actor.sprate
        self.edamage+=magicdam(q,a[0].to_f)
        mxuanyun(a[1].to_i)
      else
        self.edamage+=ephysicaldam(q,a[0].to_f*@emakedamage[q])
        val=[@actor.sp-@spcost,a[2].to_f].min
        @spcost+=val
      end
    when 176 #激光
      a=@efightvalue[q][@eturn[q]].split("-")
      self.edamage+=a[0].to_f
      val=a[1].to_f/100
      @oldmshield=(@oldmshield*(1-val)).to_i
      self.mshield=@actor.rshield(@oldmshield)
    when 182 #牺牲
      a=@efightvalue[q][@eturn[q]].split("-")
      val=@ehp[q]*(a[0].to_f/100)
      val2=val*(a[1].to_f/100)
      if @ehp[q]/@emaxhp[q]>a[2].to_f/100
        self.edamage+=magicdam(q,val2)
      else
        self.edamage+=val
      end
      @ehp[q]-=val
    when 183 #活血术
      a=@efightvalue[q][@eturn[q]].split("-")
      @edebuff[@rtarget].push([a[0].to_i,@efight[q][@eturn[q]],q,a[1].to_f/100,true])
    when 186 #极寒风暴
      a=@efightvalue[q][@eturn[q]].split("-")
      @edebuff[q].push([a[0].to_i,@efight[q][@eturn[q]],q,@efightvalue[q][@eturn[q]],true])
      @oldmcombo-=a[1].to_i
      @mcombo=Math.sqrt([@oldmcombo,0].max)/10.0
      @ecanspell[q]=-1
      @ecanattack[q]=-1 #负数表示蓄力状态
      @ebkb[q]=2
    when 190 #黑龙吐息
      a=@efightvalue[q][@eturn[q]].split("-")
      self.edamage+=magicdam(q,a[0].to_i)
      self.edamage+=ephysicaldam(q,a[0].to_i*@emakedamage[q])
      @md*=1-a[3].to_f/100
      @mdebuff.push([a[1].to_i,@efight[q][@eturn[q]],a[2].to_f/100,q])
    when 192 #猛毒缠身
      a=@efightvalue[q][@eturn[q]].split("-")
      self.edamage+=poison_damage(q,a[0].to_i)
      if !have_skill(q,223) && $game_variables[226]!=0 && $game_variables[226][4]==7
      else
        check=false
        for i in @afterevent
          if i[0]==14
            i[1]+=a[1].to_i
            check=true;break
          end
        end
        if !check
          @afterevent.push([14,a[1].to_i]) #战后处理
        end
      end
    when 195 #虚弱之诏
      a=@efightvalue[q][@eturn[q]].split("-")
      self.edamage+=magicdam(q,a[0].to_i)
      if !have_skill(q,223) && $game_variables[226]!=0 && $game_variables[226][24]==7
      else
        val=a[1].to_i
        if !have_skill(q,223) && $game_variables[226]!=0 && $game_variables[226][24]>=4
          val=[val-1,1].max
        end
        check=false
        for i in @afterevent
          if i[0]==15
            i[1]+=val
            check=true;break
          end
        end
        if !check
          @afterevent.push([15,val]) #战后处理
        end
      end
    when 199 #剑刃风暴
      a=@efightvalue[q][@eturn[q]].split("-")
      @edebuff[q].push([a[0].to_i+1,@efight[q][@eturn[q]],q,a[1].to_f,true])
      @ebkb[q]=2
      @ecanattack[q]=a[0].to_i
    when 202 #巨浪
      a=@efightvalue[q][@eturn[q]].split("-")
      self.edamage+=magicdam(q,a[0].to_i)
      @mmisszero+=1
      @oldmshield-=a[2].to_i
      self.mshield=@actor.rshield(@oldmshield)
      @mdebuff.push([a[1].to_i,@efight[q][@eturn[q]],a[2].to_i,q])
    when 208 #月神之箭
      a=@efightvalue[q][@eturn[q]].split("-")
      self.edamage+=magicdam(q,a[1].to_f/100*a[3].to_f)
      mxuanyun(a[2].to_i) #眩晕玩家
    when 209 #群星风暴
      a=@efightvalue[q][@eturn[q]].split("-")
      val=@mmaxhp/100.0*a[0].to_f+a[1].to_f
      self.edamage+=magicdam(q,val)
      @edebuff[q].push([a[2].to_i+1,@efight[q][@eturn[q]],q,val/100.0*a[3].to_f,true])
      @ecanspell[q]=-1
      @ecanattack[q]=-1 if @ecanattack[q]==0#负数表示蓄力状态
    when 211 #命运之笔
      @ecanattack[q]=1 if @ecanattack[q]<1 #自我缴械，当前回合不作普通攻击
      if @estatus[211]==nil
        @estatus[211]=0
      end
      a=@efightvalue[q][@eturn[q]].split("-")
      val=a[3].to_f/100+1
      val=a[1].to_f*(val**@estatus[211])
      @estatus[211]+=1
      self.edamage+=magicdam(q,val)
      @edebuff[q].push([a[2].to_i+1,@efight[q][@eturn[q]],q,val/100.0*a[3].to_f,true])
      check=false
      for i in @afterevent
        if i[0]==17
          i[1]+=a[2].to_i
          check=true;break
        end
      end
      if !check
        @afterevent.push([17,a[2].to_i]) #战后处理
      end
    when 214 #否决之力
      a=@efightvalue[q][@eturn[q]].split("-")
      val2=a[0].to_i
      val=[@actor.sp-@spcost,val2].min
      @spcost+=val
      check=false
      for i in @afterevent
        if i[0]==16
          i[1]+=a[1].to_i
          check=true;break
        end
      end
      if !check
        @afterevent.push([16,a[1].to_i]) #战后处理
      end
    when 215 #憎恶
      @abominate_list=[1,2,3,5,7,11,13,17,19,23,29,31,37,41,43,47]
      a=@efightvalue[q][@eturn[q]].split("-")
      mxuanyun(1)
      self.edamage+=a[0].to_f+(@mhp-self.edamage)*a[1].to_f/100
      @mdebuff.push([a[2].to_i-1,@efight[q][@eturn[q]],q,[1,1,a[0].to_f,a[1].to_f/100]])
    when 216 #暮色凋零
      a=@efightvalue[q][@eturn[q]].split("-")
      @edebuff[q].push([a[0].to_i,@efight[q][@eturn[q]],q,@efightvalue[q][@eturn[q]],true])
      @ecanspell[q]=-1
      @ecanattack[q]=-1 #负数表示蓄力状态
    when 218 #超强力量
      eremove_debuff(q) #驱散自身不良状态
      a=@efightvalue[q][@eturn[q]].split("-")
      val=[@oldecombo[q]*a[1].to_f,@ea[q]*a[2].to_f/100]
      @edebuff[q].push([a[0].to_i,@efight[q][@eturn[q]],q,val,true])
      @oldecombo[q]+=val[0]
      @ecombo[q]=Math.sqrt([@oldecombo[q],0].max)/10.0
      @ea[q]+=val[1]
    when 220 #九阳踏天
      a=@efightvalue[q][@eturn[q]].split("-")
      val=a[0].to_f+(@mmaxhp-@mhp+@edamage)*(a[1].to_f/100)
      self.edamage+=val
      mxuanyun(a[2].to_i) #眩晕玩家
    when 222 #命源逆转
      a=@efightvalue[q][@eturn[q]].split("-")[0].to_f/100
      val=[(@mhp-@edamage)/@mmaxhp,a].min
      val2=[(@actor.sp-@spcost.to_f)/@actor.maxsp,a].min
      @edamage=@mhp-@mmaxhp*val2
      @spcost=@actor.sp-@actor.maxsp*val
    when 224 #风暴之锤
      a=@efightvalue[q][@eturn[q]].split("-")
      @ecanattack[q]=1 if @ecanattack[q]<1 #自我缴械，当前回合不作普通攻击
      mxuanyun(a[1].to_i) #眩晕玩家
      self.edamage+=magicdam(q,a[0].to_f) #受到多重强化，伤害递增20%
    when 225 #神之力量
      a=@efightvalue[q][@eturn[q]].split("-")
      val=$data_enemies[@elist[q]].atk*a[1].to_f/100
      val2=$data_enemies[@elist[q]].maxhp*a[2].to_f/100#怪生命
      @ea[q]+=val
      @ehp[q]+=@ehp[q]/@emaxhp[q]*val2
      @emaxhp[q]+=val2
      @edebuff[q].push([a[0].to_i,@efight[q][@eturn[q]],q,[val,val2],true])
    end
  end
  #反击类技能伤害
  def counterskill(i)
    @lsvar[i]=0
    d=0
    return d if @epassbreak[i]>0
    if have_skill(i,11) #野兽直觉
      if @ecanattack[i]==0
        a=ephysicaldam(i,[@ea[i]-@md,0].max*@emakedamage[i])
        @lsvar[i]+=a*@evampire[i]
        d+=a
        d+=enormal_attack(i,1)
        first_attack_debuff(i)
      end
    end
    if  have_skill(i,75) #反击
      if @ecanattack[i]==0
        a=ephysicaldam(i,[@ea[i]-@md,0].max*@mcombo*enemy_miss(i)*@emakedamage[i])
        @lsvar[i]+=a*@evampire[i]
        d+=a
        d+=enormal_attack(i,@mcombo*enemy_miss(i))
        first_attack_debuff(i)
      end
    end
    if  have_skill(i,139) #反击螺旋
      a=ephysicaldam(i,@eskill[i][139].to_f*@mcombo*enemy_miss(i)*@emakedamage[i])
      d+=a
    end
    if have_skill(i,82) #攻击反噬
      a=@eskill[i][82].to_f/100
      b=mturn_damage(i)-mtd_extra(i)
      if @mbkb==0
        d+=magicdam(i,b)*a
      end
    end
    if have_skill(i,83) #勇气之霎 \v\v
      b=@eskill[i][83].split("-")
      a=ephysicaldam(i,(b[0].to_f/100)*[@ea[i]-@md,0].max*@emakedamage[i])
      @lsvar[i]+=a*(b[1].to_f/100+@evampire[i])
      d+=a
      d+=enormal_attack(i,1)
      first_attack_debuff(i)
    end
    if @estatus[128]!=nil #荆棘光环
      a=@estatus[128].to_f/100
      b=mturn_damage(i)-mtd_extra(i)
      d+=ephysicaldam(i,[b,@ehp[i]].min*a)
    end
    if have_skill(i,221) #抗性皮肤
      if @mbkb==0
        a=@eskill[i][221].to_f/100
        b=mturn_damage(i)-mtd_extra(i)
        d+=[b,@ehp[i]].min*a
      end
    end
    @havedamage=true if d>0
    return d
  end
  #第一次命中后开始生效的法球
  def first_attack_debuff(i)
    return if @epassbreak[i]>0
    if have_skill(i,1) #寒霜攻击 \v
      if @estatus[1]==nil && @ecanattack[i]==0
        @estatus[1]=true
        @oldmcombo-=@eskill[i][1].to_i
        @mcombo=Math.sqrt([@oldmcombo,0].max)/10.0
      end
    end
    if have_skill(i,29) #淬毒攻击 \v
      if @estatus[29]==nil && @ecanattack[i]==0
        @estatus[29]=true
      end
    end
    if have_skill(i,31) #混沌一击 \v
      if @estatus[31]==nil && @ecanattack[i]==0
        @estatus[31]=true
        @oldmshield-=@eskill[i][31].split("-")[2].to_i
        self.mshield=@actor.rshield(@oldmshield)
      end
    end
    if have_skill(i,113) #野性掠夺 \v\v
      if @estatus[113]==nil && @ecanattack[i]==0
        @estatus[113]=true
        a=@eskill[i][113].split("-")
        value=@actor.base_str
        for jj in @actor.states
          value *= $data_states[jj].str_rate / 100.0
        end
        value=(@actor.str-value)*(a[1].to_f/100)
        @ma-=value
        @ea[i]+=value
        @oldmcombo-=a[0].to_i
        @mcombo=Math.sqrt([@oldmcombo,0].max)/10.0
        @oldecombo[i]+=a[0].to_i
        @ecombo[i]=Math.sqrt([@oldecombo[i],0].max)/10.0
      end
    end
    if have_skill(i,193) #魔霭诅咒 \v\v
      if @estatus[193]==nil && @ecanattack[i]==0
        @estatus[193]=true
        a=@eskill[i][193].split("-")
        value=a[0].to_i
        if @oldmcombo>value
          value=@oldmcombo-value
          @oldmcombo=a[0].to_i
          @mcombo=Math.sqrt([@oldmcombo,0].max)/10.0
          for q in 0...@elist.size
            @oldecombo[q]+=value
            @ecombo[q]=Math.sqrt([@oldecombo[q],0].max)/10.0
          end
        end
        value=a[1].to_f
        if @oldmshield>value
          value=@oldmshield-value
          @oldmshield=a[1].to_f
          self.mshield=@actor.rshield(@oldmshield)
          for q in 0...@elist.size
            @oldeshield[q]+=value
            @eshield[q]=@actor.rshield(@oldeshield[q])
          end
        end
      end
    end
    if have_skill(i,70) #破甲熔炎 \v\v
      if @ecanattack[i]==0
        a=@eskill[i][70].split("-")
        @estatus[70]=[] if @estatus[70]==nil
        if @estatus[70][i]==nil
          @estatus[70][i]=0
        end
        if @estatus[70][i]<a[1].to_i
          k=a[0].to_i*@ecombo[i]*player_miss(i)
          @estatus[70][i]+=k
          if @estatus[70][i]>a[1].to_i
            k=a[1].to_i+k-@estatus[70][i]
            @estatus[70][i]=a[1].to_i
            size=@edebuff[i].size
            j=0
            while j<size
              if @edebuff[i][j][1]==70
                @edebuff[i].delete_at(j)
                size-=1
              else
                j+=1
              end
            end
          end
          @oldmshield-=k
          self.mshield=@actor.rshield(@oldmshield)
        end
      end
    end
    if have_skill(i,119) #腐尸毒 \v
      if @estatus[119]==nil && @ecanattack[i]==0
        @estatus[119]=true
        a=@eskill[i][119].split("-")
        @oldmcombo-=a[2].to_i
        @mcombo=Math.sqrt([@oldmcombo,0].max)/10.0
        for q in 0...@elist.size
          @emakedamage[q]+=a[1].to_f/100
        end
      end
    end
  end
  def support_skill(zdskill,zdvalue) #支援技能处理
    if $supskill.size>0
      savesk=[]
    end
    for i in $supskill
      sw=true
      if $data_skills[i[0]].scope==2 && savesk[i[0]]==nil
        for q in 0...@elist.size
          for j in 0...zdskill[q].size
            if zdskill[q][j]==i[0] && zdvalue[q][j]==i[1]
              savesk[i[0]]=true
              sw=false
              break
            end
          end
          break if !sw
        end
      end
      if sw
        if $data_skills[i[0]].animation2_id>0
          @animation.push($data_skills[i[0]].animation2_id)
        end
        case i[0]
        when 33 #洗礼
          return if have_skill(@rtarget,66)
          if @table[$data_enemies[@elist[@rtarget]].element_ranks[3]]
            @ehp[@rtarget]-=i[1].split("-")[0].to_f if @ebkb[@rtarget]==0
          else
            @ehp[@rtarget]+=i[1].split("-")[0].to_f
          end
          self.edamage+=i[1].split("-")[1].to_f
        when 34 #驱逐
          target=is_bkb?(@rtarget)
          next if @ebkb[target]>0
          #持续时间，技能编号，技能数值，来源（0为无来源或来自于玩家），是否为增益状态
          @edebuff[target].push([i[1].to_i,i[0],0,0,true])
          @ebkb[target]=2 if @ebkb[target]!=1 #不会覆盖真实魔免
        when 35 #退化光环
          if @estatus[35]==nil
            @estatus[35]=true
            @oldmcombo-=i[1].split("-")[0].to_f
            @mcombo=Math.sqrt([@oldmcombo,0].max)/10.0
            if i[1].split("-")[1].to_i==100
              @mmisszero+=1
            else
              @mmiss=1-(1-@mmiss)*(1-i[1].split("-")[1].to_f/100.0)
            end
          end
        when 67 #绝望光环
          if @estatus[67]==nil
            @estatus[67]=true
            a=i[1].split("-")
            val=a[0].to_f/100
            val/=2 if $game_variables[177]>=2
            @oldmshield=(@oldmshield*(1-val)).to_i
            self.mshield=@actor.rshield(@oldmshield)
            val=a[1].to_f/100
            val/=2 if $game_variables[177]>=2
            @mmagicdef[1]+=val
          end
        when 91 #精气光环
          if @estatus[91]==nil
            @estatus[91]=true
            a=i[1].to_i
            for q in 0...@elist.size  
              if @efight[q]!=[0]
                s1=@efight[q].clone
                s2=@efightvalue[q].clone
                for j in 0...a-1
                  @efight[q]+=s1
                  @efightvalue[q]+=s2
                end
              end
            end
          end
        when 92 #奥术光环
          if @estatus[92]==nil
            @estatus[92]=i[1].to_i
          end
        when 148 #活体护甲
          a=i[1].split("-")
          q=@rtarget
          save=q
          while q>=0
            if ehavebuff?(q,148)==-1 && @ehp[q]>=0
              @ehp[q]+=erecover(q,a[3].to_f/100*@emaxhp[q])
              @oldeshield[q]+=a[1].to_i
              @eshield[q]=@actor.rshield(@oldeshield[q])
              @ed[q]+=a[2].to_f/@eshield[q]
              @edebuff[q].push([a[0].to_i,148,q,[a[1].to_i,a[2].to_f/@eshield[q],a[3].to_f/100],true])
              break
            end
            q-=1
            q=@elist.size-1 if q==-1
            break if q==save
          end
        when 156 #禁魔领域
          if @estatus[156]==nil
            @estatus[156]=i[1].split("-")[0].to_f/100
          end
        when 198 #壮烈成仁
          if @estatus[198]==nil
            @estatus[198]=i[1].split("-")[0].to_f/100
          end
        when 158 #幽冥守卫
          if @estatus[158]==nil
            @estatus[158]=i[1].split("-")[1].to_f
          end
        when 210 #回溯共鸣
          if @estatus[210]==nil
            @estatus[210]=[]
            @estatus[210][0]=i[1].split("-")[2].to_f/100
          else
            val=i[1].split("-")[0].to_f/100
            if val>@estatus[210][0]
              @estatus[210][0]=val
            end
          end
          for q in 0...@elist.size
            @estatus[210][q+1]=false
          end
        end
      end
    end
  end
  def area_skill #范围光环处理
    for i in @area
      value=i[1].split("-")
      case i[0]
      when 100 #神力图腾
        for q in 0...@elist.size
          @ea[q]=@ea[q]*(1+value[0].to_f/100)
        end
      when 101 #守护图腾
        for q in 0...@elist.size
          @ed[q]=@ed[q]*(1+value[0].to_f/100)
        end
      when 102 #治愈图腾
        if @estatus[102]==nil
          @estatus[102]=value[0].to_i
        else
          @estatus[102]+=value[0].to_i
        end
      when 103 #破甲光环
        if @estatus[103]==nil
          a=value[0].to_i
          @estatus[103]=a
          @oldmshield-=a
          self.mshield=@actor.rshield(@oldmshield)
        elsif value[0].to_i>@estatus[103]
          a=@estatus[103]-value[0].to_i
          @estatus[103]=value[0].to_i
          @oldmshield-=a
          self.mshield=@actor.rshield(@oldmshield)
        end
      when 110 #风之守护
        for q in 0...@elist.size
          @oldecombo[q]+=value[0].to_i
          @ecombo[q]=Math.sqrt([@oldecombo[q],0].max)/10.0
          @emiss[q]*=(1-value[1].to_f/100)
        end
      when 128 #荆棘光环
        if @estatus[128]==nil
          @estatus[128]=value[0].to_i
        elsif value[0].to_i>@estatus[128]
          @estatus[128]=value[0].to_i
        end
      when 133 #霜冻光环
        if @estatus[133]==nil
          @estatus[133]=value[0].to_i
          @oldmcombo-=value[0].to_i
          @mcombo=Math.sqrt([@oldmcombo,0].max)/10.0
          if value[1].to_i==100
            @mmisszero+=1
          else
            @mmiss=1-(1-@mmiss)*(1-value[1].to_f/100.0)
          end
        elsif value[0].to_i>@estatus[133]
          a=@estatus[133].split("-")
          if value[0].to_i>a[0].to_i
            @oldmcombo+=a[0].to_i
            if a[1].to_i==100
              @mmisszero-=1
            else
              @mmiss=1-(1-@mmiss)/(1-a[1].to_f/100.0)
            end
            @oldmcombo-=value[0].to_i
            @mcombo=Math.sqrt([@oldmcombo,0].max)/10.0
            if value[1].to_i==100
              @mmisszero+=1
            else
              @mmiss=1-(1-@mmiss)*(1-value[1].to_f/100.0)
            end
          end
          @estatus[133]=value[0].to_i
        end
      when 136 #血战誓约
        if @estatus[136]==nil
          for q in 0...@elist.size
            @eskill[q][75]=0
            @evampire[q]+=value[0].to_i/100.0
          end
          @estatus[136]=1
        end
      when 144 #竭心光环
        @edamage+=@mmaxhp*value[0].to_f/100
        @soulcost+=value[1].to_i
      when 159 #神力光环
        a=value[0].to_f/100
        for q in 0...@elist.size
          if i[2]!=nil
            x1=$game_map.events[i[2]].x
            x2=$game_map.events[i[3]].x
            y1=$game_map.events[i[2]].y
            y2=$game_map.events[i[3]].y
            b=a-[[(x1-x2).abs,(y1-y2).abs].max-1,0].max*value[1].to_f/100
          else
            b=a
          end
          @ea[q]=@ea[q]*(1+b)
          @ed[q]=@ed[q]*(1+b)
        end
      when 177 #真视领域
        if @actor.check_buff(7)
          @mturn=-1
          val=1+value[0].to_f/100
          @mmagicdef[1]*=val
          for q in 0...@elist.size
            @emakedamage[q]*=val
          end
          if !@afterevent.include?([12])
            @afterevent.push([12])
          end
        end
      when 178 #镜壁领域
        if @estatus[178]==nil
          for q in 0...@elist.size
            if @eskill[q][82]==nil
              @eskill[q][82]=value[0].to_i
            else
              @eskill[q][82]=value[1].to_i
            end
          end
          @estatus[178]=1
        end
      when 184 #焚灭之域
        for q in 0...@elist.size
          @estatus[108]=[] if @estatus[108]==nil
          @estatus[108][q]=[value[0].to_i,value[1].to_i]
          @eskill[q][108]=1
        end
      when 194 #强体光环
        for q in 0...@elist.size
          @emaxhp[q]=@emaxhp[q]*(1+value[0].to_f/100)
          @ehp[q]=@emaxhp[q]
        end
      when 196 #震荡领域
        mxuanyun(value[0].to_i)
        self.edamage+=magicdam(0,value[1].to_f)
      when 197 #阳炎冲击
        a=value[0].to_i
        if i[2]!=nil
          x1=$game_map.events[i[2]].x
          x2=$game_map.events[i[3]].x
          y1=$game_map.events[i[2]].y
          y2=$game_map.events[i[3]].y
          a+=((x1-x2).abs+(y1-y2).abs)*value[2].to_i
        end
        @mdebuff.push([a,i[0],value[1].to_f,0,true])
      when 213 #傲慢之心
        if @eid>0
          for q in 0...@elist.size
            if @elist[q]==value[0].to_i
              @ea[q]*=(1+value[1].to_f/100.0)
              @ehp[q]*=(1+value[2].to_f/100.0)
              @emaxhp[q]=@ehp[q]
              break
            end
          end
        end
      when 219 #不朽之域
        for q in 0...@elist.size
          if !got_p_val(@elist[q],219) && @eskill[q][18]==nil
            @eskill[q][18]=1
            enemy_new_pass(q,18)
          end
        end
      end
    end
  end
  def ecleardebuff(q)
    for i in @edebuff[q]
      i[0]-=1
     # if i[0]>=50 || i[0]<0
     #   p i
      #  exit
     # end
      case i[1]
      when 5 #紫怨主动
        val=[i[2]-@ehp[q],0].max*0.2
        @ehp[q]-=emagicdam(q,val)
        i[2]=@ehp[q]
      when 7 #血棘主动
        val=[i[2]-@ehp[q],0].max*0.3
        @ehp[q]-=emagicdam(q,val)
        i[2]=@ehp[q]
      when 34 #驱逐
        if i[0]==0
          @ebkb[q]=0 if @ebkb[q]==2 #驱逐结束，取消魔免
        end
      when 76 #守护天使
        if @ehp[q]>0
          @ehp[q]+=erecover(q,@ehp[i[2]]*i[3])
        end
        if i[0]==0
          @edecdamage[q]-=@actor.str*100
        end
      when 80 #伪无敌斩
        if @ecanspell[q]>=0
          i[0]=0 #蓄力中断
          eskill_break(q)
        else
          if i[0]==0
            @estatus[80]=true
            if have_skill(q,72) #剑舞 \v\v
              b=@eskill[q][72].split("-")[1].to_f
            else
              b=1
            end
            d=[[ephysicaldam(q,$data_enemies[@elist[q]].atk*b-@md),0].max-@mdecdamage,0].max*@emakedamage[q]
            b=1
            if have_skill(q,13) #致命一击 \v\v
              b*=@eskill[q][13].split("-")[1].to_f
            end
            if have_skill(q,31) #混沌一击 \v\v
              b*=@eskill[q][31].split("-")[1].to_f
            end
            if !check_player_ghost?
              self.edamage+=d*b*i[3] if @ecanattack[q]==-1 || $data_enemies[@elist[q]].element_ranks[199]==1
            end
            @ecanspell[q]=0
            @ecanattack[q]=0 if @ecanattack[q]==-1
          end
        end
      when 93 #极寒领域
        a=i[3].split("-")
        if @ecanspell[q]>=0
          i[0]=0 #蓄力中断
          @oldmcombo+=a[1].to_i
          @mcombo=Math.sqrt([@oldmcombo,0].max)/10.0
          eskill_break(q)
          for j in 0...a[3].to_i
            @efight[q].insert(@eturn[q]+1,0)
            @efightvalue[q].insert(@eturn[q]+1,"")
          end
          @ecanspell[q]=a[3].to_i
          @ecanattack[q]=a[3].to_i
        else
          self.edamage+=magicdam(q,a[2].to_f)
          if i[0]==0
            @oldmcombo+=a[1].to_i
            @mcombo=Math.sqrt([@oldmcombo,0].max)/10.0
            @ecanspell[q]=0
            @ecanattack[q]=0 if @ecanattack[q]==-1
          end
        end
      when 186 #极寒风暴
        a=i[3].split("-")
        if @ecanspell[q]>=0
          i[0]=0 #蓄力中断
          @ebkb[q]=0
          @oldmcombo+=a[1].to_i
          @mcombo=Math.sqrt([@oldmcombo,0].max)/10.0
          self.edamage+=magicdam(q,a[3].to_f)
          @ehp[q]-=emagicdam(q,a[3].to_f)
          eskill_break(q)
        else
          self.edamage+=magicdam(q,a[2].to_f)
          if i[0]==0
            @oldmcombo+=a[1].to_i
            @mcombo=Math.sqrt([@oldmcombo,0].max)/10.0
            @ecanspell[q]=0
            @ecanattack[q]=0
            @ebkb[q]=0
          end
        end
      when 120 #地震
        if @ecanspell[q]>=0
          i[0]=0 #蓄力中断
          eskill_break(q)
        else
          if i[0]==0
            a=i[3].split("-")
            @mdebuff.push([a[1].to_i,@efight[q][@eturn[q]],a[3]+"-"+a[4]+"-"+a[2],q])
            @oldmcombo-=a[2].to_i
            @mcombo=Math.sqrt([@oldmcombo,0].max)/10.0
            @mmisszero+=1
            @ecanspell[q]=0
            @ecanattack[q]=0
          end
        end
      when 134 #神龙摆尾减伤
        if i[0]==0
          @enodamage[q]/=i[3]
        end
      when 140 #狂战怒吼 护甲提升
        if i[0]==0
          @oldeshield[q]-=i[3]
          @eshield[q]=@actor.rshield(@oldeshield[q])
        end
      when 143 #致命连接
        if @mbkb==0 #未魔免
          self.edamage+=[[(i[2][1]-@estatus[143])*i[3],0].max,@mmaxhp*0.5].min
        end
        if @ebkb[q]==0 #未魔免
          @ehp[q]-=[[(@alldamage-i[2][0])*i[3],0].max,@ehp[q]*0.5].min
        end
        i[2][1]=@ehp[q]
        i[2][0]=@alldamage
      when 145 #强力击
        if @ecanspell[q]>=0
          i[0]=0 #蓄力中断
          eskill_break(q)
        else
          if i[0]==0
            self.edamage+=magicdam(q,i[3][1]/100*i[3][0])
            @ecanspell[q]=0
            @ecanattack[q]=0
          end
        end
      when 146 #风行
        if i[0]==0
          @emisszero[q]+=1
          @oldecombo[q]-=i[3]
          @ecombo[q]=Math.sqrt([@oldecombo[q],0].max)/10.0
        end
      when 148 #活体护甲
        @ehp[q]+=erecover(q,i[3][2]*@emaxhp[q])
        if i[0]==0
          @oldeshield[q]-=i[3][0]
          @eshield[q]=@actor.rshield(@oldeshield[q])
          @ed[q]-=i[3][1]
        end
      when 151
        if @ebkb[q]==0 && @ehp[q]>0 && @ehp[q]/@emaxhp[q]<i[2] #冰晶爆轰
          @ehp[q]=0 #即死
        end
        if i[0]==0
          @estatus[151][q]=0 #取消无法回复生命的状态
        end
      when 164 #虚灵
        if i[0]==0
          @enomagic[q]/=1.4 #魔抗恢复
        else
          @ecanattack[q]=1 if @ecanattack[q]<1 #虚无无法普攻
        end
      when 171 #自杀攻击
        if i[0]==0
          self.edamage+=ephysicaldam(q,i[3][0])
          self.edamage+=magicdam(q,i[3][1])
          @ehp[q]=0
        end
      when 172 #战场轰炸
        val=0
        for ck in @mdebuff
          if ck[1]==4 || ck[1]==6
            val=1;break
          end
        end
        if val==0
          self.edamage+=ephysicaldam(q,i[3][1].to_f)
          @oldmshield-=i[3][2].to_i
          self.mshield=@actor.rshield(@oldmshield)
        end
        if i[0]==0
          if @ehp[q]<@emaxhp[q]*(i[3][3].to_f/100)
            @eskill[q][83]=i[3][4]+"-"+i[3][5]
          end
        end
      when 183 #活血术
        @ehp[q]+=(@emaxhp[q]-@ehp[q])*i[3]
      when 199 #剑刃风暴
        if @ecanspell[q]>0
          i[0]=0
          @ebkb[q]=0
          eskill_break(q)
        else
          if i[0]==0
            @ebkb[q]=0
          else
            arr=[13,31,72]
            b=1
            for val in arr
              if have_skill(q,val)
                b=@eskill[q][val].split("-")[1].to_f
                break
              end
            end
            self.edamage+=ephysicaldam(q,i[3]*b)
          end
        end
      when 206 #恩赐解脱
        if check_player_ghost? && @ecanattack[q]==0
          self.edamage+=magicdam(q,groupDeGrace(q)/@emakedamage[q]/@mphysicaldef)
        end
        if i[0]==0
          @evampire[q]-=i[3]
        end
      when 209 #群星风暴
        if @ecanspell[q]>=0
          i[0]=0 #蓄力中断
          eskill_break(q)
        else
          if i[0]==0
            self.edamage+=magicdam(q,i[3])
            @ecanspell[q]=0
            @ecanattack[q]=0 if @ecanattack[q]==-1
          end
        end
      when 216 #暮色凋零
        a=i[3].split("-")
        if @ecanspell[q]>=0
          i[0]=0 #蓄力中断
          self.edamage+=magicdam(q,a[2].to_f)
          @ehp[q]-=emagicdam(q,a[2].to_f)
          eskill_break(q)
        else
          self.edamage+=magicdam(q,@mmaxhp*(a[1].to_f/100))
          if i[0]==0
            @ecanspell[q]=0
            @ecanattack[q]=0
          end
        end
      when 218 #超强力量
        if i[0]==0
          @oldecombo[q]-=i[3][0]
          @ecombo[q]=Math.sqrt([@oldecombo[q],0].max)/10.0
          @ea[q]-=i[3][1]
        end
      when 225 #神之力量
        if i[0]==0
          @ea[q]-=i[3][0]
          @emaxhp[q]-=i[3][1]
          if @ehp[q]>@emaxhp[q]
            @ehp[q]=@emaxhp[q]
          end
        end
      end
      if i[0]==0
        enemy_end_debuff(q,i)
      end
    end
    i=@edebuff[q].size-1
    while i>=0
      if @edebuff[q][i][0]==0
        @edebuff[q].delete_at(i)
      end
      i-=1
    end
  end
  def enemy_end_debuff(q,i) #敌人debuff结束效果（用于自我驱散）
    case i[1]
    when 1 #跳刀突袭
      @enodamage[q]/=2
    when 2 #回音战刃
      @oldecombo[q]+=100
      @ecombo[q]=Math.sqrt([@oldecombo[q],0].max)/10.0
      @emisszero[q]-=1
    when 3 #飓风长戟
      @oldecombo[q]+=160
      @ecombo[q]=Math.sqrt([@oldecombo[q],0].max)/10.0
      @emisszero[q]-=1
    when 4 #魂之挽歌减速
      @oldecombo[q]+=i[2][0]
      @ecombo[q]=Math.sqrt([@oldecombo[q],0].max)/10.0
      @ea[q]+=i[2][1]
    when 6 #天堂伤害加深
      @enodamage[q]/=1.5
    when 7 #血棘主动
      @enodamage[q]/=3/1.6
    when 8 #折跃匕首突袭
      @enodamage[q]/=2
      @enomagic[q]/=1.2
    end
  end
  def enemy_selfdamage(i) #敌人自我伤害
    d=0
    if have_skill(i,21) #过载
      d+=@eskill[i][21].split("-")[0].to_f #纯粹伤害
    end
    return d
  end
  def enemy_dead(q) #敌人死亡处理
    @edead[q]=true
    if have_skill(q,65) && @emirror[q]==nil#超新星，幻象不触发
      i=@elist.size
      @rtarget=@elist.size
      @target=@elist[@rtarget]
      a=@eskill[q][65].split("-")
      @elist.push(185)
      @eskill[i]=[]
      @eskill[i][17]=a[0].to_i
      @eskill[i][66]=1
      @ehp[i]=a[1].to_i
      @elevel[i]=1
      @ea[i]=0
      @ed[i]=0
      @emaxhp[i]=@ehp[i]#怪生命
      @firstmiss[i]=0
      @emakedamage[i]=1 
      @eskilldamage[i]=1
      @enodamage[i]=1  
      @edecdamage[i]=0 
      @enomagic[i]=1  
      @edecmagic[i]=0 
      @evampire[i]=0 
      @ecrit[i]=1
      @ecritvalue[i]=1
      @ehitrate[i]=1
      @emiss[i]=1
      @emisszero[i]=0
      @ecombo[i]=0
      @oldecombo[i]=0
      @oldeshield[i]=0
      @eshield[i]=1
      @ebkb[i]=1
      @edead[i]=false
      @eturn[i]=0
      @eturnr[i]=0
      @efight[i]=[]
      @efightvalue[i]=[] 
      @ecanattack[i]=0 
      @ecanspell[i]=0 
      @epassbreak[i]=0
      @edebuff[i]=[]
      if @eatimes !=nil
        @etd[i]=eturn_damage(i)
        @etdc[i]=counterskill(i)
        @esd[i]=enemy_selfdamage(i) #怪物每回合自损生命
        @pcs[i]=player_counter_skill(i) #玩家每回合群体伤害（辉耀等）
        @getd[i]=after_battle(i)
        @mtd[i]=mturn_damage(i)+@esd[i]+@getd[i]+@pcs[i]
        @eatimes[i]=(@ehp[i].to_f/@mtd[i]).to_i#怪物的攻击次数
        @eatimes[i]-=1 if @eatimes[i]*@mtd[i]>=@ehp[i] #整数的情况下怪物的攻击次数要-1
        @eatimes[i]=0 if @eatimes[i]<0#不能攻击的怪物攻击次数=0
        if @pcs[i]+@esd[i]>0
          @eatimes2[i]=(@ehp[i]/(@pcs[i]+@esd[i])).to_i
          @eatimes2[i]-=1 if @eatimes2[i]*(@pcs[i]+@esd[i])>=@ehp[i]
          @eatimes2[i]=0 if @eatimes2[i]<0
        else
          @eatimes2[i]=-1
        end
      end
      if @mcombo*[@mhitrate,0].max*enemy_miss(i)*a[2].to_i<@ehp[i]
        @emirror[q]="000"
        if self.edamage<0
          self.edamage=0
          @mhpre=0
        end
        @afterevent.push([1]) if @enemyid==@elist[q]#重生预定
      end
      return
    end
    #回溯共鸣
    if @estatus[210]!=nil
      if !@estatus[210][q+1]
        @estatus[210][q+1]=true
        @edead[q]=false
        @edebuff[q]=[]
        @eturn[q]-=1 
        @ehp[q]=@emaxhp[q]*@estatus[210][0]
        if @eatimes !=nil
          @etd[q]=eturn_damage(q)
          @etdc[q]=counterskill(q)
          @esd[q]=enemy_selfdamage(q) #怪物每回合自损生命
          @pcs[q]=player_counter_skill(q) #玩家每回合群体伤害（辉耀等）
          @getd[q]=after_battle(q)
          @mtd[q]=mturn_damage(q)+@esd[q]+@getd[q]+@pcs[q]
          @eatimes[q]=(@ehp[q].to_f/@mtd[q]).to_i#怪物的攻击次数
          @eatimes[q]-=1 if @eatimes[q]*@mtd[q]>=@ehp[q] #整数的情况下怪物的攻击次数要-1
          @eatimes[q]=0 if @eatimes[q]<0#不能攻击的怪物攻击次数=0
          if @pcs[q]+@esd[q]>0
            @eatimes2[q]=(@ehp[q]/(@pcs[q]+@esd[q])).to_i
            @eatimes2[q]-=1 if @eatimes2[q]*(@pcs[q]+@esd[q])>=@ehp[q]
            @eatimes2[q]=0 if @eatimes2[q]<0
          else
            @eatimes2[q]=-1
          end
        end
      end
    end
  end
  def eskill_break(q)#敌人技能被打断
    @ecanspell[q]=0 if @ecanspell[q]==-1
    @ecanattack[q]=0 if @ecanattack[q]==-1
  end
end