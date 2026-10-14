
Playerdate_SWITCH = 1 # 当1号开关打开，本脚本才开始工作。
Playerdate_magicdef =19
Yellowkey_itemid=1
Bluekey_itemid=2
Redkey_itemid=3
Greenkey_itemid=41

   def fuck(i)
     return "0" if i==0
      len=(i.abs.to_s).length
      if len%4==2 && len>4
        len=[(len-2)/4,0].max
        return sprintf("%.1f",(i*10/(10**(len*4))/10.0))+$shuwei[len+$game_variables[148]]
      else
        len=[(len-2)/4,0].max
        return (i/(10**(len*4))).to_s+$shuwei[len+$game_variables[148]]
      end
    end
    
      def fucko(i)
        return "0" if i==0
      len=(i.abs.to_s).length
      len=[(len-4)/4,0].max
      return (i/(10**(len*4))).to_s+$shuwei[len]
    end
    def fuckp(i)
       len=(i.abs.to_s).length
      if len%3==1 && len>3
        len=[(len-1)/3,0].max
        return sprintf("%.1f",(i*10/(10**(len*3))/10.0))+$shuwei3[len+$game_variables[148]]
      else
        len=[(len-1)/3,0].max
        return (i/(10**(len*3))).to_s+$shuwei3[len]
      end
    end
    
#==============================================================================
# ■ Window_PlayerDate
#------------------------------------------------------------------------------
# 　显示玩家状态的窗口。
#==============================================================================

class Window_PlayerDate < Window_Base
  #--------------------------------------------------------------------------
  # ● 初始化窗口
  #--------------------------------------------------------------------------
  def initialize
    super(0, 0, 170, 480)#395)#192，416
    self.contents = Bitmap.new(width - 32, height - 32)
    self.z =210
    self.opacity=0
    self.back_opacity =255
    self.visible = false
    @first=true
    @actor=$game_actors[$game_variables[1]+1]
    
    @attrSpr=[]
    for i in 0...3
      @attrSpr[i]=Sprite.new
      @attrSpr[i].bitmap=RPG::Cache.picture("AttrsIcon")
      @attrSpr[i].x=17+i*42
      @attrSpr[i].y=342
      @attrSpr[i].z=self.z+1
      @attrSpr[i].visible=false
    end
    refresh
  end  
  def dispose
    super
    for i in 0...3
      @attrSpr[i].dispose
    end
  end
  def visible=(visible)
    super
    if @attrSpr !=nil
      for i in 0...3
        @attrSpr[i].visible=visible
      end
    end
  end
  def refresh
    if !@first && $game_switches[171]
      self.contents.fill_rect(2,83,130,20,$mapdamage_obj.getcolor(0))
      @xlife=@actor.hp
      @xmlife=@actor.maxhp
      str=fuck(@xlife)+"/"+fuck(@xmlife)
      if self.contents.text_size(str).width<=110
        self.contents.font.color = system_color
        self.contents.draw_text(4, 83, 40, 20, "生命", 0)
        self.contents.font.color = normal_color
        self.contents.draw_text(38,83, 90, 20,str, 2)
      else
        self.contents.font.color = normal_color
        self.contents.draw_text(2,83, 130, 20,str, 1)
      end
    
      return
    end
    @first=false
    self.contents.clear
    x=35
    y=10
 #   draw_actor_graphic($game_party.actors[0], 20, 40)
    #勇士图形
    self.contents.font.color = system_color
    self.contents.draw_text(28, 11, 25, 20, "第", 0) if $game_switches[64]
    self.contents.draw_text(88, 11, 25, 20, "层", 0)if $game_switches[64]
    self.contents.draw_text(2, 48, 50, 20, "等级", 0)
    
    self.contents.draw_text(4, 48+x*2, 40, 20, "魔法", 0) #if @actor.maxsp>0
