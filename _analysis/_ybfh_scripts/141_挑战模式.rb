class Challenge
  def main
    file = Zlib::GzipReader.open("Data/Challenge#{$game_variables[239]}.rxdata")
    $desc=Marshal.load(file)  
    # 读取描绘存档文件用的角色数据
    characters = Marshal.load(file)
    # 读取测量游戏时间用画面计数
    Graphics.frame_count = Marshal.load(file)
    # 读取校验
    crcs = Marshal.load(file)
    # 读取文档字串
    strings = Marshal.load(file)
    # 校验检测
    key = 20120430
    strings.each_index do |i|
      key = Zlib.crc32(strings[i],key)
      unless crcs[i] == key
      file.close
      raise "file check error"
      return
      end
    end
    # 读取各种游戏对像
    $game_system = Marshal.load(Zlib::Inflate.inflate(strings[0]))
    $game_variables = Marshal.load(Zlib::Inflate.inflate(strings[1]))
    $game_self_switches = Marshal.load(Zlib::Inflate.inflate(strings[2]))
    $game_switches = Marshal.load(Zlib::Inflate.inflate(strings[3]))
    $game_troop = Marshal.load(Zlib::Inflate.inflate(strings[4]))
    $game_map = Marshal.load(Zlib::Inflate.inflate(strings[5]))
    $game_player = Marshal.load(Zlib::Inflate.inflate(strings[6]))
    $game_screen = Marshal.load(Zlib::Inflate.inflate(strings[7]))
    $game_actors = Marshal.load(Zlib::Inflate.inflate(strings[8]))
    $game_party = Marshal.load(Zlib::Inflate.inflate(strings[9]))
    $floorenemies = Marshal.load(Zlib::Inflate.inflate(strings[10]))
    $fledam = Marshal.load(Zlib::Inflate.inflate(strings[11]))
    $movedevents = Marshal.load(Zlib::Inflate.inflate(strings[12]))
    if strings.size>13
      $new_map = Marshal.load(Zlib::Inflate.inflate(strings[13]))
    else
      $new_map=[]
    end
    if $game_system.magic_number != $data_system.magic_number
      # 重新装载地图
      $game_map.setup($game_map.map_id)
      $game_player.center($game_player.x, $game_player.y)
    end
    Graphics.frame_count=0
    # 刷新同伴成员
    $game_party.refresh
    file.close
    # 还原 BGM、BGS
    $game_system.bgm_play($game_system.playing_bgm)
    $game_system.bgs_play($game_system.playing_bgs)

    # 刷新地图 (执行并行事件)
    $game_map.update
    Graphics.update
    # 刷新输入信息
    Input.update
    # 切换到地图画面
    $scene = Scene_Map.new
  end
end