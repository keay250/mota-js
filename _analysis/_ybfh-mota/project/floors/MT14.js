main.floors.MT14=
{
    "floorId": "MT14",
    "title": "姆伊森运河·主河道",
    "name": "姆伊森运河",
    "width": 15,
    "height": 15,
    "canFlyTo": true,
    "canUseQuickShop": true,
    "cannotViewMap": false,
    "images": [
        {
            "name": "map014_bg.png",
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
            "text": "进入【姆伊森运河·主河道】！运河波光粼粼，水汽扑面而来！"
        }
    ],
    "eachArrive": [],
    "parallelDo": "",
    "events": {
        "7,12": {
            "trigger": "action",
            "enable": true,
            "data": [
                {
                    "type": "setText",
                    "align": "center"
                },
                "\t[路牌]设定说明之闪避与普攻结算",
                "\t[路牌]每回合实际造成的伤害除了攻速系数外，还存在着命中系数。",
                "\t[路牌]通常情况下初始命中系数为 1，而闪避类技能可大幅削弱命中系数！",
                {
                    "type": "setText",
                    "align": "left"
                }
            ]
        },
        "2,12": {
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
        "8,10": {
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
        "13,12": {
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
        "6,8": {
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
        "0,8": {
            "trigger": "action",
            "enable": true,
            "data": [
                {
                    "type": "playSound",
                    "name": "cursor.mp3"
                },
                "\t[警示标志]前方为【姆伊森运河·下游激流】！水流极为湍急，水流闸门紧闭，暂无法涉水渡河！"
            ]
        }
    },
    "changeFloor": {
        "7,14": {
            "floorId": "MT15",
            "loc": [
                7,
                1
            ],
            "direction": "down"
        },
        "14,9": {
            "floorId": "MT16",
            "loc": [
                1,
                9
            ],
            "direction": "right"
        }
    },
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
            17,
            17,
            17,
            17,
            17,
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
        ],
        [
            17,
            17,
            17,
            17,
            17,
            17,
            17,
            32,
            0,
            217,
            27,
            17,
            17,
            17,
            17
        ],
        [
            0,
            0,
            0,
            218,
            0,
            0,
            33,
            0,
            0,
            0,
            17,
            17,
            17,
            28,
            17
        ],
        [
            17,
            32,
            31,
            17,
            0,
            0,
            0,
            0,
            210,
            0,
            0,
            0,
            215,
            0,
            88
        ],
        [
            17,
            17,
            17,
            17,
            17,
            202,
            17,
            17,
            21,
            210,
            0,
            0,
            209,
            32,
            17
        ],
        [
            17,
            31,
            0,
            31,
            17,
            31,
            31,
            17,
            17,
            17,
            17,
            17,
            17,
            213,
            17
        ],
        [
            17,
            0,
            33,
            0,
            17,
            17,
            203,
            129,
            0,
            214,
            0,
            31,
            17,
            21,
            17
        ],
        [
            17,
            28,
            0,
            28,
            211,
            209,
            0,
            0,
            202,
            17,
            27,
            0,
            17,
            32,
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
            88,
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
        7,
        14
    ],
    "upFloor": [
        14,
        9
    ],
    "bgm": "forest.mp3",
    "canFlyFrom": true
}
