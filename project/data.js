var data_a1e2fb4a_e986_4524_b0da_9b7ba7c0874d = 
{
	"main": {
		"floorIds": [
			"MT1",
			"MT2"
		],
		"floorPartitions": [],
		"images": [
			"map007_bg.png",
			"bear.png",
			"bg.jpg",
			"dragon.png",
			"hero.png",
			"winskin.png"
		],
		"tilesets": [
			"magictower.png",
			"003-Forest01.png"
		],
		"animates": [
			"hand",
			"sword",
			"zone"
		],
		"bgms": [
			"bgm.mp3",
			"title.mp3",
			"forest.mp3",
			"标题画面.mp3",
			"寂静之森.mp3"
		],
		"sounds": [
			"attack.mp3",
			"bomb.mp3",
			"cancel.mp3",
			"centerFly.mp3",
			"confirm.mp3",
			"cursor.mp3",
			"door.mp3",
			"equip.mp3",
			"error.mp3",
			"floor.mp3",
			"gem.mp3",
			"icePickaxe.mp3",
			"item.mp3",
			"jump.mp3",
			"load.mp3",
			"open_ui.mp3",
			"pickaxe.mp3",
			"recovery.mp3",
			"save.mp3",
			"shop.mp3",
			"zone.mp3"
		],
		"fonts": [],
		"nameMap": {
			"确定": "confirm.mp3",
			"取消": "cancel.mp3",
			"操作失败": "error.mp3",
			"光标移动": "cursor.mp3",
			"打开界面": "open_ui.mp3",
			"读档": "load.mp3",
			"存档": "save.mp3",
			"获得道具": "item.mp3",
			"回血": "recovery.mp3",
			"炸弹": "bomb.mp3",
			"飞行器": "centerFly.mp3",
			"开关门": "door.mp3",
			"上下楼": "floor.mp3",
			"跳跃": "jump.mp3",
			"破墙镐": "pickaxe.mp3",
			"破冰镐": "icePickaxe.mp3",
			"宝石": "gem.mp3",
			"阻激夹域": "zone.mp3",
			"穿脱装备": "equip.mp3",
			"背景音乐": "bgm.mp3",
			"攻击": "attack.mp3",
			"背景图": "bg.jpg",
			"商店": "shop.mp3",
			"领域": "zone"
		},
		"levelChoose": [
			{
				"title": "简单",
				"name": "Easy",
				"hard": 1,
				"color": [
					64,
					255,
					85,
					1
				],
				"action": [
					{
						"type": "comment",
						"text": "在这里写该难度需执行的事件"
					}
				]
			},
			{
				"title": "普通",
				"name": "Normal",
				"hard": 2,
				"color": [
					255,
					221,
					32,
					1
				],
				"action": []
			},
			{
				"title": "困难",
				"name": "Hard",
				"hard": 3,
				"color": [
					255,
					68,
					64,
					1
				],
				"action": []
			}
		],
		"equipName": [
			"武器",
			"盾牌"
		],
		"startBgm": "title.mp3",
		"styles": {
			"startBackground": "project/images/bg.jpg",
			"startVerticalBackground": "project/images/bg.jpg",
			"startLogoStyle": "color: black",
			"startButtonsStyle": "background-color: #32369F; opacity: 0.85; color: #FFFFFF; border: #FFFFFF 2px solid; caret-color: #FFD700;",
			"statusLeftBackground": "url(project/materials/ground.png) repeat",
			"statusTopBackground": "url(project/materials/ground.png) repeat",
			"toolsBackground": "black",
			"borderColor": [
				0,
				0,
				0,
				1
			],
			"statusBarColor": [
				255,
				255,
				255,
				1
			],
			"selectColor": [
				255,
				215,
				0,
				1
			],
			"floorChangingStyle": "background-color: black; color: white",
			"font": "Verdana"
		},
		"splitImages": [
			{
				"name": "dragon.png",
				"width": 384,
				"height": 96,
				"prefix": "dragon_"
			}
		]
	},
	"firstData": {
		"title": "永不复还 · 寂静之森",
		"name": "template",
		"version": "Ver 2.10.3",
		"floorId": "MT1",
		"hero": {
			"image": "hero.png",
			"animate": false,
			"name": "贾斯汀",
			"lv": 1,
			"hpmax": 9999,
			"hp": 500,
			"manamax": -1,
			"mana": 0,
			"atk": 12,
			"def": 2,
			"mdef": 0,
			"money": 0,
			"exp": 0,
			"equipment": [],
			"items": {
				"constants": {},
				"tools": {},
				"equips": {}
			},
			"loc": {
				"direction": "up",
				"x": 2,
				"y": 12
			},
			"flags": {},
			"followers": [],
			"steps": 0
		},
		"startCanvas": [],
		"startText": [
			{
				"type": "comment",
				"text": "初始剧情"
			},
			"辉煌大陆西北角，寂静之森。\n\n贾斯汀，一个普通的不能再普通的小佣兵。\n十四岁成为佣兵之后在温饱线上已经挣扎了两年。",
			"在辉煌大陆，寻常佣兵根本没有什么地位可言，\n所接到的任务也不过是些类似于看家护院找猫找狗的垃圾任务。\n\n—— 改编自《永不复还》第一章 · 厄泽往事"
		],
		"shops": [
			{
				"id": "shop1",
				"text": "\t[贪婪之神,moneyShop]勇敢的武士啊, 给我${20+2*flag:shop1}金币就可以：",
				"textInList": "1F金币商店",
				"mustEnable": false,
				"disablePreview": false,
				"choices": [
					{
						"text": "生命+800",
						"need": "status:money>=20+2*flag:shop1",
						"action": [
							{
								"type": "comment",
								"text": "新版商店中需要手动扣减金币和增加访问次数"
							},
							{
								"type": "setValue",
								"name": "status:money",
								"operator": "-=",
								"value": "20+2*flag:shop1"
							},
							{
								"type": "setValue",
								"name": "flag:shop1",
								"operator": "+=",
								"value": "1"
							},
							{
								"type": "setValue",
								"name": "status:hp",
								"operator": "+=",
								"value": "800"
							}
						]
					},
					{
						"text": "攻击+4",
						"need": "status:money>=20+2*flag:shop1",
						"action": [
							{
								"type": "comment",
								"text": "新版商店中需要手动扣减金币和增加访问次数"
							},
							{
								"type": "setValue",
								"name": "status:money",
								"operator": "-=",
								"value": "20+2*flag:shop1"
							},
							{
								"type": "setValue",
								"name": "flag:shop1",
								"operator": "+=",
								"value": "1"
							},
							{
								"type": "setValue",
								"name": "status:atk",
								"operator": "+=",
								"value": "4"
							}
						]
					}
				]
			},
			{
				"id": "shop2",
				"text": "\t[贪婪之神,expShop]勇敢的武士啊, 给我一定经验就可以：",
				"textInList": "1F经验商店",
				"mustEnable": false,
				"disablePreview": true,
				"choices": [
					{
						"text": "等级+1（100经验）",
						"need": "status:exp>=100",
						"action": [
							{
								"type": "setValue",
								"name": "status:exp",
								"operator": "-=",
								"value": "100"
							},
							{
								"type": "setValue",
								"name": "status:lv",
								"operator": "+=",
								"value": "1"
							},
							{
								"type": "setValue",
								"name": "status:hp",
								"operator": "+=",
								"value": "1000"
							}
						]
					}
				]
			},
			{
				"id": "itemShop",
				"item": true,
				"textInList": "道具商店",
				"mustEnable": false,
				"choices": [
					{
						"id": "yellowKey",
						"number": 10,
						"money": "10",
						"sell": "5"
					}
				]
			},
			{
				"id": "keyShop",
				"textInList": "回收钥匙商店",
				"mustEnable": false,
				"commonEvent": "回收钥匙商店"
			}
		],
		"levelUp": [
			{
				"need": "0",
				"title": "",
				"action": [
					{
						"type": "comment",
						"text": "此处是初始等级，只需填写称号"
					}
				]
			},
			{
				"need": "20",
				"title": "",
				"action": [
					{
						"type": "setValue",
						"name": "status:atk",
						"operator": "+=",
						"value": "10"
					},
					{
						"type": "setValue",
						"name": "status:def",
						"operator": "+=",
						"value": "10"
					}
				]
			},
			{
				"need": "40",
				"title": "",
				"action": [
					{
						"type": "tip",
						"text": "恭喜升级"
					}
				]
			}
		]
	},
	"values": {
		"lavaDamage": 100,
		"poisonDamage": 10,
		"weakValue": 20,
		"redGem": 1,
		"blueGem": 1,
		"greenGem": 2,
		"redPotion": 50,
		"bluePotion": 100,
		"yellowPotion": 200,
		"greenPotion": 20,
		"breakArmor": 0.9,
		"counterAttack": 0.1,
		"purify": 3,
		"hatred": 2,
		"animateSpeed": 300,
		"moveSpeed": 100,
		"statusCanvasRowsOnMobile": 3,
		"floorChangeTime": 100
	},
	"flags": {
		"statusBarItems": [
			"enableFloor",
			"enableLv",
			"enableHP",
			"enableMana",
			"enableAtk",
			"enableDef",
			"enableMDef",
			"enableMoney",
			"enableExp",
			"enableKeys",
			"enablePZF",
			"enableSkill"
		],
		"autoScale": true,
		"extendToolbar": false,
		"flyNearStair": true,
		"flyRecordPosition": false,
		"itemFirstText": false,
		"equipboxButton": false,
		"enableAddPoint": false,
		"enableNegativeDamage": false,
		"betweenAttackMax": false,
		"useLoop": false,
		"startUsingCanvas": false,
		"statusCanvas": false,
		"enableEnemyPoint": true,
		"enableGentleClick": true,
		"ignoreChangeFloor": true,
		"canGoDeadZone": false,
		"enableMoveDirectly": true,
		"enableRouteFolding": true,
		"disableShopOnDamage": false,
		"blurFg": false,
		"hideLeftStatusBar": false
	}
}