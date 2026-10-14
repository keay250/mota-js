#==============================================================================
# 本脚本来自www.66RPG.com，使用和转载请保留此信息
#============================================================================== 


# ————————————————————————————————————

# ▼▲▼ XRXS13. パーティ列車移動 ver.1.02 ▼▲▼
# by fukuyama

#
# Train_Actor
#
# fukuyama@alles.or.jp
# http://www4.big.or.jp/~fukuyama/rgss/Train_Actor.txt
#

module Train_Actor

 


#是否使用停止跟随的方法，也就是说，这里false改为true的时候，如果TRANSPARENT_SWITCHES_INDEX
#开关打开，跟随的人物就消失了（其实只是变成透明而已）
TRANSPARENT_SWITCH = false
TRANSPARENT_SWITCHES_INDEX = 20
#举例：第一个为true，第二个为20，则打开20号开关，后面的人都没了。

 

 

#跟随人数的最大数目，可以更改为2、3什么的。
TRAIN_ACTOR_SIZE_MAX = 4

 

 

# 定数
#Input::DOWN = 2
#Input::LEFT = 4
#Input::RIGHT = 6
#Input::UP = 6
DOWN_LEFT = 1
DOWN_RIGHT = 3
UP_LEFT = 7
UP_RIGHT = 9
JUMP = 5

class Game_Party_Actor < Game_Character
def initialize
super()
@through = true
end
def setup(actor)
# キャラクターのファイル名と色相を設定
if actor != nil
@character_name = actor.character_name
@character_hue = actor.character_hue
else
@character_name = ""
@character_hue = 0
end
# 不透明度と合成方法を初期化
@opacity = $game_player.opacity
@blend_type = 0
end
def set_opc(i)
  @opacity=i
end
def set_direction(d)
  @direction=d
end
def screen_z(height = 0)
if $game_player.x == @x and $game_player.y == @y
return $game_player.screen_z(height) - 1
end
super(height)
end
#--------------------------------------------------------------------------
# ● 下に移動
# turn_enabled : その場での向き変更を許可するフラグ
#--------------------------------------------------------------------------
def move_down(turn_enabled = true)
# 下を向く
if turn_enabled
turn_down
end
# 通行可能な場合
if passable?(@x, @y, Input::DOWN)
# 下を向く
turn_down
# 座標を更新
@y += 1
end
end
#--------------------------------------------------------------------------
# ● 左に移動
# turn_enabled : その場での向き変更を許可するフラグ
#--------------------------------------------------------------------------
def move_left(turn_enabled = true)
# 左を向く
if turn_enabled
turn_left
end
# 通行可能な場合
if passable?(@x, @y, Input::LEFT)
# 左を向く
turn_left
# 座標を更新
@x -= 1
  tile_id = $game_map.data[@x, @y, 1]
  if tile_id != nil
    if $game_map.terrain_tags[tile_id]==1
      @y+=1
    end
    if $game_map.terrain_tags[tile_id]==2
      @y-=1
    end
  end
end
end
#--------------------------------------------------------------------------
# ● 右に移動
# turn_enabled : その場での向き変更を許可するフラグ
#--------------------------------------------------------------------------
def move_right(turn_enabled = true)
# 右を向く
if turn_enabled
turn_right
end
# 通行可能な場合
if passable?(@x, @y, Input::RIGHT)
# 右を向く
turn_right
# 座標を更新
@x += 1
tile_id = $game_map.data[@x, @y, 1]
  if tile_id != nil
    if $game_map.terrain_tags[tile_id]==1
      @y-=1
    end
    if $game_map.terrain_tags[tile_id]==2
      @y+=1
    end
  end
