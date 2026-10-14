



Enemies_Switches=8 #8号开关决定是否显示怪物信息，主要以是否获得怪物手册为准
Enemieskind_Variables=7#本层的怪物种类数
Playerdate_magicdef=19#19号开关决定是否采用勇士魔防
#==============================================================================
# ■ Window_EnemyDate
#------------------------------------------------------------------------------
# 　显示怪物的生命及造成的伤害等。
#==============================================================================

class Window_EnemyDate < Window_Selectable
  #--------------------------------------------------------------------------
  # ● 初始化对像
  #--------------------------------------------------------------------------
  def initialize
    super(160, 0, 480, 480)
    @column_max = 1
    refresh
    self.index = -1
    self.active = false
  end
  #--------------------------------------------------------------------------
  # ● 获取开头行
  #--------------------------------------------------------------------------
  def top_row
    # 将窗口内容的传送源 Y 坐标、1 行的高 32 等分
    return self.oy / 112
  end
  #--------------------------------------------------------------------------
  # ● 设置开头行
  #     row : 显示开头的行
  #--------------------------------------------------------------------------
  def top_row=(row)
    # row 未满 0 的场合更正为 0
    if row < 0
      row = 0
    end
    # row 超过 row_max - 1 的情况下更正为 row_max - 1 
    if row > row_max - 1
      row = row_max - 1
    end
    # row 1 行高的 32 倍、窗口内容的传送源 Y 坐标
    self.oy = row * 112
  end
  #--------------------------------------------------------------------------
  # ● 获取 1 页可以显示的行数
  #--------------------------------------------------------------------------
  def page_row_max
    # 窗口的高度，设置画面的高度减去 32 ，除以 1 行的高度 32 
    return (self.height - 32) / 112
  end
  #--------------------------------------------------------------------------
  # ● 更新光标举行
  #--------------------------------------------------------------------------
  def update_cursor_rect
    # 光标位置不满 0 的情况下
    if @index < 0
      self.cursor_rect.empty
      return
    end
    # 获取当前的行
    row = @index / @column_max
    # 当前行被显示开头行前面的情况下
    if row < self.top_row
      # 从当前行向开头行滚动
      self.top_row = row
    end
    # 当前行被显示末尾行之后的情况下
    if row > self.top_row + (self.page_row_max - 1)
      # 从当前行向末尾滚动
      self.top_row = row - (self.page_row_max - 1)
    end
    # 计算光标的宽
    cursor_width = self.width / @column_max - 32
    # 计算光标坐标
    x = @index % @column_max * (cursor_width + 32)
    y = @index / @column_max * 112 - self.oy
    # 更新国标矩形
    self.cursor_rect.set(x, y, cursor_width, 112)
  end
  
  #--------------------------------------------------------------------------
  # ● 获取怪物信息
  #--------------------------------------------------------------------------
  def einfo#skill
    return @data[self.index]
  end

  #--------------------------------------------------------------------------
  # ● 刷新
  #--------------------------------------------------------------------------
  def refresh
    return if $game_switches[Enemies_Switches]==false and !$game_switches[51]
    if self.contents != nil
      self.contents.dispose
      self.contents = nil
    end
    @data = []
    @icondata=[]
    j=0
    for i in 0...$game_variables[Enemieskind_Variables]#指定当前层的怪物种类数
      if $game_switches[Enemies_Switches]
        einfo = $data_enemies[$floorenemies[i]]
        #floorenemies为数组，指定当前层分别为哪些怪物类型        
      else
        if $game_variables[114][i]!=nil
          einfo = $data_enemies[$game_variables[114][i]] 
        else
          einfo = nil
        end
      end
      if einfo != nil
        @data.push(einfo)
        @icondata.push($fleicon[i])
      end
    end
      
    # 如果项目数不是 0 就生成位图、重新描绘全部项目
      @item_max = @data.size
      if @item_max > 0
        self.contents = Bitmap.new(width - 32, row_max * 112)
        for i in 0...@item_max
        draw_item(i)
        end
      end
  end
  #--------------------------------------------------------------------------
  # ● 描绘项目
  #     index : 项目编号
  #--------------------------------------------------------------------------
  def draw_item(index)
    einfo = @data[index]
    a =108
    x =120
    y = index  * 112
    if @icondata[index]==nil
      bitmap = RPG::Cache.battler(einfo.battler_name , einfo.battler_hue )
      src_rect = Rect.new(0, 0,bitmap.width, bitmap.height)
    else
      bitmap = RPG::Cache.character(@icondata[index][0] ,@icondata[index][1])
      src_rect = Rect.new(@icondata[index][3]*bitmap.width/4, (@icondata[index][2]/2-1)*bitmap.height/4,bitmap.width/4, bitmap.height/4)
    end
    self.contents.blt(0-(src_rect.width-32)/2, y+16-(src_rect.height-32)/2, bitmap, src_rect)

    if index*1.0/2 == index/2#单双数颜色变化
      self.contents.font.color = text_color(3)
      @a=3
    else
      self.contents.font.color = text_color(4)
      @a=4
    end

    
