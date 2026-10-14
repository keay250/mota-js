=begin
 --------------------------------------------------------------------------
 详尽任务显示界面 v2.1
 --------------------------------------------------------------------------
 By 叶子
 
 日期与更新 
 3-29-2006 －v1.0
 4-3-2006  －v2.0
 －可以改变文字颜色，显示变量，显示图标，显示图片
 －大幅简化了编写任务内容的过程，加入自动换行功能
 －精简了窗口，使其还可以用作图鉴系统、日记系统等等
 4-6-2006  －v2.1
 －增加了获得全部任务与删除全部任务命令
 －改正通假字，修改了示例任务3
 --------------------------------------------------------------------------
 顾名思义，就是显示任务资料的界面
 任务资料要预先在这里设定好
 下载范例工程，能帮助你更快更好地掌握使用方法
 --------------------------------------------------------------------------
 使用方法：
 
 1、召唤任务显示界面：$scene = Scene_Task.new
 
 可以在事件中的“脚本”指令加入这段东西，又或者修改 Scene_Menu 来增加一个显示
 任务的选项。如果是修改 Scene_Menu 增加选项的话，在脚本倒数第30行左右，
 把 $scene = Scene_Map.new 修改成 $scene = Scene_Menu.new(任务界面index)
 
 2、设置任务资料
 
  2.1、相关内容解析
  
  所有内容文字必须用双引号括住
  
  名称：任务的名字（显示在左边窗口中），大小为208×32，如果全部为文字的话，
        够放九个全角字符
        
  简介：任务的介绍（显示在右边窗口中），宽368，高不限
  
        文字可以自动换行
  
   2.1.1、控制码解析
   
   名称和内容均可用控制码，注意两条反斜线都要打！
   
   \\v[n] 显示n号变量
   \\c[n] 改变字体颜色。
          n=1～7 时同“显示文章”的\c[n]，n=8 时为半透明色，n=9 时为系统色（青色）
   \\n[i] 显示i号角色名字
   \\i[文件名] 显示图标
   \\p[文件名] 显示图片
   
   2.1.2、高级：内嵌表达式
        
   请参考帮助－脚本入门－字符串－内嵌表达式相关内容。
   它可以用来在任务的名称和简介那里显示变量。
   常用的表达式（注意不要漏了井号和大括号）：
   #{$game_variables[n]}       ——插入n号变量的值
   #{$game_party.item_number(n)}  ——插入持有n号物品数量
                                      同理还有weapon_number，armor_number
   还可以预先定义一个变量，再插入（例子见示例任务3－灵魂线）
   
  2.2、注意事项
  
   2.2.1、括号、逗号和双引号 [ ] , " 必须使用半角符号（英文输入），
          引号内的内容则没有关系
          
   2.2.2、单引号 ' 和双引号 " 的区别：
          为了不出错误，全部用双引号吧！当然如果你对Ruby很熟悉，那就没所谓了
  
  2.3、开始设置吧！
  从107行开始设置任务资料，可以参考示例任务来设置，请仔细阅读附加讲解
  
 3、接受任务
 
 事件里的“脚本”指令输入：get_task(任务ID)
 例如 get_task(1) 就是接受1号任务
 
  3.1、获得全部任务
  
  事件里的“脚本”指令输入：get_all_task
  这个功能基本上是用来在编写好所有任务资料后测试排版的
  
 
 4、完成/删除任务
 
 事件里的“脚本”指令输入：finish_task(任务ID)
 例如 finish_task(1) 就是完成1号任务
 
 注意：本脚本不负责完成任务后的奖励之类的东西，请自行在事件中判断，
       这里的完成任务指的是从任务列表中删去此任务
 
  4.1、删除全部任务
  
  事件里的“脚本”指令输入：finish_all_task
  作为获得全部任务的对应功能存在，似乎不会怎么用到
=end

class Scene_Task
  # 这里设置任务内容翻页音效
  CHANGE_PAGE_SE = "Audio/SE/046-Book01"
end

class Game_Party
  #--------------------------------------------------------------------------
  # ● 设置任务资料
  #--------------------------------------------------------------------------
  def get_tasks_info
    if @tasks_info==nil
      @tasks_info = []
    end
    #-----------------------------
    # 战场阶层划分
    #-----------------------------
    名称 = "\\c[6]战场阶层划分"
    简介 = "\\c[0]  位面战场，强者如林，不管是兵卒还是狩士，进入位面战场的资格都至少是英雄境界，而在这汇聚了诸天万界无数位面英雄的战场中，下位英雄通常是最为普通的兵卒，也是最没有价值的炮灰。
  而到了上位英雄境界，便有资格在兵卒中获得一定的领导者地位，其中六阶可任小队队长，八阶可任大队队长，而唯有拥有至少九阶实力，才能成为一整支战团的督军。
  至于狩士，英雄八阶与九阶实力的较为常见，八阶之下极少，而不管是九阶狩士还是战团督军，都并非是位面战场的统治者。传奇生命高高在上，通常不会在第十七战场这等规模级别的战场中出手，但并不代表九阶便是传奇之下的最强者。
  英雄九阶按照战力阶位可划分为普通、喽啰、精英、领主四大阶位，在其之上还存在着名为半步传奇的战力境界，这一境界指的是掌握了自身奥义雏形的九阶巅峰强者，当然也有些仍处于单纯九阶范畴，战力却超越领主的妖孽存在，因这类人数量极少，又普遍较为年轻，因此其阶位又被称之为未来史诗。
  与之前境界一样，半步传奇同样可划分为普通、喽啰、精英、领主，其中普通阶位的半步传奇在实力上略强于九阶领主一点，而领主阶位的半步传奇更是极其恐怖，但由于英雄与传奇境界之间差距极大，因此即便是这等强者，也只能勉强抗衡最弱的传奇生命，或者说的难听一点，仅仅是有能力在其手中保住性命。
  最后说到传奇生命，自然是第十七战场中的至高存在，若不幸遭遇这等强敌，只能说算你倒霉。
