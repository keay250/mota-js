=begin
module Screen  
  @screen = Win32API.new 'screenshot', 'Screenshot', %w(l l l l p l l), ''
  @readini = Win32API.new 'kernel32', 'GetPrivateProfileStringA', %w(p p p p l p), 'l'
  @findwindow = Win32API.new 'user32', 'FindWindowA', %w(p p), 'l' 
  module_function
  def shot(index,file = "motaSave", typ = 2)
    # to add the right extension...
    if typ == 0
      typname = ".bmp"
    elsif typ == 1
      typname = ".jpg"
    elsif typ == 2
      typname = ".png"
    end    
    file_index = 0    
    dir = "Save/"    
    # make the filename....
    file_name = dir + file.to_s + index.to_s + typname.to_s    
    # make the screenshot.... Attention dont change anything from here on....
    @screen.call(0,0,640,480,file_name,handel,typ)
  end
  # find the game window...
  def handel
    game_name = "\0" * 256
    @readini.call('Game','Title','',game_name,255,".\\Game.ini")
    game_name.delete!("\0")
    return @findwindow.call('RGSS Player',game_name)
  end
end
=end