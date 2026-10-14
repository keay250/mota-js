#==============================================================================
# ■ Main
#------------------------------------------------------------------------------
# 　各定义结束后、从这里开始实际处理。
#==============================================================================
begin
=begin
bb=0
START =201
  MAX_SIZE=300 #截止到目前XX号地图
  NO_USE=[]
  #NO_USE[8]=1 #不统计8号地图就这样做
  for p in START...MAX_SIZE+1
    next if NO_USE[p]
    id=sprintf("%03d",p)
  next if !FileTest.exist?("Data/Map#{id}.rxdata") 
  a = load_data("Data/Map#{id}.rxdata")
  for i in a.events.keys
    ev=a.events[i]
    for j in ev.pages
      for k in j.list
        if k.code==401 || k.code==101
          next if k.parameters[0][k.parameters[0].size-3,3]=="："
          bb+=k.parameters[0].size/3
          if k.parameters[0].split("少年帝皇").size>1
            p p,k.parameters[0]
            end
        end
      end
    end
  end
  Graphics.update if p%5==0
  end
  #p bb
=end
=begin
 lpRootPathName="C:\\"
    lpVolumeNameBuffer="\0"*256
    val="\0"*256
    MaximumComponentLength=0
    lpFileSystemNameBuffer="\0"*256
    FileSystemFlags=0
  gps = Win32API.new('kernel32', 'GetVolumeInformation','pplpllpl', 'l')
  a=gps.call(lpRootPathName, 
            lpVolumeNameBuffer,
            255, 
            val,
            MaximumComponentLength, 
            FileSystemFlags, 
            lpFileSystemNameBuffer,
            255)
  val.delete!("\0")
  oldval=val.clone
  s=""
  for i in 0...val.size
    s+=sprintf("%03d",val[i])
  end
  s+="00000"
  k=20 #密匙（0~500）
  #加密
  for j in 0...k
    for i in 0...val.size
      val[(i+j)%val.size]=(val[(i+j)%val.size]+i*i*3)%256
    end
  end
  count=0
  sw=false
  for q in 0...4
    count=0
    t=val.clone
    while t !=oldval
      for i in 0...t.size
        id=(i+t.size-count%t.size+q)%t.size
        t[id]=(t[id]+256-i*i*3)%256
      end
      count+=1
      if count>500
        break
      end
      if t==oldval
        sw=true
        break
      end
    end
    break if sw
  end
  if !sw
    p "请勿修改"
    exit
  end
p count
  exit
=end
=begin
  a=Bitmap.new("30-Monster.png")
  b=Bitmap.new(128,128)
  for i in 0...4
    b.blt(4,i*32,a,Rect.new(i*72+0,128,24,32))
    b.blt(4+32,i*32,a,Rect.new(i*72+24,128,24,32))
    b.blt(4+64,i*32,a,Rect.new(i*72+48,128,24,32))
    b.blt(4+96,i*32,a,Rect.new(i*72+24,128,24,32))
  end
  b.make_png("300.png")
=end
=begin
 a=Bitmap.new("SF_Outside_B.png")
  b=Bitmap.new("寒夜冰川.png")
  p=96
  q=18*32
  b.blt(0+p,0+q,a,Rect.new(384,384,128,128))
  b.make_png("寒夜冰川.png")
=end
=begin
  b.blt(0+p,32+q,a,Rect.new(0,96,16,32))
  b.blt(80+p,32+q,a,Rect.new(48,96,16,32))
  b.blt(0+p,64+q,a,Rect.new(0,128,16,32))
  b.blt(80+p,64+q,a,Rect.new(48,128,16,32))
  b.blt(16+p,32+q,a,Rect.new(16,96,32,32))
  b.blt(48+p,32+q,a,Rect.new(16,96,32,32))
  b.blt(16+p,64+q,a,Rect.new(16,128,32,32))
  b.blt(48+p,64+q,a,Rect.new(16,128,32,32))
=end
=begin
  b.blt(0+p,32+q,a,Rect.new(0,32,16,16))
  b.blt(80+p,32+q,a,Rect.new(48,32,16,16))
  b.blt(0+p,112+q,a,Rect.new(0,80,16,16))
  b.blt(80,112+q,a,Rect.new(48,80,16,16))
      
  b.blt(16+p,32+q,a,Rect.new(16,32,32,16))
  b.blt(48+p,32+q,a,Rect.new(16,32,32,16))
  b.blt(16+p,112+q,a,Rect.new(16,80,32,16))
  b.blt(48+p,112+q,a,Rect.new(16,80,32,16))
  b.blt(0+p,48+q,a,Rect.new(0,48,16,32))
  b.blt(0+p,80+q,a,Rect.new(0,48,16,32))
  b.blt(80+p,48+q,a,Rect.new(48,48,16,32))
  b.blt(80+p,80+q,a,Rect.new(48,48,16,32))
      
  b.blt(16+p,48+q,a,Rect.new(16,48,32,32))
  b.blt(16+p,80+q,a,Rect.new(16,48,32,32))
  b.blt(48+p,48+q,a,Rect.new(16,48,32,32))
  b.blt(48+p,80+q,a,Rect.new(16,48,32,32))
=end

