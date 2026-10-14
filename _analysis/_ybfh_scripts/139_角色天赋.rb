class Window_Genius < Window_Base
  #--------------------------------------------------------------------------
  # ● 初始化对像
  #--------------------------------------------------------------------------
  attr_reader   :index                    # 光标位置
  attr_reader   :skill                    # 光标位置
  attr_reader   :prepose                    # 光标位置
  def initialize
    super(0,0,576,480)
    self.windowskin=RPG::Cache.windowskin("001-Blue02")
    @backbitmap=RPG::Cache.picture("GBack")
    @skillbitmap=RPG::Cache.picture("GSkill")
    if $game_variables[226]==0
      $game_variables[226]=[]
    end
    if $game_switches[187] #洗点模式
      $game_variables[274]=$game_variables[273]
    end
    @prepose=[]
    @skill=[]
    for i in 0..40
      @skill[i]=[]
    end
    @skill[0][4]=[1,5]
    @skill[1][3]=[2,5]
    @skill[1][5]=[3,5]
    @skill[0][6]=[4,7]
    @skill[1][6]=[7,10]
    @skill[1][0]=[8,5]
    @skill[0][0]=[9,3]
    @skill[0][1]=[10,3]
    
  if $game_variables[227]>=1
    @skill[2][4]=[11,7]
    @prepose[11]=[[1,5]]
    @skill[3][3]=[12,7]
    @prepose[12]=[[2,5]]
    @skill[3][5]=[13,7]
    @prepose[13]=[[3,5]]
    @skill[3][0]=[14,7]
    @prepose[14]=[[8,5]]
    @skill[2][0]=[15,5]
    @prepose[15]=[[9,3]]
    @skill[2][1]=[16,5]
    @prepose[16]=[[10,3]]
    @skill[3][1]=[17,5]
    
    @skill[2][2]=[19,5]
    @skill[2][5]=[18,6]
    @skill[3][6]=[5,10]
    @skill[2][6]=[6,10]
  end  
  if $game_variables[227]>=2
    @skill[4][2]=[20,5]
    @skill[4][4]=[21,5]
    @prepose[20]=[[14,7],[15,5],[16,5],[21,-1]]
    @prepose[21]=[[11,7],[12,7],[13,7],[20,-1]]
  end
  if $game_variables[227]>=3
    if $game_switches[194]
      @skill[5][1]=[22,5]
      @skill[5][3]=[23,10]
      @skill[5][5]=[24,7]
    end
  end
    for i in 0...40
      for j in 0...10
        if @skill[i][j] !=nil
          @maxlen=i
          if $game_variables[226][@skill[i][j][0]]==nil
            $game_variables[226][@skill[i][j][0]]=0
          end
        end
      end
    end
    if $game_variables[226][999]==nil
      $game_variables[226][999]=0
    end
    @maxlen=[$game_variables[227]*2+1,@maxlen].min
    self.contents = Bitmap.new(width - 32, (@maxlen+1)*80)
 #   if $game_variables[226][0]==nil
      @index=nil
      for i in 0...40
        for j in 0...10
          if @skill[i][j] !=nil
            @index=[i,j]
            break
          end
        end
        break if @index !=nil
      end
  #  else
   #   @index=$game_variables[226][0]
  #  end
    @skill[@maxlen+1][2]=[0,0]
    @skill[@maxlen+1][4]=[0,0]
    @skill[@maxlen+1][6]=[0,0]
    refresh
  end  
  def dispose
    super
  end
  def get_height
    return self.contents.height
  end
  def get_maxlen
    return @maxlen
  end
  #--------------------------------------------------------------------------
  # ● 自定义光标
  #--------------------------------------------------------------------------
  def update
    super
    if Input.repeat?(Input::RIGHT)
      check=false
      y=@index[0]
      x=@index[1]
      min=100
      while !check
        x+=1
        if @skill[y][x]!=nil
          save=[y,x]
          check=true
        end
        if x>=10
          x=-1
        end
      end
      if check
        @index[0]=save[0]
        @index[1]=save[1]
      end
    end
    if Input.repeat?(Input::LEFT)
      check=false
      y=@index[0]
      x=@index[1]
      min=100
      while !check
        x-=1
        if x<=-1
          x=10
        end
        if @skill[y][x]!=nil
          save=[y,x]
          check=true
        end
      end
      if check
        @index[0]=save[0]
        @index[1]=save[1]
      end
    end
    if Input.repeat?(Input::UP)
      check=false
      y=@index[0]
      x=@index[1]
      min=100
      while !check
        y-=1
        for j in 0...10
          if @skill[y][j]!=nil
            if (j-x).abs<min
              min=(j-x).abs
              save=[y,j]
            end
            check=true
          end
        end
        if y<0
          y=@maxlen+2
        end
      end
      if check
        @index[0]=save[0]
        @index[1]=save[1]
      end
    end
    if Input.repeat?(Input::DOWN) 
      check=false
      y=@index[0]
      x=@index[1]
      min=100
      if y>=@maxlen+1
        y=-1
      end
      while !check
        y+=1
        for j in 0...10
          if @skill[y][j]!=nil
            if (j-x).abs<min
              min=(j-x).abs
              save=[y,j]
            end
            check=true
          end
        end
        if y>=@maxlen+1
          y=-1
        end
      end
      if check
        @index[0]=save[0]
        @index[1]=save[1]
      end
    end
    self.oy = [[@index[0] * 80-240,0].max,[@maxlen*80-240,0].max].min
    # 更新国标矩形
    if @index[0]==@maxlen+1
      self.cursor_rect.set((@index[1]-1)/2*130+94,@index[0]*80+40-self.oy, 110,32)
    else
      self.cursor_rect.set(@index[1]*64+64-2,@index[0]*80+16-self.oy-2, 48+4,64+4)
    end
  end
  def get_size
    return @maxlen+1
  end
  #--------------------------------------------------------------------------
  # ● 设置文本
  #     text  : 窗口显示的字符串
  #     align : 对齐方式 (0..左对齐、1..中间对齐、2..右对齐)
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    str="[卸除装备]"
    xx=16
    ss=["上","位","英","雄"]
    yy=40
    for i in 0...4
      x=xx
      y=yy+i*20
      str=ss[i]
      self.contents.font.color = Color.new(0,0,0,255)
      self.contents.draw_text(x-1,y, 32, 32, str)
      self.contents.draw_text(x,y-1, 32, 32, str)
      self.contents.draw_text(x+1,y, 32, 32, str)
      self.contents.draw_text(x,y+1, 32, 32, str)
      self.contents.font.color = text_color(15)
      self.contents.draw_text(x,y, 32, 32, str)
    end
    if $game_variables[227]>=1
      ss=["传","奇","王","者"]
      yy=200
      for i in 0...4
        x=xx
        y=yy+i*20
        str=ss[i]
        self.contents.font.color = Color.new(0,0,0,255)
        self.contents.draw_text(x-1,y, 32, 32, str)
        self.contents.draw_text(x,y-1, 32, 32, str)
        self.contents.draw_text(x+1,y, 32, 32, str)
        self.contents.draw_text(x,y+1, 32, 32, str)
        self.contents.font.color = text_color(14)
        self.contents.draw_text(x,y, 32, 32, str)
      end
    end
    if $game_variables[227]>=2
      ss=["生命跃迁"]
      yy=354
      for i in 0...1
        x=xx
        y=yy+i*20
        str=ss[i]
        self.contents.font.color = Color.new(0,0,0,255)
        self.contents.draw_text(x-1,y, 132, 32, str)
        self.contents.draw_text(x,y-1, 132, 32, str)
        self.contents.draw_text(x+1,y, 132, 32, str)
        self.contents.draw_text(x,y+1, 132, 32, str)
        self.contents.font.color = text_color(6)
        self.contents.draw_text(x,y, 132, 32, str)
      end
    end
    if $game_variables[227]>=3
      ss=["命源","感悟"]
      yy=414
      for i in 0...2
        x=xx
        y=yy+i*30
        str=ss[i]
        self.contents.font.color = Color.new(0,0,0,255)
        self.contents.draw_text(x-1,y, 132, 32, str)
        self.contents.draw_text(x,y-1, 132, 32, str)
        self.contents.draw_text(x+1,y, 132, 32, str)
        self.contents.draw_text(x,y+1, 132, 32, str)
        self.contents.font.color = text_color(6)
        self.contents.draw_text(x,y, 132, 32, str)
      end
    end
    rect=Rect.new(0,0,48,64)
    for i in 0...@maxlen+1
      for j in 0...10
        if @skill[i][j]!=nil
          k=@skill[i][j][0]-1
          self.contents.blt(j*64+64+4,i*80+16+4, @skillbitmap,Rect.new(k%10*40,k/10*40,40,40))
          self.contents.blt(j*64+64,i*80+16, @backbitmap,rect)
        end
      end
    end
    
  end
