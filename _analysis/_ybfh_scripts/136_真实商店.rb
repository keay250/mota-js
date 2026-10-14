#============================================================================== 
# 本脚本来自www.66rpg.com，转载和使用请保留此信息  
# 脚本名：真实商店，脚本作者：柳柳  
#============================================================================== 
#  
# 功能：  
#  
# 买进卖出的物品在商店有所体现，卖出后会在商店可买物品中出现，物品有数量限制  
# 商店可进货出货————总之就是模拟真实商店。  
#   
# 这个脚本和原装商店并不冲突，两个商店可以并存。  
#  
# 使用方法：  
#  
# 1、在下面被井号框起来的中间部分，设置初期物品。格式如下：  
#    @goods[商店编号] = [ [种类，ID，可卖数量] ,  [种类，ID，可卖数量]......]  
#    其中种类，0为道具，1为武器，2为防具；ID是数据库编号  
#  
# 2、调用：$scene = Scene_Shop_Va.new(商店编号)   
#    比如你可以直接测试$scene = Scene_Shop_Va.new(1),已经设置好了。  
#  
# 3、商店出货：$game_system.shop_change(商店编号，种类，ID，数量)  
#    如果是进货，把数量设置为负数即可  
#  
#============================================================================== 
# ■ Scene_Shop  
#------------------------------------------------------------------------------  
# 　处理商店画面的类。  
#============================================================================== 
class Game_System  
 def shop_change(shop,kind,id,delnumber)  
   dl = delnumber  
   for dt in $game_variables[172][shop]  
     if (dt[0]==kind) and (dt[1]==id)  
       dt[2] -= dl  
       dt[2] = [dt[2],99].min  
       if dt[2] == 0  
         $game_variables[172][shop].delete(dt)  
       end  
       return  
     end  
   end  
   $game_variables[172][shop].push([kind,id,-delnumber])  
 end  
end

$goods=[]
$goods[1] = [[1,1,5],[1,2,5],[1,3,1],[1,6,2]]   
$goods[2] = [[1,8,2],[1,11,1],[1,7,1]]   
$goods[3] = [[1,17,5],[1,11,4],[1,13,4],[1,16,3],[1,7,3],[1,19,2],[1,4,2],[0,50,2],[0,51,1],[0,49,1]]   
$goods[4] = [[1,19,1],[1,24,1],[1,27,1],[1,28,1],[0,64,1]]   
$goods[5] = [[1,17,5],[1,4,3],[1,43,1],[1,44,10],[1,35,1],[1,36,5],[1,20,3],[1,27,3],[1,28,3],[1,37,3],[1,46,3],[1,47,3],[1,48,3],[1,24,3],[1,40,2],[0,70,1],[0,67,1],[0,68,1],[0,69,1]]   
$goods[6] = [[0,72,1],[0,73,1],[0,77,1],[0,74,1],[0,71,3],[0,75,3],[0,76,3],[0,85,3]]   
$goods[7] = [[1,43,3],[1,36,5],[1,44,5],[1,27,5],[1,37,5],[1,46,5],[1,47,5],[1,48,5],[1,70,3],[1,73,2],[1,60,1],[0,89,1],[0,90,1],[0,91,1],[0,92,1],[0,93,1]]   
$goods[8] = [[1,77,40],[0,94,5],[0,95,5]]
$goods[9] = [[0,103,99],[1,84,3],[1,88,3],[1,87,2],[1,83,2],[1,80,1],[0,97,1],[0,99,1],[0,100,1],[0,101,1],[0,96,1],[0,94,5],[0,95,5]]
$goods[10] = [[1,24,10],[1,118,10],[1,119,8],[1,120,8],[1,84,5],[1,87,5],[1,83,5],[1,129,5],[1,71,5],[1,110,10],[1,111,10],[1,112,10],
              [1,127,3],[0,107,5],[0,108,5],[0,109,1],[0,110,1],[0,111,1],[0,112,1],[0,113,1]]
