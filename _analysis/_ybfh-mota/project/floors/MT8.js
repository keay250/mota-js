main.floors.MT8 =
{
    "floorId": "MT8",
    "title": "厄泽城·装备商店",
    "name": "装备商店",
    "width": 15,
    "height": 17,
    "canFlyTo": false,
    "canUseQuickShop": true,
    "bgm": "厄泽城.mp3",
    "cannotViewMap": false,
    "defaultGround": "ground",
    "images": [
        {
            "name": "map018_bg.png",
            "canvas": "bg",
            "x": 0,
            "y": 0
        }
    ],
    "ratio": 1,
    "upFloor": [
        5,
        15
    ],
    "downFloor": [
        5,
        15
    ],
    "firstArrive": [
        {
            "type": "tip",
            "text": "进入【厄泽城·装备商店】"
        }
    ],
    "eachArrive": [],
    "parallelDo": "",
    "events": {
        "5,16": {
            "trigger": "action",
            "enable": true,
            "data": [
                {
                    "type": "playSound",
                    "name": "door.mp3"
                },
                {
                    "type": "changeFloor",
                    "floorId": "MT6",
                    "loc": [
                        68,
                        17
                    ],
                    "direction": "down"
                }
            ]
        },
        "7,8": {
            "trigger": "action",
            "enable": true,
            "data": [
                {
                    "type": "playSound",
                    "name": "cursor.mp3"
                },
                "\t[店员,shopkeeper]\b[up,7,8]小哥，来选个装备吧！保证物美价廉，实用不易磨损！",
                {
                    "type": "choices",
                    "text": "\t[店员,shopkeeper]你想挑选哪件装备？",
                    "choices": [
                        {
                            "text": "佣兵短剑 (30 G) - 攻击力 +15",
                            "action": [
                                {
                                    "type": "if",
                                    "condition": "core.getStatus('money') >= 30",
                                    "true": [
                                        {
                                            "type": "setValue",
                                            "name": "status:money",
                                            "operator": "-=",
                                            "value": "30"
                                        },
                                        {
                                            "type": "getItem",
                                            "name": "mercenarySword"
                                        },
                                        {
                                            "type": "playSound",
                                            "name": "item.mp3"
                                        },
                                        "\t[店员,shopkeeper]\b[up,7,8]多谢惠顾！这把短剑虽然轻便，但非常趁手！"
                                    ],
                                    "false": [
                                        "\t[店员,shopkeeper]\b[up,7,8]小哥，你带的金币好像不够 30G 呢……"
                                    ]
                                }
                            ]
                        },
                        {
                            "text": "劣质皮甲 (20 G) - 防御 +3, 生命 +50",
                            "action": [
                                {
                                    "type": "if",
                                    "condition": "core.getStatus('money') >= 20",
                                    "true": [
                                        {
                                            "type": "setValue",
                                            "name": "status:money",
                                            "operator": "-=",
                                            "value": "20"
                                        },
                                        {
                                            "type": "getItem",
                                            "name": "poorLeather"
                                        },
                                        {
                                            "type": "playSound",
                                            "name": "item.mp3"
                                        },
                                        "\t[店员,shopkeeper]\b[up,7,8]多谢惠顾！好歹能抵挡野兽的撕咬！"
                                    ],
                                    "false": [
                                        "\t[店员,shopkeeper]\b[up,7,8]小哥，金币不够 20G 哦。"
                                    ]
                                }
                            ]
                        },
                        {
                            "text": "轻骑护手 (120 G) - 攻击速度与敏捷 +15",
                            "action": [
                                {
                                    "type": "if",
                                    "condition": "core.getStatus('money') >= 120",
                                    "true": [
                                        {
                                            "type": "setValue",
                                            "name": "status:money",
                                            "operator": "-=",
                                            "value": "120"
                                        },
                                        {
                                            "type": "getItem",
                                            "name": "lightGauntlets"
                                        },
                                        {
                                            "type": "playSound",
                                            "name": "item.mp3"
                                        },
                                        "\t[店员,shopkeeper]\b[up,7,8]好眼光！轻骑兵专用护手，让你出刀快如疾风！"
                                    ],
                                    "false": [
                                        "\t[店员,shopkeeper]\b[up,7,8]这件护手需要 120G 呢，攒够钱再来吧！"
                                    ]
                                }
                            ]
                        },
                        {
                            "text": "骷髅盾 (70 G) - 防御 +12, 自带10%物理减伤",
                            "action": [
                                {
                                    "type": "if",
                                    "condition": "core.getStatus('money') >= 70",
                                    "true": [
                                        {
                                            "type": "setValue",
                                            "name": "status:money",
                                            "operator": "-=",
                                            "value": "70"
                                        },
                                        {
                                            "type": "getItem",
                                            "name": "skullShield"
                                        },
                                        {
                                            "type": "playSound",
                                            "name": "item.mp3"
                                        },
                                        "\t[店员,shopkeeper]\b[up,7,8]从古代遗迹发掘出的坚固骨盾，防御力非常惊人！"
                                    ],
                                    "false": [
                                        "\t[店员,shopkeeper]\b[up,7,8]骷髅盾需要 70G 哦。"
                                    ]
                                }
                            ]
                        },
                        {
                            "text": "回复戒指 (850 G) - 持续生命回复 +15/t",
                            "action": [
                                {
                                    "type": "if",
                                    "condition": "core.getStatus('money') >= 850",
                                    "true": [
                                        {
                                            "type": "setValue",
                                            "name": "status:money",
                                            "operator": "-=",
                                            "value": "850"
                                        },
                                        {
                                            "type": "getItem",
                                            "name": "ringOfRegen"
                                        },
                                        {
                                            "type": "playSound",
                                            "name": "item.mp3"
                                        },
                                        "\t[店员,shopkeeper]\b[up,7,8]镇店之宝！持续恢复活力的附魔戒指，祝你在战场上化险为夷！"
                                    ],
                                    "false": [
                                        "\t[店员,shopkeeper]\b[up,7,8]这是本店的高阶附魔首饰，售价 850G 呢。"
                                    ]
                                }
                            ]
                        },
                        {
                            "text": "我再看看 (离开)",
                            "action": [
                                "\t[店员,shopkeeper]\b[up,7,8]没关系，随时欢迎回来挑选！"
                            ]
                        }
                    ]
                }
            ]
        },
        "5,10": {
            "trigger": "action",
            "enable": true,
            "data": [
                {
                    "type": "playSound",
                    "name": "cursor.mp3"
                },
                "\t[设定说明之护甲]\b[up,5,10]护甲能够以百分比形式减少敌人的物理伤害。\n这个减伤系数由你的护甲值决定。\n至于其中的公式，可以变相理解为每点护甲为你提供6%的血量收益，10点护甲相当于在计算物理伤害时你的1点血量可以发挥出1.6点血量的作用。\n而护甲为负时每点则会增加6%受到的物理伤害。\n当然，有必要再次重申：护甲减伤只对物理伤害有效，而敌人的普通攻击属于物理伤害。"
            ]
        }
    },
    "changeFloor": {
        "5,16": {
            "floorId": "MT6",
            "loc": [
                68,
                17
            ],
            "direction": "down"
        }
    },
    "beforeBattle": {},
    "afterBattle": {},
    "afterGetItem": {},
    "afterOpenDoor": {},
    "cannotMove": {},
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
            0,
            0,
            0,
            0,
            17,
            17,
            17,
            17,
            17,
            17,
            17,
            0,
            0,
            0
        ],
        [
            0,
            0,
            0,
            17,
            17,
            17,
            17,
            17,
            17,
            17,
            0,
            17,
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
            17,
            17,
            17,
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
            0,
            0,
            0,
            0,
            0,
            0,
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
            0,
            0,
            0,
            0,
            17,
            17,
            17,
            17,
            17,
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
            0
        ],
        [
            0,
            0,
            0,
            17,
            17,
            17,
            0,
            0,
            0,
            0,
            17,
            17,
            0,
            0,
            0
        ],
        [
            0,
            0,
            0,
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
            17,
            17,
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
            0,
            0,
            0,
            0,
            0,
            0
        ]
    ],
    "cannotMoveIn": {},
    "autoEvent": {}
}
