#==============================================================================
# ◎ Scene_NameA
#------------------------------------------------------------------------------
# ◎ 处理名称输入画面的类。
#------------------------------------------------------------------------------
# 制作者：绿梨子红苹果
# 个人主页：vbgm.9126.com
# E-Mail：xhy.01@163.com
# QQ：42378361
#==============================================================================

class Scene_Name
  #--------------------------------------------------------------------------
  # ● 主处理
  #--------------------------------------------------------------------------
  def main
    # 获取角色
    @actor = $game_actors[$game_temp.name_actor_id]
    # 生成窗口
    @edit_window = Window_NameEdit.new(@actor, $game_temp.name_max_char)
    @input_window = Window_NameInputA.new
    # 初始化输入状态
    @input_state = false
    # 执行过渡
    Graphics.transition
    # 主循环
    loop do
      # 刷新游戏画面
      Graphics.update
      # 刷新输入信息
      Input.update
      # 刷新信息
      update
      # 如果画面切换就中断循环
      if $scene != self
        break
      end
    end
    # 准备过渡
    Graphics.freeze
    # 释放窗口
    @edit_window.dispose
    @input_window.dispose
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面
  #--------------------------------------------------------------------------
  def update
    # 刷新窗口
    @edit_window.update
    @input_window.update
    # 按下 B 键的情况下
    if Input.repeat?(Input::B)
      # 输入状态为真时，退出输入状态并刷新字符
      if @input_state == true
        # 演奏取消 SE
        $game_system.se_play($data_system.cancel_se)
        # 执行操作
        @input_state = false
        @input_window.update_character_table(false)
        @input_window.refresh
        return
      # 输入状态为假时，删除编辑字符
      else
        # 光标位置为 0 的情况下
        if @edit_window.index == 0
          # 演奏冻结 SE
          $game_system.se_play($data_system.buzzer_se)
          return
        end
        # 演奏取消 SE
        $game_system.se_play($data_system.cancel_se)
        # 删除文字
        @edit_window.back
        return
      end
    end
      # 按下 C 键的情况下
    if Input.trigger?(Input::C)
      # 光标位置为 [确定] 的情况下
      if @input_window.character == nil
        # 名称为空的情况下
        if @edit_window.name == ""
          # 还原为默认名称
          @edit_window.restore_default
          # 还原后名称仍为空的情况下
          if @edit_window.name == ""
            # 演奏冻结 SE
            $game_system.se_play($data_system.buzzer_se)
            return
          end
          # 演奏确定 SE
          $game_system.se_play($data_system.decision_se)
          return
        end
        # 更改角色名称
        @actor.name = @edit_window.name
        # 演奏确定 SE
        $game_system.se_play($data_system.decision_se)
        # 切换到地图画面
        $scene = Scene_Map.new
        return
      end
      # 输入状态为假时，进入输入状态并刷新字符
      if @input_state == false
        # 输入窗口指向文字为空时
        if @input_window.character == ""
          # 演奏冻结 SE
          $game_system.se_play($data_system.buzzer_se)
          return
        end
        # 演奏确定 SE
        $game_system.se_play($data_system.decision_se)
        # 执行操作
        @input_state = true
        @input_window.update_character_table(true)
        @input_window.refresh
        return
      # 输入状态为真时，输入编辑字符
      else
        # 光标位置为最大的情况下
        if @edit_window.index == $game_temp.name_max_char
          # 演奏冻结 SE
          $game_system.se_play($data_system.buzzer_se)
          return
        end
        # 文字为空的情况下
        if @input_window.character == ""
          # 演奏冻结 SE
          $game_system.se_play($data_system.buzzer_se)
          return
        end
        # 演奏确定 SE
        $game_system.se_play($data_system.decision_se)
        # 添加文字
        @edit_window.add(@input_window.character)
        return
      end
    end
  end
end