"
    i=12
    if @tasks_info[i]==nil
      @tasks_info[i] = Game_Task.new(名称, 简介)
    else
      if !@tasks_info[i].name.include?("完成")
        @tasks_info[i] = Game_Task.new(名称, 简介)
      end
    end
    #-----------------------------
    # 战场地图介绍
    #-----------------------------
    名称 = "\\c[6]战场地图介绍"
    简介 = "\\c[0]  第十七战场天辉与夜魇双方共分出三路战线，分别是上路战场、中路战场、下路战场，除了这三路战场外还有一些该位面中对于狩士较为重要的地点，将在此一一介绍。
  \\c[4]上路战场\\c[0]  上路战场天辉一方处于优势，地形也多为适合天辉生命生存的平原、山林，由于天辉对此地掌控的力量较为强大，天辉中一些势力的天骄子弟往往也会选择在上路战场进行历练，外围较为安全，狩士可进入其中，但不推荐任何半步传奇之下战力的狩士孤身深入上路。
  \\c[4]下路战场\\c[0]  下路战场目前主要被把持在我方夜魇手中，但由于夜魇生命的普遍习性，下路战场中自然也充斥着弱肉强食的争斗，一些狩士中的强者则是选择在下路占据地盘，组建或是吞并其他小势力，亦或是进入天辉地界中进行劫掠、捞取军功。
  \\c[4]中路战场\\c[0]  \\c[2]极度危险\\c[0]
  中路战场是双方交战的主战场，时有大大小小的战斗爆发，那是兵卒之间主力的对决厮杀，狩士的个体力量在这战争洪流中显得十分微不足道，即便是半步传奇也难以自保，因此建议每一位狩士远离中路战场。
  \\c[4]妖精之泉\\c[0]  妖精之泉位于天辉控制区，但实际上天辉对此并无掌控权，此地是第十七位面战场中唯一一处得到天辉夜魇双方承认的土著疆域，由该位面中的最强原住民种族妖精掌管。妖精一族掌握着战场稀缺资源[魔瓶]的制造方法，因此许多狩士势力会以武力抢夺或是完成委托的方式来此地获取魔瓶。
  \\c[4]神符海峡\\c[0]  神符海峡是位于下路战场与中路战场之间的一片特殊区域，这里汇聚了许多神符，在此地，实力才是决定能否夺得神符的关键。
  \\c[4]绝望之塔\\c[0]  绝望之塔处于夜魇控制区，但同样是中立地带，此地有一座上古时期遗留下来的高塔遗迹，传闻此遗迹中蕴藏着某一位伟大存在的传承，凡是处于英雄境界的任何智慧生灵都能进入其中进行试炼。绝望之塔本身是极其危险，塔中试炼守护者一层比一层强大，而每通过一层便能获得来自遗迹的奖励，然而至今为止绝望之塔通关者有之，却从未有人获得过那传说中的传承。
  \\c[4]不朽山谷\\c[0]  每一处排名在前二十的位面战场中都存在着一座不朽山谷，此山谷来源据说与天辉夜魇两方的最高层有关。山谷中居住着一头极其可怕的传奇生命，若有人能够将其击杀，便能获得其身上的不朽之力，在不朽之力的影响下获得者在不朽山谷所在的位面战场中拥有一次死而复生的机会，不过遗憾的是，这股不朽之力仅对史诗之下的境界有效，并且数十年后不朽之力将会返回到不朽山谷中重新形成那头传奇生命。
"
    i=13
    if @tasks_info[i]==nil
      @tasks_info[i] = Game_Task.new(名称, 简介)
    else
      if !@tasks_info[i].name.include?("完成")
        @tasks_info[i] = Game_Task.new(名称, 简介)
      end
    end
    #-----------------------------
    # 战场天骄介绍
    #-----------------------------
    名称 = "\\c[6]战场天骄介绍"
    简介 = "\\c[0]  位面战场对于弱小的兵卒来说是残酷的炼狱，对于赌上性命的狩士来说危险的试炼，而对于那些天之骄子来说则不过是一场游戏。当今位面战场中正是存在着这样一些天骄，他们个个实力高绝，同时在他们身上也意味着惊人的财富以及军功。
