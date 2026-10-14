=begin
#==============================================================================
# ■ Enemy_property
#------------------------------------------------------------------------------
# 　确定怪物的属性及伤害等。
#==============================================================================
class Enemy_property
  #--------------------------------------------------------------------------
  # ● 初始化状态
  #--------------------------------------------------------------------------
  def initialize(enemyid)
    @enemyid=enemyid
    cal_enemy#计算怪物各种能力
  end
  
  #--------------------------------------------------------------------------
  # ● 计算怪物的各种能力等
  #--------------------------------------------------------------------------
  def cal_enemy
    #属性表
    @table=[false,true,false,false,false,false,false]
    @eskill=[]
    @mskill=[]
    @actor=$game_actors[$game_variables[1]+1]
    @mlevel=@actor.level
    @spcost=0 #魔法消耗
    @mhp=@actor.hp#基础勇生命
    @ma=@actor.str#基础勇攻
    @md=@actor.dex#基础勇防
    @mmd=@actor.int#基础勇魔防
    @elevel=$data_enemies[@enemyid].str#怪攻
    @ea=$data_enemies[@enemyid].atk#怪攻
    @ed=$data_enemies[@enemyid].pdef#怪防
    @ehp=$data_enemies[@enemyid].maxhp#怪生命
    @enodamage=1  #怪物百分比减伤
    @edecdamage=0 #怪物固定减伤
    @evampire=0 #敌人吸血百分比
    @mcombo=@actor.atkspeed
    @ecombo=$data_enemies[@enemyid].agi
    @mmiss=1-@actor.miss
    @mhpre=@actor.hprecover
    @mshield=@actor.rshield
    @mmagicdef=@actor.magicdef
    @mequip=@actor.equip_id
    @ecrit=1
    @ecritvalue=1
    @mcrit=1
    @mhitrate=1
    @ehitrate=1
  
    @kind=0#属性种数
    for i in 0...@actor.skills.size
      @mskill[i]=0
    end
    kk=0
    zdskill=[]
    zdvalue=[]
    zdnum=[]
    for i in 1...$data_enemies[@enemyid].element_ranks.xsize
      if @table[$data_enemies[@enemyid].element_ranks[i]]
        @kind+=1
        if $data_skills[i].scope==3
          if $data_skills[i].description.split("\\v").size>1
             kk+=1
            @eskill[i]=$data_enemies[@enemyid].name.split(":")[kk]
          end
        end
        if $data_skills[i].scope==1
          if $data_skills[i].description.split("\\v").size>1
            kk+=1
            s=$data_enemies[@enemyid].name.split(":")[kk]
            zdnum[zdskill.size]=s.split("&")[1]
            if zdnum[zdskill.size]==nil
              zdnum[zdskill.size]=999+zdskill.size
            else
              zdnum[zdskill.size]=zdnum[zdskill.size].to_i
            end
          else
            zdnum[zdskill.size]=999+zdskill.size
          end
          zdskill.push(i)
          if $data_skills[i].description.split("\\v").size>1
            zdvalue.push(s.split("&")[0]) 
          else
            zdvalue.push("")
          end
        end
      end
    end
    for i in 0...zdskill.size#怪物伤害排序
     for j in i...zdskill.size
      if zdnum[i]>zdnum[j]
       temp=zdnum[i]
       zdnum[i]=zdnum[j]
       zdnum[j]=temp
       temp=zdskill[i]
       zdskill[i]=zdskill[j]
       zdskill[j]=temp
       temp=zdvalue[i]
       zdvalue[i]=zdvalue[j]
       zdvalue[j]=temp
      end
     end
   end
   
    @oldmcombo=@mcombo #老攻速
    @oldecombo=@ecombo
    
    #以下是玩家被动
    if @mequip.include?(18) #寒铁钢爪
      if @mlevel>=@elevel
        @enodamage*=1.4
      end
    else
      if @mequip.include?(16) #压制之刃
        if @mlevel>=@elevel
          @enodamage*=1.32
        end
      end
    end
    
    
    #以下是怪物被动
    
    if @table[$data_enemies[@enemyid].element_ranks[3]] #亡灵协同 \v
      @ehp*=(1+@eskill[3].to_i*($game_variables[163]-1)/100.0)
      for i in @mequip
        case i
        when 6
          @md+=5
        when 15
          @md+=50
        end
      end
    end
    if @table[$data_enemies[@enemyid].element_ranks[4]] #嗜血本能 \v
      @oldecombo+=((1-@actor.hprate)*100*@eskill[4].to_f).to_i
    end
    if @table[$data_enemies[@enemyid].element_ranks[5]] #上位者威压 \v
      a=(1-@eskill[5].to_f/100.0)**([@elevel-@mlevel,0].max)
      @ma*=a;@md*=a
    end
    miss=0
    if @table[$data_enemies[@enemyid].element_ranks[6]] #闪避 \v
      @mhitrate*=(1-@eskill[6].to_f/100)
      miss=1
    end
    if @table[$data_enemies[@enemyid].element_ranks[14]] #皮肤硬化 \v
      a=@eskill[14].split("-")
      @enodamage*=(1-a[0].to_f/100.0)
      @edecdamage+=a[1].to_f
    end
    if @table[$data_enemies[@enemyid].element_ranks[9]] #领主光环 \v\v\v
      a=@eskill[9].split("-")
      b=(1-a[0].to_f/100.0)
      @ma*=b;@md*=b
      @oldmcombo-=a[1].to_f
      @enodamage*=(1-a[2].to_f/100.0)
    end
    if @table[$data_enemies[@enemyid].element_ranks[13]] #致命一击 \v\v
      a=@eskill[13].split("-")
      b=a[0].to_f/100
      a=a[1].to_f
      @ecrit*=1+b*(a-1)
      @ecritvalue*=a
    end
    if @table[$data_enemies[@enemyid].element_ranks[21]] #过载 \v\v\v
      a=@eskill[21].split("-")
      @oldecombo+=a[1].to_f
      @enodamage*=(1-a[2].to_f/100.0)
    end
    @mcombo=Math.sqrt([@oldmcombo,0].max)/10.0 #重定义攻速
    @ecombo=Math.sqrt([@oldecombo,0].max)/10.0 #重定义攻速
    @eatimes=0
    @edamage=0
    @mturn=0
    @eturn=0
    @mturnr=0
    @eturnr=0
    @efight=[] #怪物行动列表
    @efightvalue=[] #怪物行动数值
    @mfight=[] #玩家行动列表
    @mfightvalue=[] #玩家行动数值
    @estatus=[] #判断是否赋予debuff
    @mcanattack=0 #玩家是否被缴械标记（或者处于吟唱状态）
    @mcanspell=0 #玩家是否被沉默被标记
    @ecanattack=0 #怪物是否被缴械标记（或者处于吟唱状态）
    @ecanspell=0 #怪物是否被沉默被标记
    @mdebuff=[]
    @edebuff=[]
    
    #生成玩家行动列表
    sign=-1
    for i in 0...$game_variables[183].size
      if $game_variables[183][$game_variables[183].size-1-i]>0
        sign=$game_variables[183].size-1-i
      end
    end
    for i in 0...sign+1
      @mfight.push($game_variables[183][i])
      if $game_variables[183][i]==0
        @mfightvalue.push("")
      end
      for j in 0...@actor.skills.size
        if @actor.skills[j]==$game_variables[183][i]
          @mfightvalue.push($game_variables[180][j])
          break
        end
      end
    end

    #生成怪物行动列表
    for i in 0...zdskill.size
      @efight.push(zdskill[i])
      @efightvalue.push(zdvalue[i])
      case zdskill[i]
      when 7#奥术飞弹（连续三回合）
        @efight.push(zdskill[i]);@efightvalue.push(zdvalue[i])
        @efight.push(zdskill[i]);@efightvalue.push(zdvalue[i])
      when 12#炎爆术（连续七回合）
        for j in 0...6
          @efight.push(zdskill[i]);@efightvalue.push(zdvalue[i])
        end
      when 16#烈焰之拳
        for j in 0...zdvalue[i].split("-")[0].to_i-1
          @efight.push(zdskill[i]);@efightvalue.push(zdvalue[i])
        end
      when 24#凤凰冲击
        @mturn=-1 #怪物夺取先手
        @edamage+=magicdam(zdvalue[i].to_i)
        @efight.delete_at(@efight.size-1)
        @efightvalue.delete_at(@efight.size-1)
      end
    end
    @first_sign=true
    @mfight[0]=0 if true && @mfight.size==0 #为玩家添加空位，确保先手
    @efight[0]=0 if @efight.size==0 #怪物第一回合预处理
    #true未来将替换为先手标志
    @save_ehp=@ehp
    while ((@mturn<@mfight.size || @eturn<@efight.size || @mdebuff.size+@edebuff.size>0) \
      || (@mcanattack+@mcanspell+@ecanattack+@ecanspell>0)) && @ehp>0
      if myactive? #判断玩家是否可以行动
        @edamage-=mrecover(@mhpre)#固定回血
        player_first_active if @mturn==0 && @first_sign
        #若玩家行动列表里有主动技能则开始逐项处理
          if @mcanspell==0 #判断玩家是否被沉默
            my_skill if @mturn<@mfight.size
          else
            @mcanspell-=1
            @mturn-=1 #沉默则推迟技能的使用
          end
      
          
        if @mcanattack==0
          if @mturnr==0 #玩家的第一回合
            if !(miss>=2)  #拥有高级闪避属性的怪物第一回合无法被命中
              @edamage+=counterskill #用于处理反击类技能
              @ehp+=@lsvar*@evampire
              @ehp-=mturn_damage
            end
          else
            @edamage+=counterskill
            @ehp+=@lsvar*@evampire
            @ehp-=mturn_damage
          end
      
        else
          @mcanattack-=1
        end
        mcleardebuff if @mdebuff.size>0
      end
      if @ehp>0
        #若怪物行动列表里有主动技能则开始逐项处理
        @ehp-=enemy_selfdamage
        if @ehp>0

          if @ecanspell==0 #判断怪物是否被沉默
            enemy_skill if @eturn<@efight.size
          else        
            @ecanspell-=1
            @eturn-=1 #沉默则推迟技能的使用
          end

        if @ecanattack==0 #判断怪物是否被缴械或处于吟唱状态
          #处理第一次命中后开始生效的法球
          first_attack_debuff
          if @eturnr==0
            a=eturn_damage(true) #第一下必定暴击
          else
            #怪物攻击生效
            a=eturn_damage
          end
          @ehp+=(a-enormal_attack)*@evampire #敌人吸血
          @edamage+=a
          #玩家反击技能
          a=player_counter_skill
          @ehp-=a
        else
          @ecanattack-=1
        end
        end
      end
      
      if @edamage>=@mhp
        check=@actor.skills.index(20)
        if check && @mskill[check]==0 && @mcanattack==0 #玩家绝境反击
          @mskill[check]=1 #禁用
          a=[(@ma-@ed)*@enodamage-@edecdamage,0].max
          @ehp-=a
          @edamage+=counterskill
          @ehp+=@lsvar*@evampire
          @edamage-=mrecover(a)*$game_variables[180][check].to_f/100
        end
      end

      @mturn+=1;@eturn+=1; #进程处理位置
      @mturnr+=1;@eturnr+=1 #实际回合数
    end
   # p @ehp,@edamage if @enemyid==66
    if @ehp<=0 #若预处理后怪物已经被击败
      @nowin=0
      @edamage=@edamage.to_i
      return
    else
      @edamage-=mrecover(@mhpre)
    end
    #防止法球没有添加的情况出现
    first_attack_debuff
    #吸血等效果处理
    getd=after_battle
    #双方技能释放完毕，进入互相对A环节
    esd=enemy_selfdamage
    pcs=player_counter_skill
    mtd=mturn_damage+esd+getd+pcs
    if mtd>0 #能够破防
      @ehp+=pcs
      @eatimes=(@ehp.to_f/mtd).to_i#怪物的攻击次数
      @eatimes-=1 if @eatimes*mtd>=@ehp #整数的情况下怪物的攻击次数要-1
      @eatimes=0 if @eatimes<0#不能攻击的怪物攻击次数=0
      @edamage+=counterskill
      @edamage+=(eturn_damage-mrecover(@mhpre)+counterskill)*@eatimes
      
      if @edamage>=@mhp
        check=@actor.skills.index(20)
        if check && @mskill[check]==0 #玩家绝境反击
          @mskill[check]=1 #禁用
          a=[(@ma-@ed)*@enodamage-@edecdamage,0].max
          if a>0
            b=(eturn_damage-@mhpre+counterskill)
            if @edamage-b>=@mhp
              @edamage-=b
            end
          end
          @edamage+=counterskill
          @edamage-=mrecover(a)*$game_variables[180][check].to_f/100
        end
      end
      
      @nowin=0
    else#勇士的攻击<怪物的防御
      @edamage=9999999999999#伤害等于次大
      @nowin=1
    end
    @edamage=@edamage.to_i
 
  end
  #怪物回合伤害
  def eturn_damage(crit=false)
    table=[false,true,false,false,false,false,false]
    if !crit
      d=[@ea-@md,0].max*@ecombo*@ecrit*@mmiss*@mshield
    else
      d=[@ea-@md,0].max*@ecombo*@ecritvalue*@mmiss*@mshield
    end
    d+=enormal_attack
    return d
  end
  def enormal_attack
    d=0
    #敌人的普攻附带效果处理
    if @table[$data_enemies[@enemyid].element_ranks[2]] #腐蚀毒素 \v
      d+=@eskill[2].to_i*@mshield
    end
    if @table[$data_enemies[@enemyid].element_ranks[17]] #永恒献祭 \v
      d+=@eskill[17].to_i #纯粹伤害
    end
    if @table[$data_enemies[@enemyid].element_ranks[26]] #元素冲击 \v
      d+=magicdam(@eskill[26].to_i)*@ecombo
    end
    if @table[$data_enemies[@enemyid].element_ranks[29]] #粹毒攻击 \v
      d+=@eskill[29].to_i*@mshield
    end
    return d
  end
  def after_battle
    #这里处理吸血等带来的特殊计算
    d=0
    d-=(eturn_damage-enormal_attack)*@evampire #敌人吸血处理
    counterskill
    d-=@lsvar*@evampire
    return d
  end
  #玩家回合伤害
  def mturn_damage
    d=[(@ma-@ed)*@enodamage-@edecdamage,0].max*@mcombo*@mhitrate
    return d
  end
  def magicdam(dam) #计算怪物实际魔法伤害
    dam=[dam-@mmagicdef,0].max
    return dam
  end
  def emagicdam(dam) #计算玩家实际魔法伤害

    return dam
  end
  def mrecover(value) #计算实际恢复量
    if @estatus[29] #淬毒攻击，生命回复变为相反数
      value*=-1
    end
    return value
  end
  #第一次命中后开始生效的法球
  def first_attack_debuff 
    if @table[$data_enemies[@enemyid].element_ranks[1]] #寒霜攻击 \v
      if @estatus[1]==nil && @ecanattack[@efight.size]!=false
        @estatus[1]=true
        @oldmcombo-=@eskill[1].to_i
        @mcombo=Math.sqrt([@oldmcombo,0].max)/10.0
      end
    end
    if @table[$data_enemies[@enemyid].element_ranks[29]] #淬毒攻击 \v
      if @estatus[29]==nil && @ecanattack[@efight.size]!=false
        @estatus[29]=true
      end
    end
  end
  #反击类技能伤害
  def counterskill
    @lsvar=0
    d=0
    if @table[$data_enemies[@enemyid].element_ranks[11]] #野兽直觉
      if @ecanattack==0
        a=[@ea-@md,0].max*@mshield
        @lsvar+=a
        d+=a
        d+=enormal_attack
        first_attack_debuff 
      end
    end
    return d
  end
  #玩家反击类技能
  def player_counter_skill
    d=0
   #勇气之霎
    check=@actor.skills.index(27)
    if check && @mskill[check]==0 && @mcanattack==0 #勇气之霎
      @mskill[check]=1 #禁用
      value=[(@ma-@ed)*@enodamage-@edecdamage,0].max
      @ehp-=value
      @edamage+=counterskill
      @ehp+=@lsvar*@evampire
      value=[value,@ehp].min
      @edamage-=mrecover(value)*$game_variables[180][check].to_f/100
    end
    return d
  end
  #判断玩家是否可以行动
  def myactive?
    return (@mturn>=0) #0表示玩家获得先手，需要单独处理
  end
  #处理玩家的技能效果
  def my_skill
    if @mfight[@mturn]>0
      if @spcost+@mfightvalue[@mturn].split("-")[0].to_i<=@actor.sp
        @spcost+=@mfightvalue[@mturn].split("-")[0].to_i
        case @mfight[@mturn]
        when 28 #风暴之锤
          @mcanattack=1 if @mcanattack<1 #自我缴械，当前回合不作普通攻击
          @ehp-=emagicdam(@mfightvalue[@mturn].split("-")[1].to_f)*@enodamage
          exuanyun(@mfightvalue[@mturn].split("-")[2].to_i) #眩晕怪物
        end
      end
    end
  end
  #处理怪物的技能效果
  def enemy_skill
    if @efight[@eturn]>0
      if @table[$data_enemies[@enemyid].element_ranks[23]] #静电场
        @edamage+=(@mhp-@edamage)*@eskill[23].to_f/100 #纯粹伤害
      end
    end
    #0表示第一回合的普攻，不作处理
    case @efight[@eturn]
    when 7 #奥术飞弹
      @ecanattack=1 if @ecanattack<1 #自我缴械，当前回合不作普通攻击
      @edamage+=magicdam(@efightvalue[@eturn].to_i)
    when 10 #风暴
      @mdebuff.push([5,@efight[@eturn],@efightvalue[@eturn]]) #持续5回合的debuff
      @oldmcombo-=@efightvalue[@eturn].split("-")[1].to_f
      @mcombo=Math.sqrt([@oldmcombo,0].max)/10.0
    when 12 #炎爆术
      @ecanattack=1 if @ecanattack<1 #自我缴械，当前回合不作普通攻击
      @edamage+=magicdam(@efightvalue[@eturn].to_i)
    when 15 #雷霆一击
      @mdebuff.push([@efightvalue[@eturn].split("-")[1].to_i,@efight[@eturn],@efightvalue[@eturn]]) #持续5回合的debuff
      @edamage+=magicdam(@efightvalue[@eturn].split("-")[0].to_f)
      @oldmcombo-=@efightvalue[@eturn].split("-")[2].to_f
      @mcombo=Math.sqrt([@oldmcombo,0].max)/10.0
    when 16 #烈焰之拳
      @edamage+=magicdam(@efightvalue[@eturn].split("-")[1].to_i)
    when 19 #次级沟壑
      @ecanattack=1 if @ecanattack<1 #自我缴械，当前回合不作普通攻击
      mxuanyun(@efightvalue[@eturn].split("-")[1].to_i) #眩晕玩家
      @edamage+=magicdam(@efightvalue[@eturn].split("-")[0].to_i)
    when 22 #雷霆之击
      @ecanattack=1 if @ecanattack<1 #自我缴械，当前回合不作普通攻击
      @mdebuff.push([4,@efight[@eturn],@efightvalue[@eturn]]) #持续5回合的debuff
    when 25 #撕裂伤口
      @mdebuff.push([@efightvalue[@eturn].split("-")[0].to_i,@efight[@eturn],@efightvalue[@eturn]]) #持续\v回合的debuff
      @oldmcombo-=@efightvalue[@eturn].split("-")[1].to_f
      @mcombo=Math.sqrt([@oldmcombo,0].max)/10.0
      @evampire+=@efightvalue[@eturn].split("-")[2].to_f/100
    end
  end
  def mcleardebuff
    for i in @mdebuff
      i[0]-=1
      if i[0]>=50 || i[0]<0
        p i
        exit
      end
      case i[1]
      when 1 #相位鞋被动
        if i[0]==0
          @mmiss/=0.76
          #还原闪避
        end
      when 10 #风暴
        @edamage+=magicdam(i[2].split("-")[0].to_f)
        if i[0]==0
          @oldmcombo+=i[2].split("-")[1].to_f
          @mcombo=Math.sqrt([@oldmcombo,0].max)/10.0
          #还原攻速
        end
      when 15 #雷霆一击
        if i[0]==0
          @oldmcombo+=i[2].split("-")[2].to_f
          @mcombo=Math.sqrt([@oldmcombo,0].max)/10.0
          #还原攻速
        end
      when 22 #雷霆之击
        @edamage+=magicdam(i[2].to_f)
      when 25 #撕裂伤口
        if i[0]==0
          @oldmcombo+=i[2].split("-")[1].to_f
          @mcombo=Math.sqrt([@oldmcombo,0].max)/10.0
          #还原攻速
          @evampire-=i[2].split("-")[2].to_f/100
          #还原吸血率
        end
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
  #玩家第一回合行动（装备使用等）
  def player_first_active
    @first_sign=false
    if @mequip.include?(21) #相位鞋
      #持续3回合的增益buff，第四个参数确定是否为增益状态
      #主要针对在怪物回合数防御的要+1
      @mdebuff.push([3+1,1,24,true])
      @mmiss*=0.76
    end
  end
  def enemy_selfdamage #敌人自我伤害
    d=0
    if @table[$data_enemies[@enemyid].element_ranks[21]] #过载
      d+=@eskill[21].split("-")[0].to_f #纯粹伤害
    end
    return d
  end
  def mxuanyun(i)
    @mcanattack=i if @mcanattack<i
    @mcanspell=i if @mcanspell<i
  end
  def exuanyun(i)
    @ecanattack=i if @ecanattack<i
    @ecanspell=i if @ecanspell<i
  end
  #--------------------------------------------------------------------------
  # ● 返回怪物的伤害类型
  #--------------------------------------------------------------------------
  def got_nowin
    return @nowin
    #0代表可以对怪物造成伤害,1代表无法伤害,2代表怪物无敌
  end
  #--------------------------------------------------------------------------
  # ● 返回怪物的伤害
  #--------------------------------------------------------------------------
  def got_damage
    return @edamage
  end
  #--------------------------------------------------------------------------
  # ● 返回怪物的伤害
  #--------------------------------------------------------------------------
  def got_spcost
    return @spcost
  end
    def got_dex
    return @edex
  end
  #--------------------------------------------------------------------------
  # ● 返回怪物的攻击
  #--------------------------------------------------------------------------
  def got_ea
    return @ea
  end
  #--------------------------------------------------------------------------
  # ● 返回怪物的防御
  #--------------------------------------------------------------------------
  def got_ed
    return @ed
  end
    def got_ehp
    return @ehp
  end
  #--------------------------------------------------------------------------
  # ● 返回怪物的属性
  #--------------------------------------------------------------------------
  def got_p(val)
    table=[false,true,false,false,false,false,false]
    return table[$data_enemies[@enemyid].element_ranks[val]]
  end
  #--------------------------------------------------------------------------
  # ● 返回怪物的属性种数
  #--------------------------------------------------------------------------
  def got_kind
    return @kind
  end
end
  #--------------------------------------------------------------------------
  # ● 返回怪物的属性
  #--------------------------------------------------------------------------
  def got_p(id,val)
    table=[false,true,false,false,false,false,false]
    return false if $data_enemies[id].element_ranks[val]==nil
    return table[$data_enemies[id].element_ranks[val]]
  end
  def got_p_value(id,val)
    table=[false,true,false,false,false,false,false]
    kk=0
    value=nil
    for i in 1...$data_enemies[id].element_ranks.xsize
      if table[$data_enemies[id].element_ranks[i]]
        if $data_skills[i].description.split("\\v").size>1
          kk+=1
          if val==i
            value=$data_enemies[id].name.split(":")[kk]
            break
          end
        end
      end
    end
    return value
  end
=end