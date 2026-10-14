main.floors.MT10 =
{
    "floorId": "MT10",
    "title": "厄泽城·公会右侧回廊",
    "name": "公会右侧回廊",
    "width": 23,
    "height": 15,
    "canFlyTo": false,
    "canUseQuickShop": true,
    "bgm": "厄泽城事变.mp3",
    "cannotViewMap": false,
    "defaultGround": "ground",
    "images": [
        {
            "name": "map048_bg.png",
            "canvas": "bg",
            "x": 0,
            "y": 0
        }
    ],
    "ratio": 1,
    "upFloor": [
        1,
        8
    ],
    "downFloor": [
        1,
        8
    ],
    "firstArrive": [
        {
            "type": "tip",
            "text": "进入【厄泽城·公会右侧回廊】"
        }
    ],
    "eachArrive": [],
    "parallelDo": "",
    "events": {
        "6,6": {
            "trigger": "action",
            "enable": true,
            "data": [
                {
                    "type": "playSound",
                    "name": "cursor.mp3"
                },
                "\t[贾斯汀,hero]\b[up,hero]……不是这间！"
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
                "\t[贾斯汀,hero]\b[up,hero]……也不是这间！"
            ]
        },
        "16,6": {
            "trigger": "action",
            "enable": true,
            "data": [
                {
                    "type": "if",
                    "condition": "!core.hasFlag('killed_gredy')",
                    "true": [
                        {
                            "type": "playSound",
                            "name": "door.mp3"
                        },
                        "\t[回廊深处]\b[up,16,6]里面传来了少女的低吟和男人粗重的喘息声。",
                        "\t[贾斯汀,hero]\b[up,hero]…………",
                        "\t[贾斯汀,hero]\b[up,hero]……………………",
                        "\t[贾斯汀,hero]\b[up,hero]………………………………！",
                        "\t[格瑞迪,man]\b[up,16,6]咦？！你这家伙，不是死了吗！为什么会出现在这里？！",
                        "\t[格瑞迪,man]\b[up,16,6]你，你杀了门外他们两个？！",
                        "\t[格瑞迪,man]\b[up,16,6]呃……啊啊啊啊！",
                        {
                            "type": "playSound",
                            "name": "attack.mp3"
                        },
                        {
                            "type": "tip",
                            "text": "怒火中烧的贾斯汀一剑斩杀了格瑞迪，踹开了房门！"
                        },
                        {
                            "type": "setValue",
                            "name": "flag:killed_gredy",
                            "value": "true"
                        },
                        {
                            "type": "function",
                            "function": "function() { core.setFlag(\"killed_gredy\", true); }"
                        },
                        {
                            "type": "changeFloor",
                            "floorId": "MT11",
                            "loc": [
                                8,
                                11
                            ],
                            "direction": "up"
                        }
                    ],
                    "false": [
                        {
                            "type": "playSound",
                            "name": "door.mp3"
                        },
                        {
                            "type": "changeFloor",
                            "floorId": "MT11",
                            "loc": [
                                8,
                                11
                            ],
                            "direction": "up"
                        }
                    ]
                }
            ]
        },
        "5,7": {
            "trigger": "action",
            "enable": true,
            "data": [
                {
                    "type": "playSound",
                    "name": "cursor.mp3"
                },
                "\t[巡逻佣兵,man]\b[up,5,7]这里是公会高层的专属休息区，别乱晃悠！"
            ]
        },
        "5,9": {
            "trigger": "action",
            "enable": true,
            "data": [
                {
                    "type": "playSound",
                    "name": "cursor.mp3"
                },
                "\t[巡逻佣兵,man]\b[up,5,9]刚才好像看见格瑞迪少爷往最里面的房间去了……"
            ]
        }
    },
    "changeFloor": {
        "1,8": {
            "floorId": "MT7",
            "loc": [
                22,
                30
            ],
            "direction": "left"
        }
    },
    "beforeBattle": {},
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
            0,
            0,
            0,
            0,
            0,
            17,
            17
        ],
        [
            17,
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
            0,
            0,
            0,
            0,
            0,
            0,
            17,
            17
        ],
        [
            17,
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
            0,
            0,
            0,
            0,
            0,
            0,
            17,
            17
        ],
        [
            17,
            17,
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
            0,
            0,
            0,
            0,
            0,
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
    "cannotMoveIn": {},
    "autoEvent": {}
}
