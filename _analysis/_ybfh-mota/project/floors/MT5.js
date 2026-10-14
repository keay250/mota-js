main.floors.MT5=
{
    "floorId": "MT5",
    "title": "寂静之森外围 5F·厄泽城外",
    "name": "寂静之森外围 5F·厄泽城外",
    "width": 15,
    "height": 15,
    "canFlyTo": true,
    "canUseQuickShop": true,
    "cannotViewMap": false,
    "images": [
        {
            "name": "map013_bg.png",
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
            "text": "进入【寂静之森外围 5F·厄泽城外】！"
        }
    ],
    "eachArrive": [],
    "parallelDo": "",
    "events": {
        "11,11": {
            "trigger": "action",
            "enable": true,
            "data": [
                {
                    "type": "playSound",
                    "name": "recovery.mp3"
                },
                {
                    "type": "setValue",
                    "name": "status:hp",
                    "operator": "=",
                    "value": "status:maxHp"
                },
                {
                    "type": "tip",
                    "text": "在厄泽城小站充分休整，生命值已完全恢复！"
                }
            ]
        },
        "12,6": {
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
        "13,11": {
            "trigger": "action",
            "enable": true,
            "data": [
                {
                    "type": "playSound",
                    "name": "recovery.mp3"
                },
                {
                    "type": "setValue",
                    "name": "status:hp",
                    "operator": "=",
                    "value": "status:maxHp"
                },
                {
                    "type": "tip",
                    "text": "在厄泽城小站充分休整，生命值已完全恢复！"
                }
            ]
        },
        "10,11": {
            "trigger": "action",
            "enable": true,
            "data": [
                {
                    "type": "playSound",
                    "name": "recovery.mp3"
                },
                {
                    "type": "setValue",
                    "name": "status:hp",
                    "operator": "=",
                    "value": "status:maxHp"
                },
                {
                    "type": "tip",
                    "text": "在厄泽城小站充分休整，生命值已完全恢复！"
                }
            ]
        },
        "13,10": {
            "trigger": "action",
            "enable": true,
            "data": [
                {
                    "type": "playSound",
                    "name": "recovery.mp3"
                },
                {
                    "type": "setValue",
                    "name": "status:hp",
                    "operator": "=",
                    "value": "status:maxHp"
                },
                {
                    "type": "tip",
                    "text": "在厄泽城小站充分休整，生命值已完全恢复！"
                }
            ]
        },
        "10,10": {
            "trigger": "action",
            "enable": true,
            "data": [
                {
                    "type": "playSound",
                    "name": "recovery.mp3"
                },
                {
                    "type": "setValue",
                    "name": "status:hp",
                    "operator": "=",
                    "value": "status:maxHp"
                },
                {
                    "type": "tip",
                    "text": "在厄泽城小站充分休整，生命值已完全恢复！"
                }
            ]
        },
        "12,11": {
            "trigger": "action",
            "enable": true,
            "data": [
                {
                    "type": "playSound",
                    "name": "recovery.mp3"
                },
                {
                    "type": "setValue",
                    "name": "status:hp",
                    "operator": "=",
                    "value": "status:maxHp"
                },
                {
                    "type": "tip",
                    "text": "在厄泽城小站充分休整，生命值已完全恢复！"
                }
            ]
        },
        "7,7": {
            "trigger": "action",
            "enable": true,
            "data": [
                {
                    "type": "playSound",
                    "name": "cursor.mp3"
                },
                "\t[贾斯汀]终于走出来了……森林里的雾气开始散去了！",
                "\t[贾斯汀]其他人没有在这里等待吗？也许已经安全回城了也说不定。",
                "\t[贾斯汀]前面好像有人，去问问看！",
                {
                    "type": "hide",
                    "remove": true
                }
            ]
        },
        "11,6": {
            "trigger": "action",
            "enable": true,
            "data": [
                {
                    "type": "playSound",
                    "name": "cursor.mp3"
                },
                "\t[路过的佣兵]你问我在这里干什么？\n好吧，偷偷告诉你，我的祖传信物丢在森林深处了……",
                "\t[路过的佣兵]看到年轻的勇士这么有活力，这把祖传【蓝钥匙】就送给你防身吧！",
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
                    "type": "tip",
                    "text": "获得了【蓝钥匙】！"
                },
                "\t[贾斯汀]多谢大叔！城门就在前方，我得赶紧赶回厄泽城了。"
            ]
        },
        "8,5": {
            "trigger": "action",
            "enable": true,
            "data": [
                {
                    "type": "playSound",
                    "name": "cursor.mp3"
                },
                "\t[路牌]【厄泽城外小站】\n向东穿过最后一道哨卡，即是光辉之城【厄泽城】西城门！"
            ]
        },
        "14,7": {
            "trigger": "action",
            "enable": true,
            "data": [
                {
                    "type": "playSound",
                    "name": "door.mp3"
                },
                "\t[贾斯汀]队长、同伴们，我活着回来了！",
                {
                    "type": "changeFloor",
                    "floorId": "MT6",
                    "loc": [
                        6,
                        72
                    ],
                    "direction": "right"
                }
            ]
        }
    },
    "changeFloor": {
        "0,7": {
            "floorId": "MT4",
            "loc": [
                14,
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
            17,
            17,
            17,
            17,
            17,
            0,
            0,
            0,
            0,
            0,
            0
        ],
        [
            17,
            0,
            0,
            210,
            0,
            0,
            17,
            17,
            0,
            0,
            0,
            0,
            0,
            0,
            0
        ],
        [
            17,
            81,
            17,
            17,
            17,
            0,
            17,
            17,
            0,
            0,
            0,
            0,
            0,
            0,
            0
        ],
        [
            17,
            27,
            31,
            28,
            17,
            213,
            17,
            17,
            0,
            0,
            0,
            0,
            0,
            0,
            0
        ],
        [
            17,
            17,
            218,
            17,
            17,
            0,
            17,
            17,
            0,
            0,
            0,
            17,
            17,
            0,
            0
        ],
        [
            17,
            32,
            0,
            209,
            0,
            0,
            17,
            17,
            129,
            0,
            0,
            17,
            17,
            0,
            0
        ],
        [
            17,
            0,
            0,
            17,
            17,
            17,
            17,
            17,
            0,
            0,
            34,
            128,
            21,
            0,
            0
        ],
        [
            88,
            0,
            81,
            213,
            0,
            214,
            81,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            89
        ],
        [
            17,
            0,
            17,
            0,
            31,
            0,
            17,
            17,
            0,
            0,
            28,
            0,
            27,
            0,
            0
        ],
        [
            17,
            215,
            17,
            17,
            17,
            217,
            17,
            17,
            0,
            0,
            0,
            0,
            0,
            0,
            0
        ],
        [
            17,
            0,
            31,
            17,
            31,
            0,
            17,
            17,
            0,
            0,
            90,
            0,
            0,
            90,
            0
        ],
        [
            17,
            0,
            0,
            17,
            0,
            0,
            17,
            17,
            0,
            0,
            90,
            90,
            90,
            90,
            0
        ],
        [
            17,
            214,
            17,
            17,
            17,
            215,
            17,
            17,
            0,
            0,
            0,
            0,
            0,
            0,
            0
        ],
        [
            17,
            0,
            31,
            0,
            31,
            0,
            17,
            17,
            0,
            0,
            0,
            0,
            0,
            0,
            0
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
            0,
            0,
            0,
            0,
            0,
            0
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
    "bgm": "厄泽城.mp3",
    "beforeBattle": {},
    "cannotMoveIn": {},
    "autoEvent": {},
    "canFlyFrom": true
}