end

class Scene_Genius
  def main
    text=merit_text
    $point=0
    for i in 1...301
      if text[i]!=nil && $merit[i][0]
        $point+=text[i][1]
      end
    end
    @genius_window=Window_Genius.new
    @item_window = Window_GeniusHelp.new(@genius_window.prepose)
    $game_variables[228]=$game_variables[226].clone
    $game_variables[228][0]=$game_variables[225] #剩余天赋点
    #$game_variables[226][999] 当前消耗的成就点
    @text_window = Window_GeniusText.new(@genius_window.skill,@genius_window.get_height,@genius_window.get_maxlen)
    @confirm_window = Window_Base.new(120, 188, 400, 64)
    @confirm_window.contents = Bitmap.new(368, 32)
    @confirm_window.contents.font.size = 20
    @confirm_window.visible = false
    @confirm_window.z = 1500
    @confirm_window.windowskin=RPG::Cache.windowskin("001-Blue02")
    @yes_no_window = Window_Command.new(330, ["确认兑换", "取消兑换","全部兑换"],3)
    @yes_no_window.visible = false
    @yes_no_window.active = false
    @yes_no_window.index = 1
    @yes_no_window.height=64
    @yes_no_window.y = 252
    @yes_no_window.z = 1500
    @yes_no_window.windowskin=RPG::Cache.windowskin("001-Blue02")
    @saveindex=nil
    Graphics.transition
    # 主循环
    loop do
      # 刷新游戏画面
      Graphics.update
      # 刷新输入信息
      Input.update
      if @genius_window.active
        @genius_window.update
      end
      @text_window.oy=@genius_window.oy
      # 刷新画面
      update
      # 如果画面切换的话的就中断循环
      if $scene != self
        break
      end
    end
    $game_switches[187]=false
    # 准备过渡
    Graphics.freeze
    # 释放窗口
    @genius_window.dispose
    @item_window.dispose
    @text_window.dispose
  end
  def update
    if @yes_no_window.active
      @yes_no_window.update
      if Input.trigger?(Input::C)
        if @yes_no_window.index==0
          need=100
          if $game_variables[228][999]==0
            need+=500
          end
          if $game_variables[228][999]+need<=$point
            $game_variables[228][999]+=need
            $game_variables[228][0]+=1
            $game_variables[226][999]=$game_variables[228][999]
            $game_variables[225]+=1
            Audio.se_play("Audio/SE/Hand_of_Midas") 
            @text_window.refresh
          else
            Audio.se_play("Audio/SE/057-Wrong01") 
            return
          end
        end
        if @yes_no_window.index==2
          need=100
          if $game_variables[228][999]==0
            need+=500
          end
          sw=false
          while $game_variables[228][999]+need<=$point
             $game_variables[228][999]+=need
            $game_variables[228][0]+=1
            $game_variables[226][999]=$game_variables[228][999]
            $game_variables[225]+=1
            sw=true
            need=100
          end
          if sw
            Audio.se_play("Audio/SE/Hand_of_Midas")
          else
            Audio.se_play("Audio/SE/057-Wrong01") 
            return
          end
          @text_window.refresh
        end
        @genius_window.active=true
        @confirm_window.visible=false
        @yes_no_window.active=false
        @yes_no_window.visible=false
      end
      if Input.trigger?(Input::B)
        $game_system.se_play($data_system.cancel_se)
        @genius_window.active=true
        @confirm_window.visible=false
        @yes_no_window.active=false
        @yes_no_window.visible=false
      end
      return
    end
    if @saveindex !=@genius_window.index
      a=@genius_window.index
      @item_window.refresh(@genius_window.skill[a[0]][a[1]])
      @saveindex=@genius_window.index.clone
    end
    if Input.trigger?(Input::B)
      a=@genius_window.index
      if a[0]==@genius_window.get_size
        # 演奏取消 SE
        $game_system.se_play($data_system.cancel_se)
        $scene = Scene_Map.new
      elsif $game_switches[187] #洗点
        a=@genius_window.skill[a[0]][a[1]]
        if $game_variables[274]<$game_variables[273] && $game_variables[228][a[0]]<$game_variables[226][a[0]] && check_prepose(a[0])
          Audio.se_play("Audio/SE/002-System02") 
          $game_variables[228][a[0]]+=1
          $game_variables[274]+=1
          a=@genius_window.index
          @item_window.refresh(@genius_window.skill[a[0]][a[1]])
          @text_window.refresh
        else
          Audio.se_play("Audio/SE/057-Wrong01") 
        end
      elsif $game_variables[228][0]==$game_variables[225]
        Audio.se_play("Audio/SE/057-Wrong01") 
      elsif check_delprepose(@genius_window.skill[a[0]][a[1]][0])
        Audio.se_play("Audio/SE/057-Wrong01") 
      else
        #加点
        a=@genius_window.skill[a[0]][a[1]]
        if $game_variables[228][a[0]]>$game_variables[226][a[0]]
          Audio.se_play("Audio/SE/008-System08") 
          $game_variables[228][a[0]]-=1
          $game_variables[228][0]+=1
          a=@genius_window.index
          @item_window.refresh(@genius_window.skill[a[0]][a[1]])
          @text_window.refresh
        end
        ##
      end
      return
    end
    # 按下 C 键的情况下
    if Input.trigger?(Input::C)
      a=@genius_window.index
      if a[0]==@genius_window.get_size
        #最下一行
        if a[1]==2 #确认加点
          if $game_switches[187] #洗点
            $game_system.se_play($data_system.equip_se)
            for p in 1...$game_variables[226].size
              i=$game_variables[226].size-p
              next if $game_variables[226][i]==nil
              if $game_variables[226][i]>$game_variables[228][i]
                j=$game_variables[226][i]
                while j>$game_variables[228][i]
                  skill_lvdown(i,j)
                  j-=1
                end
              end
            end
            $game_variables[225]+=$game_variables[273]-$game_variables[274]
            $game_variables[273]=$game_variables[274]
            $game_variables[226]=$game_variables[228].clone
            @text_window.refresh
          else
            ###加点
            if $game_variables[228][0]<0 || $game_switches[168]
              Audio.se_play("Audio/SE/057-Wrong01") 
              return
            end
            $game_system.se_play($data_system.equip_se)
            for i in 1...$game_variables[226].size
              next if $game_variables[226][i]==nil
              if $game_variables[226][i]<$game_variables[228][i]
                for j in $game_variables[226][i]+1...$game_variables[228][i]+1
                  skill_lvup(i,j)
                end
              end
            end
            $game_variables[226]=$game_variables[228].clone
            $game_variables[225]=$game_variables[228][0]
            @text_window.refresh
            ####
          end
        end
        if a[1]==4 #退出
          # 演奏取消 SE
          $game_system.se_play($data_system.cancel_se)
          $scene = Scene_Map.new
        end
        if a[1]==6 #兑换天赋
          if $game_switches[187]
            Audio.se_play("Audio/SE/057-Wrong01") 
            return
          end
          if  $game_variables[228][999]==0
            string = "100成就点可以兑换1天赋点，第一次兑换需要额外消耗500成就点"
            cw = @confirm_window.contents.text_size(string).width
          else
            string = "100成就点可以兑换1天赋点"
            cw = @confirm_window.contents.text_size(string).width+48
          end
          @confirm_window.width=cw-16
          @confirm_window.x=400-@confirm_window.width/2
          @yes_no_window.x=400-@yes_no_window.width/2
          @confirm_window.contents.clear
          @confirm_window.contents = Bitmap.new(cw-48,32)
          center = @confirm_window.contents.width/2 - cw /2
          @confirm_window.contents.draw_text(0, 0, cw, 30, string)
          @genius_window.active=false
          @confirm_window.visible=true
          @yes_no_window.active=true
          @yes_no_window.visible=true
        end
      else
        if $game_switches[187] #洗点
          a=@genius_window.skill[a[0]][a[1]]
          if $game_variables[274]>0 && $game_variables[228][a[0]]>0 && check_onedelpre(a[0])
             Audio.se_play("Audio/SE/002-System02") 
            $game_variables[228][a[0]]-=1
            $game_variables[274]-=1
            a=@genius_window.index
            @item_window.refresh(@genius_window.skill[a[0]][a[1]])
            @text_window.refresh
          else
            Audio.se_play("Audio/SE/057-Wrong01") 
          end
         # if a[1]
        else
          #加点
          a=@genius_window.skill[a[0]][a[1]]
          if $game_variables[228][a[0]]<a[1] && check_prepose(a[0])# && $game_variables[228][0]>0
            Audio.se_play("Audio/SE/002-System02") 
            $game_variables[228][a[0]]+=1
            $game_variables[228][0]-=1
            a=@genius_window.index
            @item_window.refresh(@genius_window.skill[a[0]][a[1]])
            @text_window.refresh
          else
            Audio.se_play("Audio/SE/057-Wrong01") 
          end
          ###
        end
      end
    end
  end
  
  def check_prepose(j)
    return true if @genius_window.prepose[j]==nil
    for i in @genius_window.prepose[j]
      if i[1]==-1
        if $game_variables[228][i[0]]!=0
          return false
        end
      else
        if $game_variables[228][i[0]]<i[1]
          return false
        end
      end
    end
    return true
  end
  
  def check_delprepose(j)
    val=$game_variables[228][j]
    for i in 1...@genius_window.prepose.size+1
      next if i==j
      if @genius_window.prepose[i] !=nil && $game_variables[228][i]>0
        for k in @genius_window.prepose[i]
          if k[0]==j
            if val-1<k[1]
              return true
            end
          end
        end
      end
    end
    return false
  end
  
  def check_onedelpre(j)
    for i in 1...@genius_window.prepose.size+1
      next if i==j
      next if @genius_window.prepose[i]==nil
      for q in @genius_window.prepose[i]
        if $game_variables[228][i]>0 && q[0]==j && $game_variables[228][j]<=q[1]
          return false
        end
      end
    end
    return true
  end
  
  def skill_lvdown(id,lv) #部分加点的处理
    case id
    when 8 #毁灭阴影LV2
      for i in 0...$game_actors[$game_variables\
          [1]+1].skills.size
          k=$game_actors[$game_variables[1]+1].skills[i]
          if $data_skills[k].name[0,12]=="毁灭阴影"
            a=$game_variables[180][i].split("-")
            if lv==1
              a[0]=(a[0].to_i-2500).to_s
            else
              a[0]=(a[0].to_i-4000).to_s
            end
            if lv>=3
              a[1]=(a[1].to_i-1).to_s
            end
            if lv==3
              a[2]=(a[2].to_i-2).to_s
            end
            if lv>3
              a[2]=(a[2].to_i-4).to_s
            end
            if lv==5
              a[3]=(a[3].to_i+1).to_s
            end
            $game_variables[180][i]=a[0]+"-"+a[1]+"-"+a[2]+"-"+a[3]
          end
        end
    when 9 #灵魂支配LV2
        for i in 0...$game_actors[$game_variables\
          [1]+1].skills.size
          k=$game_actors[$game_variables[1]+1].skills[i]
          if $data_skills[k].name[0,12]=="灵魂支配"
            a=$game_variables[180][i].split("-")
            if lv==1
              a[0]=(a[0].to_i-10).to_s
              a[1]=(a[1].to_i-2).to_s
              a[2]=(a[2].to_i-100).to_s
              $game_variables[198]=a[0].to_i
            else
              a[0]=(a[0].to_i-20).to_s
              a[1]=(a[1].to_i-2).to_s
              a[2]=(a[2].to_i-200).to_s
              $game_variables[198]=a[0].to_i
            end
            $game_variables[180][i]=a[0]+"-"+a[1]+"-"+a[2]
          end
        end
    when 10 #魔王降临LV1
        for i in 0...$game_actors[$game_variables\
          [1]+1].skills.size
          k=$game_actors[$game_variables[1]+1].skills[i]
          if $data_skills[k].name[0,12]=="魔王降临"
            a=$game_variables[180][i].split("-")
            if lv==1
              a[0]=(a[0].to_i-1).to_s
            else
              a[0]=(a[0].to_i-2).to_s
            end
            $game_variables[180][i]=a[0]
          end
        end
    when 14 #毁灭阴影LV3
      for i in 0...$game_actors[$game_variables\
          [1]+1].skills.size
          k=$game_actors[$game_variables[1]+1].skills[i]
          if $data_skills[k].name[0,12]=="毁灭阴影"
            a=$game_variables[180][i].split("-")
            case lv
            when 1
              a[0]=(a[0].to_i-25000).to_s
              $game_variables[180][i]=a[0]+"-"+a[1]+"-"+a[2]+"-"+a[3]
            when 2
              a[0]=(a[0].to_i-30000).to_s
              $game_variables[180][i]=a[0]+"-"+a[1]+"-"+a[2]+"-"+a[3]
            when 3
              a[0]=(a[0].to_i-70000).to_s
              a[2]=(a[2].to_i-20).to_s
              $game_actors[$game_variables[1]+1].skills[i]=73
              $game_variables[180][i]=a[0]+"-"+a[1]+"-"+a[2]+"-"+a[3]
              for i in $game_variables[182]
                for j in 0...i.size
                  i[j]=73 if i[j]==166
                end
              end
              for i in 0...$game_variables[183].size
                if $game_variables[183][i]==166
                  $game_variables[183][i]=73
                end
              end
            when 4,5,6
              a[0]=(a[0].to_i-50000).to_s
              $game_variables[180][i]=a[0]+"-"+a[1]+"-"+a[2]+"-"+a[3]+"-"+a[4]
            when 7
              a[1]=(a[1].to_i-1).to_s
              a[4]=(a[4].to_i-1).to_s
              $game_variables[180][i]=a[0]+"-"+a[1]+"-"+a[2]+"-"+a[3]+"-"+a[4]
            end
          end
        end
    when 15 #灵魂支配LV3
        for i in 0...$game_actors[$game_variables\
          [1]+1].skills.size
          k=$game_actors[$game_variables[1]+1].skills[i]
          if $data_skills[k].name[0,12]=="灵魂支配"
            a=$game_variables[180][i].split("-")
            case lv
            when 1,2
              a[0]=(a[0].to_i-20).to_s
              a[1]=(a[1].to_i-10).to_s
              a[2]=(a[2].to_i-500).to_s
              $game_variables[198]=a[0].to_i
              $game_variables[180][i]=a[0]+"-"+a[1]+"-"+a[2]
            when 3
              $game_actors[$game_variables[1]+1].skills[i]=74
              a[1]=(a[1].to_i-10).to_s
              a[2]=(a[2].to_i-2000).to_s
              $game_variables[198]=a[0].to_i
              $game_variables[199]-=1
              $game_variables[180][i]=a[0]+"-"+a[1]+"-"+a[2]
            when 4,5
              a[0]=(a[0].to_i-30).to_s
              a[1]=(a[1].to_i-20).to_s
              a[2]=(a[2].to_i-3000).to_s
              a[3]=(a[3].to_i-1).to_s
              $game_variables[198]=a[0].to_i
              $game_variables[180][i]=a[0]+"-"+a[1]+"-"+a[2]+"-"+a[3]
            end
            $game_variables[197]=[$game_variables[197],$game_actors[$game_variables[1]+1].soul_max].min
          end
        end
    when 16 #魔王降临LV2
        for i in 0...$game_actors[$game_variables\
          [1]+1].skills.size
          k=$game_actors[$game_variables[1]+1].skills[i]
          if $data_skills[k].name[0,12]=="魔王降临"
            a=$game_variables[180][i].split("-")
            case lv
            when 1
              a[0]=(a[0].to_i-2).to_s
              $game_variables[180][i]=a[0]
            when 2
              a[0]=(a[0].to_i-3).to_s
              $game_variables[180][i]=a[0]
            when 3
              $game_actors[$game_variables[1]+1].skills[i]=109
              a[0]=(a[0].to_i-4).to_s
              $game_variables[266]=1
              $game_variables[180][i]=a[0]
            when 4,5
              a[0]=(a[0].to_i-3).to_s
              a[1]=(a[1].to_i-2).to_s
              $game_variables[180][i]=a[0]+"-"+a[1]
            end
          end
        end
    when 17 #魂之挽歌LV1
        for i in 0...$game_actors[$game_variables\
          [1]+1].skills.size
          k=$game_actors[$game_variables[1]+1].skills[i]
          if $data_skills[k].name[0,12]=="魂之挽歌"
            a=$game_variables[180][i].split("-")
            case lv
            when 1,2
            when 3,4
              a[1]=(a[1].to_i+1).to_s
            when 5
              a[1]=(a[1].to_i+1).to_s
            end
            $game_variables[180][i]=a[0]+"-"+a[1]+"-"+a[2]+"-"+a[3]+"-"+a[4]+"-"+a[5]+"-"+a[6]
          end
        end
    when 20 #灵魂化
      if lv==1
        for i in 0...$game_actors[$game_variables\
          [1]+1].skills.size
          k=$game_actors[$game_variables[1]+1].skills[i]
          if $data_skills[k].name[0,12]=="魔王降临"
            a=$game_variables[180][i].split("-")
            $game_actors[$game_variables[1]+1].skills[i]=169
            a[2]="10"
            a[3]="200"
            $game_variables[266]=3
            $game_variables[180][i]=a[0]+"-"+a[1]+"-"+a[2]+"-"+a[3]
          end
        end
      end
      for i in 0...$game_actors[$game_variables\
        [1]+1].skills.size
        k=$game_actors[$game_variables[1]+1].skills[i]
        if $data_skills[k].name[0,12]=="灵魂支配"
          a=$game_variables[180][i].split("-")
          a[1]=(a[1].to_i+20).to_s
          $game_variables[180][i]=a[0]+"-"+a[1]+"-"+a[2]+"-"+a[3]
        end
        if lv>=2 && $data_skills[k].name[0,12]=="魔王降临"
          a=$game_variables[180][i].split("-")
          a[2]=(a[2].to_i+10).to_s
          a[3]=(a[3].to_i+200).to_s
          $game_variables[180][i]=a[0]+"-"+a[1]+"-"+a[2]+"-"+a[3]
        end
      end

    end
    
  end
  
  def skill_lvup(id,lv) #部分加点的处理
    case id
    when 8 #毁灭阴影LV2
      for i in 0...$game_actors[$game_variables\
          [1]+1].skills.size
          k=$game_actors[$game_variables[1]+1].skills[i]
          if $data_skills[k].name[0,12]=="毁灭阴影"
            a=$game_variables[180][i].split("-")
            if lv==1
              a[0]=(a[0].to_i+2500).to_s
            else
              a[0]=(a[0].to_i+4000).to_s
            end
            if lv>=3
              a[1]=(a[1].to_i+1).to_s
            end
            if lv==3
              a[2]=(a[2].to_i+2).to_s
            end
            if lv>3
              a[2]=(a[2].to_i+4).to_s
            end
            if lv==5
              a[3]=(a[3].to_i-1).to_s
            end
            $game_variables[180][i]=a[0]+"-"+a[1]+"-"+a[2]+"-"+a[3]
          end
        end
    when 9 #灵魂支配LV2
        for i in 0...$game_actors[$game_variables\
          [1]+1].skills.size
          k=$game_actors[$game_variables[1]+1].skills[i]
          if $data_skills[k].name[0,12]=="灵魂支配"
            a=$game_variables[180][i].split("-")
            if lv==1
              a[0]=(a[0].to_i+10).to_s
              a[1]=(a[1].to_i+2).to_s
              a[2]=(a[2].to_i+100).to_s
              $game_variables[198]=a[0].to_i
            else
              a[0]=(a[0].to_i+20).to_s
              a[1]=(a[1].to_i+2).to_s
              a[2]=(a[2].to_i+200).to_s
              $game_variables[198]=a[0].to_i
            end
            $game_variables[180][i]=a[0]+"-"+a[1]+"-"+a[2]
          end
        end
    when 10 #魔王降临LV1
        for i in 0...$game_actors[$game_variables\
          [1]+1].skills.size
          k=$game_actors[$game_variables[1]+1].skills[i]
          if $data_skills[k].name[0,12]=="魔王降临"
            a=$game_variables[180][i].split("-")
            if lv==1
              a[0]=(a[0].to_i+1).to_s
            else
              a[0]=(a[0].to_i+2).to_s
            end
            $game_variables[180][i]=a[0]
          end
        end
    when 14 #毁灭阴影LV3
      for i in 0...$game_actors[$game_variables\
          [1]+1].skills.size
          k=$game_actors[$game_variables[1]+1].skills[i]
          if $data_skills[k].name[0,12]=="毁灭阴影"
            a=$game_variables[180][i].split("-")
            case lv
            when 1
              a[0]=(a[0].to_i+25000).to_s
              $game_variables[180][i]=a[0]+"-"+a[1]+"-"+a[2]+"-"+a[3]
            when 2
              a[0]=(a[0].to_i+30000).to_s
              $game_variables[180][i]=a[0]+"-"+a[1]+"-"+a[2]+"-"+a[3]
            when 3
              a[0]=(a[0].to_i+70000).to_s
              a[4]="3"
              a[2]=(a[2].to_i+20).to_s
              $game_actors[$game_variables[1]+1].skills[i]=166
              $game_variables[180][i]=a[0]+"-"+a[1]+"-"+a[2]+"-"+a[3]+"-"+a[4]
              for i in $game_variables[182]
                for j in 0...i.size
                  i[j]=166 if i[j]==73
                end
              end
              for i in 0...$game_variables[183].size
                if $game_variables[183][i]==73
                  $game_variables[183][i]=166
                end
              end
            when 4,5,6
              a[0]=(a[0].to_i+50000).to_s
              $game_variables[180][i]=a[0]+"-"+a[1]+"-"+a[2]+"-"+a[3]+"-"+a[4]
            when 7
              a[1]=(a[1].to_i+1).to_s
              a[4]=(a[4].to_i+1).to_s
              $game_variables[180][i]=a[0]+"-"+a[1]+"-"+a[2]+"-"+a[3]+"-"+a[4]
            end
          end
        end
    when 15 #灵魂支配LV3
        for i in 0...$game_actors[$game_variables\
          [1]+1].skills.size
          k=$game_actors[$game_variables[1]+1].skills[i]
          if $data_skills[k].name[0,12]=="灵魂支配"
            a=$game_variables[180][i].split("-")
            case lv
            when 1,2
              a[0]=(a[0].to_i+20).to_s
              a[1]=(a[1].to_i+10).to_s
              a[2]=(a[2].to_i+500).to_s
              $game_variables[198]=a[0].to_i
              $game_variables[180][i]=a[0]+"-"+a[1]+"-"+a[2]
            when 3
              $game_actors[$game_variables[1]+1].skills[i]=167
              a[1]=(a[1].to_i+10).to_s
              a[2]=(a[2].to_i+2000).to_s
              a[3]="1"
              $game_variables[198]=a[0].to_i
              $game_variables[199]+=1
              $game_variables[180][i]=a[0]+"-"+a[1]+"-"+a[2]+"-"+a[3]
            when 4,5
              a[0]=(a[0].to_i+30).to_s
              a[1]=(a[1].to_i+20).to_s
              a[2]=(a[2].to_i+3000).to_s
              a[3]=(a[3].to_i+1).to_s
              $game_variables[198]=a[0].to_i
              $game_variables[180][i]=a[0]+"-"+a[1]+"-"+a[2]+"-"+a[3]
            end
          end
        end
    when 16 #魔王降临LV2
        for i in 0...$game_actors[$game_variables\
          [1]+1].skills.size
          k=$game_actors[$game_variables[1]+1].skills[i]
          if $data_skills[k].name[0,12]=="魔王降临"
            a=$game_variables[180][i].split("-")
            case lv
            when 1
              a[0]=(a[0].to_i+2).to_s
              $game_variables[180][i]=a[0]
            when 2
              a[0]=(a[0].to_i+3).to_s
              $game_variables[180][i]=a[0]
            when 3
              $game_actors[$game_variables[1]+1].skills[i]=168
              a[0]=(a[0].to_i+4).to_s
              a[1]="1"
              $game_variables[266]=2
              $game_variables[180][i]=a[0]+"-"+a[1]
            when 4,5
              a[0]=(a[0].to_i+3).to_s
              a[1]=(a[1].to_i+2).to_s
              $game_variables[180][i]=a[0]+"-"+a[1]
            end
          end
        end
    when 17 #魂之挽歌LV1
        for i in 0...$game_actors[$game_variables\
          [1]+1].skills.size
          k=$game_actors[$game_variables[1]+1].skills[i]
          if $data_skills[k].name[0,12]=="魂之挽歌"
            a=$game_variables[180][i].split("-")
            a[0]=(a[0].to_i+100).to_s
            a[2]=(a[2].to_i+200000).to_s
            a[3]=(a[3].to_i+1).to_s
            a[4]=(a[4].to_i+(lv+2)*100).to_s
            a[5]=(a[5].to_i+2).to_s
            $game_variables[180][i]=a[0]+"-"+a[1]+"-"+a[2]+"-"+a[3]+"-"+a[4]+"-"+a[5]
          end
        end
    when 20 #灵魂化
      if lv==1
        for i in 0...$game_actors[$game_variables\
          [1]+1].skills.size
          k=$game_actors[$game_variables[1]+1].skills[i]
          if $data_skills[k].name[0,12]=="魔王降临"
            a=$game_variables[180][i].split("-")
            $game_actors[$game_variables[1]+1].skills[i]=169
            a[2]="10"
            a[3]="0.1"
            $game_variables[266]=3
            $game_variables[180][i]=a[0]+"-"+a[1]+"-"+a[2]+"-"+a[3]
          end
        end
      end
      for i in 0...$game_actors[$game_variables\
        [1]+1].skills.size
        k=$game_actors[$game_variables[1]+1].skills[i]
        if $data_skills[k].name[0,12]=="灵魂支配"
          a=$game_variables[180][i].split("-")
          a[1]=(a[1].to_i+20).to_s
          $game_variables[180][i]=a[0]+"-"+a[1]+"-"+a[2]+"-"+a[3]
        end
        if lv>=2 && $data_skills[k].name[0,12]=="魔王降临"
          a=$game_variables[180][i].split("-")
          a[2]=(a[2].to_i+10).to_s
          a[3]=(a[3].to_f+0.1).to_s
          $game_variables[180][i]=a[0]+"-"+a[1]+"-"+a[2]+"-"+a[3]
        end
      end

    end
    
  end
