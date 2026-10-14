#==============================================================================
# ■ Window_Help
#------------------------------------------------------------------------------
# 　特技及物品的说明、角色的状态显示的窗口。
#==============================================================================

class Window_SaveBitmap < Window_Base
  #--------------------------------------------------------------------------
  # ● 初始化对像
  #--------------------------------------------------------------------------
  def initialize
    super(0, -16, 640, 512)
    @spr=Sprite.new
    @spr.bitmap=Bitmap.new(1,1)
    @spr.opacity=250
    @ifhave=false
    @spr.z=self.z+14
    @spr.opacity
  end  
  def opcupdate
    if @ifhave
      @spr.opacity+=25 if @spr.opacity<250
    else
      @spr.opacity-=25 if @spr.opacity>0
    end
  end
  def dispose
    super
    @spr.bitmap.dispose
    @spr.dispose
  end
  #--------------------------------------------------------------------------
  # ● 设置文本
  #     text  : 窗口显示的字符串
  #     align : 对齐方式 (0..左对齐、1..中间对齐、2..右对齐)
  #--------------------------------------------------------------------------
  def refresh(i)
    if FileTest.exist?("Save/motaSave#{i + 1}.rxdata")
      @spr.bitmap.dispose
      file = Zlib::GzipReader.open("Save/motaSave#{i + 1}.rxdata")
      a=Marshal.load(file)
      if a.is_a?(Bitmap)
        @spr.bitmap= a
        @spr.src_rect=Rect.new(0,0,640,480)
      else
        @spr.bitmap =Bitmap.new("Save/motaSave#{i + 1}.png")
      end
      @ifhave=true
      @spr.bitmap.draw_text(422,0,200,32,file.mtime.strftime("%Y/%m/%d %H:%M"),2)
      file.close
    else
      @ifhave=false
    end
  end
end

class Game_System
  #---------------------------------------------------------------------------#
  # 实例变量                                                                  #
  #---------------------------------------------------------------------------#
  attr_accessor:snap_bitmap
end

#-----------------------------------------------------------------------------#
# 拦截读档与存档界面的打开与地图进入菜单前截图                                #
#-----------------------------------------------------------------------------#
trace_var :$scene do
 # if $scene.is_a?(Scene_Save)
 #   $scene = Scene_Save_Load.new
 # elsif $scene.is_a?(Scene_Load)
 #   $scene = Scene_Save_Load.new(1)
 # end
  if $scene.is_a?(Scene_Menu) and $_prev_scene == "Scene_Map"
    $snap_bitmap = Graphics.snap_to_bitmap
  end
  $_prev_scene = $scene.class.name
end

#-----------------------------------------------------------------------------#
# Graphics.snap_to_bitmap（优化版）                                           #
# 作者：神思                                                                  #
# 优化：釣到一隻猴子@_@  (  AAM@_@  )                                         #
# 出处：www.66rpg.com
#-----------------------------------------------------------------------------#
#-----------------------------------------------------------------------------#
# Graphics                                                                    #
#-----------------------------------------------------------------------------#
class << Graphics
=begin
    CreateDC = Win32API.new("gdi32", "CreateDC", "pppl", "l")
    CreateCompatibleBitmap = Win32API.new("gdi32", "CreateCompatibleBitmap", "lll", "l")
    CreateCompatibleDC = Win32API.new("gdi32", "CreateCompatibleDC", "l", "l")
    SelectObject = Win32API.new("gdi32", "SelectObject", "ll", "l")
    BitBlt = Win32API.new("gdi32", "BitBlt", "lllllllll", "l")
    GetBitmapBits = Win32API.new("gdi32", "GetBitmapBits", "llp", "l")
    ScreenToClient = Win32API.new("user32", "ScreenToClient", "ip", "i")
    SRCCOPY = 0xCC0020
    RtlMoveMemory = Win32API.new('kernel32', 'RtlMoveMemory', 'ipi', 'i')
   # HWnd = Win32API.new("user32", "GetActiveWindow", nil, 'l').call
    
    @readini = Win32API.new 'kernel32', 'GetPrivateProfileStringA', %w(p p p p l p), 'l'
    @findwindow = Win32API.new 'user32', 'FindWindowA', %w(p p), 'l' 
    game_name = "\0" * 256
    @readini.call('Game','Title','',game_name,255,".\\Game.ini")
    game_name.delete!("\0")
    HWnd= @findwindow.call('RGSS Player',game_name)
    
    DwCount = (800* 480 * 4) * 2
    @@lpBits = "\000" * DwCount
    DwCount2 = (160* 480 * 4) * 2
    @@lpBits2 = "\000" * DwCount2
