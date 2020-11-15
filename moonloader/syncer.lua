local imgui = require('imgui')
local event = require('lib.samp.events')
local encoding = require('encoding')

encoding.default = 'CP1251'
local u8 = encoding.UTF8

local menu_state = imgui.ImBool(false)

local menu_page = 0
local tab_page = 0

local btn_size = imgui.ImVec2(-0.1, 30)
local btn_size_small = imgui.ImVec2(150, 20)
local btn_size_very_small = imgui.ImVec2(112, 20)

local rpc = {
	hook = {
		entervehicle = {
			nop = imgui.ImBool(false),
			vehId = {
				state = imgui.ImBool(false),
				id = imgui.ImInt(0)
			},
			passenger = {
				state = imgui.ImBool(false),
				is = imgui.ImBool(false)
			}
		},
		clickplayer = {
			nop = imgui.ImBool(false),
			playerId = {
				state = imgui.ImBool(false),
				id = imgui.ImInt(0)
			},
			source = {
				state = imgui.ImBool(false),
				count = imgui.ImInt(0)
			}
		},
		clientjoin = {
			nop = imgui.ImBool(false),
			version = {
				state = imgui.ImBool(false),
				count = imgui.ImInt(0)
			},
			mod = {
				state = imgui.ImBool(false),
				count = imgui.ImInt(0)
			},
			nickname = {
				state = imgui.ImBool(false),
				count = imgui.ImBuffer(32)
			},
			challengeResponse = {
				state = imgui.ImBool(false),
				count = imgui.ImInt(0)
			},
			joinauthkey = {
				state = imgui.ImBool(false),
				count = imgui.ImBuffer(256)
			},
			clientVer = {
				state = imgui.ImBool(false),
				count = imgui.ImBuffer(256)
			},
			unknown = {
				state = imgui.ImBool(false),
				count = imgui.ImInt(0)
			}
		},
		entereditobject = {
			nop = imgui.ImBool(false),
			type = {
				state = imgui.ImBool(false),
				count = imgui.ImInt(0)
			},
			objectid = {
				state = imgui.ImBool(false),
				id = imgui.ImInt(0)
			},
			model = {
				state = imgui.ImBool(false),
				id = imgui.ImInt(0)
			},
			pos = {
				state = imgui.ImBool(false),
				x = imgui.ImFloat(0),
				y = imgui.ImFloat(0),
				z = imgui.ImFloat(0)
			}
		},
		--[[sendcommand = {
			nop = imgui.ImBool(false),
			cmd = {
				state = imgui.ImBool(false),
				count = imgui.ImBuffer(256)
			}
		},]]
		spawn = {
			nop = imgui.ImBool(false)
		},
		death = {
			nop = imgui.ImBool(false),
			reason = {
				state = imgui.ImBool(false),
				count = imgui.ImInt(0)
			},
			killerid = {
				state = imgui.ImBool(false),
				id = imgui.ImInt(0)
			}
		},
		dialogresponse = {
			nop = imgui.ImBool(false),
			dialogid = {
				state = imgui.ImBool(false),
				id = imgui.ImInt(0)
			},
			button = {
				state = imgui.ImBool(false),
				count = imgui.ImInt(0)
			},
			listboxid = {
				state = imgui.ImBool(false),
				count = imgui.ImInt(0)
			},
			input = {
				state = imgui.ImBool(false),
				count = imgui.ImBuffer(256)
			}
		},
		clicktextdraw = {
			nop = imgui.ImBool(false),
			textdrawid = {
				state = imgui.ImBool(false),
				id = imgui.ImInt(0)
			}
		},
		vehicletuning = {
			nop = imgui.ImBool(false),
			vehid = {
				state = imgui.ImBool(false),
				id = imgui.ImInt(0)
			},
			param1 = {
				state = imgui.ImBool(false),
				count = imgui.ImInt(0)
			},
			param2 = {
				state = imgui.ImBool(false),
				count = imgui.ImInt(0)
			},
			event = {
				state = imgui.ImBool(false),
				count = imgui.ImInt(0)
			}
		},
		chat = {
			nop = imgui.ImBool(false),
			msg = {
				state = imgui.ImBool(false),
				count = imgui.ImBuffer(256)
			}
		},
		vehicledamaged = {
			nop = imgui.ImBool(false),
			vehid = {
				state = imgui.ImBool(false),
				id = imgui.ImInt(0)
			},
			paneldmg = {
				state = imgui.ImBool(false),
				count = imgui.ImInt(0)
			},
			doordmg = {
				state = imgui.ImBool(false),
				count = imgui.ImInt(0)
			},
			lights = {
				state = imgui.ImBool(false),
				count = imgui.ImInt(0)
			},
			tires = {
				state = imgui.ImBool(false),
				count = imgui.ImInt(0)
			}
		},
		editattachedobject = {
			nop = imgui.ImBool(false),
			response = {
				state = imgui.ImBool(false),
				count = imgui.ImInt(0)
			},
			index = {
				state = imgui.ImBool(false),
				count = imgui.ImInt(0)
			},
			model = {
				state = imgui.ImBool(false),
				count = imgui.ImInt(0)
			},
			bone = {
				state = imgui.ImBool(false),
				count = imgui.ImInt(0)
			},
			pos = {
				state = imgui.ImBool(false),
				x = imgui.ImFloat(0),
				y = imgui.ImFloat(0),
				z = imgui.ImFloat(0)
			},
			rotation = {
				state = imgui.ImBool(false),
				x = imgui.ImFloat(0),
				y = imgui.ImFloat(0),
				z = imgui.ImFloat(0)
			},
			scale = {
				state = imgui.ImBool(false),
				x = imgui.ImFloat(0),
				y = imgui.ImFloat(0),
				z = imgui.ImFloat(0)
			},
			color1 = {
				state = imgui.ImBool(false),
				count = imgui.ImInt(0)
			},
			color2 = {
				state = imgui.ImBool(false),
				count = imgui.ImInt(0)
			}
		},
		editobject = {
			nop = imgui.ImBool(false),
			playerobject = {
				state = imgui.ImBool(false),
				count = imgui.ImBool(false)
			},
			objectid = {
				state = imgui.ImBool(false),
				count = imgui.ImInt(0)
			},
			response = {
				state = imgui.ImBool(false),
				count = imgui.ImInt(0)
			},
			pos = {
				state = imgui.ImBool(false),
				x = imgui.ImFloat(0),
				y = imgui.ImFloat(0),
				z = imgui.ImFloat(0)
			},
			rotation = {
				state = imgui.ImBool(false),
				x = imgui.ImFloat(0),
				y = imgui.ImFloat(0),
				z = imgui.ImFloat(0)
			}
		},
		interiorchange = {
			nop = imgui.ImBool(false),
			interiorid = {
				state = imgui.ImBool(false),
				id = imgui.ImInt(0)
			}
		},
		mapmarker = {
			nop = imgui.ImBool(false),
			pos = {
				state = imgui.ImBool(false),
				x = imgui.ImFloat(0),
				y = imgui.ImFloat(0),
				z = imgui.ImFloat(0)
			}
		},
		requestclass = {
			nop = imgui.ImBool(false),
			classid = {
				state = imgui.ImBool(false),
				id = imgui.ImInt(0)
			}
		},
		requestspawn = {
			nop = imgui.ImBool(false)
		},
		pickeduppickup = {
			nop = imgui.ImBool(false),
			pickupid = {
				state = imgui.ImBool(false),
				id = imgui.ImInt(0)
			}
		},
		menuselect = {
			nop = imgui.ImBool(false),
			row = {
				state = imgui.ImBool(false),
				count = imgui.ImInt(0)
			}
		},
		vehicledestroyed = {
			nop = imgui.ImBool(false),
			vehicleid = {
				state = imgui.ImBool(false),
				id = imgui.ImInt(0)
			}
		},
		quitmenu = {
			nop = imgui.ImBool(false)
		},
		exitvehicle = {
			nop = imgui.ImBool(false),
			vehicleid = {
				state = imgui.ImBool(false),
				id = imgui.ImInt(0)
			}
		},
		updatescoresandpings = {
			nop = imgui.ImBool(false)
		},
		givedamage = {
			nop = imgui.ImBool(false),
			playerid = {
				state = imgui.ImBool(false),
				id = imgui.ImInt(0)
			},
			damage = {
				state = imgui.ImBool(false),
				count = imgui.ImFloat(0)
			},
			weapon = {
				state = imgui.ImBool(false),
				id = imgui.ImInt(0)
			},
			bodypart = {
				state = imgui.ImBool(false),
				id = imgui.ImInt(0)
			},
		},
		takedamage = {
			nop = imgui.ImBool(false),
			playerid = {
				state = imgui.ImBool(false),
				id = imgui.ImInt(0)
			},
			damage = {
				state = imgui.ImBool(false),
				count = imgui.ImFloat(0)
			},
			weapon = {
				state = imgui.ImBool(false),
				id = imgui.ImInt(0)
			},
			bodypart = {
				state = imgui.ImBool(false),
				id = imgui.ImInt(0)
			},
		}
	},
	send = {
		entervehicle = {
			vehId = imgui.ImInt(0),
			passenger = imgui.ImBool(false)
		},
		clickplayer = {
			playerId = imgui.ImInt(0),
			source = imgui.ImInt(0)
		},
		clientjoin = {
			version = imgui.ImInt(0),
			mod = imgui.ImInt(0),
			nickname = imgui.ImBuffer(32),
			challengeResponse = imgui.ImInt(0),
			joinauthkey = imgui.ImBuffer(256),
			clientVer = imgui.ImBuffer(256),
			unknown = imgui.ImInt(0)
		},
		entereditobject = {
			type = imgui.ImInt(0),
			objectid = imgui.ImInt(0),
			model = imgui.ImInt(0),
			pos = {
				x = imgui.ImFloat(0),
				y = imgui.ImFloat(0),
				z = imgui.ImFloat(0)
			}
		},
		--[[sendcommand = {
			cmd = imgui.ImBuffer(256)
		},]]
		spawn = {
			empty = nil
		},
		death = {
			reason = imgui.ImInt(0),
			killerid = imgui.ImInt(0)
		},
		dialogresponse = {
			dialogid = imgui.ImInt(0),
			button = imgui.ImInt(0),
			listboxid = imgui.ImInt(0),
			input = imgui.ImBuffer(256)
		},
		clicktextdraw = {
			textdrawid = imgui.ImInt(0)
		},
		vehicletuning = {
			vehid = imgui.ImInt(0),
			param1 = imgui.ImInt(0),
			param2 = imgui.ImInt(0),
			event = imgui.ImInt(0)
		},
		chat = {
			msg = imgui.ImBuffer(256)
		},
		vehicledamaged = {
			vehid = imgui.ImInt(0),
			paneldmg = imgui.ImInt(0),
			doordmg = imgui.ImInt(0),
			lights = imgui.ImInt(0),
			tires = imgui.ImInt(0)
		},
		editattachedobject = {
			response = imgui.ImInt(0),
			index = imgui.ImInt(0),
			model = imgui.ImInt(0),
			bone = imgui.ImInt(0),
			pos = {
				x = imgui.ImFloat(0),
				y = imgui.ImFloat(0),
				z = imgui.ImFloat(0)
			},
			rotation = {
				x = imgui.ImFloat(0),
				y = imgui.ImFloat(0),
				z = imgui.ImFloat(0)
			},
			scale = {
				x = imgui.ImFloat(0),
				y = imgui.ImFloat(0),
				z = imgui.ImFloat(0)
			},
			color1 = imgui.ImInt(0),
			color2 = imgui.ImInt(0)
		},
		editobject = {
			playerobject = imgui.ImBool(false),
			objectid = imgui.ImInt(0),
			response = imgui.ImInt(0),
			pos = {
				x = imgui.ImFloat(0),
				y = imgui.ImFloat(0),
				z = imgui.ImFloat(0)
			},
			rotation = {
				x = imgui.ImFloat(0),
				y = imgui.ImFloat(0),
				z = imgui.ImFloat(0)
			}
		},
		interiorchange = {
			interiorid = imgui.ImInt(0)
		},
		mapmarker = {
			pos = {
				x = imgui.ImFloat(0),
				y = imgui.ImFloat(0),
				z = imgui.ImFloat(0)
			}
		},
		requestclass = {
			classid = imgui.ImInt(0)
		},
		requestspawn = {
			empty = nil
		},
		pickeduppickup = {
			pickupid = imgui.ImInt(0)
		},
		menuselect = {
			row = imgui.ImInt(0)
		},
		vehicledestroyed = {
			vehicleid = imgui.ImInt(0)
		},
		quitmenu = {
			empty = nil
		},
		exitvehicle = {
			vehicleid = imgui.ImInt(0)
		},
		updatescoresandpings = {
			empty = nil
		},
		givedamage = {
			playerid = imgui.ImInt(0),
			damage = imgui.ImFloat(0),
			weapon = imgui.ImInt(0),
			bodypart = imgui.ImInt(0)
		},
		takedamage = {
			playerid = imgui.ImInt(0),
			damage = imgui.ImFloat(0),
			weapon = imgui.ImInt(0),
			bodypart = imgui.ImInt(0)
		}
	}
}

local packet = {
	hook = {
		vehicle = {
			nop = imgui.ImBool(false),
			veh = {
				state = imgui.ImBool(false),
				id = imgui.ImInt(0)
			},
			pos = {
				state = imgui.ImBool(false),
				x = imgui.ImFloat(0),
				y = imgui.ImFloat(0),
				z = imgui.ImFloat(0)
			},
			quaternion = {
				state = imgui.ImBool(false),
				x = imgui.ImFloat(0),
				y = imgui.ImFloat(0),
				z = imgui.ImFloat(0),
				w = imgui.ImFloat(0)
			},
			moveSpeed = {
				state = imgui.ImBool(false),
				x = imgui.ImFloat(0),
				y = imgui.ImFloat(0),
				z = imgui.ImFloat(0)
			},
			health = {
				state = imgui.ImBool(false),
				playerHealth = imgui.ImFloat(0),
				vehHealth = imgui.ImFloat(0)
			},
			armor = {
				state = imgui.ImBool(false),
				count = imgui.ImFloat(0)
			},
			weapon = {
				state = imgui.ImBool(false),
				id = imgui.ImInt(0)
			},
			siren = {
				state = imgui.ImBool(false),
				count = imgui.ImInt(0)
			},
			trailer = {
				state = imgui.ImBool(false),
				id = imgui.ImInt(0)
			},
			trainSpeed = {
				state = imgui.ImBool(false),
				speed = imgui.ImFloat(0)
			}
		},
		player = {
			nop = imgui.ImBool(false),
			pos = {
				state = imgui.ImBool(false),
				x = imgui.ImFloat(0),
				y = imgui.ImFloat(0),
				z = imgui.ImFloat(0)
			},
			quaternion = {
				state = imgui.ImBool(false),
				x = imgui.ImFloat(0),
				y = imgui.ImFloat(0),
				z = imgui.ImFloat(0),
				w = imgui.ImFloat(0)
			},
			health = {
				state = imgui.ImBool(false),
				count = imgui.ImFloat(0)
			},
			armor = {
				state = imgui.ImBool(false),
				count = imgui.ImFloat(0)
			},
			weapon = {
				state = imgui.ImBool(false),
				id = imgui.ImInt(0)
			},
			specialAction = {
				state = imgui.ImBool(false),
				id = imgui.ImInt(0)
			},
			moveSpeed = {
				state = imgui.ImBool(false),
				x = imgui.ImFloat(0),
				y = imgui.ImFloat(0),
				z = imgui.ImFloat(0)
			},
			surfing = {
				state = imgui.ImBool(false),
				vehId = imgui.ImInt(0),
				offset_x = imgui.ImFloat(0),
				offset_y = imgui.ImFloat(0),
				offset_z = imgui.ImFloat(0)
			},
			animation = {
				state = imgui.ImBool(false),
				id = imgui.ImInt(0),
				flags = imgui.ImInt(0)
			}
		},
		passenger = {
			nop = imgui.ImBool(false),
			veh = {
				state = imgui.ImBool(false),
				id = imgui.ImInt(0)
			},
			seat = {
				state = imgui.ImBool(false),
				id = imgui.ImInt(0)
			},
			weapon = {
				state = imgui.ImBool(false),
				id = imgui.ImInt(0)
			},
			health = {
				state = imgui.ImBool(false),
				count = imgui.ImFloat(0)
			},
			armor = {
				state = imgui.ImBool(false),
				count = imgui.ImFloat(0)
			},
			pos = {
				state = imgui.ImBool(false),
				x = imgui.ImFloat(0),
				y = imgui.ImFloat(0),
				z = imgui.ImFloat(0)
			}
		},
		unoccupied = {
			nop = imgui.ImBool(false),
			veh = {
				state = imgui.ImBool(false),
				id = imgui.ImInt(0)
			},
			seat = {
				state = imgui.ImBool(false),
				id = imgui.ImInt(0)
			},
			pos = {
				state = imgui.ImBool(false),
				x = imgui.ImFloat(0),
				y = imgui.ImFloat(0),
				z = imgui.ImFloat(0)
			},
			roll = {
				state = imgui.ImBool(false),
				x = imgui.ImFloat(0),
				y = imgui.ImFloat(0),
				z = imgui.ImFloat(0)
			},
			direction = {
				state = imgui.ImBool(false),
				x = imgui.ImFloat(0),
				y = imgui.ImFloat(0),
				z = imgui.ImFloat(0)
			},
			moveSpeed = {
				state = imgui.ImBool(false),
				x = imgui.ImFloat(0),
				y = imgui.ImFloat(0),
				z = imgui.ImFloat(0)
			},
			turnSpeed = {
				state = imgui.ImBool(false),
				x = imgui.ImFloat(0),
				y = imgui.ImFloat(0),
				z = imgui.ImFloat(0)
			},
			health = {
				state = imgui.ImBool(false),
				vehHealth = imgui.ImFloat(0)
			}
		},
		aim = {
			nop = imgui.ImBool(false),
			camMode = {
				state = imgui.ImBool(false),
				mode = imgui.ImInt(0)
			},
			camFront = {
				state = imgui.ImBool(false),
				x = imgui.ImFloat(0),
				y = imgui.ImFloat(0),
				z = imgui.ImFloat(0)
			},
			camPos = {
				state = imgui.ImBool(false),
				x = imgui.ImFloat(0),
				y = imgui.ImFloat(0),
				z = imgui.ImFloat(0)
			},
			aimZ = {
				state = imgui.ImBool(false),
				count = imgui.ImFloat(0)
			},
			camExtZoom = {
				state = imgui.ImBool(false),
				count = imgui.ImInt(0)
			},
			weaponState = {
				state = imgui.ImBool(false),
				count = imgui.ImInt(0)
			},
			unknown = {
				state = imgui.ImBool(false),
				count = imgui.ImInt(0)
			}
		},
		trailer = {
			nop = imgui.ImBool(false),
			veh = {
				state = imgui.ImBool(false),
				id = imgui.ImInt(0)
			},
			pos = {
				state = imgui.ImBool(false),
				x = imgui.ImFloat(0),
				y = imgui.ImFloat(0),
				z = imgui.ImFloat(0)
			},
			roll = {
				state = imgui.ImBool(false),
				x = imgui.ImFloat(0),
				y = imgui.ImFloat(0),
				z = imgui.ImFloat(0)
			},
			direction = {
				state = imgui.ImBool(false),
				x = imgui.ImFloat(0),
				y = imgui.ImFloat(0),
				z = imgui.ImFloat(0)
			},
			speed = {
				state = imgui.ImBool(false),
				x = imgui.ImFloat(0),
				y = imgui.ImFloat(0),
				z = imgui.ImFloat(0)
			},
			unk = {
				state = imgui.ImBool(false),
				count = imgui.ImInt(0)
			}
		},
		spectator = {
			nop = imgui.ImBool(false),
			pos = {
				state = imgui.ImBool(false),
				x = imgui.ImFloat(0),
				y = imgui.ImFloat(0),
				z = imgui.ImFloat(0)
			}
		},
		bullet = {
			nop = imgui.ImBool(false),
			targetType = {
				state = imgui.ImBool(false),
				count = imgui.ImInt(0)
			},
			targetId = {
				state = imgui.ImBool(false),
				count = imgui.ImInt(0)
			},
			origin = {
				state = imgui.ImBool(false),
				x = imgui.ImFloat(0),
				y = imgui.ImFloat(0),
				z = imgui.ImFloat(0)
			},
			target = {
				state = imgui.ImBool(false),
				x = imgui.ImFloat(0),
				y = imgui.ImFloat(0),
				z = imgui.ImFloat(0)
			},
			center = {
				state = imgui.ImBool(false),
				x = imgui.ImFloat(0),
				y = imgui.ImFloat(0),
				z = imgui.ImFloat(0)
			},
			weapon = {
				state = imgui.ImBool(false),
				id = imgui.ImInt(0)
			}
		}
	},
	send = {
		vehicle = {
			vehid = imgui.ImInt(0),
			pos = {
				x = imgui.ImFloat(0),
				y = imgui.ImFloat(0),
				z = imgui.ImFloat(0)
			},
			quaternion = {
				x = imgui.ImFloat(0),
				y = imgui.ImFloat(0),
				z = imgui.ImFloat(0),
				w = imgui.ImFloat(0)
			},
			moveSpeed = {
				x = imgui.ImFloat(0),
				y = imgui.ImFloat(0),
				z = imgui.ImFloat(0)
			},
			health = {
				playerHealth = imgui.ImFloat(0),
				vehHealth = imgui.ImFloat(0)
			},
			armor = imgui.ImFloat(0),
			weapon = imgui.ImInt(0),
			siren = imgui.ImInt(0),
			trailerid = imgui.ImInt(0),
			trainSpeed = imgui.ImFloat(0)
		},
		player = {
			pos = {
				x = imgui.ImFloat(0),
				y = imgui.ImFloat(0),
				z = imgui.ImFloat(0)
			},
			quaternion = {
				x = imgui.ImFloat(0),
				y = imgui.ImFloat(0),
				z = imgui.ImFloat(0),
				w = imgui.ImFloat(0)
			},
			health = imgui.ImFloat(0),
			armor = imgui.ImFloat(0),
			weapon = imgui.ImInt(0),
			specialAction = imgui.ImInt(0),
			moveSpeed = {
				x = imgui.ImFloat(0),
				y = imgui.ImFloat(0),
				z = imgui.ImFloat(0)
			},
			surfing = {
				vehId = imgui.ImInt(0),
				offset_x = imgui.ImFloat(0),
				offset_y = imgui.ImFloat(0),
				offset_z = imgui.ImFloat(0)
			},
			animation = {
				id = imgui.ImInt(0),
				flags = imgui.ImInt(0)
			}
		},
		passenger = {
			vehid = imgui.ImInt(0),
			seat = imgui.ImInt(0),
			weapon = imgui.ImInt(0),
			health = imgui.ImFloat(0),
			armor = imgui.ImFloat(0),
			pos = {
				x = imgui.ImFloat(0),
				y = imgui.ImFloat(0),
				z = imgui.ImFloat(0)
			}
		},
		unoccupied = {
			vehid = imgui.ImInt(0),
			seat = imgui.ImInt(0),
			pos = {
				x = imgui.ImFloat(0),
				y = imgui.ImFloat(0),
				z = imgui.ImFloat(0)
			},
			roll = {
				x = imgui.ImFloat(0),
				y = imgui.ImFloat(0),
				z = imgui.ImFloat(0)
			},
			direction = {
				x = imgui.ImFloat(0),
				y = imgui.ImFloat(0),
				z = imgui.ImFloat(0)
			},
			moveSpeed = {
				x = imgui.ImFloat(0),
				y = imgui.ImFloat(0),
				z = imgui.ImFloat(0)
			},
			turnSpeed = {
				x = imgui.ImFloat(0),
				y = imgui.ImFloat(0),
				z = imgui.ImFloat(0)
			},
			health = imgui.ImFloat(0)
		},
		aim = {
			camMode = imgui.ImInt(0),
			camFront = {
				x = imgui.ImFloat(0),
				y = imgui.ImFloat(0),
				z = imgui.ImFloat(0)
			},
			camPos = {
				x = imgui.ImFloat(0),
				y = imgui.ImFloat(0),
				z = imgui.ImFloat(0)
			},
			aimZ = imgui.ImFloat(0),
			camExtZoom = imgui.ImInt(0),
			weaponState = imgui.ImInt(0),
			unknown = imgui.ImInt(0)
		},
		trailer = {
			trailerid = imgui.ImInt(0),
			pos = {
				x = imgui.ImFloat(0),
				y = imgui.ImFloat(0),
				z = imgui.ImFloat(0)
			},
			roll = {
				x = imgui.ImFloat(0),
				y = imgui.ImFloat(0),
				z = imgui.ImFloat(0)
			},
			direction = {
				x = imgui.ImFloat(0),
				y = imgui.ImFloat(0),
				z = imgui.ImFloat(0)
			},
			speed = {
				x = imgui.ImFloat(0),
				y = imgui.ImFloat(0),
				z = imgui.ImFloat(0)
			},
			unk = imgui.ImInt(0)
		},
		spectator = {
			pos = {
				x = imgui.ImFloat(0),
				y = imgui.ImFloat(0),
				z = imgui.ImFloat(0)
			}
		},
		bullet = {
			targetType =imgui.ImInt(0),
			targetId = imgui.ImInt(0),
			origin = {
				x = imgui.ImFloat(0),
				y = imgui.ImFloat(0),
				z = imgui.ImFloat(0)
			},
			target = {
				x = imgui.ImFloat(0),
				y = imgui.ImFloat(0),
				z = imgui.ImFloat(0)
			},
			center = {
				x = imgui.ImFloat(0),
				y = imgui.ImFloat(0),
				z = imgui.ImFloat(0)
			},
			weapon = imgui.ImInt(0)
		}
	}
}

