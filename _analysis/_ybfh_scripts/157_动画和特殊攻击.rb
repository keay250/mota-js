class Sprite_Anima < RPG::Sprite
  attr_accessor :id
  attr_accessor :real_x
  attr_accessor :real_y
  def initialize(viewport,i)
    super(viewport)
    @id=i
    @real_x=0
    @real_y=0
    @wait=0
    @time=0
    @kind=0
    @start=false
    @val=0
    @ox=0
    @z=0
    @start=false
    self.bitmap=Bitmap.new(1,1)
    update
  end
  def screen_x
    return (@real_x - $game_map.display_x + 3) / 4 +16
  end
  def screen_y
    y = (@real_y - $game_map.display_y + 3) / 4 + 16
    return y
  end
  def screen_z(height = 0)
    z = (@real_y - $game_map.display_y + 3) / 4 + 32
    return z + ((height > 32) ? 31 : 0)
  end
  def update
    super
    # 设置脚本的坐标
    if $game_variables[247][@id]!=nil
      if @wait==0
        a=$game_variables[247][@id]
        animation = $data_animations[a[2]]
        @time=animation.frame_max+1
        if !@start
          @z=0
          @real_x=a[0]
          @real_y=a[1]
          @kind=a[3]
          self.angle=0
          self.opacity=255
          self.bitmap.clear
          self.bitmap=Bitmap.new(1,1)
          self.zoom_x=1
          self.zoom_y=1
          self.ox=0
          self.oy=0
          if a[5]!=nil
            @val=a[5].clone
          end
        end
        if @kind==4
          @time+=12
        end
        if @kind==5
          @time+=50
        end
        if @kind==6
          @time+=50
        end
        if @kind==9
          @time+=12
        end
        if @kind==10 || @kind==11
          @time+=38
          @abc=-1
        end

        if a[4]>0
          @wait=a[4]
        else
          $game_variables[247][@id]=nil
        end
        @start=true
        animation(animation, true)
      end
    else
      @start=false
      @wait=0
    end
    self.x = screen_x
    self.y = screen_y
    self.z = screen_z+@z
   
    if @wait>0
      @wait-=1
    end
    #主要处理
    if @time>0
      @time-=1
      case @kind
      when 10,11 #追随动画
        @real_x=$game_map.events[$game_variables[249][0]].real_x
        @real_y=$game_map.events[$game_variables[249][0]].real_y
        xx=(@real_x-$game_player.real_x).abs/4.0
        yy=(@real_y-$game_player.real_y).abs/4.0
        self.x = screen_x
        self.y = screen_y
        self.z = screen_z+@z
        if @_animation_sprites !=nil
        if xx*xx+yy*yy<=10000 
          newBitmap=RPG::Cache.animation($data_animations[93].animation_name,150)
          @@_reference_count[newBitmap]=@@_reference_count[@_animation_sprites[0].bitmap]
          for i in 0..15
            @_animation_sprites[i].bitmap=newBitmap
            @_animation_sprites[i].visible=false if @abc!=1
          end
          @abc=1
        else
          number=300 if @kind==10
          number=90 if @kind==11
          newBitmap=RPG::Cache.animation($data_animations[93].animation_name,number)
          @@_reference_count[newBitmap]=@@_reference_count[@_animation_sprites[0].bitmap]
          for i in 0..15
            @_animation_sprites[i].bitmap=newBitmap
            @_animation_sprites[i].visible=false if @abc!=0
          end
          @abc=0
        end
        end
      when 9 #光击阵
        if @time==31
          w=96;h=96
          if !$game_switches[173]
            self.bitmap=Bitmap.new(w,h)
            for i in 0...9
              if i==0
                self.bitmap.fill_rect(i%3*32+14,i/3*32+14,16,16,$mapdamage_obj.getcolor(9))
              elsif i==2
                self.bitmap.fill_rect(i%3*32+1,i/3*32+14,16,16,$mapdamage_obj.getcolor(9))
              elsif i==6
                self.bitmap.fill_rect(i%3*32+14,i/3*32+1,16,16,$mapdamage_obj.getcolor(9))
              elsif i==8
                self.bitmap.fill_rect(i%3*32+1,i/3*32+1,16,16,$mapdamage_obj.getcolor(9))
              else
                self.bitmap.fill_rect(i%3*32+1,i/3*32+1,30,30,$mapdamage_obj.getcolor(9))
              end
            end
            self.opacity=200
            self.ox=w/2
            self.oy=h/2
          end
        end
        if @time==6
          xx=(@real_x-$game_player.real_x).abs/4.0
          yy=(@real_y-$game_player.real_y).abs/4.0
          if xx*xx+yy*yy<=2500
            self.flash($mapdamage_obj.getcolor(13),10) if self.ox>0
            $game_player.animation_id=47
            $game_variables[289]=60 #眩晕
            damage=50000000
            if damage>=$game_actors[1].hp
              $game_variables[19]=1
              $game_actors[1].hp-=damage
              $game_temp.common_event_id =12#生命小于0，调用1号结局
            else
              $game_actors[1].hp-=damage
              Audio.se_play("Audio/SE/复件 Annihilation2",80)
            end
          end
        end
      when 1,2,3 #ZXC炮
        if @time==15
          w=96;h=96
          if !$game_switches[173]
            self.bitmap.clear
            self.bitmap=Bitmap.new(w,h)
            for i in 0...9
              self.bitmap.fill_rect(i%3*32+1,i/3*32+1,30,30,$mapdamage_obj.getcolor(3))
            end
            self.opacity=200
            self.ox=w/2
            self.oy=h/2
          end
        end
        if @time==11
        for i in $game_variables[249]
          value=$game_map.events[i]
         # if value.name[0,6]=="怪物" && value.character_name!=""
            xx=(@real_x-value.real_x).abs/4.0
            yy=(@real_y-value.real_y).abs/4.0
            if xx*xx+yy*yy<=2500
              $game_variables[244]-=180
              get_achievement(219,[@kind]) #ZZXC
              self.flash($mapdamage_obj.getcolor(5),10) if self.ox>0
              value.animation_id=44
            end
          #end
        end
        end
      when 4 #冰晶
        if @time==41
          w=96;h=96
          if !$game_switches[173]
            self.bitmap=Bitmap.new(w,h)
            for i in 0...9
              if i==0
                self.bitmap.fill_rect(i%3*32+14,i/3*32+14,16,16,$mapdamage_obj.getcolor(12))
              elsif i==2
                self.bitmap.fill_rect(i%3*32+1,i/3*32+14,16,16,$mapdamage_obj.getcolor(12))
              elsif i==6
                self.bitmap.fill_rect(i%3*32+14,i/3*32+1,16,16,$mapdamage_obj.getcolor(12))
              elsif i==8
                self.bitmap.fill_rect(i%3*32+1,i/3*32+1,16,16,$mapdamage_obj.getcolor(12))
              else
                self.bitmap.fill_rect(i%3*32+1,i/3*32+1,30,30,$mapdamage_obj.getcolor(12))
              end
            end
            self.opacity=200
            self.ox=w/2
            self.oy=h/2
          end
        end
        if @time==6
          xx=(@real_x-$game_player.real_x).abs/4.0
          yy=(@real_y-$game_player.real_y).abs/4.0
          if xx*xx+yy*yy<=2500
            self.flash($mapdamage_obj.getcolor(13),10) if self.ox>0
            $game_player.animation_id=47
            if $game_variables[252][0]>5
              damage=1000000*(1+$game_variables[253])
            else
              damage=80000*(1+$game_variables[253])
            end
            if damage>=$game_actors[1].hp
              $game_variables[19]=1
              $game_actors[1].hp-=damage
              $game_temp.common_event_id =12#生命小于0，调用1号结局
            else
              $game_actors[1].hp-=damage
              Audio.se_play("Audio/SE/复件 Annihilation2",80)
            end
          end
        end
      when 5
        self.z=0
        if @time==99
          x=@real_x
          y=@real_y
          px=$game_player.real_x
          py=$game_player.real_y-24
          self.angle=(bullet_fllow(x,y,px,py)+rand(1000)/10.0-50)%360
        end
        @real_x+=$movex[(self.angle*10).to_i]*12
        @real_y+=$movey[(self.angle*10).to_i]*12
        x=@real_x
        y=@real_y
        if !$game_switches[174]
          if @time<99 && @time%4==0
            Audio.se_play("Audio/SE/se_tan00",30)
         
              #px=$game_player.real_x
             # py=$game_player.real_y-24
             # fllow=bullet_fllow(x,y,px,py)#+rand(100)/10.0-5
             # new_bullet([RPG::Cache.picture("bullet1"),Rect.new(96,209,32,30),x,y,1,2,2,0,0,1,0])
              new_bullet([RPG::Cache.picture("bullet1"),Rect.new(96,16,16,16),x,y,10,1,1,self.angle+135,7,0,8000])
              new_bullet([RPG::Cache.picture("bullet1"),Rect.new(96,16,16,16),x,y,10,1,1,self.angle-135,7,0,8000])
              # end
          end
            
          xx=(@real_x-$game_player.real_x).abs/4.0
          yy=(@real_y-$game_player.real_y).abs/4.0
          if xx*xx+yy*yy<=2000
            @time=1
            new_anima(x,y,49,0)
            damage=400000*(1+$game_variables[253])
            if damage>=$game_actors[1].hp
              $game_actors[1].hp-=damage
              $game_variables[19]=1
              $game_temp.common_event_id =12#生命小于0，调用1号结局
            else
              $game_actors[1].hp-=damage
              Audio.se_play("Audio/SE/054-Cannon03",70)
            end
            @time=0
          end
        else
          @time=10 if @time>10
          self.opacity-=25
        end
        if @time==1
          a=rand(90)/10.0
          Audio.se_play("Audio/SE/se_tan01",90)
          for j in 0...40
            new_bullet([RPG::Cache.picture("bullet1"),Rect.new(96,48,16,16),x,y,9,1,1,a+j*9,3+j%2,0,20000])
          end
        end
      when 6 #不朽山谷终符
        animation_set_z(2001)
        @val[3]+=1
        @real_x=@val[0]+Math.cos((@val[2]+@val[3]*2)/57.3)*128*3
        @real_y=@val[1]+Math.sin((@val[2]+@val[3]*2)/57.3)*128*3+192
        if $game_switches[174]
          self.opacity-=25
          if self.opacity<=10
            self.opacity=0
          end
        else
          if !$game_temp.message_window_showing 
            if @val[3]>=50 && @val[3]%10==0
              new_bullet([RPG::Cache.picture("bullet2"),Rect.new(96,128,32,32),@real_x,@real_y,8,1,1,(@val[2]+@val[3]*2)+90,4,0,10000])
            end
          end
        end
      when 7 #魂之挽歌
        if @time>=5 && @time%2==0
          a=(21-@time)/2
          if !$game_switches[173]
            new_anima(@real_x,@real_y,75,8,0,[a])
          end
        end
      when 8 #魂之挽歌分散攻击
        self.z=0
        if @time==15
          l=@val[0]
          w=l*32*2+32;h=w
          self.bitmap.clear
            self.bitmap=Bitmap.new(w,h)
            for i in -l...l+1
              for j in -l...l+1
                if (i.abs+j.abs-l).abs<=0
                  if (i==0 || j==0 || i.abs==j.abs) && l%2==0
                     new_anima(@real_x+i*128,@real_y+j*128,42,0,0)
                  end
                  self.bitmap.fill_rect(i*32+l*32+1,j*32+l*32+1,30,30,$mapdamage_obj.getcolor(5))
                  for q in $game_variables[249]
                    value=$game_map.events[q]
                    xx=(@real_x+i*128-value.real_x).abs/4.0
                    yy=(@real_y+j*128-value.real_y).abs/4.0
                    if xx*xx+yy*yy<=256
                      $game_variables[244]-=1800
                      self.flash($mapdamage_obj.getcolor(5),10) if self.ox>0
                      value.animation_id=44
                    end
                    
                  end
                end
              end
            end
            self.opacity=200
            self.ox=w/2
            self.oy=h/2
        end
      end
    else
      if self.ox>0
        self.opacity=[self.opacity-20,0].max
        if self.opacity==0
          self.ox=0
        end
      end
    end
    if $game_switches[175]
      self.opacity-=25
      if self.opacity<=10
        self.opacity=0
      end
    end
  end
end

def new_anima(x,y,id,kind,loop=0,var=nil)
  for i in $game_variables[248]...50
    if $game_variables[247][i]==nil
      $game_variables[247][i]=[x,y,id,kind,loop,var]
      $game_variables[248]=i+1
      return i
    end
  end
  for i in 0...50
    if $game_variables[247][i]==nil
      $game_variables[247][i]=[x,y,id,kind,loop,var]
      $game_variables[248]=i+1
      return i
    end
  end
  p "溢出"
  return
end


module RPG
  class Sprite < ::Sprite
    def animation_set_z(z)
      return if @_animation_sprites==nil
      for i in 0..15
        @_animation_sprites[i].z=z
      end
    end
  end
end
