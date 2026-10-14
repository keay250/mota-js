def get_achievement(num,vab=[])
  if !$merit[num][0]
    return if $game_switches[65] && num !=120
    sw=false
    case num
    when 1..50
      sw=true
    when 101 #一滴不漏
      value=20
      $game_variables[208][num]=0 if $game_variables[208][num]==nil
      a=$game_actors[$game_variables[1]+1]
      $game_variables[208][num]+=1 if a.hp==a.maxhp
      sw = ($game_variables[208][num]>=value)
    when 102 #移动血瓶
      value=2000
      return if $game_variables[10]<=0
      $game_variables[208][num]=0 if $game_variables[208][num]==nil
      a=$game_actors[$game_variables[1]+1]
      $game_variables[208][num]+=[$game_variables[10],a.maxhp-a.hp].min
      sw = ($game_variables[208][num]>=value)
    when 103 #一战到底
      value=6
      a=$game_actors[$game_variables[1]+1]
      $game_variables[208][num]=[0,a.hp] if $game_variables[208][num]==nil
      
      if $game_variables[10]>0
        $game_variables[208][num][0]=0
      end
      if $game_variables[208][num][1]!=a.hp 
        $game_variables[208][num][0]=0
      end
      if $game_variables[10].abs>a.hp/3 && $game_variables[10].abs<a.hp
        $game_variables[208][num][0]+=1
      else
        $game_variables[208][num][0]=0
      end
      $game_variables[208][num][1]=a.hp+$game_variables[10]

      sw = ($game_variables[208][num][0]>=value)
    when 104 #碾压的开始
      sw=($game_party.item_number(3) >= 1 && $game_variables[177] <= 1)
    when 105 #强者的力量
      sw=($game_variables[128]>=0 && $game_variables[177]==0)
    when 106 #以一敌多
      a=0
      $game_map.events.each_value{ |value|
        a+=1 if value.name=="黄门"
      }
      sw = (a==6)
    when 107 #恶魔诱惑
      sw=($game_variables[178]+$game_variables[179]==0)
    when 108 #征服死亡
      sw=($game_actors[$game_variables[1]+1].hprate==1 && $game_variables[177]==0)
    when 109 #吃你一击又如何
      sw=(Enemy_property.new(216).merit109_check)
    when 110 #粉碎石像
      return if $game_switches[146]
      $game_variables[208][num]=[] if $game_variables[208][num]==nil
      if $game_variables[4]==187 && $game_variables[208][num][0]==nil
        $game_variables[208][num][0]=1
      end
      if $game_variables[4]==196 && $game_variables[208][num][1]==nil
        $game_variables[208][num][1]=1
      end
      if $game_variables[4]==197 && $game_variables[208][num][2]==nil
        $game_variables[208][num][2]=1
      end
      sw=($game_variables[208][num]==[1,1,1])
    when 111
      sp=$game_actors[$game_variables[1]+1].power2+$game_variables[157]-$game_variables[217]
      for i in $game_actors[$game_variables[1]+1].equip_id
      if i !=nil && $data_weapons[i]!= nil
        for j in $data_weapons[i].name.split(':')
          if j[0,1]=="C"
            sp+=j[1,j.size-1].to_i
          end
        end
      end
      end
      sw=(sp<=0)
    when 112,113,114,115,116,117 #无影身法
      sw=true
    when 118
      sw=(Enemy_property.new(324).merit118_check)
    when 119,120,121,122,123,124,125,126,127,128
      sw=true
    when 201 #勇气可嘉
      sw=true
    when 202 #勤恳好学
      value=15
      $game_variables[208][num]=0 if $game_variables[208][num]==nil
      $game_variables[208][num]+=1
      sw = ($game_variables[208][num]>=value)
    when 203 #原地传送
      value=3
      $game_variables[208][num]=0 if $game_variables[208][num]==nil
      if $game_variables[168]==$game_map.map_id
        $game_variables[208][num]+=1
      else
        $game_variables[208][num]=0
      end
      sw = ($game_variables[208][num]>=value)
    when 204 #手持神装
      value=10
      $game_variables[208][num]=0 if $game_variables[208][num]==nil
      $game_variables[208][num]+=1 if $game_actors[1].equip_id.include?(5)
      sw = ($game_variables[208][num]>=value)
    when 205..217 #错误选择
      sw=true
    when 218
      sw=false
      for j in $game_variables[232]
        if j[0]==5
          sw=(j[2]>=30)
        end
      end
    when 219 #ZZXC
      $game_variables[208][num]=[0,0] if $game_variables[208][num]==nil
      value=vab[0]
      bb=[1,1,2,3]
      if bb[$game_variables[208][num][0]]==value
        $game_variables[208][num][0]+=1
        if $game_variables[208][num][0]>3
          $game_variables[208][num][0]=0
          $game_variables[208][num][1]+=1
        end
      else
        $game_variables[208][num][0]=0
        $game_variables[208][num][1]=0
      end
      sw=($game_variables[208][num][1]>=3)
    when 220 #王者的感觉
      sw=false
      $game_variables[208][num]=0 if $game_variables[208][num]==nil
      d=$game_player.direction
      if d==2
        $game_variables[208][num]+=1
      else
        $game_variables[208][num]=0
      end
      if $game_variables[208][num]>=400
        sw=true
      end
    when 221,223,224,225,226,227,228,229 #儿时的梦想
      sw=true
    when 222 #隐身=无敌？
      sw=(-$game_variables[10]>=$game_actors[1].hp)
    end
    
    if sw
      $merit[num][0] = true
      save_data($merit, "Save/Merit.rxdata")
      
      #Audio.me_play("Audio/ME/Victory1.ogg", 100, 100)
      text_value = merit_text[num][2]
      str=["剧情","技巧","探索"]
      bitmap = Bitmap.new(100, 100)
      textwidth = bitmap.text_size(text_value).width + 95
      itempop_window = Window_Tips.new(400-textwidth/2, 128, textwidth, 100)
      itempop_window.contents = Bitmap.new(itempop_window.width - 32, itempop_window.height - 32)
      itempop_window.contents.draw_text(0, 0, 160, 32, "解锁#{str[(num-1)/100]}成就：")
      itempop_window.contents.draw_text(32, 36, 240, 32, text_value)
      for i in 0..60
        Graphics.update
      end
      for i in 0..30
        itempop_window.opacity -= 10
        itempop_window.contents_opacity -= 10
        Graphics.update
      end
      itempop_window.dispose
      
      for i in 0..3
        Graphics.update
      end
      
    end
  end
end
#==============================================================================
# ■ Window_Tips
#------------------------------------------------------------------------------
# 　显示增减物品、金钱和装备的窗口
#==============================================================================

class Window_Tips < Window_Base
  #--------------------------------------------------------------------------
  # ● 初始化对象
  #--------------------------------------------------------------------------
  def initialize(x = 170, y = 128, width = 300, height = 96)
    super
    self.z=5999
  end
  
  #--------------------------------------------------------------------------
  # ● 增强绘制物品名称
  #--------------------------------------------------------------------------
  def adv_draw_item_name(item, x, y)
    return unless item
    change_color(normal_color, true)
    draw_text(x + 24, y, width, line_height, item.name)
  end
  
end