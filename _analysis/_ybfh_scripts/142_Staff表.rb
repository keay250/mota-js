class Staff
  def initialize(i=0)
    @spr=Sprite.new
    @spr.bitmap=RPG::Cache.picture("staff#{i}")
    @spr.src_rect.x=0
    @spr.src_rect.width=300
    @spr.src_rect.height=0
    @spr.ox=150
    @spr.oy=100
    @spr.x=320
    @spr.y=220
    @spr.z=300
    @time=-200
  end
  def update
    @time+=1
    if @time<0
      @spr.src_rect.height+=1
    end
    if @time>=0 && @time%400>=200
      if @spr.src_rect.y>@spr.bitmap.height-200
        @spr.src_rect.height-=1
      end
      @spr.src_rect.y+=1
    end
  end
  def over?
    return (@time>=0 && @spr.src_rect.height<=1)
  end
  def dispose
    @spr.bitmap.dispose
    @spr.dispose
  end
end