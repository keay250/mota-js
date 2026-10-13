main.floors.MT2=
{
    "floorId": "MT2",
    "title": "寂静之森外围 2F",
    "name": "寂静之森外围 2F",
    "width": 15,
    "height": 15,
    "canFlyTo": true,
    "canUseQuickShop": true,
    "cannotViewMap": false,
    "images": [
        {
            "name": "map009_bg.png",
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
            "text": "进入【寂静之森外围 2F】！"
        }
    ],
    "eachArrive": [],
    "parallelDo": "",
    "events": {
        "6,13": {
            "trigger": "action",
            "enable": true,
            "data": [
                {
                    "type": "if",
                    "condition": "(status:hpmax - status:hp < 50)",
                    "true": [
                        {
                            "type": "setText",
                            "align": "center"
                        },
                        "\t[说明]生命上限不足，已损失血量少于 50 点。\n为避免浪费，待需要时再来饮用吧。",
                        {
                            "type": "setText",
                            "align": "left"
                        }
                    ],
                    "false": [
                        {
                            "type": "playSound",
                            "name": "recovery.mp3"
                        },
                        {
                            "type": "setValue",
                            "name": "status:hp",
                            "operator": "+=",
                            "value": "50"
                        },
                        {
                            "type": "hide",
                            "remove": true
                        }
                    ]
                }
            ]
        },
        "1,8": {
            "trigger": "action",
            "enable": true,
            "data": [
                {
                    "type": "if",
                    "condition": "(status:hpmax - status:hp < 100)",
                    "true": [
                        {
                            "type": "setText",
                            "align": "center"
                        },
                        "\t[说明]生命上限不足，已损失血量少于 100 点。\n为避免浪费，待需要时再来饮用吧。",
                        {
                            "type": "setText",
                            "align": "left"
                        }
                    ],
                    "false": [
                        {
                            "type": "playSound",
                            "name": "recovery.mp3"
                        },
                        {
                            "type": "setValue",
                            "name": "status:hp",
                            "operator": "+=",
                            "value": "100"
                        },
                        {
                            "type": "hide",
                            "remove": true
                        }
                    ]
                }
            ]
        },
        "1,9": {
            "trigger": "action",
            "enable": true,
            "data": [
                {
                    "type": "if",
                    "condition": "(status:hpmax - status:hp < 50)",
                    "true": [
                        {
                            "type": "setText",
                            "align": "center"
                        },
                        "\t[说明]生命上限不足，已损失血量少于 50 点。\n为避免浪费，待需要时再来饮用吧。",
                        {
                            "type": "setText",
                            "align": "left"
                        }
                    ],
                    "false": [
                        {
                            "type": "playSound",
                            "name": "recovery.mp3"
                        },
                        {
                            "type": "setValue",
                            "name": "status:hp",
                            "operator": "+=",
                            "value": "50"
                        },
                        {
                            "type": "hide",
                            "remove": true
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
                    "type": "playSound",
                    "name": "recovery.mp3"
                },
                {
                    "type": "setValue",
                    "name": "status:hpmax",
                    "operator": "+=",
                    "value": "20"
                },
                {
                    "type": "setValue",
                    "name": "status:hp",
                    "operator": "+=",
                    "value": "20"
                },
                {
                    "type": "tip",
                    "text": "生命上限 +20！当前生命值随比例同步提升！"
                },
                {
                    "type": "hide",
                    "remove": true
                }
            ]
        },
        "8,1": {
            "trigger": "action",
            "enable": true,
            "data": [
                {
                    "type": "if",
                    "condition": "(status:hpmax - status:hp < 50)",
                    "true": [
                        {
                            "type": "setText",
                            "align": "center"
                        },
                        "\t[说明]生命上限不足，已损失血量少于 50 点。\n为避免浪费，待需要时再来饮用吧。",
                        {
                            "type": "setText",
                            "align": "left"
                        }
                    ],
                    "false": [
                        {
                            "type": "playSound",
                            "name": "recovery.mp3"
                        },
                        {
                            "type": "setValue",
                            "name": "status:hp",
                            "operator": "+=",
                            "value": "50"
                        },
                        {
                            "type": "hide",
                            "remove": true
                        }
                    ]
                }
            ]
        },
        "9,3": {
            "trigger": "action",
            "enable": true,
            "data": [
                {
                    "type": "if",
                    "condition": "(status:hpmax - status:hp < 100)",
                    "true": [
                        {
                            "type": "setText",
                            "align": "center"
                        },
                        "\t[说明]生命上限不足，已损失血量少于 100 点。\n为避免浪费，待需要时再来饮用吧。",
                        {
                            "type": "setText",
                            "align": "left"
                        }
                    ],
                    "false": [
                        {
                            "type": "playSound",
                            "name": "recovery.mp3"
                        },
                        {
                            "type": "setValue",
                            "name": "status:hp",
                            "operator": "+=",
                            "value": "100"
                        },
                        {
                            "type": "hide",
                            "remove": true
                        }
                    ]
                }
            ]
        },
        "13,10": {
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
        "2,3": {
            "trigger": "action",
            "enable": true,
            "data": [
                {
                    "type": "playSound",
                    "name": "recovery.mp3"
                },
                {
                    "type": "setValue",
                    "name": "status:hpmax",
                    "operator": "+=",
                    "value": "20"
                },
                {
                    "type": "setValue",
                    "name": "status:hp",
                    "operator": "+=",
                    "value": "20"
                },
                {
                    "type": "tip",
                    "text": "生命上限 +20！当前生命值随比例同步提升！"
                },
                {
                    "type": "hide",
                    "remove": true
                }
            ]
        },
        "1,13": {
            "trigger": "action",
            "enable": true,
            "data": [
                {
                    "type": "if",
                    "condition": "(status:hpmax - status:hp < 50)",
                    "true": [
                        {
                            "type": "setText",
                            "align": "center"
                        },
                        "\t[说明]生命上限不足，已损失血量少于 50 点。\n为避免浪费，待需要时再来饮用吧。",
                        {
                            "type": "setText",
                            "align": "left"
                        }
                    ],
                    "false": [
                        {
                            "type": "playSound",
                            "name": "recovery.mp3"
                        },
                        {
                            "type": "setValue",
                            "name": "status:hp",
                            "operator": "+=",
                            "value": "50"
                        },
                        {
                            "type": "hide",
                            "remove": true
                        }
                    ]
                }
            ]
        },
        "10,9": {
            "trigger": "action",
            "enable": true,
            "data": [
                {
                    "type": "if",
                    "condition": "(status:hpmax - status:hp < 50)",
                    "true": [
                        {
                            "type": "setText",
                            "align": "center"
                        },
                        "\t[说明]生命上限不足，已损失血量少于 50 点。\n为避免浪费，待需要时再来饮用吧。",
                        {
                            "type": "setText",
                            "align": "left"
                        }
                    ],
                    "false": [
                        {
                            "type": "playSound",
                            "name": "recovery.mp3"
                        },
                        {
                            "type": "setValue",
                            "name": "status:hp",
                            "operator": "+=",
                            "value": "50"
                        },
                        {
                            "type": "hide",
                            "remove": true
                        }
                    ]
                }
            ]
        },
        "5,3": {
            "trigger": "action",
            "enable": true,
            "data": [
                {
                    "type": "if",
                    "condition": "(status:hpmax - status:hp < 50)",
                    "true": [
                        {
                            "type": "setText",
                            "align": "center"
                        },
                        "\t[说明]生命上限不足，已损失血量少于 50 点。\n为避免浪费，待需要时再来饮用吧。",
                        {
                            "type": "setText",
                            "align": "left"
                        }
                    ],
                    "false": [
                        {
                            "type": "playSound",
                            "name": "recovery.mp3"
                        },
                        {
                            "type": "setValue",
                            "name": "status:hp",
                            "operator": "+=",
                            "value": "50"
                        },
                        {
                            "type": "hide",
                            "remove": true
                        }
                    ]
                }
            ]
        },
        "6,10": {
            "trigger": "action",
            "enable": true,
            "data": [
                {
                    "type": "if",
                    "condition": "(status:hpmax - status:hp < 50)",
                    "true": [
                        {
                            "type": "setText",
                            "align": "center"
                        },
                        "\t[说明]生命上限不足，已损失血量少于 50 点。\n为避免浪费，待需要时再来饮用吧。",
                        {
                            "type": "setText",
                            "align": "left"
                        }
                    ],
                    "false": [
                        {
                            "type": "playSound",
                            "name": "recovery.mp3"
                        },
                        {
                            "type": "setValue",
                            "name": "status:hp",
                            "operator": "+=",
                            "value": "50"
                        },
                        {
                            "type": "hide",
                            "remove": true
                        }
                    ]
                }
            ]
        },
        "12,2": {
            "trigger": "action",
            "enable": true,
            "data": [
                {
                    "type": "if",
                    "condition": "(status:hpmax - status:hp < 50)",
                    "true": [
                        {
                            "type": "setText",
                            "align": "center"
                        },
                        "\t[说明]生命上限不足，已损失血量少于 50 点。\n为避免浪费，待需要时再来饮用吧。",
                        {
                            "type": "setText",
                            "align": "left"
                        }
                    ],
                    "false": [
                        {
                            "type": "playSound",
                            "name": "recovery.mp3"
                        },
                        {
                            "type": "setValue",
                            "name": "status:hp",
                            "operator": "+=",
                            "value": "50"
                        },
                        {
                            "type": "hide",
                            "remove": true
                        }
                    ]
                }
            ]
        }
    },
    "changeFloor": {
        "2,14": {
            "floorId": "MT1",
            "stair": "upFloor"
        },
        "12,0": {
            "floorId": ":next",
            "stair": "downFloor"
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
            17,
            17,
            17,
            87,
            17,
            17
        ],
        [
            17,
            17,
            17,
            17,
            28,
            0,
            209,
            0,
            31,
            33,
            17,
            17,
            0,
            27,
            17
        ],
        [
            17,
            17,
            17,
            17,
            81,
            17,
            17,
            205,
            17,
            17,
            17,
            17,
            31,
            0,
            17
        ],
        [
            17,
            17,
            33,
            17,
            204,
            31,
            17,
            0,
            17,
            32,
            17,
            17,
            17,
            0,
            17
        ],
        [
            17,
            0,
            0,
            17,
            0,
            0,
            0,
            203,
            0,
            81,
            0,
            17,
            17,
            0,
            17
        ],
        [
            17,
            201,
            17,
            17,
            17,
            17,
            17,
            0,
            17,
            17,
            205,
            0,
            17,
            202,
            17
        ],
        [
            17,
            0,
            0,
            204,
            17,
            0,
            0,
            0,
            17,
            17,
            17,
            0,
            204,
            0,
            17
        ],
        [
            17,
            17,
            17,
            0,
            0,
            201,
            0,
            17,
            17,
            17,
            17,
            17,
            81,
            17,
            17
        ],
        [
            17,
            32,
            17,
            17,
            17,
            0,
            17,
            17,
            17,
            17,
            17,
            17,
            0,
            17,
            17
        ],
        [
            17,
            31,
            0,
            81,
            0,
            0,
            0,
            204,
            0,
            17,
            31,
            0,
            0,
            202,
            17
        ],
        [
            17,
            17,
            17,
            0,
            203,
            0,
            31,
            17,
            0,
            0,
            0,
            0,
            202,
            21,
            17
        ],
        [
            17,
            0,
            201,
            0,
            17,
            81,
            17,
            17,
            205,
            17,
            17,
            0,
            17,
            17,
            17
        ],
        [
            17,
            0,
            0,
            17,
            17,
            204,
            17,
            17,
            0,
            203,
            204,
            0,
            17,
            17,
            17
        ],
        [
            17,
            31,
            0,
            17,
            27,
            0,
            31,
            17,
            27,
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
            17,
            17
        ]
    ],
    "bgmap": [],
    "fgmap": [],
    "downFloor": [
        2,
        14
    ],
    "upFloor": [
        12,
        0
    ],
    "bgm": "forest.mp3",
    "beforeBattle": {},
    "cannotMoveIn": {},
    "autoEvent": {},
    "canFlyFrom": true
}
