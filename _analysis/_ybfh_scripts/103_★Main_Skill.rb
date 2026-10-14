class Scene_EnemyView
  def initialize(kind=0)
    @kind=kind  
  end
  #--------------------------------------------------------------------------
  # ● 主处理
  #--------------------------------------------------------------------------
  def main
    @enemy_window = Window_Enemy.new(@kind)
    if @kind==1
      $right_back_spr=Sprite.new
      if $game_switches[140]
        $right_back_spr.bitmap=RPG::Cache.picture("nevermore")
      else
        $right_back_spr.bitmap=RPG::Cache.picture("sven")
      end
      $right_back_spr.x=640
      $right_back_spr.z=100
    end
    if @kind==1 && $game_switches[120]
      @skill_set_window=Window_SetSkill.new
    end
    # 执行过渡
    Graphics.transition
    # 主循环
    loop do
      # 刷新游戏画面
      Graphics.update
      # 刷新输入信息
      Input.update
      # 刷新画面
      update
      # 如果切换画面就中断循环
      if $scene != self
        break
      end
    end
    # 准备过渡
    Graphics.freeze
    # 释放窗口
    @enemy_window.dispose
    if @kind==1 && $game_switches[120]
      @skill_set_window.dispose
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面
  #--------------------------------------------------------------------------
  def update
    # 刷新窗口
    @enemy_window.update
    if @kind==1 && $game_switches[120]
      @skill_set_window.update
    end
   # if @enemy_window.active
      update_command
   #   return
   # end
 end
  def have_skill_number(k)
    n=0
    for i in $game_variables[183]
      n+=1 if i==k
    end
    return n
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面 (命令窗口被激活的情况下)
  #--------------------------------------------------------------------------
  def update_command
    # 按下 B 键的情况下
    if @kind==0 || !$game_switches[120]
      if Input.trigger?(Input::B) || (Kboard.trigger?($game_config.data("keyboard")[3]) && @kind==1)
        # 演奏取消 SE
        $game_system.se_play($data_system.cancel_se)
        # 切换的地图画面
        if @kind==0
          $scene = Scene_Menu.new
        else
          $scene = Scene_Map.new
        end
        return
      end
    else
      if Input.trigger?(Input::C)
       if @enemy_window.active
         k=@enemy_window.skill_list[@enemy_window.index]
          if $data_skills[k].scope==3 || have_skill_number(k)>100-$data_skills[k].hit
            $game_system.se_play($data_system.buzzer_se)
          else
            $game_system.se_play($data_system.actor_collapse_se)
            @enemy_window.active=false
            @skill_set_window.active=true
            $game_variables[183][@skill_set_window.index]=@enemy_window.skill_list[@enemy_window.index]
            @skill_set_window.refresh
          end
        else
          @enemy_window.active=true
          @skill_set_window.active=false
        end
      end
      if Input.trigger?(Input::B) || (Kboard.trigger?($game_config.data("keyboard")[3]) && @kind==1)
        # 演奏取消 SE
        $game_system.se_play($data_system.cancel_se)
        # 切换的地图画面
        if @enemy_window.active
          $game_system.se_play($data_system.actor_collapse_se)
          @enemy_window.active=false
          @skill_set_window.active=true
          $game_variables[183][@skill_set_window.index]=0
          @skill_set_window.refresh
        else
          $scene = Scene_Map.new
        end
        return
      end
    end
  end
end