function imgui.OnDrawFrame()
	if menu_state.v then
		local xw, yw = getScreenResolution()
		imgui.SetNextWindowPos(imgui.ImVec2(xw / 2 - 200, yw / 2), imgui.WindowFlags.NoResize)
		imgui.SetNextWindowSize(imgui.ImVec2(710, 400), imgui.WindowFlags.NoResize)
		imgui.Begin(u8'Syncer', menu_state, imgui.WindowFlags.NoResize)
		imgui.BeginChild(u8'##lefttab', imgui.ImVec2(200, 365), true)
		if imgui.Button(u8'Перехваты / Хуки', btn_size) then
			menu_page = 1
		end
		if menu_page == 1 then
			empty()
			if imgui.Button(u8'Перехват RPC', btn_size_small) then
				menu_page = 1.1
				tab_page = 0
			end
			empty()
			if imgui.Button(u8'Перехват пакетов', btn_size_small) then
				menu_page = 1.2
				tab_page = 0
			end
		end
		if imgui.Button(u8'Отправка', btn_size) then
			menu_page = 2
		end
		if menu_page == 2 then
			empty()
			if imgui.Button(u8'Отправка RPC', btn_size_small) then
				menu_page = 2.1
				tab_page = 0
			end
			empty()
			if imgui.Button(u8'Отправка пакетов', btn_size_small) then
				menu_page = 2.2
				tab_page = 0
			end
		end
		imgui.EndChild()
		imgui.SameLine()
		imgui.BeginChild(u8'##righttab', imgui.ImVec2(510, 365), false)
		imgui.BeginChild(u8'##toptab', imgui.ImVec2(490, 55), true)
		if menu_page == 1.1 or menu_page == 2.1 then
			rpc_tab()
		end
		if menu_page == 1.2 or menu_page == 2.2 then
			if imgui.Button(u8'Player sync', btn_size_very_small) then
				tab_page = 1
			end
			imgui.SameLine()
			if imgui.Button(u8'Vehicle sync', btn_size_very_small) then
				tab_page = 2
			end
			imgui.SameLine()
			if imgui.Button(u8'Passenger sync', btn_size_very_small) then
				tab_page = 3
			end
			imgui.SameLine()
			if imgui.Button(u8'Aim sync', btn_size_very_small) then
				tab_page = 4
			end
			if imgui.Button(u8'Trailer sync', btn_size_very_small) then
				tab_page = 5
			end
			imgui.SameLine()
			if imgui.Button(u8'Unoccupied sync', btn_size_very_small) then
				tab_page = 6
			end
			imgui.SameLine()
			if imgui.Button(u8'Spectator sync', btn_size_very_small) then
				tab_page = 7
			end
			imgui.SameLine()
			if imgui.Button(u8'Bullet sync', btn_size_very_small) then
				tab_page = 8
			end
		end
		imgui.EndChild()
		imgui.BeginChild(u8'##options', imgui.ImVec2(490, 305), true)
		if menu_page == 2.1 then
			sendrpcs()
		end
		if menu_page == 2.2 then
			sendpackets()
		end
		if menu_page == 1.1 then
			rpcnops()
			if tab_page ~= 0 then
				imgui.Separator()
			end
		end
		if menu_page == 1.1 or menu_page == 2.1 then
			imgui.BeginChild('##block1', imgui.ImVec2(200, 250), false)
			if tab_page == 1 and (menu_page == 1.1 and not rpc.hook.entervehicle.nop.v or menu_page == 2.1) then
				entervehicle_imgui1()
			end
			if tab_page == 2 and (menu_page == 1.1 and not rpc.hook.clickplayer.nop.v or menu_page == 2.1) then
				clickplayer_imgui1()
			end
			if tab_page == 3 and (menu_page == 1.1 and not rpc.hook.clientjoin.nop.v or menu_page == 2.1) then
				clientjoin_imgui1()
			end
			if tab_page == 4 and (menu_page == 1.1 and not rpc.hook.entereditobject.nop.v or menu_page == 2.1) then
				entereditobject_imgui1()
			end
			--[[if tab_page == 5 and not rpc.hook.sendcommand.nop.v then
				sendcommand_imgui1()
			end]]
			if tab_page == 7 and (menu_page == 1.1 and not rpc.hook.death.nop.v or menu_page == 2.1) then
				death_imgui1()
			end
			if tab_page == 8 and (menu_page == 1.1 and not rpc.hook.dialogresponse.nop.v or menu_page == 2.1) then
				dialogresponse_imgui1()
			end
			if tab_page == 9 and (menu_page == 1.1 and not rpc.hook.clicktextdraw.nop.v or menu_page == 2.1) then
				clicktextdraw_imgui1()
			end
			if tab_page == 10 and (menu_page == 1.1 and not rpc.hook.vehicletuning.nop.v or menu_page == 2.1) then
				vehicletuning_imgui1()
			end
			if tab_page == 11 and (menu_page == 1.1 and not rpc.hook.chat.nop.v or menu_page == 2.1) then
				chat_imgui1()
			end
			if tab_page == 12 and (menu_page == 1.1 and not rpc.hook.vehicledamaged.nop.v or menu_page == 2.1) then
				vehicledamaged_imgui1()
			end
			if tab_page == 13 and (menu_page == 1.1 and not rpc.hook.editattachedobject.nop.v or menu_page == 2.1) then
				editattachedobject_imgui1()
			end
			if tab_page == 14 and (menu_page == 1.1 and not rpc.hook.editobject.nop.v or menu_page == 2.1) then
				editobject_imgui1()
			end
			if tab_page == 15 and (menu_page == 1.1 and not rpc.hook.interiorchange.nop.v or menu_page == 2.1) then
				interiorchange_imgui1()
			end
			if tab_page == 16 and (menu_page == 1.1 and not rpc.hook.mapmarker.nop.v or menu_page == 2.1) then
				mapmarker_imgui1()
			end
			if tab_page == 17 and (menu_page == 1.1 and not rpc.hook.requestclass.nop.v or menu_page == 2.1) then
				requestclass_imgui1()
			end
			if tab_page == 18 and (menu_page == 1.1 and not rpc.hook.pickeduppickup.nop.v or menu_page == 2.1) then
				pickeduppickup_imgui1()
			end
			if tab_page == 19 and (menu_page == 1.1 and not rpc.hook.menuselect.nop.v or menu_page == 2.1) then
				menuselect_imgui1()
			end
			if tab_page == 20 and (menu_page == 1.1 and not rpc.hook.vehicledestroyed.nop.v or menu_page == 2.1) then
				vehicledestroyed_imgui1()
			end
			if tab_page == 21 and (menu_page == 1.1 and not rpc.hook.exitvehicle.nop.v or menu_page == 2.1) then
				exitvehicle_imgui1()
			end
			if tab_page == 25 and (menu_page == 1.1 and not rpc.hook.takedamage.nop.v or menu_page == 2.1) then
				takedamage_imgui1()
			end
			if tab_page == 26 and (menu_page == 1.1 and not rpc.hook.givedamage.nop.v or menu_page == 2.1) then
				givedamage_imgui1()
			end
			imgui.EndChild()
			imgui.SameLine()
			imgui.BeginChild('##block2', imgui.ImVec2(290, 250), false)
			if tab_page == 3 and (menu_page == 1.1 and not rpc.hook.clientjoin.nop.v or menu_page == 2.1) then
				clientjoin_imgui2()
			end
			if tab_page == 4 and (menu_page == 1.1 and not rpc.hook.entereditobject.nop.v or menu_page == 2.1) then
				entereditobject_imgui2()
			end
			if tab_page == 8 and (menu_page == 1.1 and not rpc.hook.dialogresponse.nop.v or menu_page == 2.1) then
				dialogresponse_imgui2()
			end
			if tab_page == 10 and (menu_page == 1.1 and not rpc.hook.vehicletuning.nop.v or menu_page == 2.1) then
				vehicletuning_imgui2()
			end
			if tab_page == 12 and (menu_page == 1.1 and not rpc.hook.vehicledamaged.nop.v or menu_page == 2.1) then
				vehicledamaged_imgui2()
			end
			if tab_page == 13 and (menu_page == 1.1 and not rpc.hook.editattachedobject.nop.v or menu_page == 2.1) then
				editattachedobject_imgui2()
			end
			if tab_page == 14 and (menu_page == 1.1 and not rpc.hook.editobject.nop.v or menu_page == 2.1) then
				editobject_imgui2()
			end
			if tab_page == 25 and (menu_page == 1.1 and not rpc.hook.takedamage.nop.v or menu_page == 2.1) then
				takedamage_imgui2()
			end
			if tab_page == 26 and (menu_page == 1.1 and not rpc.hook.givedamage.nop.v or menu_page == 2.1) then
				givedamage_imgui2()
			end
			imgui.EndChild()
		end
		if menu_page == 1.2 then
		if tab_page == 1 then
			imgui.Checkbox('NOP##psync', packet.hook.player.nop)
			if isCharInAnyCar(PLAYER_PED) and not packet.hook.player.nop.v then
				imgui.TextColoredRGB('{FF5656}Внимание! Вы находитесь в авто!')
			end
		end
		if tab_page == 2 then
			imgui.Checkbox('NOP##vsync', packet.hook.vehicle.nop)
			if isCharOnFoot(PLAYER_PED) and not packet.hook.vehicle.nop.v then
				imgui.TextColoredRGB('{FF5656}Внимание! Вы находитесь не в авто!')
			end
		end
		if tab_page == 3 then
			imgui.Checkbox('NOP##psync', packet.hook.passenger.nop)
			if isCharOnFoot(PLAYER_PED) and not packet.hook.passenger.nop.v then
				imgui.TextColoredRGB('{FF5656}Внимание! Вы находитесь не в авто!')
			elseif isCharInAnyCar(PLAYER_PED) and not packet.hook.passenger.nop.v then
				local veh = getCarCharIsUsing(PLAYER_PED)
				local driver = getDriverOfCar(veh)
				if driver == PLAYER_PED then
					imgui.TextColoredRGB('{FF5656}Внимание! Вы должны находиться на пассажирском месте!')
				elseif driver ~= -1 then
					imgui.TextColoredRGB('{FF5656}Внимание! В авто не должно быть водителя!')
				end
			end
		end
		if tab_page == 4 then
			imgui.Checkbox('NOP##async', packet.hook.aim.nop)
		end
		if tab_page == 5 then
			imgui.Checkbox('NOP##tsync', packet.hook.trailer.nop)
		end
		if tab_page == 6 then
			imgui.Checkbox('NOP##usync', packet.hook.unoccupied.nop)
		end
		if tab_page == 7 then
			imgui.Checkbox('NOP##ssync', packet.hook.spectator.nop)
		end
		if tab_page == 8 then
			imgui.Checkbox('NOP##bsync', packet.hook.bullet.nop)
		end
		if tab_page ~= 0 then
			imgui.Separator()
		end
	end
	if menu_page == 2.2 or menu_page == 1.2 then
		imgui.BeginChild('##block1', imgui.ImVec2(200, 250), false)
		if tab_page == 1 then
			onfsync_imgui1()
		end
		if tab_page == 2 then
			vsync_imgui1()
		end
		if tab_page == 3 then
			psync_imgui1()
		end
		if tab_page == 4 then
			async_imgui1()
		end
		if tab_page == 5 then
			tsync_imgui1()
		end
		if tab_page == 6 then
			usync_imgui1()
		end
		if tab_page == 7 then
			ssync_imgui1()
		end
		if tab_page == 8 then
			bsync_imgui1()
		end
		imgui.EndChild()
		imgui.SameLine()
		imgui.BeginChild('##block2', imgui.ImVec2(290, 250), false)
		if tab_page == 1 then
			onfsync_imgui2()
		end
		if tab_page == 2 then
			vsync_imgui2()
		end
		if tab_page == 3 then
			psync_imgui2()
		end
		if tab_page == 4 then
			async_imgui2()
		end
		if tab_page == 5 then
			tsync_imgui2()
		end
		if tab_page == 6 then
			usync_imgui2()
		end
		if tab_page == 8 then
			bsync_imgui2()
		end
		imgui.EndChild()
		end
		imgui.EndChild()
		imgui.EndChild()
		imgui.End()
	end
end

function sendrpcs()
	if tab_page ~= 0 and imgui.Button(u8'Отправить##rpcsend', btn_size_small) then
		if tab_page == 1 then
			sampSendEnterVehicle(rpc.send.entervehicle.vehId.v, rpc.send.entervehicle.passenger.v)
		end
		if tab_page == 2 then
			sampSendClickPlayer(rpc.send.clickplayer.playerId.v, rpc.send.clickplayer.source.v)
		end
		if tab_page == 3 then
			local bs = raknetNewBitStream()
			raknetBitStreamWriteInt32(bs, rpc.send.clientjoin.version.v)
			raknetBitStreamWriteInt8(bs, rpc.send.clientjoin.mod.v)
			raknetBitStreamWriteString(bs, rpc.send.clientjoin.nickname.v)
			raknetBitStreamWriteInt32(bs, rpc.send.clientjoin.challengeResponse.v)
			raknetBitStreamWriteString(bs, rpc.send.clientjoin.joinauthkey.v)
			raknetBitStreamWriteString(bs, rpc.send.clientjoin.clientVer.v)
			raknetBitStreamWriteInt32(bs, rpc.send.clientjoin.unknown.v)
			raknetSendRpc(25, bs)
			raknetDeleteBitStream(bs)
		end
		if tab_page == 4 then
			local bs = raknetNewBitStream()
			raknetBitStreamWriteInt32(bs, rpc.send.entereditobject.type.v)
			raknetBitStreamWriteInt16(bs, rpc.send.entereditobject.objectid.v)
			raknetBitStreamWriteInt32(bs, rpc.send.entereditobject.model.v)
			raknetBitStreamWriteFloat(bs, rpc.send.entereditobject.pos.x)
			raknetBitStreamWriteFloat(bs, rpc.send.entereditobject.pos.y)
			raknetBitStreamWriteFloat(bs, rpc.send.entereditobject.pos.z)
			raknetSendRpc(27, bs)
			raknetDeleteBitStream(bs)
		end
		--[[if tab_page == 5 then
			local bs = raknetNewBitStream()
			raknetBitStreamWriteString(bs, rpc.send.sendcommand.cmd.v)
			raknetSendRpc(50, bs)
			raknetDeleteBitStream(bs)
		end]]
		if tab_page == 6 then
			sampSendSpawn()
		end
		if tab_page == 7 then
			sampSendDeathByPlayer(rpc.send.death.killerid.v, rpc.send.death.reason.v)
		end
		if tab_page == 8 then
			sampSendDialogResponse(rpc.send.dialogresponse.dialogid.v, rpc.send.dialogresponse.button.v, rpc.send.dialogresponse.listboxid.v, rpc.send.dialogresponse.input.v)
		end
		if tab_page == 9 then
			sampSendClickTextdraw(rpc.send.clicktextdraw.textdrawid.v)
		end
		if tab_page == 10 then
			sampSendScmEvent(rpc.send.vehicletuning.event.v, rpc.send.vehicletuning.vehid.v, rpc.send.vehicletuning.param1.v, rpc.send.vehicletuning.param2.v)
		end
		if tab_page == 11 then
			sampSendChat(rpc.send.chat.msg.v)
		end
		if tab_page == 12 then
			sampSendDamageVehicle(rpc.send.vehicledamaged.vehid.v, rpc.send.vehicledamaged.paneldmg.v, rpc.send.vehicledamaged.doordmg.v, rpc.send.vehicledamaged.lights.v, rpc.send.vehicledamaged.tires.v)
		end
		if tab_page == 13 then
			sampSendEditAttachedObject(rpc.send.editattachedobject.response.v, rpc.send.editattachedobject.index.v, rpc.send.editattachedobject.model.v, rpc.send.editattachedobject.bone.v, rpc.send.editattachedobject.pos.x.v, rpc.send.editattachedobject.pos.y.v, rpc.send.editattachedobject.pos.z.v, rpc.send.editattachedobject.rotation.x.v, rpc.send.editattachedobject.rotation.y.v, rpc.send.editattachedobject.rotation.z.v, rpc.send.editattachedobject.scale.x.v, rpc.send.editattachedobject.scale.y.v, rpc.send.editattachedobject.scale.z.v)
		end
		if tab_page == 14 then
			sampSendEditObject(rpc.send.editobject.playerobject.v, rpc.send.editobject.objectid.v, rpc.send.editobject.response.v, rpc.send.editobject.pos.x.v, rpc.send.editobject.pos.y.v, rpc.send.editobject.pos.z.v, rpc.send.editobject.rotation.x.v, rpc.send.editobject.rotation.y.v, rpc.send.editobject.rotation.z.v)
		end
		if tab_page == 15 then
			sampSendInteriorChange(rpc.send.interiorchange.interiorid.v)
		end
		if tab_page == 16 then
			local bs = raknetNewBitStream()
			raknetBitStreamWriteFloat(bs, rpc.send.mapmarker.pos.x.v)
			raknetBitStreamWriteFloat(bs, rpc.send.mapmarker.pos.y.v)
			raknetBitStreamWriteFloat(bs, rpc.send.mapmarker.pos.z.v)
			raknetSendRpc(119, bs)
			raknetDeleteBitStream(bs)
		end
		if tab_page == 17 then
			sampRequestClass(rpc.send.requestclass.classid.v)
		end
		if tab_page == 18 then
			sampSendPickedUpPickup(rpc.send.pickeduppickup.pickupid.v)
		end
		if tab_page == 19 then
			sampSendMenuSelectRow(rpc.send.menuselect.row.v)
		end
		if tab_page == 20 then
			sampSendVehicleDestroyed(rpc.send.vehicledestroyed.vehicleid.v)
		end
		if tab_page == 21 then
			sampSendExitVehicle(rpc.send.exitvehicle.vehicleid.v)
		end
		if tab_page == 22 then
			sampSendRequestSpawn()
		end
		if tab_page == 23 then
			sampSendMenuQuit()
		end
		if tab_page == 24 then
			raknetSendRpc(155, 0)
		end
		if tab_page == 25 then
			sampSendTakeDamage(rpc.send.takedamage.playerid.v, rpc.send.takedamage.damage.v, rpc.send.takedamage.weapon.v, rpc.send.takedamage.bodypart.v)
		end
		if tab_page == 26 then
			sampSendGiveDamage(rpc.send.givedamage.playerid.v, rpc.send.givedamage.damage.v, rpc.send.givedamage.weapon.v, rpc.send.givedamage.bodypart.v)
		end
	end
