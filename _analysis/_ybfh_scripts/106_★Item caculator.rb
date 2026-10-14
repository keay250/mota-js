#==============================================================================
# ■ Item_calc
#------------------------------------------------------------------------------
# 　计算求得物品对应的事件。
#==============================================================================
class Item_calc
  attr_reader:name   #事件名
  attr_reader:chname #行走图
  attr_reader:direct #方向
  attr_reader:patt   #模式
  #--------------------------------------------------------------------------
  # ● 初始化状态
  #--------------------------------------------------------------------------
  def initialize(item_cat, item_num)
    @item_cat=item_cat
    @item_num=item_num
    cal_item
  end
  #--------------------------------------------------------------------------
  # ● 执行计算
  #--------------------------------------------------------------------------
  def cal_item
    @name="I:"+@item_cat.to_s+":"+@item_num.to_s
    
    if @item_cat==1
      n=$data_items[@item_num].icon_name
    end
    if @item_cat==2
      n=$data_weapons[@item_num].icon_name
    end
    if @item_cat==3
      n=$data_armors[@item_num].icon_name
    end
    p1=n[0,3]
    p2=p1[1,2]
    @chname=p1+"-item"+p2
    
    p3=n[4,2].to_i
    p4=p3/4
    p5=p3%4
    if p5==0
      p5=4
      p4-=1
    end
    
    @direct=2*(p4+1)
    @patt=p5-1
  end
end