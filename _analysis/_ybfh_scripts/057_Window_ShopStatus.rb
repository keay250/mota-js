#==============================================================================
# ■ Window_ShopStatus
#------------------------------------------------------------------------------
# 　商店画面、显示物品所持数与角色装备的窗口。
#==============================================================================

class Window_ShopStatus < Window_Base
  #--------------------------------------------------------------------------
  # ● 初始化对像
  #--------------------------------------------------------------------------
  def initialize
    super(576, 0, 224,480)
    self.contents = Bitmap.new(width - 32, height - 32)
    @item = nil
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 刷新
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    if @item == nil
      return
    end
    if @item.is_a?(RPG::Item)
      return
    end
    # 添加装备品信息
    for i in 0...$game_party.actors.size
      # 获取角色
      actor = $game_party.actors[i]
      # 可以装备为普通文字颜色、不能装备设置为无效文字颜色
      if actor.equippable?(@item)
        self.contents.font.color = normal_color
      else
        self.contents.font.color = disabled_color
      end
      # 描绘角色名字
     # self.contents.draw_text(4, 64 + 64 * i, 120, 32, actor.name)
    end

      # 如果文本和对齐方式的至少一方与上次的不同
    if @item.is_a?(RPG::Weapon)
      # 再描绘文本
        self.contents.font.color = normal_color
        self.contents.font.size=16
        line=0
        align=0
        a=@item.name.split(":")[0]
        ma=TextStream.new
        if ma.open("Info/Equip/"+a)
          linel=0
          maxlinel=0
          loop do
            maxlinel=self.contents.font.size
            s=ma.get_text(1).split("\n")[0]
            s=s[3,s.size-3] if line==0
            if s=="\\~\\/[END]"
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
                  case $1.to_i
                  when 0
                    s=s[0,pos]+@item.price.to_s+s[pos,s.size-pos]
                  when 1
                    s=s[0,pos]+(($game_actors[$game_variables[1]+1].init_maxsp*0.2).to_i).to_s+s[pos,s.size-pos]
                  end
                when "A"
                  align=$1.to_i
                  case align
                  when 0
                    stpos=0
                  when 2
                    ss=s+""
                    if ss.split("\K[0]").size>0
                      ss+=@item.price.to_s
                    end
                    ss.gsub!(/\[([0-9]+)\]/, "")
                    ss.gsub!(/\\([A-Z])/, "")
                    stpos=189-self.contents.text_size(ss[0,ss.size]).width
                  end
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
      end

  end
  #--------------------------------------------------------------------------
  # ● 设置物品
  #     item : 新的物品
  #--------------------------------------------------------------------------
  def item=(item)
    if @item != item
      @item = item
      refresh
    end
  end
end