$goods[11] = [[0,98,5],[1,65,1]]
class Scene_Shop_Va  
 def initialize(shop_number)  
   # 当前商店编号  
   if $game_variables[172]==0
     $game_variables[172]=[]
   end
   if $game_variables[172][shop_number]==nil
     $game_variables[172][shop_number]=[]
     for i in 0..$goods[shop_number].size-1
       $game_variables[172][shop_number][i]=[]
       for j in $goods[shop_number][i]
         $game_variables[172][shop_number][i].push(j)
       end
     end
   end
   for i in $game_variables[172][shop_number]
     if i[1]==9
       $game_variables[172][shop_number].delete(i)
     end
   end
  # $game_variables[172][5].insert(15,[1,24,3])
   @shop_now = shop_number      
 end    
 #--------------------------------------------------------------------------  
 # ● 主处理  
 #--------------------------------------------------------------------------  
 def main  
   # 生成帮助窗口  
   @help_window = Window_Help.new(576)
   # 生成指令窗口  
   @command_window = Window_ShopCommand.new  
   # 生成金钱窗口  
   @gold_window = Window_Gold.new   
   # 生成时间窗口  
   @dummy_window = Window_Base.new(0, 128,576,352)  
   # 生成购买窗口  
   @buy_window = Window_ShopBuy_Va.new($game_variables[172][@shop_now])  
   @buy_window.active = false  
   @buy_window.visible = false  
   @buy_window.help_window = @help_window  
   # 生成卖出窗口  
   @sell_window = Window_ShopSell.new  
   @sell_window.active = false  
   @sell_window.visible = false  
   @sell_window.help_window = @help_window  
   # 生成数量输入窗口  
   @number_window = Window_ShopNumber.new  
   @number_window.active = false  
   @number_window.visible = false  
   # 生成状态窗口  
   @status_window = Window_EquipHelp.new  #Window_ShopStatus.new  
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
     # 如果画面切换的话就中断循环  
     if $scene != self  
       break  
     end  
   end  
   # 准备过渡  
   Graphics.freeze  
   # 释放窗口  
   @help_window.dispose  
   @command_window.dispose  
   @gold_window.dispose  
   @dummy_window.dispose  
   @buy_window.dispose  
   @sell_window.dispose  
   @number_window.dispose  
   @status_window.dispose  
 end  
 #--------------------------------------------------------------------------  
 # ● 刷新画面  
 #--------------------------------------------------------------------------  
 def update  
   # 刷新窗口  
   @help_window.update  
   @command_window.update  
   @gold_window.update  
   @dummy_window.update  
   @buy_window.update  
   @sell_window.update  
   @number_window.update  
   @status_window.update  
   # 指令窗口激活的情况下: 调用 update_command  
   if @command_window.active  
     update_command  
     return  
   end  
   # 购买窗口激活的情况下: 调用 update_buy  
   if @buy_window.active  
     update_buy  
     return  
   end  
   # 卖出窗口激活的情况下: 调用 update_sell  
   if @sell_window.active  
     update_sell  
     return  
   end  
   # 个数输入窗口激活的情况下: 调用 update_number  
   if @number_window.active  
     update_number  
     return  
   end  
 end  
 #--------------------------------------------------------------------------  
 # ● 刷新画面 (指令窗口激活的情况下)  
 #--------------------------------------------------------------------------  
 def update_command  
   # 按下 B 键的情况下  
   if Input.trigger?(Input::B)  
     # 演奏取消 SE  
     $game_system.se_play($data_system.cancel_se)  
     # 切换到地图画面  
     $scene = Scene_Map.new  
     return  
   end  
   # 按下 C 键的情况下  
   if Input.trigger?(Input::C)  
     @save_index2=nil
     # 命令窗口光标位置分支  
     case @command_window.index  
     when 0  # 购买  
       # 演奏确定 SE  
       $game_system.se_play($data_system.decision_se)  
       # 窗口状态转向购买模式  
       @command_window.active = false  
       @dummy_window.visible = false  
       @buy_window.active = true  
       @buy_window.visible = true  
       @buy_window.refresh  
       #@status_window.visible = true  
     when 1  # 卖出  
       # 演奏确定 SE  
       $game_system.se_play($data_system.decision_se)  
       # 窗口状态转向卖出模式  
       @command_window.active = false  
       @dummy_window.visible = false  
       @sell_window.active = true  
       @sell_window.visible = true  
       @sell_window.refresh  
     when 2  # 取消  
       # 演奏确定 SE  
       $game_system.se_play($data_system.decision_se)  
       # 切换到地图画面  
       $scene = Scene_Map.new  
     end  
     return  
   end  
 end  
 #--------------------------------------------------------------------------  
 # ● 刷新画面 (购买窗口激活的情况下)  
 #--------------------------------------------------------------------------  
 def update_buy  
   # 设置状态窗口的物品  
   # 按下 B 键的情况下  
   if Input.trigger?(Input::B)  
     # 演奏取消 SE  
     $game_system.se_play($data_system.cancel_se)  
     # 窗口状态转向初期模式  
     @command_window.active = true  
     @dummy_window.visible = true  
     @buy_window.active = false  
     @buy_window.visible = false  
     @status_window.set_text("")
     # 删除帮助文本  
     @help_window.set_text("")  
     return  
   end  
   # 按下 C 键的情况下  
   if Input.trigger?(Input::C)  
     # 获取物品  
     @item = @buy_window.item  
     # 物品无效的情况下、或者价格在所持金以上的情况下  
     if @item == nil or @item.price > $game_party.gold  
       # 演奏冻结 SE  
       $game_system.se_play($data_system.buzzer_se)  
       return  
     end  
     # 获取物品所持数  
     case @item  
     when RPG::Item  
       number = $game_party.item_number(@item.id)  
     when RPG::Weapon  
       number = $game_party.weapon_number(@item.id)  
     when RPG::Armor  
       number = $game_party.armor_number(@item.id)  
     end  
     # 如果已经拥有了 99 个情况下  
     if number == 99  
       # 演奏冻结 SE  
       $game_system.se_play($data_system.buzzer_se)  
       return  
     end  
     # 演奏确定 SE  
     $game_system.se_play($data_system.decision_se)  
     # 计算可以最多购买的数量  
     max = @item.price == 0 ? 99 : $game_party.gold / @item.price  
     max = [[max, 99 - number].min,@buy_window.item_number].min  
     # 窗口状态转向数值输入模式  
     @buy_window.active = false  
     @buy_window.visible = false  
     @number_window.set(@item, max, @item.price)  
     @number_window.active = true  
     @number_window.visible = true  
   end  
   if @save_index2!=@buy_window.index
     @save_index2=@buy_window.index 
     if (@buy_window.item).is_a?(RPG::Weapon)
       @status_window.set_text(@buy_window.item   == nil ? "" : @buy_window.item.id)
     else
       @status_window.set_text("")
     end
   end
 end  
 #--------------------------------------------------------------------------  
 # ● 画面更新 (卖出窗口激活的情况下)  
 #--------------------------------------------------------------------------  
 def update_sell  
    # 按下 B 键的情况下  
   if Input.trigger?(Input::B)  
     # 演奏取消 SE  
     $game_system.se_play($data_system.cancel_se)  
     # 窗口状态转向初期模式  
     @command_window.active = true  
     @dummy_window.visible = true  
     @sell_window.active = false  
     @sell_window.visible = false  
     @status_window.set_text("")
     # 删除帮助文本  
     @help_window.set_text("")  
     return  
   end  
   # 按下 C 键的情况下  
   if Input.trigger?(Input::C)  
     # 获取物品  
     @item = @sell_window.item  
     # 物品无效的情况下、或者价格为 0 (不能卖出) 的情况下  
     if @item == nil or @item.price == 0  
       # 演奏冻结 SE  
       $game_system.se_play($data_system.buzzer_se)  
       return  
     end  
     # 演奏确定 SE  
     $game_system.se_play($data_system.decision_se)  
     # 获取物品的所持数  
     case @item  
     when RPG::Item  
       number = $game_party.item_number(@item.id)  
     when RPG::Weapon  
       number = $game_party.weapon_number(@item.id)  
     when RPG::Armor  
       number = $game_party.armor_number(@item.id)  
     end  
     # 最大卖出个数 = 物品的所持数  
     max = number  
     case @item  
     when RPG::Weapon
       max-=1 if $game_variables[181][@item.id]!=nil && $game_variables[181][@item.id]>0 && @item.id !=52
     end
     # 窗口状态转向个数输入模式  
     @sell_window.active = false  
     @sell_window.visible = false  
     value=@item.price / 2
       case @item  
       when RPG::Weapon
         if @item.id==52 #点金
           value*=2
         end
       end
     @number_window.set(@item, max,value)  
     @number_window.active = true  
     @number_window.visible = true  
   end  
   if @save_index2!=@sell_window.index
     @save_index2=@sell_window.index 
     if (@sell_window.item).is_a?(RPG::Weapon)
       @status_window.set_text(@sell_window.item   == nil ? "" : @sell_window.item.id)
     else
       @status_window.set_text("")
     end
   end
 end  
 #--------------------------------------------------------------------------  
 # ● 刷新画面 (个数输入窗口激活的情况下)  
 #--------------------------------------------------------------------------  
 def update_number  
   # 按下 B 键的情况下  
   if Input.trigger?(Input::B)  
     # 演奏取消 SE  
     $game_system.se_play($data_system.cancel_se)  
     # 设置个数输入窗口为不活动·非可视状态  
     @number_window.active = false  
     @number_window.visible = false  
     # 命令窗口光标位置分支  
     case @command_window.index  
     when 0  # 购买  
       # 窗口状态转向购买模式  
       @buy_window.active = true  
       @buy_window.visible = true  
     when 1  # 卖出  
       # 窗口状态转向卖出模式  
       @sell_window.active = true  
       @sell_window.visible = true  
       @save_index2=-1
     end  
     return  
   end  
   # 按下 C 键的情况下  
   if Input.trigger?(Input::C)  
     # 演奏商店 SE  
     $game_system.se_play($data_system.shop_se)  
     # 设置个数输入窗口为不活动·非可视状态  
     @number_window.active = false  
     @number_window.visible = false  
     # 命令窗口光标位置分支  
     case @command_window.index  
     when 0  # 购买  
       # 购买处理  
       temp = 0  
       $game_party.lose_gold(@number_window.number * @item.price)  
       case @item  
       when RPG::Item  
         $game_party.gain_item(@item.id, @number_window.number)  
       when RPG::Weapon  
         $game_party.gain_weapon(@item.id, @number_window.number)  
         temp = 1  
       when RPG::Armor  
         $game_party.gain_armor(@item.id, @number_window.number)  
         temp = 2  
       end  
       goods_del(temp,@item.id,@number_window.number)  
       # 刷新各窗口  
       @buy_window = Window_ShopBuy_Va.new($game_variables[172][@shop_now]) 
       @buy_window.help_window = @help_window 
       @gold_window.refresh  
       @buy_window.refresh  
       if (@buy_window.item).is_a?(RPG::Weapon)
         @status_window.set_text(@buy_window.item   == nil ? "" : @buy_window.item.id)
       else
         @status_window.set_text("")
       end
       # 窗口状态转向购买模式  
       @buy_window.active = true  
       @buy_window.visible = true  
     when 1  # 卖出  
       # 卖出处理  
       case @item  
       when RPG::Weapon
         if @item.id==52 #点金
           $game_party.gain_gold(@number_window.number * (@item.price / 2)) 
         end
       end
       $game_party.gain_gold(@number_window.number * (@item.price / 2))  
       temp = 0  
       case @item  
       when RPG::Item  
         $game_party.lose_item(@item.id, @number_window.number)  
       when RPG::Weapon  
         $game_party.lose_weapon(@item.id, @number_window.number)  
       #  $game_variables[181][@item.id]=0 if $game_variables[181][@item.id]!=nil && $game_variables[181][@item.id]>0
         temp = 1  
       when RPG::Armor  
         $game_party.lose_armor(@item.id, @number_window.number)  
         temp = 2  
       end  
       # 刷新各窗口  
       goods_del(temp,@item.id,-@number_window.number)  
       @buy_window = Window_ShopBuy_Va.new($game_variables[172][@shop_now])  
       @buy_window.active = false  
       @buy_window.visible = false  
       @buy_window.help_window = @help_window  
       @gold_window.refresh  
       @sell_window.refresh  
       if (@sell_window.item).is_a?(RPG::Weapon)
         @status_window.set_text(@sell_window.item   == nil ? "" : @sell_window.item.id)
       else
         @status_window.set_text("")
       end
       # 窗口状态转向卖出模式  
       @sell_window.active = true  
       @sell_window.visible = true 
       @save_index2=-1
     end  
     return  
   end  
 end  
 # 删除可出售商品内容  
 def goods_del(kind,id,delnumber)  
   dl = delnumber  
   for dt in $game_variables[172][@shop_now]  
     if (dt[0]==kind) and (dt[1]==id)  
       dt[2] -= dl  
       dt[2] = [dt[2],99].min  
       if dt[2] == 0  
         $game_variables[172][@shop_now].delete(dt)  
       end  
       return  
     end  
   end  
   $game_variables[172][@shop_now].push([kind,id,-delnumber])  
 end  