#    self.contents.draw_text(4, 65+x*1.5, 40, 20, "生命", 0) if !$game_switches[135]
    self.contents.draw_text(4, 48+x*3, 40, 20, "攻击", 0)
    self.contents.draw_text(4, 48+x*3.8, 40, 20,"防御", 0)
    self.contents.draw_text(4, 48+x*4.6, 40, 20, "攻速", 0)
    self.contents.draw_text(4, 48+x*5.5, 40, 20, "护甲", 0)

    self.contents.draw_text(4, 45+x*6.4, 40, 20, "进阶", 0)
    self.contents.draw_text(4, 45+x*7.2, 40, 20, "金钱", 0)

    if $game_switches[26]
      bitmap = RPG::Cache.icon("101-01")#黄钥匙)
      self.contents.blt(5, 399, bitmap, Rect.new(0, 0, 32, 32))    
      bitmap = RPG::Cache.icon("101-02")#蓝钥匙)
      self.contents.blt(35, 399, bitmap, Rect.new(0, 0, 32, 32))
      bitmap = RPG::Cache.icon("101-03")#红钥匙)
      self.contents.blt(65, 399, bitmap, Rect.new(0, 0, 32, 32))
      bitmap = RPG::Cache.icon("101-04") if $game_switches[43]#绿钥匙)
      self.contents.blt(95, 399, bitmap, Rect.new(0, 0, 32, 32))
      
    else
      self.contents.font.color = text_color(6)    
      self.contents.draw_text(8, 275, 50, 20, "黄钥匙", 0)
      self.contents.font.color = text_color(4)    
      self.contents.draw_text(8, 303, 50, 20, "蓝钥匙", 0)
      self.contents.font.color = text_color(2)    
      self.contents.draw_text(8, 331, 50, 20, "红钥匙", 0)
      self.contents.font.color = text_color(3)    
      self.contents.draw_text(8, 359, 50, 20, "绿钥匙", 0) if $game_switches[43]
    end
    @xgraphic=$game_party.actors[0]
    @xfloor=$game_variables[2]
    if !$game_switches[203]
      @xlevel=$lvstr[@actor.level]
    else
      @xlevel=$lvstr2[@actor.level]
    end
    @xlife=@actor.hp
    @xmlife=@actor.maxhp
    @xlifere=@actor.hprecover.to_i
    @xmagic=@actor.sp
    @xmmagic=@actor.maxsp
    @xmagicp=@actor.sprecover#@actor.magicpower
    @xatkspe=@actor.atkspeed
    @xshield=@actor.shield-$juewang
    @xattact=@actor.str
    @xdefence=@actor.dex
    @xexp= @actor.exp
    @xgold=$game_party.gold
    @xyellowkey=$game_party.item_number(Yellowkey_itemid)
    @xbluekey=$game_party.item_number(Bluekey_itemid)
    @xredkey=$game_party.item_number(Redkey_itemid)
    @xgreenkey=$game_party.item_number(Greenkey_itemid) if $game_switches[43]
   
    for i in 0...3
      if $game_variables[154]==i+1
        @attrSpr[i].src_rect=Rect.new(i*36+108,0,36,36)
      else
        @attrSpr[i].src_rect=Rect.new(i*36,0,36,36)
      end
    end
    
    self.contents.font.color = text_color($LvColor[@actor.level])
    self.contents.draw_text(50, 43, 80, 30, @xlevel.to_s, 2)
    self.contents.font.color = normal_color
    @mapid=$game_map.map_id
      #  self.contents.font.name="隶书"
    self.contents.draw_text(10, 0, 120, 45, @xfloor.to_s, 1) if $game_switches[64]
    self.contents.draw_text(-2, 0, 140, 45, $data_mapname[@mapid].name,1) if !$game_switches[64]
   # self.contents.font.name="黑体"
   # if $game_switches[401]
   #   else

    if $game_variables[161]>0
      self.contents.font.size=16
      self.contents.font.color = text_color(2)
      self.contents.draw_text(32, 50+x*3, 50, 20,"("+$game_variables[161].to_s+"/3)", 2)
      self.contents.font.size=22
      self.contents.font.color = normal_color
    end
    if $game_variables[162]>0
      self.contents.font.size=16
      self.contents.font.color = text_color(1)
      self.contents.draw_text(32, 50+x*3.8, 50, 20,"("+$game_variables[162].to_s+"/3)", 2)
      self.contents.font.size=22
      self.contents.font.color = normal_color
    end
    str=fuck(@xlife)+"/"+fuck(@xmlife)
    if self.contents.text_size(str).width<=110
      self.contents.font.color = system_color
      self.contents.draw_text(4, 48+x, 40, 20, "生命", 0)
      self.contents.font.color = normal_color
