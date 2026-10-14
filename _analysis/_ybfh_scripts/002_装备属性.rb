module Monster
  
 module_function
  #载入大属性装备
  def equipLoad
    eset(51,1250,0,0,0,0) #水晶剑二阶
    eset(63,1350,0,0,0,0) #水晶剑（寒冰）
    eset(72,1800,0,75,0,50) #回音战刃
    eset(76,2700,0,0,0,80) #红杖2级
    eset(79,6000,0,120,90,120) #飓风长戟
    eset(83,3600,0,0,0,0) #秘银锤
    eset(85,7200,0,0,0,0) #漩涡
    eset(86,4000,0,0,0,0) #炎阳纹章
    eset(106,1230,0,0,0,0) #
    eset(107,0,1230,0,0,0) #
    eset(108,2230,0,0,0,0) #
    eset(109,0,2230,0,0,0) #
    eset(113,6000,0,160,0,0) #散华
    eset(114,6000,0,0,160,0) #夜叉
    eset(115,30000,0,200,200,0) #散夜对剑
    eset(116,15000,0,0,0,150) #红杖3级
    eset(117,40000,0,0,0,0) #虚灵3级
    eset(123,0,0,0,0,240) #紫怨
    eset(124,12000,0,0,0,60) #刃甲
    eset(125,30000,0,200,0,0) #天堂之戟
    eset(128,80000,0,0,0,0) #影刃
    eset(129,8800,0,0,0,0) #大剑
    eset(131,0,0,0,0,360) #血棘
    eset(133,0,0,200,100,0) #魂之灵瓮
    eset(134,0,0,120,120,120) #永恒之盘
    eset(136,150000,0,0,200,0) #白银之锋
    $data_weapons[126].name="传奇夜魔祭品:D10:A2000:SR0.5:MP1000:BL0.2"
    $data_weapons[89].name="洞察烟斗:MD1500:MD%30:SD15:SM25:MS300:A300"
    $data_weapons[122].name="血精石:MH25000000:MS1500:A8000:SR0.5:MP3000"
    $data_weapons[133].name="魂之灵瓮:D15:A3000:MH15000000:SK180:GD5000"
    $data_weapons[134].name="永恒之盘:D18:MS600:MH12000000"
    $data_weapons[131].name="血棘:C750:MD%30:SD50:SK170"
  end
  def eset(id,atk,pdef,str,dex,int,name=nil)
    if id>=1
      if name !=nil
        $data_weapons[id].name=name
      end
      $data_weapons[id].str_plus=atk
      $data_weapons[id].dex_plus=pdef
      $data_weapons[id].atk=str
      $data_weapons[id].pdef=dex
      $data_weapons[id].mdef=int
    end
  end
end