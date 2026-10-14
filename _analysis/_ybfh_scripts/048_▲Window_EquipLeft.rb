#==============================================================================
# ■ Window_EquipLeft
#------------------------------------------------------------------------------
# 　装备画面的、显示角色能力值变化的窗口。
#==============================================================================

class Window_EquipLeft < Window_Base
  #--------------------------------------------------------------------------
  # ● 初始化对像
  #     actor : 角色
  #--------------------------------------------------------------------------
  def initialize(actor,actor_index)
    super(240, 240, 336, 240)
    self.contents = Bitmap.new(width - 32, height - 32)
    @actor = actor
    @actor_index = actor_index
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 刷新
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    def fuck(i)
      return "0" if i==0
      len=(i.abs.to_s).length
      len=[(len-4)/4,0].max
      return (i/(10**(len*4))).to_s+$shuwei[len+$game_variables[148]]
    end
    old_x=16
    draw_actor_graphic($game_party.actors[@actor_index], 211+old_x, 44)
    self.contents.font.size=22
    draw_actor_level(@actor, +old_x, 0)
    x=old_x;y=34
    self.contents.font.size=20
    self.contents.font.color = system_color
    self.contents.draw_text(x, y, 120, 32, "生命")
    self.contents.font.color = normal_color
    self.contents.draw_text(x+33, y, 90, 32,fuck(@actor.hp), 2)
    self.contents.draw_text(x+130, y, 90, 32,"/", 0)
    self.contents.draw_text(x+140, y, 90, 32,fuck(@actor.maxhp), 0)
    if @new_maxhp != nil
      self.contents.font.size=14
      if @new_maxhp>@actor.maxhp#角色的生命上限
        self.contents.font.color = text_color(3)
        self.contents.draw_text(x+140, y+16, 90, 32, fuck(@new_maxhp), 0)
      else
        if @new_maxhp<@actor.maxhp
          self.contents.font.color = text_color(9)
          self.contents.draw_text(x+140, y+16, 90, 32, fuck(@new_maxhp), 0)
        end
      end
=begin
      if @new_maxhp>@actor.maxhp
        self.contents.font.color = text_color(3)
        self.contents.draw_text(x+33, y+16, 90, 32, fuck((@new_maxhp*@actor.hprate).to_i), 2)
      end
      if @new_maxhp<@actor.maxhp
        self.contents.font.color = text_color(9)
        self.contents.draw_text(x+33, y+16, 90, 32, fuck((@new_maxhp*@actor.hprate).to_i), 2)
      end
=end
      if @new_maxhp<@actor.hp
        self.contents.font.color = text_color(9)
        self.contents.draw_text(x+33, y+16, 90, 32, fuck(@new_maxhp.to_i), 2)
      end
    end
    if @new_hpre != nil
      self.contents.font.size=14
      str=fuck(@new_hpre.to_i)+""
      if @new_hpre>=0
        str="+"+str
      end
      if @new_hpre>@actor.hprecover#角色的生命上限
        self.contents.font.color = text_color(3)
        self.contents.draw_text(x+178, y+16, 90, 32, str, 2)
      else
        if @new_hpre<@actor.hprecover
          self.contents.font.color = text_color(9)
          self.contents.draw_text(x+178, y+16, 90, 32, str, 2)
        end
      end
    end
    self.contents.font.size=15
    if @actor.hprecover>=0
      self.contents.font.color = text_color(3)
      self.contents.draw_text(x+178, y, 90, 32,"+"+@actor.hprecover.to_i.to_s+"", 2)
    else
      self.contents.font.color = text_color(9)
      self.contents.draw_text(x+178, y, 90, 32,@actor.hprecover.to_i.to_s+"", 2)
    end
    x=old_x;y=68
    self.contents.font.size=20
    self.contents.font.color = system_color
    self.contents.draw_text(x, y, 120, 32, "魔法")
    self.contents.font.color = normal_color
    self.contents.draw_text(x+33, y, 90, 32,fuck(@actor.sp), 2)
    self.contents.draw_text(x+130, y, 90, 32,"/", 0)
    self.contents.draw_text(x+140, y, 90, 32,fuck(@actor.maxsp), 0)
    if @new_maxsp != nil
      self.contents.font.size=14
      if @new_maxsp>@actor.maxsp#角色的魔法上限
        self.contents.font.color = text_color(3)
        self.contents.draw_text(x+140, y+16, 90, 32, fuck(@new_maxsp), 0)
      else
        if @new_maxsp<@actor.maxsp
          self.contents.font.color = text_color(9)
          self.contents.draw_text(x+140, y+16, 90, 32, fuck(@new_maxsp), 0)
        end
      end
        if @new_maxsp>0
          a=@actor.sprate
        else
          a=1
        end
