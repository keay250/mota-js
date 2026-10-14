=begin
$color_balck=Color.new(0,0,0,0)

#fill_rect(x,y,width,height,$color_balck)

  class Bitmap #< ::Bitmap
    def clear_rect(x, y, width, height)
      fill_rect(x,y,width,height,$color_balck)
   #   $game_map.light_surface.bitmap.stretch_blt(Rect.new(x+96,y+96,width,height),$black_bitmap,Rect.new(0,0,1,1))
    end
  end

=end