end

function sendpackets()
	if tab_page ~= 0 and imgui.Button(u8'Отправить##packetsend', btn_size_small) then
		if tab_page == 1 then
			local data = samp_create_sync_data('player')
			data.position.x, data.position.y, data.position.z = packet.send.player.pos.x.v, packet.send.player.pos.y.v, packet.send.player.pos.z.v
			data.quaternion[0], data.quaternion[1], data.quaternion[2], data.quaternion[3] = packet.send.player.quaternion.x.v, packet.send.player.quaternion.y.v, packet.send.player.quaternion.z.v, packet.send.player.quaternion.w.v
			data.health = packet.send.player.health.v
			data.armor = packet.send.player.armor.v
			data.weapon = packet.send.player.weapon.v
			data.specialAction = packet.send.player.specialAction.v
			data.moveSpeed.x, data.moveSpeed.y, data.moveSpeed.z = packet.send.player.moveSpeed.x.v, packet.send.player.moveSpeed.y.v, packet.send.player.moveSpeed.z.v
			data.surfingOffsets.x, data.surfingOffsets.y, data.surfingOffsets.z = packet.send.player.surfing.offset_x.v, packet.send.player.surfing.offset_y.v, packet.send.player.surfing.offset_z.v
			data.surfingVehicleId = packet.send.player.surfing.vehId.v
			data.animationId = packet.send.player.animation.id.v
			data.animationFlags = packet.send.player.animation.flags.v
			data.send()
		end
		if tab_page == 2 then
			local data = samp_create_sync_data('vehicle')
			data.vehicleId = packet.send.vehicle.vehid.v
			data.quaternion[0], data.quaternion[1], data.quaternion[2], data.quaternion[3] = packet.send.vehicle.quaternion.x.v, packet.send.vehicle.quaternion.y.v, packet.send.vehicle.quaternion.z.v, packet.send.vehicle.quaternion.w.v
			data.position.x, data.position.y, data.position.z = packet.send.vehicle.pos.x.v, packet.send.vehicle.pos.y.v, packet.send.vehicle.pos.z.v
			data.moveSpeed.x, data.moveSpeed.y, data.moveSpeed.z = packet.send.vehicle.moveSpeed.x.v, packet.send.vehicle.moveSpeed.y.v, packet.send.vehicle.moveSpeed.z.v
			data.vehicleHealth = packet.send.vehicle.health.vehHealth.v
			data.playerHealth = packet.send.vehicle.health.playerHealth.v
			data.armor = packet.send.vehicle.armor.v
			data.currentWeapon = packet.send.vehicle.weapon.v
			data.siren = packet.send.vehicle.siren.v
			data.trailerId = packet.send.vehicle.trailerid.v
			data.trainSpeed = packet.send.vehicle.trainSpeed.v
			data.send()
		end
		if tab_page == 3 then
			local data = samp_create_sync_data('passenger')
			data.vehicleId = packet.send.passenger.vehid.v
			data.seatId = packet.send.passenger.seat.v
			data.currentWeapon = packet.send.passenger.weapon.v
			data.health = packet.send.passenger.health.v
			data.armor = packet.send.passenger.armor.v
			data.position.x, data.position.y, data.position.z = packet.send.passenger.pos.x.v, packet.send.passenger.pos.y.v, packet.send.passenger.pos.z.v
			data.send()
		end
		if tab_page == 4 then
			local data = samp_create_sync_data('aim')
			data.camMode = packet.send.aim.camMode.v
			data.camFront.x, data.camFront.y, data.camFront.z = packet.send.aim.camFront.x.v, packet.send.aim.camFront.y.v, packet.send.aim.camFront.z.v
			data.camPos.x, data.camPos.y, data.camPos.z = packet.send.aim.camPos.x.v, packet.send.aim.camPos.y.v, packet.send.aim.camPos.z.v
			data.aimZ = packet.send.aim.aimZ.v
			data.camExtZoom = packet.send.aim.camExtZoom.v
			data.weaponState = packet.send.aim.weaponState.v
			data.unknown = packet.send.aim.unknown.v
			data.send()
		end
		if tab_page == 5 then
			local data = samp_create_sync_data('trailer')
			data.trailerId = packet.send.trailer.trailerid.v
			data.position.x, data.position.x, data.position.z = packet.send.trailer.pos.x.v, packet.send.trailer.pos.y.v, packet.send.trailer.pos.z.v
			data.roll.x, data.roll.x, data.roll.z = packet.send.trailer.roll.x.v, packet.send.trailer.roll.y.v, packet.send.trailer.roll.z.v
			data.direction.x, data.direction.x, data.direction.z = packet.send.trailer.direction.x.v, packet.send.trailer.direction.y.v, packet.send.trailer.direction.z.v
			data.speed.x, data.speed.x, data.speed.z = packet.send.trailer.speed.x.v, packet.send.trailer.speed.y.v, packet.send.trailer.speed.z.v
			data.unk = packet.send.trailer.unk.v
			data.send()
		end
		if tab_page == 6 then
			local data = samp_create_sync_data('unoccupied')
			data.vehicleId = packet.send.unoccupied.vehid.v
			data.seatId = packet.send.unoccupied.seat.v
			data.roll.x, data.roll.y, data.roll.z = packet.send.unoccupied.roll.x.v, packet.send.unoccupied.roll.y.v, packet.send.unoccupied.roll.z.v
			data.direction.x, data.direction.y, data.direction.z = packet.send.unoccupied.direction.x.v, packet.send.unoccupied.direction.y.v, packet.send.unoccupied.direction.z.v
			data.position.x, data.position.y, data.position.z = packet.send.unoccupied.pos.x.v, packet.send.unoccupied.pos.y.v, packet.send.unoccupied.pos.z.v
			data.moveSpeed.x, data.moveSpeed.y, data.moveSpeed.z = packet.send.unoccupied.moveSpeed.x.v, packet.send.unoccupied.moveSpeed.y.v, packet.send.unoccupied.moveSpeed.z.v
			data.turnSpeed.x, data.turnSpeed.y, data.turnSpeed.z = packet.send.unoccupied.turnSpeed.x.v, packet.send.unoccupied.turnSpeed.y.v, packet.send.unoccupied.turnSpeed.z.v
			data.vehicleHealth = packet.send.unoccupied.health.v
			data.send()
		end
		if tab_page == 7 then
			local data = samp_create_sync_data('spectator')
			data.position.x, data.position.x, data.position.z = packet.send.spectator.pos.x.v, packet.send.spectator.pos.y.v, packet.send.spectator.pos.z.v
			data.send()
		end
		if tab_page == 8 then
			local data = samp_create_sync_data('bullet')
			data.targetType = packet.send.bullet.targetType.v
			data.targetId = packet.send.bullet.targetId.v
			data.origin.x, data.origin.x, data.origin.z = packet.send.bullet.origin.x.v, packet.send.bullet.origin.y.v, packet.send.bullet.origin.z.v
			data.target.x, data.target.x, data.target.z = packet.send.bullet.target.x.v, packet.send.bullet.target.y.v, packet.send.bullet.target.z.v
			data.center.x, data.center.x, data.center.z = packet.send.bullet.center.x.v, packet.send.bullet.center.y.v, packet.send.bullet.center.z.v
			data.weaponId = packet.send.bullet.weapon.v
			data.send()
		end
	end
end

function entervehicle_imgui1()
	if menu_page == 1.1 then
		imgui.Checkbox(u8'ID авто##eveh', rpc.hook.entervehicle.vehId.state)
		if rpc.hook.entervehicle.vehId.state.v then
			imgui.PushItemWidth(50)
			imgui.InputInt(u8'ID##eveh', rpc.hook.entervehicle.vehId.id, 0, 0)
		end
		imgui.Checkbox(u8'Пассажирское место##eveh', rpc.hook.entervehicle.passenger.state)
		if rpc.hook.entervehicle.passenger.state.v then
			imgui.Checkbox(u8'Да/Нет##eveh', rpc.hook.entervehicle.passenger.is)
		end
	else
		imgui.PushItemWidth(50)
		imgui.InputInt(u8'ID авто##eveh', rpc.send.entervehicle.vehId, 0, 0)
		imgui.Checkbox(u8'Пассажирское место##eveh', rpc.send.entervehicle.passenger)
	end
end

function clickplayer_imgui1()
	if menu_page == 1.1 then
		imgui.Checkbox(u8'ID игрока##clplr', rpc.hook.clickplayer.playerId.state)
		if rpc.hook.clickplayer.playerId.state.v then
			imgui.PushItemWidth(50)
			imgui.InputInt(u8'ID##clplr', rpc.hook.clickplayer.playerId.id, 0, 0)
		end
		imgui.Checkbox(u8'Source##clplr', rpc.hook.clickplayer.source.state)
		if rpc.hook.clickplayer.source.state.v then
			imgui.PushItemWidth(50)
			imgui.InputInt(u8'Значение##clplr', rpc.hook.clickplayer.source.count, 0, 0)
		end
	else
		imgui.PushItemWidth(50)
		imgui.InputInt(u8'ID игрока##clplr', rpc.send.clickplayer.playerId, 0, 0)
		imgui.PushItemWidth(50)
		imgui.InputInt(u8'Source##clplr', rpc.send.clickplayer.source, 0, 0)
	end
end

function clientjoin_imgui1()
	if menu_page == 1.1 then
		imgui.Checkbox(u8'Version##cljoi', rpc.hook.clientjoin.version.state)
		if rpc.hook.clientjoin.version.state.v then
			imgui.PushItemWidth(50)
			imgui.InputInt(u8'Значение##cljoi1', rpc.hook.clientjoin.version.count, 0, 0)
		end
		imgui.Checkbox(u8'Mod##cljoi', rpc.hook.clientjoin.mod.state)
		if rpc.hook.clientjoin.mod.state.v then
			imgui.PushItemWidth(50)
			imgui.InputInt(u8'Значение##cljoi2', rpc.hook.clientjoin.mod.count, 0, 0)
		end
		imgui.Checkbox(u8'Nickname##cljoi', rpc.hook.clientjoin.nickname.state)
		if rpc.hook.clientjoin.nickname.state.v then
			imgui.PushItemWidth(50)
			imgui.InputText(u8'Значение##cljoi3', rpc.hook.clientjoin.nickname.count)
		end
		imgui.Checkbox(u8'ChallengeResponse##cljoi', rpc.hook.clientjoin.challengeResponse.state)
		if rpc.hook.clientjoin.challengeResponse.state.v then
			imgui.PushItemWidth(50)
			imgui.InputInt(u8'Значение##cljoi4', rpc.hook.clientjoin.challengeResponse.count, 0, 0)
		end
	else
		imgui.PushItemWidth(50)
		imgui.InputInt(u8'Version##cljoi', rpc.send.clientjoin.version, 0, 0)
		imgui.PushItemWidth(50)
		imgui.InputInt(u8'Mode##cljoi', rpc.send.clientjoin.mod, 0, 0)
		imgui.PushItemWidth(50)
		imgui.InputText(u8'Nickname##cljoi', rpc.send.clientjoin.nickname)
		imgui.PushItemWidth(50)
		imgui.InputInt(u8'ChallengeResponse##cljoi', rpc.send.clientjoin.challengeResponse, 0, 0)
	end
end

function clientjoin_imgui2()
	if menu_page == 1.1 then
		imgui.Checkbox(u8'JoinAuthKey##cljoi', rpc.hook.clientjoin.joinauthkey.state)
		if rpc.hook.clientjoin.joinauthkey.state.v then
			imgui.PushItemWidth(50)
			imgui.InputText(u8'Значение##cljoi5', rpc.hook.clientjoin.joinauthkey.count)
		end
		imgui.Checkbox(u8'ClientVer##cljoi', rpc.hook.clientjoin.clientVer.state)
		if rpc.hook.clientjoin.clientVer.state.v then
			imgui.PushItemWidth(50)
			imgui.InputText(u8'Значение##cljoi6', rpc.hook.clientjoin.clientVer.count)
		end
		imgui.Checkbox(u8'Unknown##cljoi', rpc.hook.clientjoin.unknown.state)
		if rpc.hook.clientjoin.unknown.state.v then
			imgui.PushItemWidth(50)
			imgui.InputInt(u8'Значение##cljoi4', rpc.hook.clientjoin.unknown.count, 0, 0)
		end
	else
		imgui.PushItemWidth(50)
		imgui.InputText(u8'JoinAuthKey##cljoi', rpc.send.clientjoin.joinauthkey)
		imgui.PushItemWidth(50)
		imgui.InputText(u8'ClientVer##cljoi', rpc.send.clientjoin.clientVer)
		imgui.PushItemWidth(50)
		imgui.InputInt(u8'Unknown##cljoi', rpc.send.clientjoin.unknown, 0, 0)
	end
end

function entereditobject_imgui1()
	if menu_page == 1.1 then
		imgui.Checkbox(u8'Тип##eeobj', rpc.hook.entereditobject.type.state)
		if rpc.hook.entereditobject.type.state.v then
			imgui.PushItemWidth(50)
			imgui.InputInt(u8'Значение##eeobj', rpc.hook.entereditobject.type.count, 0, 0)
		end
		imgui.Checkbox(u8'ID объекта##eeobj', rpc.hook.entereditobject.objectid.state)
		if rpc.hook.entereditobject.objectid.state.v then
			imgui.PushItemWidth(50)
			imgui.InputInt(u8'Значение##eeobj2', rpc.hook.entereditobject.objectid.id, 0, 0)
		end
	else
		imgui.PushItemWidth(50)
		imgui.InputInt(u8'Тип##eeobj', rpc.send.entereditobject.type, 0, 0)
		imgui.PushItemWidth(50)
		imgui.InputInt(u8'ID объекта##eeobj', rpc.send.entereditobject.objectid, 0, 0)
	end
end

function entereditobject_imgui2()
	if menu_page == 1.1 then
		imgui.Checkbox(u8'Модель##eeobj', rpc.hook.entereditobject.model.state)
		if rpc.hook.entereditobject.model.state.v then
			imgui.PushItemWidth(50)
			imgui.InputInt(u8'Значение##eeobj', rpc.hook.entereditobject.model.id, 0, 0)
		end
		imgui.Checkbox(u8'Позиция##eeobj', rpc.hook.entereditobject.pos.state)
		if rpc.hook.entereditobject.pos.state.v then
			imgui.PushItemWidth(50)
			imgui.InputFloat(u8'X##eeobj', rpc.hook.entereditobject.pos.x, 0, 0, 2)
			imgui.SameLine()
			imgui.PushItemWidth(50)
			imgui.InputFloat(u8'Y##eeobj', rpc.hook.entereditobject.pos.y, 0, 0, 2)
			imgui.SameLine()
			imgui.PushItemWidth(50)
			imgui.InputFloat(u8'Z##eeobj', rpc.hook.entereditobject.pos.z, 0, 0, 2)
		end
	else
		imgui.PushItemWidth(50)
		imgui.InputInt(u8'Модель##eeobj', rpc.send.entereditobject.model, 0, 0)
		imgui.Text(u8'Позиция:')
		imgui.PushItemWidth(50)
		imgui.InputFloat(u8'X##eeobj', rpc.send.entereditobject.pos.x, 0, 0, 2)
		imgui.SameLine()
		imgui.PushItemWidth(50)
		imgui.InputFloat(u8'Y##eeobj', rpc.send.entereditobject.pos.y, 0, 0, 2)
		imgui.SameLine()
		imgui.PushItemWidth(50)
		imgui.InputFloat(u8'Z##eeobj', rpc.send.entereditobject.pos.z, 0, 0, 2)
	end
end

--[[function sendcommand_imgui1()
	if menu_page == 1.1 then
		imgui.Checkbox(u8'Команда##scmd', rpc.hook.sendcommand.cmd.state)
		if rpc.hook.sendcommand.cmd.state.v then
			imgui.InputText(u8'Значение##scmd', rpc.hook.sendcommand.cmd.count)
		end
	else
		imgui.InputText(u8'Команда##scmd', rpc.send.sendcommand.cmd)
	end
end]]

function death_imgui1()
	if menu_page == 1.1 then
		imgui.Checkbox(u8'ID оружия##death', rpc.hook.death.reason.state)
		if rpc.hook.death.reason.state.v then
			imgui.PushItemWidth(50)
			imgui.InputInt(u8'ID##death', rpc.hook.death.reason.count, 0, 0)
		end
		imgui.Checkbox(u8'ID убийцы##death', rpc.hook.death.killerid.state)
		if rpc.hook.death.killerid.state.v then
			imgui.PushItemWidth(50)
			imgui.InputInt(u8'ID##death2', rpc.hook.death.killerid.id, 0, 0)
		end
	else
		imgui.PushItemWidth(50)
		imgui.InputInt(u8'ID оружия##death', rpc.send.death.reason, 0, 0)
		imgui.PushItemWidth(50)
		imgui.InputInt(u8'ID убийцы##death2', rpc.send.death.killerid, 0, 0)
	end
end

function dialogresponse_imgui1()
	if menu_page == 1.1 then
		imgui.Checkbox(u8'ID диалога##dr', rpc.hook.dialogresponse.dialogid.state)
		if rpc.hook.dialogresponse.dialogid.state.v then
			imgui.PushItemWidth(50)
			imgui.InputInt(u8'ID##dr', rpc.hook.dialogresponse.dialogid.id, 0, 0)
		end
		imgui.Checkbox(u8'ID кнопки##dr', rpc.hook.dialogresponse.button.state)
		if rpc.hook.dialogresponse.button.state.v then
			imgui.PushItemWidth(50)
			imgui.InputInt(u8'ID##dr2', rpc.hook.dialogresponse.button.count, 0, 0)
		end
	else
		imgui.PushItemWidth(50)
		imgui.InputInt(u8'ID диалога##dr', rpc.send.dialogresponse.dialogid, 0, 0)
		imgui.PushItemWidth(50)
		imgui.InputInt(u8'ID кнопки##dr2', rpc.send.dialogresponse.button, 0, 0)
	end
end

function dialogresponse_imgui2()
	if menu_page == 1.1 then
		imgui.Checkbox(u8'ID листбокса##dr', rpc.hook.dialogresponse.listboxid.state)
		if rpc.hook.dialogresponse.listboxid.state.v then
			imgui.PushItemWidth(50)
			imgui.InputInt(u8'ID##dr3', rpc.hook.dialogresponse.listboxid.count, 0, 0)
		end
		imgui.Checkbox(u8'Текст##dr', rpc.hook.dialogresponse.input.state)
		if rpc.hook.dialogresponse.input.state.v then
			imgui.InputText(u8'Значение##dr', rpc.hook.dialogresponse.input.count)
		end
	else
		imgui.PushItemWidth(50)
		imgui.InputInt(u8'ID листбокса##dr3', rpc.send.dialogresponse.listboxid, 0, 0)
		imgui.InputText(u8'Текст##dr', rpc.send.dialogresponse.input)
	end
end

function clicktextdraw_imgui1()
	if menu_page == 1.1 then
		imgui.Checkbox(u8'ID текстдрава##ctd', rpc.hook.clicktextdraw.textdrawid.state)
		if rpc.hook.clicktextdraw.textdrawid.state.v then
			imgui.PushItemWidth(50)
			imgui.InputInt(u8'ID##ctd', rpc.hook.clicktextdraw.textdrawid.id, 0, 0)
		end
	else
		imgui.PushItemWidth(50)
		imgui.InputInt(u8'ID текстдрава##ctd', rpc.send.clicktextdraw.textdrawid, 0, 0)
	end
end

function vehicletuning_imgui1()
	if menu_page == 1.1 then
		imgui.Checkbox(u8'ID авто##vtn', rpc.hook.vehicletuning.vehid.state)
		if rpc.hook.vehicletuning.vehid.state.v then
			imgui.PushItemWidth(50)
			imgui.InputInt(u8'ID##vtn', rpc.hook.vehicletuning.vehid.id, 0, 0)
		end
		imgui.Checkbox(u8'Param1##vtn', rpc.hook.vehicletuning.param1.state)
		if rpc.hook.vehicletuning.param1.state.v then
			imgui.PushItemWidth(50)
			imgui.InputInt(u8'Значение##vtn', rpc.hook.vehicletuning.param1.count, 0, 0)
		end
	else
		imgui.PushItemWidth(50)
		imgui.InputInt(u8'ID авто##vtn', rpc.send.vehicletuning.vehid, 0, 0)
		imgui.PushItemWidth(50)
		imgui.InputInt(u8'Param1##vtn', rpc.send.vehicletuning.param1, 0, 0)
	end
end

