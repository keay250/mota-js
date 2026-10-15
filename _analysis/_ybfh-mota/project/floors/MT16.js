main.floors.MT16=
{
    "floorId": "MT16",
    "title": "姆伊森运河·支流前哨",
    "name": "姆伊森运河·支流前哨",
    "width": 15,
    "height": 15,
    "canFlyTo": true,
    "canUseQuickShop": true,
    "cannotViewMap": false,
    "images": [
        {
            "name": "map016_bg.png",
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
            "text": "进入【姆伊森运河·支流前哨】！前方水流隐约可见！"
        }
    ],
    "eachArrive": [],
    "parallelDo": "",
    "events": {
        "7,11": {
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
                "\t[宝箱]打开了古代遗物宝箱！",
                "\t[系统]获得了【精钢长剑】！已放入装备库并自动佩戴（攻击力 +15）！",
                {
                    "type": "setText",
                    "align": "left"
                },
                {
                    "type": "function",
                    "function": "function() {\n    core.addItem('steelSword', 1);\n    core.loadEquip('steelSword');\n}"
                },
                {
                    "type": "hide",
                    "remove": true
                }
            ]
        }
    },
    "changeFloor": {
        "7,14": {
            "floorId": "MT4",
            "loc": [
                7,
                1
            ],
            "direction": "down"
        },
        "0,9": {
            "floorId": "MT14",
            "loc": [
                13,
                9
            ],
            "direction": "left"
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
            0,
            27,
            0,
            17,
            17,
            17,
            17,
            17,
            17
        ],
        [
            88,
            0,
            17,
            17,
            0,
            0,
            214,
            0,
            214,
            0,
            0,
            17,
            17,
            17,
            17
        ],
        [
            17,
            210,
            0,
            0,
            209,
            17,
            17,
            17,
            17,
            17,
            213,
            0,
            0,
            17,
            17
        ],
        [
            17,
            0,
            31,
            17,
            17,
            17,
            31,
            38,
            31,
            17,
            17,
            17,
            32,
            0,
            17
        ],
        [
            17,
            211,
            17,
            17,
            31,
            17,
            17,
            85,
            17,
            17,
            32,
            17,
            17,
            217,
            17
        ],
        [
            17,
            0,
            215,
            27,
            31,
            17,
            201,
            0,
            201,
            17,
            32,
            28,
            218,
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
        0,
        9
    ],
    "bgm": "forest.mp3",
    "canFlyFrom": true
}