\\c[4]天辉主要天骄\\c[0]
  \\c[5]训仙宇\\c[0] 英雄九阶-未来史诗，推测其战力可能已经达到半步传奇精英阶位，出身天辉超凡世家训氏家族的天骄，性格沉稳冷静，已经可以确认其身上拥有一件传奇装备，据推测极有可能为“影刃”。
  夜魇悬赏此人:#{$data_enemies[387].maxsp}军功。
  \\c[5]梦多古\\c[0] 半步传奇-喽啰，天辉顶级势力全能教团的圣女候补，被任命坐镇全能神教在该处位面战场的据点，信仰坚定，掌握有神圣劝化的能力，手下掌管有一个圣堂骑士小队。
  夜魇悬赏此人:#{$data_enemies[388].maxsp}军功。
  \\c[5]西诺比\\c[0] 半步传奇-喽啰，天辉超凡势力星隐寺忍僧一脉的杰出天才之一，但其性格猥琐，行为下作，被星隐寺高层所不喜，甚至断了其修炼资源，据说是为了获取修炼资源而选择来到位面战场。
  夜魇悬赏此人:#{$data_enemies[389].maxsp}军功。
  \\c[4]夜魇主要天骄\\c[0]
  \\c[5]风凌影\\c[0] 英雄九阶-未来史诗，推测其战力可能已经达到半步传奇精英阶位，隶属于夜魇超凡世家风氏家族，颇为神秘，有关于他的情报不多，目前是下路战场第一大狩士势力影刃帮的首领，拥有一件传奇装备。
  \\c[5]卡罗尔\\c[0] 半步传奇-喽啰，年龄相较其他天骄要大上不少，独来独往的狩士，但有许多传言说他听从夜魇狩士势力万会盟的指令，由于见过此人的大多都死了，因此再无更多相关情报，但可以确定他在近十年前便通过了绝望之塔第五层。
  \\c[5]阿克苏\\c[0] 半步传奇-喽啰，红雾军团首领斧王的后裔，但并非嫡系，目前在下路战场掌控狩士势力红雾营，热衷于战斗。
"
    i=14
    if @tasks_info[i]==nil
      @tasks_info[i] = Game_Task.new(名称, 简介)
    else
      if !@tasks_info[i].name.include?("完成")
        @tasks_info[i] = Game_Task.new(名称, 简介)
      end
    end
    #－讲解－
    # 三个示例任务由浅入深，其实只要看懂第一个就可以使用了。
    # 任务的写法多种多样，不限于这三个任务的方法
    #－－－－
    #-----------------------------
    # 任务1
    #-----------------------------
    名称 = "\\c[6]赏金—魉拙计"
    #－讲解－
    # 注意！脚本编辑器的变色功能并不是非常完善，所以换行后字变黑了，但仍然是字符
    # 串的一部分，所以不要忘记在内容最后打一个双引号
    # 按回车是强制换行
    #－－－－
    简介 = "\\c[6]目标是时常出没于大草原西北部的兽人魉拙计，拥有十分恐怖的速度以及闪避率、暴击率。
顺带一提除食物外他最喜欢掠夺的东西是女式内衣。
\\e[72]

\\c[9]任务目标：
击杀魉拙计
赏金：
500金币
"
    #－讲解－
    # 每个任务最后一定要加上：
    # @tasks_info[任务ID] = Game_Task.new(名称, 简介)
    # 接受任务和完成任务都是用这个任务ID来索引
    #－－－－
    i=0
    if @tasks_info[i]==nil
      @tasks_info[i] = Game_Task.new(名称, 简介)
    else
      if !@tasks_info[i].name.include?("完成")
        @tasks_info[i] = Game_Task.new(名称, 简介)
      end
    end
   
    #-----------------------------
    # 任务2
    #-----------------------------
    名称 = "\\c[6]赏金—流动巨大果冻"
    简介 = "\\c[6]目标是长期在大草原西南部游荡的巨型凝胶怪，此赏金首极度危险，曾经有一支全部由职业者组成的精英小队前去讨伐，苦战数日被困，只有队长一人逃回，据他回忆，是草莓味的。
\\e[75]
\\c[9]任务目标：
消灭流动巨大果冻
赏金：
800金币

"
    i=1
    if @tasks_info[i]==nil
      @tasks_info[i] = Game_Task.new(名称, 简介)
    else
      if !@tasks_info[i].name.include?("完成")
        @tasks_info[i] = Game_Task.new(名称, 简介)
      end
    end
    #-----------------------------
    # 任务3
    #-----------------------------
    名称 = "\\c[6]赏金—封尘魔导师"
    简介 = "\\c[6]目标是盘踞在已经废弃的皇家陵园（往昔之园）中看起来有些疯癫的魔法师，其擅长土系魔法，且周边地形十分复杂。
\\e[95]

\\c[9]任务目标：
消灭封尘魔导师