=begin
      if @new_maxsp>@actor.maxsp
        self.contents.font.color = text_color(3)
        self.contents.draw_text(x+33, y+16, 90, 32, fuck((@new_maxsp*a).to_i), 2)
      end
      if @new_maxsp<@actor.maxsp
        self.contents.font.color = text_color(9)
        self.contents.draw_text(x+33, y+16, 90, 32, fuck((@new_maxsp*a).to_i), 2)
      end
=end
      if @new_maxsp<@actor.sp
        self.contents.font.color = text_color(9)
        self.contents.draw_text(x+33, y+16, 90, 32, fuck(@new_maxsp.to_i), 2)
      end
    end
    if @new_mp != nil
      self.contents.font.size=14
      str=sprintf("%.2f",@new_mp)+""
      if @new_mp>=0 
        str="+"+str
      end
      if @new_mp>@actor.sprecover#角色的生命上限
        self.contents.font.color = text_color(3)
        self.contents.draw_text(x+178, y+16, 90, 32, str, 2)
      else
        if @new_mp<@actor.sprecover
          self.contents.font.color = text_color(9)
          self.contents.draw_text(x+178, y+16, 90, 32, str, 2)
        end
      end
    end
    self.contents.font.size=15
    if @actor.sprecover>=0
      self.contents.font.color = text_color(1)
      self.contents.draw_text(x+178, y, 90, 32,"+"+sprintf("%.2f",@actor.sprecover)+"", 2)
    else
      self.contents.font.color = text_color(9)
      self.contents.draw_text(x+178, y, 90, 32,sprintf("%.2f",@actor.sprecover)+"", 2)
    end
    
if $game_variables[154]>0
    x=old_x;y=102
    self.contents.font.color = system_color
    self.contents.font.size=18
    self.contents.font.color = text_color(9)# if $game_variables[154]==1
    self.contents.draw_text(x, y, 120, 32, "力量")
    self.contents.font.color = system_color
    self.contents.font.color = text_color(3)# if $game_variables[154]==2
    self.contents.draw_text(x+90, y, 120, 32, "敏捷")
    self.contents.font.color = system_color
    self.contents.font.color = text_color(1)# if $game_variables[154]==3
    self.contents.draw_text(x+180, y, 120, 32, "智力")
    self.contents.font.color = normal_color
    if @new_power1 != nil
      if @new_power1>@actor.power1#角色的力量
        self.contents.font.color = text_color(3)
      else
        if @new_power1<@actor.power1
          self.contents.font.color = text_color(9)
        end
      end
      self.contents.draw_text(x+20, y, 90, 32,fuck(@new_power1), 1)
    else
      self.contents.draw_text(x+20, y, 90, 32,fuck(@actor.power1), 1)
    end
    self.contents.font.color = normal_color
    if @new_power2 != nil
      if @new_power2>@actor.power2#角色的敏捷
        self.contents.font.color = text_color(3)
      else
        if @new_power2<@actor.power2
          self.contents.font.color = text_color(9)
        end
      end
      self.contents.draw_text(x+110, y, 90, 32,fuck(@new_power2), 1)
    else
      self.contents.draw_text(x+110, y, 90, 32,fuck(@actor.power2), 1)
    end
    self.contents.font.color = normal_color
    if @new_power3 != nil
      if @new_power3>@actor.power3#角色的智力
        self.contents.font.color = text_color(3)
      else
        if @new_power3<@actor.power3
          self.contents.font.color = text_color(9)
        end
      end
      self.contents.draw_text(x+200, y, 90, 32,fuck(@new_power3), 1)
    else
      self.contents.draw_text(x+200, y, 90, 32,fuck(@actor.power3), 1)
    end
