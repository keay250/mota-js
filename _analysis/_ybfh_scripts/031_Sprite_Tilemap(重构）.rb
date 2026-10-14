class Newtile_Map
  attr_accessor
  def initialize(map,view)
    @map = map.clone
    @tileset = RPG::Cache.tileset($game_map.tileset_name)
    @sprite = []
    for i in 0...@map.width
      @sprite[i]=[]
      for j in 0...@map.height
        @sprite[i][j]=[]
        for k in 0...3
          if i>=5 && @map.data[i,j,k]>0
            tid = @map.data[i,j,k]
            @sprite[i][j][k] = Sprite_Tile.new(view,i,j,tid)
            tid-=384
            @sprite[i][j][k].bitmap = @tileset
            @sprite[i][j][k].src_rect = Rect.new(tid%8*32,tid/8*32,32,32)
          end
        end
      end
    end
  end
  def start(csprite,player)
    @character_sprite = csprite
    @player_sprite = player
    case $game_map.map_id
    when 558
      make_float(Rect.new(8,15,13,23),rand(128),2)
      make_float(Rect.new(13,10,16,14),rand(128),2)
      make_float(Rect.new(9,3,12,9),rand(128),2)
      make_float(Rect.new(16,12,27,25),rand(128),1)
      make_float(Rect.new(15,1,27,9),rand(128),1)
    when 560
      make_float(Rect.new(6,20,16,28),rand(128),2)
      make_float(Rect.new(20,22,25,29),rand(128),2)
      val=rand(128)
      make_float(Rect.new(8,5,19,18),val,1)
      make_float(Rect.new(20,6,27,20),val,1)
      make_float(Rect.new(14,0,20,4),rand(128),1)
    when 562
      make_float(Rect.new(7,6,12,13),rand(128),1)
      make_float(Rect.new(7,14,12,22),rand(128),1)
      make_float(Rect.new(22,6,27,13),rand(128),1)
      make_float(Rect.new(22,14,27,22),rand(128),1)
    when 564
      make_float(Rect.new(15,16,19,22),rand(128),2)
      make_float(Rect.new(9,18,12,23),rand(128),2)
      make_float(Rect.new(8,8,12,16),rand(128),2)
      make_float(Rect.new(9,2,12,6),rand(128),2)
      make_float(Rect.new(16,2,22,9),rand(128),2)
      make_float(Rect.new(24,5,27,9),rand(128),2)
      make_float(Rect.new(23,11,25,16),rand(128),2)
      make_float(Rect.new(22,18,27,26),rand(128),2)
    end
  end
  def update
    for i in 0...@map.width
      for j in 0...@map.height
        for k in 0...3
          if @sprite[i][j][k] != nil
            @sprite[i][j][k].update
          end
        end
      end
    end
    
    @player_sprite.type = 0
    @player_sprite.time = 0
    i = @player_sprite.character.real_x/128
    j = @player_sprite.character.real_y/128
    if i>=0 && j>=0 && i<@map.width && j<@map.height
      for k in 0...3
        if @sprite[i][j][k] != nil && @sprite[i][j][k].type>0
          if @player_sprite.type != @sprite[i][j][k].type
            @player_sprite.type = @sprite[i][j][k].type
            @player_sprite.time = (@sprite[i][j][k].time+127)%128
          end
        end
      end
    end
  end
  def dispose
    for i in 0...@map.width
      for j in 0...@map.height
        for k in 0...3
          if @sprite[i][j][k] != nil
            @sprite[i][j][k].dispose
          end
        end
      end
    end
    @tileset.dispose
    @sprite = []
  end
  def make_float(rect,time,type)
    for i in rect.x..rect.width
      for j in rect.y..rect.height
        for k in 0...3
          if @sprite[i][j][k] != nil
            @sprite[i][j][k].type = type
            @sprite[i][j][k].time = time
          end
        end  
      end
    end  
    for sprite in @character_sprite
      event = sprite.character
      if event.x >= rect.x && event.x <=rect.width &&
        event.y >= rect.y && event.y <=rect.height
        sprite.type = type
        sprite.time = time
      end
    end
  end
end