=begin
      long=@xlife*90/@xmlife
      src=Rect.new(130-long+1,48+x+2,long,0)
      self.contents.fill_rect(40,src.y-1,92, 22, Color.new(255,255,255)) 
      self.contents.fill_rect(41,src.y,90, 20, Color.new(0,0,0)) 
      self.contents.fill_rect(src.x,src.y,src.width, 10, Color.new(255,0,0)) 
      self.contents.fill_rect(src.x,src.y+10,src.width, 5, Color.new(220,0,0))
      self.contents.fill_rect(src.x,src.y+15,src.width, 3, Color.new(180,0,0))
      self.contents.fill_rect(src.x,src.y+18,src.width, 2, Color.new(150,0,0))
=end
      self.contents.draw_text(38,48+x, 90, 20,str, 2)
    else
=begin
      long=@xlife*130/@xmlife
      src=Rect.new(130-long+1,48+x+2,long,0)
      self.contents.fill_rect(0,src.y-1,132, 22, Color.new(255,255,255)) 
      self.contents.fill_rect(1,src.y,130, 20, Color.new(0,0,0)) 
      self.contents.fill_rect(src.x,src.y,src.width, 10, Color.new(255,0,0)) 
      self.contents.fill_rect(src.x,src.y+10,src.width, 5, Color.new(220,0,0))
      self.contents.fill_rect(src.x,src.y+15,src.width, 3, Color.new(180,0,0))
      self.contents.fill_rect(src.x,src.y+18,src.width, 2, Color.new(150,0,0))