=begin
  list=Bitmap.new("Futuristic_A4.png")
  b=Bitmap.new(96,128)
  a=Bitmap.new(64,96)
  for j in 0...4
    for i in 0...8
      a.blt(0,0,list,Rect.new(i*64,j*160,64,96))
      
      b.blt(0,0,a,Rect.new(0,0,32,32))
      b.blt(64,0,a,Rect.new(32,0,32,32))
      
      b.blt(0,32,a,Rect.new(0,32,16,16))
      b.blt(80,32,a,Rect.new(48,32,16,16))
      b.blt(0,112,a,Rect.new(0,80,16,16))
      b.blt(80,112,a,Rect.new(48,80,16,16))
      
      b.blt(16,32,a,Rect.new(16,32,32,16))
      b.blt(48,32,a,Rect.new(16,32,32,16))
      b.blt(16,112,a,Rect.new(16,80,32,16))
      b.blt(48,112,a,Rect.new(16,80,32,16))
      b.blt(0,48,a,Rect.new(0,48,16,32))
      b.blt(0,80,a,Rect.new(0,48,16,32))
      b.blt(80,48,a,Rect.new(48,48,16,32))
      b.blt(80,80,a,Rect.new(48,48,16,32))
      
      b.blt(16,48,a,Rect.new(16,48,32,32))
      b.blt(16,80,a,Rect.new(16,48,32,32))
      b.blt(48,48,a,Rect.new(16,48,32,32))
      b.blt(48,80,a,Rect.new(16,48,32,32))
      b.make_png("Futuristic_A4-"+sprintf("%02d",j*8+i), "Auto/")
      a.clear
      b.clear
    end
  end
  p "完成"
  exit
=end
=begin
list=Bitmap.new("TileA1_b-07.png")
  b=Bitmap.new(384,128)
  a=Bitmap.new(96,128)
  a.blt(0,0,list,Rect.new(0,0,96,128))
    for i in 0...4
      l=i*8
      r=32-i*8
      for j in 0...12
      b.blt(0+j%3*32+i*96,0+j/3*32,a,Rect.new(0+j%3*32,32-l+j/3*32,32,l))
      b.blt(0+j%3*32+i*96,l+j/3*32,a,Rect.new(0+j%3*32,0+j/3*32,32,32-l))
      end
    end
      b.make_png("1111"+sprintf("%02d",j*8+i), "Auto/")
  p "完成"
  exit
=end
=begin
list=Bitmap.new("TileA1_b.png")
  b=Bitmap.new(96*4,128)
  a=Bitmap.new(64,96)
  for j in 0...8
    for i in 0...4
      if i==3
        a.blt(0,0,list,Rect.new(j%2*256+64,j/2*96,64,96))
      else
        a.blt(0,0,list,Rect.new(j%2*256+i*64,j/2*96,64,96))
      end
      b.blt(0+i*96,0,a,Rect.new(0,0,32,32))
      b.blt(64+i*96,0,a,Rect.new(32,0,32,32))
      
      b.blt(0+i*96,32,a,Rect.new(0,32,16,16))
      b.blt(80+i*96,32,a,Rect.new(48,32,16,16))
      b.blt(0+i*96,112,a,Rect.new(0,80,16,16))
      b.blt(80+i*96,112,a,Rect.new(48,80,16,16))
      
      b.blt(16+i*96,32,a,Rect.new(16,32,32,16))
      b.blt(48+i*96,32,a,Rect.new(16,32,32,16))
      b.blt(16+i*96,112,a,Rect.new(16,80,32,16))
      b.blt(48+i*96,112,a,Rect.new(16,80,32,16))
      b.blt(0+i*96,48,a,Rect.new(0,48,16,32))
      b.blt(0+i*96,80,a,Rect.new(0,48,16,32))
      b.blt(80+i*96,48,a,Rect.new(48,48,16,32))
      b.blt(80+i*96,80,a,Rect.new(48,48,16,32))
      
      b.blt(16+i*96,48,a,Rect.new(16,48,32,32))
      b.blt(16+i*96,80,a,Rect.new(16,48,32,32))
      b.blt(48+i*96,48,a,Rect.new(16,48,32,32))
      b.blt(48+i*96,80,a,Rect.new(16,48,32,32))
            a.clear
    end
      b.make_png("TileA1_b-"+sprintf("%02d",j*8+i), "Auto/")
      b.clear
  end
  p "完成"
  exit
=end
  # 准备过渡
  # 设置系统默认字体
=begin
  a = load_data("Data/Enemies.rxdata")
  c=[]
  q=a[784] #指定一个空的编号（但要已拥有的）
  for i in 0...2000
    if i<=a.size
      c[i]=a[i]
    else
      c[i]=q
    end
  end
  save_data(c,"Data/Enemies.rxdata")
  exit
=end
#a = load_data("Data/Enemies.rxdata")
#a[133].name="魔导师遗骸:10:360:300-200&3:720-3&1:30-50&2"
#save_data(a,"Data/Enemies.rxdata")
#exit
 Font.default_name = (["黑体","新細明體","宋体","標楷體","Arial"])
  # 生成场景对像 (标题画面)
  Graphics.freeze
  $scene = Scene_Title.new
  # $scene 为有效的情况下调用 main 过程
  while $scene != nil
    $scene.main
  end
  # 淡入淡出
  Graphics.transition(20)
rescue Errno::ENOENT
  # 补充 Errno::ENOENT 以外错误
  # 无法打开文件的情况下、显示信息后结束
  filename = $!.message.sub("No such file or directory - ", "")
  print("找不到文件 #{filename}。 ")
#rescue

#p $!
end