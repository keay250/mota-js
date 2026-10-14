main.floors.MT4=
{
    "floorId": "MT4",
    "title": "寂静之森外围 4F",
    "name": "寂静之森外围 4F",
    "width": 15,
    "height": 15,
    "canFlyTo": true,
    "canUseQuickShop": true,
    "cannotViewMap": false,
    "images": [
        {
            "name": "map012_bg.png",
            "x": 0,
            "y": 0,
            "canvas": "bg"
        }
    ],
    "ratio": 1,
    "defaultGround": "ground",
    "firstArrive": [
        {
            "type": "playSound",
            "name": "forest.mp3"
        },
        {
            "type": "tip",
            "text": "进入【寂静之森外围 4F】！"
        }
    ],
    "eachArrive": [],
    "parallelDo": "",
    "events": {
        "4,13": {
            "trigger": "action",
            "enable": true,
            "data": [
                {
                    "type": "playSound",
                    "name": "item.mp3"
                },
                {
                    "type": "setValue",
                    "name": "item:blueKey",
                    "operator": "+=",
                    "value": "1"
                },
                {
                    "type": "hide",
                    "remove": true
                }
            ]
        },
        "2,3": {
            "trigger": "action",
            "enable": true,
            "data": [
                {
                    "type": "playSound",
                    "name": "item.mp3"
                },
                {
                    "type": "setValue",
                    "name": "item:yellowKey",
                    "operator": "+=",
                    "value": "1"
                },
                {
                    "type": "hide",
                    "remove": true
                }
            ]
        },
        "7,2": {
            "trigger": "action",
            "enable": true,
            "data": [
                {
                    "type": "playSound",
                    "name": "item.mp3"
                },
                {
                    "type": "setValue",
                    "name": "item:yellowKey",
                    "operator": "+=",
                    "value": "1"
                },
                {
                    "type": "hide",
                    "remove": true
                }
            ]
        },
        "13,3": {
            "trigger": "action",
            "enable": true,
            "data": [
                {
                    "type": "playSound",
                    "name": "item.mp3"
                },
                {
                    "type": "setValue",
                    "name": "item:yellowKey",
                    "operator": "+=",
                    "value": "1"
                },
                {
                    "type": "hide",
                    "remove": true
                }
            ]
        },
        "9,7": {
            "trigger": "action",
            "enable": true,
            "data": [
                {
                    "type": "playSound",
                    "name": "item.mp3"
                },
                {
                    "type": "setValue",
                    "name": "item:yellowKey",
                    "operator": "+=",
                    "value": "1"
                },
                {
                    "type": "hide",
                    "remove": true
                }
            ]
        },
        "1,7": {
            "trigger": "action",
            "enable": true,
            "data": [
                {
                    "type": "playSound",
                    "name": "cursor.mp3"
                },
                "\t[贾斯汀]我的天，这里怎么会有一只荷依米贵族！\n这种高阶魔物原本绝不会出现在森林外围啊。",
                "\t[贾斯汀]一定要小心谨慎，先绕过它……",
                {
                    "type": "hide",
                    "remove": true
                }
            ]
        },
        "3,5": {
            "trigger": "action",
            "enable": true,
            "data": [
                {
                    "type": "playSound",
                    "name": "cursor.mp3"
                },
                "\t[路牌]【设定说明之等级】\n通过与怪物战斗获取经验，适时升级提升属性。\n面对伤害过高的强敌，可先消灭弱小怪物凑经验升级！"
            ]
        },
        "4,0": {
            "trigger": "action",
            "enable": true,
            "data": [
                {
                    "type": "playSound",
                    "name": "cursor.mp3"
                },
                "\t[路牌]【设定说明之机关门】\n机关门往往需要达成特定条件才能开启，最常见的是击杀附近的守护怪物！"
            ]
        }
    },
    "changeFloor": {
        "0,7": {
            "floorId": "MT3",
            "loc": [
                14,
                5
            ]
        },
        "14,7": {
            "floorId": "MT5",
            "loc": [
                0,
                7
            ]
        }
    },
    "afterBattle": {},
    "afterGetItem": {},
    "afterOpenDoor": {},
    "cannotMove": {},
    "map": [
        [
            17,
            17,
            17,
            17,
            129,
            17,
            17,
            0,
            17,
            17,
            17,
            17,
            17,
            17,
            17
        ],
        [
            17,
            33,
            28,
            17,
            0,
            85,
            32,
            0,
            32,
            85,
            0,
            0,
            0,
            0,
            17
        ],
        [
            17,
            17,
            210,
            17,
            32,
            17,
            0,
            21,
            0,
            17,
            32,
            17,
            17,
            81,
            17
        ],
        [
            17,
            32,
            21,
            17,
            0,
            17,
            27,
            0,
            28,
            17,
            0,
            17,
            0,
            21,
            17
        ],
        [
            17,
            209,
            17,
            17,
            32,
            17,
            17,
            85,
            17,
            17,
            32,
            17,
            32,
            17,
            17
        ],
        [
            17,
            0,
            32,
            129,
            0,
            210,
            0,
            0,
            0,
            213,
            0,
            17,
            0,
            27,
            17
        ],
        [
            17,
            205,
            0,
            82,
            204,
            17,
            17,
            0,
            17,
            17,
            81,
            17,
            17,
            0,
            17
        ],
        [
            88,
            0,
            17,
            17,
            0,
            32,
            17,
            211,
            0,
            21,
            0,
            28,
            17,
            214,
            87
        ],
        [
            17,
            204,
            0,
            81,
            214,
            17,
            17,
            0,
            17,
            0,
            32,
            0,
            17,
            0,
            17
        ],
        [
            17,
            0,
            32,
            17,
            0,
            0,
            0,
            0,
            17,
            81,
            17,
            209,
            17,
            28,
            17
        ],
        [
            17,
            205,
            17,
            17,
            209,
            17,
            17,
            17,
            17,
            0,
            0,
            81,
            0,
            0,
            17
        ],
        [
            17,
            0,
            17,
            32,
            0,
            0,
            0,
            33,
            0,
            0,
            17,
            17,
            81,
            17,
            17
        ],
        [
            17,
            0,
            17,
            17,
            17,
            17,
            211,
            17,
            17,
            209,
            17,
            210,
            0,
            210,
            17
        ],
        [
            17,
            213,
            213,
            213,
            22,
            17,
            28,
            32,
            210,
            0,
            17,
            0,
            210,
            0,
            17
        ],
        [
            17,
            17,
            17,
            17,
            17,
            17,
            17,
            17,
            17,
            17,
            17,
            17,
            17,
            17,
            17
        ]
    ],
    "bgmap": [],
    "fgmap": [],
    "downFloor": [
        0,
        7
    ],
    "upFloor": [
        14,
        7
    ],
    "bgm": "forest.mp3",
    "beforeBattle": {},
    "cannotMoveIn": {},
    "autoEvent": {},
    "canFlyFrom": true
}
