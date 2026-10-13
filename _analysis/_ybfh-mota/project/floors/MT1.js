main.floors.MT1=
{
    "floorId": "MT1",
    "title": "寂静之森外围",
    "name": "寂静之森外围",
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
        "\t[贾斯汀]啊……",
        "\t[贾斯汀]头好痛……",
        "\t[贾斯汀]我刚刚是透支体力昏过去了么。队长呢？其他人呢？",
        "\t[贾斯汀]等等，我想起来了……",
        "\t[贾斯汀]队长，队长他一个人把那些魔兽引开了，然后让我们拼命逃……",
        "\t[贾斯汀]…………",
        "\t[贾斯汀]希望我之前跑的方向没有错，这里应该是离开森林的道路。",
        "\t[贾斯汀]说不定其他人已经回去了呢，哈哈……",
        "\t[贾斯汀]伟大的全能之神，请您保佑我和我队友们吧……",
        {"type": "setText", "align": "left"},
        {"type": "tip", "text": "【寂静之森外围】按方向键移动；撞上怪物即可战斗。"}
    ],
    "eachArrive": [],
    "parallelDo": "",
    "events": {
        "9,1": {
            "trigger": "action",
            "enable": true,
            "noPass": null,
            "displayDamage": true,
            "opacity": 1,
            "filter": {"blur": 0, "hue": 0, "grayscale": 0, "invert": false, "shadow": 0},
            "data": [
                {"type": "setText", "align": "center"},
                "\t[路牌]↑ 姆依森运河",
                "\t[路牌]→ 厄泽城",
                "\t[路牌]←↓ 寂静之森深处",
                {"type": "setText", "align": "left"},
                {"type": "tip", "text": "太好了，看到路牌了，小站应该就在前面。"}
            ]
        },
        "5,3": {
            "trigger": "action",
            "enable": true,
            "noPass": null,
            "displayDamage": true,
            "opacity": 1,
            "filter": {"blur": 0, "hue": 0, "grayscale": 0, "invert": false, "shadow": 0},
            "data": [
                {"type": "setText", "align": "center"},
                "\t[路过的佣兵]你问我在这里干什么？好吧，偷偷告诉你。",
                "\t[路过的佣兵]我的东西丢在了森林里面，在等待有谁捡到还给我。",
                "\t[路过的佣兵]那是一根不起眼的树枝，是我小时候家里后院桃树上的，对我有很重要的纪念意义。",
                "\t[路过的佣兵]如果找到了的话把它还给我，我可以给你另一样东西，具体是什么先保密。",
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
                "\t[贾斯汀]我的天，这里怎么会有一只荷依米贵族！这种魔物应该不会出现在森林外围啊。",
                "\t[贾斯汀]一定要小心谨慎，绕过它……",
                {"type": "setText", "align": "left"}
            ]
        }
    },
    "changeFloor": {
        "11,11": {"floorId": ":next", "stair": "downFloor"}
    },
    "afterBattle": {},
    "afterGetItem": {},
    "afterOpenDoor": {},
    "cannotMove": {},
    "map": [
    [  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3],
    [  3, 88,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  3],
    [  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  0,  3],
    [  3, 21,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  3],
    [  3,  0,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3],
    [  3,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 31,  3],
    [  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  0,  3],
    [  3,201,202,201,  0,  0, 28, 27,  0,  0,  0,  0,  3],
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
    "bgm": "bgm.mp3",
    "beforeBattle": {},
    "cannotMoveIn": {},
    "autoEvent": {},
    "canFlyFrom": true
}