class Window_Enemy < Window_Selectable
  attr_reader   :skill_list                   #技能列表
  #--------------------------------------------------------------------------
  # ● 初始化窗口
  #--------------------------------------------------------------------------
  def initialize(kind)
    @kind=kind
    if kind==0
      super(0, 0, 640, 480)
      @max_line=3
      count=0
      allsk=[]
      for i in 1...$data_skills.size
        if got_p($floorenemies[$game_variables[13]],i)
          count+=1
          allsk.push(i)
        end
      end
    else
      if $game_switches[120]
        super(0, 0, 640, 385)
      else
        super(0, 0, 640, 480)
      end
      @max_line=2
      count=$game_actors[$game_variables[1]+1].all_skill.size
      self.active=false if $game_switches[120]
      allsk=$game_actors[$game_variables[1]+1].all_skill
    end
    @item_max=count
    a=85
    if @item_max>=4
      a=64
    end
    @alllength1=[]
    @alllength2=[]
    l=0
    j=0
    for i in allsk
      str=$data_skills[i].description.clone
      if str[0,2]=="Lv"
        str=str.split("Lv")[$data_skills[i].name.split("Lv")[1][0,1].to_i]
        str=str[2,str.size-3]
      end
      @alllength1[j]=l
      @alllength2[j]=96*([str.split("\\n").size-3,0].max*0.22+1)
      l+=96*([str.split("\\n").size-3,0].max*0.22+1)#@alllength2[j]
      j+=1
    end
    @maxlength=l
    if $game_switches[120] && @item_max==3
      self.contents = Bitmap.new(width - 32, a+l.to_i-20)
    else
      self.contents = Bitmap.new(width - 32, a+l.to_i)
    end
    refresh
    self.index = 0
  end
  #--------------------------------------------------------------------------
  # ● 自定义光标
  #--------------------------------------------------------------------------
  def update_cursor_rect
    # 光标位置不满 0 的情况下
    if @item_max<=0 || !self.active
      self.cursor_rect.empty
      return
    end
    # 获取当前的行
    row = @index
    # 当前行被显示开头行前面的情况下
    if row < self.top_row 
      # 从当前行向开头行滚动
      self.top_row = row
    end
    # 当前行被显示末尾行之后的情况下
    if row > self.top_row #+ @max_line
      # 从当前行向末尾滚动
      self.top_row = row #- @max_line
    end
    # 更新国标矩形
    self.cursor_rect.set(16, @alllength1[@index] +85 - self.oy-10, 600, @alllength2[@index].to_i-5)
  end
  def top_row=(row)
    # row 未满 0 的场合更正为 0
    if row < 0
      row = 0
    end
    # row 超过 row_max - 1 的情况下更正为 row_max - 1 
    if row > @item_max - 1
      row = @item_max - 1
    end
    # row 1 行高的 32 倍、窗口内容的传送源 Y 坐标
    self.oy = [[[@alllength1[row]-96,0].max,@maxlength+96-self.height].min,0].max
  end
  def top_row
    # 将窗口内容的传送源 Y 坐标、1 行的高 32 等分
    return @item_max
  end
  #--------------------------------------------------------------------------
  # ● 刷新
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    if @kind==0
      einfo=$data_enemies[$floorenemies[$game_variables[13]]]
      e=Enemy_property.new(einfo.id)
      
      self.contents.font.color = text_color(6)
      self.contents.font.size = 26
      self.contents.draw_text(0, 0, 608, 32, einfo.name.split(":")[0].to_s, 1)
      icondata=$fleicon[$game_variables[13]]
      if icondata==nil
        bitmap = RPG::Cache.battler(einfo.battler_name , einfo.battler_hue )
        src_rect = Rect.new(0, 0,bitmap.width, bitmap.height)
      else
        bitmap = RPG::Cache.character(icondata[0] ,icondata[1])
        src_rect = Rect.new(icondata[3]*bitmap.width/4, (icondata[2]/2-1)*bitmap.height/4,bitmap.width/4, bitmap.height/4)
      end
      self.contents.blt(304-src_rect.width/2, 50-src_rect.height/2, bitmap, src_rect)
      self.contents.font.color = text_color(0)
      self.contents.font.size = 18
  
      if einfo.item_id>0
        p=$data_items[einfo.item_id]
        bitmap = RPG::Cache.icon(p.icon_name)
        src_rect = Rect.new(0, 0,bitmap.width, bitmap.height)
        self.contents.blt(324, 42, bitmap, src_rect)
        if einfo.treasure_prob == 100 and !e.got_p(16) and !e.got_p(26)
          self.contents.draw_text(360, 44, 200, 32, p.name+"（死后掉落）", 0)
        else
          self.contents.draw_text(360, 44, 200, 32, p.name+"（不掉落）", 0)
        end
      end
      if einfo.weapon_id>0
        p=$data_weapons[einfo.weapon_id]
        bitmap = RPG::Cache.icon(p.icon_name)
        src_rect = Rect.new(0, 0,bitmap.width, bitmap.height)
        self.contents.blt(324, 42, bitmap, src_rect)
        if einfo.treasure_prob == 100 and !e.got_p(16) and !e.got_p(26)
          self.contents.draw_text(360, 44, 200, 32, p.name+"（死后掉落）", 0)
        else
          self.contents.draw_text(360, 44, 200, 32, p.name+"（不掉落）", 0)
        end
      end
      if einfo.armor_id>0
        p=$data_armors[einfo.armor_id]
        bitmap = RPG::Cache.icon(p.icon_name)
        src_rect = Rect.new(0, 0,bitmap.width, bitmap.height)
        self.contents.blt(324, 42, bitmap, src_rect)
        if einfo.treasure_prob == 100 and !e.got_p(16) and !e.got_p(26)
          self.contents.draw_text(360, 44, 200, 32, p.name+"（战斗后掉落）", 0)
        else
          self.contents.draw_text(360, 44, 200, 32, p.name+"（不掉落）", 0)
        end
      end
      self.contents.font.color = text_color(3)
      self.contents.draw_text(12, 50, 192, 32, "技能列表：", 0)
      if $game_switches[163] #开启军功
        if einfo.maxsp>0
          self.contents.font.color = text_color(0)
          if  $game_variables[278]>0
            self.contents.draw_text(320, 32, 80, 32, "仙蕴"+einfo.maxsp.to_s, 1)
          else
            self.contents.draw_text(320, 32, 80, 32, "军功"+einfo.maxsp.to_s, 1)
          end
        end
      end
      y=-0.1
      kcskill=[]
      kcvalue=[]
      bdskill=[]
      bdvalue=[]
      zdskill=[]
      zdvalue=[]
      zdnum=[]
      kk=0
      for i in $enemies_skills[einfo.id]
          if $data_skills[i].scope==5
            kcskill.push(i)
            if $data_skills[i].description.split("\\v").size>1
              kk+=1
            end
            s=""
            case i
            when 30,64
              s=""
              a=einfo.name.split(":")[kk]
              a=a.split("&")
              for j in 0...a.size
                b=a[j].split("-")
                s+="#{b[1].to_i}个#{$data_enemies[b[0].to_i].name.split(":")[0]}"
                if j<a.size-2
                  s+="、"
                elsif j==a.size-2
                  s+="与"
                end
              end
            when 135
              s=""
              a=einfo.name.split(":")[kk]
              a=a.split("&")
              for j in 0...a.size
                if j==0
                  b=a[j].split("-")
                  for qq in 0...3
                    if b[qq][0,1]=="M"
                      b[qq].slice!(0,1)
                      b[qq]=-(b[qq].to_i)
                    end
                  end
                  for count in b
                    kcvalue.push(count)
                  end
                  next
                end
                b=a[j].split("-")
                s+="#{b[1].to_i}个#{$data_enemies[b[0].to_i].name.split(":")[0]}"
                if j<a.size-2
                  s+="、"
                elsif j==a.size-2
                  s+="与"
                end
              end
            when 138
              a=einfo.name.split(":")[kk]
              a=a.split("&")
              for j in 0...a.size
                if j==0
                  for count in a[j].split("-")
                    kcvalue.push(count)
                  end
                  next
                end
              end
              a=$game_variables[234][$game_map.map_id]
              if a==nil
                s="无"
              else
                s=$data_enemies[a].name.split(":")[0]
              end
            when 41,179
              s=einfo.name.split(":")[kk]
            end
            kcvalue.push(s)
          end
          if $data_skills[i].scope==3 || $data_skills[i].scope==4
            bdskill.push(i)
            if $data_skills[i].description.split("\\v").size>1
              kk+=1
              bdvalue.push(einfo.name.split(":")[kk]) 
            else
              bdvalue.push("")
            end
          end
          if $data_skills[i].scope<=2
            if $data_skills[i].description.split("\\v").size>1
              kk+=1
              s=einfo.name.split(":")[kk]
              zdnum[zdskill.size]=s.split("&")[1]
              if zdnum[zdskill.size]==nil
                zdnum[zdskill.size]=999+zdskill.size
              else
                zdnum[zdskill.size]=zdnum[zdskill.size].to_i
              end
            else
              zdnum[zdskill.size]=999+zdskill.size
            end
            zdskill.push(i)
            if $data_skills[i].description.split("\\v").size>1
              zdvalue.push(s.split("&")[0]) 
            else
              zdvalue.push("")
            end
          end
          
      end
      for i in 0...zdskill.size#怪物伤害排序
       for j in i...zdskill.size
        if zdnum[i]>zdnum[j]
         temp=zdnum[i]
         zdnum[i]=zdnum[j]
         zdnum[j]=temp
         temp=zdskill[i]
         zdskill[i]=zdskill[j]
         zdskill[j]=temp
         temp=zdvalue[i]
         zdvalue[i]=zdvalue[j]
         zdvalue[j]=temp
        end
       end
     end
   end
   if @kind==1
     @actor=$game_actors[$game_variables[1]+1]
     self.contents.font.color = text_color(6)
      self.contents.font.size = 26
      self.contents.draw_text(0, 0, 608, 32, @actor.name, 1)
      bitmap = RPG::Cache.character(@actor.character_name  , @actor.character_hue)
      src_rect = Rect.new(0, 0, bitmap.width/4, bitmap.height/4)
      self.contents.blt(288, 25, bitmap, src_rect)
      self.contents.font.color = text_color(0)
      self.contents.font.size = 18
      self.contents.font.color = text_color(3)
      self.contents.draw_text(12, 50, 192, 32, "技能列表：", 0)
      y=-0.1
      kcskill=[]
      kcvalue=[]
      bdskill=[]
      bdvalue=[]
      zdskill=[]
      zdvalue=[]
      zdnum=[]
      for i in 0...@actor.all_skill.size
        if $data_skills[@actor.all_skill[i]].scope==3
          bdskill.push(@actor.all_skill[i])
          bdvalue.push($game_variables[180][i])
          if $data_skills[@actor.all_skill[i]].name[0,12]=="灵魂支配"
            a=bdvalue[bdvalue.size-1].split("-")
            str=""
            for ch in 0...a.size
              str+="-" if ch>0
              if a[ch].to_i==$game_variables[198]
                val=a[ch].to_i
                if $game_switches[148]
                  val*=1.5
                end
                if $game_variables[181][122]!=nil
                  val+=$game_variables[181][122]*100
                end
                str+=val.to_s
              else
                str+=a[ch]
              end
            end
            bdvalue[bdvalue.size-1]=str.clone
          end
        end
        if $data_skills[@actor.all_skill[i]].scope==1
          zdskill.push(@actor.all_skill[i])
          if $game_variables[180][i]==nil
            power=0
            n=$data_skills[@actor.all_skill[i]].name.split(":")
            @pro=n[0].to_s
            @pro=@pro.split("|")
            plus=nil
            plus=@pro[1] if @pro.size>1
            s=$data_skills[@actor.all_skill[i]].description.clone
            if s[0,2]=="Lv"
              s=s.split("Lv")[$data_skills[@actor.all_skill[i]].name.split("Lv")[1][0,1].to_i]
              s=s[2,s.size-3]
            end
            s.sub!(/\{([0-9]+)\}/, "")
            if $1 !=nil
              power+=$1.to_i
            end
            if plus !=nil
              power+=(plus.to_f*@actor.magicpower.to_i).to_i
            end
            power=(power*@actor.skilldam).to_i
            if @actor.all_skill[i]==164
              case $game_variables[154]
              when 1
                val=@actor.power1
              when 2
                val=@actor.power2
              when 3
                val=@actor.power3
              end
              power=(power*(1+val*0.001)).to_i
            end
          elsif $data_skills[@actor.all_skill[i]].variance==100
            power=$game_variables[180][i]
          else
            ss=$game_variables[180][i].split("-")
            s=""
            for j in 0...ss.size
              if j>0
                s+="-"
              end
              if j==$data_skills[@actor.all_skill[i]].variance-1
                power=ss[j].to_f
                n=$data_skills[@actor.all_skill[i]].name.split(":")
                @pro=n[0].to_s
                @pro=@pro.split("|")
                plus=nil
                plus=@pro[1] if @pro.size>1
                if $data_skills[@actor.all_skill[i]].name[0,12]=="毁灭阴影"
                  if $game_variables[266]>=3
                    for k in 0...@actor.all_skill.size
                      if $data_skills[@actor.all_skill[k]].name[0,12]=="魔王降临"
                         power*=(1+[$game_variables[197],@actor.soul_max_hard].min*$game_variables[180][k].split("-")[3].to_f/100)
                      end
                    end
                  end
                end
                if plus !=nil
                  power+=(plus.to_f*@actor.magicpower.to_i).to_i
                end
                power=(power*@actor.skilldam).to_i
                s+=power.to_s
              else
                s+=ss[j]
              end
            end
            power=s
          end
          zdvalue.push(power.to_s)
        end
        if $data_skills[@actor.all_skill[i]].scope==7 #装备技能
          #???
        end
      end
    end
    kk=0
    l=0
    j=0
      for i in kcskill
        str=$data_skills[i].description.clone
        if str[0,2]=="Lv"
          str=str.split("Lv")[$data_skills[i].name.split("Lv")[1][0,1].to_i]
          str=str[2,str.size-3]
        end
        @alllength1[j]=l
        @alllength2[j]=96*([str.split("\\n").size-3,0].max*0.21+1)
        l+=@alllength2[j]
        j+=1
        
        n=$data_skills[i].name.split(":")
        @pro=n[0].to_s
        bitmap = RPG::Cache.icon($data_skills[i].icon_name)
        self.contents.blt(24, y*96+42+@alllength2[j-1]/2, bitmap, Rect.new(0, 0,bitmap.width, bitmap.height))
        self.contents.font.color = text_color(3)
        @pro+="（召唤技能）"
        self.contents.draw_text(112, 89+y*96, 192, 20, @pro, 0)
        self.contents.font.color = text_color(0)
        str=$data_skills[i].description.clone
        case i
        when 30
          str.sub!(/\\[Vv]/) {kcvalue[kk]}
        when 41
          if str.split("\\v").size>1
            for q in 0...str.split("\\v").size
              str.sub!(/\\[Vv]/) {kcvalue[kk].split("-")[q]}
            end
          end
        when 49
          str.sub!(/\\[Vv]/) {kcvalue[kk]}
        when 64
          str.sub!(/\\[Vv]/) {kcvalue[kk]}
        when 135
          for i in 0...4
            if i>=1
              kk+=1
            end
            str.sub!(/\\[Vv]/) {kcvalue[kk]}
          end
        when 138
          for i in 0...3
            if i>=1
              kk+=1
            end
            str.sub!(/\\[Vv]/) {kcvalue[kk]}
          end
          kk+=1
          str.sub!(/\\[Kk]/) {kcvalue[kk]}
        when 179 #分则能成
      
              str.sub!(/\\[Vv]/) {""}
              if icondata==nil
                bitmap = RPG::Cache.battler(einfo.battler_name , einfo.battler_hue )
                src_rect = Rect.new(0, 0,bitmap.width, bitmap.height)
              else
                bitmap = RPG::Cache.character(icondata[0] ,icondata[1])
                src_rect = Rect.new(icondata[3]*bitmap.width/4, (icondata[2]/2-1)*bitmap.height/4,bitmap.width/4, bitmap.height/4)
              end
              self.contents.blt(370,93+y*96+72,bitmap,src_rect)
              for fl in kcvalue[kk].split("&")
                aa=fl.split("-")[0].to_i
                bb=fl.split("-")[1].to_i
                fx=0;fy=0
                case aa
                when 2
                  fy=-32
                when 4
                  fx=-32
                when 6
                  fx=32
                when 8
                  fy=32
                end
                bitmap = RPG::Cache.battler($data_enemies[bb].battler_name ,$data_enemies[bb].battler_hue )
                src_rect = Rect.new(0, 0,bitmap.width, bitmap.height)
                self.contents.blt(370+fx,93+y*96+72+fy,bitmap,src_rect)
              end
        end
        kk+=1
        line=1
        for i in str.split("\\n")
          self.contents.draw_text(112, 93+y*96+line*20, 520, 20, i, 0)
          line+=1
        end
        y+=1+[line-4,0].max*0.21
      end
    
    speicalCheck=bdskill.index(212)
    if speicalCheck !=nil && speicalCheck>0
      tmp=bdskill[0]
      bdskill[0]=bdskill[speicalCheck]
      bdskill[speicalCheck]=tmp
      tmp=bdvalue[0].clone
      bdvalue[0]=bdvalue[speicalCheck]
      bdvalue[speicalCheck]=tmp
    end
    kk=0
    for i in bdskill
      str=$data_skills[i].description.clone
        if str[0,2]=="Lv"
          str=str.split("Lv")[$data_skills[i].name.split("Lv")[1][0,1].to_i]
          str=str[2,str.size-3]
        end
        @alllength1[j]=l
        @alllength2[j]=96*([str.split("\\n").size-3,0].max*0.21+1)
        l+=@alllength2[j]
        j+=1
        n=$data_skills[i].name.split(":")
        @pro=n[0].to_s
        bitmap = RPG::Cache.icon($data_skills[i].icon_name)
        self.contents.blt(24, y*96+42+@alllength2[j-1]/2, bitmap, Rect.new(0, 0,bitmap.width, bitmap.height))
        self.contents.font.color = text_color(3)
        if $data_skills[i].scope==4
          @pro+="（光环技能）"
        else
          if i==212 #认知干扰
            @pro+="（？？？）"
          else
            @pro+="（被动技能）"
          end
        end
        self.contents.draw_text(112, 89+y*96, 322, 20, @pro, 0)
        self.contents.font.color = text_color(0)
        str=$data_skills[i].description.clone
        if str[0,2]=="Lv"
          str=str.split("Lv")[$data_skills[i].name.split("Lv")[1][0,1].to_i]
          str=str[2,str.size-3]
        end
        if str.split("\\v").size>1
          for q in 0...str.split("\\v").size
            if i==38 || i==71  #重生
              str.sub!(/\\[Vv]/) {$data_enemies[bdvalue[kk].split("-")[q].to_i].name.split(":")[0]}
              next
            end
            str.sub!(/\\[Vv]/) {fucko(bdvalue[kk].split("-")[q].to_f)}
          end
        end
                
        if $data_skills[i].name[0,12]=="灵魂支配"
          sx=36
          sy=y*90+144
          str2=$game_variables[197].to_s
          self.contents.font.color = text_color(8)
          self.contents.draw_text(sx-1,sy-1, 64, 32, str2,2)
          self.contents.draw_text(sx+1,sy-1, 64, 32, str2,2)
          self.contents.draw_text(sx-1,sy+1, 64, 32, str2,2)
          self.contents.draw_text(sx+1,sy+1, 64, 32, str2,2)
          self.contents.font.color = text_color(2)
          self.contents.draw_text(sx,sy, 64, 32, str2,2)
          self.contents.font.color = text_color(0)
        end
        line=1
        kk+=1
        if i==212 #认知干扰
          self.contents.font.color = text_color(9)
        end
        for i in str.split("\\n")
          self.contents.font.color = text_color(16) if i[0,4]=="[超"
          self.contents.font.color = text_color(14) if i[0,4]=="[传"
          self.contents.font.color = text_color(17) if i[0,4]=="[仙"
          self.contents.draw_text(112, 93+y*96+line*20, 520, 20, i, 0)
          self.contents.font.color = text_color(0) if i[0,4]=="[超" || i[0,4]=="[传" || i[0,4]=="[仙"
          line+=1
        end
        y+=1+[line-4,0].max*0.21
      end
      kk=0
    for i in zdskill
      str=$data_skills[i].description.clone
        if str[0,2]=="Lv"
          str=str.split("Lv")[$data_skills[i].name.split("Lv")[1][0,1].to_i]
          str=str[2,str.size-3]
        end
        @alllength1[j]=l
        @alllength2[j]=96*([str.split("\\n").size-3,0].max*0.21+1)
        l+=@alllength2[j]
        j+=1
        
        n=$data_skills[i].name.split(":")
        @pro=n[0].to_s
        @pro=@pro.split("|")
        plus=nil
        plus=@pro[1] if @pro.size>1
        @pro=@pro[0]
        bitmap = RPG::Cache.icon($data_skills[i].icon_name)
        self.contents.blt(24, y*96+42+@alllength2[j-1]/2, bitmap, Rect.new(0, 0,bitmap.width, bitmap.height))
        self.contents.font.color = text_color(3)
        if $data_skills[i].scope==1
          @pro+="（主动技能）"
        else
          @pro+="（支援技能）"
        end
        self.contents.draw_text(112, 89+y*96, 322, 20, @pro, 0)
        px=self.contents.text_size(@pro).width
        self.contents.font.color = text_color(14)
        self.contents.draw_text(112+px, 89+y*96, 200, 20, "["+plus+"Ω]*"+@actor.magicpower.to_i.to_s, 0) if plus !=nil
        self.contents.font.color = text_color(0)
        str=$data_skills[i].description.clone
        if str[0,2]=="Lv"
          str=str.split("Lv")[$data_skills[i].name.split("Lv")[1][0,1].to_i]
          str=str[2,str.size-3]
        end
        
        fvalue=zdvalue[kk].split("-")
        if $data_skills[i].name[0,12]=="魂之挽歌"
          if $game_variables[226]!=0 && $game_variables[226][17]!=nil
            bl=@actor.soul_max_hard*0.5*0.001
            fvalue[2]=fvalue[2].to_i*(1+bl)
          end
        end
        str.sub!(/\{([0-9]+)\}/, "")
        if str.split("\\v").size>1
          for q in 0...str.split("\\v").size
            str.sub!(/\\[Vv]/) {fucko(fvalue[q].to_i)}
          end
        end
        if str.split("多重强化").size>1
          if !bdskill.include?(63)
            str=str.split("多重强化")[0]
          end
        end
        kk+=1
        line=1
        for i in str.split("\\n")
          self.contents.font.color = text_color(16) if i[0,4]=="[超"
          self.contents.font.color = text_color(14) if i[0,4]=="[传"
          self.contents.font.color = text_color(17) if i[0,4]=="[仙"
          self.contents.draw_text(112, 93+y*96+line*20, 480, 20, i, 0)
          self.contents.font.color = text_color(0) if i[0,4]=="[超" || i[0,4]=="[传" || i[0,4]=="[仙"
          line+=1
        end
        y+=1+[line-4,0].max*0.21
      end
    @skill_list=bdskill+zdskill
  end
    def fucko(i)
      return "0" if i==0
      if i*10%10 !=0
        return i
      end
      i=i.to_i
      len=(i.abs.to_s).length
      len2=(i.abs.to_s).length
      if len2>4 && len2%4==2
        len=[(len-2)/4,0].max
        t=i.abs/i
        return (i.abs/(10**(len*4-1))/10.0*t).to_s+$shuwei[len+$game_variables[400]]
      end
      len=[(len-2)/4,0].max
      return (i/(10**(len*4))).to_s+$shuwei[len]
    end