=end
      self.contents.draw_text(2,48+x, 130, 20,str, 1)
    end
    
    
    self.contents.draw_text(38, 48+x*2, 90, 20,fuck(@xmagic)+"/"+fuck(@xmmagic), 2)# if @actor.maxsp>0
    
    if @actor.str_minus
      self.contents.font.color = text_color(9)
    else
      self.contents.font.color = normal_color
    end
    self.contents.draw_text(38, 48+x*3, 90, 20,fuck(@xattact), 2)
    if @actor.dex_minus
      self.contents.font.color = text_color(9)
    else
      self.contents.font.color = normal_color
    end
    self.contents.draw_text(38, 48+x*3.8, 90, 20,fuck(@xdefence), 2)
    self.contents.font.color = normal_color
    check=@actor.atkspeed(true)
    if @xatkspe<check
      self.contents.font.color = text_color(9)
      self.contents.draw_text(38, 48+x*4.6, 90, 20,@xatkspe.to_s+"%(-"+(check-@xatkspe).to_s+")", 2)
    elsif @xatkspe>check
      self.contents.font.color = text_color(3)
      self.contents.draw_text(38, 48+x*4.6, 90, 20,@xatkspe.to_s+"%("+(@xatkspe-check).to_s+")", 2)
    else
      self.contents.draw_text(38, 48+x*4.6, 90, 20,@xatkspe.to_s+"%", 2)
    end
    if $juewang>0
      self.contents.font.color = text_color(9)
    else
      self.contents.font.color = normal_color
    end
    self.contents.draw_text(38, 48+x*5.5, 90, 20,@xshield.to_s, 2)
    self.contents.font.color = normal_color
  #@cha=[(@xgold-@xexp),0].max
    if !$game_switches[203]
      maxexp=$expmax[@actor.level]
    else
      maxexp=$expmax2[@actor.level]
    end
    self.contents.draw_text(38, 48+x*6.4, 90, 20,fucko(maxexp-@xexp), 2)
    self.contents.draw_text(38, 48+x*7.2, 90, 20,fucko(@xgold), 2)
    
    self.contents.font.size=15
    if @xlifere>=0
      self.contents.font.color = text_color(3)
      if $game_variables[192]>0
        self.contents.draw_text(38, 48+x*1.5, 90, 20,"+"+@xlifere.to_s+"(-"+$game_variables[192].to_s+")/t", 2)
      else
        self.contents.draw_text(38, 48+x*1.5, 90, 20,"+"+@xlifere.to_s+"/t", 2)
      end
    else
      self.contents.font.color = text_color(9)
      if $game_variables[192]>0
        self.contents.draw_text(38, 48+x*1.5, 90, 20,@xlifere.to_s+"(-"+$game_variables[192].to_s+")/t", 2)
      else
        self.contents.draw_text(38, 48+x*1.5, 90, 20,@xlifere.to_s+"/t", 2)
      end
    end
    
    if @xmagicp>=0
      self.contents.font.color = text_color(1)
      self.contents.draw_text(38, 48+x*2.5, 90, 20,"+"+sprintf("%.2f",@xmagicp)+"/t", 2) #if @actor.maxsp>0
    else
      self.contents.font.color = text_color(9)
      self.contents.draw_text(38, 48+x*2.5, 90, 20,sprintf("%.2f",@xmagicp)+"/t", 2)
    end
    
    self.contents.font.color = text_color(9)
    self.contents.draw_text(38, 48+x*5.1, 90, 20,"*"+sprintf("%.2f",Math.sqrt(@xatkspe)/10.0), 2)
    self.contents.font.color = text_color(4)
    rshield=@actor.prshield(@xshield)
    if @xshield>=0
      if rshield<=1
        self.contents.draw_text(38, 48+x*6.0, 90, 20,"-"+((1000-(rshield*1000).to_i)/10.0).to_s+"%", 2)
      else
        self.contents.draw_text(38, 48+x*6.0, 90, 20,"+"+((1000-(rshield*1000).to_i)/10.0).abs.to_s+"%", 2)
      end
    else
      self.contents.draw_text(38, 48+x*6.0, 90, 20,"+"+((rshield.abs*1000-1000).to_i/10.0).to_s+"%", 2)
    end
    #+"(*"+sprintf("%.1f",Math.sqrt(@xatkspe)/10.0).to_s+")"
    self.contents.font.size=22
    self.contents.font.color = text_color(6)
    self.contents.draw_text(12, 416, 25, 20, @xyellowkey.to_s, 2)
    self.contents.font.color = text_color(4)
    self.contents.draw_text(42, 416, 25, 20, @xbluekey .to_s, 2)
    self.contents.font.color = text_color(2)
    self.contents.draw_text(72, 416, 25, 20, @xredkey.to_s, 2)
    self.contents.font.color = text_color(3)
    self.contents.draw_text(102, 416, 25, 20, @xgreenkey.to_s, 2) if $game_switches[43]
    self.contents.font.size=20
    if @actor.power1_minus
      self.contents.font.color = text_color(9)
    else
      self.contents.font.color = text_color(2)
    end
    self.contents.draw_text(-4,365,60,20,fuckp(@actor.power1),1)
    if @actor.power2_minus
      self.contents.font.color = text_color(9)
    else
      self.contents.font.color = text_color(3)
    end  
    self.contents.draw_text(-4+42,365,60,20,fuckp(@actor.power2),1)
    if @actor.power3_minus
      self.contents.font.color = text_color(9)
    else
      self.contents.font.color = text_color(4)
    end 
    self.contents.draw_text(-4+83,365,60,20,fuckp(@actor.power3),1)
    self.contents.font.size=22
    $game_switches[188]=true
  end

  def judge#用于判断是否数据变更，节约内存
    return true if @xlife!=@actor.hp
    return false if $game_switches[171]
    return true if @xgraphic!=$game_party.actors[0]
    return true if @xfloor!=$game_variables[2]
    if !$game_switches[203]
      return true if @xlevel!=$lvstr[@actor.level]
    else
      return true if @xlevel!=$lvstr2[@actor.level]
    end
    return true if @xmlife!=@actor.maxhp
    return true if @xlifere!=@actor.hprecover.to_i
    return true if @xmagic!=@actor.sp
    return true if @xmmagic!=@actor.maxsp
    return true if @xmagicp!=@actor.sprecover#@actor.magicpower
    return true if @xatkspe!=@actor.atkspeed
    return true if @xshield!=@actor.shield-$juewang
    return true if @xattact!=@actor.str
    return true if @xdefence!=@actor.dex
    return true if @xexp!= @actor.exp
    return true if @xgold!=$game_party.gold
    return true if @xyellowkey!=$game_party.item_number(Yellowkey_itemid)
    return true if @xbluekey!=$game_party.item_number(Bluekey_itemid)
    return true if @xredkey!=$game_party.item_number(Redkey_itemid)
    return true if @xgreenkey!=$game_party.item_number(Greenkey_itemid) if $game_switches[43]
    return true if @mapid!=$game_map.map_id
    return true if $game_switches[56]
    return false
  end