end
end
#--------------------------------------------------------------------------
# ● 上に移動
# turn_enabled : その場での向き変更を許可するフラグ
#--------------------------------------------------------------------------
def move_up(turn_enabled = true)
# 上を向く
if turn_enabled
turn_up
end
# 通行可能な場合
if passable?(@x, @y, Input::UP)
# 上を向く
turn_up
# 座標を更新
@y -= 1
end
end
#--------------------------------------------------------------------------
# ● 左下に移動
#--------------------------------------------------------------------------
def move_lower_left
# 向き固定でない場合
unless @direction_fix
# 右向きだった場合は左を、上向きだった場合は下を向く
@direction = (@direction == Input::RIGHT ? Input::LEFT : @direction == Input::UP ? Input::DOWN : @direction)
end
# 下→左、左→下 のどちらかのコースが通行可能な場合
if (passable?(@x, @y, Input::DOWN) and passable?(@x, @y + 1, Input::LEFT)) or
(passable?(@x, @y, Input::LEFT) and passable?(@x - 1, @y, Input::DOWN))
# 座標を更新
@x -= 1
@y += 1
end
end
#--------------------------------------------------------------------------
# ● 右下に移動
#--------------------------------------------------------------------------
def move_lower_right
# 向き固定でない場合
unless @direction_fix
# 左向きだった場合は右を、上向きだった場合は下を向く
@direction = (@direction == Input::LEFT ? Input::RIGHT : @direction == Input::UP ? Input::DOWN : @direction)
end
# 下→右、右→下 のどちらかのコースが通行可能な場合
if (passable?(@x, @y, Input::DOWN) and passable?(@x, @y + 1, Input::RIGHT)) or
(passable?(@x, @y, Input::RIGHT) and passable?(@x + 1, @y, Input::DOWN))
# 座標を更新
@x += 1
@y += 1
end
end
#--------------------------------------------------------------------------
# ● 左上に移動
#--------------------------------------------------------------------------
def move_upper_left
# 向き固定でない場合
unless @direction_fix
# 右向きだった場合は左を、下向きだった場合は上を向く
@direction = (@direction == Input::RIGHT ? Input::LEFT : @direction == Input::DOWN ? Input::UP : @direction)
end
# 上→左、左→上 のどちらかのコースが通行可能な場合
if (passable?(@x, @y, Input::UP) and passable?(@x, @y - 1, Input::LEFT)) or
(passable?(@x, @y, Input::LEFT) and passable?(@x - 1, @y, Input::UP))
# 座標を更新
@x -= 1
@y -= 1
end
end
#--------------------------------------------------------------------------
# ● 右上に移動
#--------------------------------------------------------------------------
def move_upper_right
# 向き固定でない場合
unless @direction_fix
# 左向きだった場合は右を、下向きだった場合は上を向く
@direction = (@direction == Input::LEFT ? Input::RIGHT : @direction == Input::DOWN ? Input::UP : @direction)
end
# 上→右、右→上 のどちらかのコースが通行可能な場合
if (passable?(@x, @y, Input::UP) and passable?(@x, @y - 1, Input::RIGHT)) or
(passable?(@x, @y, Input::RIGHT) and passable?(@x + 1, @y, Input::UP))
# 座標を更新
@x += 1
@y -= 1
end
end
attr_writer :move_speed
attr_writer :step_anime
end
module Spriteset_Map_Module
def setup_actor_character_sprites?
return @setup_actor_character_sprites_flag != nil
end
def setup_actor_character_sprites(characters)
if !setup_actor_character_sprites?
index_game_player = 0
@character_sprites.each_index do |i|
if @character_sprites[i].character.instance_of?(Game_Player)
index_game_player = i
break
end
end
for character in characters.reverse
@character_sprites.unshift(
Sprite_Character.new(@viewport1, character)
)
end
@setup_actor_character_sprites_flag = true
end
end
end
module Scene_Map_Module
def setup_actor_character_sprites(characters)
@spriteset.setup_actor_character_sprites(characters)
end
end
module Game_Party_Module
def set_transparent_actors(transparent)
@transparent = transparent
end
def set_characters(i,d)
  @characters[i].set_direction(d)
end
def delete_move
  @move_list = []
end
def get_characters_xy(i)
  return [@characters[i].x,@characters[i].y]
end
def set_characters_xy(i,x,y)
  @characters[i].set_xy(x,y)
end
def set_characters(i,d)
  @characters[i].set_direction(d)
end
def setup_actor_character_sprites
if @characters == nil
@characters = []
for i in 1 ... TRAIN_ACTOR_SIZE_MAX
@characters.push(Game_Party_Actor.new)
end
end
for i in 1 ... TRAIN_ACTOR_SIZE_MAX
@characters[i - 1].setup(actors[i])
end
if $scene.class.method_defined?('setup_actor_character_sprites')
$scene.setup_actor_character_sprites(@characters)
end
end
def update_party_actors
setup_actor_character_sprites
transparent = $game_player.transparent
if transparent == false
if TRANSPARENT_SWITCH
transparent = $game_switches[TRANSPARENT_SWITCHES_INDEX]
end
end
for character in @characters
character.transparent = transparent
character.move_speed = $game_player.move_speed
character.step_anime = $game_player.step_anime
if $game_player.character_name==""
  character.set_opc(0)
else
  character.set_opc($game_player.opacity)
