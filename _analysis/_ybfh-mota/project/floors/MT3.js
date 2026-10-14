main.floors.MT3 =
{
    "floorId": "MT3",
    "title": "寂静之森外围 3F",
    "name": "寂静之森外围 3F",
    "width": 15,
    "height": 15,
    "canFlyTo": true,
    "canUseQuickShop": true,
    "cannotViewMap": false,
    "images": [
        {
            "name": "map010_bg.png",
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
            "text": "进入【寂静之森外围 3F】！"
        }
    ],
    "eachArrive": [
        {
            "type": "if",
            "condition": "core.hasFlag('mt3_doors_opened') || !core.hasMonsterInArea('MT3', 1, 7, 5, 11) || !core.hasEnemyLeft(null, 'MT3')",
            "true": [
                {
                    "type": "function",
                    "function": "function() {\n    core.setFlag('mt3_doors_opened', true);\n    var b = core.getBlock(2, 6);\n    if (b && (b.number == 85 || (b.event && b.event.id == 'specialDoor'))) {\n        core.removeBlock(2, 6);\n    }\n}"
                }
            ]
        }
    ],
    "parallelDo": "",
    "events": {
        "2,6": {
            "trigger": "action",
            "enable": true,
            "data": [
                {
                    "type": "if",
                    "condition": "!core.hasMonsterInArea('MT3', 1, 7, 5, 11) || !core.hasEnemyLeft(null, 'MT3')",
                    "true": [
                        {
                            "type": "setValue",
                            "name": "flag:mt3_doors_opened",
                            "value": "true"
                        },
                        {
                            "type": "playSound",
                            "name": "door.mp3"
                        },
                        {
                            "type": "tip",
                            "text": "【机关门已开启！】机关解除了！"
                        },
                        {
                            "type": "openDoor",
                            "loc": [
                                2,
                                6
                            ],
                            "needKey": false,
                            "async": false
                        }
                    ],
                    "false": [
                        {
                            "type": "show",
                            "text": "\t[机关门]一道沉重冰冷的特殊铁门紧紧锁着……\n隐约能感觉到左下方守护怪物的魔力牵制，\n击败它们或许就能解除机关！"
                        }
                    ]
                }
            ]
        },
        "9,11": {
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
        "11,2": {
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
        "9,3": {
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
        "11,12": {
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
                    "name": "cursor.mp3"
                },
                "\t[路牌]↑ 姆依森运河\n→ 厄泽城\n←↓ 寂静之森深处",
                "\t[贾斯汀]太好了，看到路牌了，小站应该就在前面。\n只要到了小站就能安全回城了。"
            ]
        },
        "0,3": {
            "trigger": "action",
            "enable": true,
            "data": [
                {
                    "type": "playSound",
                    "name": "cursor.mp3"
                },
                "\t[山壁塌方]通往密林更深处的哥布林洞穴已被巨石阻塞，前方道路暂未开放。"
            ]
        }
    },
    "changeFloor": {
        "3,14": {
            "floorId": "MT2",
            "loc": [
                12,
                1
            ],
            "direction": "down"
        },
        "14,5": {
            "floorId": "MT4",
            "loc": [
                1,
                7
            ],
            "direction": "right"
        },
        "9,0": {
            "floorId": "MT15",
            "loc": [
                11,
                13
            ],
            "direction": "up"
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
            17,
            17,
            17,
            17,
            17
        ],
        [
            17,
            0,
            31,
            0,
            31,
            17,
            0,
            203,
            0,
            0,
            205,
            0,
            17,
            31,
            17
        ],
        [
            17,
            31,
            17,
            17,
            17,
            17,
            0,
            17,
            17,
            17,
            17,
            21,
            0,
            203,
            17
        ],
        [
            17,
            0,
            83,
            0,
            31,
            17,
            0,
            17,
            31,
            21,
            17,
            17,
            202,
            17,
            17
        ],
        [
            17,
            17,
            17,
            0,
            17,
            17,
            0,
            17,
            17,
            210,
            27,
            17,
            0,
            32,
            17
        ],
        [
            17,
            31,
            0,
            0,
            17,
            32,
            204,
            0,
            17,
            81,
            17,
            17,
            202,
            0,
            87
        ],
        [
            17,
            17,
            85,
            17,
            17,
            17,
            17,
            0,
            31,
            0,
            0,
            17,
            0,
            28,
            17
        ],
        [
            17,
            209,
            0,
            0,
            0,
            209,
            17,
            201,
            17,
            17,
            202,
            17,
            81,
            17,
            17
        ],
        [
            17,
            0,
            209,
            0,
            209,
            0,
            129,
            0,
            17,
            0,
            31,
            0,
            205,
            31,
            17
        ],
        [
            17,
            0,
            0,
            211,
            0,
            32,
            202,
            0,
            81,
            205,
            0,
            27,
            17,
            17,
            17
        ],
        [
            17,
            0,
            209,
            0,
            209,
            0,
            17,
            203,
            17,
            28,
            17,
            0,
            17,
            31,
            17
        ],
        [
            17,
            209,
            0,
            0,
            0,
            209,
            17,
            0,
            17,
            21,
            17,
            202,
            81,
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
            0,
            17,
            17,
            17,
            21,
            17,
            17,
            17
        ],
        [
            17,
            17,
            17,
            0,
            0,
            0,
            201,
            0,
            204,
            0,
            31,
            0,
            81,
            33,
            17
        ],
        [
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
        3,
        14
    ],
    "upFloor": [
        14,
        5
    ],
    "bgm": "forest.mp3",
    "beforeBattle": {},
    "cannotMoveIn": {},
    "autoEvent": {
        "0,0": [
            {
                "condition": "(!core.hasFlag('mt3_doors_opened')) && (!core.hasMonsterInArea('MT3', 1, 7, 5, 11) || !core.hasEnemyLeft(null, 'MT3'))",
                "currentFloor": true,
                "priority": 0,
                "delayExecute": false,
                "multiExecute": false,
                "data": [
                    {
                        "type": "setValue",
                        "name": "flag:mt3_doors_opened",
                        "value": "true"
                    },
                    {
                        "type": "playSound",
                        "name": "door.mp3"
                    },
                    {
                        "type": "tip",
                        "text": "【机关门已开启！】机关解除了！"
                    },
                    {
                        "type": "openDoor",
                        "loc": [
                            2,
                            6
                        ],
                        "needKey": false,
                        "async": false
                    }
                ]
            }
        ]
    },
    "canFlyFrom": true
}
