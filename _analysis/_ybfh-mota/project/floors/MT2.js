main.floors.MT2=
{
    "floorId": "MT2",
    "title": "寂静之森外围 · 出口",
    "name": "寂静之森外围 · 出口",
    "width": 13,
    "height": 13,
    "canFlyTo": true,
    "canUseQuickShop": true,
    "cannotViewMap": false,
    "images": [],
    "ratio": 1,
    "defaultGround": "ground",
    "firstArrive": [
        {"type": "playSound", "name": "zone.mp3"},
        {"type": "setText", "align": "center"},
        "\t[贾斯汀]终于出来了……",
        "\t[贾斯汀]其他人没有在这里等待吗？也许已经回城了也说不定。",
        {"type": "setText", "align": "left"},
        {"type": "tip", "text": "【寂静之森外围·出口】前方就是厄泽城小站。按方向键移动，撞上怪物即可战斗。"}
    ],
    "eachArrive": [],
    "parallelDo": "",
    "events": {
        "5,3": {
            "trigger": "action",
            "enable": true,
            "noPass": null,
            "displayDamage": true,
            "opacity": 1,
            "filter": {"blur": 0, "hue": 0, "grayscale": 0, "invert": false, "shadow": 0},
            "data": [
                {"type": "if", "condition": "item:yellowKey", "true": [
                    {"type": "setText", "align": "center"},
                    "\t[路过的佣兵]太棒了，你终于找到它了！",
                    "\t[路过的佣兵]给你，祖传的蓝钥匙！",
                    "\t[贾斯汀]（只是一把蓝钥匙啊……说起来这根树枝总感觉怪怪的，以后或许可能会有用的样子……）",
                    "\t[路过的佣兵]真是个乐于助人的好少年呀。",
                    {"type": "setText", "align": "left"},
                    {"type": "function", "function": "function(){\ncore.addItem('blueKey',1)\n}"},
                    {"type": "tip", "text": "获得【蓝钥匙】×1"}
                ], "false": [
                    {"type": "setText", "align": "center"},
                    "\t[路过的佣兵]你问我在这里干什么？好吧，偷偷告诉你。",
                    "\t[路过的佣兵]我的东西丢在了森林里面，在等待有谁捡到还给我。",
                    "\t[路过的佣兵]那是一根不起眼的树枝，是我小时候家里后院桃树上的，对我有很重要的纪念意义。",
                    "\t[路过的佣兵]如果找到了的话把它还给我，我可以给你另一样东西，具体是什么先保密。",
                    {"type": "setText", "align": "left"}
                ]}
            ]
        },
        "9,1": {
            "trigger": "action",
            "enable": true,
            "noPass": null,
            "displayDamage": true,
            "opacity": 1,
            "filter": {"blur": 0, "hue": 0, "grayscale": 0, "invert": false, "shadow": 0},
            "data": [
                {"type": "setText", "align": "center"},
                "\t[路牌]欢迎来到厄泽城小站。",
                "\t[路牌]小站能够让你在地图之间快速地穿行。",
                "\t[贾斯汀]（当然，这是作为玩家所拥有的特权，实际上，游戏中的人物还是要用腿去走完中间的路程的。）",
                {"type": "setText", "align": "left"}
            ]
        },
        "7,7": {
            "trigger": "action",
            "enable": true,
            "noPass": null,
            "displayDamage": true,
            "opacity": 1,
            "filter": {"blur": 0, "hue": 0, "grayscale": 0, "invert": false, "shadow": 0},
            "data": [
                {"type": "setText", "align": "center"},
                "\t[贾斯汀]这里安静得有些反常……森林出口附近的魔物反而更多了。",
                {"type": "setText", "align": "left"}
            ]
        }
    },
    "changeFloor": {
        "1,1": {"floorId": ":before", "stair": "upFloor"}
    },
    "afterBattle": {},
    "afterGetItem": {},
    "afterOpenDoor": {},
    "cannotMove": {},
    "map": [
    [  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3],
    [  3, 88,  0,  0,  0,  0,  0,  0,  0,129,  0,  0,  3],
    [  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  0,  3],
    [  3, 21,  0,  0,  0,121,  0,  0,  0,  0,  0,  0,  3],
    [  3,  0,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3],
    [  3,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 31,  3],
    [  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  0,  3],
    [  3,209,210,210,  0,  0, 27, 28,  0,  0,  0,  0,  3],
    [  3,  0,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3],
    [  3,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  3],
    [  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  0,  3],
    [  3,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 87,  3],
    [  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3]
],
    "bgmap": [

],
    "fgmap": [

],
    "downFloor": [1, 1],
    "upFloor": [11, 11],
    "bgm": "forest.mp3",
    "beforeBattle": {},
    "cannotMoveIn": {},
    "autoEvent": {},
    "canFlyFrom": true
}