=end
  CreateDC = Win32API.new("gdi32", "CreateDC", "pppl", "l")
  CreateCompatibleBitmap = Win32API.new("gdi32", "CreateCompatibleBitmap", "lll", "l")
  CreateCompatibleDC = Win32API.new("gdi32", "CreateCompatibleDC", "l", "l")
  SelectObject = Win32API.new("gdi32", "SelectObject", "ll", "l")
  BitBlt = Win32API.new("gdi32", "BitBlt", "lllllllll", "l")
  GetBitmapBits = Win32API.new("gdi32", "GetBitmapBits", "llp", "l")
  ScreenToClient = Win32API.new("user33", "ScreenToClient", "ip", "i")
  DeleteDC = Win32API.new("gdi32", "DeleteDC", "l", "l")
  DeleteObject = Win32API.new("gdi32", "DeleteObject", "l", "l")
  SRCCOPY = 0xCC0020
  RtlMoveMemory = Win32API.new("kernel32", "RtlMoveMemory", "ipi", "i")
  RtlMoveMemory_pi = Win32API.new("kernel32", "RtlMoveMemory", "pii", "i")
  HWnd = Graphics::HWND#Win32API.new("user32", "GetActiveWindow", nil, 'l').call
  DwCount = (800*480 * 4)# * 2
  @@lpBits = "\000" * DwCount
  
  #---------------------------------------------------------------------------#
  # snap_to_bitmap                                                            #
  #---------------------------------------------------------------------------#
  def snap_to_bitmap(width=640)
    height = 480
    hb = Bitmap.new(width, height)
    rgbs = self.bitmap_data(width)
    len = width * 4
    for y in 0...height
      break if 2*y >= height - 1
      nth1 = y * len
      nth2 = (height - 1 - y) * len
      tStr = rgbs[nth1,len]
      rgbs[nth1, len] = rgbs[nth2, len]
      rgbs[nth2, len] = tStr
    end
    RtlMoveMemory.call(hb.address, rgbs, width * 480 * 4)
    return hb
  end
  #---------------------------------------------------------------------------#
  # bitmap_data                                                          #
  #---------------------------------------------------------------------------#
  def bitmap_data(width)
=begin
    hScrDC = CreateDC.call("DISPLAY", "", "", 0)
    hMemDC = CreateCompatibleDC.call(hScrDC)
    hBitmap = CreateCompatibleBitmap.call(hScrDC, width, 480)
    hOldBitmap = SelectObject.call(hMemDC, hBitmap)
    BitBlt.call(hMemDC, xsrc, ysrc, width*2, 480*2, hScrDC, 0, 0, SRCCOPY)
    hBitmap = SelectObject.call(hMemDC, hOldBitmap)
    GetBitmapBits.call(hBitmap, DwCount, @@lpBits)
    return @@lpBits
=end
    hScrDC = CreateDC.call("DISPLAY", "", "", 0)
    hMemDC = CreateCompatibleDC.call(hScrDC)
    hBitmap = CreateCompatibleBitmap.call(hScrDC, width, height)
    hOldBitmap = SelectObject.call(hMemDC, hBitmap)
    win_pos = "\0\0\0\0\0\0\0\0"
    ScreenToClient.call(HWnd, win_pos)
    win_pos = win_pos.unpack("LL")
    BitBlt.call(hMemDC, win_pos[0], win_pos[1], width*2, height*2, hScrDC, 0, 0, SRCCOPY)
    hBitmap2 = SelectObject.call(hMemDC, hOldBitmap)
    GetBitmapBits.call(hBitmap2, DwCount, @@lpBits)
    # 释放所有东西
    DeleteDC.call(hScrDC)
    DeleteDC.call(hMemDC)
    DeleteObject.call(hBitmap)
    DeleteObject.call(hOldBitmap)
    DeleteObject.call(hBitmap2)
    return @@lpBits
  end
  #---------------------------------------------------------------------------#
  # 用户窗口的位置                                                            #
  #---------------------------------------------------------------------------#
  def xsrc
    return self.point[0]
  end
  #---------------------------------------------------------------------------#
  # 用户窗口的位置                                                            #
  #---------------------------------------------------------------------------#
  def ysrc
    return self.point[1]
  end
  #---------------------------------------------------------------------------#
  # 那个点                                                                    #
  #---------------------------------------------------------------------------#
  def point
    point = [0,0].pack("LL")
    ScreenToClient.call(HWnd, point)
    return point.unpack("LL")
  end
end

#-----------------------------------------------------------------------------#
# Font                                                                        #
#-----------------------------------------------------------------------------#
class Font
  #---------------------------------------------------------------------------#
  # marshal_dump                                                              #
  #---------------------------------------------------------------------------#
  def marshal_dump
  end
  #---------------------------------------------------------------------------#
  # marshal_load                                                              #
  #---------------------------------------------------------------------------#
  def marshal_load(obj)
  end
end

#-----------------------------------------------------------------------------#
# Bitmap                                                                      #
#-----------------------------------------------------------------------------#
class Bitmap
  RtlMoveMemory = Win32API.new('kernel32', 'RtlMoveMemory', 'pii', 'i')
  # 传送到内存的API函数
  RtlMoveMemory_pi = Win32API.new('kernel32', 'RtlMoveMemory', 'pii', 'i')
  RtlMoveMemory_ip = Win32API.new('kernel32', 'RtlMoveMemory', 'ipi', 'i')
  #---------------------------------------------------------------------------#
  # _dump                                                                     #
  #---------------------------------------------------------------------------#
  def _dump(limit)
    data = "rgba" * width * height
    RtlMoveMemory_pi.call(data, address, data.length)
    [width, height, Zlib::Deflate.deflate(data)].pack("LLa*") # 压缩
  end
  #---------------------------------------------------------------------------#
  # _load                                                                     #
  #---------------------------------------------------------------------------#
  def self._load(str)
    w, h, zdata = str.unpack("LLa*")
    b = self.new(w, h)
    RtlMoveMemory_ip.call(b.address, Zlib::Inflate.inflate(zdata), w * h * 4)
    return b
  end
  #---------------------------------------------------------------------------#
  # address                                                                   #
  #---------------------------------------------------------------------------#
  def address
    # [[[bitmap.object_id * 2 + 16] + 8] + 16] == 数据的开头
    buffer, ad = "xxxx", object_id * 2 + 16
    RtlMoveMemory.call(buffer, ad, 4)
    ad = buffer.unpack("L")[0] + 8
    RtlMoveMemory.call(buffer, ad, 4)
    ad = buffer.unpack("L")[0] + 16
    RtlMoveMemory.call(buffer, ad, 4)
    return buffer.unpack("L")[0]
  end
end