赏金：
800金币
"
    i=2
    if @tasks_info[i]==nil
      @tasks_info[i] = Game_Task.new(名称, 简介)
    else
      if !@tasks_info[i].name.include?("完成")
        @tasks_info[i] = Game_Task.new(名称, 简介)
      end
    end
    #-----------------------------
    # 任务4
    #-----------------------------
    名称 = "\\c[6]赏金—沙土魔神像"
    简介 = "\\c[6]目标是姆伊森人秘密制造出的巨大战争兵器“沙土魔神像”，位于姆伊森的核心地带砂锁之地，此任务为潜入破坏任务，切勿打草惊蛇。
\\e[104]
\\c[9]任务目标：
破坏沙土魔神像所有部件，阻止其被拼装。
赏金：
1500金币
"
    i=3
    if @tasks_info[i]==nil
      @tasks_info[i] = Game_Task.new(名称, 简介)
    else
      if !@tasks_info[i].name.include?("完成")
        @tasks_info[i] = Game_Task.new(名称, 简介)
      end
    end
    #-----------------------------
    # 任务5
    #-----------------------------
    名称 = "\\c[6]赏金—叛逃者黑王"
    简介 = "\\c[6]目标是普利斯特佣兵公会分会史上最大叛逃者黑王，其目前势力扎根于杜鲁德草原东南部，环境恶劣且危机四伏的雷霆高原，只有将其击杀才能瓦解其手下的盗匪团伙。
\\e[105]
\\c[9]任务目标：
消灭叛逃者黑王。
赏金：
2000金币
"
    i=4
    if @tasks_info[i]==nil
      @tasks_info[i] = Game_Task.new(名称, 简介)
    else
      if !@tasks_info[i].name.include?("完成")
        @tasks_info[i] = Game_Task.new(名称, 简介)
      end
    end
    #-----------------------------
    # 任务6
    #-----------------------------
    名称 = "\\c[6]赏金—玛荷托拉族皇"
    简介 = "\\c[6]目标是玛荷托拉氏族的一位族皇，掌握族中大权的存在，其名为席塔，人称席塔族皇。
\\e[137]
\\c[9]任务目标：
消灭玛荷托拉族皇。
赏金：
3000金币
"
    i=5
    if @tasks_info[i]==nil
      @tasks_info[i] = Game_Task.new(名称, 简介)
    else
      if !@tasks_info[i].name.include?("完成")
        @tasks_info[i] = Game_Task.new(名称, 简介)
      end
    end
    #-----------------------------
    # 任务7
    #-----------------------------
    名称 = "\\c[6]赏金—超流动巨大果冻"
    简介 = "\\c[6]更大的果冻出现了！
    
\\e[85]

\\c[9]任务目标：
消灭超流动巨大果冻

赏金：
10000金币（别看了，实际上根本消灭不了，这任务就是闹着玩的）

"
    i=6
    if @tasks_info[i]==nil
      @tasks_info[i] = Game_Task.new(名称, 简介)
    else
      if !@tasks_info[i].name.include?("完成")
        @tasks_info[i] = Game_Task.new(名称, 简介)
      end
    end
    
    #-----------------------------
    # 任务7
    #-----------------------------
    名称 = "\\c[6]悬赏—乌诺巨人"
    简介 = "\\c[6]目标是一头叫乌诺的巨型食人魔，目前出没于郊外平原。
\\e[179]

\\c[9]任务目标：
消灭乌诺巨人

赏金：
5000金币

"
    i=7
    if @tasks_info[i]==nil
      @tasks_info[i] = Game_Task.new(名称, 简介)
    else
      if !@tasks_info[i].name.include?("完成")
        @tasks_info[i] = Game_Task.new(名称, 简介)
      end
    end
    #-----------------------------
    # 任务8
    #-----------------------------
    名称 = "\\c[6]悬赏—圣骑士梅罗"
    简介 = "\\c[6]目标是数百年前入侵寒夜位面的圣光部队的余孽，如今在位于火焰长河深处的暗影庇护所中占山为王。
\\e[212]

\\c[9]任务目标：
消灭圣骑士梅罗

赏金：
10000金币
"
    i=8
    if @tasks_info[i]==nil
      @tasks_info[i] = Game_Task.new(名称, 简介)
    else
      if !@tasks_info[i].name.include?("完成")
        @tasks_info[i] = Game_Task.new(名称, 简介)
      end
    end
    #-----------------------------
    # 任务9
    #-----------------------------
    名称 = "\\c[6]悬赏—特罗格玛"
    简介 = "\\c[6]目标是曾经名噪一时的炼金术师特罗格玛，有情报显示其曾经在东南方向的黑森林附近出没过。
    
\\c[9]任务目标：
寻找特罗格玛的踪迹并将其抓捕。

赏金：
15000金币
"
    i=9
    if @tasks_info[i]==nil
      @tasks_info[i] = Game_Task.new(名称, 简介)
    else
      if !@tasks_info[i].name.include?("完成")
        @tasks_info[i] = Game_Task.new(名称, 简介)
      end
    end
    #-----------------------------
    # 任务11
    #-----------------------------
    名称 = "\\c[6]拯救王国密探"
    简介 = "\\c[6]有一个自称是为普利斯特王国探听姆伊森人动向的密探需要人的救助，想办法从姆伊森人手中将他救出来吧。

