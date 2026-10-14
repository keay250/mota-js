#==============================================================================
# ◎ ruby常用语法
#==============================================================================
#转载互联网，内容修改丿轩恺丶，使用和转载请保留本信息
#==============================================================================
#常用计算：
#加法：+
#减法：-
#乘法：*
#除法：/
#平方：**
#根号：//
#显示文章：
#$game_temp.message_text＝ ""
#显示引号中的文章。
#更改文章选项：
#$game_system.message_position ＝0，1，2
#表示上、中、下，三个位置
#$game_system.message_frame ＝ 0 ，1
#0表示不透明，其他的话就透明
#等待：
#@wait_count = X
#等待X帧
#中断事件处理：
#command_end
#把某一个事件暂时消除
#$game_map.events[X].erase
#其中X表示把X号事件暂时消除，如果是消除本事件X = @event_id
#执行公共事件：
#$game_temp.common_event_id = 编号
#执行编号的公共事件。注意，这个执行和直接在事件中的公共事件有微妙区别。
#开关操作：
#$game_switches[编号] = true / false
#true是打开，false是关闭
#变量操作：
#$game_variables[编号] = 数值
#这里有一些常用的内容：
#rand(100)：返回0－99的随机数
#rand(100)+10000：返回10000－10099的随机数
#$game_party.item_number(编号)：编号物品的个数
#角色相关：以下为某编号的角色的相关属性
#生命：$game_actors[编号].hp
#精神：$game_actors[编号].sp
#经验：$game_actors[编号].exp
#等级：$game_actors[编号].level
#最大生命：$game_actors[编号].maxhp
#最大精神：$game_actors[编号].maxsp
#力量：$game_actors[编号].str
#灵巧：$game_actors[编号].dex
#速度：$game_actors[编号].agi
#魔力：$game_actors[编号].int
#攻击力：$game_actors[编号].atk
#物理防御：$game_actors[编号].pdef
#魔法防御：$game_actors[编号].mdef
#回避修正：$game_actors[编号].eva
#姓名：$game_actors[编号].name
#职业编号：$game_actors[编号].class_id
#职业名称：$game_actors[编号].class_name
#武器编号：$game_actors[编号].weapon_id
#防具1编号：$game_actors[编号].armor1_id
#防具2编号：$game_actors[编号].armor2_id
#防具3编号：$game_actors[编号].armor3_id
#防具4编号：$game_actors[编号].armor4_id
#完全回复：$game_actors[编号].recover_all
#领悟特技：$game_actors[编号].learn_skill(编号)
#遗忘特技：$game_actors[编号].forget_skill(编号)
#位置(前卫返回0，中卫返回1，后卫返回2)：$data_classes[$game_actors[编号].class_id].position
#学会特技总数：$game_actors[编号].skills.size
#敌人：$game_troop.enemies[编号]
#敌人拥有角色的部分功能，包括.hp，.sp，.maxhp，.maxsp，.str，.dex，.agi，.int，.atk，.pdef，.mdef，.eva
#地图的事件属性：
#$game_map.events[编号].x，$game_map.events[编号].y
#编号事件的x，y坐标
#$game_map.events[编号].screen_x，$game_map.events[编号].screen_y
#编号事件的屏幕x，y坐标
#$game_map.events[编号].direction
#编号事件的朝向
#$game_map.events[编号].terrain_tag
#编号事件所处的地形标志
#$game_map.events[编号].moveto(x,y)
#把事件扔到(x,y)
#——以上几个事件的，如果要求为角色，则为“$game_player.x”等
#地图ID：$game_map.map_id
#同伴总人数：$game_party.actors.size
#步数：$game_party.steps
#金钱：$game_party.gold
#游戏总时间(秒数)：Graphics.frame_count / Graphics.frame_rate
#游戏总帧数：Graphics.frame_count
#游戏帧速率(可直接＝n调整)：Graphics.frame_rate
#计时器剩余秒数：$game_system.timer / Graphics.frame_rate
#存档次数：$game_system.save_count
#独立开关操作：
#$game_self_switches[[地图编号,事件编号,"A"]] = true/false
#把地图编号的地图上的事件编号的事件的A开关打开。其实不光ABCD，还可以建立更多独立开关，不过调用也得用同样脚本。
#计时器打开：
#$game_system.timer = 需要的秒数;$game_system.timer_working = true
#计时器关闭：
#$game_system.timer_working = false
#增减金钱：
#$game_party.gain_gold(金钱量)
#增减物品：
#$game_party.gain_item(物品编号,数量)
#举例：
#$game_party.gain_item(rand(10),rand(10))：随机获得0－9号中某一物品，数量为0－9随机。
#增减武器：
#$game_party.gain_weapon(物品编号,数量)
#增减防具：
#$game_party.gain_armor(物品编号,数量)
#清空现有所有物品：
#$game_party.items.clear
#清空所有武器：
#$game_party.weapons.clear
#清空所有防具：
#$game_party.armors.clear
#角色替换：
#加入角色：$game_party.add_actor(编号)
#删除角色：$game_party.remove_actor(编号)
#初始化角色：$game_party[编号].setup(编号)
#更改窗口外观：
#$game_system.windowskin_name = 文件名
#更改禁止存档
#$game_system.save_disabled = true/false
#更改禁止菜单：
#$game_system.menu_disabled = true/false
#更改禁止遇敌：
#$game_system.encounter_disabled = true/false
#地图卷动:
#$game_map.start_scroll(方向，距离，速度)
#地图某角色显示动画：
#$game_map.events[id].animation_id = 动画编号
#角色透明：
#$game_player.transparent ＝ true/false
#等待移动结束：
#@move_route_waiting = true
#开始更改色调：
#$game_screen.start_tone_change(Tone.new(R,G,B,A),帧数)
#画面闪烁：
#$game_screen.start_flash(Color.new(R,G,B,A),帧数)
#画面振动：
#$game_screen.start_shake(力度，速度，帧数)
#显示图片：
#$game_screen.pictures[number].show(name, origin, x, y, zoom_x, zoom_y, opacity, blend_type)
#移动图片：
#$game_screen.pictures[number].move(duration, origin, x, y, zoom_x, zoom_y, opacity, blend_type)
#其中：
#     name         : 文件名
#     origin       : 原点
#     x            : X 坐标
#     y            : Y 坐标
#     zoom_x       : X 方向放大率
#     zoom_y       : Y 方向放大率
#     opacity      : 不透明度
#     blend_type   : 合成方式
#     duration     : 时间
#旋转图片：
#$game_screen.pictures[number].rotate(速度)
#删除图片：
#$game_screen.pictures[number].erase
#显示动画(战斗中)
#battler.animation_id = 动画编号
#battler可以是敌人或者自己人，请先定义。
#显示伤害：
#battler.damage = 伤害值
#battler.damage_pop = true
#注意，这个显示伤害可以让伤害值为字符串！并不会真的减血，减血用battler.hp -= 数值
#battler.criticle = true 这个还可以打开会心一击标志
#战斗中断：
#$game_temp.battle_abort = true
#调用菜单：
#$game_temp.menu_calling = true
#调用存档画面：
#$game_temp.save_calling = true
#游戏结束：
#$game_temp.gameover = true
#返回标题画面：
#$game_temp.to_title = true
#强行启动事件：
#$game_map.events[编号].start
#通行判定：
#$game_player.passable?(x,y,方向)
#用来判断地图某处是否在某个方向可通行
#正在移动判定：
#$game_player.moving?
#$game_map.events[编号].moving?
#播放效果：
#Audio.bgm_play("文件名",音量,节奏速度)
#Audio.bgs_play("文件名",音量,节奏速度)
#Audio.me_play("文件名",音量,节奏速度)
#Audio.se_play("文件名",音量,节奏速度)
#播放bgm,bgs,me,se
#Audio.bgm_stop
#Audio.bgs_stop
#Audio.me_stop
#Audio.se_stop
#停止播放bgm,bgs,me,se
#$game_system.playing_bgm，$game_system.playing_bgs
#获得演奏中的bgm,bgs
#game_system.bgm_memorize，game_system.bgm_restore
#game_system.bgs_memorize，game_system.bgs_restore
#记忆、还原bgm,bgs
#判断某角色在队伍中：$game_party.actors.include?($game_actors[编号])
#判断是否学过某特技：$game_actors[编号].skill_learn?(特技编号)
#按下某键的时候：Input.press?(键)，Input.trigger?(键)