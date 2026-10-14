#==============================================================================
#               本脚本出自www.66rpg.com，转载请注明。
#==============================================================================
=begin
==============================================================================
                        Bitmap to PNG By 轮回者
==============================================================================

 对Bitmap对象直接使用
 
 bitmap_obj.make_png(name[, path])
 
 name:保存文件名
 path:保存路径

 感谢66、夏娜、金圭子的提醒和帮助！
   
==============================================================================
=end
=begin
module Zlib
  class Png_File < GzipWriter
    #--------------------------------------------------------------------------
    # ● 主处理
    #-------------------------------------------------------------------------- 
    def make_png(bitmap_Fx,mode)
      @mode = mode
      @bitmap_Fx = bitmap_Fx
      self.write(make_header)
      self.write(make_ihdr)
      self.write(make_idat)
      self.write(make_iend)
    end
    #--------------------------------------------------------------------------
    # ● PNG文件头数据块
    #--------------------------------------------------------------------------
    def make_header
      return [0x89,0x50,0x4e,0x47,0x0d,0x0a,0x1a,0x0a].pack("C*")
    end
    #--------------------------------------------------------------------------
    # ● PNG文件情报头数据块(IHDR)
    #-------------------------------------------------------------------------- 
    def make_ihdr
      ih_size = [13].pack("N")
      ih_sign = "IHDR"
      ih_width = [@bitmap_Fx.width].pack("N")
      ih_height = [@bitmap_Fx.height].pack("N")
      ih_bit_depth = [8].pack("C")
      ih_color_type = [6].pack("C")
      ih_compression_method = [0].pack("C")
      ih_filter_method = [0].pack("C")
      ih_interlace_method = [0].pack("C")
      string = ih_sign + ih_width + ih_height + ih_bit_depth + ih_color_type +
               ih_compression_method + ih_filter_method + ih_interlace_method
      ih_crc = [Zlib.crc32(string)].pack("N")
      return ih_size + string + ih_crc
    end
    #--------------------------------------------------------------------------
    # ● 生成图像数据(IDAT)
    #-------------------------------------------------------------------------- 
    def make_idat
      header = "\x49\x44\x41\x54"
      case @mode # 请54~
      when 1
        data = make_bitmap_data#1
      else
        data = make_bitmap_data
      end
      data = Zlib::Deflate.deflate(data, 8)
      crc = [Zlib.crc32(header + data)].pack("N")
      size = [data.length].pack("N")
      return size + header + data + crc
    end
    #--------------------------------------------------------------------------
    # ● 从Bitmap对象中生成图像数据 mode 1(请54~)
    #-------------------------------------------------------------------------- 
    def make_bitmap_data1
      w = @bitmap_Fx.width
      h = @bitmap_Fx.height
      data = []
      for y in 0...h
        data.push(0)
        for x in 0...w
          color = @bitmap_Fx.get_pixel(x, y)
          red = color.red
          green = color.green
          blue = color.blue
          alpha = color.alpha
          data.push(red)
          data.push(green)
          data.push(blue)
          data.push(alpha)
        end
      end
      return data.pack("C*")
    end
    #--------------------------------------------------------------------------
    # ● 从Bitmap对象中生成图像数据 mode 0
    #-------------------------------------------------------------------------- 
    def make_bitmap_data
      gz = Zlib::GzipWriter.open('hoge.gz')
      t_Fx = 0
      w = @bitmap_Fx.width
      h = @bitmap_Fx.height
      data = []
      for y in 0...h
        data.push(0)
        for x in 0...w
          t_Fx += 1
          if t_Fx % 10000 == 0
            Graphics.update
          end
          if t_Fx % 100000 == 0
            s = data.pack("C*")
            gz.write(s)
            data.clear
            #GC.start
          end
          color = @bitmap_Fx.get_pixel(x, y)
          red = color.red
          green = color.green
          blue = color.blue
          alpha = color.alpha
          data.push(red)
          data.push(green)
          data.push(blue)
          data.push(alpha)
        end
      end
      s = data.pack("C*")
      gz.write(s)
      gz.close    
      data.clear
      gz = Zlib::GzipReader.open('hoge.gz')
      data = gz.read
      gz.close
      File.delete('hoge.gz') 
      return data
    end
    #--------------------------------------------------------------------------
    # ● PNG文件尾数据块(IEND)
    #-------------------------------------------------------------------------- 
    def make_iend
      ie_size = [0].pack("N")
      ie_sign = "IEND"
      ie_crc = [Zlib.crc32(ie_sign)].pack("N")
      return ie_size + ie_sign + ie_crc
    end
  end
end
#==============================================================================
# ■ Bitmap
#------------------------------------------------------------------------------
# 　关联到Bitmap。
#==============================================================================
class Bitmap
  #--------------------------------------------------------------------------
  # ● 关联
  #-------------------------------------------------------------------------- 
  def make_png(name="like", path="",mode=0)
    make_dir(path) if path != ""
    Zlib::Png_File.open("temp.gz") {|gz|
      gz.make_png(self,mode)
    }
    Zlib::GzipReader.open("temp.gz") {|gz|
      $read = gz.read
    }
    f = File.open(path + name + ".png","wb")
    f.write($read)
    f.close
    File.delete('temp.gz') 
    end
  #--------------------------------------------------------------------------
  # ● 生成保存路径
  #-------------------------------------------------------------------------- 
  def make_dir(path)
    dir = path.split("/")
    for i in 0...dir.size
      unless dir == "."
        add_dir = dir[0..i].join("/")
        begin
          Dir.mkdir(add_dir)
        rescue
        end
      end
    end
  end
end
#==============================================================================
#               本脚本出自www.66rpg.com，转载请注明。
#==============================================================================
=end