if $game_switches[Enemies_Switches]#拥有怪物手册则...
    result=[]
    savech={}
    for i in $game_variables[139]
      if $data_enemies[einfo.id].element_ranks[i[0]]==1
        next if savech[i[0]]!=nil
        savech[i[0]]=1
        result.push([i[0],i[4]])
      end
    end
    e=$fleinfo[index]
 #   e=Enemy_property.new(einfo.id,0,result)
    
    self.contents.draw_text(120, y, a, 32, "生命", 0)
    self.contents.draw_text(275, y,a, 32, "攻击",0)
    if (einfo.str>=16 && einfo.str<=300) || einfo.str>=337 || e.got_eshield[0]<0
      self.contents.draw_text(120, y+24, a, 32, "攻速", 0)
      self.contents.draw_text(275, y+23, a, 32, "防御",0)
      self.contents.font.size=16
      self.contents.draw_text(280, y+44, a, 32, "护甲",0)
      self.contents.draw_text(125, y+44, a, 32, "魔抗", 0)
      self.contents.font.size=22
    else
      self.contents.draw_text(120, y+32, a, 32, "攻速", 0)
      self.contents.draw_text(275, y+32, a, 32, "防御",0)
    end
    self.contents.draw_text(275, y+64, a, 32, "伤害", 0)
    
    self.contents.draw_text(120, y+64, a, 32, "金经", 0)
    
    
    p=e.got_kind
    #取得属性种数，3种或以上不显示
    
    @name=0#初始化怪物“伪装”属性，默认不是“伪装”
    
    self.contents.font.color = text_color(0)#描绘怪物姓名
    if einfo.item_id>0 or einfo.weapon_id>0 or einfo.armor_id>0
      self.contents.font.color = text_color(1)#描绘怪物姓名
    end
    self.contents.draw_text(35, y+4, 80, 32, einfo.name.split(':')[0].to_s ,1)
    self.contents.font.size=16
      case einfo.dex
      when 1004
        self.contents.draw_text(35, y+68, 80, 32, "远古", 1)
      when 1003
        self.contents.draw_text(35, y+68, 80, 32, "君王Ⅲ", 1)
      when 1002
        self.contents.draw_text(35, y+68, 80, 32, "君王Ⅱ", 1)
      when 1001
        self.contents.draw_text(35, y+68, 80, 32, "君王Ⅰ", 1)
      when 1000
        self.contents.draw_text(35, y+68, 80, 32, "未来史诗", 1)
      when 999
        self.contents.draw_text(35, y+68, 80, 32, "领主", 1)
      when 998
        self.contents.draw_text(35, y+68, 80, 32, "精英", 1)
      when 997
        self.contents.draw_text(35, y+68, 80, 32, "喽啰", 1)
      when 996
        self.contents.draw_text(35, y+68, 80, 32, "守护者", 1)
      end
    self.contents.font.size=22
    xx=33
    if p==0
      self.contents.font.color = text_color(0)
      self.contents.draw_text(xx, y+28, 80, 32, "普通", 1)
    else
      if p<3
        kkk=0
        for i in $enemies_skills[einfo.id]
          if e.got_p(i)
            n=$data_skills[i].name.split(":")
            if p==2
              self.contents.font.size=18
            else
              self.contents.font.size=22
            end
            if n[1].to_s=="a"
              self.contents.font.color = text_color(n[2].to_i)
            else
              if n[4]==nil
                self.contents.font.color = Color.new(n[1].to_i,n[2].to_i,n[3].to_i)
              else
                self.contents.font.color = Color.new(n[1].to_i,n[2].to_i,n[3].to_i,n[4].to_i)
              end
            end
            
            @pro=n[0].to_s
            self.contents.draw_text(xx, y+28, 80, 32, @pro.to_s,1) if p==1
            self.contents.draw_text(xx+42*kkk, y+28, 42, 32, @pro.to_s,1) if p==2
            kkk+=1
          end
        end
      else
        self.contents.font.color = text_color(1)
        self.contents.draw_text(xx, y+28, 80, 32, "详细…", 1)
      end
    end
    self.contents.font.size=22
    if index*1.0/2 == index/2#单双数颜色变化
      self.contents.font.color = text_color(3)
    else
      self.contents.font.color = text_color(4)
    end
  
    if @name==0 #不是伪装属性

    
    
    
    def fuck(i)
      return "0" if i==0
      len=(i.abs.to_s).length
      len=[(len-4)/4,0].max
      return (i/(10**(len*4))).to_s+$shuwei[len+$game_variables[148]]
    end
        
    def fucko(i)
      return "0" if i==0
      len=(i.abs.to_s).length
      len=[(len-2)/4,0].max
      return (i/(10**(len*4))).to_s+$shuwei[len]
    end
      @dengji=$lvstr[einfo.str]
      
      ehp=einfo.maxhp
      #atk=einfo.atk
      atk=e.got_ea
      agi=einfo.agi
      pdef=einfo.pdef
      
      j=0
      if e.got_kind>0
      for i in $enemies_skills[einfo.id]
        if e.got_p(i)
          j+=1 if $data_skills[i].description.split("\\v").size>1
          case i
          when 4  #嗜血本能
            agi+=((1-$game_actors[$game_variables[1]+1].hprate)*100*einfo.name.split(":")[j].to_f).to_i
           when 72 #剑舞
             atk=einfo.atk
          when 107 #无影拳
            agi-=$data_enemies[einfo.id].agi-($game_actors[$game_variables[1]+1].atkspeed*einfo.name.split(":")[j].to_f).to_i
          
