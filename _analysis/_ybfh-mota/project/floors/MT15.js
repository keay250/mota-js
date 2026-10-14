main.floors.MT15 =
{
    "floorId": "MT15",
    "title": "寂静之森外围·密林深径",
    "name": "寂静之森外围·密林深径",
    "width": 15,
    "height": 15,
    "canFlyTo": true,
    "canUseQuickShop": true,
    "cannotViewMap": false,
    "images": [
        {
            "name": "map011_bg.png",
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
            "text": "进入【寂静之森外围·密林深径】！四周传来隐秘的宝物光芒！"
        }
    ],
    "eachArrive": [],
    "parallelDo": "",
    "events": {
        "11,1": {
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
        "5,12": {
            "trigger": "action",
            "enable": true,
            "data": [
                {
                    "type": "playSound",
                    "name": "recovery.mp3"
                },
                {
                    "type": "function",
                    "function": "function() {\n    core.addMaxHp(20);\n}"
                },
                {
                    "type": "tip",
                    "text": "获得生命水晶，生命上限 +20！"
                },
                {
                    "type": "hide",
                    "remove": true
                }
            ]
        },
        "10,10": {
            "trigger": "action",
            "enable": true,
            "data": [
                {
                    "type": "playSound",
                    "name": "item.mp3"
                },
                {
                    "type": "setText",
                    "align": "center"
                },
                "\t[宝箱]打开了密林遗失的宝箱！",
                "\t[系统]获得了【森林长剑】！攻击力 +15！",
                {
                    "type": "setText",
                    "align": "left"
                },
                {
                    "type": "setValue",
                    "name": "status:atk",
                    "operator": "+=",
                    "value": "15"
                },
                {
                    "type": "hide",
                    "remove": true
                }
            ]
        },
        "9,5": {
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
        "3,8": {
            "trigger": "action",
            "enable": true,
            "data": [
                {
                    "type": "playSound",
                    "name": "recovery.mp3"
                },
                {
                    "type": "function",
                    "function": "function() {\n    core.addMaxHp(20);\n}"
                },
                {
                    "type": "tip",
                    "text": "获得生命水晶，生命上限 +20！"
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
        "10,9": {
            "trigger": "action",
            "enable": true,
            "data": [
                {
                    "type": "setText",
                    "align": "center"
                },
                "\t[路牌]设定说明之生命回复与伤害结算",
                "\t[路牌]与毒素腐蚀等固定扣血不同，回复量根据角色当前状态比例结算。",
                "\t[路牌]另外，怪物的最终战斗结算伤害可为负数，合理搭配护甲与减伤可无伤刷怪！",
                {
                    "type": "setText",
                    "align": "left"
                }
            ]
        },
        "4,3": {
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
        }
    },
    "changeFloor": {
        "11,14": {
            "floorId": "MT3",
            "loc": [
                9,
                1
            ],
            "direction": "down"
        }
    },
    "map": [
        [
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0
        ],
        [
            0,
            27,
            0,
            0,
            31,
            0,
            0,
            210,
            0,
            31,
            0,
            21,
            0,
            28,
            0
        ],
        [
            0,
            0,
            209,
            81,
            0,
            0,
            0,
            81,
            0,
            0,
            0,
            0,
            0,
            213,
            0
        ],
        [
            0,
            28,
            0,
            0,
            21,
            27,
            0,
            0,
            202,
            0,
            209,
            0,
            0,
            0,
            0
        ],
        [
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            203,
            0,
            0,
            0,
            81,
            0,
            0,
            0
        ],
        [
            0,
            0,
            201,
            0,
            0,
            0,
            0,
            31,
            0,
            21,
            203,
            0,
            202,
            32,
            0
        ],
        [
            0,
            0,
            0,
            0,
            0,
            0,
            204,
            0,
            0,
            0,
            0,
            205,
            0,
            0,
            0
        ],
        [
            0,
            21,
            0,
            32,
            210,
            0,
            0,
            204,
            0,
            0,
            0,
            0,
            0,
            0,
            0
        ],
        [
            0,
            0,
            81,
            33,
            0,
            0,
            0,
            27,
            0,
            0,
            0,
            0,
            0,
            0,
            0
        ],
        [
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            31,
            129,
            31,
            0,
            203,
            0
        ],
        [
            0,
            31,
            0,
            0,
            0,
            205,
            0,
            0,
            0,
            0,
            38,
            0,
            0,
            0,
            0
        ],
        [
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            31,
            0,
            31,
            0,
            0,
            0
        ],
        [
            0,
            27,
            0,
            209,
            81,
            33,
            0,
            0,
            0,
            0,
            213,
            0,
            0,
            0,
            0
        ],
        [
            0,
            209,
            81,
            28,
            0,
            209,
            81,
            205,
            0,
            0,
            0,
            0,
            201,
            0,
            0
        ],
        [
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            88,
            0,
            0,
            0
        ]
    ],
    "bgmap": [],
    "fgmap": [],
    "downFloor": [
        11,
        14
    ],
    "upFloor": [
        11,
        1
    ],
    "bgm": "forest.mp3",
    "canFlyFrom": true,
    "afterBattle": {},
    "afterGetItem": {},
    "afterOpenDoor": {},
    "beforeBattle": {},
    "cannotMoveIn": {},
    "autoEvent": {}
}
