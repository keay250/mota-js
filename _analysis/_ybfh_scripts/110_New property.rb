#==============================================================================
# ■ Enemy_property
#------------------------------------------------------------------------------
# 　确定怪物的属性及伤害等。
#==============================================================================
class Enemy_property
  #--------------------------------------------------------------------------
  # ● 初始化状态
  #--------------------------------------------------------------------------
  def initialize(enemyid,event_id=0,area=[])
    #area为范围光环等效果
    @enemyid=enemyid
    @area=area
    @eid=event_id
    cal_enemy#计算怪物各种能力
  end
  def edamage=(edamage)
    if edamage>@edamage
      dam=edamage-@edamage
      if @mofang>0
        if dam<@mofang
          @mofang-=dam
          edamage-=dam
        else
          edamage-=@mofang
          @mofang=0
        end
      end
      if edamage>@edamage
        @alldamage+=dam
        @havedamage=true 
      end
    end
    @edamage=edamage
  end
  def mshield=(a)
    if $game_variables[279]!=0
      a*=$game_variables[279]
    end
    if $game_variables[232]!=0
      a*=1+@actor.get_buff_time(8)*0.1
    end
    @mshield=a
  end
  def mshield
    return @mshield
  end
  def edamage
    return @edamage
  end
  #--------------------------------------------------------------------------
  # ● 计算怪物的各种能力等
  #--------------------------------------------------------------------------
  def cal_enemy
    #初始化预处理
    battle_init
    while ((@mturn<@mfight.size || !eall_fin? || @mdebuff.size+ealldebuff>0) \
      || (@mcanattack+@mcanspell+eallcan>0)) && ealive?
      if myactive? #判断玩家是否可以行动
        @edamage-=mrecover(@mhpre)#固定回血
        player_first_active if @mturn==0 && @first_sign
        #若玩家行动列表里有主动技能则开始逐项处理
          if @mcanspell==0 #判断玩家是否被沉默
            result=my_skill if @mturn<@mfight.size
            if !result
              @mturn-=1 #全体魔免会推迟技能使用
            end
          else
            @mcanspell-=1 if @mcanspell>0
            if @mcanspell==-1 #如果是蓄力状态
              if @mdebuff.size+ealldebuff==0 && eall_fin? #不存在打断可能，无限蓄力
                @mturn=@mfight.size #取消之后所有技能
              end
            end
            @mturn-=1 #沉默则推迟技能的使用
          end
          
        checktarget
        
        if @mcanattack==0 && @ehp[@rtarget]>0
          if @mturnr==0 #玩家的第一回合
            if !(@firstmiss[@rtarget]>=2 || @emisszero[@rtarget]<0)  #拥有高级闪避属性的怪物第一回合无法被命中
              attackcount=1
              attackcount+=2 if @mequip.include?(69) && @emiss[@rtarget]>0 #魔龙枪
              attackcount+=2 if @mequip.include?(79) && @emiss[@rtarget]>0 #飓风长戟
              while attackcount>0
                attackcount-=1
                self.edamage+=counterskill(@rtarget) #用于处理反击类技能
                @ehp[@rtarget]+=@lsvar[@rtarget]
                dam=[mturn_damage(@rtarget),@ehp[@rtarget]].min
                @ehp[@rtarget]-=dam
                @edamage-=mrecover2(@mvampire*(dam-mtd_extra(@rtarget))) if @mvampire>0
              end
              if @mequip.include?(72) && @emiss[@rtarget]>0 #回音战刃
                if @ebkb[@rtarget]==0 #对魔免无效
                  @edebuff[@rtarget].push([2+1,2,0,@rtarget])
                  @oldecombo[@rtarget]-=100
                  @ecombo[@rtarget]=Math.sqrt([@oldecombo[@rtarget],0].max)/10.0
                  @emisszero[@rtarget]+=1
                  @ehp[@rtarget]-=emagicdam(@rtarget,@ma*0.2+@actor.magicpower*2)
                end
              end
              if @mequip.include?(79) && @emiss[@rtarget]>0 #飓风长戟
                if @ebkb[@rtarget]==0 #对魔免无效
                  @edebuff[@rtarget].push([3+1,3,0,@rtarget])
                  @oldecombo[@rtarget]-=160
                  @ecombo[@rtarget]=Math.sqrt([@oldecombo[@rtarget],0].max)/10.0
                  @emisszero[@rtarget]+=1
                  @ehp[@rtarget]-=emagicdam(@rtarget,@ma*0.4+@actor.magicpower*2.5)
                end
              end
            end
          else
            self.edamage+=counterskill(@rtarget)
            @ehp[@rtarget]+=@lsvar[@rtarget]
            dam=[mturn_damage(@rtarget),@ehp[@rtarget]].min
            @ehp[@rtarget]-=dam
            @edamage-=mrecover2(@mvampire*(dam-mtd_extra(@rtarget))) if @mvampire>0
          end
          if @mequip.include?(85) #漩涡闪电链
            count=4
            i=@rtarget-1
            i=@elist.size-1 if i<0
            while count>0
              if @ehp[i]>0 && @ebkb[i]==0
                @ehp[i]-=emagicdam(i,1200*(0.8**(5-count))*[@mhitrate,0].max*enemy_miss(i)*@mcombo)
                count-=1
                i+=1 if have_skill(i,157) #军团作战
              end
              i-=1
              i=@elist.size-1 if i<0
              break if i==@rtarget
            end
          end
          
        else
          @mcanattack-=1 if @mcanattack>0
        end
        mcleardebuff if @mdebuff.size>0
      end
      checktarget
