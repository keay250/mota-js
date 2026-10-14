#==============================================================================
# ■ Window_PlayerDate
#------------------------------------------------------------------------------
# 　显示玩家状态的窗口。
#==============================================================================

class Window_PlayerDate2 < Window_Base
  #--------------------------------------------------------------------------
  # ● 初始化窗口
  #--------------------------------------------------------------------------
  def initialize
    super(640, 0, 180, 480)
    self.contents = Bitmap.new(width - 32, height - 32)
    self.z =210
    self.opacity=0
    self.back_opacity =255
    self.visible = false
    @spr=[]
    for i in 0...10
      @spr[i]=Sprite.new
      @spr[i].bitmap=Bitmap.new(80,80)
      j=0.5
      @spr[i].x=self.x+26+i%3*80*j
      @spr[i].y=55+i/3*80*j
      @spr[i].z=209
      @spr[i].zoom_x=j
      @spr[i].zoom_y=@spr[i].zoom_x
      @spr[i].visible = false
    end
    for i in 10...16
      k=i-10
      @spr[i]=Sprite.new
      @spr[i].bitmap=Bitmap.new(80,80)
      j=0.5
      @spr[i].x=self.x+26+k%3*100*j
      @spr[i].y=262+k/3*90*j
      @spr[i].z=209
      @spr[i].zoom_x=j
      @spr[i].zoom_y=@spr[i].zoom_x
      @spr[i].visible = false
    end
    @espr=[]
    for i in 0...6
      @espr[i]=Sprite.new
      @espr[i].bitmap=Bitmap.new(1,1)
      @espr[i].x=self.x+22+i%3*86*0.5
      @espr[i].y=350+i/3*64*0.5
      @espr[i].z=209
      @espr[i].zoom_x=0.5
      @espr[i].zoom_y=@espr[i].zoom_x
      @espr[i].visible = false
    end
    refresh
  end  
  def resetsprx
    j=0.5
    for i in 0...10
      @spr[i].x=self.x+26+i%3*80*j
    end
    for i in 10...16
      k=i-10
      @spr[i].x=self.x+26+k%3*100*j
    end
    for i in 0...6
      @espr[i].x=self.x+22+i%3*86*0.5
    end
    j=10
    for i in $game_actors[$game_variables[1]+1].all_skill
      if $data_skills[i].scope==3
        j+=1
      end
    end
    case j
    when 11
      @spr[10].x=self.x+69
    when 12
      @spr[10].x=self.x+39
      @spr[11].x=self.x+99
    when 13
      @spr[10].x=self.x+26
      @spr[11].x=self.x+69
      @spr[12].x=self.x+112
    end
  end
  def sprvi(sw)
    for i in 0...16
      @spr[i].visible=sw
    end
    for i in 0...6
      @espr[i].visible=sw
    end
  end
  def dispose
    super
    for i in 0...16
      @spr[i].bitmap.dispose if @spr[i].bitmap!=nil
      @spr[i].dispose
    end
    for i in 0...6
      @espr[i].bitmap.dispose if @espr[i].bitmap!=nil
      @espr[i].dispose
    end
  end
  def refresh
    self.contents.clear
    for i in 0...16
      @spr[i].bitmap=nil
    end
    for i in 0...6
      @espr[i].bitmap=nil
    end
    x=0
    y=10
    self.contents.font.size=22
    self.contents.font.color = system_color
    self.contents.draw_text(x+3,y, 140, 24, "技能组合", 1)
    @xequip=$game_actors[$game_variables[1]+1].equip_id.clone
    @xskill=$game_variables[183]
    j=0
    if $game_switches[120]
      for i in $game_variables[183]
        if i !=0
          @spr[j].bitmap=RPG::Cache.icon($data_skills[i].icon_name)
          if $game_actors[$game_variables[1]+1].all_skill.include?(i)
            @spr[j].color=$mapdamage_obj.getcolor(8)
          else
            @spr[j].color=$mapdamage_obj.getcolor(7)
          end
        end
        j+=1
      end
    end
    
    y=205
    self.contents.draw_text(x+3,y,140, 24, "被动技能", 1)
    j=10
    for i in $game_actors[$game_variables[1]+1].all_skill
      if $data_skills[i].scope==3
        @spr[j].bitmap=RPG::Cache.icon($data_skills[i].icon_name)
        if $tuihua==false
          @spr[j].color=$mapdamage_obj.getcolor(8)
        else
          @spr[j].color=$mapdamage_obj.getcolor(7)
        end
        j+=1
      end
    end
    case j
    when 11
      @spr[10].x=self.x+69
    when 12
      @spr[10].x=self.x+39
      @spr[11].x=self.x+99
    when 13
      @spr[10].x=self.x+26
      @spr[11].x=self.x+69
      @spr[12].x=self.x+112
    end
    j=10
    for i in $game_actors[$game_variables[1]+1].all_skill
      sx=@spr[j].x-(self.x+42)
      sy=@spr[j].y
      if $data_skills[i].name[0,12]=="灵魂支配"
        self.contents.font.size=18
        str=$game_variables[197].to_s
        self.contents.font.color = text_color(8)
        self.contents.draw_text(sx-1,sy-1, 64, 32, str,2)
        self.contents.draw_text(sx+1,sy-1, 64, 32, str,2)
        self.contents.draw_text(sx-1,sy+1, 64, 32, str,2)
        self.contents.draw_text(sx+1,sy+1, 64, 32, str,2)
        self.contents.font.color = text_color(2)
        self.contents.draw_text(sx,sy, 64, 32, str,2)
        self.contents.font.size=22
        self.contents.font.color = system_color
      end
      if $game_variables[284]==i #开关光环技能
        if $game_switches[69]
          @spr[j].color=$mapdamage_obj.getcolor(8)
        else
          @spr[j].color=$mapdamage_obj.getcolor(7)
        end
      end
      j+=1 if $data_skills[i].scope==3
    end
    
    y=305
    self.contents.draw_text(x+3,y,140, 24, "当前装备", 1)
    
    j=0
    data=[]
    if $game_variables[285]==0 #正常装备栏
      equip=$game_actors[$game_variables[1]+1].equip_id
    else
      equip=$game_variables[285]
    end
    for i in equip
      if i !=nil && i !=0
        if $game_variables[285]!=0 && j<=($game_actors[$game_variables[1]+1].get_buff_time(10)-1)/5
          @espr[j].color=$mapdamage_obj.getcolor(7)
          self.contents.font.size=15
          self.contents.font.color = normal_color
          self.contents.draw_text(6+j%3*43,345+j/3*32, 42, 32, "闭锁中",2)
          j+=1
          next
        else
          @espr[j].color=$mapdamage_obj.getcolor(8)
        end
        if i==39 && $game_switches[142]
          self.contents.font.size=15
          self.contents.font.color = normal_color
          self.contents.draw_text(6+j%3*43,345+j/3*32, 42, 32, "冷却中",2)
          j+=1
          next
        end
        if $game_variables[181][i]!=nil && $game_variables[181][i]!=0 && !data.include?(i)
          data.push(i)
          self.contents.font.size=15
          self.contents.font.color = normal_color
          if $game_variables[181][i]==-1
            self.contents.draw_text(16+j%3*43,345+j/3*32, 32, 32, "开启",2)
          else
            self.contents.draw_text(16+j%3*43,345+j/3*32, 32, 32, $game_variables[181][i].to_s,2)
          end
          if i==74 && $game_switches[159]
            self.contents.draw_text(16+j%3*43,327+j/3*32, 32, 32, "开启",2)
          end
        end
      end
      j+=1
    end
    j=0
    for i in equip
      if i !=nil && i !=0
        @espr[j].bitmap=RPG::Cache.icon($data_weapons[i].icon_name)
      end
      j+=1
    end
    y=415
    self.contents.font.size=22
    if $game_switches[65]
      self.contents.font.color = text_color(6)
      self.contents.draw_text(x,y, 140, 24, "作弊模式", 1)
    else
      if $game_switches[168]
        self.contents.font.color = text_color(5)
        self.contents.draw_text(x,y, 140, 24, "挑战模式", 1)
      else
        case $game_variables[177]
        when 0
          self.contents.font.color = text_color(2)
          self.contents.draw_text(x,y, 140, 24, "传奇史诗", 1)
        when 1
          self.contents.font.color = text_color(4)
          self.contents.draw_text(x,y, 140, 24, "冒险篇章", 1)
        when 2
          self.contents.font.color = text_color(3)
          self.contents.draw_text(x,y, 140, 24, "初心试炼", 1)
        end
      end
     end
      
  end
  def judge
    return true if @xequip !=$game_actors[$game_variables[1]+1].equip_id
    return true if @xskill !=$game_variables[183]
    return true if $game_switches[56]
    return false
  end
end