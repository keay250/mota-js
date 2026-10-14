#==============================================================================
# ■ Game_Actor
#------------------------------------------------------------------------------
# 　处理角色的类。本类在 Game_Actors 类 ($game_actors)
# 的内部使用、Game_Party 类请参考 ($game_party) 。
#==============================================================================

class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # ● 定义实例变量
  #--------------------------------------------------------------------------
  attr_reader   :name                     # 名称
  attr_reader   :character_name           # 角色 文件名
  attr_reader   :character_hue            # 角色 色相
  attr_reader   :class_id                 # 职业 ID
  attr_accessor   :equip_id                # 武器 ID
  attr_reader   :level                    # 水平
  attr_accessor   :hprate
  attr_accessor   :sprate
  attr_reader   :exp                      # EXP
  attr_reader   :skills                   # 特技
  
  attr_reader   :str_minus                # 攻击下降标志
  attr_reader   :dex_minus                # 防御下降标志
  attr_reader   :power1_minus             # 力量下降标志
  attr_reader   :power2_minus             # 敏捷下降标志
  attr_reader   :power3_minus             # 智力下降标志
  #--------------------------------------------------------------------------
  # ● 初始化对像
  #     actor_id : 角色 ID
  #--------------------------------------------------------------------------
  def initialize(actor_id)
    super()
    setup(actor_id)
  end
  #--------------------------------------------------------------------------
  # ● 设置
  #     actor_id : 角色 ID
  #--------------------------------------------------------------------------
  def setup(actor_id)
    actor = $data_actors[actor_id]
    @actor_id = actor_id
    @name = actor.name
    @character_name = actor.character_name
    @character_hue = actor.character_hue
    @battler_name = actor.battler_name
    @battler_hue = actor.battler_hue
    @class_id = actor.class_id
    @equip_id =[nil,nil,nil,nil,nil,nil]
    @level = actor.initial_level
    @exp_list = Array.new(101)
    make_exp_list
    @exp = @exp_list[@level]
    @skills = []
    @hp = maxhp
    @sp = maxsp
    @hprate=1
    @sprate=1
    @str_minus=false
    @dex_minus=false
    @power1_minus=false
    @power2_minus=false
    @power3_minus=false
    @states = []
    @states_turn = {}
    @maxhp_plus = 0
    @maxsp_plus = 0
    @str_plus = 0
    @dex_plus = 0
    @agi_plus = 0
    @int_plus = 0
    # 学会特技
    for i in 1..@level
      for j in $data_classes[@class_id].learnings
        if j.level == i
          learn_skill(j.skill_id)
        end
      end
    end
    # 刷新自动状态
    for i in @equip_id
      update_auto_state(nil, $data_weapons[i]) if i !=nil
    end
  end
  #--------------------------------------------------------------------------
  # ● 获取角色 ID 
  #--------------------------------------------------------------------------
  def id
    return @actor_id
  end
  def set_skills(i)
    @skills=i
  end
  #--------------------------------------------------------------------------
  # ● 获取索引
  #--------------------------------------------------------------------------
  def index
    return $game_party.actors.index(self)
  end
  #--------------------------------------------------------------------------
  # ● 计算 EXP
  #--------------------------------------------------------------------------
  def make_exp_list
    actor = $data_actors[@actor_id]
    @exp_list[1] = 0
    pow_i = 2.4 + actor.exp_inflation / 100.0
    for i in 2..100
      if i > actor.final_level
        @exp_list[i] = 0
      else
        n = actor.exp_basis * ((i + 3) ** pow_i) / (5 ** pow_i)
        @exp_list[i] = @exp_list[i-1] + Integer(n)
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 取得属性修正值
  #     element_id : 属性 ID
  #--------------------------------------------------------------------------
  def element_rate(element_id)
   
  end
  #--------------------------------------------------------------------------
  # ● 获取属性有效度
  #--------------------------------------------------------------------------
  def state_ranks
    return $data_classes[@class_id].state_ranks
  end
  #--------------------------------------------------------------------------
  # ● 判定防御属性
  #     state_id : 属性 ID
  #--------------------------------------------------------------------------
  def state_guard?(state_id)
    
  end
  #--------------------------------------------------------------------------
  # ● 获取普通攻击属性
  #--------------------------------------------------------------------------
  def element_set
   
  end
  #--------------------------------------------------------------------------
  # ● 获取普通攻击状态变化 (+)
  #--------------------------------------------------------------------------
  def plus_state_set
    
  end
  #--------------------------------------------------------------------------
  # ● 获取普通攻击状态变化 (-)
  #--------------------------------------------------------------------------
  def minus_state_set
    
  end
  #--------------------------------------------------------------------------
  # ● 获取 三维
  #--------------------------------------------------------------------------
  def power1
    return 0 if $game_variables[154]==0
    @power1_minus=false
    n=$game_variables[151]
    for i in @equip_id
      next if i==nil
      n+=$data_weapons[i]!= nil ? $data_weapons[i].atk : 0
      if $game_variables[154]==1 && $data_weapons[i]!= nil
        for j in $data_weapons[i].name.split(':')
          if j[0,2]=="MA"
            n+=j[2,j.size-2].to_i
          end
        end
      end
    end
    if @equip_id.include?(65) #极限法球特殊判断
      q=@equip_id.index(65)
      check=true
      for k in 0...@equip_id.size
        next if k==q
        j=@equip_id[k]
        if j != nil && j !=0 && $data_weapons[j].price>=100000
          check=false
          break
        end
      end
      if check
        n+=$data_weapons[65].atk*2
      end
    end
    if $game_variables[226]!=0 #天赋开启
      n+=$game_variables[226][1]*10
      n+=[$game_variables[226][11],6].min*20 if $game_variables[226][11]!=nil
      n+=$game_variables[226][21]*30 if $game_variables[226][21]!=nil
    end
    if $game_variables[232]!=0
      if get_buff_time(11)>0
        @power1_minus=true
        if get_buff_time(11)>30
          return 0
        end
        n*=$rate_list_3[[get_buff_time(11),30].min]
      end
    end
    return n.to_i
  end
  def power2
    return 0 if $game_variables[154]==0
    @power2_minus=false
    n=$game_variables[152]
    for i in @equip_id
      next if i==nil
      n+=$data_weapons[i]!= nil ? $data_weapons[i].pdef : 0
      if $game_variables[154]==2 && $data_weapons[i]!= nil
        for j in $data_weapons[i].name.split(':')
          if j[0,2]=="MA"
            n+=j[2,j.size-2].to_i
          end
        end
      end
    end
    if @equip_id.include?(65) #极限法球特殊判断
      q=@equip_id.index(65)
      check=true
      for k in 0...@equip_id.size
        next if k==q
        j=@equip_id[k]
        if j != nil && j !=0 && $data_weapons[j].price>=100000
          check=false
          break
        end
      end
      if check
        n+=$data_weapons[65].pdef*2
      end
    end
    if $game_variables[226]!=0 #天赋开启
      n+=$game_variables[226][2]*10
      n+=[$game_variables[226][12],6].min*20 if $game_variables[226][12]!=nil
      n+=$game_variables[226][21]*30 if $game_variables[226][21]!=nil
    end
    if $game_variables[232]!=0
      if get_buff_time(11)>0
        @power2_minus=true
        if get_buff_time(11)>30
          return 0
        end
        n*=$rate_list_3[[get_buff_time(11),30].min]
      end
    end
    return n.to_i
  end
  def power3
    return 0 if $game_variables[154]==0
    @power3_minus=false
    n=$game_variables[153]
    for i in @equip_id
      next if i==nil
      n+=$data_weapons[i]!= nil ? $data_weapons[i].mdef : 0
      if $game_variables[154]==3 && $data_weapons[i]!= nil
        for j in $data_weapons[i].name.split(':')
          if j[0,2]=="MA"
            n+=j[2,j.size-2].to_i
          end
        end
      end
    end
    if @equip_id.include?(65) #极限法球特殊判断
      q=@equip_id.index(65)
      check=true
      for k in 0...@equip_id.size
        next if k==q
        j=@equip_id[k]
        if j != nil && j !=0 && $data_weapons[j].price>=100000
          check=false
          break
        end
      end
      if check
        n+=$data_weapons[65].mdef*2
      end
    end
    if $game_variables[226]!=0 #天赋开启
      n+=$game_variables[226][3]*10
      n+=[$game_variables[226][13],6].min*20 if $game_variables[226][13]!=nil
      n+=$game_variables[226][21]*30 if $game_variables[226][21]!=nil
    end
    base_power3=n
    if @equip_id.include?($game_variables[231]) && $game_variables[231]>0 #夜魔祭品
      if $game_variables[237]!=0
        for i in $game_variables[237]
          case i[0]
          when 10
            n+=(base_power3*0.04).to_i
          when 104
            n+=(base_power3*0.05).to_i
          end
        end
      end
    end
    if @equip_id.include?(115) #散夜
      if n>power2 && n>power1
        n/=2
      end
    end
    if $game_variables[232]!=0
      if get_buff_time(11)>0
        @power3_minus=true
        if get_buff_time(11)>30
          return 0
        end
        n*=$rate_list_3[[get_buff_time(11),30].min]
      end
    end
    return n.to_i
  end
  def init_power3
    return 0 if $game_variables[154]==0
    n=$game_variables[153]
    return n
  end
  def keys_number
    n=0
    n+=$game_party.item_number(1)
    n+=$game_party.item_number(2)*4
    n+=$game_party.item_number(3)*15
    return n
  end
  def keys_number2
    n=0
    n+=$game_party.item_number(1)
    n+=$game_party.item_number(2)
    n+=$game_party.item_number(3)
    return true if n==0
  end
  def keys_number3
    n=0
    n+=$game_party.item_number(1)
    n+=$game_party.item_number(2)
    return true if n==0
  end
  #--------------------------------------------------------------------------
  # ● 获取 回血速度
  #--------------------------------------------------------------------------
  def hprecover
    n = $game_variables[155]
    n*=(1+power1*0.01)
    for i in @equip_id
      if i !=nil && $data_weapons[i]!= nil
        for j in $data_weapons[i].name.split(':')
          if j[0,1]=="A"
            n+=j[1,j.size-1].to_f
          end
        end
      end
    end
    if $game_switches[166] #妖精之泉效果
      n+=2000
    end
    if @equip_id.include?($game_variables[231]) && $game_variables[231]>0 #夜魔祭品
      if $game_variables[237]!=0
        for i in $game_variables[237]
          case i[0]
          when 6
            n+=power1*8
          when 103
            n+=power1*10
          end
        end
      end
    end
    if $game_switches[183]
      n=0
    end
    if $game_variables[226]!=0 #天赋开启
      if $tuihua==false
        if $game_variables[226][22]!=nil
          if $game_variables[226][22]>0
            n+=$game_variables[197]/100.0*maxhp*0.000015*$game_variables[226][22]
          end
        end
      end
    end
    n-=$game_variables[192]
 #   n = [[n, 0].max, 99999999].min
    return n
  end
  #--------------------------------------------------------------------------
  # ● 获取 回魔速度
  #--------------------------------------------------------------------------
  def sprecover
    n = $game_variables[143]
    n*=(1+power3*0.01)
    for i in @equip_id
      if i !=nil && $data_weapons[i]!= nil
        for j in $data_weapons[i].name.split(':')
          if j[0,2]=="SR"
            n+=j[2,j.size-2].to_f
          end
        end
      end
    end
    if @equip_id.include?(38) #奥术鞋
      n*=1.2
    end
    if @equip_id.include?(67) #卫士胫甲
      n*=1.25
    end
    if @equip_id.include?(134) #永恒之盘
      n*=1.2
    end
    #不朽山谷
    if $game_party.actors.include?($game_actors[3]) && $game_actors[3].level==3
      n*=1.25
    end
    if @equip_id.include?($game_variables[231]) && $game_variables[231]>0 #夜魔祭品
      if $game_variables[237]!=0
        for i in $game_variables[237]
          case i[0]
          when 9
            n+=power3*0.001
          when 103
            n+=power3*0.0015
          end
        end
      end
    end
    if $game_variables[226]!=0 #天赋开启
      if $tuihua==false
        if $game_variables[226][22]!=nil
          if $game_variables[226][22]>0
            n+=$game_variables[197]/100.0*maxsp*0.000006*$game_variables[226][22]
          end
        end
      end
    end
    n+=$jinmo[1]
    if $game_switches[183]
      n=0
    end
  #  n = [[n, 0].max, 99999999].min
    return n
  end
  #--------------------------------------------------------------------------
  # ● 获取 闪避率
  #--------------------------------------------------------------------------
  def miss(base=false)
    n = 1-$game_variables[164]/100.0
    for i in @equip_id
      if i !=nil && $data_weapons[i]!= nil
        for j in $data_weapons[i].name.split(':')
          if j[0,2]=="MI"
            n*=(1-j[2,j.size-2].to_f/100.0)
          end
        end
      end
    end
    #传奇附魔
    if @equip_id.include?($game_variables[231]) && $game_variables[231]>0 #夜魔祭品
      if $game_variables[237]!=0
        k=0
        for i in $game_variables[237]
          case i[0]
          when 11
            k+=0.04
          when 105
            k+=0.05
          end
        end
        n*=(1-k)
      end
    end
    if !base
      if $game_variables[232]!=0
        for j in $game_variables[232]
          if j[0]==1 #急速神符
            n*=0.65
          end
        end
      end
    end
    n = 1 - n
    n = [n, 0].max
    return n
  end
  #--------------------------------------------------------------------------
  # ● 获取 技能伤害加成
  #--------------------------------------------------------------------------
  def skilldam(base=false)
    n = 1
    for i in @equip_id
      if i !=nil && $data_weapons[i]!= nil
        for j in $data_weapons[i].name.split(':')
          if j[0,2]=="SD"
            n+=j[2,j.size-2].to_f/100
          end
        end
      end
    end
      if $game_variables[199]==6
        for i in 0...$game_actors[$game_variables[1]+1].skills.size
          k=$game_actors[$game_variables[1]+1].skills[i]
          if $data_skills[k].name[0,12]=="灵魂支配"
            a=$game_variables[180][i].split("-")
            if $tuihua==false
              n+=$game_variables[197]*a[3].to_f/10000
            else
              n+=[$game_variables[197]-$game_variables[198],0].max*a[3].to_f/10000
            end
          end
        end
      end

    if @equip_id.include?($game_variables[231]) && $game_variables[231]>0 #夜魔祭品
      if $game_variables[237]!=0
        k=0
        for i in $game_variables[237]
          case i[0]
          when 7
            k+=0.125
          when 104
            k+=0.125
          end
        end
        n+=k
      end
    end
    if $game_variables[226]!=0 #天赋开启
      if $game_variables[226][21]!=nil
        if $game_variables[226][21]>0
          n*=(0.45+$game_variables[226][21]*0.05) 
        end
      end
    end
    if !base
      if $game_variables[232]!=0
        for j in $game_variables[232]
          if j[0]==2 #奥术神符
            n*=1.6
          end
        end
      end
    end
    n = [n, 0].max
    return n
  end
  #--------------------------------------------------------------------------
  # ● 获取 法力消耗减少
  #--------------------------------------------------------------------------
  def skillminus(base=false)
    n = 1
    for i in @equip_id
      if i !=nil && $data_weapons[i]!= nil
        for j in $data_weapons[i].name.split(':')
          if j[0,2]=="SM"
            n*=(1-j[2,j.size-2].to_f/100)
          end
        end
      end
    end
    if !base
      if $game_variables[232]!=0
        for j in $game_variables[232]
          if j[0]==2 #奥术神符
            n*=0.6
          end
        end
      end
    end
    if @equip_id.include?($game_variables[231]) && $game_variables[231]>0 #夜魔祭品
      if $game_variables[237]!=0
        k=1
        for i in $game_variables[237]
          case i[0]
          when 8
            k-=0.075
          when 104
            k-=0.1
          end
        end
        n*=k
      end
    end
    n*=$jinmo[0]
    n = [n, 0].max
    return n
  end
  #--------------------------------------------------------------------------
  # ● 获取 吸血倍率
  #--------------------------------------------------------------------------
  def vampire
    n=0
    for i in @equip_id
      if i !=nil && $data_weapons[i]!= nil
        for j in $data_weapons[i].name.split(':')
          if j[0,2]=="BL"
            n=j[2,j.size-2].to_f if n<j[2,j.size-2].to_f
          end
        end
      end
    end
    if $tuihua==false
      if $game_variables[266]==2
        for i in 0...$game_actors[$game_variables[1]+1].skills.size
          k=$game_actors[$game_variables[1]+1].skills[i]
          if $data_skills[k].name[0,12]=="魔王降临"
            a=$game_variables[180][i].split("-")
            n+=a[1].to_f/100
          end
        end
      end
    end
    return n
  end
  #--------------------------------------------------------------------------
  # ● 获取 穿甲
  #--------------------------------------------------------------------------
  def armorbreak
    n = 0
    for i in @equip_id
      if i !=nil && $data_weapons[i]!= nil
        for j in $data_weapons[i].name.split(':')
          if j[0,2]=="BA"
            n+=j[2,j.size-2].to_i
          end
        end
      end
    end
    if $tuihua==false
      for i in 0...$game_actors[$game_variables[1]+1].skills.size
        k=$game_actors[$game_variables[1]+1].skills[i]
        if $data_skills[k].name[0,12]=="魔王降临"
          a=$game_variables[180][i].split("-")
          n+=a[0].to_i
        end
      end
    end
    if @equip_id.include?($game_variables[231]) && $game_variables[231]>0 #夜魔祭品
      if $game_variables[237]!=0
        for i in $game_variables[237]
          case i[0]
          when 3
            n+=6
          when 101
            n+=7
          when 201
            n+=20
          end
        end
      end
    end
    n = [[n, 0].max, 99999999].min
    return n
  end
  def hitrate(base=false)
    n=1
     if !base
      if $game_variables[232]!=0
        for j in $game_variables[232]
          if j[0]==3 #双倍神符
            n*=2
          end
        end
      end
    end
    return n
  end
  #--------------------------------------------------------------------------
  # ● 获取 法术能量
  #--------------------------------------------------------------------------
  def magicpower
    n = $game_variables[156]
    for i in @equip_id
      if i !=nil && $data_weapons[i]!= nil
        for j in $data_weapons[i].name.split(':')
          if j[0,2]=="MP"
            n+=j[2,j.size-2].to_f
          end
        end
      end
    end
    if @equip_id.include?(123) #紫苑
      if power3>power1 && power3>power2
        n+=[power3/100.0*(@str_plus+999)/500,20000].min
      end
    end
    if @equip_id.include?(131) #血棘
      if power3>power1 && power3>power2
        n+=[power3/100.0*(@str_plus+999)/2000,400000].min
      end
    end
    if @equip_id.include?(89)
      n+=(@str_plus+999)/50
    end
    if (@equip_id.include?(75) && $game_variables[181][75]==-1)#以太之镜
      n+=(@str_plus+999)/50
    end
    if $tuihua==false
      if $game_variables[266]==3
        for i in 0...$game_actors[$game_variables[1]+1].skills.size
          k=$game_actors[$game_variables[1]+1].skills[i]
          if $data_skills[k].name[0,12]=="魔王降临"
            a=$game_variables[180][i].split("-")
            n*=1+a[2].to_f/100
          end
        end
      end
    end
    n*=(1+power3*0.01)
    n = [[n.to_i, 0].max, 99999999].min
    return n
  end
  #--------------------------------------------------------------------------
  # ● 获取 MaxHP
  #--------------------------------------------------------------------------
  def maxhp
    value=power1*0.01
    if @equip_id.include?(131) #血棘
      if power3>power1 && power3>power2
        value+=power3/100.0*0.25
      end
    end
    n = [[base_maxhp + (@maxhp_plus+9999)*(1+value), 1].max, 9999999999999999].min
    for i in @states
      n *= $data_states[i].maxhp_rate / 100.0
    end
    n = [[Integer(n), 1].max, 9999999999999999].min
    return n
  end
  #--------------------------------------------------------------------------
  # ● 获取基本 MaxHP
  #--------------------------------------------------------------------------
  def base_maxhp
    n=0#$data_actors[@actor_id].parameters[0,1]
    for i in @equip_id
      if i !=nil && $data_weapons[i]!= nil
        for j in $data_weapons[i].name.split(':')
          if j[0,2]=="MH"
            n+=j[2,j.size-2].to_i
          end
        end
      end
    end
    if $game_variables[199]==5 || $game_variables[199]==6
      for i in 0...$game_actors[$game_variables[1]+1].skills.size
        k=$game_actors[$game_variables[1]+1].skills[i]
        if $data_skills[k].name[0,12]=="灵魂支配"
          a=$game_variables[180][i].split("-")
          if $tuihua==false
            n+=$game_variables[197]*a[2].to_i
          else
            n+=[$game_variables[197]-$game_variables[198],0].max*a[2].to_i
          end
        end
      end
    end
    return [[n.to_i, 0].max, 99999999999999999].min
  end
  #--------------------------------------------------------------------------
  # ● 更改 HP
  #     hp : 新的 HP
  #--------------------------------------------------------------------------
  def hp=(hp)
    @hp = [[hp, maxhp].min, 0].max
    # 解除附加的战斗不能状态
    for i in 1...$data_states.size
      if $data_states[i].zero_hp
        if self.dead?
          add_state(i)
        else
          remove_state(i)
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 获取 MaxSP
  #--------------------------------------------------------------------------
  def maxsp
   # n=base_maxsp + (@maxsp_plus+9999)*(1+power3*0.01)
    n = [[base_maxsp + (@maxsp_plus+9999)*(1+power3*0.01), 0].max, 9999999999999999].min
    for i in @states
      n *= $data_states[i].maxsp_rate / 100.0
    end
    n = [[Integer(n), 0].max, 9999999999999999].min
    return n
  end
  def init_maxsp
    return [(@maxsp_plus+9999)*(1+init_power3*0.01), 0].max
  end
  def init_maxsp_unzero
    return (@maxsp_plus+9999)*(1+init_power3*0.01)
  end
  #--------------------------------------------------------------------------
  # ● 获取基本 MaxSP
  #--------------------------------------------------------------------------
  def base_maxsp
    n=0#$data_actors[@actor_id].parameters[1,1]
    for i in @equip_id
      if i !=nil && $data_weapons[i]!= nil
        for j in $data_weapons[i].name.split(':')
          if j[0,2]=="MS"
            n+=j[2,j.size-2].to_i
          end
        end
      end
    end
    return [[n, 0].max, 99999999999999999].min
  end
  #--------------------------------------------------------------------------
  # ● 获取力量
  #--------------------------------------------------------------------------
  def str
    @str_minus=false
    n = [[base_str + ((@str_plus+999)*(1+power2*0.001)), 0].max, 99999999].min
    for i in @states
      n *= $data_states[i].str_rate / 100.0
    end
    if $game_variables[232]!=0
      if get_buff_time(9)>0
        @str_minus=true
        if get_buff_time(9)>30
          return 0
        end
        n*=$rate_list_3[[get_buff_time(9),30].min]
      end
    end
    n = [[Integer(n), 0].max, 99999999].min
    return n
  end
  #--------------------------------------------------------------------------
  # ● 获取灵巧
  #--------------------------------------------------------------------------
  def dex
    @dex_minus=false
    n = [[base_dex + ((@dex_plus+999)*(1+power1*0.001)), 0].max, 99999999].min
    for i in @states
      n *= $data_states[i].dex_rate / 100.0
    end
    if $game_variables[232]!=0
      if get_buff_time(9)>0
        @dex_minus=true
        if get_buff_time(9)>30
          return 0
        end
        n*=$rate_list_3[[get_buff_time(9),30].min]
      end
    end
    n = [[Integer(n), 0].max, 99999999].min
    return n
  end
  #--------------------------------------------------------------------------
  # ● 获取基本力量
  #--------------------------------------------------------------------------
  def base_str
    n = 0#$data_actors[@actor_id].parameters[2, 1]#@level]
    for i in @equip_id
      n+=$data_weapons[i]!= nil ? $data_weapons[i].str_plus : 0 if i !=nil
      if i==66
        n+=(@str_plus+999)/10
      end
      if i==126
        n+=(@str_plus+999)*0.15
      end
    end
    if $game_variables[226]!=0 #天赋开启
      if $game_variables[226][21]!=nil
        n+=(@str_plus+999)*$game_variables[226][21]*0.01
      end
    end
    #灵魂支配
    if $tuihua==false
    case $game_variables[199]
    when 1
      n+=($game_variables[197]*0.1).to_i
    when 2
      n+=($game_variables[197]).to_i
    when 3
      n+=($game_variables[197]*3).to_i
    when 4
      n+=($game_variables[197]*5).to_i
    end
    end
  
    if $game_variables[199]==5 || $game_variables[199]==6
      for i in 0...$game_actors[$game_variables[1]+1].skills.size
        k=$game_actors[$game_variables[1]+1].skills[i]
        if $data_skills[k].name[0,12]=="灵魂支配"
          a=$game_variables[180][i].split("-")
          if $tuihua==false
            n+=$game_variables[197]*a[1].to_i
          else
            n+=[$game_variables[197]-$game_variables[198],0].max*a[1].to_i
          end
        end
      end
    end
    
    if @equip_id.include?(123) #紫苑
      if power3>power1 && power3>power2
        n+=power3*(@str_plus+999)/4000
      end
    end
    if @equip_id.include?(131) #血棘
      if power3>power1 && power3>power2
        n+=power3*(@str_plus+999)/3333
      end
    end
    if @equip_id.include?(89)
      n+=[magicpower,8000].min
    end
    if (@equip_id.include?(75) && $game_variables[181][75]!=-1)#以太之镜
      n+=[magicpower,5000].min
    end
    if @equip_id.include?($game_variables[231]) && $game_variables[231]>0 #夜魔祭品
      if $game_variables[237]!=0
        for i in $game_variables[237]
          case i[0]
          when 1
            n+=(@str_plus+999)/50
          when 101
            n+=(@str_plus+999)/40
          end
        end
      end
    end
    return [[n, 0].max, 9999999999999999999999].min
  end
  #--------------------------------------------------------------------------
  # ● 获取基本灵巧
  #--------------------------------------------------------------------------
  def base_dex
    n = 0#$data_actors[@actor_id].parameters[3, 1]#@level]
    for i in @equip_id
      n+=$data_weapons[i]!= nil ? $data_weapons[i].dex_plus : 0  if i !=nil
    end
    if $game_variables[226]!=0 #天赋开启
      if $game_variables[226][21]!=nil
        n+=(@dex_plus+999)*$game_variables[226][21]*0.01
      end
    end
    if @equip_id.include?(123) #紫苑
      if power3>power1 && power3>power2
        n+=power3*(@dex_plus+999)/4000
      end
    end
    if @equip_id.include?(131) #血棘
      if power3>power1 && power3>power2
        n+=power3*(@dex_plus+999)/3333
      end
    end
    if @equip_id.include?($game_variables[231]) && $game_variables[231]>0 #夜魔祭品
      if $game_variables[237]!=0
        for i in $game_variables[237]
          case i[0]
          when 2
            n+=(@dex_plus+999)/50
          when 102
            n+=(@dex_plus+999)/40
          end
        end
      end
    end
    return [[n, 0].max, 99999999999999999999999].min
  end
  #--------------------------------------------------------------------------
  # ● 获取 角色攻速
  #--------------------------------------------------------------------------
  def atkspeed(base=false)
    n = $game_variables[157]+power2
    for i in @equip_id
      if i !=nil && $data_weapons[i]!= nil
        for j in $data_weapons[i].name.split(':')
          if j[0,1]=="C"
            n+=j[1,j.size-1].to_i
          end
        end
      end
    end
    if !base
      if $game_variables[232]!=0
        for j in $game_variables[232]
          if j[0]==1 #急速神符
            n*=3
          end
        end
      end
      n-=$game_variables[217]
    end
    if @equip_id.include?($game_variables[231]) && $game_variables[231]>0 #夜魔祭品
      if $game_variables[237]!=0
        for i in $game_variables[237]
          case i[0]
          when 4
            n+=250
          when 105
            n+=300
          end
        end
      end
    end
    if @equip_id.include?(115)
      n*=1.3
    elsif @equip_id.include?(114) #夜叉
      n*=1.2
    end
    n = [[n.to_i, 0].max, 99999999].min
    return n
  end
  #--------------------------------------------------------------------------
  # ● 获取 角色护甲
  #--------------------------------------------------------------------------
  def shield
    n = $game_variables[158]+power2/10
    for i in @equip_id
      if i !=nil && $data_weapons[i]!= nil
        for j in $data_weapons[i].name.split(':')
          if j[0,1]=="D"
            n+=j[1,j.size-1].to_f
          end
        end
      end
    end
    #不朽山谷
    if $game_party.actors.include?($game_actors[3]) && $game_actors[3].level==3
      n+=(power3*0.02).to_i
    end
    if @equip_id.include?($game_variables[231]) && $game_variables[231]>0 #夜魔祭品
      if $game_variables[237]!=0
        for i in $game_variables[237]
          case i[0]
          when 5
            n+=6
          when 102
            n+=7
          when 202
            n+=20
          end
        end
      end
    end
    n = [n, 99999999].min
    return n
  end
  def prshield(a=shield)
    if a>=0
      a=(a*0.06)/(1+0.06*a)
      a=1-a
      if $game_variables[279]!=0
        a*=$game_variables[279]
      end
      if $game_variables[232]!=0
        a*=1+get_buff_time(8)*0.1
      end
      return a
    else
      a=-a*0.06
      return 1+a
    end
  end
  def rshield(a=shield)
    if a>=0
      a=(a*0.06)/(1+0.06*a)
      return 1-a
    else
      a=-a*0.06
      return 1+a
    end
  end
  #--------------------------------------------------------------------------
  # ● 获取 角色普攻伤害格挡
  #--------------------------------------------------------------------------
  def defence
    n=0
    for i in @equip_id
      if i !=nil && $data_weapons[i]!= nil
        for j in $data_weapons[i].name.split(':')
          if j[0,2]=="GD"
            n+=j[2,j.size-2].to_f
          end
        end
      end
    end
    if @equip_id.include?($game_variables[231]) && $game_variables[231]>0 #夜魔祭品
      if $game_variables[237]!=0
        for i in $game_variables[237]
          case i[0]
          when 102
            n+=500
          end
        end
      end
    end
    if @equip_id.include?(133) #魂之灵瓮
      n+=(power1*$game_variables[197]*0.01).to_i
    end
    for i in @states
      n *= $data_states[i].pdef_rate / 100.0
    end
    return n
  end
  #--------------------------------------------------------------------------
  # ● 获取 角色魔法抵挡
  #--------------------------------------------------------------------------
  def magicdef
    n1 = $game_variables[175]
    a=power3
    if a>500
      a=(a-500)/10
      a=(a*0.03)/(1+0.03*a)*0.4
      n2 = 1*(1-[0.5+a,0.9].min)
    else
      n2 = 1*(1-power3*0.001)
    end
    for i in @equip_id
      if i !=nil && $data_weapons[i]!= nil
        for j in $data_weapons[i].name.split(':')
          if j[0,2]=="MD"
            if j[2,1]=="%"
              n2*=(1-j[3,j.size-3].to_f/100.0)
           else
              n1+=j[2,j.size-2].to_f
            end
          end
        end
      end
    end
    if $game_variables[226]!=0 #天赋开启
      n2*=(1-$game_variables[226][21]*0.05) if $game_variables[226][21]!=nil
    end
    n1 = [n1, 0].max
    return [n1,n2]
  end
  def soul_max #灵魂上限
    n=$game_variables[198]
    n=(n*1.5).to_i if $game_switches[148]
    if $game_variables[285]==0
      eq=@equip_id
    else
      eq=$game_variables[285]
    end
    if eq.include?(122) || $game_party.weapon_number(122)>0
      if $game_variables[181]!=0 && $game_variables[181][122]!=nil
        n+=$game_variables[181][122]*100
      end
    end
    return n
  end
  def soul_max_hard #灵魂上限（高难度下）
    n=$game_variables[198]
    if $game_variables[285]==0
      eq=@equip_id
    else
      eq=$game_variables[285]
    end
    if eq.include?(122) || $game_party.weapon_number(122)>0
      if $game_variables[181]!=0 && $game_variables[181][122]!=nil
        n+=$game_variables[181][122]*100
      end
    end
    return n
  end
  #--------------------------------------------------------------------------
  # ● 获取基本速度
  #--------------------------------------------------------------------------
  def base_agi
    n = $data_actors[@actor_id].parameters[4,1]# @level]
    for i in @equip_id
      n+=$data_weapons[i]!= nil ? $data_weapons[i].agi_plus : 0 if i !=nil
    end
    return [[n, 0].max, 99999].min
  end
  #--------------------------------------------------------------------------
  # ● 获取基本魔力
  #--------------------------------------------------------------------------
  def base_int
    n = $data_actors[@actor_id].parameters[5,1]# @level]
    for i in @equip_id
      n+=$data_weapons[i]!= nil ? $data_weapons[i].int_plus : 0 if i !=nil
    end
    return [[n, 0].max, 999999999999999999999999999999999999].min
  end
  #--------------------------------------------------------------------------
  # ● 获取基本攻击力
  #--------------------------------------------------------------------------
  def base_atk
    n = 0
    for i in @equip_id
      n+=$data_weapons[i]!= nil ? $data_weapons[i].atk_plus : 0 if i !=nil
    end
    return [[n, 0].max, 99999999999999999999999].min
  end
  #--------------------------------------------------------------------------
  # ● 获取基本魔法防御
  #--------------------------------------------------------------------------
  def base_mdef
    n=0
    for i in @equip_id
      n+=$data_weapons[i]!= nil ? $data_weapons[i].mdef_plus : 0 if i !=nil
    end
    return [[n, 0].max, 99999999999999999999999].min
  end
  #--------------------------------------------------------------------------
  # ● 获取基本回避修正
  #--------------------------------------------------------------------------
  def base_eva
     n=0
    for i in @equip_id
      n+=$data_weapons[i]!= nil ? $data_weapons[i].eva : 0 if i !=nil
    end
    return [[n, 0].max, 99999999999999999999999].min
  end
  #buff列表
  #1 极速神符 攻速3倍 闪避率+35%
  #2 奥术神符 魔法伤害+60% 魔法消耗-40%
  #4 双倍神符 普攻伤害*2
  #5 毒素烙印
  #6 诡计之雾
  #7 影刃
  #8 猛毒缠身debuff
  #9 虚弱之诏debuff
  #10 否决烙印debuff
  #11 命运之笔debuff
  def buff
    return $game_variables[232]==0 ? [] : $game_variables[232]
  end
  def add_buff(i,time,lv=nil,maxlv=0,debuff=nil)
    if $game_variables[232]==0
      $game_variables[232]=[]
    end
    for j in $game_variables[232]
      if j[0]==i
        j[2]=[j[2]+lv,maxlv].min if lv !=nil
        j[1]=time
        refresh_buff_effect(j)
        return
      end
    end
    new_buff=[i,time,lv,maxlv,debuff]
    $game_variables[232].push(new_buff)
    refresh_buff_effect(new_buff)
  end
  def add_buff_ex(i,time,lv=nil,maxlv=0,debuff=nil)
    if $game_variables[232]==0
      $game_variables[232]=[]
    end
    for j in $game_variables[232]
      if j[0]==i
        j[2]=[j[2]+lv,maxlv].min if lv !=nil
        j[1]=time+1+j[1]
        refresh_buff_effect(j,j[1]-1)
        return
      end
    end
    new_buff=[i,time+1,lv,maxlv,debuff]
    $game_variables[232].push(new_buff)
    refresh_buff_effect(new_buff,new_buff[1]-1)
  end
  def check_buff(i)
    return false if $game_variables[232]==0
    for j in $game_variables[232]
      return true if j[0]==i
    end
    return false
  end
  def get_buff_lv(i)
    return 0 if $game_variables[232]==0
    for j in $game_variables[232]
      return j[2] if j[0]==i
    end
    return 0
  end
  def get_buff_time(i)
    return 0 if $game_variables[232]==0
    for j in $game_variables[232]
      return j[1] if j[0]==i
    end
    return 0
  end
  def del_buff(i)
    if $game_variables[232]==0
      $game_variables[232]=[]
    end
    for j in $game_variables[232]
      if j[0]==i
        finaldelbuf([j])
        break
      end
    end
  end
  def del_all_buff #不包括debuff
    return if $game_variables[232]==0
    del=[]
    for j in $game_variables[232]
      del.push(j) if j[4]==nil
    end
    finaldelbuf(del)
  end
  def del_all_debuff #清除debuff
    return if $game_variables[232]==0
    del=[]
    for j in $game_variables[232]
      del.push(j) if j[4]
    end
    finaldelbuf(del)
  end
  def update_buff
    if $game_variables[232]!=0
      del=[]
      for j in $game_variables[232]
        if j[1]>0
          j[1]-=1
        end
        if j[1]==0
          del.push(j)
        else
          refresh_buff_effect(j)
        end
      end
      finaldelbuf(del)
    end
  end
  def update_a_buff(i)
    if $game_variables[232]!=0
      del=[]
      for j in $game_variables[232]
        if j[0]==i
          if j[1]>0
            j[1]-=1
          end
          if j[1]==0
            del.push(j)
          end
          break
        end
      end
      finaldelbuf(del)
    end
  end
  def finaldelbuf(del)
    for j in del
      if !$nowbattle
        case j[0]
        when 6,7 #隐身
          $game_player.set_opacity(255)
        when 10 #闭锁
          @equip_id=$game_variables[285].clone
          $game_variables[285]=0
        end
      end
      $game_variables[232].delete(j)
    end
  end
  #刷新BUFF效果
  def refresh_buff_effect(j,lv=-1)
    if !$nowbattle
      if lv<0
        lv=j[1]
      end
      case j[0]
      when 10 #闭锁
        eq=@equip_id
        if $game_variables[285]==0
          $game_variables[285]=eq.clone
        else
          @equip_id=$game_variables[285].clone
          eq=@equip_id
        end
        for k in 0...[(lv-1)/5+1,6].min
          eq[k]=0
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 普通攻击 获取攻击方动画 ID
  #--------------------------------------------------------------------------
  def animation1_id
 #   weapon = $data_weapons[@equip1_id]
  #  return weapon != nil ? weapon.animation1_id : 0
  end
  #--------------------------------------------------------------------------
  # ● 普通攻击 获取对像方动画 ID
  #--------------------------------------------------------------------------
  def animation2_id
   # weapon = $data_weapons[@equip1_id]
   # return weapon != nil ? weapon.animation2_id : 0
  end
  #--------------------------------------------------------------------------
  # ● 获取类名
  #--------------------------------------------------------------------------
  def class_name
    return $data_classes[@class_id].name
  end
  #--------------------------------------------------------------------------
  # ● 获取 EXP 字符串
  #--------------------------------------------------------------------------
  def exp_s
    return @exp_list[@level+1] > 0 ? @exp.to_s : "-------"
  end
  #--------------------------------------------------------------------------
  # ● 获取下一等级的 EXP 字符串
  #--------------------------------------------------------------------------
  def next_exp_s
    return @exp_list[@level+1] > 0 ? @exp_list[@level+1].to_s : "-------"
  end
  #--------------------------------------------------------------------------
  # ● 获取离下一等级还需的 EXP 字符串
  #--------------------------------------------------------------------------
  def next_rest_exp_s
    return @exp_list[@level+1] > 0 ?
      (@exp_list[@level+1] - @exp).to_s : "-------"
  end
  #--------------------------------------------------------------------------
  # ● 更新自动状态
  #     old_armor : 卸下防具
  #     new_armor : 装备防具
  #--------------------------------------------------------------------------
  def update_auto_state(old_armor, new_armor)
    # 强制解除卸下防具的自动状态
    if old_armor != nil and old_armor.plus_state_set.size>0
      for i in old_armor.plus_state_set
        remove_state(i, true)
      end
    end
    # 强制附加装备防具的自动状态
    if new_armor != nil and new_armor.plus_state_set.size>0
      for i in new_armor.plus_state_set
        add_state(i, true)
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 装备固定判定
  #     equip_type : 装备类型
  #--------------------------------------------------------------------------
  def equip_fix?(equip_type)
   # return $data_actors[@actor_id].equip_id[equip_type]
  end
  #--------------------------------------------------------------------------
  # ● 变更装备
  #     equip_type : 装备类型
  #     id    : 武器 or 防具 ID  (0 为解除装备)
  #--------------------------------------------------------------------------
  def equip(equip_type, id, check=false)
      if id == 0 or $game_party.weapon_number(id) > 0
        if equip_id[equip_type]!=nil
         update_auto_state($data_weapons[@equip_id[equip_type]], $data_weapons[id]) 
         $game_party.gain_weapon(@equip_id[equip_type], 1)
        end
        @equip_id[equip_type] = id
        $game_party.lose_weapon(id, 1)
        self.hprate=self.hp.to_f/self.maxhp
        if self.maxsp>0
          self.sprate=self.sp.to_f/self.maxsp
        else
          self.sprate=1
        end
        if $game_variables[285]!=0
          $game_variables[285][equip_type]=id
        end
       # self.hp=(self.maxhp*@hprate).to_i
      #  self.sp=(self.maxsp*@sprate).to_i
      end
  end
  #--------------------------------------------------------------------------
  # ● 可以装备判定
  #     item : 物品
  #--------------------------------------------------------------------------
  def equippable?(item)
    # 武器的情况
    if item.is_a?(RPG::Weapon)
      # 包含当前的职业可以装备武器的场合
      if $data_classes[@class_id].weapon_set.include?(item.id)
        return true
      end
    end
    return false
  end
  #--------------------------------------------------------------------------
  # ● 更改 EXP
  #     exp : 新的 EXP
  #--------------------------------------------------------------------------
  def exp=(exp)
    @exp = [[exp, 999999999999999999999999999999999999].min, 0].max
    # 升级