end

class Window_GeniusHelp < Window_Base
  #--------------------------------------------------------------------------
  # ● 初始化对像
  #--------------------------------------------------------------------------
  def initialize(pre)
    super(576, 0, 224,480)
    self.windowskin=RPG::Cache.windowskin("001-Blue02")
    self.contents = Bitmap.new(width - 32, height - 32)
    @prepose=pre
  end
  #--------------------------------------------------------------------------
  # ● 刷新
  #--------------------------------------------------------------------------
  def refresh(id)
      maxlevel=id[1]
      id=id[0]
      self.contents.clear
      return if id==0
      self.contents.font.color = normal_color
      self.contents.font.size=16
        line=0
        align=0
        a=$data_weapons[id].name.split(":")[0]
        ma=TextStream.new
        if ma.open("Info/Genius/"+sprintf("%04d",id))
          s=ma.get_all
          sk=s.split("Lv")
          s=sk[0]
          if $game_variables[228][id]>0
            val=2
            val=3 if $game_variables[228][id]>=10
            ss=sk[$game_variables[228][id]]
            ss=ss[val,ss.size-val]
            s+="\\S[20]\\C[4]当前等级\\C[0]\\S[18]"+ss+"\n"
          end
          if $game_variables[228][id]<maxlevel
            val=2
            val=3 if $game_variables[228][id]>=9
            ss=sk[$game_variables[228][id]+1]
            ss=ss[val,ss.size-val]
            s+="\\S[20]\\C[3]下一等级\\C[0]\\S[18]"+ss
          end
          linel=0
          line2=0
          maxlinel=0
          text=s.split("\n")
          loop do
            maxlinel=self.contents.font.size
            break if line2>=text.size
            s=text[line2]
            s=s[3,s.size-3] if line2==0
            line2+=1
            if s=="\\~\\/[END]"
              break
            end
            pos=0
            posl=0
            case align
            when 0
              stpos=0
            when 2
              ss=s+""
              ss.gsub!(/\[([0-9]+)\]/, "")
              ss.gsub!(/\\([A-Z])/, "")
              stpos=174-self.contents.text_size(ss[0,ss.size]).width
            end
            loop do
              break if s==nil
              while s[pos,1]=="\\"
                kind=s[pos+1,1]
                s=s[0,pos]+s[pos+2,s.size-pos-2]
                num=s.sub!(/\[([0-9]+)\]/, "")
                case kind
                when "C"
                  self.contents.font.color = text_color($1.to_i)
                when "S"
                  self.contents.font.size=$1.to_i
                when "K"
                  val=$1.to_i
                  case val
                  when 0
                    if $game_variables[228][id]==50
                      s=s[0,pos]+"[未学习]"+s[pos,s.size-pos]
                    else
                      s=s[0,pos]+"[Lv"+$game_variables[228][id].to_s+"/"+maxlevel.to_s+"]"+s[pos,s.size-pos]
                    end
                  when 1 #前置
                    if @prepose[id]!=nil #存在前置
                      for q in @prepose[id]
                        mb=TextStream.new
                        mb.open("Info/Genius/"+sprintf("%04d",q[0]))
                        ps=mb.get_all.split("\n")[0]
                        ps.gsub!(/\[([0-9]+)\]/, "")
                        ps.gsub!(/\\([A-Z])/, "")
                        ps.gsub!(/ /, "")
                        ps=ps[3,ps.size-3]
                        if @prepose.index(q)==@prepose[id].size-1
                          s=s[0,pos]+"\\N[0]"+s[pos,s.size-pos]
                        end
                        if q[1]==-1
                          if $game_variables[228][q[0]]==0
                            s=s[0,pos]+"\\N[0]\\C[4]\\S[18]需要["+ps+"]未曾学习过"+s[pos,s.size-pos]
                          else
                            s=s[0,pos]+"\\N[0]\\C[2]\\S[18]需要["+ps+"]未曾学习过"+s[pos,s.size-pos]
                          end
                        else
                          if $game_variables[228][q[0]]>=q[1]
                            s=s[0,pos]+"\\N[0]\\C[4]\\S[18]需要["+ps+"]Lv"+q[1].to_s+s[pos,s.size-pos]
                          else
                            s=s[0,pos]+"\\N[0]\\C[2]\\S[18]需要["+ps+"]Lv"+q[1].to_s+s[pos,s.size-pos]
                          end
                        end
                        #+s[pos,s.size-pos]
                     #   for i in 0...$game_variables[237].size
                       #   ss=$game_variables[237][i][1].split("：")
                       #   s+="\\C[17]"+ss[0]+" \\C[0]"+ss[1]+"\\N[0]"
                       # end
                      end
                    end
                  end
                  
                when "A"
                  align=$1.to_i
                  case align
                  when 0
                    stpos=0
                  when 2
                    ss=s+""
                    if ss.split("\K[0]").size>0
                      ss+=$data_weapons[id].price.to_s
                    end
                    ss.gsub!(/\[([0-9]+)\]/, "")
                    ss.gsub!(/\\([A-Z])/, "")
                    stpos=189-self.contents.text_size(ss[0,ss.size]).width
                  end
                when "N"
                  posl=0
                  line+=1
                  linel+=maxlinel
                end
              end
              if s[pos]!=nil
                if s[pos]<128
                  self.contents.draw_text(posl+stpos,linel, self.contents.font.size,self.contents.font.size, s[pos,1], align)
                  posl+=self.contents.text_size(s[pos,1]).width
                  if self.contents.text_size(s[pos,1]).height>maxlinel
                    maxlinel=self.contents.text_size(s[pos,1]).height
                  end
                  pos+=1
                else
                  self.contents.draw_text(posl+stpos,linel, self.contents.font.size,self.contents.font.size, s[pos,3], align)
                  posl+=self.contents.text_size(s[pos,3]).width
                  if self.contents.text_size(s[pos,3]).height>maxlinel
                    maxlinel=self.contents.text_size(s[pos,3]).height
                  end
                  pos+=3
                end
              else
                pos+=1
              end
              if posl>180
                posl=0
                line+=1
                linel+=maxlinel
              end
              break if pos>s.size
            end
            line+=1
            linel+=maxlinel
          end

        end
    self.visible = true
  end
