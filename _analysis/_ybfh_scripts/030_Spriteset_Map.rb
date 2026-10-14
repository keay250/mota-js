#==============================================================================
# ■ Spriteset_Map
#------------------------------------------------------------------------------
# 　处理地图画面活动块和元件的类。本类在
# Scene_Map 类的内部使用。
#==============================================================================

class Spriteset_Map
  #--------------------------------------------------------------------------
  # ● 初始化对像
  #--------------------------------------------------------------------------
  def initialize
    # 生成显示端口
    @viewport1 = Viewport.new(0, 0, 640, 480)
    $mainviewport=@viewport1
    @viewport2 = Viewport.new(0, 0, 800, 480)
    @viewport3 = Viewport.new(0, 0, 640, 480)
    @viewport2.z = 200
    @viewport3.z = 5000
    
    #新版tilemap开关
    @use_new_tile=false
    if $game_config.data("effect")>0
      case $game_map.tileset_id 
      when 24 #赤炼天盘使用
        @use_new_tile=true
      end
    end
    # 生成元件地图
    if @use_new_tile
      @tilemap=Newtile_Map.new($game_map,@viewport1)
    else
      @tilemap = Tilemap.new(@viewport1)
      @tilemap.tileset = RPG::Cache.tileset($game_map.tileset_name)
      for i in 0..6
        autotile_name = $game_map.autotile_names[i]
        @tilemap.autotiles[i] = RPG::Cache.autotile(autotile_name)
      end
      @tilemap.map_data = $game_map.data
      @tilemap.priorities = $game_map.priorities
    end
    # 生成远景平面
    @panorama = Plane.new(@viewport1)
    @panorama.z = -1000
    # 生成雾平面
    @fog = Plane.new(@viewport1)
    @fog.z = 3000
    # 生成角色活动块
    @character_sprites = []

    for i in $game_map.events.keys.sort
      sprite = Sprite_Character.new(@viewport1, $game_map.events[i])
      if $game_map.events[i].event.name=="float"
        sprite.type = 1
        sprite.time = rand(128)
      end
      @character_sprites.push(sprite)
    end

    @player_character =Sprite_Character.new(@viewport1, $game_player)
    @character_sprites.push(@player_character)
    if @use_new_tile
      @tilemap.start(@character_sprites,@player_character)
    end
    #旧版本天气系统转换
    if $game_screen.get_weather_max>=500
      $game_screen.set_weather_max(35)
    end
    # 生成天气
    @weather = RPG::Weather.new(@viewport1)
    # 生成图片
    @picture_sprites = []
    for i in 1..50
      @picture_sprites.push(Sprite_Picture.new(@viewport2,
      $game_screen.pictures[i]))
    end
    $game_variables[247]=[] if $game_variables[247]==0
    @anima = []  
    for i in 0...50
      @anima.push(Sprite_Anima.new(@viewport1,i))
    end
    @bullet = []  
    $game_variables[250]=[] if $game_variables[250]==0
    for i in 0...$game_variables[250].size
      if $game_variables[250][i]==nil
        @bullet.push(nil)
      else
        @bullet.push(Sprite_Bullet.new(@viewport2,i))
        @bullet[i].reset(*$game_variables[250][i])
      end
    end
    # 生成计时器块
    @timer_sprite = Sprite_Timer.new
    # 刷新画面
    update
  end
  def view1
    return @viewport1
  end
  #--------------------------------------------------------------------------
  # ● 释放
  #--------------------------------------------------------------------------
  def dispose
    if @use_new_tile
      @tilemap.dispose
    else
      # 释放元件地图
      @tilemap.tileset.dispose
      for i in 0..6
        @tilemap.autotiles[i].dispose
      end
      @tilemap.dispose
    end
    # 释放远景平面
    @panorama.dispose
    # 释放雾平面
    @fog.dispose
    # 释放角色活动块
    for sprite in @character_sprites
      sprite.dispose
    end
    # 释放天候
    @weather.dispose
    # 释放图片
    for sprite in @picture_sprites
      sprite.dispose
    end
    for sprite in @anima
      sprite.dispose
    end
    for i in 0...$game_variables[250].size
      if @bullet[i]!=nil
        @bullet[i].dispose
      end
    end
    @bullet=[]
    # 释放计时器块
    @timer_sprite.dispose
    # 释放显示端口
    @viewport1.dispose
    @viewport2.dispose
    @viewport3.dispose
    if $sandstorm !=nil
    for i in $sandstorm
      i.dispose
    end
    end
    $sandstorm=[]
  end
  def get_view
    return @viewport1
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面
  #--------------------------------------------------------------------------
  def update
    # 远景与现在的情况有差异发情况下
    if @panorama_name != $game_map.panorama_name or
       @panorama_hue != $game_map.panorama_hue
      @panorama_name = $game_map.panorama_name
      @panorama_hue = $game_map.panorama_hue
      if @panorama.bitmap != nil
        @panorama.bitmap.dispose
        @panorama.bitmap = nil
      end
      if @panorama_name != ""
        @panorama.bitmap = RPG::Cache.panorama(@panorama_name, @panorama_hue)
      end
      Graphics.frame_reset
    end
    # 雾与现在的情况有差异的情况下
    if @fog_name != $game_map.fog_name or @fog_hue != $game_map.fog_hue
      @fog_name = $game_map.fog_name
      @fog_hue = $game_map.fog_hue
      if @fog.bitmap != nil
        @fog.bitmap.dispose
        @fog.bitmap = nil
      end
      if @fog_name != ""
        @fog.bitmap = RPG::Cache.fog(@fog_name, @fog_hue)
      end
      Graphics.frame_reset
    end
    # 刷新元件地图
    if @use_new_tile
      @tilemap.update
    else
      @tilemap.ox = $game_map.display_x / 4
      @tilemap.oy = $game_map.display_y / 4
      @tilemap.update
    end
    # 刷新远景平面
    case $game_map.tileset_id 
    when 3
      $game_variables[191]-=1
      $game_variables[191]-=700 if $game_variables[191]>=700
      @panorama.ox = $game_variables[191]
      @panorama.oy = $game_map.display_y / 8
    when 58
      $game_variables[191]+=1
      $game_variables[191]-=700 if $game_variables[191]>=700
      @panorama.ox = $game_variables[191]
    when 112
      $game_variables[191]+=0.4
      $game_variables[191]-=700 if $game_variables[191]>=700
      @panorama.ox = $game_variables[191]
      @panorama.oy = $game_map.display_y / 8
      @panorama.zoom_y=0.15+$game_map.height/17.5
    when 15
      $game_variables[191]+=0.4
      $game_variables[191]-=700 if $game_variables[191]>=700
      @panorama.ox = $game_variables[191]
    when 19
      $game_variables[191]-=0.5
      $game_variables[27]+=0.5
      $game_variables[191]-=800 if $game_variables[191]>=800
      $game_variables[27]-=576 if $game_variables[127]>=576
      @panorama.ox = $game_variables[191]-$game_map.display_x / 8
      @panorama.oy = $game_variables[27]-$game_map.display_y / 8
    when 59
      @panorama.ox = $game_map.display_x / 8
      @panorama.oy = 0
    when 24,26
      @panorama.ox = $game_map.display_x / 8
      @panorama.oy = 150-($game_map.height-15)*6+$game_map.display_y / 12
    else
      @panorama.ox = $game_map.display_x / 8
      @panorama.oy = $game_map.display_y / 8
    end
    # 刷新雾平面
    @fog.zoom_x = $game_map.fog_zoom / 100.0
    @fog.zoom_y = $game_map.fog_zoom / 100.0
    @fog.opacity = $game_map.fog_opacity
    @fog.blend_type = $game_map.fog_blend_type
    @fog.ox = $game_map.display_x / 4 + $game_map.fog_ox
    @fog.oy = $game_map.display_y / 4 + $game_map.fog_oy
    @fog.tone = $game_map.fog_tone
    # 刷新角色活动块
    for sprite in @character_sprites
      sprite.update
    end
    # 刷新天候图形
    @weather.type = $game_screen.weather_type
    @weather.max = $game_screen.weather_max
    @weather.ox = $game_map.display_x / 4
    @weather.oy = $game_map.display_y / 4
    @weather.update
    # 刷新图片
    for sprite in @picture_sprites
      sprite.update
    end
    if $game_switches[171]
      for sprite in @anima
        sprite.update
      end
      check=false
      for j in 0...$game_variables[250].size
        i=$game_variables[250].size-1-j
        if $game_variables[250][i]!=nil
          if @bullet[i]==nil
            @bullet[i]=Sprite_Bullet.new(@viewport2,i)
            @bullet[i].reset(*$game_variables[250][i])
          end
          @bullet[i].update
          if @bullet[i].dead && @bullet[i].zoom_x==0
            @bullet[i].dispose
            @bullet[i]=nil
            $game_variables[250][i]=nil
          end
        end
      end
    end
=begin
    for j in 0...$game_variables[250].size
      i=$game_variables[250].size-1-j
      if $game_variables[250][i]==nil
        if !check
          @bullet.delete_at(i)
          $game_variables[250].delete_at(i)
        end
      else
        check=true
      end
    end
=end
    if $sandstorm !=nil
    for sprite in $sandstorm
      sprite.update
    end
    end
    # 刷新计时器块
    @timer_sprite.update
    # 设置画面的色调与震动位置
    @viewport1.tone = $game_screen.tone
    @viewport1.ox = $game_screen.shake
    # 设置画面的闪烁色
    @viewport3.color = $game_screen.flash_color
    # 刷新显示端口
    @viewport1.update
    @viewport3.update
  end
end