\\c[9]任务目标：
从砂锁之地的姆伊森城镇里获取“沙岚秘匙”并将密探救出

报酬：
8000金币？

"
    i=11
    if @tasks_info[i]==nil
      @tasks_info[i] = Game_Task.new(名称, 简介)
    else
      if !@tasks_info[i].name.include?("完成")
        @tasks_info[i] = Game_Task.new(名称, 简介)
      end
    end
    
    
    
  end
end
    
#==============================================================================
# ■ Interpreter
#------------------------------------------------------------------------------
# 　执行事件命令的解释器。本类在 Game_System 类
# 与 Game_Event 类的内部使用。
#==============================================================================

class Interpreter
  #--------------------------------------------------------------------------
  # ● 接受任务
  #--------------------------------------------------------------------------
  def get_task(id)
    $game_party.get_tasks_info
    task = $game_party.tasks_info[id]
    return true if (task.nil? or $game_party.current_tasks.include?(task.id))
    $game_party.current_tasks.unshift(task.id)
    return true
  end
  def have_task?(id)
    task = $game_party.tasks_info[id]
    return false if task==nil
    return true if $game_party.current_tasks.include?(task.id)
    return false
  end
  #--------------------------------------------------------------------------
  # ● 获得全部任务
  #--------------------------------------------------------------------------
  def get_all_task
    # 清空当前任务
    $game_party.current_tasks.clear
    for task in $game_party.tasks_info
      next if task.nil?
      $game_party.current_tasks.unshift(task.id)
    end
    return true
  end
  #--------------------------------------------------------------------------
  # ● 完成/放弃任务
  #--------------------------------------------------------------------------
  def finish_task(id)
    $game_party.tasks_info[id].name+="(完成)"
    return true
    #task = $game_party.tasks_info[id]
    #return true if task.nil?
    #$game_party.current_tasks.delete(task.id)
    #return true
  end
  def finish_task?(id)
    return false if $game_party.tasks_info[id]==nil
    return true if $game_party.tasks_info[id]!=nil && $game_party.tasks_info[id].name.include?("完成")
    return false
  end
  #--------------------------------------------------------------------------
  # ● 删除全部任务
  #--------------------------------------------------------------------------
  def finish_all_task
    $game_party.current_tasks.clear
    return true
  end
end

#==============================================================================
# ■ Game_Party
#------------------------------------------------------------------------------
# 　处理同伴的类。包含金钱以及物品的信息。本类的实例
# 请参考 $game_party。
#==============================================================================

class Game_Party
  #--------------------------------------------------------------------------
  # ● 定义实例变量
  #--------------------------------------------------------------------------
  attr_writer     :latest_task                  # 上次查看的任务
  #--------------------------------------------------------------------------
  # ● 取得任务资料
  #--------------------------------------------------------------------------
  def tasks_info
    if @tasks_info.nil?
      get_tasks_info
    end
    return @tasks_info
  end
  #--------------------------------------------------------------------------
  # ● 取得当前任务
  #--------------------------------------------------------------------------
  def current_tasks
    if @current_tasks.nil?
      @current_tasks = []
    end
    return @current_tasks
  end
  #--------------------------------------------------------------------------
  # ● 上次查看的任务
  #--------------------------------------------------------------------------
  def latest_task
    if !current_tasks.include?(@latest_task)
      @latest_task = current_tasks[0]
    end
    return @latest_task
  end
end

#==============================================================================
# ■ Game_Task
#------------------------------------------------------------------------------
# 　处理任务的类。包含任务的信息。
#==============================================================================

class Game_Task
  attr_accessor   :name                   # 名称
  attr_accessor   :briefing               # 简介
  def initialize(name, briefing)
    @name = name
    @briefing = briefing
  end
  def height
    text = @briefing.clone
    x = 0
    y = -65
    min_y = 0
    # 限制文字处理
    begin
      last_text = text.clone
      text.gsub!(/\\[Vv]\[([0-9]+)\]/) { $game_variables[$1.to_i] }
    end until text == last_text
    text.gsub!(/\\[Nn]\[([0-9]+)\]/) do
      $game_actors[$1.to_i] != nil ? $game_actors[$1.to_i].name : ""
    end
    # 为了方便、将 "\\\\" 变换为 "\000" 
    text.gsub!(/\\\\/) { "\000" }
    # "\C" 变为 "\001" 
    text.gsub!(/\\[Cc]\[([0-9]+)\]/) { "\001[#{$1}]" }
    # "\I" 变为 "\002" 
    text.gsub!(/\\[Ii]/) { "\002" }
    # "\P" 变为 "\003" 
    text.gsub!(/\\[Pp]/) { "\003" }
    # c 获取 1 个字 (如果不能取得文字就循环)
    while ((c = text.slice!(/./m)) != nil)
      # \\ 的情况下
      if c == "\000"
        # 还原为本来的文字
        c = "\\"
      end
      # \C[n] 的情况下
      if c == "\001"
        # 更改文字色
        text.sub!(/\[([0-9]+)\]/, "")
        # 下面的文字
        next
      end
      # 图标的情况下
      if c == "\002"
        icon_name = ''
        while ((cha = text.slice!(/./m)) != ']')
          next if cha == '['
          icon_name += cha
        end
        icon = RPG::Cache.icon(icon_name)
        if x + icon.width > 368
          x = 0
          y += [32, min_y].max
          min_y = 0
        end
        x += 28
        next
      end
      # 图片的情况下
      if c == "\003"
        pic_name = ''
        while ((cha = text.slice!(/./m)) != ']')
          next if cha == '['
          pic_name += cha
        end
        pic = RPG::Cache.picture(pic_name)
        if x + pic.width > 368
          x = 0
          y += [32, min_y].max
          min_y = 0
        end
        x += pic.width
        min_y = [pic.height, 32].max
        next
      end
      # 另起一行文字的情况下
      if c == "\n"
        y += [32, min_y].max
        min_y = 0
        x = 0
        # 下面的文字
        next
      end
      # 自动换行处理
      if x + 22 > 368
        y += [32, min_y].max
        min_y = 0
        x = 0
      end
      # x 为要描绘文字的加法运算
      x += 22
    end
    return (y + [32, min_y].max)+32
  end
  def id
    return $game_party.tasks_info.index(self)
  end