end

class Window_GeniusText < Window_Base
  #--------------------------------------------------------------------------
  # ● 初始化对像
  #--------------------------------------------------------------------------
  def initialize(sk,h,l)
    super(0,0,576,480)
    self.contents = Bitmap.new(width - 32, h+80)
    self.back_opacity=0
    self.opacity=0
    @skill=sk
    @maxlen=l
    refresh
  end
  def refresh
    self.contents.clear
    self.contents.font.size=13
    color=text_color(3)
    for i in 0...@maxlen+1
      for j in 0...10
        if @skill[i][j]!=nil
          k=@skill[i][j][0]
          c=$game_variables[228][k]
          self.contents.font.color = normal_color
          if $game_variables[228][k]>$game_variables[226][k]
            self.contents.font.color = color
          end
          if $game_variables[228][k]<$game_variables[226][k]
            self.contents.font.color = text_color(9)
          end
          self.contents.draw_text(j*64+49,i*80+54, 80, 32,"["+c.to_s+"/"+@skill[i][j][1].to_s+"]".to_s,1)
        end
      end
    end
    
    
    self.contents.font.size=20
    if $game_switches[187] #洗点模式
      str="剩余洗点次数："+$game_variables[274].to_s
    else
      str="剩余天赋点："+$game_variables[228][0].to_s+" 剩余成就点："+($point-$game_variables[228][999]).to_s
    end
    x=116
    y=(@maxlen+1)*80+10
    self.contents.font.color = Color.new(0,0,0,255)
    self.contents.draw_text(x-1,y, 320, 32, str,1)
    self.contents.draw_text(x,y-1, 320, 32, str,1)
    self.contents.draw_text(x+1,y, 320, 32, str,1)
    self.contents.draw_text(x,y+1, 320, 32, str,1)
    if $game_variables[228][0]<0
      self.contents.font.color = text_color(9)
    else
      self.contents.font.color = normal_color
    end
    self.contents.draw_text(x,y, 320, 32, str,1)
    
    ss=["[确认加点]","[退出加点]","[兑换天赋]"]
    xx=100
    yy=40
    for i in 0...3
      x=xx+i*130
      y=yy+(@maxlen+1)*80
      str=ss[i]
      self.contents.font.color = Color.new(0,0,0,255)
      self.contents.draw_text(x-1,y, 120, 32, str)
      self.contents.draw_text(x,y-1, 120, 32, str)
      self.contents.draw_text(x+1,y, 120, 32, str)
      self.contents.draw_text(x,y+1, 120, 32, str)
      self.contents.font.color = normal_color
      if $game_switches[168] && i==0
        self.contents.font.color = Color.new(255, 255, 255, 128)
      end
      if $game_switches[187] && i==2
        self.contents.font.color = Color.new(255, 255, 255, 128)
      end
      self.contents.draw_text(x,y, 120, 32, str)
    end
    
  end
end