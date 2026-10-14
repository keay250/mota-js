main.floors.MT5 =
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
        "10,9": {
            "trigger": "action",
            "enable": true,
            "data": [
                {
                    "type": "playSound",
                    "name": "centerFly.mp3"
                },
                {
                    "type": "if",
                    "condition": "!core.hasFlag('station_mt5_activated')",
                    "true": [
                        {
                            "type": "tip",
                            "text": "【厄泽城外小站】已成功登记激活！"
                        },
                        {
                            "type": "setValue",
                            "name": "flag:station_mt5_activated",
                            "operator": "=",
                            "value": "true"
                        }
                    ]
                },
                {
                    "type": "choices",
                    "text": "\t[厄泽城外小站]\n古老符文闪烁着流光，这是连通大陆各处的魔法传送阵。\n请选择小站服务：",
                    "choices": [
                        {
                            "text": "休整：恢复全部生命值",
                            "action": [
                                {
                                    "type": "playSound",
                                    "name": "recovery.mp3"
                                },
                                {
                                    "type": "function",
                                    "function": "function() { core.status.hero.hp = core.status.hero.hpmax || 1000; core.updateStatusBar(); }"
                                },
                                {
                                    "type": "tip",
                                    "text": "生命值已完全恢复！"
                                }
                            ]
                        },
                        {
                            "text": "传送：前往其他小站",
                            "action": [
                                {
                                    "type": "if",
                                    "condition": "core.hasFlag('station_mt6_activated')",
                                    "true": [
                                        {
                                            "type": "choices",
                                            "text": "请选择目的地：",
                                            "choices": [
                                                {
                                                    "text": "厄泽城·中央广场小站",
                                                    "action": [
                                                        {
                                                            "type": "changeFloor",
                                                            "floorId": "MT6",
                                                            "loc": [
                                                                37,
                                                                30
                                                            ],
                                                            "direction": "down",
                                                            "time": 300
                                                        }
                                                    ]
                                                },
                                                {
                                                    "text": "取消",
                                                    "action": []
                                                }
                                            ]
                                        }
                                    ],
                                    "false": [
                                        "\t[小站管理员]目前尚未连接其他已激活的小站。穿过哨卡进入厄泽城后，可在中央广场激活城镇小站！"
                                    ]
                                }
                            ]
                        },
                        {
                            "text": "离开",
                            "action": []
                        }
                    ]
                }
            ]
        },
        "11,9": {
            "trigger": "action",
            "enable": true,
            "data": [
                {
                    "type": "playSound",
                    "name": "centerFly.mp3"
                },
                {
                    "type": "if",
                    "condition": "!core.hasFlag('station_mt5_activated')",
                    "true": [
                        {
                            "type": "tip",
                            "text": "【厄泽城外小站】已成功登记激活！"
                        },
                        {
                            "type": "setValue",
                            "name": "flag:station_mt5_activated",
                            "operator": "=",
                            "value": "true"
                        }
                    ]
                },
                {
                    "type": "choices",
                    "text": "\t[厄泽城外小站]\n古老符文闪烁着流光，这是连通大陆各处的魔法传送阵。\n请选择小站服务：",
                    "choices": [
                        {
                            "text": "休整：恢复全部生命值",
                            "action": [
                                {
                                    "type": "playSound",
                                    "name": "recovery.mp3"
                                },
                                {
                                    "type": "function",
                                    "function": "function() { core.status.hero.hp = core.status.hero.hpmax || 1000; core.updateStatusBar(); }"
                                },
                                {
                                    "type": "tip",
                                    "text": "生命值已完全恢复！"
                                }
                            ]
                        },
                        {
                            "text": "传送：前往其他小站",
                            "action": [
                                {
                                    "type": "if",
                                    "condition": "core.hasFlag('station_mt6_activated')",
                                    "true": [
                                        {
                                            "type": "choices",
                                            "text": "请选择目的地：",
                                            "choices": [
                                                {
                                                    "text": "厄泽城·中央广场小站",
                                                    "action": [
                                                        {
                                                            "type": "changeFloor",
                                                            "floorId": "MT6",
                                                            "loc": [
                                                                37,
                                                                30
                                                            ],
                                                            "direction": "down",
                                                            "time": 300
                                                        }
                                                    ]
                                                },
                                                {
                                                    "text": "取消",
                                                    "action": []
                                                }
                                            ]
                                        }
                                    ],
                                    "false": [
                                        "\t[小站管理员]目前尚未连接其他已激活的小站。穿过哨卡进入厄泽城后，可在中央广场激活城镇小站！"
                                    ]
                                }
                            ]
                        },
                        {
                            "text": "离开",
                            "action": []
                        }
                    ]
                }
            ]
        },
        "12,9": {
            "trigger": "action",
            "enable": true,
            "data": [
                {
                    "type": "playSound",
                    "name": "centerFly.mp3"
                },
                {
                    "type": "if",
                    "condition": "!core.hasFlag('station_mt5_activated')",
                    "true": [
                        {
                            "type": "tip",
                            "text": "【厄泽城外小站】已成功登记激活！"
                        },
                        {
                            "type": "setValue",
                            "name": "flag:station_mt5_activated",
                            "operator": "=",
                            "value": "true"
                        }
                    ]
                },
                {
                    "type": "choices",
                    "text": "\t[厄泽城外小站]\n古老符文闪烁着流光，这是连通大陆各处的魔法传送阵。\n请选择小站服务：",
                    "choices": [
                        {
                            "text": "休整：恢复全部生命值",
                            "action": [
                                {
                                    "type": "playSound",
                                    "name": "recovery.mp3"
                                },
                                {
                                    "type": "function",
                                    "function": "function() { core.status.hero.hp = core.status.hero.hpmax || 1000; core.updateStatusBar(); }"
                                },
                                {
                                    "type": "tip",
                                    "text": "生命值已完全恢复！"
                                }
                            ]
                        },
                        {
                            "text": "传送：前往其他小站",
                            "action": [
                                {
                                    "type": "if",
                                    "condition": "core.hasFlag('station_mt6_activated')",
                                    "true": [
                                        {
                                            "type": "choices",
                                            "text": "请选择目的地：",
                                            "choices": [
                                                {
                                                    "text": "厄泽城·中央广场小站",
                                                    "action": [
                                                        {
                                                            "type": "changeFloor",
                                                            "floorId": "MT6",
                                                            "loc": [
                                                                37,
                                                                30
                                                            ],
                                                            "direction": "down",
                                                            "time": 300
                                                        }
                                                    ]
                                                },
                                                {
                                                    "text": "取消",
                                                    "action": []
                                                }
                                            ]
                                        }
                                    ],
                                    "false": [
                                        "\t[小站管理员]目前尚未连接其他已激活的小站。穿过哨卡进入厄泽城后，可在中央广场激活城镇小站！"
                                    ]
                                }
                            ]
                        },
                        {
                            "text": "离开",
                            "action": []
                        }
                    ]
                }
            ]
        },
        "13,9": {
            "trigger": "action",
            "enable": true,
            "data": [
                {
                    "type": "playSound",
                    "name": "centerFly.mp3"
                },
                {
                    "type": "if",
                    "condition": "!core.hasFlag('station_mt5_activated')",
                    "true": [
                        {
                            "type": "tip",
                            "text": "【厄泽城外小站】已成功登记激活！"
                        },
                        {
                            "type": "setValue",
                            "name": "flag:station_mt5_activated",
                            "operator": "=",
                            "value": "true"
                        }
                    ]
                },
                {
                    "type": "choices",
                    "text": "\t[厄泽城外小站]\n古老符文闪烁着流光，这是连通大陆各处的魔法传送阵。\n请选择小站服务：",
                    "choices": [
                        {
                            "text": "休整：恢复全部生命值",
                            "action": [
                                {
                                    "type": "playSound",
                                    "name": "recovery.mp3"
                                },
                                {
                                    "type": "function",
                                    "function": "function() { core.status.hero.hp = core.status.hero.hpmax || 1000; core.updateStatusBar(); }"
                                },
                                {
                                    "type": "tip",
                                    "text": "生命值已完全恢复！"
                                }
                            ]
                        },
                        {
                            "text": "传送：前往其他小站",
                            "action": [
                                {
                                    "type": "if",
                                    "condition": "core.hasFlag('station_mt6_activated')",
                                    "true": [
                                        {
                                            "type": "choices",
                                            "text": "请选择目的地：",
                                            "choices": [
                                                {
                                                    "text": "厄泽城·中央广场小站",
                                                    "action": [
                                                        {
                                                            "type": "changeFloor",
                                                            "floorId": "MT6",
                                                            "loc": [
                                                                37,
                                                                30
                                                            ],
                                                            "direction": "down",
                                                            "time": 300
                                                        }
                                                    ]
                                                },
                                                {
                                                    "text": "取消",
                                                    "action": []
                                                }
                                            ]
                                        }
                                    ],
                                    "false": [
                                        "\t[小站管理员]目前尚未连接其他已激活的小站。穿过哨卡进入厄泽城后，可在中央广场激活城镇小站！"
                                    ]
                                }
                            ]
                        },
                        {
                            "text": "离开",
                            "action": []
                        }
                    ]
                }
            ]
        },
        "14,9": {
            "trigger": "action",
            "enable": true,
            "data": [
                {
                    "type": "playSound",
                    "name": "centerFly.mp3"
                },
                {
                    "type": "if",
                    "condition": "!core.hasFlag('station_mt5_activated')",
                    "true": [
                        {
                            "type": "tip",
                            "text": "【厄泽城外小站】已成功登记激活！"
                        },
                        {
                            "type": "setValue",
                            "name": "flag:station_mt5_activated",
                            "operator": "=",
                            "value": "true"
                        }
                    ]
                },
                {
                    "type": "choices",
                    "text": "\t[厄泽城外小站]\n古老符文闪烁着流光，这是连通大陆各处的魔法传送阵。\n请选择小站服务：",
                    "choices": [
                        {
                            "text": "休整：恢复全部生命值",
                            "action": [
                                {
                                    "type": "playSound",
                                    "name": "recovery.mp3"
                                },
                                {
                                    "type": "function",
                                    "function": "function() { core.status.hero.hp = core.status.hero.hpmax || 1000; core.updateStatusBar(); }"
                                },
                                {
                                    "type": "tip",
                                    "text": "生命值已完全恢复！"
                                }
                            ]
                        },
                        {
                            "text": "传送：前往其他小站",
                            "action": [
                                {
                                    "type": "if",
                                    "condition": "core.hasFlag('station_mt6_activated')",
                                    "true": [
                                        {
                                            "type": "choices",
                                            "text": "请选择目的地：",
                                            "choices": [
                                                {
                                                    "text": "厄泽城·中央广场小站",
                                                    "action": [
                                                        {
                                                            "type": "changeFloor",
                                                            "floorId": "MT6",
                                                            "loc": [
                                                                37,
                                                                30
                                                            ],
                                                            "direction": "down",
                                                            "time": 300
                                                        }
                                                    ]
                                                },
                                                {
                                                    "text": "取消",
                                                    "action": []
                                                }
                                            ]
                                        }
                                    ],
                                    "false": [
                                        "\t[小站管理员]目前尚未连接其他已激活的小站。穿过哨卡进入厄泽城后，可在中央广场激活城镇小站！"
                                    ]
                                }
                            ]
                        },
                        {
                            "text": "离开",
                            "action": []
                        }
                    ]
                }
            ]
        },
        "10,10": {
            "trigger": "action",
            "enable": true,
            "data": [
                {
                    "type": "playSound",
                    "name": "centerFly.mp3"
                },
                {
                    "type": "if",
                    "condition": "!core.hasFlag('station_mt5_activated')",
                    "true": [
                        {
                            "type": "tip",
                            "text": "【厄泽城外小站】已成功登记激活！"
                        },
                        {
                            "type": "setValue",
                            "name": "flag:station_mt5_activated",
                            "operator": "=",
                            "value": "true"
                        }
                    ]
                },
                {
                    "type": "choices",
                    "text": "\t[厄泽城外小站]\n古老符文闪烁着流光，这是连通大陆各处的魔法传送阵。\n请选择小站服务：",
                    "choices": [
                        {
                            "text": "休整：恢复全部生命值",
                            "action": [
                                {
                                    "type": "playSound",
                                    "name": "recovery.mp3"
                                },
                                {
                                    "type": "function",
                                    "function": "function() { core.status.hero.hp = core.status.hero.hpmax || 1000; core.updateStatusBar(); }"
                                },
                                {
                                    "type": "tip",
                                    "text": "生命值已完全恢复！"
                                }
                            ]
                        },
                        {
                            "text": "传送：前往其他小站",
                            "action": [
                                {
                                    "type": "if",
                                    "condition": "core.hasFlag('station_mt6_activated')",
                                    "true": [
                                        {
                                            "type": "choices",
                                            "text": "请选择目的地：",
                                            "choices": [
                                                {
                                                    "text": "厄泽城·中央广场小站",
                                                    "action": [
                                                        {
                                                            "type": "changeFloor",
                                                            "floorId": "MT6",
                                                            "loc": [
                                                                37,
                                                                30
                                                            ],
                                                            "direction": "down",
                                                            "time": 300
                                                        }
                                                    ]
                                                },
                                                {
                                                    "text": "取消",
                                                    "action": []
                                                }
                                            ]
                                        }
                                    ],
                                    "false": [
                                        "\t[小站管理员]目前尚未连接其他已激活的小站。穿过哨卡进入厄泽城后，可在中央广场激活城镇小站！"
                                    ]
                                }
                            ]
                        },
                        {
                            "text": "离开",
                            "action": []
                        }
                    ]
                }
            ]
        },
        "11,10": {
            "trigger": "action",
            "enable": true,
            "data": [
                {
                    "type": "playSound",
                    "name": "centerFly.mp3"
                },
                {
                    "type": "if",
                    "condition": "!core.hasFlag('station_mt5_activated')",
                    "true": [
                        {
                            "type": "tip",
                            "text": "【厄泽城外小站】已成功登记激活！"
                        },
                        {
                            "type": "setValue",
                            "name": "flag:station_mt5_activated",
                            "operator": "=",
                            "value": "true"
                        }
                    ]
                },
                {
                    "type": "choices",
                    "text": "\t[厄泽城外小站]\n古老符文闪烁着流光，这是连通大陆各处的魔法传送阵。\n请选择小站服务：",
                    "choices": [
                        {
                            "text": "休整：恢复全部生命值",
                            "action": [
                                {
                                    "type": "playSound",
                                    "name": "recovery.mp3"
                                },
                                {
                                    "type": "function",
                                    "function": "function() { core.status.hero.hp = core.status.hero.hpmax || 1000; core.updateStatusBar(); }"
                                },
                                {
                                    "type": "tip",
                                    "text": "生命值已完全恢复！"
                                }
                            ]
                        },
                        {
                            "text": "传送：前往其他小站",
                            "action": [
                                {
                                    "type": "if",
                                    "condition": "core.hasFlag('station_mt6_activated')",
                                    "true": [
                                        {
                                            "type": "choices",
                                            "text": "请选择目的地：",
                                            "choices": [
                                                {
                                                    "text": "厄泽城·中央广场小站",
                                                    "action": [
                                                        {
                                                            "type": "changeFloor",
                                                            "floorId": "MT6",
                                                            "loc": [
                                                                37,
                                                                30
                                                            ],
                                                            "direction": "down",
                                                            "time": 300
                                                        }
                                                    ]
                                                },
                                                {
                                                    "text": "取消",
                                                    "action": []
                                                }
                                            ]
                                        }
                                    ],
                                    "false": [
                                        "\t[小站管理员]目前尚未连接其他已激活的小站。穿过哨卡进入厄泽城后，可在中央广场激活城镇小站！"
                                    ]
                                }
                            ]
                        },
                        {
                            "text": "离开",
                            "action": []
                        }
                    ]
                }
            ]
        },
        "12,10": {
            "trigger": "action",
            "enable": true,
            "data": [
                {
                    "type": "playSound",
                    "name": "centerFly.mp3"
                },
                {
                    "type": "if",
                    "condition": "!core.hasFlag('station_mt5_activated')",
                    "true": [
                        {
                            "type": "tip",
                            "text": "【厄泽城外小站】已成功登记激活！"
                        },
                        {
                            "type": "setValue",
                            "name": "flag:station_mt5_activated",
                            "operator": "=",
                            "value": "true"
                        }
                    ]
                },
                {
                    "type": "choices",
                    "text": "\t[厄泽城外小站]\n古老符文闪烁着流光，这是连通大陆各处的魔法传送阵。\n请选择小站服务：",
                    "choices": [
                        {
                            "text": "休整：恢复全部生命值",
                            "action": [
                                {
                                    "type": "playSound",
                                    "name": "recovery.mp3"
                                },
                                {
                                    "type": "function",
                                    "function": "function() { core.status.hero.hp = core.status.hero.hpmax || 1000; core.updateStatusBar(); }"
                                },
                                {
                                    "type": "tip",
                                    "text": "生命值已完全恢复！"
                                }
                            ]
                        },
                        {
                            "text": "传送：前往其他小站",
                            "action": [
                                {
                                    "type": "if",
                                    "condition": "core.hasFlag('station_mt6_activated')",
                                    "true": [
                                        {
                                            "type": "choices",
                                            "text": "请选择目的地：",
                                            "choices": [
                                                {
                                                    "text": "厄泽城·中央广场小站",
                                                    "action": [
                                                        {
                                                            "type": "changeFloor",
                                                            "floorId": "MT6",
                                                            "loc": [
                                                                37,
                                                                30
                                                            ],
                                                            "direction": "down",
                                                            "time": 300
                                                        }
                                                    ]
                                                },
                                                {
                                                    "text": "取消",
                                                    "action": []
                                                }
                                            ]
                                        }
                                    ],
                                    "false": [
                                        "\t[小站管理员]目前尚未连接其他已激活的小站。穿过哨卡进入厄泽城后，可在中央广场激活城镇小站！"
                                    ]
                                }
                            ]
                        },
                        {
                            "text": "离开",
                            "action": []
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
                    "name": "centerFly.mp3"
                },
                {
                    "type": "if",
                    "condition": "!core.hasFlag('station_mt5_activated')",
                    "true": [
                        {
                            "type": "tip",
                            "text": "【厄泽城外小站】已成功登记激活！"
                        },
                        {
                            "type": "setValue",
                            "name": "flag:station_mt5_activated",
                            "operator": "=",
                            "value": "true"
                        }
                    ]
                },
                {
                    "type": "choices",
                    "text": "\t[厄泽城外小站]\n古老符文闪烁着流光，这是连通大陆各处的魔法传送阵。\n请选择小站服务：",
                    "choices": [
                        {
                            "text": "休整：恢复全部生命值",
                            "action": [
                                {
                                    "type": "playSound",
                                    "name": "recovery.mp3"
                                },
                                {
                                    "type": "function",
                                    "function": "function() { core.status.hero.hp = core.status.hero.hpmax || 1000; core.updateStatusBar(); }"
                                },
                                {
                                    "type": "tip",
                                    "text": "生命值已完全恢复！"
                                }
                            ]
                        },
                        {
                            "text": "传送：前往其他小站",
                            "action": [
                                {
                                    "type": "if",
                                    "condition": "core.hasFlag('station_mt6_activated')",
                                    "true": [
                                        {
                                            "type": "choices",
                                            "text": "请选择目的地：",
                                            "choices": [
                                                {
                                                    "text": "厄泽城·中央广场小站",
                                                    "action": [
                                                        {
                                                            "type": "changeFloor",
                                                            "floorId": "MT6",
                                                            "loc": [
                                                                37,
                                                                30
                                                            ],
                                                            "direction": "down",
                                                            "time": 300
                                                        }
                                                    ]
                                                },
                                                {
                                                    "text": "取消",
                                                    "action": []
                                                }
                                            ]
                                        }
                                    ],
                                    "false": [
                                        "\t[小站管理员]目前尚未连接其他已激活的小站。穿过哨卡进入厄泽城后，可在中央广场激活城镇小站！"
                                    ]
                                }
                            ]
                        },
                        {
                            "text": "离开",
                            "action": []
                        }
                    ]
                }
            ]
        },
        "14,10": {
            "trigger": "action",
            "enable": true,
            "data": [
                {
                    "type": "playSound",
                    "name": "centerFly.mp3"
                },
                {
                    "type": "if",
                    "condition": "!core.hasFlag('station_mt5_activated')",
                    "true": [
                        {
                            "type": "tip",
                            "text": "【厄泽城外小站】已成功登记激活！"
                        },
                        {
                            "type": "setValue",
                            "name": "flag:station_mt5_activated",
                            "operator": "=",
                            "value": "true"
                        }
                    ]
                },
                {
                    "type": "choices",
                    "text": "\t[厄泽城外小站]\n古老符文闪烁着流光，这是连通大陆各处的魔法传送阵。\n请选择小站服务：",
                    "choices": [
                        {
                            "text": "休整：恢复全部生命值",
                            "action": [
                                {
                                    "type": "playSound",
                                    "name": "recovery.mp3"
                                },
                                {
                                    "type": "function",
                                    "function": "function() { core.status.hero.hp = core.status.hero.hpmax || 1000; core.updateStatusBar(); }"
                                },
                                {
                                    "type": "tip",
                                    "text": "生命值已完全恢复！"
                                }
                            ]
                        },
                        {
                            "text": "传送：前往其他小站",
                            "action": [
                                {
                                    "type": "if",
                                    "condition": "core.hasFlag('station_mt6_activated')",
                                    "true": [
                                        {
                                            "type": "choices",
                                            "text": "请选择目的地：",
                                            "choices": [
                                                {
                                                    "text": "厄泽城·中央广场小站",
                                                    "action": [
                                                        {
                                                            "type": "changeFloor",
                                                            "floorId": "MT6",
                                                            "loc": [
                                                                37,
                                                                30
                                                            ],
                                                            "direction": "down",
                                                            "time": 300
                                                        }
                                                    ]
                                                },
                                                {
                                                    "text": "取消",
                                                    "action": []
                                                }
                                            ]
                                        }
                                    ],
                                    "false": [
                                        "\t[小站管理员]目前尚未连接其他已激活的小站。穿过哨卡进入厄泽城后，可在中央广场激活城镇小站！"
                                    ]
                                }
                            ]
                        },
                        {
                            "text": "离开",
                            "action": []
                        }
                    ]
                }
            ]
        },
        "10,11": {
            "trigger": "action",
            "enable": true,
            "data": [
                {
                    "type": "playSound",
                    "name": "centerFly.mp3"
                },
                {
                    "type": "if",
                    "condition": "!core.hasFlag('station_mt5_activated')",
                    "true": [
                        {
                            "type": "tip",
                            "text": "【厄泽城外小站】已成功登记激活！"
                        },
                        {
                            "type": "setValue",
                            "name": "flag:station_mt5_activated",
                            "operator": "=",
                            "value": "true"
                        }
                    ]
                },
                {
                    "type": "choices",
                    "text": "\t[厄泽城外小站]\n古老符文闪烁着流光，这是连通大陆各处的魔法传送阵。\n请选择小站服务：",
                    "choices": [
                        {
                            "text": "休整：恢复全部生命值",
                            "action": [
                                {
                                    "type": "playSound",
                                    "name": "recovery.mp3"
                                },
                                {
                                    "type": "function",
                                    "function": "function() { core.status.hero.hp = core.status.hero.hpmax || 1000; core.updateStatusBar(); }"
                                },
                                {
                                    "type": "tip",
                                    "text": "生命值已完全恢复！"
                                }
                            ]
                        },
                        {
                            "text": "传送：前往其他小站",
                            "action": [
                                {
                                    "type": "if",
                                    "condition": "core.hasFlag('station_mt6_activated')",
                                    "true": [
                                        {
                                            "type": "choices",
                                            "text": "请选择目的地：",
                                            "choices": [
                                                {
                                                    "text": "厄泽城·中央广场小站",
                                                    "action": [
                                                        {
                                                            "type": "changeFloor",
                                                            "floorId": "MT6",
                                                            "loc": [
                                                                37,
                                                                30
                                                            ],
                                                            "direction": "down",
                                                            "time": 300
                                                        }
                                                    ]
                                                },
                                                {
                                                    "text": "取消",
                                                    "action": []
                                                }
                                            ]
                                        }
                                    ],
                                    "false": [
                                        "\t[小站管理员]目前尚未连接其他已激活的小站。穿过哨卡进入厄泽城后，可在中央广场激活城镇小站！"
                                    ]
                                }
                            ]
                        },
                        {
                            "text": "离开",
                            "action": []
                        }
                    ]
                }
            ]
        },
        "11,11": {
            "trigger": "action",
            "enable": true,
            "data": [
                {
                    "type": "playSound",
                    "name": "centerFly.mp3"
                },
                {
                    "type": "if",
                    "condition": "!core.hasFlag('station_mt5_activated')",
                    "true": [
                        {
                            "type": "tip",
                            "text": "【厄泽城外小站】已成功登记激活！"
                        },
                        {
                            "type": "setValue",
                            "name": "flag:station_mt5_activated",
                            "operator": "=",
                            "value": "true"
                        }
                    ]
                },
                {
                    "type": "choices",
                    "text": "\t[厄泽城外小站]\n古老符文闪烁着流光，这是连通大陆各处的魔法传送阵。\n请选择小站服务：",
                    "choices": [
                        {
                            "text": "休整：恢复全部生命值",
                            "action": [
                                {
                                    "type": "playSound",
                                    "name": "recovery.mp3"
                                },
                                {
                                    "type": "function",
                                    "function": "function() { core.status.hero.hp = core.status.hero.hpmax || 1000; core.updateStatusBar(); }"
                                },
                                {
                                    "type": "tip",
                                    "text": "生命值已完全恢复！"
                                }
                            ]
                        },
                        {
                            "text": "传送：前往其他小站",
                            "action": [
                                {
                                    "type": "if",
                                    "condition": "core.hasFlag('station_mt6_activated')",
                                    "true": [
                                        {
                                            "type": "choices",
                                            "text": "请选择目的地：",
                                            "choices": [
                                                {
                                                    "text": "厄泽城·中央广场小站",
                                                    "action": [
                                                        {
                                                            "type": "changeFloor",
                                                            "floorId": "MT6",
                                                            "loc": [
                                                                37,
                                                                30
                                                            ],
                                                            "direction": "down",
                                                            "time": 300
                                                        }
                                                    ]
                                                },
                                                {
                                                    "text": "取消",
                                                    "action": []
                                                }
                                            ]
                                        }
                                    ],
                                    "false": [
                                        "\t[小站管理员]目前尚未连接其他已激活的小站。穿过哨卡进入厄泽城后，可在中央广场激活城镇小站！"
                                    ]
                                }
                            ]
                        },
                        {
                            "text": "离开",
                            "action": []
                        }
                    ]
                }
            ]
        },
        "12,11": {
            "trigger": "action",
            "enable": true,
            "data": [
                {
                    "type": "playSound",
                    "name": "centerFly.mp3"
                },
                {
                    "type": "if",
                    "condition": "!core.hasFlag('station_mt5_activated')",
                    "true": [
                        {
                            "type": "tip",
                            "text": "【厄泽城外小站】已成功登记激活！"
                        },
                        {
                            "type": "setValue",
                            "name": "flag:station_mt5_activated",
                            "operator": "=",
                            "value": "true"
                        }
                    ]
                },
                {
                    "type": "choices",
                    "text": "\t[厄泽城外小站]\n古老符文闪烁着流光，这是连通大陆各处的魔法传送阵。\n请选择小站服务：",
                    "choices": [
                        {
                            "text": "休整：恢复全部生命值",
                            "action": [
                                {
                                    "type": "playSound",
                                    "name": "recovery.mp3"
                                },
                                {
                                    "type": "function",
                                    "function": "function() { core.status.hero.hp = core.status.hero.hpmax || 1000; core.updateStatusBar(); }"
                                },
                                {
                                    "type": "tip",
                                    "text": "生命值已完全恢复！"
                                }
                            ]
                        },
                        {
                            "text": "传送：前往其他小站",
                            "action": [
                                {
                                    "type": "if",
                                    "condition": "core.hasFlag('station_mt6_activated')",
                                    "true": [
                                        {
                                            "type": "choices",
                                            "text": "请选择目的地：",
                                            "choices": [
                                                {
                                                    "text": "厄泽城·中央广场小站",
                                                    "action": [
                                                        {
                                                            "type": "changeFloor",
                                                            "floorId": "MT6",
                                                            "loc": [
                                                                37,
                                                                30
                                                            ],
                                                            "direction": "down",
                                                            "time": 300
                                                        }
                                                    ]
                                                },
                                                {
                                                    "text": "取消",
                                                    "action": []
                                                }
                                            ]
                                        }
                                    ],
                                    "false": [
                                        "\t[小站管理员]目前尚未连接其他已激活的小站。穿过哨卡进入厄泽城后，可在中央广场激活城镇小站！"
                                    ]
                                }
                            ]
                        },
                        {
                            "text": "离开",
                            "action": []
                        }
                    ]
                }
            ]
        },
        "13,11": {
            "trigger": "action",
            "enable": true,
            "data": [
                {
                    "type": "playSound",
                    "name": "centerFly.mp3"
                },
                {
                    "type": "if",
                    "condition": "!core.hasFlag('station_mt5_activated')",
                    "true": [
                        {
                            "type": "tip",
                            "text": "【厄泽城外小站】已成功登记激活！"
                        },
                        {
                            "type": "setValue",
                            "name": "flag:station_mt5_activated",
                            "operator": "=",
                            "value": "true"
                        }
                    ]
                },
                {
                    "type": "choices",
                    "text": "\t[厄泽城外小站]\n古老符文闪烁着流光，这是连通大陆各处的魔法传送阵。\n请选择小站服务：",
                    "choices": [
                        {
                            "text": "休整：恢复全部生命值",
                            "action": [
                                {
                                    "type": "playSound",
                                    "name": "recovery.mp3"
                                },
                                {
                                    "type": "function",
                                    "function": "function() { core.status.hero.hp = core.status.hero.hpmax || 1000; core.updateStatusBar(); }"
                                },
                                {
                                    "type": "tip",
                                    "text": "生命值已完全恢复！"
                                }
                            ]
                        },
                        {
                            "text": "传送：前往其他小站",
                            "action": [
                                {
                                    "type": "if",
                                    "condition": "core.hasFlag('station_mt6_activated')",
                                    "true": [
                                        {
                                            "type": "choices",
                                            "text": "请选择目的地：",
                                            "choices": [
                                                {
                                                    "text": "厄泽城·中央广场小站",
                                                    "action": [
                                                        {
                                                            "type": "changeFloor",
                                                            "floorId": "MT6",
                                                            "loc": [
                                                                37,
                                                                30
                                                            ],
                                                            "direction": "down",
                                                            "time": 300
                                                        }
                                                    ]
                                                },
                                                {
                                                    "text": "取消",
                                                    "action": []
                                                }
                                            ]
                                        }
                                    ],
                                    "false": [
                                        "\t[小站管理员]目前尚未连接其他已激活的小站。穿过哨卡进入厄泽城后，可在中央广场激活城镇小站！"
                                    ]
                                }
                            ]
                        },
                        {
                            "text": "离开",
                            "action": []
                        }
                    ]
                }
            ]
        },
        "14,11": {
            "trigger": "action",
            "enable": true,
            "data": [
                {
                    "type": "playSound",
                    "name": "centerFly.mp3"
                },
                {
                    "type": "if",
                    "condition": "!core.hasFlag('station_mt5_activated')",
                    "true": [
                        {
                            "type": "tip",
                            "text": "【厄泽城外小站】已成功登记激活！"
                        },
                        {
                            "type": "setValue",
                            "name": "flag:station_mt5_activated",
                            "operator": "=",
                            "value": "true"
                        }
                    ]
                },
                {
                    "type": "choices",
                    "text": "\t[厄泽城外小站]\n古老符文闪烁着流光，这是连通大陆各处的魔法传送阵。\n请选择小站服务：",
                    "choices": [
                        {
                            "text": "休整：恢复全部生命值",
                            "action": [
                                {
                                    "type": "playSound",
                                    "name": "recovery.mp3"
                                },
                                {
                                    "type": "function",
                                    "function": "function() { core.status.hero.hp = core.status.hero.hpmax || 1000; core.updateStatusBar(); }"
                                },
                                {
                                    "type": "tip",
                                    "text": "生命值已完全恢复！"
                                }
                            ]
                        },
                        {
                            "text": "传送：前往其他小站",
                            "action": [
                                {
                                    "type": "if",
                                    "condition": "core.hasFlag('station_mt6_activated')",
                                    "true": [
                                        {
                                            "type": "choices",
                                            "text": "请选择目的地：",
                                            "choices": [
                                                {
                                                    "text": "厄泽城·中央广场小站",
                                                    "action": [
                                                        {
                                                            "type": "changeFloor",
                                                            "floorId": "MT6",
                                                            "loc": [
                                                                37,
                                                                30
                                                            ],
                                                            "direction": "down",
                                                            "time": 300
                                                        }
                                                    ]
                                                },
                                                {
                                                    "text": "取消",
                                                    "action": []
                                                }
                                            ]
                                        }
                                    ],
                                    "false": [
                                        "\t[小站管理员]目前尚未连接其他已激活的小站。穿过哨卡进入厄泽城后，可在中央广场激活城镇小站！"
                                    ]
                                }
                            ]
                        },
                        {
                            "text": "离开",
                            "action": []
                        }
                    ]
                }
            ]
        },
        "10,12": {
            "trigger": "action",
            "enable": true,
            "data": [
                {
                    "type": "playSound",
                    "name": "centerFly.mp3"
                },
                {
                    "type": "if",
                    "condition": "!core.hasFlag('station_mt5_activated')",
                    "true": [
                        {
                            "type": "tip",
                            "text": "【厄泽城外小站】已成功登记激活！"
                        },
                        {
                            "type": "setValue",
                            "name": "flag:station_mt5_activated",
                            "operator": "=",
                            "value": "true"
                        }
                    ]
                },
                {
                    "type": "choices",
                    "text": "\t[厄泽城外小站]\n古老符文闪烁着流光，这是连通大陆各处的魔法传送阵。\n请选择小站服务：",
                    "choices": [
                        {
                            "text": "休整：恢复全部生命值",
                            "action": [
                                {
                                    "type": "playSound",
                                    "name": "recovery.mp3"
                                },
                                {
                                    "type": "function",
                                    "function": "function() { core.status.hero.hp = core.status.hero.hpmax || 1000; core.updateStatusBar(); }"
                                },
                                {
                                    "type": "tip",
                                    "text": "生命值已完全恢复！"
                                }
                            ]
                        },
                        {
                            "text": "传送：前往其他小站",
                            "action": [
                                {
                                    "type": "if",
                                    "condition": "core.hasFlag('station_mt6_activated')",
                                    "true": [
                                        {
                                            "type": "choices",
                                            "text": "请选择目的地：",
                                            "choices": [
                                                {
                                                    "text": "厄泽城·中央广场小站",
                                                    "action": [
                                                        {
                                                            "type": "changeFloor",
                                                            "floorId": "MT6",
                                                            "loc": [
                                                                37,
                                                                30
                                                            ],
                                                            "direction": "down",
                                                            "time": 300
                                                        }
                                                    ]
                                                },
                                                {
                                                    "text": "取消",
                                                    "action": []
                                                }
                                            ]
                                        }
                                    ],
                                    "false": [
                                        "\t[小站管理员]目前尚未连接其他已激活的小站。穿过哨卡进入厄泽城后，可在中央广场激活城镇小站！"
                                    ]
                                }
                            ]
                        },
                        {
                            "text": "离开",
                            "action": []
                        }
                    ]
                }
            ]
        },
        "11,12": {
            "trigger": "action",
            "enable": true,
            "data": [
                {
                    "type": "playSound",
                    "name": "centerFly.mp3"
                },
                {
                    "type": "if",
                    "condition": "!core.hasFlag('station_mt5_activated')",
                    "true": [
                        {
                            "type": "tip",
                            "text": "【厄泽城外小站】已成功登记激活！"
                        },
                        {
                            "type": "setValue",
                            "name": "flag:station_mt5_activated",
                            "operator": "=",
                            "value": "true"
                        }
                    ]
                },
                {
                    "type": "choices",
                    "text": "\t[厄泽城外小站]\n古老符文闪烁着流光，这是连通大陆各处的魔法传送阵。\n请选择小站服务：",
                    "choices": [
                        {
                            "text": "休整：恢复全部生命值",
                            "action": [
                                {
                                    "type": "playSound",
                                    "name": "recovery.mp3"
                                },
                                {
                                    "type": "function",
                                    "function": "function() { core.status.hero.hp = core.status.hero.hpmax || 1000; core.updateStatusBar(); }"
                                },
                                {
                                    "type": "tip",
                                    "text": "生命值已完全恢复！"
                                }
                            ]
                        },
                        {
                            "text": "传送：前往其他小站",
                            "action": [
                                {
                                    "type": "if",
                                    "condition": "core.hasFlag('station_mt6_activated')",
                                    "true": [
                                        {
                                            "type": "choices",
                                            "text": "请选择目的地：",
                                            "choices": [
                                                {
                                                    "text": "厄泽城·中央广场小站",
                                                    "action": [
                                                        {
                                                            "type": "changeFloor",
                                                            "floorId": "MT6",
                                                            "loc": [
                                                                37,
                                                                30
                                                            ],
                                                            "direction": "down",
                                                            "time": 300
                                                        }
                                                    ]
                                                },
                                                {
                                                    "text": "取消",
                                                    "action": []
                                                }
                                            ]
                                        }
                                    ],
                                    "false": [
                                        "\t[小站管理员]目前尚未连接其他已激活的小站。穿过哨卡进入厄泽城后，可在中央广场激活城镇小站！"
                                    ]
                                }
                            ]
                        },
                        {
                            "text": "离开",
                            "action": []
                        }
                    ]
                }
            ]
        },
        "12,12": {
            "trigger": "action",
            "enable": true,
            "data": [
                {
                    "type": "playSound",
                    "name": "centerFly.mp3"
                },
                {
                    "type": "if",
                    "condition": "!core.hasFlag('station_mt5_activated')",
                    "true": [
                        {
                            "type": "tip",
                            "text": "【厄泽城外小站】已成功登记激活！"
                        },
                        {
                            "type": "setValue",
                            "name": "flag:station_mt5_activated",
                            "operator": "=",
                            "value": "true"
                        }
                    ]
                },
                {
                    "type": "choices",
                    "text": "\t[厄泽城外小站]\n古老符文闪烁着流光，这是连通大陆各处的魔法传送阵。\n请选择小站服务：",
                    "choices": [
                        {
                            "text": "休整：恢复全部生命值",
                            "action": [
                                {
                                    "type": "playSound",
                                    "name": "recovery.mp3"
                                },
                                {
                                    "type": "function",
                                    "function": "function() { core.status.hero.hp = core.status.hero.hpmax || 1000; core.updateStatusBar(); }"
                                },
                                {
                                    "type": "tip",
                                    "text": "生命值已完全恢复！"
                                }
                            ]
                        },
                        {
                            "text": "传送：前往其他小站",
                            "action": [
                                {
                                    "type": "if",
                                    "condition": "core.hasFlag('station_mt6_activated')",
                                    "true": [
                                        {
                                            "type": "choices",
                                            "text": "请选择目的地：",
                                            "choices": [
                                                {
                                                    "text": "厄泽城·中央广场小站",
                                                    "action": [
                                                        {
                                                            "type": "changeFloor",
                                                            "floorId": "MT6",
                                                            "loc": [
                                                                37,
                                                                30
                                                            ],
                                                            "direction": "down",
                                                            "time": 300
                                                        }
                                                    ]
                                                },
                                                {
                                                    "text": "取消",
                                                    "action": []
                                                }
                                            ]
                                        }
                                    ],
                                    "false": [
                                        "\t[小站管理员]目前尚未连接其他已激活的小站。穿过哨卡进入厄泽城后，可在中央广场激活城镇小站！"
                                    ]
                                }
                            ]
                        },
                        {
                            "text": "离开",
                            "action": []
                        }
                    ]
                }
            ]
        },
        "13,12": {
            "trigger": "action",
            "enable": true,
            "data": [
                {
                    "type": "playSound",
                    "name": "centerFly.mp3"
                },
                {
                    "type": "if",
                    "condition": "!core.hasFlag('station_mt5_activated')",
                    "true": [
                        {
                            "type": "tip",
                            "text": "【厄泽城外小站】已成功登记激活！"
                        },
                        {
                            "type": "setValue",
                            "name": "flag:station_mt5_activated",
                            "operator": "=",
                            "value": "true"
                        }
                    ]
                },
                {
                    "type": "choices",
                    "text": "\t[厄泽城外小站]\n古老符文闪烁着流光，这是连通大陆各处的魔法传送阵。\n请选择小站服务：",
                    "choices": [
                        {
                            "text": "休整：恢复全部生命值",
                            "action": [
                                {
                                    "type": "playSound",
                                    "name": "recovery.mp3"
                                },
                                {
                                    "type": "function",
                                    "function": "function() { core.status.hero.hp = core.status.hero.hpmax || 1000; core.updateStatusBar(); }"
                                },
                                {
                                    "type": "tip",
                                    "text": "生命值已完全恢复！"
                                }
                            ]
                        },
                        {
                            "text": "传送：前往其他小站",
                            "action": [
                                {
                                    "type": "if",
                                    "condition": "core.hasFlag('station_mt6_activated')",
                                    "true": [
                                        {
                                            "type": "choices",
                                            "text": "请选择目的地：",
                                            "choices": [
                                                {
                                                    "text": "厄泽城·中央广场小站",
                                                    "action": [
                                                        {
                                                            "type": "changeFloor",
                                                            "floorId": "MT6",
                                                            "loc": [
                                                                37,
                                                                30
                                                            ],
                                                            "direction": "down",
                                                            "time": 300
                                                        }
                                                    ]
                                                },
                                                {
                                                    "text": "取消",
                                                    "action": []
                                                }
                                            ]
                                        }
                                    ],
                                    "false": [
                                        "\t[小站管理员]目前尚未连接其他已激活的小站。穿过哨卡进入厄泽城后，可在中央广场激活城镇小站！"
                                    ]
                                }
                            ]
                        },
                        {
                            "text": "离开",
                            "action": []
                        }
                    ]
                }
            ]
        },
        "14,12": {
            "trigger": "action",
            "enable": true,
            "data": [
                {
                    "type": "playSound",
                    "name": "centerFly.mp3"
                },
                {
                    "type": "if",
                    "condition": "!core.hasFlag('station_mt5_activated')",
                    "true": [
                        {
                            "type": "tip",
                            "text": "【厄泽城外小站】已成功登记激活！"
                        },
                        {
                            "type": "setValue",
                            "name": "flag:station_mt5_activated",
                            "operator": "=",
                            "value": "true"
                        }
                    ]
                },
                {
                    "type": "choices",
                    "text": "\t[厄泽城外小站]\n古老符文闪烁着流光，这是连通大陆各处的魔法传送阵。\n请选择小站服务：",
                    "choices": [
                        {
                            "text": "休整：恢复全部生命值",
                            "action": [
                                {
                                    "type": "playSound",
                                    "name": "recovery.mp3"
                                },
                                {
                                    "type": "function",
                                    "function": "function() { core.status.hero.hp = core.status.hero.hpmax || 1000; core.updateStatusBar(); }"
                                },
                                {
                                    "type": "tip",
                                    "text": "生命值已完全恢复！"
                                }
                            ]
                        },
                        {
                            "text": "传送：前往其他小站",
                            "action": [
                                {
                                    "type": "if",
                                    "condition": "core.hasFlag('station_mt6_activated')",
                                    "true": [
                                        {
                                            "type": "choices",
                                            "text": "请选择目的地：",
                                            "choices": [
                                                {
                                                    "text": "厄泽城·中央广场小站",
                                                    "action": [
                                                        {
                                                            "type": "changeFloor",
                                                            "floorId": "MT6",
                                                            "loc": [
                                                                37,
                                                                30
                                                            ],
                                                            "direction": "down",
                                                            "time": 300
                                                        }
                                                    ]
                                                },
                                                {
                                                    "text": "取消",
                                                    "action": []
                                                }
                                            ]
                                        }
                                    ],
                                    "false": [
                                        "\t[小站管理员]目前尚未连接其他已激活的小站。穿过哨卡进入厄泽城后，可在中央广场激活城镇小站！"
                                    ]
                                }
                            ]
                        },
                        {
                            "text": "离开",
                            "action": []
                        }
                    ]
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
        "7,7": {
            "trigger": "action",
            "enable": true,
            "data": [
                {
                    "type": "if",
                    "condition": "!core.hasFlag('mt5_story_learned')",
                    "true": [
                        {
                            "type": "playSound",
                            "name": "cursor.mp3"
                        },
                        "\t[贾斯汀]终于出来了……森林里的雾气开始散去了！",
                        "\t[贾斯汀]其他人没有在这里等待吗？也许已经安全回城了也说不定。前面好像有人，去打听一下！",
                        "\t[贾斯汀]请问……这里发生了什么大事吗？",
                        "\t[路过的佣兵]哦，天呐，居然还有幸存者！一定是全能之神保佑！",
                        "\t[贾斯汀]赞美全能之神。请问发生什么事了？",
                        "\t[路过的佣兵]你不知道吗？那你可真好运！三天前公会发布了一项寻找森林深处遗迹的任务，最开始是作为中阶任务，被一个普通小队接走了。",
                        "\t[路过的佣兵]结果就在前天这个任务被临时拔高为超阶无限制任务，连我们厄泽城唯一的荣耀佣兵【训蛇士大人】都被惊动了！",
                        "\t[路过的佣兵]训蛇士大人亲自带队闯入寂静之森，结果回来时小队折损了一半！据说森林深处遗迹导致高阶魔兽疯狂外迁，不少实力不济的小队全死在里面了！",
                        "\t[贾斯汀]……那个最开始接任务的佣兵小队怎么样了？",
                        "\t[路过的佣兵]还能怎么样，拉瓦尔队长的佣兵徽章都被捡回来了，小队成员全灭，过两天就要在公会被正式注销掉了。",
                        "\t[贾斯汀]（队长……真的牺牲了吗……）\n非常感谢你告诉我这些。",
                        "\t[路过的佣兵]不客气，你能从中级魔兽堆里活着走出来，真是福大命大！",
                        {
                            "type": "setValue",
                            "name": "flag:mt5_story_learned",
                            "operator": "=",
                            "value": "true"
                        }
                    ]
                },
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
                {
                    "type": "if",
                    "condition": "core.hasFlag('mt5_branch_exchanged')",
                    "true": [
                        "\t[路过的佣兵]真是个乐于助人的好少年呀。"
                    ],
                    "false": [
                        {
                            "type": "if",
                            "condition": "core.hasItem('ironBranch') || core.hasFlag('has_ironBranch')",
                            "true": [
                                "\t[路过的佣兵]太棒了，你终于找到它了！",
                                "\t[路过的佣兵]给你，祖传的蓝钥匙！",
                                {
                                    "type": "playSound",
                                    "name": "item.mp3"
                                },
                                {
                                    "type": "function",
                                    "function": "function() { core.removeItem('ironBranch', 1); core.addItem('blueKey', 1); core.setFlag('mt5_branch_exchanged', true); }"
                                },
                                {
                                    "type": "tip",
                                    "text": "获得了【蓝钥匙】×1！"
                                },
                                "\t[贾斯汀]（只是一把蓝钥匙啊……说起来这根树枝总感觉怪怪的，以后或许可能会有用的样子……）"
                            ],
                            "false": [
                                "\t[路过的佣兵]你问我在这里干什么？好吧，偷偷告诉你。\n我的东西丢在了森林里面，在等待有谁捡到还给我。",
                                "\t[路过的佣兵]那是一根不起眼的树枝，是我小时候家里后院桃树上的，对我有很重要的纪念意义。",
                                "\t[路过的佣兵]如果找到了的话把它还给我，我可以给你另一样东西，具体是什么先保密。"
                            ]
                        }
                    ]
                }
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
                "\t[路牌]【厄泽城小站】\n小站能够让你在地图之间快速地穿行。\n当然，这是作为冒险者所拥有的特权，实际上，大陆上的人们还是要用双脚去走完路程的。"
            ]
        },
        "14,7": {
            "trigger": "action",
            "enable": true,
            "data": [
                {
                    "type": "if",
                    "condition": "!core.hasFlag('mt5_entered_city')",
                    "true": [
                        {
                            "type": "playSound",
                            "name": "door.mp3"
                        },
                        "\t[贾斯汀]队长、同伴们，我活着回来了！",
                        {
                            "type": "setValue",
                            "name": "flag:mt5_entered_city",
                            "operator": "=",
                            "value": "true"
                        }
                    ]
                },
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
                13,
                7
            ],
            "direction": "left"
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
            17,
            17,
            17
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
            17
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
            17
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
            17
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
            17
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
            17
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
            17
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
            17
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
            17
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
            17
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
            17
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
            17
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
    "bgm": "厄泽城.mp3",
    "beforeBattle": {},
    "cannotMoveIn": {},
    "autoEvent": {},
    "canFlyFrom": true
}