end

#==============================================================================
# ■ Window_Task_Name
#------------------------------------------------------------------------------
# 　任务名称显示窗口。
#==============================================================================

class Window_Task_Name < Window_Selectable
  #--------------------------------------------------------------------------
  # ● 初始化对像
  #--------------------------------------------------------------------------
  def initialize(tasks)
    super(0, 0, 240, 480)
    @tasks = []
    for id in tasks
      @tasks.push($game_party.tasks_info[id])
    end
    @item_max = tasks.size
    self.contents = Bitmap.new(
    self.width - 32, @item_max == 0 ? 32 : @item_max * 32+32)
    refresh
    self.index = 0
  end
  #--------------------------------------------------------------------------
  # ● 刷新
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    if @tasks != []
      for task in @tasks
        draw_item(task)
      end
      self.contents.font.color = system_color
      self.contents.draw_text(4, @tasks.size*32, self.contents.width - 8, 32, '按确定键翻页')
    else
      draw_blank
    end
  end
  #--------------------------------------------------------------------------
  # ● 描绘项目
  #--------------------------------------------------------------------------
  def draw_item(task)
    text = task.name.clone
    x = 0
    y = @tasks.index(task) * 32
    # 限制文字处理
    begin
      last_text = text.clone
      text.gsub!(/\\[Vv]\[([0-9]+)\]/) { $game_variables[$1.to_i] }
    end until text == last_text
    text.gsub!(/\\[Nn]\[([0-9]+)\]/) do
      $game_actors[$1.to_i] != nil ? $game_actors[$1.to_i].name : ""
    end
    # 为了方便、将 "\\\\" 变换为 "\000" 
    text.gsub!(/\\\\/) { "\000" }
    # "\\C" 变为 "\001" 
    text.gsub!(/\\[Cc]\[([0-9]+)\]/) { "\001[#{$1}]" }
    # "\I" 变为 "\002" 
    text.gsub!(/\\[Ii]/) { "\002" }
    # "\P" 变为 "\003" 
    text.gsub!(/\\[Pp]/) { "\003" }
    # c 获取 1 个字 (如果不能取得文字就循环)
    while ((c = text.slice!(/./m)) != nil)
      # \\ 的情况下
      if c == "\000"
        # 还原为本来的文字
        c = "\\"
      end
      # \C[n] 的情况下
      if c == "\001"
        # 更改文字色
        text.sub!(/\[([0-9]+)\]/, "")
        if task.name.include?("完成")
          color=8
        else
        color = $1.to_i
        end
        if color >= 0 and color <= 7
          self.contents.font.color = text_color(color)
        elsif color == 8
          self.contents.font.color = disabled_color
        elsif color == 9
          self.contents.font.color = system_color
        end
        # 下面的文字
        next
      end
      # 图标的情况下
      if c == "\002"
        icon_name = ''
        while ((cha = text.slice!(/./m)) != ']')
          next if cha == '['
          icon_name += cha
        end
        icon = RPG::Cache.icon(icon_name)
        if x + icon.width > self.contents.width
          x = 0
          y += [32, min_y].max
          min_y = 0
        end
        self.contents.blt(x + 4, y + 4, icon, Rect.new(0, 0, 24, 24))
        x += 28
        next
      end
      # 图片的情况下
      if c == "\003"
        pic_name = ''
        while ((cha = text.slice!(/./m)) != ']')
          next if cha == '['
          pic_name += cha
        end
        pic = RPG::Cache.picture(pic_name)
        if x + pic.width > self.contents.width
          x = 0
          y += [32, min_y].max
          min_y = 0
        end
        self.contents.blt(x + 4, y, pic, Rect.new(0, 0, pic.width, pic.height))
        x += pic.width
        next
      end
      # 描绘文字
      self.contents.draw_text(4 + x, y, 40, 32, c)
      # x 为要描绘文字的加法运算
      x += self.contents.text_size(c).width
    end
  end
  #--------------------------------------------------------------------------
  # ● 描绘空行
  #--------------------------------------------------------------------------
  def draw_blank
    self.contents.font.color = disabled_color
    rect = Rect.new(4, 0, self.contents.width - 8, 32)
    self.contents.fill_rect(rect, Color.new(0, 0, 0, 0))
    self.contents.draw_text(rect, '当前没有任何信息')
  end
  #--------------------------------------------------------------------------
  # ● 获取任务
  #--------------------------------------------------------------------------
  def task
    return @tasks[self.index]
  end
