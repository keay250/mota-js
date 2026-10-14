class Sprite_Bullet < Sprite
  attr_accessor   :time
  attr_accessor   :rx
  attr_accessor   :ry
  attr_accessor   :rangle
  attr_accessor   :kind
  attr_accessor   :speed
  attr_accessor   :damage
  attr_accessor   :dead
  #--------------------------------------------------------------------------
  # ● 初始化对象
  #--------------------------------------------------------------------------
  def initialize(viewport,id)
    super(viewport)
    @rx=0
    @ry=0
    @id=id
    @rangle=0
    @time=0
    @kind=0
    @speed=0
    @damage=0
    @dead=true
    @bit_id=0
    @var=0
  end
  def reset(bitmap,rect,x,y,z,zoom_x,zoom_y,angle,speed,kind,damage,var=0)
    @dead=false
    self.bitmap=bitmap
    case bitmap
    when RPG::Cache.picture("bullet1")
      @bit_id=1
    when RPG::Cache.picture("bullet2")
      @bit_id=2
    end
    self.src_rect=rect
    self.visible=true
    @rx=x
    @ry=y
    self.z=z
    while angle>360 do
      angle-=360
    end
    while angle<0 do
      angle+=360
    end
    @rangle=angle%360
    self.angle=360-@rangle
    @speed=speed
    @kind=kind
    self.opacity=255
    if @kind==1
      self.opacity=205
    end
    if @kind<=3 && @kind !=1
      self.zoom_x=zoom_x*1.2
      self.zoom_y=zoom_y*1.2
    end
    if @kind>=2
      self.blend_type=1
    else
      self.blend_type=0
    end
    @time=0
    @var=var
    @damage=damage
    self.ox=rect.width/2
    self.oy=rect.height/2
  end
  #--------------------------------------------------------------------------
  # ● 释放
  #--------------------------------------------------------------------------
  def dispose
    super
  end
  def screen_x
    return (@rx - $game_map.display_x + 3) / 4 +16
  end
  def screen_y
    y = (@ry - $game_map.display_y + 3) / 4 + 16
    return y
  end
  #--------------------------------------------------------------------------
  # ● 更新画面
  #--------------------------------------------------------------------------
  def update
    super
    @dead=true if $game_switches[174]
    if @dead
      self.zoom_x-=0.1
      self.zoom_y-=0.1
      if self.zoom_x<=0
        self.zoom_x=0
      end
      return
    end
    @time+=1
    @rx+=$movex[(@rangle*10).to_i]*@speed*4
    @ry+=$movey[(@rangle*10).to_i]*@speed*4
    $game_variables[250][@id][2]=@rx
    $game_variables[250][@id][3]=@ry
    
    case @kind
    when 1 #发弹效果
      if self.zoom_x>1.0 && self.opacity>=10
        self.zoom_x-=0.1;self.zoom_y-=0.1;self.opacity-=10
      end
      if @time>=24
        @dead=true
        self.zoom_x=0
      end
    when 2 #神枪
      if @time<=60
        px=$game_player.real_x
        py=$game_player.real_y-24
        self.angle=360-bullet_fllow(@rx,@ry,px,py)
      elsif @time<=100
        @rx+=$movex[((540-self.angle)%360*10).to_i]*3
        @ry+=$movey[((540-self.angle)%360*10).to_i]*3
      elsif @time<=140
        for i in 0...3
          @rx+=$movex[((360-self.angle)%360*10).to_i]*60
          @ry+=$movey[((360-self.angle)%360*10).to_i]*60
          xx=(self.x-$game_player.screen_x).abs-3
          yy=(self.y-$game_player.screen_y+22).abs-3
          if xx*xx+yy*yy<=400
            @time=300
            $game_player.animation_id=44
            if @damage*(1+$game_variables[253])>=$game_actors[1].hp
              $game_variables[19]=1
              $game_actors[1].hp-=@damage*(1+$game_variables[253])
              $game_temp.common_event_id =12#生命小于0，调用1号结局
            else
              $game_actors[1].hp-=@damage*(1+$game_variables[253])
              Audio.se_play("Audio/SE/VX Slash8",80)
            end
            break
          end
        end
      elsif @time<=310
        self.opacity-=25
        if self.opacity<=10
          @dead=true
          self.visible=false
        end
      end
    when 3 #神枪2
      if @time<=20
        px=$game_player.real_x
        py=$game_player.real_y-24
      elsif @time<=40
        @rx+=$movex[((540-self.angle)%360*10).to_i]*3
        @ry+=$movey[((540-self.angle)%360*10).to_i]*3
      elsif @time<=60
        for i in 0...3
          @rx+=$movex[((360-self.angle)%360*10).to_i]*60
          @ry+=$movey[((360-self.angle)%360*10).to_i]*60
          xx=(self.x-$game_player.screen_x).abs-3
          yy=(self.y-$game_player.screen_y+22).abs-3
          if xx*xx+yy*yy<=400
            @time=300
            $game_player.animation_id=44
            if @damage*(1+$game_variables[253])>=$game_actors[1].hp
              $game_variables[19]=1
              $game_actors[1].hp-=@damage*(1+$game_variables[253])
              $game_temp.common_event_id =12#生命小于0，调用1号结局
            else
              $game_actors[1].hp-=@damage*(1+$game_variables[253])
              Audio.se_play("Audio/SE/VX Slash8",80)
            end
            break
          end
        end
      elsif @time<=310
        self.opacity-=25
        if self.opacity<=10
          @dead=true
          self.visible=false
        end
      end
    when 4 #极限火花
      if @time==1
        @var=[@rx,@ry]
        self.oy=40
        px=$game_player.real_x
        py=$game_player.real_y-24
        @rangle=bullet_fllow(@rx,@ry,px,py)
        self.angle=180-@rangle
        @rangle=@rangle%360
        self.zoom_x=0.02
        self.zoom_y=2.0
      end
      @rx=@var[0]+rand(4)-2
      @ry=@var[1]+rand(4)-2
      if @time==40
        Audio.se_play("Audio/SE/charge",100)
      end
      if @time>50 && @time<=80
        self.zoom_x+=0.03
      end 
      if @time>=50 && @time%16==0 && @time<300
        new_bullet([RPG::Cache.picture("laser"),Rect.new(512,0,256,192),@rx,@ry,10,self.zoom_x*0.27,1,180-self.angle,0,5,0,[@rx,@ry,@id]])
      end
      if @time>=50 && @time%10==0 && @time<=300
        Audio.se_play("Audio/SE/spark1",60)
      end
      if @time>=70 && @time<280 && @time%10==0
        a=rand(30)/10.0
        b=rand(3600)/10.0
        c=rand(2)*32
        Audio.se_play("Audio/SE/se_tan01",90)
        for i in 0...15
          new_bullet([RPG::Cache.picture("bullet2"),Rect.new(96+c,0,32,32),@rx,@ry,8,1,1,i*24+b,2.5+a,0,150000])
        end
      end
      if @time>=120 && @time<=300
        px=$game_player.real_x
        py=$game_player.real_y-24
        a=(180+bullet_fllow(@var[0],@var[1],px,py))%360
        if (a-@rangle).abs>0.5
          if @rangle<a
            a1=a-@rangle
            a2=@rangle+360-a
            if a1<a2
              @rangle-=0.5
            else
              @rangle+=0.5
            end
          else
            a1=@rangle-a
            a2=a+360-@rangle
            if a1>a2
              @rangle-=0.5
            else
              @rangle+=0.5
            end
          end
          @rangle=(@rangle+360)%360
          self.angle=180-@rangle
        else
          @rangle=a
        end
      end
      if @time>=300
        self.zoom_x-=0.03
        if self.zoom_x<=0
          self.zoom_x=0
          @dead=true
        end
      end
      $game_variables[277]=@rangle
    when 5 #极限火花装饰
      @rangle=$game_variables[277]
      self.angle=180-@rangle
      @rx=@var[0]+(20+@time*60) * Math.cos((@rangle-90)/57.3)
      @ry=@var[1]+(20+@time*60) * Math.sin((@rangle-90)/57.3)
      self.zoom_y=0 if @time<3
      if @time>2 && @time<=15
        self.zoom_y=1
        self.zoom_x+=0.04
      end
      if @time%1==0
        xx=(self.x-$game_player.screen_x).abs/self.zoom_x
        yy=(self.y-$game_player.screen_y+22).abs/self.zoom_x
        if xx*xx+yy*yy<=13000
          damage=1000000
          if damage*(1+$game_variables[253])>=$game_actors[1].hp
            $game_variables[19]=1
            $game_actors[1].hp-=damage*(1+$game_variables[253])
            $game_temp.common_event_id =12#生命小于0，调用1号结局
          else
            $game_actors[1].hp-=damage*(1+$game_variables[253])
          end
        end
      end
    end
    return if @dead
    
    self.x=screen_x
    self.y=screen_y
 #   self.z=2000
    if @bit_id==2 && self.src_rect.y==192 #大玉
      self.angle=(@time*8)%360
    end
    if @time<=10 && @kind !=1 && self.zoom_x>1
      self.zoom_x/=1.019
      self.zoom_y/=1.019
      if @time==10
        self.zoom_x=1
        self.zoom_y=1
      end
    end
    w=($game_map.width)*32
    h=$game_map.height*32
    if $game_map.map_id==479
      h=24*32
    end
    if @kind==5
      h=28*32
    end
    if $game_map.map_id==573
      h=34*32
    end
    if @rx/4>w+self.ox || @rx/4<160-self.ox || @ry/4>h+self.oy || @ry/4<0-self.oy
      @dead=true
      self.visible=false
    else
      judge if @damage>0
    end
    #  update_animation
  end
  def judge
    xx=(self.x-$game_player.screen_x).abs-3
    yy=(self.y-$game_player.screen_y+22).abs-3
    case @bit_id
    when 1
      case self.src_rect.y
      when 16,80,96
        make_damage if xx*xx+yy*yy<=5*5
      when 48
        make_damage if xx*xx+yy*yy<=7*7
      end
    when 2
      case self.src_rect.y
      when 0
        return if @kind==2
        make_damage if xx*xx+yy*yy<=12*12
      when 32
        make_damage if xx*xx+yy*yy<=12*12
      when 64,96,128
        make_damage if xx*xx+yy*yy<=7*7
      when 192
        make_damage if xx*xx+yy*yy<=20*20
      end
    end
    
  end
  def make_damage
    @dead=true
    self.visible=false
    $game_player.animation_id=44
    if @damage*(1+$game_variables[253])>=$game_actors[1].hp
      $game_variables[19]=1
      $game_actors[1].hp-=@damage*(1+$game_variables[253])
      $game_temp.common_event_id =12#生命小于0，调用1号结局
    else
      $game_actors[1].hp-=@damage*(1+$game_variables[253])
      Audio.se_play("Audio/SE/VX Sword1",80)
    end
  end