#    while @exp >= @exp_list[@level+1] and @exp_list[@level+1] > 0
#      @level += 1
      # 学会特技
#      for j in $data_classes[@class_id].learnings
#        if j.level == @level
#          learn_skill(j.skill_id)
#        end
#      end
#    end
    # 降级
#    while @exp < @exp_list[@level]
#      @level -= 1
#    end
    # 修正当前的 HP 与 SP 超过最大值
#    @hp = [@hp, self.maxhp].min
#    @sp = [@sp, self.maxsp].min
  end
  #--------------------------------------------------------------------------
  # ● 更改水品
  #     level : 新的等级
  #--------------------------------------------------------------------------
  def level=(level)
  # 检查上下限
    level = [[level, 999].min, 1].max
    @level += level - self.level#1
    # 更改 EXP
#    self.exp = @exp_list[level]
  end
  #--------------------------------------------------------------------------
  # ● 觉悟特技
  #     skill_id : 特技 ID
  #--------------------------------------------------------------------------
  def learn_skill(skill_id)
    if skill_id > 0 and not skill_learn?(skill_id)
      @skills.push(skill_id)
  #    @skills.sort!
    end
  end
  #--------------------------------------------------------------------------
  # ● 遗忘特技
  #     skill_id : 特技 ID
  #--------------------------------------------------------------------------
  def forget_skill(skill_id)
    @skills.delete(skill_id)
  end
  #--------------------------------------------------------------------------
  # ● 已经学会的特技判定
  #     skill_id : 特技 ID
  #--------------------------------------------------------------------------
  def skill_learn?(skill_id)
    return @skills.include?(skill_id)
  end
  #--------------------------------------------------------------------------
  # ● 可以使用特技判定
  #     skill_id : 特技 ID
  #--------------------------------------------------------------------------
  def skill_can_use?(skill_id)
    if not skill_learn?(skill_id)
      return false
    end
    return super
  end
  #--------------------------------------------------------------------------
  # ● 特技总览
  #--------------------------------------------------------------------------
  def all_skill
    data=[]
    if $game_variables[285]==0
      for i in @equip_id
        if i !=nil && $data_weapons[i]!= nil
          for j in $data_weapons[i].name.split(':')
            if j[0,2]=="SK"
              a=j[2,j.size-2]
              for k in a.split('-')
                data.push(k.to_i)
              end
            end
          end
        end
      end
    end
    for actor in $game_party.actors
      case actor.id
      when 3
        if $game_actors[3].level==3
          data.push(150)
          data.push(151)
          data.push(152)
        end
      when 5
        if $game_actors[5].level==2
          data.push(173)
        end
      when 7
        data.push(200)
        data.push(201)
      end
    end
    #不朽山谷
    data2=@skills.clone
    if @skills.include?(85) && !$game_party.actors.include?($game_actors[4])
      data2.delete(85)
    end
    return data2+data
  end
  #--------------------------------------------------------------------------
  # ● 更改名称
  #     name : 新的名称
  #--------------------------------------------------------------------------
  def name=(name)
    @name = name
  end
  #--------------------------------------------------------------------------
  # ● 更改职业 ID
  #     class_id : 新的职业 ID
  #--------------------------------------------------------------------------
  def class_id=(class_id)
    if $data_classes[class_id] != nil
      @class_id = class_id
      # 避开无法装备的物品
      
    end
  end
  #--------------------------------------------------------------------------
  # ● 更改图形
  #     character_name : 新的角色 文件名
  #     character_hue  : 新的角色 色相
  #     battler_name   : 新的战斗者 文件名
  #     battler_hue    : 新的战斗者 色相
  #--------------------------------------------------------------------------
  def set_graphic(character_name, character_hue, battler_name, battler_hue)
    @character_name = character_name
    @character_hue = character_hue
    @battler_name = battler_name
    @battler_hue = battler_hue
  end
  #--------------------------------------------------------------------------
  # ● 取得战斗画面的 X 坐标
  #--------------------------------------------------------------------------
  def screen_x
    # 返回计算后的队伍 X 坐标的排列顺序
    if self.index != nil
      return self.index * 160 + 80
    else
      return 0
    end
  end
  #--------------------------------------------------------------------------
  # ● 取得战斗画面的 Y 坐标
  #--------------------------------------------------------------------------
  def screen_y
    return 464
  end
  #--------------------------------------------------------------------------
  # ● 取得战斗画面的 Z 坐标
  #--------------------------------------------------------------------------
  def screen_z
    # 返回计算后的队伍 Z 坐标的排列顺序
    if self.index != nil
      return 4 - self.index
    else
      return 0
    end
  end
end