end
  
#==============================================================================
# ■ Window_Task
#------------------------------------------------------------------------------
# 　任务内容显示窗口。
#==============================================================================

class Window_Task < Window_Base
  #--------------------------------------------------------------------------
  # ● 初始化对像
  #--------------------------------------------------------------------------
  def initialize(task_id)
    super(240, 0, 400, 480)
    refresh(task_id)
  end
  #--------------------------------------------------------------------------
  # ● 刷新内容
  #--------------------------------------------------------------------------
  def refresh(task_id)
    self.oy = 0
    self.visible = true
    return if task_id.nil?
    task = $game_party.tasks_info[task_id]
    if !task.nil?
      self.contents = Bitmap.new(self.width - 32, task.height)
    else
      self.contents = Bitmap.new(self.width - 32, self.height - 32)
      return
    end
    self.contents.font.color = normal_color
    # 描绘任务内容
    draw_task_info(task)
  end
  #--------------------------------------------------------------------------
  # ● 描绘任务内容
  #--------------------------------------------------------------------------
  def draw_task_info(task)
    # 记录文字x坐标
    x = 0
    # 记录文字y坐标
    y = 0
    # 记录换行时y坐标最小加值
    min_y = 0
    self.contents.font.color = normal_color
    # 描绘任务简介
    text = task.briefing.clone
    # 限制文字处理
    begin
      last_text = text.clone
      text.gsub!(/\\[Vv]\[([0-9]+)\]/) { $game_variables[$1.to_i] }
    end until text == last_text
    text.gsub!(/\\[Nn]\[([0-9]+)\]/) do
      $game_actors[$1.to_i] != nil ? $game_actors[$1.to_i].name : ""
    end
    # 为了方便、将 "\\\\" 变换为 "\000" 
    text.gsub!(/\\\\/) { "\000" }
    # "\C" 变为 "\001" 
    text.gsub!(/\\[Cc]\[([0-9]+)\]/) { "\001[#{$1}]" }
    # "\I" 变为 "\002" 
    text.gsub!(/\\[Ii]/) { "\002" }
    # "\P" 变为 "\003" 
    text.gsub!(/\\[Pp]/) { "\003" }
    #用于显示怪物资料
    text.gsub!(/\\[Ee]/) { "\004" }
    # c 获取 1 个字 (如果不能取得文字就循环)
    while ((c = text.slice!(/./m)) != nil)
      # \\ 的情况下
      if c == "\000"
        # 还原为本来的文字
        c = "\\"
      end
      # \C[n] 的情况下
      if c == "\001"
        # 更改文字色
        text.sub!(/\[([0-9]+)\]/, "")
        color = $1.to_i
        if color >= 0 and color <= 7
          self.contents.font.color = text_color(color)
        elsif color == 8
          self.contents.font.color = disabled_color
        elsif color == 9
          self.contents.font.color = system_color
        end
        # 下面的文字
        next
      end
      # 图标的情况下
      if c == "\002"
        icon_name = ''
        while ((cha = text.slice!(/./m)) != ']')
          next if cha == '['
          icon_name += cha
        end
        icon = RPG::Cache.icon(icon_name)
        if x + icon.width > self.contents.width
          x = 0
          y += [32, min_y].max
          min_y = 0
        end
        self.contents.blt(x + 4, y + 4, icon, Rect.new(0, 0, 24, 24))
        x += 28
        next
      end
      # 图片的情况下
      if c == "\003"
        pic_name = ''
        while ((cha = text.slice!(/./m)) != ']')
          next if cha == '['
          pic_name += cha
        end
        pic = RPG::Cache.picture(pic_name)
        if x + pic.width > self.contents.width
          x = 0
          y += [32, min_y].max
          min_y = 0
        end
        self.contents.blt(x + 4, y, pic, Rect.new(0, 0, pic.width, pic.height))
        x += pic.width
        min_y = [pic.height, 32].max
        next
      end
      if c == "\004"
        colorsave=self.contents.font.color
        text.sub!(/\[([0-9]+)\]/, "")
        eid = $1.to_i
        bitmap = RPG::Cache.battler($data_enemies[eid].battler_name , $data_enemies[eid].battler_hue )
        src_rect = Rect.new(0, 0,bitmap.width, bitmap.height)
        self.contents.blt(x+4, y, bitmap, src_rect)
        self.contents.font.color = text_color(2)
        self.contents.draw_text(x+50,y,150,32, $data_enemies[eid].name.split(":")[0], 0)
        y+=32
        self.contents.font.color = text_color(3)
        self.contents.draw_text(x+4,y,150,32, "生命", 0)
        self.contents.draw_text(x+154, y, 150,32, "攻速", 0)
        self.contents.draw_text(x+24,y,150,32, $data_enemies[eid].maxhp.to_s, 1)
        self.contents.draw_text(x+174,y,150,32, $data_enemies[eid].agi.to_s+"%", 1)
        y+=32
        self.contents.font.color = text_color(4)
        self.contents.draw_text(x+4, y,150,32, "攻击",0)
        self.contents.draw_text(x+154,y, 150,32, "防御",0)
        self.contents.draw_text(x+24,y,150,32, $data_enemies[eid].atk.to_s, 1)
        self.contents.draw_text(x+174,y,150,32, $data_enemies[eid].pdef.to_s, 1) 
        y+=32
        self.contents.font.color = text_color(3)
        self.contents.draw_text(x+4, y,150,32, "拥有技能：",0)
        x+=50
        for j in 1...$data_skills.size
          if got_p(eid,j)
            n=$data_skills[j].name.split(":")
            if n[1].to_s=="a"
              self.contents.font.color = text_color(n[2].to_i)
            else
              if n[4]==nil
                self.contents.font.color = Color.new(n[1].to_i,n[2].to_i,n[3].to_i)
              else
                self.contents.font.color = Color.new(n[1].to_i,n[2].to_i,n[3].to_i,n[4].to_i)
              end
            end
            if x+self.contents.text_size(n[0]).width>300
               y += [32, min_y].max
               min_y = 0
               x = 50
            end
            self.contents.draw_text(x+60, y, 120, 32, n[0],0)
            x+=self.contents.text_size(n[0]).width+6
          end
        end
        self.contents.font.color = colorsave
        next
      end
      # 另起一行文字的情况下
      if c == "\n"
        y += [32, min_y].max
        min_y = 0
        x = 0
        # 下面的文字
        next
      end
      # 自动换行处理
      if x + self.contents.text_size(c).width > self.contents.width
        y += [32, min_y].max
        min_y = 0
        x = 0
      end
      # 描绘文字
      self.contents.draw_text(4 + x, y, 40, 32, c)
      # x 为要描绘文字的加法运算
      x += self.contents.text_size(c).width
    end
  end
