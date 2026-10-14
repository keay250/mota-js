#==============================================================================
# ■ Scene_Equip
#------------------------------------------------------------------------------
# 　处理装备画面的类。
#==============================================================================

class Scene_Equip
  #--------------------------------------------------------------------------
  # ● 初始化对像
  #     actor_index : 角色索引
  #     equip_index : 装备索引
  #--------------------------------------------------------------------------
  def initialize(actor_index = 0, equip_index = 0)
    @actor_index = actor_index
    @equip_index = equip_index
  end
  #--------------------------------------------------------------------------
  # ● 主处理
  #--------------------------------------------------------------------------
  def main
    # 获取角色
    $game_variables[181]=[] if $game_variables[181]==0
    @save_index=0
    @actor = $game_party.actors[@actor_index]
    # 生成窗口
    @help_window = Window_EquipHelp.new
    @left_window = Window_EquipLeft.new(@actor,@actor_index)
    @right_window = Window_EquipRight.new(@actor)
    @item_window = Window_EquipItem.new(@actor, 0)
    # 关联帮助窗口
    @right_window.help_window = @help_window
    @item_window.help_window = @help_window
    # 设置光标位置
    @right_window.index = @equip_index
    # 执行过渡
    refresh
    Graphics.transition
    # 主循环
    loop do
      # 刷新游戏画面
      Graphics.update
      # 刷新输入信息
      Input.update
      # 刷新画面
      update
      # 如果画面切换的话的就中断循环
      if $scene != self
        break
      end
    end
    $game_actors[$game_variables[1]+1].hprate=$game_actors[$game_variables[1]+1].hp.to_f/$game_actors[$game_variables[1]+1].maxhp
    if $game_actors[$game_variables[1]+1].maxsp>0
      $game_actors[$game_variables[1]+1].sprate=$game_actors[$game_variables[1]+1].sp.to_f/$game_actors[$game_variables[1]+1].maxsp
    else
      $game_actors[$game_variables[1]+1].sprate=1
    end
    # 准备过渡
    Graphics.freeze
    # 释放窗口
    @help_window.dispose
    @left_window.dispose
    @right_window.dispose
    @item_window.dispose
  end
  #--------------------------------------------------------------------------
  # ● 刷新
  #--------------------------------------------------------------------------
  def refresh
    # 设置物品窗口的可视状态
    @item_window.visible = true
    # 获取当前装备中的物品
    item1 = @right_window.item
    # 设置当前的物品窗口到 @item_window
    # 右窗口被激活的情况下
    if @save_right_active !=@right_window.active
      if @right_window.active
        # 删除变更装备后的能力
        @left_window.set_new_parameters(nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil)
      end
      @save_right_active=@right_window.active
    end
    # 物品窗口被激活的情况下
    if @item_window.active && @save_item_index !=@item_window.item
      # 获取现在选中的物品
      @save_item_index=@item_window.item
      item2 = @item_window.item
      # 变更装备
      last_hp = @actor.hp
      last_sp = @actor.sp
      @actor.equip(@right_window.index, item2 == nil ? 0 : item2.id)
      # 获取变更装备后的能力值
      new_atk = @actor.str
      new_pdef = @actor.dex
      new_mdef = @actor.int
      new_maxhp = @actor.maxhp
      new_maxsp = @actor.maxsp
      new_power1 = @actor.power1
      new_power2 = @actor.power2
      new_power3 = @actor.power3
      new_hpre = @actor.hprecover
      new_mp = @actor.sprecover
      new_atkspe = @actor.atkspeed
      new_shield = @actor.shield
      new_magicdef = @actor.magicdef
      new_miss = @actor.miss
      # 返回到装备
      @actor.equip(@right_window.index, item1 == nil ? 0 : item1.id)
      @actor.hp = last_hp
      @actor.sp = last_sp
      # 描画左窗口
      @left_window.set_new_parameters(new_atk, new_pdef, new_mdef,new_maxhp,new_maxsp, \
      new_power1,new_power2,new_power3,new_hpre,new_mp,new_atkspe,new_shield,new_magicdef,\
      new_miss)
    end
    if !@item_window.active
      @save_item_index=0
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面
  #--------------------------------------------------------------------------
  def update
    # 刷新窗口
    @left_window.update
    @right_window.update
    @item_window.update
    @item_window.help_window.update
    refresh
    # 右侧窗口被激活的情况下: 调用 update_right
    if @right_window.active
      update_right
      if Kboard.press?($game_config.data("keyboard")[2])
        for i in 48...58
          if Kboard.trigger?(i)
            @item_window.setsave(i-48)
            if $game_variables[174]==0
              $game_variables[174]=[]
            end
            if $game_variables[174][$game_variables[1]]==nil
              $game_variables[174][$game_variables[1]]=[]
            end
            $game_system.se_play($data_system.equip_se)
            $game_variables[174][$game_variables[1]][i-48]=@actor.equip_id.clone
            break
          end
        end
      end
      return
    end
    # 物品窗口被激活的情况下: 调用 update_item
    if @item_window.active
      update_item
      return
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面 (右侧窗口被激活的情况下)
  #--------------------------------------------------------------------------
  def update_right
    # 按下 B 键的情况下
    if Input.trigger?(Input::B) || Kboard.trigger?($game_config.data("keyboard")[0])
      # 演奏取消 SE
      $game_system.se_play($data_system.cancel_se)
      # 切换到菜单画面

     #楼层怪物刷新
      $scene = Scene_Map.new