end

class Window_SetSkill < Window_Base
  attr_reader   :index                    # 光标位置
  #--------------------------------------------------------------------------
  # ● 初始化窗口
  #--------------------------------------------------------------------------
  def initialize
    super(0, 364, 640, 112)
    @item_max=10
    self.contents = Bitmap.new(width - 32, height - 32)
    @index2 = 1
    @index = 0
    self.back_opacity=0
    self.opacity=0
    self.z=102
    @back_window=Window_Base.new(0,384,640,96)
    @back_window.z=self.z
    @spr=[]
    for i in 0...10
      @spr[i]=Sprite.new
      @spr[i].x=self.x+i*56+16
      @spr[i].y=self.y+40+16
      @spr[i].bitmap=Bitmap.new(84,84)
      @spr[i].z=@back_window.z
      @spr[i].zoom_x=0.58
      @spr[i].zoom_y=0.58
    end
    refresh
  end
  def dispose
    super
    for i in 0...10
      @spr[i].bitmap.dispose
      @spr[i].dispose
    end
    @back_window.dispose
  end
  def update
    super
    if self.active
      # 方向键右被按下的情况下
      if Input.repeat?(Input::RIGHT)
        # 列数为 2 以上并且、光标位置在(项目数 - 1)之前的情况下
        if @index < @item_max - 1
          # 光标向右移动
          $game_system.se_play($data_system.cursor_se)
          @index += 1
        end
      end
      # 方向键左被按下的情况下
      if Input.repeat?(Input::LEFT)
        # 列数为 2 以上并且、光标位置在 0 之后的情况下
        if @index > 0
          # 光标向左移动
          $game_system.se_play($data_system.cursor_se)
          @index -= 1
        end
      end
      if Kboard.press?($game_config.data("keyboard")[4])
        for i in 48...58
          if Kboard.trigger?(i)
            $game_system.se_play($data_system.equip_se)
            $game_variables[182][i-48]=$game_variables[183].clone
            refresh
            $game_system.se_play($data_system.actor_collapse_se)
            self.contents.draw_text(92,4, 250,37,"#{i-48}号技能组合保存成功！", 0)
            break
          end
        end
      end
    end
    update_cursor_rect
  end
  def refresh
    self.contents.clear
    for i in 0...10
      @spr[i].visible=false
    end
    self.contents.font.color = system_color
    #self.contents.font.size = 26
    self.contents.draw_text(0,4, 100,37,"技能组合", 0)
    self.contents.font.color = normal_color
    @mag=0
    @actor=$game_actors[$game_variables[1]+1]
    for i in 0...@item_max
      if $game_variables[183][i]>0
        @spr[i].bitmap=RPG::Cache.icon($data_skills[$game_variables[183][i]].icon_name)
        @spr[i].visible=true
        sw=false
        first=true
        for j in 0...@actor.skills.size
          if @actor.skills[j]==$game_variables[183][i]
            case $game_variables[183][i]
            when 28,39
              first=false if $game_variables[183][i]==28
              @mag+=$game_variables[180][j].split("-")[0].to_i
            when 51
              cost=$game_variables[180][j].split("-")[1].to_i
              cost*=3 if first
              first=false
              @mag+=cost
            when 73
              cost=$game_variables[180][j].split("-")[2].to_i
              cost*=3 if first
              first=false
              @mag+=cost
            when 85
              cost=$game_variables[180][j].split("-")[0].to_i
              first=false
              @mag+=cost
            when 122
              first=false
              @mag+=40
            when 161
              cost=$game_variables[180][j].split("-")[0].to_i
              first=false
              @mag+=cost
            when 166
              cost=$game_variables[180][j].split("-")[2].to_i*$game_variables[180][j].split("-")[4].to_i
              first=false
              @mag+=cost
            end
            sw=true
            break
          end
        end
        if !sw
          @mag+=$data_skills[$game_variables[183][i]].sp_cost
        end
      else
        self.contents.draw_text(i*56 ,40,48,48,"普攻", 1)
      end
    end
    val=(@mag*@actor.skillminus*1.000001).to_i
    self.contents.font.color = system_color
    self.contents.draw_text(330,4, 300,37,"当前组合共计消耗#{val}点魔法", 0)
  end
  #--------------------------------------------------------------------------
  # ● 自定义光标
  #--------------------------------------------------------------------------
  def update_cursor_rect
    self.cursor_rect.set(@index*56 ,40,48,48)
  end
end