module Camera
  
  module_function
  def start(x,y)
    z=42
    $mapdamage_obj.clear
    Graphics.update
    Audio.se_play("Audio/SE/se_alert.wav") 
    @camera_bitmap = Graphics.snap_to_bitmap
    @spr=Sprite.new
    @spr.bitmap=@camera_bitmap
    a=(x-$game_map.display_x/128.0-12)*8
    @spr.ox=(x-$game_map.display_x/128.0+1)*32-16+a
    a=(y-$game_map.display_y/128.0-7)*8
    @spr.oy=(y-$game_map.display_y/128.0+1)*32-16+a
    @spr.x=@spr.ox
    @spr.y=@spr.oy
    @spr.z=z
    @danger1=Sprite.new
    @danger1.bitmap=RPG::Cache.picture("danger")
    @danger1.src_rect=Rect.new(0,0,200,75)
    @danger1.x=700
    @danger1.y=100
    @danger1.z=z
    @danger2=Sprite.new
    @danger2.bitmap=RPG::Cache.picture("danger")
    @danger2.src_rect=Rect.new(0,75,200,75)
    @danger1.zoom_x=1.8
    @danger2.zoom_x=1.8
    @danger1.zoom_y=1.8
    @danger2.zoom_y=1.8
    @danger2.z=z
    @name=Sprite.new
    w=400;h=80
    @name.bitmap=Bitmap.new(w,h)
    if $game_player.x==x && $game_player.y==y
      str=$game_actors[1].name
    else
      id=$game_map.check_event(x,y)
      if $game_map.events[id].event.name[0,6]=="怪物"
        str=$data_enemies[$game_map.events[id].event.name[6,3].to_i].name.split(":")[0]
      else
        str=$game_map.events[id].event.name
      end
    end
    @name.bitmap.font.color = $mapdamage_obj.getcolor(0)
    @name.bitmap.font.size=42
    @name.bitmap.font.bold=true
    @name.bitmap.font.name="黑体"
    @name.bitmap.draw_text(2,0, w,h, str,1)
    @name.bitmap.draw_text(0,0, w,h, str,1)
    @name.bitmap.draw_text(2,2, w,h, str,1)
    @name.bitmap.draw_text(0,2, w,h, str,1)
    @name.bitmap.font.color = $mapdamage_obj.getcolor(2)
    @name.bitmap.draw_text(1,1,w,h, str,1)
    @name.y=300
    @name.z=z
    @time=0
    for i in 0...30
      @danger1.x-=14
      @spr.zoom_x*=1.05
      @spr.zoom_y*=1.05
      update
    end
    for i in 0...75
      @danger1.x-=1
      @spr.zoom_x*=1.003
      @spr.zoom_y*=1.003
      update
    end
    for i in 0...29
      @danger1.x-=14
      @spr.zoom_x/=1.06
      @spr.zoom_y/=1.06
      update
    end
    @camera_bitmap.dispose
    @spr.dispose
    @danger1.dispose
    @danger2.dispose
    @name.bitmap.dispose
    @name.dispose
    $game_switches[56]=true
  end
  def update
    @danger2.x=@danger1.x
    @danger2.y=@danger1.y
    @danger1.opacity=115+((@time)%40-20).abs*7
    @name.x=500-@danger1.x
    Graphics.update
    @time+=1
  end
end