end
character.update
end
end
def moveto_party_actors( x, y )
setup_actor_character_sprites
for character in @characters
character.moveto( x, y )
end
if @move_list == nil
@move_list = []
end
move_list_setup
end
def move_party_actors
if @move_list == nil
@move_list = []
move_list_setup
end
@move_list.each_index do |i|
if @characters[i] != nil
case @move_list[i].type
when Input::DOWN
@characters[i].move_down(@move_list[i].args[0])
when Input::LEFT
@characters[i].move_left(@move_list[i].args[0])
when Input::RIGHT
@characters[i].move_right(@move_list[i].args[0])
when Input::UP
@characters[i].move_up(@move_list[i].args[0])
when DOWN_LEFT
@characters[i].move_lower_left
when DOWN_RIGHT
@characters[i].move_lower_right
when UP_LEFT
@characters[i].move_upper_left
when UP_RIGHT
@characters[i].move_upper_right
when JUMP
@characters[i].jump(@move_list[i].args[0],@move_list[i].args[1])
end
end
end
end
class Move_List_Element
def initialize(type,args)
@type = type
@args = args
end
def type() return @type end
def args() return @args end
end
def move_list_setup
for i in 0 .. TRAIN_ACTOR_SIZE_MAX
@move_list[i] = nil
end
end
def add_move_list(type,*args)
@move_list.unshift(Move_List_Element.new(type,args)).pop
end
def move_down_party_actors(turn_enabled = true)
move_party_actors
add_move_list(Input::DOWN,turn_enabled)
end
def move_left_party_actors(turn_enabled = true)
move_party_actors
add_move_list(Input::LEFT,turn_enabled)
end
def move_right_party_actors(turn_enabled = true)
move_party_actors
add_move_list(Input::RIGHT,turn_enabled)
end
def move_up_party_actors(turn_enabled = true)
move_party_actors
add_move_list(Input::UP,turn_enabled)
end
def move_lower_left_party_actors
move_party_actors
add_move_list(DOWN_LEFT)
end
def move_lower_right_party_actors
move_party_actors
add_move_list(DOWN_RIGHT)
end
def move_upper_left_party_actors
move_party_actors
add_move_list(UP_LEFT)
end
def move_upper_right_party_actors
move_party_actors
add_move_list(UP_RIGHT)
end
def jump_party_actors(x_plus, y_plus)
move_party_actors
add_move_list(JUMP,x_plus, y_plus)
end
end
module Game_Player_Module
def update
$game_party.update_party_actors
super
end
def moveto( x, y )
$game_party.moveto_party_actors( x, y )
super( x, y )
end
def move_down(turn_enabled = true)
if passable?(@x, @y, Input::DOWN)
$game_party.move_down_party_actors(turn_enabled)
end
super(turn_enabled)
end
def move_left(turn_enabled = true)
if passable?(@x, @y, Input::LEFT)
$game_party.move_left_party_actors(turn_enabled)
end
super(turn_enabled)
end
def move_right(turn_enabled = true)
if passable?(@x, @y, Input::RIGHT)
$game_party.move_right_party_actors(turn_enabled)
end
super(turn_enabled)
end
def move_up(turn_enabled = true)
if passable?(@x, @y, Input::UP)
$game_party.move_up_party_actors(turn_enabled)
end
super(turn_enabled)
end
def move_lower_left
# 下→左、左→下 のどちらかのコースが通行可能な場合
if (passable?(@x, @y, Input::DOWN) and passable?(@x, @y + 1, Input::LEFT)) or
(passable?(@x, @y, Input::LEFT) and passable?(@x - 1, @y, Input::DOWN))
$game_party.move_lower_left_party_actors
end
super
end
def move_lower_right
# 下→右、右→下 のどちらかのコースが通行可能な場合
if (passable?(@x, @y, Input::DOWN) and passable?(@x, @y + 1, Input::RIGHT)) or
(passable?(@x, @y, Input::RIGHT) and passable?(@x + 1, @y, Input::DOWN))
$game_party.move_lower_right_party_actors
end
super
end
def move_upper_left
# 上→左、左→上 のどちらかのコースが通行可能な場合
if (passable?(@x, @y, Input::UP) and passable?(@x, @y - 1, Input::LEFT)) or
(passable?(@x, @y, Input::LEFT) and passable?(@x - 1, @y, Input::UP))
$game_party.move_upper_left_party_actors
end
super
end
def move_upper_right
# 上→右、右→上 のどちらかのコースが通行可能な場合
if (passable?(@x, @y, Input::UP) and passable?(@x, @y - 1, Input::RIGHT)) or
(passable?(@x, @y, Input::RIGHT) and passable?(@x + 1, @y, Input::UP))
$game_party.move_upper_right_party_actors
end
super
end
def jump(x_plus, y_plus)
# 新しい座標を計算
new_x = @x + x_plus
new_y = @y + y_plus
# 加算値が (0,0) の場合か、ジャンプ先が通行可能な場合
if (x_plus == 0 and y_plus == 0) or passable?(new_x, new_y, 0)
$game_party.jump_party_actors(x_plus, y_plus)
end
super(x_plus, y_plus)
end
attr_reader :move_speed
attr_reader :step_anime
end
end # module Train_Actor
class Game_Party
include Train_Actor::Game_Party_Module
end
class Game_Player
include Train_Actor::Game_Player_Module
end
class Spriteset_Map
include Train_Actor::Spriteset_Map_Module
end
class Scene_Map
include Train_Actor::Scene_Map_Module
end

#==============================================================================
# 本脚本来自www.66RPG.com，使用和转载请保留此信息
#============================================================================== 