function vehicletuning_imgui2()
	if menu_page == 1.1 then
		imgui.Checkbox(u8'Param2##vtn', rpc.hook.vehicletuning.param2.state)
		if rpc.hook.vehicletuning.param2.state.v then
			imgui.PushItemWidth(50)
			imgui.InputInt(u8'Значение##vtn2', rpc.hook.vehicletuning.param2.count, 0, 0)
		end
		imgui.Checkbox(u8'Событие (event)##vtn', rpc.hook.vehicletuning.event.state)
		if rpc.hook.vehicletuning.event.state.v then
			imgui.PushItemWidth(50)
			imgui.InputInt(u8'Значение##vtn3', rpc.hook.vehicletuning.event.count, 0, 0)
		end
	else
		imgui.PushItemWidth(50)
		imgui.InputInt(u8'Param2##vtn2', rpc.send.vehicletuning.param2, 0, 0)
		imgui.PushItemWidth(50)
		imgui.InputInt(u8'Событие (event)##vtn3', rpc.send.vehicletuning.event, 0, 0)
	end
end

function chat_imgui1()
	if menu_page == 1.1 then
		imgui.Checkbox(u8'Текст##chat', rpc.hook.chat.msg.state)
		if rpc.hook.chat.msg.state.v then
			imgui.InputText(u8'Значение##chat', rpc.hook.chat.msg.count)
		end
	else
		imgui.InputText(u8'Текст##chat', rpc.send.chat.msg)
	end
end

function vehicledamaged_imgui1()
	if menu_page == 1.1 then
		imgui.Checkbox(u8'ID авто##vdmg', rpc.hook.vehicledamaged.vehid.state)
		if rpc.hook.vehicledamaged.vehid.state.v then
			imgui.PushItemWidth(50)
			imgui.InputInt(u8'ID##vdmg', rpc.hook.vehicledamaged.vehid.id, 0, 0)
		end
		imgui.Checkbox(u8'panelDmg##vdmg', rpc.hook.vehicledamaged.paneldmg.state)
		if rpc.hook.vehicledamaged.paneldmg.state.v then
			imgui.PushItemWidth(50)
			imgui.InputInt(u8'Значение##vdmg1', rpc.hook.vehicledamaged.paneldmg.count, 0, 0)
		end
		imgui.Checkbox(u8'doorDmg##vdmg', rpc.hook.vehicledamaged.doordmg.state)
		if rpc.hook.vehicledamaged.doordmg.state.v then
			imgui.PushItemWidth(50)
			imgui.InputInt(u8'Значение##vdmg2', rpc.hook.vehicledamaged.doordmg.count, 0, 0)
		end
	else
		imgui.PushItemWidth(50)
		imgui.InputInt(u8'ID авто##vdmg', rpc.send.vehicledamaged.vehid, 0, 0)
		imgui.PushItemWidth(50)
		imgui.InputInt(u8'panelDmg##vdmg1', rpc.send.vehicledamaged.paneldmg, 0, 0)
		imgui.PushItemWidth(50)
		imgui.InputInt(u8'doorDmg##vdmg2', rpc.send.vehicledamaged.doordmg, 0, 0)
	end
end

function vehicledamaged_imgui2()
	if menu_page == 1.1 then
		imgui.Checkbox(u8'lights##vdmg', rpc.hook.vehicledamaged.lights.state)
		if rpc.hook.vehicledamaged.lights.state.v then
			imgui.PushItemWidth(50)
			imgui.InputInt(u8'Значение##vdmg3', rpc.hook.vehicledamaged.lights.count, 0, 0)
		end
		imgui.Checkbox(u8'tires##vdmg', rpc.hook.vehicledamaged.tires.state)
		if rpc.hook.vehicledamaged.tires.state.v then
			imgui.PushItemWidth(50)
			imgui.InputInt(u8'Значение##vdmg4', rpc.hook.vehicledamaged.tires.count, 0, 0)
		end
	else
		imgui.PushItemWidth(50)
		imgui.InputInt(u8'lights##vdmg3', rpc.send.vehicledamaged.lights, 0, 0)
		imgui.PushItemWidth(50)
		imgui.InputInt(u8'tires##vdmg4', rpc.send.vehicledamaged.tires, 0, 0)
	end
end

function editattachedobject_imgui1()
	if menu_page == 1.1 then
		imgui.Checkbox(u8'response##eattobj', rpc.hook.editattachedobject.response.state)
		if rpc.hook.editattachedobject.response.state.v then
			imgui.PushItemWidth(50)
			imgui.InputInt(u8'Значение##eattobj', rpc.hook.editattachedobject.response.count, 0, 0)
		end
		imgui.Checkbox(u8'index##eattobj', rpc.hook.editattachedobject.index.state)
		if rpc.hook.editattachedobject.index.state.v then
			imgui.PushItemWidth(50)
			imgui.InputInt(u8'Значение##eattobj2', rpc.hook.editattachedobject.index.count, 0, 0)
		end
		imgui.Checkbox(u8'model##eattobj', rpc.hook.editattachedobject.model.state)
		if rpc.hook.editattachedobject.model.state.v then
			imgui.PushItemWidth(50)
			imgui.InputInt(u8'Значение##eattobj3', rpc.hook.editattachedobject.model.count, 0, 0)
		end
		imgui.Checkbox(u8'bone##eattobj', rpc.hook.editattachedobject.bone.state)
		if rpc.hook.editattachedobject.bone.state.v then
			imgui.PushItemWidth(50)
			imgui.InputInt(u8'Значение##eattobj4', rpc.hook.editattachedobject.bone.count, 0, 0)
		end
		imgui.Checkbox(u8'Позиция##eattobj', rpc.hook.editattachedobject.pos.state)
		if rpc.hook.editattachedobject.pos.state.v then
			imgui.PushItemWidth(50)
			imgui.InputFloat(u8'X##poseattobj', rpc.hook.editattachedobject.pos.x, 0, 0, 2)
			imgui.SameLine()
			imgui.PushItemWidth(50)
			imgui.InputFloat(u8'Y##poseattobj', rpc.hook.editattachedobject.pos.y, 0, 0, 2)
			imgui.SameLine()
			imgui.PushItemWidth(50)
			imgui.InputFloat(u8'Z##poseattobj', rpc.hook.editattachedobject.pos.z, 0, 0, 2)
		end
	else
		imgui.PushItemWidth(50)
		imgui.InputInt(u8'response##eattobj', rpc.send.editattachedobject.response, 0, 0)
		imgui.PushItemWidth(50)
		imgui.InputInt(u8'index##eattobj2', rpc.send.editattachedobject.index, 0, 0)
		imgui.PushItemWidth(50)
		imgui.InputInt(u8'model##eattobj3', rpc.send.editattachedobject.model, 0, 0)
		imgui.PushItemWidth(50)
		imgui.InputInt(u8'bone##eattobj4', rpc.send.editattachedobject.bone, 0, 0)
		imgui.Text(u8'Позиция:')
		imgui.PushItemWidth(50)
		imgui.InputFloat(u8'X##poseattobj', rpc.send.editattachedobject.pos.x, 0, 0, 2)
		imgui.SameLine()
		imgui.PushItemWidth(50)
		imgui.InputFloat(u8'Y##poseattobj', rpc.send.editattachedobject.pos.y, 0, 0, 2)
		imgui.SameLine()
		imgui.PushItemWidth(50)
		imgui.InputFloat(u8'Z##poseattobj', rpc.send.editattachedobject.pos.z, 0, 0, 2)
	end
end

function editattachedobject_imgui2()
	if menu_page == 1.1 then
		imgui.Checkbox(u8'rotation##eattobj', rpc.hook.editattachedobject.rotation.state)
		if rpc.hook.editattachedobject.rotation.state.v then
			imgui.PushItemWidth(50)
			imgui.InputFloat(u8'X##rotationeattobj', rpc.hook.editattachedobject.rotation.x, 0, 0, 2)
			imgui.SameLine()
			imgui.PushItemWidth(50)
			imgui.InputFloat(u8'Y##rotationeattobj', rpc.hook.editattachedobject.rotation.y, 0, 0, 2)
			imgui.SameLine()
			imgui.PushItemWidth(50)
			imgui.InputFloat(u8'Z##rotationeattobj', rpc.hook.editattachedobject.rotation.z, 0, 0, 2)
		end
		imgui.Checkbox(u8'scale##eattobj', rpc.hook.editattachedobject.scale.state)
		if rpc.hook.editattachedobject.scale.state.v then
			imgui.PushItemWidth(50)
			imgui.InputFloat(u8'X##scaleeattobj', rpc.hook.editattachedobject.scale.x, 0, 0, 2)
			imgui.SameLine()
			imgui.PushItemWidth(50)
			imgui.InputFloat(u8'Y##scaleeattobj', rpc.hook.editattachedobject.scale.y, 0, 0, 2)
			imgui.SameLine()
			imgui.PushItemWidth(50)
			imgui.InputFloat(u8'Z##scaleeattobj', rpc.hook.editattachedobject.scale.z, 0, 0, 2)
		end
		imgui.Checkbox(u8'color1##eattobj', rpc.hook.editattachedobject.color1.state)
		if rpc.hook.editattachedobject.color1.state.v then
			imgui.PushItemWidth(50)
			imgui.InputInt(u8'Значение##eattobj5', rpc.hook.editattachedobject.color1.count, 0, 0)
		end
		imgui.Checkbox(u8'color2##eattobj', rpc.hook.editattachedobject.color2.state)
		if rpc.hook.editattachedobject.color2.state.v then
			imgui.PushItemWidth(50)
			imgui.InputInt(u8'Значение##eattobj6', rpc.hook.editattachedobject.color2.count, 0, 0)
		end
	else
		imgui.Text(u8'rotation:')
		imgui.PushItemWidth(50)
		imgui.InputFloat(u8'X##rotationeattobj', rpc.send.editattachedobject.rotation.x, 0, 0, 2)
		imgui.SameLine()
		imgui.PushItemWidth(50)
		imgui.InputFloat(u8'Y##rotationeattobj', rpc.send.editattachedobject.rotation.y, 0, 0, 2)
		imgui.SameLine()
		imgui.PushItemWidth(50)
		imgui.InputFloat(u8'Z##rotationeattobj', rpc.send.editattachedobject.rotation.z, 0, 0, 2)
		imgui.Text(u8'scale:')
		imgui.PushItemWidth(50)
		imgui.InputFloat(u8'X##scaleeattobj', rpc.send.editattachedobject.scale.x, 0, 0, 2)
		imgui.SameLine()
		imgui.PushItemWidth(50)
		imgui.InputFloat(u8'Y##scaleeattobj', rpc.send.editattachedobject.scale.y, 0, 0, 2)
		imgui.SameLine()
		imgui.PushItemWidth(50)
		imgui.InputFloat(u8'Z##scaleeattobj', rpc.send.editattachedobject.scale.z, 0, 0, 2)
		imgui.PushItemWidth(50)
		imgui.InputInt(u8'color1##eattobj5', rpc.send.editattachedobject.color1, 0, 0)
		imgui.PushItemWidth(50)
		imgui.InputInt(u8'color2##eattobj6', rpc.send.editattachedobject.color2, 0, 0)
	end
end

function editobject_imgui1()
	if menu_page == 1.1 then
		imgui.Checkbox(u8'PlayerObject##eobj', rpc.hook.editobject.playerobject.state)
		if rpc.hook.editobject.playerobject.state.v then
			imgui.Checkbox(u8'Да/Нет##eobj', rpc.hook.editobject.playerobject.count)
		end
		imgui.Checkbox(u8'ID объекта##eobj', rpc.hook.editobject.objectid.state)
		if rpc.hook.editobject.objectid.state.v then
			imgui.PushItemWidth(50)
			imgui.InputInt(u8'ID##eobj', rpc.hook.editobject.objectid.count, 0, 0)
		end
		imgui.Checkbox(u8'response##eobj', rpc.hook.editobject.response.state)
		if rpc.hook.editobject.response.state.v then
			imgui.PushItemWidth(50)
			imgui.InputInt(u8'Значение##eobj', rpc.hook.editobject.response.count, 0, 0)
		end
	else
		imgui.Checkbox(u8'PlayerObject##eobj', rpc.send.editobject.playerobject)
		imgui.PushItemWidth(50)
		imgui.InputInt(u8'ID объекта##eobj', rpc.send.editobject.objectid, 0, 0)
		imgui.PushItemWidth(50)
		imgui.InputInt(u8'response##eobj', rpc.send.editobject.response, 0, 0)
	end
end

function editobject_imgui2()
	if menu_page == 1.1 then
		imgui.Checkbox(u8'Позиция##eobj', rpc.hook.editobject.pos.state)
		if rpc.hook.editobject.pos.state.v then
			imgui.PushItemWidth(50)
			imgui.InputFloat(u8'X##poseobj', rpc.hook.editobject.pos.x, 0, 0, 2)
			imgui.SameLine()
			imgui.PushItemWidth(50)
			imgui.InputFloat(u8'Y##poseobj', rpc.hook.editobject.pos.y, 0, 0, 2)
			imgui.SameLine()
			imgui.PushItemWidth(50)
			imgui.InputFloat(u8'Z##poseobj', rpc.hook.editobject.pos.z, 0, 0, 2)
		end
		imgui.Checkbox(u8'Rotation##eobj', rpc.hook.editobject.rotation.state)
		if rpc.hook.editobject.rotation.state.v then
			imgui.PushItemWidth(50)
			imgui.InputFloat(u8'X##rotationeobj', rpc.hook.editobject.rotation.x, 0, 0, 2)
			imgui.SameLine()
			imgui.PushItemWidth(50)
			imgui.InputFloat(u8'Y##rotationeobj', rpc.hook.editobject.rotation.y, 0, 0, 2)
			imgui.SameLine()
			imgui.PushItemWidth(50)
			imgui.InputFloat(u8'Z##rotationeobj', rpc.hook.editobject.rotation.z, 0, 0, 2)
		end
	else
		imgui.Text(u8'Позиция:')
		imgui.PushItemWidth(50)
		imgui.InputFloat(u8'X##poseobj', rpc.send.editobject.pos.x, 0, 0, 2)
		imgui.SameLine()
		imgui.PushItemWidth(50)
		imgui.InputFloat(u8'Y##poseobj', rpc.send.editobject.pos.y, 0, 0, 2)
		imgui.SameLine()
		imgui.PushItemWidth(50)
		imgui.InputFloat(u8'Z##poseobj', rpc.send.editobject.pos.z, 0, 0, 2)
		imgui.Text(u8'Rotation:')
		imgui.PushItemWidth(50)
		imgui.InputFloat(u8'X##rotationeobj', rpc.send.editobject.rotation.x, 0, 0, 2)
		imgui.SameLine()
		imgui.PushItemWidth(50)
		imgui.InputFloat(u8'Y##rotationeobj', rpc.send.editobject.rotation.y, 0, 0, 2)
		imgui.SameLine()
		imgui.PushItemWidth(50)
		imgui.InputFloat(u8'Z##rotationeobj', rpc.send.editobject.rotation.z, 0, 0, 2)
	end
end

function interiorchange_imgui1()
	if menu_page == 1.1 then
		imgui.Checkbox(u8'InteriorID##intchange', rpc.hook.interiorchange.interiorid.state)
		if rpc.hook.interiorchange.interiorid.state.v then
			imgui.PushItemWidth(50)
			imgui.InputInt(u8'ID##intchange', rpc.hook.interiorchange.interiorid.id, 0, 0)
		end
	else
		imgui.PushItemWidth(50)
		imgui.InputInt(u8'InteriorID##intchange', rpc.send.interiorchange.interiorid, 0, 0)
	end
end

function mapmarker_imgui1()
	if menu_page == 1.1 then
		imgui.Checkbox(u8'Позиция##mmark', rpc.hook.mapmarker.pos.state)
		if rpc.hook.mapmarker.pos.state.v then
			imgui.PushItemWidth(50)
			imgui.InputFloat(u8'X##mmark', rpc.hook.mapmarker.pos.x, 0, 0, 2)
			imgui.SameLine()
			imgui.PushItemWidth(50)
			imgui.InputFloat(u8'Y##mmark', rpc.hook.mapmarker.pos.y, 0, 0, 2)
			imgui.SameLine()
			imgui.PushItemWidth(50)
			imgui.InputFloat(u8'Z##mmark', rpc.hook.mapmarker.pos.z, 0, 0, 2)
		end
	else
		imgui.Text(u8'Позиция:')
		imgui.PushItemWidth(50)
		imgui.InputFloat(u8'X##mmark', rpc.send.mapmarker.pos.x, 0, 0, 2)
		imgui.SameLine()
		imgui.PushItemWidth(50)
		imgui.InputFloat(u8'Y##mmark', rpc.send.mapmarker.pos.y, 0, 0, 2)
		imgui.SameLine()
		imgui.PushItemWidth(50)
		imgui.InputFloat(u8'Z##mmark', rpc.send.mapmarker.pos.z, 0, 0, 2)
	end
end

function requestclass_imgui1()
	if menu_page == 1.1 then
		imgui.Checkbox(u8'ClassID##rclass', rpc.hook.requestclass.classid.state)
		if rpc.hook.requestclass.classid.state.v then
			imgui.PushItemWidth(50)
			imgui.InputInt(u8'ID##rclass', rpc.hook.requestclass.classid.id, 0, 0)
		end
	else
		imgui.PushItemWidth(50)
		imgui.InputInt(u8'ClassID##rclass', rpc.send.requestclass.classid, 0, 0)
	end
end

function pickeduppickup_imgui1()
	if menu_page == 1.1 then
		imgui.Checkbox(u8'ID пикапа##pupick', rpc.hook.pickeduppickup.pickupid.state)
		if rpc.hook.pickeduppickup.pickupid.state.v then
			imgui.PushItemWidth(50)
			imgui.InputInt(u8'ID##pupick', rpc.hook.pickeduppickup.pickupid.id, 0, 0)
		end
	else
		imgui.PushItemWidth(50)
		imgui.InputInt(u8'ID пикапа##pupick', rpc.send.pickeduppickup.pickupid, 0, 0)
	end
end

function menuselect_imgui1()
	if menu_page == 1.1 then
		imgui.Checkbox(u8'Row##msel', rpc.hook.menuselect.row.state)
		if rpc.hook.menuselect.row.state.v then
			imgui.PushItemWidth(50)
			imgui.InputInt(u8'ID##msel', rpc.hook.menuselect.row.count, 0, 0)
		end
	else
		imgui.PushItemWidth(50)
		imgui.InputInt(u8'Row##msel', rpc.send.menuselect.row, 0, 0)
	end
end

function vehicledestroyed_imgui1()
	if menu_page == 1.1 then
		imgui.Checkbox(u8'ID авто##vehdestr', rpc.hook.vehicledestroyed.vehicleid.state)
		if rpc.hook.vehicledestroyed.vehicleid.state.v then
			imgui.PushItemWidth(50)
			imgui.InputInt(u8'ID##vehdestr', rpc.hook.vehicledestroyed.vehicleid.id, 0, 0)
		end
	else
		imgui.PushItemWidth(50)
		imgui.InputInt(u8'ID авто##vehdestr', rpc.send.vehicledestroyed.vehicleid, 0, 0)
	end
end

function exitvehicle_imgui1()
	if menu_page == 1.1 then
		imgui.Checkbox(u8'ID авто##vehdestr', rpc.hook.exitvehicle.vehicleid.state)
		if rpc.hook.exitvehicle.vehicleid.state.v then
			imgui.PushItemWidth(50)
			imgui.InputInt(u8'ID##vehdestr', rpc.hook.exitvehicle.vehicleid.id, 0, 0)
		end
	else
		imgui.PushItemWidth(50)
		imgui.InputInt(u8'ID авто##vehdestr', rpc.send.exitvehicle.vehicleid, 0, 0)
	end
end

function takedamage_imgui1()
	if menu_page == 1.1 then
		imgui.Checkbox(u8'ID игрока##tdmg', rpc.hook.takedamage.playerid.state)
		if rpc.hook.takedamage.playerid.state.v then
			imgui.PushItemWidth(50)
			imgui.InputInt(u8'ID##tdmg', rpc.hook.takedamage.playerid.id, 0, 0)
		end
		imgui.Checkbox(u8'Урон##tdmg', rpc.hook.takedamage.damage.state)
		if rpc.hook.takedamage.damage.state.v then
			imgui.PushItemWidth(50)
			imgui.InputFloat(u8'Значение##tdmg', rpc.hook.takedamage.damage.count, 0, 0, 2)
		end
	else
		imgui.PushItemWidth(50)
		imgui.InputInt(u8'ID игрока##tdmg', rpc.send.takedamage.playerid, 0, 0)
		imgui.PushItemWidth(50)
		imgui.InputFloat(u8'Урон##tdmg', rpc.send.takedamage.damage, 0, 0, 2)
	end
end

function takedamage_imgui2()
	if menu_page == 1.1 then
		imgui.Checkbox(u8'ID оружия##tdmg', rpc.hook.takedamage.weapon.state)
		if rpc.hook.takedamage.weapon.state.v then
			imgui.PushItemWidth(50)
			imgui.InputInt(u8'ID##tdmg2', rpc.hook.takedamage.weapon.id, 0, 0)
		end
		imgui.Checkbox(u8'Часть тела##tdmg', rpc.hook.takedamage.bodypart.state)
		if rpc.hook.takedamage.bodypart.state.v then
			imgui.PushItemWidth(50)
			imgui.InputInt(u8'ID##tdmg3', rpc.hook.takedamage.bodypart.id, 0, 0)
		end
	else
		imgui.PushItemWidth(50)
		imgui.InputInt(u8'ID оружия##tdmg2', rpc.send.takedamage.weapon, 0, 0)
		imgui.PushItemWidth(50)
		imgui.InputInt(u8'Часть тела##tdmg3', rpc.send.takedamage.bodypart, 0, 0)
	end
