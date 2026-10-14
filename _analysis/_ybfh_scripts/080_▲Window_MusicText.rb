#==============================================================================
# ■ Window_MusicText
#------------------------------------------------------------------------------
# 　音乐介绍窗口
#==============================================================================

class Window_MusicText < Window_Base
  #--------------------------------------------------------------------------
  # ● 初始化对像
  #--------------------------------------------------------------------------
  def initialize
    super(265, 315, 468,180)
    @text_width=self.width-66
    self.contents = Bitmap.new(self.width - 32, self.height - 32)
  end
  #--------------------------------------------------------------------------
  # ● 设置文本
  #     text  : 窗口显示的字符串
  #     align : 对齐方式 (0..左对齐、1..中间对齐、2..右对齐)
  #--------------------------------------------------------------------------
  def set_text(name, align = 0)
      self.contents.clear
      self.contents.font.color = normal_color
      self.contents.font.size=18
        line=0
        align=0
        stpos=0
        ma=TextStream.new
        if ma.open("Info/Music/"+name)
          s=ma.get_all
          sk=s.split("Lv")
          s=sk[0]
          linel=0
          line2=0
          maxlinel=0
          text=s.split("\n")
          text[0]="\\A[1]"+text[0][3,text[0].size-3]+"\\A[0]\\S[16]"
          loop do
            maxlinel=self.contents.font.size
            break if line2>=text.size
            s=text[line2]
            line2+=1
            if s=="\\~\\/[END]"
              break
            end
            pos=0
            if linel>0
              posl=self.contents.font.size
            else
              posl=0
            end
            case align
            when 0
              stpos=0
            when 2
              ss=s+""
              ss.gsub!(/\[([0-9]+)\]/, "")
              ss.gsub!(/\\([A-Z])/, "")
              stpos=@text_width-6-self.contents.text_size(ss[0,ss.size]).width
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

                when "A"
                  align=$1.to_i
                  case align
                  when 0
                    stpos=0
                  when 1
                    ss=s+""
                    ss.gsub!(/\[([0-9]+)\]/, "")
                    ss.gsub!(/\\([A-Z])/, "")
                    stpos=@text_width/2+12-self.contents.text_size(ss[0,ss.size]).width/2
                  when 2
                    ss=s+""
                    if ss.split("\K[0]").size>0
                      ss+=$data_weapons[id].price.to_s
                    end
                    ss.gsub!(/\[([0-9]+)\]/, "")
                    ss.gsub!(/\\([A-Z])/, "")
                    stpos=@text_width+9-self.contents.text_size(ss[0,ss.size]).width
                  end
                when "N"
                  posl=0
                  line+=1
                  linel+=maxlinel+2
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
              if posl>@text_width
                posl=0
                line+=1
                linel+=maxlinel+2
              end
              break if pos>s.size
            end
            line+=1
            linel+=maxlinel+2
            if line==1
              linel+=6
            end
          end
        end
    self.visible = true
  end
end