=begin
          when 3  #亡灵协同
            ehp=(ehp*(1+($game_variables[163]-1)*einfo.name.split(":")[j].to_i/100.0)).to_i
          when 4  #嗜血本能
            agi+=((1-$game_actors[$game_variables[1]+1].hprate)*100*einfo.name.split(":")[j].to_f).to_i
          when 99 #镜像
            atk=$game_actors[$game_variables[1]+1].str
            pdef=$game_actors[$game_variables[1]+1].dex
          when 107 #无影拳
            agi-=$data_enemies[einfo.id].agi-($game_actors[$game_variables[1]+1].atkspeed*einfo.name.split(":")[j].to_f).to_i
          when 157 #军团作战
            val=einfo.name.split(":")[j].split("-")
            b=val[1].to_f/100
            c=$game_actors[$game_variables[1]+1].str
            if c>atk
              atk+=((c-atk)*b).to_i
            end
            c=$game_actors[$game_variables[1]+1].dex
            if c>pdef
              pdef+=((c-pdef)*b).to_i
            end
=end
          end
        end
      end
      end
      
      self.contents.draw_text(168, y, a-8, 32, fuck(e.got_emaxhp), 1)
      self.contents.draw_text(320, y, a-8, 32, fuck(atk), 1)
      if (einfo.str>=16 && einfo.str<=300) || einfo.str>=337 || e.got_eshield[0]<0
        self.contents.draw_text(168, y+23, a-8, 32, fuck(agi)+"%", 1)
        self.contents.draw_text(320, y+23, a-8, 32, fuck(e.got_ed), 1) 
        self.contents.font.size=16
        co=self.contents.font.color
        if 1-e.got_enomagic<einfo.mdef/100.0-0.001
          self.contents.font.color = text_color(9)
        end
        self.contents.draw_text(168, y+44, a-8, 32, sprintf("%.1f",(1-e.got_enomagic)*100)+"%", 1) 
        self.contents.font.color=co
        co=self.contents.font.color
        if e.got_eshield[0]<einfo.eva
          self.contents.font.color = text_color(9)
        end
        if e.got_eshield[0]>=0
          self.contents.draw_text(320, y+44, a-8, 32, fuck(e.got_eshield[0].to_i)+\
          "("+"-"+((1000-(e.got_eshield[1]*1000).to_i)/10.0).to_s+"%)", 1) 
        else
          self.contents.draw_text(320, y+44, a-8, 32, fuck(e.got_eshield[0].to_i)+\
          "("+"+"+(-(1000-(e.got_eshield[1]*1000).to_i)/10.0).to_s+"%)", 1) 
        end 
        self.contents.font.color=co
        self.contents.font.size=22
      else
        self.contents.draw_text(168, y+32, a-8, 32, fuck(agi)+"%", 1)
        self.contents.draw_text(320, y+32, a-8, 32, fuck(e.got_ed), 1) 
      end
      self.contents.font.size=16
      self.contents.font.color = text_color($LvColor[einfo.str])
      self.contents.draw_text(24, y+50, a-8, 32, @dengji, 1)
      if e.got_nowin==00
        self.contents.font.size=16
        str=e.got_turncount
        self.contents.font.color = text_color(0)
        self.contents.draw_text(-2, y+53, 40, 32, "回合数", 1)
        if str>999
          self.contents.font.color = text_color(9)
          self.contents.draw_text(-2, y+68, 40, 32, "极高", 1)
        else
          self.contents.draw_text(-2, y+68, 40, 32, str.to_s, 1)
        end
      end
      self.contents.font.size=22
      self.contents.font.color = text_color(6)