end

function givedamage_imgui1()
	if menu_page == 1.1 then
		imgui.Checkbox(u8'ID игрока##gdmg', rpc.hook.givedamage.playerid.state)
		if rpc.hook.givedamage.playerid.state.v then
			imgui.PushItemWidth(50)
			imgui.InputInt(u8'ID##gdmg', rpc.hook.givedamage.playerid.id, 0, 0)
		end
		imgui.Checkbox(u8'Урон##gdmg', rpc.hook.givedamage.damage.state)
		if rpc.hook.givedamage.damage.state.v then
			imgui.PushItemWidth(50)
			imgui.InputFloat(u8'Значение##gdmg', rpc.hook.givedamage.damage.count, 0, 0, 2)
		end
	else
		imgui.PushItemWidth(50)
		imgui.InputInt(u8'ID игрока##gdmg', rpc.send.givedamage.playerid, 0, 0)
		imgui.PushItemWidth(50)
		imgui.InputFloat(u8'Урон##gdmg', rpc.send.givedamage.damage, 0, 0, 2)
	end
end

function givedamage_imgui2()
	if menu_page == 1.1 then
		imgui.Checkbox(u8'ID оружия##gdmg', rpc.hook.givedamage.weapon.state)
		if rpc.hook.givedamage.weapon.state.v then
			imgui.PushItemWidth(50)
			imgui.InputInt(u8'ID##gdmg2', rpc.hook.givedamage.weapon.id, 0, 0)
		end
		imgui.Checkbox(u8'Часть тела##gdmg', rpc.hook.givedamage.bodypart.state)
		if rpc.hook.givedamage.bodypart.state.v then
			imgui.PushItemWidth(50)
			imgui.InputInt(u8'ID##gdmg3', rpc.hook.givedamage.bodypart.id, 0, 0)
		end
	else
		imgui.PushItemWidth(50)
		imgui.InputInt(u8'ID оружия##gdmg2', rpc.send.givedamage.weapon, 0, 0)
		imgui.PushItemWidth(50)
		imgui.InputInt(u8'Часть тела##gdmg3', rpc.send.givedamage.bodypart, 0, 0)
	end
end

function rpcnops()
	if tab_page == 1 then
		imgui.Checkbox(u8'NOP##ev', rpc.hook.entervehicle.nop)
	end
	if tab_page == 2 then
		imgui.Checkbox(u8'NOP##cp', rpc.hook.clickplayer.nop)
	end
	if tab_page == 3 then
		imgui.Checkbox(u8'NOP##cj', rpc.hook.clientjoin.nop)
	end
	if tab_page == 4 then
		imgui.Checkbox(u8'NOP##eeo', rpc.hook.entereditobject.nop)
	end
	--[[if tab_page == 5 then
		imgui.Checkbox(u8'NOP##sc', rpc.hook.sendcommand.nop)
	end]]
	if tab_page == 6 then
		imgui.Checkbox(u8'NOP##sp', rpc.hook.spawn.nop)
	end
	if tab_page == 7 then
		imgui.Checkbox(u8'NOP##de', rpc.hook.death.nop)
	end
	if tab_page == 8 then
		imgui.Checkbox(u8'NOP##dr', rpc.hook.dialogresponse.nop)
	end
	if tab_page == 9 then
		imgui.Checkbox(u8'NOP##ctd', rpc.hook.clicktextdraw.nop)
	end
	if tab_page == 10 then
		imgui.Checkbox(u8'NOP##vt', rpc.hook.vehicletuning.nop)
	end
	if tab_page == 11 then
		imgui.Checkbox(u8'NOP##ch', rpc.hook.chat.nop)
	end
	if tab_page == 12 then
		imgui.Checkbox(u8'NOP##vdmg', rpc.hook.vehicledamaged.nop)
	end
	if tab_page == 13 then
		imgui.Checkbox(u8'NOP##eao', rpc.hook.editattachedobject.nop)
	end
	if tab_page == 14 then
		imgui.Checkbox(u8'NOP##eobj', rpc.hook.editobject.nop)
	end
	if tab_page == 15 then
		imgui.Checkbox(u8'NOP##ich', rpc.hook.interiorchange.nop)
	end
	if tab_page == 16 then
		imgui.Checkbox(u8'NOP##mmrk', rpc.hook.mapmarker.nop)
	end
	if tab_page == 17 then
		imgui.Checkbox(u8'NOP##rcls', rpc.hook.requestclass.nop)
	end
	if tab_page == 18 then
		imgui.Checkbox(u8'NOP##pup', rpc.hook.pickeduppickup.nop)
	end
	if tab_page == 19 then
		imgui.Checkbox(u8'NOP##msel', rpc.hook.menuselect.nop)
	end
	if tab_page == 20 then
		imgui.Checkbox(u8'NOP##vdestr', rpc.hook.vehicledestroyed.nop)
	end
	if tab_page == 21 then
		imgui.Checkbox(u8'NOP##exveh', rpc.hook.exitvehicle.nop)
	end
	if tab_page == 22 then
		imgui.Checkbox(u8'NOP##rsp', rpc.hook.requestspawn.nop)
	end
	if tab_page == 23 then
		imgui.Checkbox(u8'NOP##qmen', rpc.hook.quitmenu.nop)
	end
	if tab_page == 24 then
		imgui.Checkbox(u8'NOP##updsc', rpc.hook.updatescoresandpings.nop)
	end
	if tab_page == 25 then
		imgui.Checkbox(u8'NOP##tdmg', rpc.hook.takedamage.nop)
	end
	if tab_page == 26 then
		imgui.Checkbox(u8'NOP##gdmg', rpc.hook.givedamage.nop)
	end
end

function rpc_tab()
	if imgui.Button(u8'EnterVehicle', btn_size_very_small) then
		tab_page = 1
	end
	imgui.SameLine()
	if imgui.Button(u8'ClickPlayer', btn_size_very_small) then
		tab_page = 2
	end
	imgui.SameLine()
	if imgui.Button(u8'ClientJoin', btn_size_very_small) then
		tab_page = 3
	end
	imgui.SameLine()
	if imgui.Button(u8'EnterEditObject', btn_size_very_small) then
		tab_page = 4
	end
	--[[if imgui.Button(u8'Command', btn_size_very_small) then
		tab_page = 5
	end
	imgui.SameLine()]]
	if imgui.Button(u8'Spawn', btn_size_very_small) then
		tab_page = 6
	end
	imgui.SameLine()
	if imgui.Button(u8'Death', btn_size_very_small) then
		tab_page = 7
	end
	imgui.SameLine()
	if imgui.Button(u8'DialogResponse', btn_size_very_small) then
		tab_page = 8
	end
	if imgui.Button(u8'ClickTextdraw', btn_size_very_small) then
		tab_page = 9
	end
	imgui.SameLine()
	if imgui.Button(u8'VehicleTuning', btn_size_very_small) then
		tab_page = 10
	end
	imgui.SameLine()
	if imgui.Button(u8'Chat', btn_size_very_small) then
		tab_page = 11
	end
	imgui.SameLine()
	if imgui.Button(u8'VehicleDamage', btn_size_very_small) then
		tab_page = 12
	end
	if imgui.Button(u8'EditAttachedObject', btn_size_very_small) then
		tab_page = 13
	end
	imgui.SameLine()
	if imgui.Button(u8'EditObject', btn_size_very_small) then
		tab_page = 14
	end
	imgui.SameLine()
	if imgui.Button(u8'InteriorChange', btn_size_very_small) then
		tab_page = 15
	end
	imgui.SameLine()
	if imgui.Button(u8'MapMarker', btn_size_very_small) then
		tab_page = 16
	end
	if imgui.Button(u8'RequestClass', btn_size_very_small) then
		tab_page = 17
	end
	imgui.SameLine()
	if imgui.Button(u8'PickedUpPickup', btn_size_very_small) then
		tab_page = 18
	end
	imgui.SameLine()
	if imgui.Button(u8'MenuSelect', btn_size_very_small) then
		tab_page = 19
	end
	imgui.SameLine()
	if imgui.Button(u8'VehicleDestroyed', btn_size_very_small) then
		tab_page = 20
	end
	if imgui.Button(u8'ExitVehicle', btn_size_very_small) then
		tab_page = 21
	end
	imgui.SameLine()
	if imgui.Button(u8'RequestSpawn', btn_size_very_small) then
		tab_page = 22
	end
	imgui.SameLine()
	if imgui.Button(u8'QuitMenu', btn_size_very_small) then
		tab_page = 23
	end
	--imgui.SameLine()
	if imgui.Button(u8'UpdateScoresAndPings', imgui.ImVec2(229, 20)) then
		tab_page = 24
	end
	imgui.SameLine()
	if imgui.Button(u8'TakeDamage', btn_size_very_small) then
		tab_page = 25
	end
	imgui.SameLine()
	if imgui.Button(u8'GiveDamage', btn_size_very_small) then
		tab_page = 26
	end
end

function onfsync_imgui1()
	if menu_page == 1.2 then
		if not packet.hook.player.nop.v then
			imgui.Checkbox(u8'Здоровье##psync', packet.hook.player.health.state)
			if packet.hook.player.health.state.v then
				imgui.PushItemWidth(50)
				imgui.InputFloat(u8'Кол-во здоровья игрока##psync', packet.hook.player.health.count, 0, 0, 2)
			end
			imgui.Checkbox(u8'Броня##psync', packet.hook.player.armor.state)
			if packet.hook.player.armor.state.v then
				imgui.PushItemWidth(50)
				imgui.InputFloat(u8'Кол-во брони игрока##psync', packet.hook.player.armor.count, 0, 0, 2)
			end
			imgui.Checkbox(u8'Оружие##psync', packet.hook.player.weapon.state)
			if packet.hook.player.weapon.state.v then
				imgui.PushItemWidth(50)
				imgui.InputInt(u8'ID оружия##psync', packet.hook.player.weapon.id, 0, 0)
			end
			imgui.Checkbox(u8'Позиция##psync', packet.hook.player.pos.state)
			if packet.hook.player.pos.state.v then
				imgui.PushItemWidth(50)
				imgui.InputFloat(u8'X##pospsync', packet.hook.player.pos.x, 0, 0, 2)
				imgui.SameLine()
				imgui.PushItemWidth(50)
				imgui.InputFloat(u8'Y##pospsync', packet.hook.player.pos.y, 0, 0, 2)
				imgui.SameLine()
				imgui.PushItemWidth(50)
				imgui.InputFloat(u8'Z##pospsync', packet.hook.player.pos.z, 0, 0, 2)
				if imgui.Button(u8'Получить координаты##psync', imgui.ImVec2(200, 20)) then
					packet.hook.player.pos.x.v, packet.hook.player.pos.y.v, packet.hook.player.pos.z.v = getCharCoordinates(PLAYER_PED)
				end
			end
		end
	else
		imgui.PushItemWidth(50)
		imgui.InputFloat(u8'Кол-во здоровья игрока##psync', packet.send.player.health, 0, 0, 2)
		imgui.PushItemWidth(50)
		imgui.InputFloat(u8'Кол-во брони игрока##psync', packet.send.player.armor, 0, 0, 2)
		imgui.PushItemWidth(50)
		imgui.InputInt(u8'ID оружия##psync', packet.send.player.weapon, 0, 0)
		imgui.Text(u8'Позиция:')
		imgui.PushItemWidth(50)
		imgui.InputFloat(u8'X##pospsync', packet.send.player.pos.x, 0, 0, 2)
		imgui.SameLine()
		imgui.PushItemWidth(50)
		imgui.InputFloat(u8'Y##pospsync', packet.send.player.pos.y, 0, 0, 2)
		imgui.SameLine()
		imgui.PushItemWidth(50)
		imgui.InputFloat(u8'Z##pospsync', packet.send.player.pos.z, 0, 0, 2)
		if imgui.Button(u8'Получить координаты##psync', imgui.ImVec2(200, 20)) then
			packet.send.player.pos.x.v, packet.send.player.pos.y.v, packet.send.player.pos.z.v = getCharCoordinates(PLAYER_PED)
		end
	end
end

function onfsync_imgui2()
	if menu_page == 1.2 then
		if not packet.hook.player.nop.v then
			imgui.Checkbox(u8'Скорость / MoveSpeed##psync', packet.hook.player.moveSpeed.state)
			if packet.hook.player.moveSpeed.state.v then
				imgui.PushItemWidth(50)
				imgui.InputFloat(u8'X##movespeedpsync', packet.hook.player.moveSpeed.x, 0, 0, 2)
				imgui.SameLine()
				imgui.PushItemWidth(50)
				imgui.InputFloat(u8'Y##movespeedpsync', packet.hook.player.moveSpeed.y, 0, 0, 2)
				imgui.SameLine()
				imgui.PushItemWidth(50)
				imgui.InputFloat(u8'Z##movespeedpsync', packet.hook.player.moveSpeed.z, 0, 0, 2)
			end
			imgui.Checkbox(u8'Поворот / Quaternion##psync', packet.hook.player.quaternion.state)
			if packet.hook.player.quaternion.state.v then
				imgui.PushItemWidth(50)
				imgui.InputFloat(u8'X##quaternionpsync', packet.hook.player.quaternion.x, 0, 0, 2)
				imgui.SameLine()
				imgui.PushItemWidth(50)
				imgui.InputFloat(u8'Y##quaternionpsync', packet.hook.player.quaternion.y, 0, 0, 2)
				imgui.SameLine()
				imgui.PushItemWidth(50)
				imgui.InputFloat(u8'Z##quaternionpsync', packet.hook.player.quaternion.z, 0, 0, 2)
				imgui.SameLine()
				imgui.PushItemWidth(50)
				imgui.InputFloat(u8'W##quaternionpsync', packet.hook.player.quaternion.w, 0, 0, 2)
			end
			imgui.Checkbox(u8'Surfing##psync', packet.hook.player.surfing.state)
			if packet.hook.player.surfing.state.v then
				imgui.PushItemWidth(50)
				imgui.InputInt(u8'SurfingVehicldId##psync', packet.hook.player.surfing.vehId, 0, 0)
				imgui.Text(u8'SurfingOffsets:')
				imgui.PushItemWidth(50)
				imgui.InputFloat(u8'X##surfpsync', packet.hook.player.surfing.offset_x, 0, 0, 2)
				imgui.SameLine()
				imgui.PushItemWidth(50)
				imgui.InputFloat(u8'Y##surfpsync', packet.hook.player.surfing.offset_y, 0, 0, 2)
				imgui.SameLine()
				imgui.PushItemWidth(50)
				imgui.InputFloat(u8'Z##surfpsync', packet.hook.player.surfing.offset_z, 0, 0, 2)
			end
			imgui.Checkbox(u8'Анимации##psync', packet.hook.player.animation.state)
			if packet.hook.player.animation.state.v then
				imgui.PushItemWidth(50)
				imgui.InputInt(u8'AnimationID##psync', packet.hook.player.animation.id, 0, 0)
				imgui.SameLine()
				imgui.PushItemWidth(50)
				imgui.InputInt(u8'AnimationFlags##psync', packet.hook.player.animation.flags, 0, 0)
			end
		end
	else
		imgui.PushItemWidth(50)
		imgui.InputInt(u8'SurfingVehicldId##psync', packet.send.player.surfing.vehId, 0, 0)
		imgui.Text(u8'SurfingOffsets:')
		imgui.PushItemWidth(50)
		imgui.InputFloat(u8'X##surfpsync', packet.send.player.surfing.offset_x, 0, 0, 2)
		imgui.SameLine()
		imgui.PushItemWidth(50)
		imgui.InputFloat(u8'Y##surfpsync', packet.send.player.surfing.offset_y, 0, 0, 2)
		imgui.SameLine()
		imgui.PushItemWidth(50)
		imgui.InputFloat(u8'Z##surfpsync', packet.send.player.surfing.offset_z, 0, 0, 2)
		imgui.PushItemWidth(50)
		imgui.InputInt(u8'AnimationID##psync', packet.send.player.animation.id, 0, 0)
		imgui.SameLine()
		imgui.PushItemWidth(50)
		imgui.InputInt(u8'AnimationFlags##psync', packet.send.player.animation.flags, 0, 0)
	end
end

function bsync_imgui1()
	if menu_page == 1.2 then
		if not packet.hook.bullet.nop.v then
			imgui.Checkbox(u8'TargetType##bsync', packet.hook.bullet.targetType.state)
			if packet.hook.bullet.targetType.state.v then
				imgui.PushItemWidth(50)
				imgui.InputInt(u8'Значение##ttbsync', packet.hook.bullet.targetType.count, 0, 0)
			end
			imgui.Checkbox(u8'TargetId##bsync', packet.hook.bullet.targetId.state)
			if packet.hook.bullet.targetId.state.v then
				imgui.PushItemWidth(50)
				imgui.InputInt(u8'Значение##tibsync', packet.hook.bullet.targetId.count, 0, 0)
			end
			imgui.Checkbox(u8'Origin##bsync', packet.hook.bullet.origin.state)
			if packet.hook.bullet.origin.state.v then
				imgui.PushItemWidth(50)
				imgui.InputFloat(u8'X##originbsync', packet.hook.bullet.origin.x, 0, 0, 2)
				imgui.SameLine()
				imgui.PushItemWidth(50)
				imgui.InputFloat(u8'Y##originbsync', packet.hook.bullet.origin.y, 0, 0, 2)
				imgui.SameLine()
				imgui.PushItemWidth(50)
				imgui.InputFloat(u8'Z##originbsync', packet.hook.bullet.origin.z, 0, 0, 2)
			end
		end
	else
		imgui.PushItemWidth(50)
		imgui.InputInt(u8'TargetType##ttbsync', packet.send.bullet.targetType, 0, 0)
		imgui.PushItemWidth(50)
		imgui.InputInt(u8'TargetId##tibsync', packet.send.bullet.targetId, 0, 0)
		imgui.Text(u8'Origin:')
		imgui.PushItemWidth(50)
		imgui.InputFloat(u8'X##originbsync', packet.send.bullet.origin.x, 0, 0, 2)
		imgui.SameLine()
		imgui.PushItemWidth(50)
		imgui.InputFloat(u8'Y##originbsync', packet.send.bullet.origin.y, 0, 0, 2)
		imgui.SameLine()
		imgui.PushItemWidth(50)
		imgui.InputFloat(u8'Z##originbsync', packet.send.bullet.origin.z, 0, 0, 2)
	end
end

function bsync_imgui2()
	if menu_page == 1.2 then
		if not packet.hook.bullet.nop.v then
			imgui.Checkbox(u8'Target##bsync', packet.hook.bullet.target.state)
			if packet.hook.bullet.target.state.v then
				imgui.PushItemWidth(50)
				imgui.InputFloat(u8'X##targetbsync', packet.hook.bullet.target.x, 0, 0, 2)
				imgui.SameLine()
				imgui.PushItemWidth(50)
				imgui.InputFloat(u8'Y##targetbsync', packet.hook.bullet.target.y, 0, 0, 2)
				imgui.SameLine()
				imgui.PushItemWidth(50)
				imgui.InputFloat(u8'Z##targetbsync', packet.hook.bullet.target.z, 0, 0, 2)
			end
			imgui.Checkbox(u8'Center##bsync', packet.hook.bullet.center.state)
			if packet.hook.bullet.center.state.v then
				imgui.PushItemWidth(50)
				imgui.InputFloat(u8'X##centerbsync', packet.hook.bullet.center.x, 0, 0, 2)
				imgui.SameLine()
				imgui.PushItemWidth(50)
				imgui.InputFloat(u8'Y##centerbsync', packet.hook.bullet.center.y, 0, 0, 2)
				imgui.SameLine()
				imgui.PushItemWidth(50)
				imgui.InputFloat(u8'Z##centerbsync', packet.hook.bullet.center.z, 0, 0, 2)
			end
			imgui.Checkbox(u8'Оружие##bsync', packet.hook.bullet.weapon.state)
			if packet.hook.bullet.weapon.state.v then
				imgui.PushItemWidth(50)
				imgui.InputInt(u8'ID##weapbsync', packet.hook.bullet.weapon.id, 0, 0)
			end
		end
	else
		imgui.Text(u8'Target:')
		imgui.PushItemWidth(50)
		imgui.InputFloat(u8'X##targetbsync', packet.send.bullet.target.x, 0, 0, 2)
		imgui.SameLine()
		imgui.PushItemWidth(50)
		imgui.InputFloat(u8'Y##targetbsync', packet.send.bullet.target.y, 0, 0, 2)
		imgui.SameLine()
		imgui.PushItemWidth(50)
		imgui.InputFloat(u8'Z##targetbsync', packet.send.bullet.target.z, 0, 0, 2)
		imgui.Text(u8'Center:')
		imgui.PushItemWidth(50)
		imgui.InputFloat(u8'X##centerbsync', packet.send.bullet.center.x, 0, 0, 2)
		imgui.SameLine()
		imgui.PushItemWidth(50)
		imgui.InputFloat(u8'Y##centerbsync', packet.send.bullet.center.y, 0, 0, 2)
		imgui.SameLine()
		imgui.PushItemWidth(50)
		imgui.InputFloat(u8'Z##centerbsync', packet.send.bullet.center.z, 0, 0, 2)
		imgui.PushItemWidth(50)
		imgui.InputInt(u8'ID оружия##weapbsync', packet.send.bullet.weapon, 0, 0)
	end
end