end
    x=old_x;y=128
    self.contents.font.color = system_color
    self.contents.font.size=18
    self.contents.draw_text(x, y, 120, 32, "攻击")
    self.contents.draw_text(x+135, y, 120, 32, "防御")
    self.contents.font.color = normal_color
    self.contents.draw_text(x+40, y, 90, 32,fuck(@actor.str), 1)
    self.contents.draw_text(x+175, y, 90, 32,fuck(@actor.dex), 1)
    
    if @new_atk != nil
      self.contents.font.size=14
      if @new_atk>@actor.str#角色的攻击
        self.contents.font.color = text_color(3)
    self.contents.draw_text(x+40,y+16, 90, 32, fuck(@new_atk), 1)
      else
        if @new_atk<@actor.str
          self.contents.font.color = text_color(9)
    self.contents.draw_text(x+40,y+16, 90, 32, fuck(@new_atk), 1)
        end
      end
    end
    if @new_pdef != nil#角色的防御
      self.contents.font.size=14
      if @new_pdef>@actor.dex
        self.contents.font.color = text_color(3)
    self.contents.draw_text(x+175,y+16, 90, 32, fuck(@new_pdef), 1)
      else
        if @new_pdef<@actor.dex
          self.contents.font.color = text_color(9)
    self.contents.draw_text(x+175,y+16, 90, 32, fuck(@new_pdef), 1)
        end
      end
    end
    
    x=old_x;y=170
    self.contents.font.color = system_color
    self.contents.font.size=18
    self.contents.draw_text(x, y-9, 120, 32, "攻速")
    self.contents.draw_text(x, y+14, 120, 32, "闪避")
    self.contents.draw_text(x+135, y-9, 120, 32, "护甲")
    self.contents.draw_text(x+135, y+14, 120, 32, "魔抗")
    self.contents.font.color = normal_color
    if @new_atkspe != nil
      if @new_atkspe>@actor.atkspeed#角色的攻击
        self.contents.font.color = text_color(3)
      else
        if @new_atkspe<@actor.atkspeed
          self.contents.font.color = text_color(9)
        end
      end
      self.contents.draw_text(x+40, y-9, 90, 32,fuck(@new_atkspe)+"%", 1)
    else
      self.contents.draw_text(x+40, y-9, 90, 32,fuck(@actor.atkspeed)+"%", 1)
    end
    self.contents.font.color = normal_color
    if @new_shield != nil#角色的防御
      if @new_shield>@actor.shield
        self.contents.font.color = text_color(3)
      else
        if @new_shield<@actor.shield
          self.contents.font.color = text_color(9)
        end
      end
      self.contents.draw_text(x+175, y-9, 90, 32,fuck(@new_shield), 1) 
    else
      self.contents.draw_text(x+175, y-9, 90, 32,fuck(@actor.shield), 1) 
    end
    self.contents.font.color = normal_color
    if @new_miss != nil#角色的防御
      if @new_miss>@actor.miss
        self.contents.font.color = text_color(3)
      else
        if @new_miss<@actor.miss
          self.contents.font.color = text_color(9)
        end
      end
      self.contents.draw_text(x+40, y+14, 90, 32,sprintf("%.1f",@new_miss*100)+"%", 1)
    else
      self.contents.draw_text(x+40, y+14, 90, 32,sprintf("%.1f",@actor.miss*100)+"%", 1)
    end
    self.contents.font.color = normal_color
    if @new_magicdef != nil#角色的防御
      if @new_magicdef[1]<@actor.magicdef[1] || @new_magicdef[0]>@actor.magicdef[0]
        self.contents.font.color = text_color(3)
      else
        if @new_magicdef[1]>@actor.magicdef[1] || @new_magicdef[0]<@actor.magicdef[0]
          self.contents.font.color = text_color(9)
        end
      end
      self.contents.draw_text(x+165, y+14, 120, 32,sprintf("%.1f",(1-@new_magicdef[1])*100)+"%+"+@new_magicdef[0].to_i.to_s, 1)
    else
      self.contents.draw_text(x+165, y+14, 120, 32,sprintf("%.1f",(1-@actor.magicdef[1])*100)+"%+"+@actor.magicdef[0].to_i.to_s, 1)
    end
  end
  #--------------------------------------------------------------------------
  # ● 变更装备后的能力值设置
  #     new_atk  : 变更装备后的攻击力
  #     new_pdef : 变更装备后的物理防御
  #     new_mdef : 变更装备后的魔法防御
  #--------------------------------------------------------------------------
  def set_new_parameters(new_atk, new_pdef, new_mdef, new_maxhp, new_maxsp,\
    new_power1,new_power2,new_power3, new_hpre, new_mp,new_atkspe,new_shield,\
    new_magicdef,new_miss)
    if @new_atk != new_atk or @new_pdef != new_pdef or @new_mdef != new_mdef \
       or @new_maxhp != new_maxhp or @new_maxsp != new_maxsp or @new_power1 != new_power1 \
       or @new_power2 != new_power2 or @new_power3 != new_power3 or @new_hpre != new_hpre \
       or @new_mp != new_mp or @new_shield != new_shield or @new_atkspe != new_atkspe\
       or @new_magicdef != new_magicdef or @new_miss != new_miss
       
      @new_atk = new_atk
      @new_pdef = new_pdef
      @new_mdef = new_mdef
      @new_maxhp= new_maxhp
      @new_maxsp= new_maxsp
      @new_power1= new_power1
      @new_power2= new_power2
      @new_power3= new_power3
      @new_hpre= new_hpre
      @new_mp= new_mp
      @new_atkspe =new_atkspe
      @new_shield =new_shield
      @new_magicdef = new_magicdef
      @new_miss = new_miss
      refresh
    end
  end
end
