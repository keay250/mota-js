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
        }
    },
    "changeFloor": {
        "2,14": {
                "floorId": "MT1",
                "loc": [
                        12,
                        1
                ],
                "direction": "down"
        },
        "12,0": {
                "floorId": "MT3",
                "loc": [
                        3,
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