function ssync_imgui1()
	if menu_page == 1.2 then
		if not packet.hook.spectator.nop.v then
			imgui.Checkbox(u8'Позиция##ssync', packet.hook.spectator.pos.state)
			if packet.hook.spectator.pos.state.v then
				imgui.PushItemWidth(50)
				imgui.InputFloat(u8'X##posssync', packet.hook.spectator.pos.x, 0, 0, 2)
				imgui.SameLine()
				imgui.PushItemWidth(50)
				imgui.InputFloat(u8'Y##posssync', packet.hook.spectator.pos.y, 0, 0, 2)
				imgui.SameLine()
				imgui.PushItemWidth(50)
				imgui.InputFloat(u8'Z##posssync', packet.hook.spectator.pos.z, 0, 0, 2)
			end
		end
	else
		imgui.Text(u8'Позиция:')
		imgui.PushItemWidth(50)
		imgui.InputFloat(u8'X##posssync', packet.send.spectator.pos.x, 0, 0, 2)
		imgui.SameLine()
		imgui.PushItemWidth(50)
		imgui.InputFloat(u8'Y##posssync', packet.send.spectator.pos.y, 0, 0, 2)
		imgui.SameLine()
		imgui.PushItemWidth(50)
		imgui.InputFloat(u8'Z##posssync', packet.send.spectator.pos.z, 0, 0, 2)
	end
end

function usync_imgui1()
	if menu_page == 1.2 then
		if not packet.hook.unoccupied.nop.v then
			imgui.Checkbox(u8'VehicleID##usync', packet.hook.unoccupied.veh.state)
			if packet.hook.unoccupied.veh.state.v then
				imgui.PushItemWidth(50)
				imgui.InputInt(u8'ID##usync', packet.hook.unoccupied.veh.id, 0, 0)
			end
			imgui.Checkbox(u8'ID сидения##usync', packet.hook.unoccupied.seat.state)
			if packet.hook.unoccupied.seat.state.v then
				imgui.PushItemWidth(50)
				imgui.InputInt(u8'ID##susync', packet.hook.unoccupied.seat.id, 0, 0)
			end
			imgui.Checkbox(u8'Roll##usync', packet.hook.unoccupied.roll.state)
			if packet.hook.unoccupied.roll.state.v then
				imgui.PushItemWidth(50)
				imgui.InputFloat(u8'X##rollusync', packet.hook.unoccupied.roll.x, 0, 0, 2)
				imgui.SameLine()
				imgui.PushItemWidth(50)
				imgui.InputFloat(u8'Y##rollusync', packet.hook.unoccupied.roll.y, 0, 0, 2)
				imgui.SameLine()
				imgui.PushItemWidth(50)
				imgui.InputFloat(u8'Z##rollusync', packet.hook.unoccupied.roll.z, 0, 0, 2)
			end
			imgui.Checkbox(u8'Direction##usync', packet.hook.unoccupied.direction.state)
			if packet.hook.unoccupied.direction.state.v then
				imgui.PushItemWidth(50)
				imgui.InputFloat(u8'X##directionusync', packet.hook.unoccupied.direction.x, 0, 0, 2)
				imgui.SameLine()
				imgui.PushItemWidth(50)
				imgui.InputFloat(u8'Y##directionusync', packet.hook.unoccupied.direction.y, 0, 0, 2)
				imgui.SameLine()
				imgui.PushItemWidth(50)
				imgui.InputFloat(u8'Z##directionusync', packet.hook.unoccupied.direction.z, 0, 0, 2)
			end
		end
	else
		imgui.PushItemWidth(50)
		imgui.InputInt(u8'VehicleID##usync', packet.send.unoccupied.vehid, 0, 0)
		imgui.PushItemWidth(50)
		imgui.InputInt(u8'ID сидения##susync', packet.send.unoccupied.seat, 0, 0)
		imgui.Text(u8'Roll:')
		imgui.PushItemWidth(50)
		imgui.InputFloat(u8'X##rollusync', packet.send.unoccupied.roll.x, 0, 0, 2)
		imgui.SameLine()
		imgui.PushItemWidth(50)
		imgui.InputFloat(u8'Y##rollusync', packet.send.unoccupied.roll.y, 0, 0, 2)
		imgui.SameLine()
		imgui.PushItemWidth(50)
		imgui.InputFloat(u8'Z##rollusync', packet.send.unoccupied.roll.z, 0, 0, 2)
		imgui.Text(u8'Direction:')
		imgui.PushItemWidth(50)
		imgui.InputFloat(u8'X##directionusync', packet.send.unoccupied.direction.x, 0, 0, 2)
		imgui.SameLine()
		imgui.PushItemWidth(50)
		imgui.InputFloat(u8'Y##directionusync', packet.send.unoccupied.direction.y, 0, 0, 2)
		imgui.SameLine()
		imgui.PushItemWidth(50)
		imgui.InputFloat(u8'Z##directionusync', packet.send.unoccupied.direction.z, 0, 0, 2)
	end
end

function usync_imgui2()
	if menu_page == 1.2 then
		if not packet.hook.unoccupied.nop.v then
			imgui.Checkbox(u8'Позиция##usync', packet.hook.unoccupied.pos.state)
			if packet.hook.unoccupied.pos.state.v then
				imgui.PushItemWidth(50)
				imgui.InputFloat(u8'X##posusync', packet.hook.unoccupied.pos.x, 0, 0, 2)
				imgui.SameLine()
				imgui.PushItemWidth(50)
				imgui.InputFloat(u8'Y##posusync', packet.hook.unoccupied.pos.y, 0, 0, 2)
				imgui.SameLine()
				imgui.PushItemWidth(50)
				imgui.InputFloat(u8'Z##posusync', packet.hook.unoccupied.pos.z, 0, 0, 2)
			end
			imgui.Checkbox(u8'MoveSpeed##usync', packet.hook.unoccupied.moveSpeed.state)
			if packet.hook.unoccupied.moveSpeed.state.v then
				imgui.PushItemWidth(50)
				imgui.InputFloat(u8'X##msusync', packet.hook.unoccupied.moveSpeed.x, 0, 0, 2)
				imgui.SameLine()
				imgui.PushItemWidth(50)
				imgui.InputFloat(u8'Y##msusync', packet.hook.unoccupied.moveSpeed.y, 0, 0, 2)
				imgui.SameLine()
				imgui.PushItemWidth(50)
				imgui.InputFloat(u8'Z##msusync', packet.hook.unoccupied.moveSpeed.z, 0, 0, 2)
			end
			imgui.Checkbox(u8'TurnSpeed##usync', packet.hook.unoccupied.turnSpeed.state)
			if packet.hook.unoccupied.turnSpeed.state.v then
				imgui.PushItemWidth(50)
				imgui.InputFloat(u8'X##tsusync', packet.hook.unoccupied.turnSpeed.x, 0, 0, 2)
				imgui.SameLine()
				imgui.PushItemWidth(50)
				imgui.InputFloat(u8'Y##tsusync', packet.hook.unoccupied.turnSpeed.y, 0, 0, 2)
				imgui.SameLine()
				imgui.PushItemWidth(50)
				imgui.InputFloat(u8'Z##tsusync', packet.hook.unoccupied.turnSpeed.z, 0, 0, 2)
			end
			imgui.Checkbox(u8'Здоровье авто##usync', packet.hook.unoccupied.health.state)
			if packet.hook.unoccupied.health.state.v then
				imgui.PushItemWidth(50)
				imgui.InputFloat(u8'Значение##healthusync', packet.hook.unoccupied.health.vehHealth, 0, 0, 2)
			end
		end
	else
		imgui.Text(u8'Позиция:')
		imgui.PushItemWidth(50)
		imgui.InputFloat(u8'X##posusync', packet.send.unoccupied.pos.x, 0, 0, 2)
		imgui.SameLine()
		imgui.PushItemWidth(50)
		imgui.InputFloat(u8'Y##posusync', packet.send.unoccupied.pos.y, 0, 0, 2)
		imgui.SameLine()
		imgui.PushItemWidth(50)
		imgui.InputFloat(u8'Z##posusync', packet.send.unoccupied.pos.z, 0, 0, 2)
		imgui.Text(u8'MoveSpeed:')
		imgui.PushItemWidth(50)
		imgui.InputFloat(u8'X##msusync', packet.send.unoccupied.moveSpeed.x, 0, 0, 2)
		imgui.SameLine()
		imgui.PushItemWidth(50)
		imgui.InputFloat(u8'Y##msusync', packet.send.unoccupied.moveSpeed.y, 0, 0, 2)
		imgui.SameLine()
		imgui.PushItemWidth(50)
		imgui.InputFloat(u8'Z##msusync', packet.send.unoccupied.moveSpeed.z, 0, 0, 2)
		imgui.Text(u8'TurnSpeed:')
		imgui.PushItemWidth(50)
		imgui.InputFloat(u8'X##tsusync', packet.send.unoccupied.turnSpeed.x, 0, 0, 2)
		imgui.SameLine()
		imgui.PushItemWidth(50)
		imgui.InputFloat(u8'Y##tsusync', packet.send.unoccupied.turnSpeed.y, 0, 0, 2)
		imgui.SameLine()
		imgui.PushItemWidth(50)
		imgui.InputFloat(u8'Z##tsusync', packet.send.unoccupied.turnSpeed.z, 0, 0, 2)
		imgui.PushItemWidth(50)
		imgui.InputFloat(u8'Здоровье авто##healthusync', packet.send.unoccupied.health, 0, 0, 2)
	end
end

function tsync_imgui1()
	if menu_page == 1.2 then
		if not packet.hook.trailer.nop.v then
			imgui.Checkbox(u8'TrailerID##tsync', packet.hook.trailer.veh.state)
			if packet.hook.trailer.veh.state.v then
				imgui.PushItemWidth(50)
				imgui.InputInt(u8'ID##tsync', packet.hook.trailer.veh.id, 0, 0)
			end
			imgui.Checkbox(u8'Позиция##tsync', packet.hook.trailer.pos.state)
			if packet.hook.trailer.pos.state.v then
				imgui.PushItemWidth(50)
				imgui.InputFloat(u8'X##postsync', packet.hook.trailer.pos.x, 0, 0, 2)
				imgui.SameLine()
				imgui.PushItemWidth(50)
				imgui.InputFloat(u8'Y##postsync', packet.hook.trailer.pos.y, 0, 0, 2)
				imgui.SameLine()
				imgui.PushItemWidth(50)
				imgui.InputFloat(u8'Z##postsync', packet.hook.trailer.pos.z, 0, 0, 2)
			end
			imgui.Checkbox(u8'Roll##tsync', packet.hook.trailer.roll.state)
			if packet.hook.trailer.roll.state.v then
				imgui.PushItemWidth(50)
				imgui.InputFloat(u8'X##rolltsync', packet.hook.trailer.roll.x, 0, 0, 2)
				imgui.SameLine()
				imgui.PushItemWidth(50)
				imgui.InputFloat(u8'Y##rolltsync', packet.hook.trailer.roll.y, 0, 0, 2)
				imgui.SameLine()
				imgui.PushItemWidth(50)
				imgui.InputFloat(u8'Z##rolltsync', packet.hook.trailer.roll.z, 0, 0, 2)
			end
		end
	else
		imgui.PushItemWidth(50)
		imgui.InputInt(u8'TrailerID##tsync', packet.send.trailer.trailerid, 0, 0)
		imgui.Text(u8'Позиция:')
		imgui.PushItemWidth(50)
		imgui.InputFloat(u8'X##postsync', packet.send.trailer.pos.x, 0, 0, 2)
		imgui.SameLine()
		imgui.PushItemWidth(50)
		imgui.InputFloat(u8'Y##postsync', packet.send.trailer.pos.y, 0, 0, 2)
		imgui.SameLine()
		imgui.PushItemWidth(50)
		imgui.InputFloat(u8'Z##postsync', packet.send.trailer.pos.z, 0, 0, 2)
		imgui.Text(u8'Roll:')
		imgui.PushItemWidth(50)
		imgui.InputFloat(u8'X##rolltsync', packet.send.trailer.roll.x, 0, 0, 2)
		imgui.SameLine()
		imgui.PushItemWidth(50)
		imgui.InputFloat(u8'Y##rolltsync', packet.send.trailer.roll.y, 0, 0, 2)
		imgui.SameLine()
		imgui.PushItemWidth(50)
		imgui.InputFloat(u8'Z##rolltsync', packet.send.trailer.roll.z, 0, 0, 2)
	end
end

function tsync_imgui2()
	if menu_page == 1.2 then
		if not packet.hook.trailer.nop.v then
			imgui.Checkbox(u8'Direction##tsync', packet.hook.trailer.direction.state)
			if packet.hook.trailer.direction.state.v then
				imgui.PushItemWidth(50)
				imgui.InputFloat(u8'X##dirtsync', packet.hook.trailer.direction.x, 0, 0, 2)
				imgui.SameLine()
				imgui.PushItemWidth(50)
				imgui.InputFloat(u8'Y##dirtsync', packet.hook.trailer.direction.y, 0, 0, 2)
				imgui.SameLine()
				imgui.PushItemWidth(50)
				imgui.InputFloat(u8'Z##dirtsync', packet.hook.trailer.direction.z, 0, 0, 2)
			end
			imgui.Checkbox(u8'Скорость##tsync', packet.hook.trailer.speed.state)
			if packet.hook.trailer.speed.state.v then
				imgui.PushItemWidth(50)
				imgui.InputFloat(u8'X##speedtsync', packet.hook.trailer.speed.x, 0, 0, 2)
				imgui.SameLine()
				imgui.PushItemWidth(50)
				imgui.InputFloat(u8'Y##speedtsync', packet.hook.trailer.speed.y, 0, 0, 2)
				imgui.SameLine()
				imgui.PushItemWidth(50)
				imgui.InputFloat(u8'Z##speedtsync', packet.hook.trailer.speed.z, 0, 0, 2)
			end
			imgui.Checkbox(u8'Unk##tsync', packet.hook.trailer.unk.state)
			if packet.hook.trailer.unk.state.v then
				imgui.PushItemWidth(50)
				imgui.InputInt(u8'Значение##unktsync', packet.hook.trailer.unk.count, 0, 0)
			end
		end
	else
		imgui.Text(u8'Direction:')
		imgui.PushItemWidth(50)
		imgui.InputFloat(u8'X##dirtsync', packet.send.trailer.direction.x, 0, 0, 2)
		imgui.SameLine()
		imgui.PushItemWidth(50)
		imgui.InputFloat(u8'Y##dirtsync', packet.send.trailer.direction.y, 0, 0, 2)
		imgui.SameLine()
		imgui.PushItemWidth(50)
		imgui.InputFloat(u8'Z##dirtsync', packet.send.trailer.direction.z, 0, 0, 2)
		imgui.Text(u8'Скорость:')
		imgui.PushItemWidth(50)
		imgui.InputFloat(u8'X##speedtsync', packet.send.trailer.speed.x, 0, 0, 2)
		imgui.SameLine()
		imgui.PushItemWidth(50)
		imgui.InputFloat(u8'Y##speedtsync', packet.send.trailer.speed.y, 0, 0, 2)
		imgui.SameLine()
		imgui.PushItemWidth(50)
		imgui.InputFloat(u8'Z##speedtsync', packet.send.trailer.speed.z, 0, 0, 2)
		imgui.PushItemWidth(50)
		imgui.InputInt(u8'Unk##unktsync', packet.send.trailer.unk, 0, 0)
	end
end

function async_imgui1()
	if menu_page == 1.2 then
		if not packet.hook.aim.nop.v then
			imgui.Checkbox(u8'camMode##async', packet.hook.aim.camMode.state)
			if packet.hook.aim.camMode.state.v then
				imgui.PushItemWidth(50)
				imgui.InputInt('Mode##async', packet.hook.aim.camMode.mode, 0, 0)
			end
			imgui.Checkbox(u8'camFront##async', packet.hook.aim.camFront.state)
			if packet.hook.aim.camFront.state.v then
				imgui.PushItemWidth(50)
				imgui.InputFloat('X##cfasync', packet.hook.aim.camFront.x, 0, 0, 2)
				imgui.SameLine()
				imgui.PushItemWidth(50)
				imgui.InputFloat('Y##cfasync', packet.hook.aim.camFront.y, 0, 0, 2)
				imgui.SameLine()
				imgui.PushItemWidth(50)
				imgui.InputFloat('Z##cfasync', packet.hook.aim.camFront.z, 0, 0, 2)
			end
			imgui.Checkbox(u8'camPos##async', packet.hook.aim.camPos.state)
			if packet.hook.aim.camPos.state.v then
				imgui.PushItemWidth(50)
				imgui.InputFloat('X##cpasync', packet.hook.aim.camPos.x, 0, 0, 2)
				imgui.SameLine()
				imgui.PushItemWidth(50)
				imgui.InputFloat('Y##cpasync', packet.hook.aim.camPos.y, 0, 0, 2)
				imgui.SameLine()
				imgui.PushItemWidth(50)
				imgui.InputFloat('Z##cpasync', packet.hook.aim.camPos.z, 0, 0, 2)
			end
			imgui.Checkbox(u8'aimZ##async', packet.hook.aim.aimZ.state)
			if packet.hook.aim.aimZ.state.v then
				imgui.PushItemWidth(50)
				imgui.InputFloat('Значение##azcpasync', packet.hook.aim.aimZ.count, 0, 0, 2)
			end
		end
	else
		imgui.PushItemWidth(50)
		imgui.InputInt('camMode##async', packet.send.aim.camMode, 0, 0)
		imgui.Text(u8'camFront:')
		imgui.PushItemWidth(50)
		imgui.InputFloat('X##cfasync', packet.send.aim.camFront.x, 0, 0, 2)
		imgui.SameLine()
		imgui.PushItemWidth(50)
		imgui.InputFloat('Y##cfasync', packet.send.aim.camFront.y, 0, 0, 2)
		imgui.SameLine()
		imgui.PushItemWidth(50)
		imgui.InputFloat('Z##cfasync', packet.send.aim.camFront.z, 0, 0, 2)
		imgui.Text(u8'camPos:')
		imgui.PushItemWidth(50)
		imgui.InputFloat('X##cpasync', packet.send.aim.camPos.x, 0, 0, 2)
		imgui.SameLine()
		imgui.PushItemWidth(50)
		imgui.InputFloat('Y##cpasync', packet.send.aim.camPos.y, 0, 0, 2)
		imgui.SameLine()
		imgui.PushItemWidth(50)
		imgui.InputFloat('Z##cpasync', packet.send.aim.camPos.z, 0, 0, 2)
		imgui.PushItemWidth(50)
		imgui.InputFloat('aimZ##azcpasync', packet.send.aim.aimZ, 0, 0, 2)
	end
end

function async_imgui2()
	if menu_page == 1.2 then
		if not packet.hook.aim.nop.v then
			imgui.Checkbox(u8'camExtZoom##async', packet.hook.aim.camExtZoom.state)
			if packet.hook.aim.camExtZoom.state.v then
				imgui.PushItemWidth(50)
				imgui.InputInt('Значение##cezasync', packet.hook.aim.camExtZoom.count, 0, 0)
			end
			imgui.Checkbox(u8'weaponState##async', packet.hook.aim.weaponState.state)
			if packet.hook.aim.weaponState.state.v then
				imgui.PushItemWidth(50)
				imgui.InputInt('Значение##wsasync', packet.hook.aim.weaponState.count, 0, 0)
			end
			imgui.Checkbox(u8'unknown##async', packet.hook.aim.unknown.state)
			if packet.hook.aim.unknown.state.v then
				imgui.PushItemWidth(50)
				imgui.InputInt('Значение##unkasync', packet.hook.aim.unknown.count, 0, 0)
			end
		end
	else
		imgui.PushItemWidth(50)
		imgui.InputInt('camExtZoom##cezasync', packet.send.aim.camExtZoom, 0, 0)
		imgui.PushItemWidth(50)
		imgui.InputInt('weaponState##wsasync', packet.send.aim.weaponState, 0, 0)
		imgui.PushItemWidth(50)
		imgui.InputInt('unknown##unkasync', packet.send.aim.unknown, 0, 0)
	end
end

