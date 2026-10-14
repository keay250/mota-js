#==============================================================================
# ■ Window_EquipHelp
#------------------------------------------------------------------------------
# 　装备辅助说明
#==============================================================================

class Window_EquipHelp < Window_Base
  #--------------------------------------------------------------------------
  # ● 初始化对像
  #--------------------------------------------------------------------------
  def initialize
    super(576, 0, 224,480)
  #  @content = Bitmap.new(width - 32, height - 32)
    @spr=[]
    @arrow=[]
    for i in 0...2
      @arrow[i]=Sprite.new
      @arrow[i].bitmap=self.windowskin
      @arrow[i].src_rect=Rect.new(144+i*24,26,8,12)
      @arrow[i].x=self.x+5+i*205
      @arrow[i].y=234
      @arrow[i].z=1001
      @arrow[i].visible=false
    end
    @nowpage=0
    @pagesize=0
  end
  #--------------------------------------------------------------------------
  # ● 设置文本
  #     text  : 窗口显示的字符串
  #     align : 对齐方式 (0..左对齐、1..中间对齐、2..右对齐)
  #--------------------------------------------------------------------------
  def set_text(text, align = 0)
    # 如果文本和对齐方式的至少一方与上次的不同
    if text != @text or align != @align
      for j in 0...@pagesize
        @spr[j].dispose
      end
      @spr=[]
      @pagesize=0
      @nowpage=0
      create_page(0)
      @content=@spr[0].bitmap
      # 再描绘文本
      @content.clear
      if text !=""
        @content.font.color = normal_color
        @content.font.size=16
      #  @content.draw_text(4, 0, self.width - 40, 32, text, align)
        id=text
        line=0
        a=$data_weapons[id].name.split(":")[0]
        ma=TextStream.new
        if ma.open("Info/Equip/"+a)
          linel=0
          maxlinel=0
          loop do
            maxlinel=@content.font.size
            s=ma.get_text(1).split("\n")[0]
            s=s[3,s.size-3] if line==0
            if s=="\\~\\/[END]"
              if linel==0
                @pagesize-=1
              end
              break
            end
            if $game_actors[$game_variables[1]+1].level<=15
              while s !=nil && (s[0,6]=="力量" || s[0,6]=="敏捷" || s[0,6]=="智力")
                s=ma.get_text(1).split("\n")[0]
                line+=1
                linel+=maxlinel
              end
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
              stpos=174-@content.text_size(ss[0,ss.size]).width
            end
            loop do
              break if s==nil
              while s[pos,1]=="\\"
                kind=s[pos+1,1]
                s=s[0,pos]+s[pos+2,s.size-pos-2]
                num=s.sub!(/\[([0-9]+)\]/, "")
                case kind
                when "C"
                  @content.font.color = text_color($1.to_i)
                when "S"
                  @content.font.size=$1.to_i
                when "K"
                  case $1.to_i
                  when 0
                    s=s[0,pos]+$data_weapons[id].price.to_s+s[pos,s.size-pos]
                  when 1
                    s=s[0,pos]+(($game_actors[$game_variables[1]+1].init_maxsp*0.2).to_i).to_s+s[pos,s.size-pos]
                  when 2
                    if $game_variables[237]!=0 #有附魔
                      s=s[0,pos]+"\\N[0]\\C[14]\\S[18]传奇附魔\\N[0]\\S[14]"
                      for i in 0...$game_variables[237].size
                        ss=$game_variables[237][i][1].split("：")
                        s+="\\C[17]"+ss[0]+" \\C[0]"+ss[1]+"\\N[0]"
                      end
                    end
                  when 3
                    s=s[0,pos]+rnumber($game_variables[238][0])+s[pos,s.size-pos]
                  when 4
                    s=s[0,pos]+rnumber($game_variables[238][1])+s[pos,s.size-pos]
                  when 5
                    s=s[0,pos]+(($game_actors[$game_variables[1]+1].init_maxsp*0.25).to_i).to_s+s[pos,s.size-pos]
                  when 6
                    s=s[0,pos]+(($game_actors[$game_variables[1]+1].init_maxsp*0.4).to_i).to_s+s[pos,s.size-pos]
                  when 7
                    s=s[0,pos]+(($game_actors[$game_variables[1]+1].init_maxsp*0.3).to_i).to_s+s[pos,s.size-pos]
                  when 8
                    zsStr=["\\C[10]无属性","\\C[2]力量","\\C[3]敏捷","\\C[1]智力"]
                    s=s[0,pos]+zsStr[$game_variables[154]]+"\\C[0]"+s[pos,s.size-pos]
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
                    stpos=189-@content.text_size(ss[0,ss.size]).width
                  end
                when "N"
                  posl=0
                  line+=1
                  linel+=maxlinel
                end
              end
              if s[pos]!=nil