self.contents.draw_text(168, y+64, a-8, 32, fucko(einfo.gold)+"/"+fucko(einfo.exp), 1
)
    else#伪装属性
      self.contents.draw_text(145, y, a-8, 32, "××", 1)
      self.contents.draw_text(255, y, a-8, 32, "××", 1)
      self.contents.draw_text(365, y, a-8, 32, "××", 1)
      self.contents.draw_text(255, y+32, a-8, 32, "××", 1)
      self.contents.draw_text(145, y+32,a-8, 32, "××", 1)
    end

    @edamage=e.got_damage
    self.contents.font.color = text_color(2)
    self.contents.font.color = text_color(0) if @edamage<=0
    self.contents.font.color = text_color(7) if @edamage>=$game_actors[$game_variables[1]+1].hp
    if e.got_nowin==2
      @edamage="?????"#怪物是无敌属性
      self.contents.font.color = text_color(8)
    elsif e.got_nowin==1
      @edamage="????" #勇士的攻击<怪物的防御
      self.contents.font.color = text_color(7)
    else
      if einfo.dex==996
      self.contents.font.color = text_color(5)
      end
      @edamage=fuck(@edamage)
    end
    self.contents.draw_text(320, y+64, a-8, 32, @edamage, 1) 


else#没有怪物手册则
end

  end
  #--------------------------------------------------------------------------
  # ● 刷新帮助文本
  #--------------------------------------------------------------------------
  def update_help
    @help_window.set_text(self.einfo == nil ? "" : self.einfo.description)
  end
end