#for q in 0...@elist.size 
q=@elist.size-1
while q>=0
  @eatked=false
      if @ehp[q]>0
        #抗性皮肤清除负面效果
        if @eskill[q][221]!=nil
          @ecanspell[q]=0 if @ecanspell[q]>0
          @ecanattack[q]=0 if @ecanattack[q]>0
          if @epassbreak[q]>0 #被破坏
            @epassbreak[q]=0
            for j in @epassskill[q]
              enemy_gain_pass(q,j)
            end
          end
        end
        #若怪物行动列表里有主动技能则开始逐项处理
        @ehp[q]-=enemy_selfdamage(q)
        if @ehp[q]>0
          if @ecanspell[q]==0 || eskill_cant_stop?(q)#判断怪物是否被沉默
            enemy_skill(q) if @eturn[q]<@efight[q].size
          else
            @ecanspell[q]-=1 if @ecanspell[q]>0
            if @ecanspell[q]==-1 #如果是蓄力状态
              if @mdebuff.size+ealldebuff==0 && @mturn>=@mfight.size #不存在打断可能，无限蓄力
                @eturn[q]=@efight[q].size #取消之后所有技能
              end
            end
            @eturn[q]-=1 #沉默则推迟技能的使用
          end
          if @ehp[q]>0  
            if @ecanattack[q]==0 #判断怪物是否被缴械或处于吟唱状态
              #玩家反击技能
              first_attack_debuff(q)
              a=player_counter_skill(q)
              @ehp[q]-=a
              if @mequip.include?(50) #先锋盾二阶的骨火
                self.edamage-=mrecover2(40*@ecombo[q])
                next if @ehp[q]<=0
              end
              #狂战士之血
              if have_skill(q,104) #狂战士之血
                value=@eskill[q][104].split("-")
                #@oldecombo[q]+=((@estatus[104][q]-@ehp[q])/@emaxhp[q])*100*value[0].to_f
                @ecombo[q]=Math.sqrt([@oldecombo[q]+(1-@ehp[q]/@emaxhp[q])*100*value[0].to_f,0].max)/10.0
                @ea[q]=$data_enemies[@elist[q]].atk*(1+(1-@ehp[q]/@emaxhp[q])*value[1].to_f)
              #  @ea[q]+=$data_enemies[@elist[q]].atk*((@estatus[104][q]-@ehp[q])/@emaxhp[q])*value[1].to_f
                @estatus[104][q]=@ehp[q]
              end
              #处理第一次命中后开始生效的法球
              if @eturnr[q]==0
                a=eturn_damage(q,true) #第一下必定暴击
              else
                #怪物攻击生效
                a=eturn_damage(q)
              end
            end
            if have_skill(q,143) #致命连接
              @estatus[143]=@ehp[q]
            end
            if @ecanattack[q]==0
              @eatked=true
              @ehp[q]+=erecover(q,(a-enormal_attack(q))*@evampire[q]) #敌人吸血
              if have_skill(q,37) #盛宴 \v      
                @ehp[q]+=erecover(q,ephysicaldam(q,@mmaxhp*@eskill[q][37].to_f/100.0*@ecombo[q]))
              end
              self.edamage+=a
              #法力损毁
              
              if have_skill(q,78) #法力损毁 \v
                value=@eskill[q][78].split("-")
                val2=value[0].to_f*@ecombo[q]*player_miss(q)
                val2=[@actor.sp-@spcost,val2].min
                @spcost+=val2
                self.edamage+=ephysicaldam(q,val2*value[1].to_f)
              end
              if have_skill(q,154) #幽冥之触 \v
                value=@eskill[q][154].split("-")
                d=value[1].to_i*@ecombo[q]*player_miss(q)
                if $game_variables[226]!=0 && $game_variables[226][4]>3
                  d*=1-($game_variables[226][4]-3)*0.25
                end
                if d>0
                  check=false
                  for i in @afterevent
                    if i[0]==0
                      i[1]+=d
                      check=true;break
                    end
                  end
                  if !check
                    @afterevent.push([0,d]) #战后处理
                  end
                end
              end
              if have_skill(q,141) #灵魂猎手 \v\v
                a=@eskill[q][141].split("-")
                value=a[0].to_f
                @soulcost+=value
                @ehp[q]+=erecover(q,@emaxhp[q]*value*a[1].to_f/100.0)
              end
              if have_skill(q,217) #怒意狂击
                value=@estatus[217][q]
                @estatus[217][q]+=@ecombo[q]
                value=(value+@estatus[217][q])/2*@ecombo[q]*@eskill[q][217]
                self.edamage+=ephysicaldam(q,value)
              end
            
            else
              self.edamage+=eturn_damage2(q) #不能攻击时记得加上每回合固定被动技能
              @ecanattack[q]-=1 if @ecanattack[q]>0
            end
            if have_skill(q,46) #龙裔血脉 \v\v
              a=@eskill[q][46].split("-")
              @ehp[q]+=erecover(q,@emaxhp[q]*a[1].to_f/100.0)
            end
            if @estatus[102]!=nil #治愈图腾
              @ehp[q]+=erecover(q,@emaxhp[q]*@estatus[102]/100.0)
            end
            if have_skill(q,149) #固定回血
              a=@eskill[q][149]
              @ehp[q]+=erecover(q,a)
            end
            #取消破坏
            if @epassbreak[q]>0 #未被破坏
              @epassbreak[q]-=1
              if @epassbreak[q]==0
                for j in @epassskill[q]
                  enemy_gain_pass(q,j)
                end
              end
            end
            
          end
        end
      end
      
      if self.edamage>=@mhp
        check=@actor.skills.index(20)
        if check && @mskill[check]==0 && @mcanattack==0 #玩家绝境反击
          @mskill[check]=1 #禁用
          @lsvar[q]=0
          a=[(@ma-@ed[q])*@enodamage[q]-@edecdamage[q],0].max*@eshield[q]
          @ehp[q]-=a
          self.edamage+=counterskill(q)
          @ehp[q]+=@lsvar[q]
          self.edamage-=mrecover2(a)*$game_variables[180][check].to_f/100
        end
      end
      #如果怪物死亡的处理
      if @ehp[q]<=0 && !@edead[q]
        enemy_dead(q)
      end
      ecleardebuff(q) if @edebuff[q].size>0
      if @ehp[q]<=0 && !@edead[q]
        enemy_dead(q)
      end
      @eturn[q]+=1;@eturnr[q]+=1 
      q-=1
    end
      checktarget
      @mturn+=1 #进程处理位置
      @mturnr+=1 #实际回合数
      @turncount+=1
    end
    @animation=@animation.uniq
    if !ealive? #若预处理后怪物已经被击败
      @nowin=0
      @edamage=self.edamage.to_i
      battle_end
      return
    end
    #防止法球没有添加的情况出现
    for q in 0...@elist.size 
      first_attack_debuff(q) if @ehp[q]>0
      if have_skill(q,104) #狂战士之血
        @evampire[q]-=@eskill[q][104].split("-")[2].to_f/100.0
      end
    end
    #吸血等效果处理
    @etd=[]
    @etdc=[]
    for q in 0...@elist.size
      if @ehp[q]>0
        if @ecanattack[q]!=0
          @etd[q]=eturn_damage2(q)
        else
          @etd[q]=eturn_damage(q)
        end
        @etdc[q]=counterskill(q)
      end
    end
    @eatimes=[]
    @eatimes2=[]
    @getd=[]
    @esd=[]
    @pcs=[]
    @mtd=[]
      sa=[]
    speical_init
    for q in 0...@elist.size
      if @ehp[q]>0
        #双方技能释放完毕，进入互相对A环节
        @esd[q]=enemy_selfdamage(q) #怪物每回合自损生命
        @pcs[q]=player_counter_skill(q) #玩家每回合群体伤害（辉耀等）
        @getd[q]=after_battle(q)
        ftd=mturn_damage(q)+@esd[q]+@pcs[q]
        @mtd[q]=ftd+@getd[q]
        if have_skill(q,104) #狂战士之血
          if !hasika(q)
            self.edamage=9999999999999#伤害等于次大
            @nowin=1
            battle_end
            return
          end
        end
        if ftd>@ehp[q]
          @eatimes[q]=0
         elsif @mtd[q]>0 && mturn_combo_ok?(q)>0#能够破防       
          @eatimes[q]=((@ehp[q]-ftd).to_f/@mtd[q]).to_i+1#怪物的攻击次数
          @eatimes[q]-=1 if (@eatimes[q]-1)*@mtd[q]+ftd>=@ehp[q] #整数的情况下怪物的攻击次数要-1
          @eatimes[q]=0 if @eatimes[q]<0#不能攻击的怪物攻击次数=0
        else#勇士的攻击<怪物的防御
          self.edamage=9999999999999#伤害等于次大
          @nowin=1
          battle_end
          return
        end
        if @pcs[q]+@esd[q]>0
          @eatimes2[q]=(@ehp[q]/(@pcs[q]+@esd[q])).to_i
          @eatimes2[q]-=1 if @eatimes2[q]*(@pcs[q]+@esd[q])>=@ehp[q]
          @eatimes2[q]=0 if @eatimes2[q]<0
        else
          @eatimes2[q]=-1
        end
      end
    end
    while ealive?
      checktarget
      @edamage-=mrecover(@mhpre)
      val=@etdc[@rtarget]+(@etd[@rtarget]+@etdc[@rtarget])*@eatimes[@rtarget]
      self.edamage+=val
      @edamage-=mrecover(@mhpre)*@eatimes[@rtarget]
      @edamage-=mrecover2((@ehp[@rtarget]-(@getd[@rtarget]+mtd_extra(@rtarget))*@eatimes[@rtarget])*@mvampire)
      if @mequip.include?(50) && @ecanattack[@rtarget]==0 #先锋盾二阶的骨火
        c=@ehp[@rtarget]-(@eatimes[@rtarget])*@mtd[@rtarget]-mturn_damage(@rtarget)-@getd[@rtarget]-@esd[@rtarget]
        if c>0 && c<=@pcs[@rtarget] #检测是否是被骨火补刀
          c=1
        else
          c=0
        end
        self.edamage-=mrecover2([40*(@eatimes[@rtarget]+c)*@ecombo[@rtarget],@ehp[@rtarget]].min)
      end
      normal_battle_eattack(@rtarget,@eatimes[@rtarget])
      @turncount+=1+@eatimes[@rtarget]
      if self.edamage>=@mhp
        check=@actor.skills.index(20)
        if check && @mskill[check]==0 #玩家绝境反击
          @mskill[check]=1 #禁用
          a=[(@ma-@ed[@rtarget])*@enodamage[@rtarget]-@edecdamage[@rtarget],0].max*@eshield[@rtarget]
          if a>0
            b=(eturn_damage(@rtarget)-@mhpre+counterskill(@rtarget))
            if self.edamage-b>=@mhp
              self.edamage-=b
            end
          end
          self.edamage+=counterskill(@rtarget)
          self.edamage-=mrecover2(a)*$game_variables[180][check].to_f/100
        end
      end
      @ehp[@rtarget]=0
      saver=@rtarget
      speical_init
      for q in 0...@elist.size
        if @ehp[q]>0 && q!=@target
          if @eatimes2[q]==-1
            l=@eatimes[@rtarget]+1
          else
            l=[@eatimes[@rtarget],@eatimes2[q]].min+1
          end
          val=@etd[q]*l
          self.edamage+=val
          if @mequip.include?(50) && @ecanattack[q]==0 #先锋盾二阶的骨火
            self.edamage-=mrecover2([40*l*@ecombo[q],@ehp[q]].min)
          end
          normal_battle_eattack(q,l)
          sa[q]=@ehp[q]
          @ehp[q]-=(@pcs[q]+@getd[q]+@esd[q])*l
          if @ehp[q]<=0
            enemy_dead(q)
          elsif sa[q]>@ehp[q]
            ftd=@mtd[q]-@getd[q]
            if ftd>@ehp[q]
              @eatimes[q]=0
            else
              @eatimes[q]=((@ehp[q]-ftd).to_f/@mtd[q]).to_i+1#怪物的攻击次数
              @eatimes[q]-=1 if (@eatimes[q]-1)*@mtd[q]+ftd>=@ehp[q] #整数的情况下怪物的攻击次数要-1
              @eatimes[q]=0 if @eatimes[q]<0#不能攻击的怪物攻击次数=0
            end
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
      enemy_dead(saver)
    end
    @nowin=0
    if @soulcost>$game_variables[197]
      self.edamage+=@mmaxhp*3
    end
    @edamage=self.edamage.to_i
   # self.edamage=0
    battle_end
  end
  def battle_end
    @turncount=[1,@turncount].max
    if $game_variables[232]!=0
      $game_variables[232]=@mallbuffsave.clone
    end
    $nowbattle=false
  end
  #怪物回合伤害
  def eturn_damage(q,crit=false)
    table=[false,true,false,false,false,false,false]
    if !crit
      d=[ephysicaldam(q,[@ea[q]-@md,0].max*@ecrit[q])-@mdecdamage,0].max*@ecombo[q]*player_miss(q)*@emakedamage[q]
    else
      d=[@ea[q]-@md,0].max*@ecritvalue[q]
      d-=@md if have_skill(q,72) #剑舞 \v\v
      d=[ephysicaldam(q,d)-@mdecdamage,0].max*@ecombo[q]*player_miss(q)*@emakedamage[q]
    end
    
    #这部分效果无视破坏被动
    if @eskill[q][206]!=nil #恩赐解脱
      d+=groupDeGrace(q)
    end
    
    d+=enormal_attack(q)
    d+=eturn_damage2(q)
    return d
  end
  def enormal_attack(q,combo=@ecombo[q])
    d=0
    return d if @epassbreak[q]>0
    #敌人的普攻附带效果处理
    if have_skill(q,2) #腐蚀毒素 \v
      d+=poison_damage(q,@eskill[q][2].to_i*@emakedamage[q])
    end
    if have_skill(q,154) #幽冥之触 \v
      a=@eskill[q][154].split("-")
      d+=poison_damage(q,a[0].to_f*@emakedamage[q]*combo*player_miss(q))
    end
    if have_skill(q,26) #元素冲击 \v
      d+=magicdam(q,@eskill[q][26].to_i)*combo
    end
    if have_skill(q,29) #粹毒攻击 \v
      d+=poison_damage(q,@eskill[q][29].to_i*@emakedamage[q])
    end
    if have_skill(q,37) #盛宴 \v
      d+=ephysicaldam(q,@mmaxhp*@eskill[q][37].to_f/100.0*combo)
    end
    if have_skill(q,96) #阎刃 \v\v
      a=@eskill[q][96].split("-")
      d+=magicdam(q,@mmaxhp*a[1].to_f/100.0+a[0].to_f)*combo
    end
    if have_skill(q,119) #腐尸毒 \v
      a=@eskill[q][119].split("-")
      d+=poison_damage(q,a[0].to_i*@emakedamage[q])
    end
    if have_skill(q,175) #重型机炮 \v
      a=@eskill[q][175].split("-")
      val=magicdam(q,ephysicaldam(q,a[0].to_f*combo*player_miss(q)*@emakedamage[q]))
      if @mcanattack>0 && @mcanspell>0
        val*=a[1].to_f
      end
      d+=val
    end
    return d
  end
  def poison_damage(q,d) #毒素伤害
    d=ephysicaldam(q,d)
    if $game_variables[226]!=0
      d*=1-$game_variables[226][4]*0.1
    end
    if $game_variables[232]!=0
      for j in $game_variables[232]
        if j[0]==5
          d*=(1+0.1*j[2])
          break
        end
      end
    end
    return d
  end
  def eturn_damage2(i)
    d=0
    #敌人的回合效果处理（被动技能，如献祭等）
    if have_skill(i,17) #永恒献祭 \v
      d+=@eskill[i][17].to_i #纯粹伤害
    end
    if have_skill(i,108) #火焰壁垒
      if @estatus[108]!=nil && @estatus[108][i]!=nil
        if @estatus[108][i][0]<=0
          @estatus[108][i]=nil
        else
          d+=magicdam(i,@estatus[108][i][1])
        end
      end
    end
    if have_skill(i,118) #飓风
      if @estatus[118]!=nil && @estatus[118][i]!=nil
        if @ecanspell[i]>=0
          @mmisszero-=1
          @oldmcombo+=@estatus[118][i][1]
          @mcombo=Math.sqrt([@oldmcombo,0].max)/10.0
          @estatus[118][i]=nil
          @ecanattack[i]=0 if @ecanattack[i]<0 #如果只是单纯沉默，那么也解除自我缴械
        else
          d+=magicdam(i,@estatus[118][i][0])
        end
      end
    end
    return d
  end
  def after_battle(q)
    #这里处理吸血等带来的特殊计算
    d=0
    if @evampire[q]>0
      d-=erecover(q,(eturn_damage(q)-enormal_attack(q))*@evampire[q]) #敌人吸血处理
    end
    counterskill(q)
    d-=@lsvar[q]
    if have_skill(q,37) #盛宴 \v
      d-=erecover(q,ephysicaldam(q,@mmaxhp*@eskill[q][37].to_f/100.0*@ecombo[q]))
    end
    if have_skill(q,46) #龙裔血脉 \v\v
      a=@eskill[q][46].split("-")
      d-=erecover(q,@emaxhp[q]*a[1].to_f/100.0)
    end
    if have_skill(q,141) #灵魂猎手 \v\v
      a=@eskill[q][141].split("-")
      d-=erecover(q,@emaxhp[q]*a[0].to_f*a[1].to_f/100.0)
    end
    if @estatus[102]!=nil #治愈图腾
      d-=erecover(q,@emaxhp[q]*@estatus[102]/100.0)
    end
    if have_skill(q,149) #固定回血
      d-=erecover(q,@eskill[q][149])
    end
    return d
  end
  #互相平A阶段怪物攻击特殊处理
  def normal_battle_eattack(q,turns)
    if have_skill(q,78) #法力损毁 \v
      value=@eskill[q][78].split("-")
      val2=value[0].to_f*@ecombo[q]*player_miss(q)*turns
      val2=[@actor.sp-@spcost,val2].min
      @spcost+=val2
      self.edamage+=ephysicaldam(q,val2*value[1].to_f)
    end
    if have_skill(q,154) #幽冥之触 \v
      value=@eskill[q][154].split("-")
      d=value[1].to_i*@ecombo[q]*player_miss(q)*turns
      if $game_variables[226]!=0 && $game_variables[226][4]>3
        d*=1-($game_variables[226][4]-3)*0.25
      end
      if d>0
        check=false
        for i in @afterevent
          if i[0]==0
            i[1]+=d
            check=true;break
          end
        end
        if !check
          @afterevent.push([0,d]) #战后处理
        end
      end
    end
    if have_skill(q,141) #灵魂猎手 \v
      value=@eskill[q][141].split("-")
      val2=[$game_variables[197]-@soulcost,value[0].to_f*turns].min
      @soulcost+=val2
    end
    if have_skill(q,217) #怒意狂击
      value=@estatus[217][q]
      @estatus[217][q]+=@ecombo[q]*turns
      value=(value+@estatus[217][q])/2*@ecombo[q]*turns*@eskill[q][217]
      self.edamage+=ephysicaldam(q,value)
    end
  end
  #玩家回合伤害
  def mturn_damage(i)
    mcombo=mturn_combo_ok?(i)
    d=[(@ma-@ed[i])*@enodamage[i]-@edecdamage[i],0].max*mcombo*[@mhitrate,0].max*@mcrit*enemy_miss(i)*@eshield[i]
    d+=mtd_extra(i)
    if have_skill(i,66) #最低伤害
      return 0 if d<=0
      return [$game_variables[263],1].max*mcombo*[@mhitrate,0].max*enemy_miss(i)
    end
    return d
  end
  def mturn_combo_ok?(i)
    mcombo=@mcombo
    if @estatus[87]!=nil && @estatus[87][i]!=nil
      mcombo=Math.sqrt([@oldmcombo-@estatus[87][i],0].max)/10.0
    end
    return mcombo
  end
  def mtd_extra(i)
    d=0
    if @mequip.include?(43) && [@mhitrate,0].max*enemy_miss(i)>0 #淬毒之珠
      d+=@emaxhp[i].to_i*0.003*@enodamage[i]*@eshield[i]   
    end
    if @etd !=nil && @mequip.include?(85) #漩涡
      d+=emagicdam(i,1200*[@mhitrate,0].max*enemy_miss(i)*@mcombo) 
      if have_skill(i,157) #军团作战
        for j in 1...5
          d+=emagicdam(i,1200*(0.8**j)*[@mhitrate,0].max*enemy_miss(i)*@mcombo) 
        end
      end
    end
    if @mequip.include?($game_variables[231]) && $game_variables[231]>0 && @oldeshield[i]>0#夜魔祭品
      if $game_variables[237]!=0
        for j in $game_variables[237]
          case j[0]
          when 101
            d+=@oldeshield[i]*30*@eshield[i]*[@mhitrate,0].max*enemy_miss(i)*@mcombo
          end
        end
      end
    end
    return d
  end
  def ephysicaldam(q,dam) #计算怪物实际物理伤害
    dam*=@mshield*@mphysicaldef
    return dam
  end
  def magicdam(q,dam) #计算怪物实际魔法伤害
    if @estatus[92]!=nil #奥术光环
      dam*=(1+@estatus[92]/100.0)
    end
    dam=[dam*@eskilldamage[q]*@mmagicdef[1]-@mmagicdef[0],0].max*@mskilldef
    return dam
  end
  def emagicdam(q,dam) #计算玩家实际魔法伤害
    return 0 if @ebkb[q]>0 #魔免怪不计算魔法伤害
    if @mequip.include?(134) && $data_enemies[@elist[q]].dex>=998 #永恒之盘
      dam*=1.2
    end
    dam=[dam*@enomagic[q]*@mskilldam-@edecmagic[q],0].max
    for ccc in @actor.states
      dam *= $data_states[ccc].int_rate / 100.0
    end
    if @estatus[108]!=nil
      if @estatus[108][q]!=nil
        if @estatus[108][q][0]>=dam
          @estatus[108][q][0]-=dam
          dam=0
        else
          dam-=@estatus[108][q][0]
          @estatus[108][q][0]=0
        end
      end
    end
    return dam
  end
  def mrecover(value) #计算实际恢复量
    value+=$game_variables[192]
    if value>0 && @estatus[198]!=nil #壮烈成仁
      value=-value*@estatus[198]
    end
    if value>0 && @estatus[29] #淬毒攻击，生命回复变为相反数
      d=-1
      if $game_variables[226]!=0 && $game_variables[226][4]>3
        d*=1-($game_variables[226][4]-3)*0.25
      end
      value*=d
    end
    
    value-=$game_variables[192]
    value-=@poison
    if value<0 #变为生命流失
      if $game_variables[232]!=0
        for j in $game_variables[232]
          if j[0]==5
            value*=(1+0.1*j[2])
            break
          end
        end
      end
    else
      value*=@mhprerate
    end
    return value
  end
  def erecover(q,value) #计算敌人的恢复量
    if @estatus[151]!=nil && @estatus[151][q]==1
      value=[0,value].min
    end
    return value
  end
  def player_miss(q)
    if have_skill(q,107) #无影拳无视闪避
      return 1
    end
    if @mmisszero>0
      return 1
    elsif @mmisszero<0
      return 0
    else
      return @mmiss
    end
  end
  def enemy_miss(q)
    if @emisszero[q]>0
      return 1
    elsif @emisszero[q]<0
      return 0
    else
      return [@emiss[q],1].min
    end
  end
  def mrecover2(value) #计算恢复量（不考虑中毒等）
   # value+=$game_variables[192]
    if value>0 && @estatus[198]!=nil #壮烈成仁
      value=-value*@estatus[198]
    end
    if value>0 && @estatus[29] #淬毒攻击，生命回复变为相反数
      d=-1
      if $game_variables[226]!=0 && $game_variables[226][4]>3
        d*=1-($game_variables[226][4]-3)*0.25
      end
      value*=d
    end
    return value
  end
  #判断玩家是否可以行动
  def myactive?
    return (@mturn>=0) #0表示玩家获得先手，需要单独处理
  end
  def mxuanyun(i)
    if @mequip.include?(134) && @estatus[134]==nil #永恒之盘
      @estatus[134]=1
      return
    end
    @mcanattack=i if @mcanattack<i
    @mcanspell=i if @mcanspell<i
  end
  def mjiaoxie(i)
    if @mequip.include?(134) && @estatus[134]==nil #永恒之盘
      @estatus[134]=1
      return
    end
    @mcanattack=i if @mcanattack<i
  end
  def mchenmo(i)
    if @mequip.include?(134) && @estatus[134]==nil #永恒之盘
      @estatus[134]=1
      return
    end
    @mcanspell=i if @mcanspell<i
  end
  def exuanyun(q,i)
    if have_skill(q,203) #海妖外壳免疫
      return
    end
    @ecanattack[q]=i if @ecanattack[q]<i
    @ecanspell[q]=i if @ecanspell[q]<i
  end
  def epassbreak(q,i) 
    return if have_skill(q,66)
    if @epassbreak[q]==0 #未被破坏
      for j in @epassskill[q]
        enemy_lose_pass(q,j)
      end
    end
    @epassbreak[q]=i if @epassbreak[q]<i
  end
  #--------------------------------------------------------------------------
  # ● 返回怪物的伤害类型
  #--------------------------------------------------------------------------
  def eall_fin?
    for i in 0...@elist.size
      return false if @eturn[i]<@efight[i].size && @ehp[i]>0
    end
    return true
  end
  def ealldebuff
    d=0
    for i in 0...@elist.size
      d+=@edebuff[i].size if @ehp[i]>0
    end
    return d
  end
  def eallcan
    d=0
    for i in 0...@elist.size
      d+=[@ecanattack[i],0].max+[@ecanspell[i],0].max+[@epassbreak[i],0].max if @ehp[i]>0
    end
    return d
  end
  def ealive?
    for i in 0...@elist.size
      return true if @ehp[i]>0
    end
    return false
  end
  def mhavebuff?(i)
    for j in 0...@mdebuff.size
      if @mdebuff[j][1]==i
        return j
      end
    end
    return -1
  end
  def ehavebuff?(q,i)
    for j in 0...@edebuff[q].size
      if @edebuff[q][j][1]==i
        return j
      end
    end
    return -1
  end
  def checktarget
    while @ehp[@rtarget]<=0
      if @rtarget>0
        @rtarget-=1 
      else
        if ealive?
          @rtarget=@elist.size-1
        else
          break
        end
      end
      @target=@elist[@rtarget]
    end
  end
  def is_bkb?(target,lk=false) #选出一个非魔免单位
    if @ehp[target]>0 && @ebkb[target]>0 #魔免不受影响
      i=@elist.size-1
      k=-1
      while i>=0     
        if @ehp[i]>0 && (!lk || !have_skill(i,54))
          if @ebkb[i]==0
            target=i
            break
          elsif @ebkb[i]!=1 && k==-1
            k=i
          end
        end
        i-=1
      end
    end
    if (lk && have_skill(target,54))
      @ebkb[@elist.size+10]=1
      return @elist.size+10
    end
    if @ebkb[target]==1 && k!=-1
      return k
    end
    return target
  end
  def is_sheep?(target,lk=false) #选出一个非变羊单位
     i=@elist.size-1
      while i>=0     
        if @ehp[i]>0 && (!lk || !have_skill(i,54))
          if !(@epassbreak[target]>0 && @epassbreak[target]==@ecanattack[target] && @epassbreak[target]==@ecanspell[target])
            target=i
            break
          end
        end
        i-=1
      end

    if (lk && have_skill(target,54))
      i=-1
    end
    if i==-1
      return i
    end
    return target
  end
  def have_skill(q,i)
    return false if @epassbreak[q]>0 #被破坏时被动无效
    return !(@eskill[q][i]==nil)
  end
  def eskill_cant_stop?(q)
    return false if @ecanattack[q]!=0 || @eturn[q]>=@efight[q].size
    #技能条件设置为[平时]时无视沉默效果
    return true if @efight[q][@eturn[q]]>0 && $data_skills[@efight[q][@eturn[q]]].occasion==0
  end
  def speical_init #特殊处理
    @lighthammer=0 #雷锤弹跳计数
  end
  def got_nowin
    return @nowin
    #0代表可以对怪物造成伤害,1代表无法伤害,2代表怪物无敌
  end
  #--------------------------------------------------------------------------
  # ● 返回怪物的伤害
  #--------------------------------------------------------------------------
  def got_damage
    if @mlevel>=16
      return [self.edamage,-@actor.maxhp/10].max
    else
      return self.edamage
    end
  end
  #--------------------------------------------------------------------------
  # ● 返回怪物的伤害
  #--------------------------------------------------------------------------
  def got_spcost
    return 0 if @nowin==1
    #女主效果
    @spcost=[@spcost,100].max if $game_switches[142]
    if $game_party.actors.include?($game_actors[3])
      case $game_actors[3].level
      when 1
        @spcost-=1
      when 2
        @spcost-=2
      end
    end
    val=(@actor.sprecover*@turncount).to_i
    if $game_variables[226]!=0 #回魔天赋
      if $game_variables[226][7]>=6
        val2=$game_variables[226][7]*3-5
      else
        val2=$game_variables[226][7]*2
      end
      if val2>0 #存在回魔天赋
        val3=(@actor.sprecover*@turncount*$game_variables[226][7]*0.03).to_i
        if val3>val2
          val+=val3
        else
          val+=val2
        end
      end
    end
    if @estatus[156]!=nil
      val=-[val*@estatus[156],@actor.sp].min if val>0
    end
    if $game_switches[183] #星界BUFF
      if @nowin==0
        val+=[90-@turncount*10,0].max
      end
    end
    if @mequip.include?(122) || $game_party.weapon_number(122)>0 #血精石
      val+=[@actor.soul_max-($game_variables[197]-@soulcost),@actor.soul_max/100+1].min*5
    end
    if val>0
      val*=@msprerate
    end
    @spcost-=val
    if @afterevent.include?([1]) || @afterevent.include?([2])
      @spcost=[0,@spcost].max
    end
    @spcost=[@actor.sp,@spcost].min
    if @mlevel>=16
      return [@spcost.to_i,-@actor.maxsp/10].max
    else
      return @spcost.to_i
    end
  end
  def got_soulcost
    return @soulcost.to_i
  end
  def got_mirror
    return @emirror
  end
  def got_event
    return @afterevent
  end
  def got_dex
    return @edex[0]
  end
  #--------------------------------------------------------------------------
  # ● 返回怪物的攻击
  #--------------------------------------------------------------------------
  def got_ea
    if @elist.include?(@enemyid)
      return @ea[0].to_i
    else
      return 0
    end
  end
  def got_ecombo
    if @elist.include?(@enemyid)
      return @oldecombo[0].to_i
    else
      return 0
    end
  end
  def got_emaxhp
    if @elist.include?(@enemyid)
      return @emaxhp[0].to_i
    else
      return 0
    end
  end
  def have_damage
    return @havedamage
  end
  #--------------------------------------------------------------------------
  # ● 返回怪物的防御
  #--------------------------------------------------------------------------
  def got_ed
    if @elist.include?(@enemyid)
      return @ed[0].to_i
    else
      return 0
    end
  end
  def got_eshield
    if @elist.include?(@enemyid)
      return [@oldeshield[0],@eshield[0]]
    else
      return [0,0]
    end
  end
  def got_enomagic
    if @ebkb[0]==1
      return 0
    end
    if @elist.include?(@enemyid)
      return @enomagic[0]
    else
      return 1
    end
  end
  def got_ehp
    return @ehp[0]
  end
  #--------------------------------------------------------------------------
  # ● 返回怪物的属性
  #--------------------------------------------------------------------------
  def got_p(val)
    return $data_enemies[@enemyid].element_ranks[val]==1
  end
  def got_p_val(id,val)
    return $enemies_skills[id].include?(val)
  end
  #--------------------------------------------------------------------------
  # ● 返回怪物的属性种数
  #--------------------------------------------------------------------------
  def got_kind
    if @elist.include?(@enemyid)
      return @kind[0]
    else
      return 1
    end
  end
  def got_turncount
    return @turncount
  end
  def got_list
    return @elist
  end
  def got_animation
    return @animation
  end
  def merit109_check
    return @estatus[80]
  end
  def merit222_check
    return @estatus[177]
  end
  def merit118_check
    return !@havedamage
  end
end
  #--------------------------------------------------------------------------
  # ● 返回怪物的属性
  #--------------------------------------------------------------------------
  def got_p(id,val)
    return $enemies_skills[id].include?(val)
  end
  def got_magicdam(dam) #计算怪物实际魔法伤害
    for i in $supskill
      if i[0]==92
        dam*=(1+i[1].to_i/100.0)
      end
    end
    a=$game_actors[$game_variables[1]+1].magicdef
    dam=[dam*a[1]-a[0],0].max
    return dam
  end
  def got_p_value(id,val)
    kk=0
    value=nil
    for i in $enemies_skills[id]
        if $data_skills[i].description.split("\\v").size>1
          kk+=1
          if val==i
            value=$data_enemies[id].name.split(":")[kk]
            break
          end
        end
    end
    return value
  end