=begin
                if line==0
                  savecolor=@content.font.color.clone
                  if s[pos]<128
                    len=1
                  else
                    len=3
                  end
                  @content.font.color=text_color(0)
                  @content.draw_text(posl+stpos-1,linel, @content.font.size,@content.font.size, s[pos,len], align)
                  @content.draw_text(posl+stpos+1,linel, @content.font.size,@content.font.size, s[pos,len], align)
                  @content.draw_text(posl+stpos,linel-1, @content.font.size,@content.font.size, s[pos,len], align)
                  @content.draw_text(posl+stpos,linel+1, @content.font.size,@content.font.size, s[pos,len], align)
                  @content.font.color=savecolor
                  # @content.font.size+=1
                 # @content.font.size-=1
               end
=end
                if s[pos]<128
                  @content.draw_text(posl+stpos,linel, @content.font.size,@content.font.size, s[pos,1], align)
                  posl+=@content.text_size(s[pos,1]).width
                  if @content.text_size(s[pos,1]).height>maxlinel
                    maxlinel=@content.text_size(s[pos,1]).height
                  end
                  pos+=1
                else
                  @content.draw_text(posl+stpos,linel, @content.font.size,@content.font.size, s[pos,3], align)
                  posl+=@content.text_size(s[pos,3]).width
                  if @content.text_size(s[pos,3]).height>maxlinel
                    maxlinel=@content.text_size(s[pos,3]).height
                  end
                  pos+=3
                end
              else
                pos+=1
              end
              if s[pos,2]!="\\N" && posl>180
                posl=0
                line+=1
                linel+=maxlinel
                #换页
                if linel>440 && linel<480
                  linel=0
                  create_page(@pagesize)
                  @content=@spr[@spr.size-1].bitmap
                  @content.font=@spr[@spr.size-2].bitmap.font.clone
                end
              end
              break if pos>s.size
            end
            
            line+=1
            linel+=maxlinel 
            #换页
            if linel>440 && linel<480
              linel=0
              create_page(@pagesize)
              @content=@spr[@spr.size-1].bitmap
              @content.font=@spr[@spr.size-2].bitmap.font.clone
            end
          end

        end
      end
      @text = text
      @align = align
      @actor = nil
      show_page(0)
    end
   # self.visible = true
  end
  
  def show_page(i)
    for j in 0...@pagesize
      if i==j
        @spr[j].visible=true
      else
        @spr[j].visible=false
      end
    end
  end
  def create_page(i)
    @pagesize=i+1
    if @spr[i] !=nil
      @spr[i].bitmap.clear
      return
    end
    @spr[i]=Sprite.new
    @spr[i].bitmap = Bitmap.new(width - 32, height - 32)
    @spr[i].x = self.x+16
    @spr[i].y = self.y+16
    @spr[i].z = 1000
    @spr[i].visible=false
  end
  #--------------------------------------------------------------------------
  # ● 销毁处理
  #--------------------------------------------------------------------------
  def dispose
    super
    for spr in @spr
      spr.bitmap.dispose
      spr.dispose
    end
    for spr in @arrow
      spr.dispose
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新处理
  #--------------------------------------------------------------------------
  def update
    super
    if Kboard.trigger?($R_Key_TAB) && @pagesize>1
      @nowpage+=1
      if @nowpage>=@pagesize
        @nowpage=0
      end
      show_page(@nowpage)
      Audio.se_play("Audio/SE/046-Book01")
    end
    @time=(Graphics.frame_count%48-24).abs/8
    if @nowpage<@pagesize-1
      @arrow[1].visible=true
      @arrow[1].ox=@time-2
    else
      @arrow[1].visible=false
    end
    if @nowpage>0
      @arrow[0].visible=true
      @arrow[0].ox=-@time+1
    else
      @arrow[0].visible=false
    end
  end
  #--------------------------------------------------------------------------
  # ● 设置角色
  #     actor : 要显示状态的角色
  #--------------------------------------------------------------------------
  def set_actor(actor)
    if actor != @actor
      @content.clear
      draw_actor_name(actor, 4, 0)
      draw_actor_state(actor, 140, 0)
      draw_actor_hp(actor, 284, 0)
      draw_actor_sp(actor, 460, 0)
      @actor = actor
      @text = nil
      self.visible = true
    end
  end
  #--------------------------------------------------------------------------
  # ● 设置敌人
  #     enemy : 要显示名字和状态的敌人
  #--------------------------------------------------------------------------
  def set_enemy(enemy)
    text = enemy.name
    state_text = make_battler_state_text(enemy, 112, false)
    if state_text != ""
      text += "  " +"黑糊糊"+ state_text
    end
    set_text(text, 1)
  end
  def rnumber(i)
     return "0" if i==0
      len=(i.abs.to_s).length
      len=[(len-2)/4,0].max
      return (i/(10**(len*4))).to_s+$shuwei[len+$game_variables[148]]
    end
end