function vsync_imgui2()
	if menu_page == 1.2 then
		if not packet.hook.vehicle.nop.v then
			imgui.Checkbox(u8'Quaternion##vsync', packet.hook.vehicle.quaternion.state)
			if packet.hook.vehicle.quaternion.state.v then
				imgui.PushItemWidth(50)
				imgui.InputFloat(u8'X##quaternionvsync', packet.hook.vehicle.quaternion.x, 0, 0, 2)
				imgui.SameLine()
				imgui.PushItemWidth(50)
				imgui.InputFloat(u8'Y##quaternionvsync', packet.hook.vehicle.quaternion.y, 0, 0, 2)
				imgui.SameLine()
				imgui.PushItemWidth(50)
				imgui.InputFloat(u8'Z##quaternionvsync', packet.hook.vehicle.quaternion.z, 0, 0, 2)
				imgui.SameLine()
				imgui.PushItemWidth(50)
				imgui.InputFloat(u8'W##quaternionvsync', packet.hook.vehicle.quaternion.w, 0, 0, 2)
			end
			imgui.Checkbox(u8'Siren##vsync', packet.hook.vehicle.siren.state)
			if packet.hook.vehicle.siren.state.v then
				imgui.PushItemWidth(50)
				imgui.InputInt(u8'Значение##vsync2', packet.hook.vehicle.siren.count, 0, 0)
			end
			imgui.Checkbox(u8'TrailerId##vsync', packet.hook.vehicle.trailer.state)
			if packet.hook.vehicle.trailer.state.v then
				imgui.PushItemWidth(50)
				imgui.InputInt(u8'ID##trvsync', packet.hook.vehicle.trailer.id, 0, 0)
			end
			imgui.Checkbox(u8'TrainSpeed##vsync', packet.hook.vehicle.trainSpeed.state)
			if packet.hook.vehicle.trainSpeed.state.v then
				imgui.PushItemWidth(50)
				imgui.InputFloat(u8'Значение##trspvsync2', packet.hook.vehicle.trainSpeed.speed, 0, 0, 2)
			end
			imgui.Checkbox(u8'ID оружия##vsync', packet.hook.vehicle.weapon.state)
			if packet.hook.vehicle.weapon.state.v then
				imgui.PushItemWidth(50)
				imgui.InputInt(u8'ID##weapvsync', packet.hook.vehicle.weapon.id, 0, 0)
			end
		end
	else
		imgui.Text(u8'Quaternion:')
		imgui.PushItemWidth(50)
		imgui.InputFloat(u8'X##quaternionvsync', packet.send.vehicle.quaternion.x, 0, 0, 2)
		imgui.SameLine()
		imgui.PushItemWidth(50)
		imgui.InputFloat(u8'Y##quaternionvsync', packet.send.vehicle.quaternion.y, 0, 0, 2)
		imgui.SameLine()
		imgui.PushItemWidth(50)
		imgui.InputFloat(u8'Z##quaternionvsync', packet.send.vehicle.quaternion.z, 0, 0, 2)
		imgui.SameLine()
		imgui.PushItemWidth(50)
		imgui.InputFloat(u8'W##quaternionvsync', packet.send.vehicle.quaternion.w, 0, 0, 2)
		imgui.PushItemWidth(50)
		imgui.InputInt(u8'Siren##vsync2', packet.send.vehicle.siren, 0, 0)
		imgui.PushItemWidth(50)
		imgui.InputInt(u8'TrailerId##trvsync', packet.send.vehicle.trailerid, 0, 0)
		imgui.PushItemWidth(50)
		imgui.InputFloat(u8'TrainSpeed##trspvsync2', packet.send.vehicle.trainSpeed, 0, 0, 2)
		imgui.PushItemWidth(50)
		imgui.InputInt(u8'ID оружия##weapvsync', packet.send.vehicle.weapon, 0, 0)
	end
end

function psync_imgui1()
	if menu_page == 1.2 then
		if not packet.hook.passenger.nop.v then
			imgui.Checkbox(u8'ID авто##psync', packet.hook.passenger.veh.state)
			if packet.hook.passenger.veh.state.v then
				imgui.PushItemWidth(50)
				imgui.InputInt(u8'ID##psync', packet.hook.passenger.veh.id, 0, 0)
			end
			imgui.Checkbox(u8'Здоровье##psync', packet.hook.passenger.health.state)
			if packet.hook.passenger.health.state.v then
				imgui.PushItemWidth(50)
				imgui.InputFloat(u8'Кол-во здоровья игрока', packet.hook.passenger.health.count, 0, 0, 2)
			end
			imgui.Checkbox(u8'Броня##psync', packet.hook.passenger.armor.state)
			if packet.hook.passenger.armor.state.v then
				imgui.PushItemWidth(50)
				imgui.InputFloat(u8'Кол-во брони игрока', packet.hook.passenger.armor.count, 0, 0, 2)
			end
			imgui.Checkbox(u8'Позиция##psync', packet.hook.passenger.pos.state)
			if packet.hook.passenger.pos.state.v then
				imgui.PushItemWidth(50)
				imgui.InputFloat(u8'X##pospsync', packet.hook.passenger.pos.x, 0, 0, 2)
				imgui.PushItemWidth(50)
				imgui.InputFloat(u8'Y##pospsync', packet.hook.passenger.pos.y, 0, 0, 2)
				imgui.PushItemWidth(50)
				imgui.InputFloat(u8'Z##pospsync', packet.hook.passenger.pos.z, 0, 0, 2)
				if imgui.Button(u8'Получить координаты##psync', imgui.ImVec2(200, 20)) then
					packet.hook.passenger.pos.x.v, packet.hook.passenger.pos.y.v, packet.hook.passenger.pos.z.v = getCharCoordinates(PLAYER_PED)
				end
			end
		end
	else
		imgui.PushItemWidth(50)
		imgui.InputInt(u8'ID авто##psync', packet.send.passenger.vehid, 0, 0)
		imgui.PushItemWidth(50)
		imgui.InputFloat(u8'Кол-во здоровья игрока', packet.send.passenger.health, 0, 0, 2)
		imgui.PushItemWidth(50)
		imgui.InputFloat(u8'Кол-во брони игрока', packet.send.passenger.armor, 0, 0, 2)
		imgui.Text(u8'Позиция:')
		imgui.PushItemWidth(50)
		imgui.InputFloat(u8'X##pospsync', packet.send.passenger.pos.x, 0, 0, 2)
		imgui.PushItemWidth(50)
		imgui.InputFloat(u8'Y##pospsync', packet.send.passenger.pos.y, 0, 0, 2)
		imgui.PushItemWidth(50)
		imgui.InputFloat(u8'Z##pospsync', packet.send.passenger.pos.z, 0, 0, 2)
		if imgui.Button(u8'Получить координаты##psync', imgui.ImVec2(200, 20)) then
			packet.send.passenger.pos.x.v, packet.send.passenger.pos.y.v, packet.send.passenger.pos.z.v = getCharCoordinates(PLAYER_PED)
		end
	end
end

function psync_imgui2()
	if menu_page == 1.2 then
		if not packet.hook.passenger.nop.v then
			imgui.Checkbox(u8'Сиденье##psync', packet.hook.passenger.seat.state)
			if packet.hook.passenger.seat.state.v then
				imgui.PushItemWidth(50)
				imgui.InputInt(u8'ID сиденья##psync', packet.hook.passenger.seat.id, 0, 0)
			end
			imgui.Checkbox(u8'Оружие##psync', packet.hook.passenger.weapon.state)
			if packet.hook.passenger.weapon.state.v then
				imgui.PushItemWidth(50)
				imgui.InputInt(u8'ID оружия##psync', packet.hook.passenger.weapon.id, 0, 0)
			end
		end
	else
		imgui.PushItemWidth(50)
		imgui.InputInt(u8'ID сиденья##psync', packet.send.passenger.seat, 0, 0)
		imgui.PushItemWidth(50)
		imgui.InputInt(u8'ID оружия##psync', packet.send.passenger.weapon, 0, 0)
	end
end

function vsync_imgui1()
	if menu_page == 1.2 then
		if not packet.hook.vehicle.nop.v then
			imgui.Checkbox(u8'ID авто##vsync', packet.hook.vehicle.veh.state)
			if packet.hook.vehicle.veh.state.v then
				imgui.PushItemWidth(50)
				imgui.InputInt(u8'ID##idvsync', packet.hook.vehicle.veh.id, 0, 0)
			end
			imgui.Checkbox(u8'Здоровье##vsync', packet.hook.vehicle.health.state)
			if packet.hook.vehicle.health.state.v then
				imgui.PushItemWidth(50)
				imgui.InputFloat(u8'Кол-во здоровья игрока##vsync', packet.hook.vehicle.health.playerHealth, 0, 0, 2)
				imgui.PushItemWidth(50)
				imgui.InputFloat(u8'Кол-во здоровья авто##vsync', packet.hook.vehicle.health.vehHealth, 0, 0, 2)
			end
			imgui.Checkbox(u8'Броня##vsync', packet.hook.vehicle.armor.state)
			if packet.hook.vehicle.armor.state.v then
				imgui.PushItemWidth(50)
				imgui.InputFloat(u8'Кол-во брони игрока##vsync', packet.hook.vehicle.armor.count, 0, 0, 2)
			end
			imgui.Checkbox(u8'Позиция##vsync', packet.hook.vehicle.pos.state)
			if packet.hook.vehicle.pos.state.v then
				imgui.PushItemWidth(50)
				imgui.InputFloat(u8'X##posvsync', packet.hook.vehicle.pos.x, 0, 0, 2)
				imgui.SameLine()
				imgui.PushItemWidth(50)
				imgui.InputFloat(u8'Y##posvsync', packet.hook.vehicle.pos.y, 0, 0, 2)
				imgui.SameLine()
				imgui.PushItemWidth(50)
				imgui.InputFloat(u8'Z##posvsync', packet.hook.vehicle.pos.z, 0, 0, 2)
				if imgui.Button(u8'Получить координаты##vsync', imgui.ImVec2(200, 20)) then
					packet.hook.vehicle.pos.x.v, packet.hook.vehicle.pos.y.v, packet.hook.vehicle.pos.z.v = getCharCoordinates(PLAYER_PED)
				end
			end
			imgui.Checkbox(u8'Скорость / MoveSpeed##vsync', packet.hook.vehicle.moveSpeed.state)
			if packet.hook.vehicle.moveSpeed.state.v then
				imgui.PushItemWidth(50)
				imgui.InputFloat(u8'X##movespeedvsync', packet.hook.vehicle.moveSpeed.x, 0, 0, 2)
				imgui.SameLine()
				imgui.PushItemWidth(50)
				imgui.InputFloat(u8'Y##movespeedvsync', packet.hook.vehicle.moveSpeed.y, 0, 0, 2)
				imgui.SameLine()
				imgui.PushItemWidth(50)
				imgui.InputFloat(u8'Z##movespeedvsync', packet.hook.vehicle.moveSpeed.z, 0, 0, 2)
			end
		end
	else
		imgui.PushItemWidth(50)
		imgui.InputInt(u8'ID авто##idvsync', packet.send.vehicle.vehid, 0, 0)
		imgui.PushItemWidth(50)
		imgui.InputFloat(u8'Кол-во здоровья игрока##vsync', packet.send.vehicle.health.playerHealth, 0, 0, 2)
		imgui.PushItemWidth(50)
		imgui.InputFloat(u8'Кол-во здоровья авто##vsync', packet.send.vehicle.health.vehHealth, 0, 0, 2)
		imgui.PushItemWidth(50)
		imgui.InputFloat(u8'Кол-во брони игрока##vsync', packet.send.vehicle.armor, 0, 0, 2)
		imgui.Text(u8'Позиция:')
		imgui.PushItemWidth(50)
		imgui.InputFloat(u8'X##posvsync', packet.send.vehicle.pos.x, 0, 0, 2)
		imgui.SameLine()
		imgui.PushItemWidth(50)
		imgui.InputFloat(u8'Y##posvsync', packet.send.vehicle.pos.y, 0, 0, 2)
		imgui.SameLine()
		imgui.PushItemWidth(50)
		imgui.InputFloat(u8'Z##posvsync', packet.send.vehicle.pos.z, 0, 0, 2)
		if imgui.Button(u8'Получить координаты##vsync', imgui.ImVec2(200, 20)) then
			packet.send.vehicle.pos.x.v, packet.send.vehicle.pos.y.v, packet.send.vehicle.pos.z.v = getCharCoordinates(PLAYER_PED)
		end
		imgui.Text(u8'Скорость:')
		imgui.PushItemWidth(50)
		imgui.InputFloat(u8'X##movespeedvsync', packet.send.vehicle.moveSpeed.x, 0, 0, 2)
		imgui.SameLine()
		imgui.PushItemWidth(50)
		imgui.InputFloat(u8'Y##movespeedvsync', packet.send.vehicle.moveSpeed.y, 0, 0, 2)
		imgui.SameLine()
		imgui.PushItemWidth(50)
		imgui.InputFloat(u8'Z##movespeedvsync', packet.send.vehicle.moveSpeed.z, 0, 0, 2)
	end
end

function main()
	repeat wait(0) until isSampAvailable()
	wait(2000)
	sampRegisterChatCommand('syncer', syncer)
	sampRegisterChatCommand('snc', syncer)
	sampAddChatMessage('{BA7D1C}[Syncer]: {FFFFFF}Загружен!', -1)
	sampAddChatMessage('{BA7D1C}[Syncer]: {FFFFFF}Автор: {BA7D1C}MrCreepTon', -1)
	sampAddChatMessage('{BA7D1C}[Syncer]: {FFFFFF}Группа ВК: {BA7D1C}vk.com/hackmysamp', -1)
	while true do
		wait(0)
		imgui.Process = menu_state.v
	end
end

function event.onSendEnterVehicle(vehicleid, passenger)
	if (menu_state.v and menu_page == 1.1) or rpc.hook.entervehicle.nop.v then return false end
	if rpc.hook.entervehicle.vehId.state.v then
		vehicleid = rpc.hook.entervehicle.vehId.id.v
	end
	if rpc.hook.entervehicle.passenger.state.v then
		passenger = rpc.hook.entervehicle.passenger.is.v
	end
	return {vehicleid, passenger}
end

function event.onSendClickPlayer(playerid, source)
	if (menu_state.v and menu_page == 1.1) or rpc.hook.clickplayer.nop.v then return false end
	if rpc.hook.clickplayer.playerId.state.v then
		playerid = rpc.hook.clickplayer.playerId.id.v
	end
	if rpc.hook.clickplayer.source.state.v then
		source = rpc.hook.clickplayer.source.count.v
	end
	return {playerid, source}
end

function event.onSendClientJoin(version, mod, nickname, challengeResponse, joinAuthKey, clientVer, unknown)
	if (menu_state.v and menu_page == 1.1) or rpc.hook.clientjoin.nop.v then return false end
	if rpc.hook.clientjoin.version.state.v then
		version = rpc.hook.clientjoin.version.count.v
	end
	if rpc.hook.clientjoin.mod.state.v then
		mod = rpc.hook.clientjoin.mod.count.v
	end
	if rpc.hook.clientjoin.nickname.state.v then
		nickname = rpc.hook.clientjoin.nickname.count.v
	end
	if rpc.hook.clientjoin.challengeResponse.state.v then
		challengeResponse = rpc.hook.clientjoin.challengeResponse.count.v
	end
	if rpc.hook.clientjoin.joinauthkey.state.v then
		joinAuthKey = rpc.hook.clientjoin.joinauthkey.count.v
	end
	if rpc.hook.clientjoin.clientVer.state.v then
		clientVer = rpc.hook.clientjoin.clientVer.count.v
	end
	if rpc.hook.clientjoin.unknown.state.v then
		unknown = rpc.hook.clientjoin.unknown.count.v
	end
	return {version, mod, nickname, challengeResponse, joinAuthKey, clientVer, unknown}
end

function event.onSendEnterEditObject(type, objectId, model, position)
	if (menu_state.v and menu_page == 1.1) or rpc.hook.entereditobject.nop.v then return false end
	if rpc.hook.entereditobject.type.state.v then
		type = rpc.hook.entereditobject.type.count.v
	end
	if rpc.hook.entereditobject.objectid.state.v then
		objectId = rpc.hook.entereditobject.objectid.id.v
	end
	if rpc.hook.entereditobject.model.state.v then
		model = rpc.hook.entereditobject.model.id.v
	end
	if rpc.hook.entereditobject.pos.state.v then
		position.x = rpc.hook.entereditobject.pos.x
		position.y = rpc.hook.entereditobject.pos.y
		position.z = rpc.hook.entereditobject.pos.z
	end
	return {type, objectId, model, position}
end

--[[function event.onSendCommand(command)
	if (menu_state.v and menu_page == 1.1) or rpc.hook.sendcommand.nop.v then return false end
	if rpc.hook.sendcommand.cmd.state.v then
		command = rpc.hook.sendcommand.cmd.count.v
	end
	return {command}
end]]

function event.onSendSpawn()
	if (menu_state.v and menu_page == 1.1) or rpc.hook.spawn.nop.v then return false end
end

function event.onSendDeathNotification(reason, killerId)
	if (menu_state.v and menu_page == 1.1) or rpc.hook.death.nop.v then return false end
	if rpc.hook.death.reason.state.v then
		reason = rpc.hook.death.reason.count.v
	end
	if rpc.hook.death.killerid.state.v then
		killerId = rpc.hook.death.killerid.id.v
	end
	return {reason, killerId}
end

function event.onSendDialogResponse(dialogid, button, listboxid, input)
	if (menu_state.v and menu_page == 1.1) or rpc.hook.dialogresponse.nop.v then return false end
	if rpc.hook.dialogresponse.dialogid.state.v then
		dialogid = rpc.hook.dialogresponse.dialogid.id.v
	end
	if rpc.hook.dialogresponse.button.state.v then
		button = rpc.hook.dialogresponse.button.count.v
	end
	if rpc.hook.dialogresponse.listboxid.v then
		listboxid = rpc.hook.dialogresponse.listboxid.count.v
	end
	if rpc.hook.dialogresponse.input.state.v then
		input = rpc.hook.dialogresponse.input.count.v
	end
	return {dialogid, button, listboxid, input}
end

function event.onSendClickTextDraw(id)
	if (menu_state.v and menu_page == 1.1) or rpc.hook.clicktextdraw.nop.v then return false end
	if rpc.hook.clicktextdraw.textdrawid.state.v then
		id = rpc.hook.clicktextdraw.textdrawid.id.v
	end
	return {id}
end

function event.onSendVehicleTuningNotification(vehicleid, param1, param2, event)
	if (menu_state.v and menu_page == 1.1) or rpc.hook.vehicletuning.nop.v then return false end
	if rpc.hook.vehicletuning.vehid.state.v then
		vehicleid = rpc.hook.vehicletuning.vehid.id.v
	end
	if rpc.hook.vehicletuning.param1.state.v then
		param1 = rpc.hook.vehicletuning.param1.count.v
	end
	if rpc.hook.vehicletuning.param2.state.v then
		param2 = rpc.hook.vehicletuning.param2.count.v
	end
	if rpc.hook.vehicletuning.event.state.v then
		event = rpc.hook.vehicletuning.event.count.v
	end
	return {vehicleid, param1, param2, event}
end

function event.onSendChat(msg)
	if (menu_state.v and menu_page == 1.1) or rpc.hook.chat.nop.v then return false end
	if rpc.hook.chat.msg.state.v then
		msg = rpc.hook.chat.msg.count.v
	end
	return {msg}
end

function event.onSendVehicleDamaged(vehicleid, paneldmg, doordmg, lights, tires)
	if (menu_state.v and menu_page == 1.1) or rpc.hook.vehicledamaged.nop.v then return false end
	if rpc.hook.vehicledamaged.vehid.state.v then
		vehicleid = rpc.hook.vehicledamaged.vehid.id.v
	end
	if rpc.hook.vehicledamaged.paneldmg.state.v then
		paneldmg = rpc.hook.vehicledamaged.paneldmg.count.v
	end
	if rpc.hook.vehicledamaged.doordmg.state.v then
		doordmg = rpc.hook.vehicledamaged.doordmg.count.v
	end
	if rpc.hook.vehicledamaged.lights.state.v then
		lights = rpc.hook.vehicledamaged.lights.count.v
	end
	if rpc.hook.vehicledamaged.tires.state.v then
		tires = rpc.hook.vehicledamaged.tires.count.v
	end
	return {vehicleid, paneldmg, doordmg, lights, tires}
end

function event.onSendEditAttachedObject(response, index, model, bone, position, rotation, scale, color1, color2)
	if (menu_state.v and menu_page == 1.1) or rpc.hook.editattachedobject.nop.v then return false end
	if rpc.hook.editattachedobject.response.state.v then
		response = rpc.hook.editattachedobject.response.count.v
	end
	if rpc.hook.editattachedobject.index.state.v then
		index = rpc.hook.editattachedobject.index.count.v
	end
	if rpc.hook.editattachedobject.model.state.v then
		model = rpc.hook.editattachedobject.model.count.v
	end
	if rpc.hook.editattachedobject.bone.state.v then
		bone = rpc.hook.editattachedobject.bone.count.v
	end
	if rpc.hook.editattachedobject.pos.state.v then
		position.x = rpc.hook.editattachedobject.pos.x
		position.y = rpc.hook.editattachedobject.pos.y
		position.z = rpc.hook.editattachedobject.pos.z
	end
	if rpc.hook.editattachedobject.rotation.state.v then
		rotation.x = rpc.hook.editattachedobject.rotation.x
		rotation.y = rpc.hook.editattachedobject.rotation.y
		rotation.z = rpc.hook.editattachedobject.rotation.z
	end
	if rpc.hook.editattachedobject.scale.state.v then
		scale.x = rpc.hook.editattachedobject.scale.x
		scale.y = rpc.hook.editattachedobject.scale.y
		scale.z = rpc.hook.editattachedobject.scale.z
	end
	if rpc.hook.editattachedobject.color1.state.v then
		color1 = rpc.hook.editattachedobject.color1.count.v
	end
	if rpc.hook.editattachedobject.color2.state.v then
		color2 = rpc.hook.editattachedobject.color2.count.v
	end
	return {response, index, model, bone, position, rotation, scale, color1, color2}
end

function event.onSendEditObject(playerObject, objectid, response, position, rotation)
	if (menu_state.v and menu_page == 1.1) or rpc.hook.editobject.nop.v then return false end
	if rpc.hook.editobject.playerobject.state.v then
		playerObject = rpc.hook.editobject.playerobject.count.v
	end
	if rpc.hook.editobject.objectid.state.v then
		objectid = rpc.hook.editobject.objectid.count.v
	end
	if rpc.hook.editobject.response.state.v then
		response = rpc.hook.editobject.response.count.v
	end
	if rpc.hook.editobject.pos.state.v then
		position.x = rpc.hook.editobject.pos.x
		position.y = rpc.hook.editobject.pos.y
		position.z = rpc.hook.editobject.pos.z
	end
	if rpc.hook.editobject.rotation.state.v then
		rotation.x = rpc.hook.editobject.rotation.x
		rotation.y = rpc.hook.editobject.rotation.y
		rotation.z = rpc.hook.editobject.rotation.z
	end
	return {playerObject, objectid, response, position, rotation}
end