end

#==============================================================================
# ■ Scene_Task
#------------------------------------------------------------------------------
# 　处理任务画面的类。
#==============================================================================

class Scene_Task
  #--------------------------------------------------------------------------
  # ● 主处理
  #--------------------------------------------------------------------------
  def main
    $right_back_spr=Sprite.new
    if $game_switches[140]
      $right_back_spr.bitmap=RPG::Cache.picture("nevermore")
    else
      $right_back_spr.bitmap=RPG::Cache.picture("sven")
    end
    $right_back_spr.x=640
    $right_back_spr.z=100
    # 刷新任务资料
    $game_party.get_tasks_info
    # 生成任务名称窗口
    @task_names_window = Window_Task_Name.new($game_party.current_tasks)
    @task_names_window.active = true
    if $game_party.current_tasks != []
      @task_names_window.index = $game_party.current_tasks.index($game_party.latest_task)
    end
    # 生成任务内容窗口
    @task_info_window = Window_Task.new($game_party.latest_task)
    @task_info_window.active = true
    @save_index=$game_party.latest_task
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
      # 如果画面被切换的话就中断循环
      if $scene != self
        break
      end
    end
    # 准备过渡
    Graphics.freeze
    # 释放窗口
    @task_names_window.dispose
    @task_info_window.dispose
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面
  #--------------------------------------------------------------------------
  def update
    # 刷新窗口
    @task_names_window.update
    @task_info_window.update
    update_task_names_window
  end
  #--------------------------------------------------------------------------
  # ● 刷新任务名称窗口
  #--------------------------------------------------------------------------
  def update_task_names_window
    # 按下 B 键的情况下
    if @save_index != @task_names_window.index
      @save_index = @task_names_window.index
      @task_info_window.refresh($game_party.current_tasks[@save_index])
    end
    if Input.trigger?(Input::B)
      # 演奏取消 SE
      $game_system.se_play($data_system.cancel_se)
      # 这里设置返回的场景，返回地图是Scene_Map.new，菜单是Scene_Menu.new(任务界面index）
      $scene = Scene_Map.new
      return
    end
    # 按下 C 键的情况下
    if Input.trigger?(Input::C)
      # 无任务可显示的话
      if @task_names_window.task == nil
        # 演奏冻结 SE
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      # 如果光标没有移动的话，翻页
      if $game_party.latest_task == @task_names_window.task.id
        if @task_info_window.oy + @task_info_window.height - 32 > @task_info_window.contents.height
          @task_info_window.oy = 0
        else
          @task_info_window.oy += 480-32
        end
        if @task_info_window.contents.height > @task_info_window.height - 32
          # 演奏翻页 SE
          Audio.se_play(CHANGE_PAGE_SE)
        end
      else
        @task_info_window.refresh(@task_names_window.task.id)
        $game_party.latest_task = @task_names_window.task.id
        # 演奏确定 SE
        $game_system.se_play($data_system.decision_se)
      end
    end
  end
end