end


###########################################################################
#                           下面的东西不需要掌握~                         #
###########################################################################

class Scene_Map
 alias xy_66rpg_main main
 def main
   @spriteset = Spriteset_Map.new
   $mapdamage_obj.dispose if $mapdamage_obj != nil && !$mapdamage_obj.canvas[1].disposed? 
   $mapdamage_obj = Map_damage.new
   @Playerdate_window = Window_PlayerDate.new
   @Playerdate_window2 = Window_PlayerDate2.new
   if $game_switches[171]  
     if @boss_window==nil
       @boss_window=Window_BossStatus.new
       @boss_window.x=160
       if $game_switches[171]
         @boss_window.refresh 
         @boss_window.sprvi(true)
       else
         @boss_window.sprvi(false)
       end
     end
   end
   $scene.check_date_lr
   if $game_switches[Playerdate_SWITCH]
     @Playerdate_window .visible = true
     @Playerdate_window2 .visible = true
     @Playerdate_window2 .sprvi(true)
   end
   @spriteset.update
   xy_66rpg_main
   @Playerdate_window .dispose
   @Playerdate_window2 .dispose
   if @boss_window !=nil
     @boss_window.dispose
     @boss_window=nil
   end
   $mapdamage_obj.dispose
   $mapdamage_obj=nil
 end
 #--------------------------------------------------------------------------
 # ● 刷新画面
 #--------------------------------------------------------------------------
 alias xy_66rpg_update update
 def update
   xy_66rpg_update
   if $game_switches[Playerdate_SWITCH]
     @Playerdate_window .visible = true
     @Playerdate_window2 .visible = true
     @Playerdate_window2 .sprvi(true)
     $game_switches[188]=false
     if @Playerdate_window.judge
       @Playerdate_window.refresh 
     end
     if @Playerdate_window2.judge
       @Playerdate_window2.refresh 
     end
     $game_switches[56]=false
   else
     @Playerdate_window .visible = false
     @Playerdate_window2 .visible = false
     @Playerdate_window2 .sprvi(false)
   end
   if $game_switches[171]  
     if @boss_window==nil
       @boss_window=Window_BossStatus.new
       @boss_window.x=160
       if $game_switches[171]
         @boss_window.refresh 
         @boss_window.sprvi(true)
       else
         @boss_window.sprvi(false)
       end
     end
     @boss_window .refresh if @boss_window.judge
     @boss_window.sprvi(true) if !@boss_window.visible
     @boss_window.update
   else
     @boss_window.sprvi(false) if @boss_window !=nil && @boss_window.visible
   end
 end
 def check_date_lr
   if $game_variables[82]==0
     @Playerdate_window.x = -5 
     @Playerdate_window2.x = 635
   else
     @Playerdate_window2.x = -8 
     @Playerdate_window.x = 638
   end
   @Playerdate_window2.resetsprx
 end
end