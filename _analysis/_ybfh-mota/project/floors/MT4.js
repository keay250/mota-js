main.floors.MT4 =
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
    "eachArrive": [
        {
            "type": "if",
            "condition": "core.hasFlag('mt4_doors_opened') || !core.hasMonsterInArea('MT4', 11, 12, 13, 13) || !core.hasEnemyLeft(null, 'MT4')",
            "true": [
                {
                    "type": "function",
                    "function": "function() {\n    core.setFlag('mt4_doors_opened', true);\n    [[7, 4], [5, 1], [9, 1]].forEach(function(loc) {\n        var b = core.getBlock(loc[0], loc[1]);\n        if (b && (b.number == 85 || (b.event && b.event.id == 'specialDoor'))) {\n            core.removeBlock(loc[0], loc[1]);\n        }\n    });\n}"
                }
            ]
        }
    ],
    "parallelDo": "",
    "events": {
        "7,4": {
            "trigger": "action",
            "enable": true,
            "data": [
                {
                    "type": "if",
                    "condition": "!core.hasMonsterInArea('MT4', 11, 12, 13, 13) || !core.hasEnemyLeft(null, 'MT4')",
                    "true": [
                        {
                            "type": "setValue",
                            "name": "flag:mt4_doors_opened",
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
                                7,
                                4
                            ],
                            "needKey": false,
                            "async": true
                        },
                        {
                            "type": "openDoor",
                            "loc": [
                                5,
                                1
                            ],
                            "needKey": false,
                            "async": true
                        },
                        {
                            "type": "openDoor",
                            "loc": [
                                9,
                                1
                            ],
                            "needKey": false,
                            "async": true
                        },
                        {
                            "type": "waitAsync"
                        }
                    ],
                    "false": [
                        {
                            "type": "show",
                            "text": "\t[机关门]一道沉重冰冷的特殊铁门紧紧锁着……\n隐约能感觉到右下角守护怪物的魔力牵制，\n击败它们或许就能解除机关！"
                        }
                    ]
                }
            ]
        },
        "5,1": {
            "trigger": "action",
            "enable": true,
            "data": [
                {
                    "type": "if",
                    "condition": "!core.hasMonsterInArea('MT4', 11, 12, 13, 13) || !core.hasEnemyLeft(null, 'MT4')",
                    "true": [
                        {
                            "type": "setValue",
                            "name": "flag:mt4_doors_opened",
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
                                7,
                                4
                            ],
                            "needKey": false,
                            "async": true
                        },
                        {
                            "type": "openDoor",
                            "loc": [
                                5,
                                1
                            ],
                            "needKey": false,
                            "async": true
                        },
                        {
                            "type": "openDoor",
                            "loc": [
                                9,
                                1
                            ],
                            "needKey": false,
                            "async": true
                        },
                        {
                            "type": "waitAsync"
                        }
                    ],
                    "false": [
                        {
                            "type": "show",
                            "text": "\t[机关门]一道沉重冰冷的特殊铁门紧紧锁着……\n隐约能感觉到右下角守护怪物的魔力牵制，\n击败它们或许就能解除机关！"
                        }
                    ]
                }
            ]
        },
        "9,1": {
            "trigger": "action",
            "enable": true,
            "data": [
                {
                    "type": "if",
                    "condition": "!core.hasMonsterInArea('MT4', 11, 12, 13, 13) || !core.hasEnemyLeft(null, 'MT4')",
                    "true": [
                        {
                            "type": "setValue",
                            "name": "flag:mt4_doors_opened",
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
                                7,
                                4
                            ],
                            "needKey": false,
                            "async": true
                        },
                        {
                            "type": "openDoor",
                            "loc": [
                                5,
                                1
                            ],
                            "needKey": false,
                            "async": true
                        },
                        {
                            "type": "openDoor",
                            "loc": [
                                9,
                                1
                            ],
                            "needKey": false,
                            "async": true
                        },
                        {
                            "type": "waitAsync"
                        }
                    ],
                    "false": [
                        {
                            "type": "show",
                            "text": "\t[机关门]一道沉重冰冷的特殊铁门紧紧锁着……\n隐约能感觉到右下角守护怪物的魔力牵制，\n击败它们或许就能解除机关！"
                        }
                    ]
                }
            ]
        },
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
        "7,0": {
            "floorId": "MT16",
            "loc": [
                7,
                13
            ],
            "direction": "up"
        },
        "0,7": {
            "floorId": "MT3",
            "loc": [
                13,
                5
            ],
            "direction": "left"
        },
        "14,7": {
            "floorId": "MT5",
            "loc": [
                1,
                7
            ],
            "direction": "right"
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
            87,
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
            214,
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
            0,
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
    "autoEvent": {
        "0,0": [
            {
                "condition": "(!core.hasFlag('mt4_doors_opened')) && (!core.hasMonsterInArea('MT4', 11, 12, 13, 13) || !core.hasEnemyLeft(null, 'MT4'))",
                "currentFloor": true,
                "priority": 0,
                "delayExecute": false,
                "multiExecute": false,
                "data": [
                    {
                        "type": "setValue",
                        "name": "flag:mt4_doors_opened",
                        "value": "true"
                    },
                    {
                        "type": "playSound",
                        "name": "door.mp3"
                    },
                    {
                        "type": "tip",
                        "text": "【机关门已开启！】通往森林深处的铁门打开了！"
                    },
                    {
                        "type": "openDoor",
                        "loc": [
                            7,
                            4
                        ],
                        "needKey": false,
                        "async": true
                    },
                    {
                        "type": "openDoor",
                        "loc": [
                            5,
                            1
                        ],
                        "needKey": false,
                        "async": true
                    },
                    {
                        "type": "openDoor",
                        "loc": [
                            9,
                            1
                        ],
                        "needKey": false,
                        "async": true
                    },
                    {
                        "type": "waitAsync"
                    }
                ]
            }
        ]
    },
    "canFlyFrom": true
}