#      $scene = Scene_Menu.new(1)
      return
    end
    # 按下 C 键的情况下
    if Input.trigger?(Input::C)
      # 固定装备的情况下
      if equip_fix?(@actor.equip_id[@right_window.index])
        # 演奏冻结 SE
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      # 演奏确定 SE
      $game_system.se_play($data_system.decision_se)
      # 激活物品窗口
      @right_window.active = false
      @item_window.active = true
      @item_window.index = 0
      return
    end
    if Input.trigger?(Input::C)
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面 (物品窗口被激活的情况下)
  #--------------------------------------------------------------------------
  def update_item
    # 按下 B 键的情况下
    if Input.trigger?(Input::B)
      # 演奏取消 SE
      $game_system.se_play($data_system.cancel_se)
      # 激活右侧窗口
      @right_window.active = true
      @item_window.active = false
      @item_window.index = -1
      return
    end
    if Kboard.trigger?($game_config.data("keyboard")[0])
      # 演奏取消 SE
      $game_system.se_play($data_system.cancel_se)
      # 切换到菜单画面
      $scene = Scene_Map.new
      return
    end
    # 按下 C 键的情况下
    if Input.trigger?(Input::C)
      # 获取物品窗口现在选择的装备数据
      item = @item_window.item
      if @item_window.index==@item_window.get_size-3
        # 演奏确定 SE
        $game_system.se_play($data_system.decision_se)
        # 保存套装
        $game_variables[12]=@actor.equip_id
        $scene = Scene_Suit.new(1)
        return
      end
      if @item_window.index==@item_window.get_size-2
        # 演奏确定 SE
        $game_system.se_play($data_system.decision_se)
        # 使用装备
        $game_variables[12]=@actor.equip_id[@right_window.index]
        $game_temp.common_event_id = 39
        $scene = Scene_Map.new
        return
      end
      # 演奏装备 SE
      $game_system.se_play($data_system.equip_se)
      # 变更装备
      if @item_window.index==@item_window.get_size-1
        @actor.equip(@right_window.index,0)
      end
      @actor.equip(@right_window.index, item == nil ? 0 : item.id)
      if @actor.hp>@actor.maxhp
        @actor.hp=@actor.maxhp
      end
      if @actor.sp>@actor.maxsp
        @actor.sp=@actor.maxsp
      end
      # 激活右侧窗口
      @right_window.active = true
      @item_window.active = false
      @item_window.index = -1
      # 再生成右侧窗口、物品窗口的内容
      @right_window.refresh
      @item_window.refresh
      return
    end
  end
  def equip_fix?(i)
    return true if $game_switches[142]
    case i
    when 39
      return  $game_switches[142]
    end
    return false
  end
end