end 
#============================================================================== 
# ■ Window_ShopBuy_Va  
#------------------------------------------------------------------------------  
# 　商店画面、浏览显示可以购买的商品的窗口。  
#============================================================================== 
class Window_ShopBuy_Va < Window_Selectable  
 attr_accessor :shop_goods  
 #--------------------------------------------------------------------------  
 # ● 初始化对像  
 #     shop_goods : 商品  
 #--------------------------------------------------------------------------  
 def initialize(shop_goods)  
   super(0, 128, 576, 352)  
   @shop_goods = shop_goods  
   @spr=Sprite.new
    @spr.x=self.x
    @spr.y=self.y
    @spr.bitmap=Bitmap.new(self.width*2,self.height*2)
    @spr.z=100
    @spr.zoom_x=0.5
    @spr.zoom_y=0.5
    refresh
    self.index = 0
  end
  def dispose
    super
    @spr.bitmap.dispose
    @spr.dispose
  end
  def visible=(i)
    super
    @spr.visible=i
  end
 #--------------------------------------------------------------------------  
 # ● 获取物品  
 #--------------------------------------------------------------------------  
 def item  
   return @data[self.index]  
 end  
 #--------------------------------------------------------------------------  
 # ● 获取物品  
 #--------------------------------------------------------------------------  
 def item_number  
   return @data_number[self.index]  
 end  
 def update
   super
   refresh_icon
 end
 def refresh_icon
    if @save_top !=self.top_row
      @save_top=self.top_row
      @spr.bitmap.clear
      a=@save_top
      for i in a...[@item_max,a+10].min
        item = @data[i]
        x = 4  
        y = (i-a) * 32  
        bitmap = RPG::Cache.icon(item.icon_name)
        opacity = self.contents.font.color == normal_color ? 255 : 128  
        if bitmap.width>40
          @spr.bitmap.blt(x*2+24,y*2+32, bitmap, Rect.new(0, 0, 86, 64), opacity)
        end
      end
    end
  end
 #--------------------------------------------------------------------------  
 # ● 刷新  
 #--------------------------------------------------------------------------  
 def refresh  
   if self.contents != nil  
     self.contents.dispose  
     self.contents = nil  
   end  
   @data = []  
   @data_number = []  
   for goods_item in @shop_goods  
     case goods_item[0]  
     when 0  
       item = $data_items[goods_item[1]]  
     when 1  
       item = $data_weapons[goods_item[1]]  
     when 2  
       item = $data_armors[goods_item[1]]  
     end  
     if (item != nil) and (goods_item[2] != 0)  
       @data.push(item)  
       @data_number.push(goods_item[2])  
     else  
       @data.delete(item)  
     end  
   end  
   # 如果项目数不是 0 就生成位图、描绘全部项目  
   @item_max = @data.size  
   if @item_max > 0  
     self.contents = Bitmap.new(width - 32, row_max * 32)  
     for i in 0...@item_max  
       draw_item(i)  
     end  
   end  
   refresh_icon
 end  
 #--------------------------------------------------------------------------  
 # ● 描绘羡慕  
 #     index : 项目编号  
 #--------------------------------------------------------------------------  
 def draw_item(index)  
   item = @data[index]  
   # 获取物品所持数  
   case item  
   when RPG::Item  
     number = $game_party.item_number(item.id)  
   when RPG::Weapon  
     number = $game_party.weapon_number(item.id)  
   when RPG::Armor  
     number = $game_party.armor_number(item.id)  
   end  
   # 价格在所持金以下、并且所持数不是 99 的情况下为普通文字颜色  
   # 除此之外的情况设置为无效文字色  
   if item.price <= $game_party.gold and number < 99  
     self.contents.font.color = normal_color  
   else  
     self.contents.font.color = disabled_color  
   end  
   x = 4  
   y = index * 32  
   rect = Rect.new(x, y, self.width - 32, 32)  
   self.contents.fill_rect(rect, Color.new(0, 0, 0, 0))  
   bitmap = RPG::Cache.icon(item.icon_name)  
   opacity = self.contents.font.color == normal_color ? 255 : 128  
   if bitmap.width<40
     self.contents.blt(x, y , bitmap, Rect.new(0, 0, 32, 32), opacity)#物品图标用32*32
   end
   str=item.name.split(":")[0]
   if item.is_a?(RPG::Weapon) && self.contents.font.color !=disabled_color  
     text=TextStream.new
     text.open("Info/Equip/"+str)
     color=text.get_text(1)
     color.sub!(/\[([0-9]+)\]/, "")
     text.close
     self.contents.font.color=text_color($1.to_i)
   end
   self.contents.draw_text(x + 42, y, 212, 32, item.name.split(":")[0], 0)  
   self.contents.font.color=normal_color
   self.contents.draw_text(x + 320, y, 88, 32, "存货  ", 2)  
   self.contents.draw_text(x + 320, y, 88, 32, @data_number[index].to_s, 2)  
   self.contents.draw_text(x + 200, y, 88, 32, item.price.to_s, 2)  
    case item
    when RPG::Item
      number = $game_party.item_number(item.id)
    when RPG::Weapon
      number = $game_party.weapon_number(item.id)
    when RPG::Armor
      number = $game_party.armor_number(item.id)
    end
    self.contents.font.size=22
  #  self.contents.font.color = system_color
    self.contents.draw_text(x + 450, y, 88, 32, "所持数")
   # self.contents.font.color = normal_color
    self.contents.draw_text(x + 450, y, 88, 32, number.to_s, 2)
 end  
 #--------------------------------------------------------------------------  
 # ● 刷新帮助文本  
 #--------------------------------------------------------------------------  
 def update_help  
   case item  
   when RPG::Item  
     @help_window.set_text(item == nil ? "" : item.description)
   when RPG::Weapon
     @help_window.set_text("")
   end
 end  
end 
#============================================================================== 
# 本脚本来自www.66RPG.com，使用和转载请保留此信息 
#==============================================================================