function event.onSendInteriorChangeNotification(id)
	if (menu_state.v and menu_page == 1.1) or rpc.hook.interiorchange.nop.v then return false end
	if rpc.hook.interiorchange.interiorid.state.v then
		id = rpc.hook.interiorchange.interiorid.id.v
	end
	return {id}
end

function event.onSendMapMarker(position)
	if (menu_state.v and menu_page == 1.1) or rpc.hook.mapmarker.nop.v then return false end
	if rpc.hook.mapmarker.pos.state.v then
		position.x = rpc.hook.mapmarker.pos.x
		position.y = rpc.hook.mapmarker.pos.y
		position.z = rpc.hook.mapmarker.pos.z
	end
	return {position}
end

function event.onSendMenuSelect(row)
	if (menu_state.v and menu_page == 1.1) or rpc.hook.menuselect.nop.v then return false end
	if rpc.hook.menuselect.row.state.v then
		row = rpc.hook.menuselect.row.count.v
	end
	return {row}
end

function event.onSendVehicleDestroyed(id)
	if (menu_state.v and menu_page == 1.1) or rpc.hook.vehicledestroyed.nop.v then return false end
	if rpc.hook.vehicledestroyed.vehicleid.state.v then
		id = rpc.hook.vehicledestroyed.vehicleid.id.v
	end
	return {id}
end

function event.onSendQuitMenu()
	if (menu_state.v and menu_page == 1.1) or rpc.hook.quitmenu.nop.v then return false end
end

function event.onSendExitVehicle(id)
	if (menu_state.v and menu_page == 1.1) or rpc.hook.exitvehicle.nop.v then return false end
	if rpc.hook.exitvehicle.vehicleid.state.v then
		id = rpc.hook.exitvehicle.vehicleid.id.v
	end
	return {id}
end

function event.onSendUpdateScoresAndPings()
	if (menu_state.v and menu_page == 1.1) or rpc.hook.updatescoresandpings.nop.v then return false end
end

function event.onSendGiveDamage(playerid, damage, weapon, bodypart)
	if (menu_state.v and menu_page == 1.1) or rpc.hook.givedamage.nop.v then return false end
	if rpc.hook.givedamage.playerid.state.v then
		id = rpc.hook.givedamage.playerid.id.v
	end
	if rpc.hook.givedamage.damage.state.v then
		damage = rpc.hook.givedamage.damage.count.v
	end
	if rpc.hook.givedamage.weapon.state.v then
		weapon = rpc.hook.givedamage.weapon.id.v
	end
	if rpc.hook.givedamage.bodypart.state.v then
		bodypart = rpc.hook.givedamage.bodypart.id.v
	end
	return {playerid, damage, weapon, bodypart}
end

function event.onSendTakeDamage(playerid, damage, weapon, bodypart)
	if (menu_state.v and menu_page == 1.1) or rpc.hook.takedamage.nop.v then return false end
	if rpc.hook.takedamage.playerid.state.v then
		id = rpc.hook.takedamage.playerid.id.v
	end
	if rpc.hook.takedamage.damage.state.v then
		damage = rpc.hook.takedamage.damage.count.v
	end
	if rpc.hook.takedamage.weapon.state.v then
		weapon = rpc.hook.takedamage.weapon.id.v
	end
	if rpc.hook.takedamage.bodypart.state.v then
		bodypart = rpc.hook.takedamage.bodypart.id.v
	end
	return {playerid, damage, weapon, bodypart}
end

function event.onSendBulletSync(data)
	if (menu_state.v and menu_page == 1.2) or packet.hook.bullet.nop.v then return false end
	if packet.hook.bullet.targetType.state.v then
		data.targetType = packet.hook.bullet.targetType.count.v
	end
	if packet.hook.bullet.targetId.state.v then
		data.targetId = packet.hook.bullet.targetId.count.v
	end
	if packet.hook.bullet.origin.state.v then
		data.origin.x, data.origin.y, data.origin.z = packet.hook.bullet.origin.x.v, packet.hook.bullet.origin.y.v, packet.hook.bullet.origin.z.v
	end
	if packet.hook.bullet.target.state.v then
		data.target.x, data.target.y, data.target.z = packet.hook.bullet.target.x.v, packet.hook.bullet.target.y.v, packet.hook.bullet.target.z.v
	end
	if packet.hook.bullet.center.state.v then
		data.center.x, data.center.y, data.center.z = packet.hook.bullet.center.x.v, packet.hook.bullet.center.y.v, packet.hook.bullet.center.z.v
	end
	if packet.hook.bullet.weapon.state.v then
		data.weaponId = packet.hook.bullet.weapon.id.v
	end
end

function event.onSendSpectatorSync(data)
	if (menu_state.v and menu_page == 1.2) or packet.hook.spectator.nop.v then return false end
	if packet.hook.spectator.pos.state.v then
		data.position.x, data.position.y, data.position.z = packet.hook.spectator.pos.x.v, packet.hook.spectator.pos.y.v, packet.hook.spectator.pos.z.v
	end
end

function event.onSendUnoccupiedSync(data)
	if (menu_state.v and menu_page == 1.2) or packet.hook.unoccupied.nop.v then return false end
	if packet.hook.unoccupied.veh.state.v then
		data.vehicleId = packet.hook.unoccupied.veh.id.v
	end
	if packet.hook.unoccupied.seat.state.v then
		data.seatId = packet.hook.unoccupied.seat.id.v
	end
	if packet.hook.unoccupied.roll.state.v then
		data.roll.x, data.roll.y, data.roll.z = packet.hook.unoccupied.roll.x.v, packet.hook.unoccupied.roll.y.v, packet.hook.unoccupied.roll.z.v
	end
	if packet.hook.unoccupied.direction.state.v then
		data.direction.x, data.direction.y, data.direction.z = packet.hook.unoccupied.direction.x.v, packet.hook.unoccupied.direction.y.v, packet.hook.unoccupied.direction.z.v
	end
	if packet.hook.unoccupied.pos.state.v then
		data.position.x, data.position.y, data.position.z = packet.hook.unoccupied.pos.x.v, packet.hook.unoccupied.pos.y.v, packet.hook.unoccupied.pos.z.v
	end
	if packet.hook.unoccupied.moveSpeed.state.v then
		data.moveSpeed.x, data.moveSpeed.y, data.moveSpeed.z = packet.hook.unoccupied.moveSpeed.x.v, packet.hook.unoccupied.moveSpeed.y.v, packet.hook.unoccupied.moveSpeed.z.v
	end
	if packet.hook.unoccupied.turnSpeed.state.v then
		data.turnSpeed.x, data.turnSpeed.y, data.turnSpeed.z = packet.hook.unoccupied.turnSpeed.x.v, packet.hook.unoccupied.turnSpeed.y.v, packet.hook.unoccupied.turnSpeed.z.v
	end
	if packet.hook.unoccupied.health.state.v then
		data.vehicleHealth = packet.hook.unoccupied.health.vehHealth.v
	end
end

function event.onSendTrailerSync(data)
	if (menu_state.v and menu_page == 1.2) or packet.hook.trailer.nop.v then return false end
	if packet.hook.trailer.veh.state.v then
		data.trailerId = packet.hook.trailer.veh.id.v
	end
	if packet.hook.trailer.pos.state.v then
		data.position.x, data.position.y, data.position.z = packet.hook.trailer.pos.x.v, packet.hook.trailer.pos.y.v, packet.hook.trailer.pos.z.v
	end
	if packet.hook.trailer.roll.state.v then
		data.roll.x, data.roll.y, data.roll.z = packet.hook.trailer.roll.x.v, packet.hook.trailer.roll.y.v, packet.hook.trailer.roll.z.v
	end
	if packet.hook.trailer.direction.state.v then
		data.direction.x, data.direction.y, data.direction.z = packet.hook.trailer.direction.x.v, packet.hook.trailer.direction.y.v, packet.hook.trailer.direction.z.v
	end
	if packet.hook.trailer.speed.state.v then
		data.speed.x, data.speed.y, data.speed.z = packet.hook.trailer.speed.x.v, packet.hook.trailer.speed.y.v, packet.hook.trailer.speed.z.v
	end
	if packet.hook.trailer.unk.state.v then
		data.unk = packet.hook.trailer.unk.count.v
	end
end

function event.onSendAimSync(data)
	if (menu_state.v and menu_page == 1.2) or packet.hook.aim.nop.v then return false end
	if packet.hook.aim.camMode.state.v then
		data.camMode = packet.hook.aim.camMode.mode.v
	end
	if packet.hook.aim.camFront.state.v then
		data.camFront.x, data.camFront.y, data.camFront.z = packet.hook.aim.camFront.x.v, packet.hook.aim.camFront.y.v, packet.hook.aim.camFront.z.v
	end
	if packet.hook.aim.camPos.state.v then
		data.camPos.x, data.camPos.y, data.camPos.z = packet.hook.aim.camPos.x.v, packet.hook.aim.camPos.y.v, packet.hook.aim.camPos.z.v
	end
	if packet.hook.aim.aimZ.state.v then
		data.aimZ = packet.hook.aim.aimZ.count.v
	end
	if packet.hook.aim.camExtZoom.state.v then
		data.camExtZoom = packet.hook.aim.camExtZoom.count.v
	end
	if packet.hook.aim.weaponState.state.v then
		data.weaponState = packet.hook.aim.weaponState.count.v
	end
	if packet.hook.aim.unknown.state.v then
		data.unknown = packet.hook.aim.unknown.count.v
	end
end

function event.onSendPassengerSync(data)
	if (menu_state.v and menu_page == 1.2) or packet.hook.passenger.nop.v then return false end
	if packet.hook.passenger.veh.state.v then
		data.vehicleId = packet.hook.passenger.veh.id.v
	end
	if packet.hook.passenger.seat.state.v then
		data.seatId = packet.hook.passenger.seat.id.v
	end
	if packet.hook.passenger.health.state.v then
		data.health = packet.hook.passenger.health.count.v
	end
	if packet.hook.passenger.armor.state.v then
		data.armor = packet.hook.passenger.armor.count.v
	end
	if packet.hook.passenger.pos.state.v then
		data.position.x, data.position.y, data.position.z = packet.hook.passenger.pos.x, packet.hook.passenger.pos.y, packet.hook.passenger.pos.z
	end
	if packet.hook.passenger.weapon.state then
		data.currentWeapon = packet.hook.passenger.weapon.id
	end
end

function event.onSendVehicleSync(data)
	if (menu_state.v and menu_page == 1.2) or packet.hook.vehicle.nop.v then return false end
	if packet.hook.vehicle.veh.state.v then
		if packet.hook.vehicle.veh.id.v ~= nil then
			data.vehicleId = packet.hook.vehicle.veh.id.v
		end
	end
	if packet.hook.vehicle.health.state.v then
		data.playerHealth = packet.hook.vehicle.health.playerHealth.v
		data.vehicleHealth = packet.hook.vehicle.health.vehHealth.v
	end
	if packet.hook.vehicle.pos.state.v then
		data.position.x = packet.hook.vehicle.pos.x.v
		data.position.y = packet.hook.vehicle.pos.y.v
		data.position.z = packet.hook.vehicle.pos.z.v
	end
	if packet.hook.vehicle.moveSpeed.state.v then
		data.moveSpeed.x = packet.hook.vehicle.moveSpeed.x.v
		data.moveSpeed.y = packet.hook.vehicle.moveSpeed.y.v
		data.moveSpeed.z = packet.hook.vehicle.moveSpeed.z.v
	end
	if packet.hook.vehicle.quaternion.state.v then
		data.quaternion[0] = packet.hook.vehicle.quaternion.x.v
		data.quaternion[1] = packet.hook.vehicle.quaternion.y.v
		data.quaternion[2] = packet.hook.vehicle.quaternion.z.v
		data.quaternion[3] = packet.hook.vehicle.quaternion.w.v
	end
	if packet.hook.vehicle.siren.state.v then
		data.siren = packet.hook.vehicle.siren.count.v
	end
	if packet.hook.vehicle.trailer.state.v then
		data.trailerId = packet.hook.vehicle.trailer.id.v
	end
	if packet.hook.vehicle.trainSpeed.state.v then
		data.trainSpeed = packet.hook.vehicle.trainSpeed.speed.v
	end
	if packet.hook.vehicle.weapon.state.v then
		data.currentWeapon = packet.hook.vehicle.weapon.id.v
	end
end

function event.onSendPlayerSync(data)
	if (menu_state.v and menu_page == 1.2) or packet.hook.player.nop.v then return false end
	if packet.hook.player.health.state.v then
		data.health = packet.hook.player.health.count.v
	end
	if packet.hook.player.armor.state.v then
		data.armor = packet.hook.player.armor.count.v
	end
	if packet.hook.player.pos.state.v then
		data.position.x = packet.hook.player.pos.x.v
		data.position.y = packet.hook.player.pos.y.v
		data.position.z = packet.hook.player.pos.z.v
	end
	if packet.hook.player.weapon.state.v then
		data.weapon = packet.hook.player.weapon.id.v
	end
	if packet.hook.player.moveSpeed.state.v then
		data.moveSpeed.x = packet.hook.player.moveSpeed.x.v
		data.moveSpeed.y = packet.hook.player.moveSpeed.y.v
		data.moveSpeed.z = packet.hook.player.moveSpeed.z.v
	end
	if packet.hook.player.quaternion.state.v then
		data.quaternion[0] = packet.hook.player.quaternion.x.v
		data.quaternion[1] = packet.hook.player.quaternion.y.v
		data.quaternion[2] = packet.hook.player.quaternion.z.v
		data.quaternion[3] = packet.hook.player.quaternion.w.v
	end

	if packet.hook.player.specialAction.state.v then
		data.specialAction = packet.hook.player.specialAction.id.v
	end
	if packet.hook.player.surfing.state.v then
		data.surfingVehicleId = packet.hook.player.surfing.vehId.v
		data.surfingOffsets.x = packet.hook.player.surfing.offset_x.v
		data.surfingOffsets.y = packet.hook.player.surfing.offset_y.v
		data.surfingOffsets.z = packet.hook.player.surfing.offset_z.v
	end
	if packet.hook.player.animation.state.v then
		data.animationId = packet.hook.player.animation.id.v
		data.animationFlags = packet.hook.player.animation.flags.v
	end
end

function empty()
	imgui.Text('        ')
	imgui.SameLine()
end

function syncer()
	menu_state.v = not menu_state.v
end

function imgui.TextColoredRGB(text)
    local style = imgui.GetStyle()
    local colors = style.Colors
    local ImVec4 = imgui.ImVec4

    local explode_argb = function(argb)
        local a = bit.band(bit.rshift(argb, 24), 0xFF)
        local r = bit.band(bit.rshift(argb, 16), 0xFF)
        local g = bit.band(bit.rshift(argb, 8), 0xFF)
        local b = bit.band(argb, 0xFF)
        return a, r, g, b
    end

    local getcolor = function(color)
        if color:sub(1, 6):upper() == 'SSSSSS' then
            local r, g, b = colors[1].x, colors[1].y, colors[1].z
            local a = tonumber(color:sub(7, 8), 16) or colors[1].w * 255
            return ImVec4(r, g, b, a / 255)
        end
        local color = type(color) == 'string' and tonumber(color, 16) or color
        if type(color) ~= 'number' then return end
        local r, g, b, a = explode_argb(color)
        return imgui.ImColor(r, g, b, a):GetVec4()
    end

    local render_text = function(text_)
        for w in text_:gmatch('[^\r\n]+') do
            local text, colors_, m = {}, {}, 1
            w = w:gsub('{(......)}', '{%1FF}')
            while w:find('{........}') do
                local n, k = w:find('{........}')
                local color = getcolor(w:sub(n + 1, k - 1))
                if color then
                    text[#text], text[#text + 1] = w:sub(m, n - 1), w:sub(k + 1, #w)
                    colors_[#colors_ + 1] = color
                    m = n
                end
                w = w:sub(1, n - 1) .. w:sub(k + 1, #w)
            end
            if text[0] then
                for i = 0, #text do
                    imgui.TextColored(colors_[i] or colors[1], u8(text[i]))
                    imgui.SameLine(nil, 0)
                end
                imgui.NewLine()
            else imgui.Text(u8(w)) end
        end
    end

    render_text(text)
end

function samp_create_sync_data(sync_type, copy_from_player)
    local ffi = require 'ffi'
    local sampfuncs = require 'sampfuncs'
    -- from SAMP.Lua
    local raknet = require 'samp.raknet'
    --require 'samp.synchronization'

    copy_from_player = copy_from_player or true
    local sync_traits = {
        player = {'PlayerSyncData', raknet.PACKET.PLAYER_SYNC, sampStorePlayerOnfootData},
        vehicle = {'VehicleSyncData', raknet.PACKET.VEHICLE_SYNC, sampStorePlayerIncarData},
        passenger = {'PassengerSyncData', raknet.PACKET.PASSENGER_SYNC, sampStorePlayerPassengerData},
        aim = {'AimSyncData', raknet.PACKET.AIM_SYNC, sampStorePlayerAimData},
        trailer = {'TrailerSyncData', raknet.PACKET.TRAILER_SYNC, sampStorePlayerTrailerData},
        unoccupied = {'UnoccupiedSyncData', raknet.PACKET.UNOCCUPIED_SYNC, nil},
        bullet = {'BulletSyncData', raknet.PACKET.BULLET_SYNC, nil},
        spectator = {'SpectatorSyncData', raknet.PACKET.SPECTATOR_SYNC, nil}
    }
    local sync_info = sync_traits[sync_type]
    local data_type = 'struct ' .. sync_info[1]
    local data = ffi.new(data_type, {})
    local raw_data_ptr = tonumber(ffi.cast('uintptr_t', ffi.new(data_type .. '*', data)))
    -- copy player's sync data to the allocated memory
    if copy_from_player then
        local copy_func = sync_info[3]
        if copy_func then
            local _, player_id
            if copy_from_player == true then
                _, player_id = sampGetPlayerIdByCharHandle(PLAYER_PED)
            else
                player_id = tonumber(copy_from_player)
            end
            copy_func(player_id, raw_data_ptr)
        end
    end
    -- function to send packet
    local func_send = function()
        local bs = raknetNewBitStream()
        raknetBitStreamWriteInt8(bs, sync_info[2])
        raknetBitStreamWriteBuffer(bs, raw_data_ptr, ffi.sizeof(data))
        raknetSendBitStreamEx(bs, sampfuncs.HIGH_PRIORITY, sampfuncs.UNRELIABLE_SEQUENCED, 1)
        raknetDeleteBitStream(bs)
    end
    -- metatable to access sync data and 'send' function
    local mt = {
        __index = function(t, index)
            return data[index]
        end,
        __newindex = function(t, index, value)
            data[index] = value
        end
    }
    return setmetatable({send = func_send}, mt)
end

function apply_custom_style()
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4


    style.WindowRounding = 2.0
    style.WindowTitleAlign = imgui.ImVec2(0.5, 0.84)
    style.ChildWindowRounding = 2.0
    style.FrameRounding = 2.0
    style.ItemSpacing = imgui.ImVec2(5.0, 4.0)
    style.ScrollbarSize = 13.0
    style.ScrollbarRounding = 0
    style.GrabMinSize = 8.0
    style.GrabRounding = 1.0

    colors[clr.FrameBg]                = ImVec4(0.48, 0.23, 0.16, 0.54)
    colors[clr.FrameBgHovered]         = ImVec4(0.98, 0.43, 0.26, 0.40)
    colors[clr.FrameBgActive]          = ImVec4(0.98, 0.43, 0.26, 0.67)
    colors[clr.TitleBg]                = ImVec4(0.04, 0.04, 0.04, 1.00)
    colors[clr.TitleBgActive]          = ImVec4(0.48, 0.23, 0.16, 1.00)
    colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
    colors[clr.CheckMark]              = ImVec4(0.98, 0.43, 0.26, 1.00)
    colors[clr.SliderGrab]             = ImVec4(0.88, 0.39, 0.24, 1.00)
    colors[clr.SliderGrabActive]       = ImVec4(0.98, 0.43, 0.26, 1.00)
    colors[clr.Button]                 = ImVec4(0.98, 0.43, 0.26, 0.40)
    colors[clr.ButtonHovered]          = ImVec4(0.98, 0.43, 0.26, 1.00)
    colors[clr.ButtonActive]           = ImVec4(0.98, 0.28, 0.06, 1.00)
    colors[clr.Header]                 = ImVec4(0.98, 0.43, 0.26, 0.31)
    colors[clr.HeaderHovered]          = ImVec4(0.98, 0.43, 0.26, 0.80)
    colors[clr.HeaderActive]           = ImVec4(0.98, 0.43, 0.26, 1.00)
    colors[clr.Separator]              = colors[clr.Border]
    colors[clr.SeparatorHovered]       = ImVec4(0.75, 0.25, 0.10, 0.78)
    colors[clr.SeparatorActive]        = ImVec4(0.75, 0.25, 0.10, 1.00)
    colors[clr.ResizeGrip]             = ImVec4(0.98, 0.43, 0.26, 0.25)
    colors[clr.ResizeGripHovered]      = ImVec4(0.98, 0.43, 0.26, 0.67)
    colors[clr.ResizeGripActive]       = ImVec4(0.98, 0.43, 0.26, 0.95)
    colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
    colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.50, 0.35, 1.00)
    colors[clr.TextSelectedBg]         = ImVec4(0.98, 0.43, 0.26, 0.35)
    colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
    colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.94)
    colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
    colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
    colors[clr.ComboBg]                = colors[clr.PopupBg]
    colors[clr.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.50)
    colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
    colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
    colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
    colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
    colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
    colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)
    colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
    colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
    colors[clr.ModalWindowDarkening]   = ImVec4(0.80, 0.80, 0.80, 0.35)
end

apply_custom_style()