end

def new_bullet(arr)
  for i in $game_variables[251]...1500
    if $game_variables[250][i]==nil
      $game_variables[250][i]=arr
      $game_variables[251]=i+1
      return i
    end
  end
  for i in 0...15000
    if $game_variables[250][i]==nil
      $game_variables[250][i]=arr
      $game_variables[251]=i+1
      return i
    end
  end
  p "溢出"
  return
end

def bullet_fllow(x1,y1,x2,y2)
	  angle=0
    sw=false
    if y1.to_i == y2.to_i
      angle= x1>x2 ? 270 : 90
      sw=true
    end
    if x1.to_i == x2.to_i
      angle= y1>y2 ? 0 : 180
      sw=true
    end
    return angle if sw
    angle=(y1-y2)/(x1-x2)
    angle=90+Math.atan(angle)*57.3
    angle+=180 if x1>x2
    return angle
end
  
$movex=[]
$movey=[]
for i in 0..3600
	if i%900 !=0 
		xx=Math.tan((90-i/10.0)/57.3)
		$movex[i]=Math.sqrt(1.0/(1+xx*xx))
		$movey[i]=-$movex[i]*xx
		if i>1800 
      $movex[i]=-$movex[i];$movey[i]=-$movey[i]
    end
	end
	$movex[0]=0;$movex[900]=1;$movex[1800]=0;$movex[2700]=-1;$movex[3600]=0
	$movey[0]=-1;$movey[900]=0;$movey[1800]=1;$movey[2700]=0;$movey[3600]=-1
end
