def spr_clone2(spr,xx,yy)
  clo=Sprite_Sandstorm.new(spr.event_id,xx,yy)
  clo.bitmap=spr.bitmap
  clo.opacity=spr.opacity
  clo.src_rect=spr.src_rect
  clo.angle=spr.angle
  clo.z=spr.z
  clo.color=spr.color
  clo.tone=spr.tone
  clo.blend_type=spr.blend_type
  return clo
end
def spr_clone3(spr,xx,yy)
  clo=Sprite_JLight.new(spr.event_id,xx,yy)
  clo.bitmap=spr.bitmap
  clo.opacity=spr.opacity
  clo.src_rect=spr.src_rect
  clo.angle=spr.angle
  clo.z=spr.z
  clo.color=spr.color
  clo.tone=spr.tone
  clo.blend_type=spr.blend_type
  return clo
end
def spr_clone4(spr,xx,yy)
  clo=Sprite_Ice.new(spr.event_id,xx,yy)
  clo.bitmap=spr.bitmap
  clo.opacity=spr.opacity
  clo.src_rect=spr.src_rect
  clo.angle=spr.angle
  clo.z=spr.z
  clo.color=spr.color
  clo.tone=spr.tone
  clo.blend_type=spr.blend_type
  return clo
end
def spr_clone5(spr,xx,yy)
  clo=Sprite_Eye.new(spr.event_id,xx,yy)
  clo.bitmap=spr.bitmap
  clo.opacity=spr.opacity
  clo.src_rect=spr.src_rect
  clo.angle=spr.angle
  clo.z=spr.z
  clo.color=spr.color
  clo.tone=spr.tone
  clo.blend_type=spr.blend_type
  return clo
end
class Sprite_Sandstorm < RPG::Sprite
  attr_accessor :event_id
  attr_accessor :sx
  attr_accessor :sy
  def initialize(event_id,sx,sy)
    super(nil)
    @event_id=event_id
    @sx=sx-48
    @sy=sy-64
    update
  end
  def update
    super
    self.x=$game_map.events[@event_id].screen_x+@sx
    self.y=$game_map.events[@event_id].screen_y+@sy
  end
end
class Sprite_JLight < RPG::Sprite
  attr_accessor :event_id
  attr_accessor :sx
  attr_accessor :sy
  attr_accessor :time
  def initialize(event_id,sx,sy)
    super($mainviewport)
    @event_id=event_id
    @sx=sx
    @sy=sy
    @time=0
    update
  end
  def update
    super
    @time=Graphics.frame_count%32
    self.x=$game_map.events[@event_id].screen_x+@sx
    self.y=$game_map.events[@event_id].screen_y+@sy
    self.src_rect.x=@time/8*32
    #@time+=1
    #@time-=32 if @time>=32
  end
end
class Sprite_Ice < RPG::Sprite
  attr_accessor :event_id
  attr_accessor :sx
  attr_accessor :sy
  attr_accessor :time
  def initialize(event_id,sx,sy)
    super($mainviewport)
    @event_id=event_id
    @sx=sx
    @sy=sy
    @time=0
    update
  end
  def update
    super
    @time=Graphics.frame_count%32
    self.x=$game_map.events[@event_id].screen_x+@sx
    self.y=$game_map.events[@event_id].screen_y+@sy
    if $game_map.events[@event_id].name[3,3]=="门"
      self.z=$game_map.events[@event_id].screen_z+1
    end
  end
end
class Sprite_Eye < RPG::Sprite
  attr_accessor :event_id
  attr_accessor :sx
  attr_accessor :sy
  attr_accessor :time
  def initialize(event_id,sx,sy)
    super(nil)
    @event_id=event_id
    @sx=sx-16
    @sy=sy-64
    @time=0
    update
  end
  def update
    super
    @time=Graphics.frame_count%32
    self.opacity=(time*8-128).abs+100
    self.x=$game_map.events[@event_id].screen_x+@sx
    self.y=$game_map.events[@event_id].screen_y+@sy
  end
end
class Sprite_Tile < RPG::Sprite
  attr_accessor :sx
  attr_accessor :sy
  attr_accessor :sz
  attr_accessor :type
  attr_accessor :time
  def initialize(view,sx,sy,tile_id)
    super(view)
    @type = 0
    @sx = sx *128
    @sy = sy *128
    @sz = $game_map.priorities[tile_id] * 32 + 32
    if $game_map.priorities[tile_id] == 0
      @sz = 0
    end
    update
  end
  def update
    super
    self.x = (@sx - $game_map.display_x + 3) / 4
    self.y = (@sy - $game_map.display_y + 3) / 4
    self.z = @sz>0 ? @sz + (@sy - $game_map.display_y + 3) / 4 : @sz
    if @type>0
      case @type
      when 1
        self.y = self.y + ((@time-64).abs-32)/8.0
        @time = (@time+1)%128
      when 2
        self.y = self.y + ((@time-64).abs-32)/4.0
        @time = (@time+1)%128
      end
    end
    #self.x=$game_map.events[@event_id].screen_x+@sx
   # self.y=$game_map.events[@event_id].screen_y+@sy
  end
end