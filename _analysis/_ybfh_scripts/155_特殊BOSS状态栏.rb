
#==============================================================================
# ■ Window_PlayerDate
#------------------------------------------------------------------------------
# 　显示玩家状态的窗口。
#==============================================================================

class Window_BossStatus < Window_Base
  #--------------------------------------------------------------------------
  # ● 初始化窗口
  #--------------------------------------------------------------------------
  def initialize
    super(0, 0,480, 80)#395)#192，416
    self.contents = Bitmap.new(width - 32, height-32)
    self.z =210
    self.opacity=0
    self.back_opacity =255
    self.visible = false
    @scid=$game_variables[254]
    @sctime=0
    @skill=[0,0,0,0]
    @spr=[]
    @cd=[-100,-100,-100,-100]
    @ct=[-100,-100,-100,-100]
    @var=[0,0,0,0]
    @maxcd=[0,0,0,0]
    @maxct=[0,0,0,0]
    @allcd=0
    @key=[$R_Key_Z,$R_Key_X,$R_Key_C,$R_Key_V]
    @bitmap=RPG::Cache.picture("boss_skill")
    for i in 0...12
      @spr[i]=Sprite.new
      @spr[i].z=1100
      @spr[i].bitmap=@bitmap
      if i>=8
        @spr[i].src_rect=Rect.new(0,0,58,58)
        if $game_variables[246][3]==0
          @spr[i].x=280+i%4*64
        else
          @spr[i].x=250+i%4*64
        end
        @spr[i].y=420
        @spr[i].z=1102
      elsif i>=4
        @spr[i].src_rect=Rect.new(308,0,42,0)
        @spr[i].opacity=0
        if $game_variables[246][3]==0
          @spr[i].x=280+8+i%4*64
        else
          @spr[i].x=250+8+i%4*64
        end
        @spr[i].y=429
        @spr[i].z=1101
      else
        if $game_variables[246][3]==0
          @spr[i].x=280+i*64
        else
          @spr[i].x=250+i*64
        end
        @spr[i].y=420
      end
      @spr[i].x+=28
      @spr[i].visible=false
    end
    @spr[12]=Sprite.new
    @spr[12].z=500
    @spr[12].bitmap=RPG::Cache.picture("scname")
    @spr[12].src_rect=Rect.new(0,7+0*38,200,38)
    @spr[12].ox=100
    @spr[12].x=-200
    @spr[12].oy=19
    @spr[12].visible=false
      
  end
  def is_ct?
    for i in 0...4
      if @ct[i]>-15
        return true
      end
    end
    return false
  end
  #主处理
  def update
    if $game_variables[289]>0
      @allcd=2
      if $game_variables[289]%6==0
        px=$game_player.real_x
        py=$game_player.real_y
        new_anima(px,py,88,0)
      end
      $game_variables[289]-=1
    end
    if !is_ct?
    for i in 0...4
      break if @allcd>0 || $game_temp.message_window_showing
      if Kboard.trigger?(@key[i])
      if @skill[i]>0 && @cd[i]<=0
        px=$game_player.x
        py=$game_player.y
        pd=$game_player.direction
        sx=$game_map.x_with_direction(0, pd)
        sy=$game_map.y_with_direction(0, pd)
        case @skill[i]
        when 1 #Z炮
          @maxcd[i]=80
          @allcd=15
          l=2
          new_anima((px+sx*l)*128,(py+sy*l)*128,42,1,0)
        when 2 #X炮
          @maxcd[i]=100
          @allcd=15
          l=4
          new_anima((px+sx*l)*128,(py+sy*l)*128,42,2,0)
        when 3 #C炮
          @maxcd[i]=120
          @allcd=15
          l=6
          new_anima((px+sx*l)*128,(py+sy*l)*128,42,3,0)
        when 4 #大招
          @maxcd[i]=1000
          @maxct[i]=70
          @allcd=@maxct[i]
          @spr[i+4].color=$mapdamage_obj.getcolor(6)
          @var[i]=$game_actors[1].hp
          Audio.se_play("Audio/SE/se_power0") 
          $game_player.animation_id=19
        end
        @cd[i]=@maxcd[i] if @maxct[i]==0
        @ct[i]=@maxct[i] if @maxct[i]>0
      else
        Audio.se_play("Audio/SE/004-System04") 
      end
      end
    end
    else
      if Kboard.trigger?($R_Key_S) || $game_variables[289]>0
        for i in 0...4
          if @ct[i]>-15
            Audio.se_play("Audio/SE/m魔法-爆气-重-005") 
            @spr[i+4].color=Color.new(255,255,255,0)
            @maxcd[i]/=3
            @cd[i]=@maxcd[i]
            @ct[i]=-100
            @allcd=1
            break
          end
        end
      end
    end
    
    for i in 0...4
      if @skill[i]==4 && @ct[i]>-15
        if (@var[i]-$game_actors[1].hp).to_f/$game_actors[1].maxhp>=0.05
          Audio.se_play("Audio/SE/VX Explosion1") 
          @spr[i+4].color=Color.new(255,255,255,0)
          @cd[i]=@maxcd[i]
          @ct[i]=-100
          @allcd=1
        end
        break
      end
    end
    for i in 0...4
      if @skill[i]>0 && @ct[i]==1
        px=$game_player.x
        py=$game_player.y
        case @skill[i]
        when 4 #大招
          @cd[i]=@maxcd[i]
          @ct[i]=-100
          @allcd=20
          @spr[i+4].color=Color.new(255,255,255,0)
          new_anima(px*128,py*128,60,7,0)
        end
      end
    end
      
    for i in 0...4
      if @skill[i]>0
        if @cd[i]>-15
          @spr[i+4].opacity=155
          if @cd[i]<=0
            l=0
          else
            l=(@cd[i]*38.0/@maxcd[i]).to_i
          end
          @spr[i+4].src_rect.height=l
          @spr[i+4].y=429+(38-l)
          @cd[i]-=1
          if @cd[i]==0
            @spr[i].flash($mapdamage_obj.getcolor(2), 15) 
          end
        elsif @ct[i]>-15
          @spr[i+4].opacity=155
          if @ct[i]<=15
            l=0
          else
            l=(38-(@ct[i]-15)*38.0/(@maxct[i]-15)).to_i
          end
          @spr[i+4].src_rect.height=l
          @spr[i+4].y=429+(38-l)
          @ct[i]-=1
          if @ct[i]==15
            @spr[i].flash($mapdamage_obj.getcolor(2), 15) 
          end
        else
          @spr[i+4].opacity=0
        end
      else
        @spr[i+4].opacity=0
      end
      @spr[i].update
    end
    if @allcd>0
      $game_switches[172]=true
      @allcd-=1
      if @allcd==0
        $game_switches[172]=false
      end
    end
    
    #符卡动画
    if $game_variables[254]!=@scid
      @scid=$game_variables[254]
      if @scid>0
        @spr[12].visible=true
        @sctime=90
        @spr[12].src_rect.y=7+(@scid-1)*38
        @spr[12].zoom_x=4
        @spr[12].zoom_y=@spr[12].zoom_x
        @spr[12].x=400
        @spr[12].y=240
      else
        @spr[12].visible=false
      end
    end
    if @sctime>0
      @sctime-=1
      if @sctime>=70
        @spr[12].zoom_x-=0.15
        @spr[12].zoom_y=@spr[12].zoom_x
        @spr[12].y+=8 
      end
      if @sctime<43
        @spr[12].y-=8
      end
    end
    
  end
  def cd?
    return @allcd>0
  end
  def sprvi(a)
    self.visible=a
    for i in 0...12
      if a
        if @skill[i%4]>0
          @spr[i].visible=a
        else
          @spr[i].visible=false
        end
      else
        @spr[i].visible=a
      end
    end
    @spr[12].visible=a
  end
  def dispose
    super
    for i in 0...13
      @spr[i].dispose
    end
    @spr=nil
  end
  def refresh
    self.contents.clear
    for i in 0...4
      a=$game_variables[246][i]
      if a !=@skill[i]
        @spr[i].src_rect=Rect.new(a%5*58,a/5*58,58,58)
      end
    end
    @skill=$game_variables[246]
    @elife=$game_variables[244]
    @emaxlife=$game_variables[245]
    #change_color(system_color)
    x=24
    y=2
    long=400
    draw_gauge(x,y+10,long, @elife.to_f/@emaxlife, hp_gauge_color1, hp_gauge_color2,20)
    draw_text_ex(x+4,y-4, 100, line_height, "敌方生命",system_color)
    if @elife == 0
      cr=knockout_color
    elsif @elife < @emaxlife / 4
      cr=crisis_color 
    else
      cr=normal_color
    end
    draw_current_and_rate(x-100, y+3, long-50,  @elife,@emaxlife,cr, normal_color)
  end
  
  def judge#用于判断是否数据变更，节约内存
    return true if @elife!=$game_variables[244]
    return true if @emaxlife!=$game_variables[245]
    return false
  end
end