extends Node3D
var transition = [""]
var timer = 0
var tplock = null

var AppID = "3082220"

var head = "res://objects/bowlingball.tscn"
var bodycolor = Color(96.0/255.0, 104.0/255.0, 149.0/255.0)

var beatelevator = -1
var beatcat = -1
var beatwizard = -1
var beatgunman = -1

var beatchallenges = {}

var catwaveeasy = 0
var catwavemedium = 0
var catwavehard = 0
var catwaverpg = 0

var unlockedheads = []
var bits = 0
var bitbags = {}

var gearmotime = 1
var tedtime = 1
var lilwizardtime = 1
var canmantime = 1

var deadboing = false
var freebits = false

var itemdata = {}
var savedhand = {"item": "", "extrainfo": {}}

var boughtitems = {}
var didintro = false
var didpiracygag = false

var gimme = 0

var baskets = 0

var sensitivity = 5.0

var hi_source_code_viewer = "im so sorry"

func _init():
	OS.set_environment("SteamAppID", AppID)
	OS.set_environment("SteamGameID", AppID)

var pausedcuzoverlay = false
	
# Called when the node enters the scene tree for the first time.
func _ready():
	Steam.steamInit()
	var isRunning = Steam.isSteamRunning()
	
	if isRunning:
		var id = Steam.getSteamID()
		var name  = Steam.getFriendPersonaName(id)
		print("username: ", str(name))
	else:
		print("steam aint runnin")
		$canvas/hud/steamdisconnect.show()
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	load_game()
	
	DiscordRPC.app_id = 1273706835492208756 # Application ID
	DiscordRPC.details = "The wacky boss fighting game"
	DiscordRPC.state = "Sittin in the Lobby"
	DiscordRPC.large_image = "gameicon" # Image key from "Art Assets"
	DiscordRPC.large_image_text = "Slapstick Bosses is free on Steam!"
	DiscordRPC.small_image = "gameicon" # Image key from "Art Assets"
	DiscordRPC.small_image_text = "havin like a ton of fun dude"

	DiscordRPC.start_timestamp = int(Time.get_unix_time_from_system()) # "02:46 elapsed"
	# DiscordRPC.end_timestamp = int(Time.get_unix_time_from_system()) + 3600 # +1 hour in unix time / "01:00:00 remaining"

	DiscordRPC.refresh() # Always refresh after changing the values!
	
	loadmap("res://maps/lobby.tscn", -1, "none")
	
func setAchievement(ach):
	if Steam.isSteamRunning():
		print(Steam.getAchievement(ach))
		if !Steam.getAchievement(ach)["achieved"]:
			Steam.setAchievement(ach)
			Steam.storeStats()
			#$sfx2.stream = load("res://audio/achievement.mp3")
			#$sfx2.play()
			#Steam.getPOPCount()
			print("got achievement: "+ach)
		else:
			print("already has achievement: "+ach)
		
func setStat(stat, amount):
	if typeof(amount) == TYPE_FLOAT:
		Steam.setStatFloat(stat, amount)
	if typeof(amount) == TYPE_INT:
		Steam.setStatInt(stat, amount)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if $canvas/hud/timer.visible:
		timer -= delta
		$canvas/hud/timer.text = str(int(ceil(timer)))
		#fuckass godot update made me do this nightmare nightmare
	$canvas/hud/healthbar.value = $player.health
	$canvas/hud/healthbar/healthlabel.text = str(round($player.health))
	$canvas/hud/healthbar.tint_progress = Color.from_hsv($player.health*0.003, 0.5, 1)
	
	if tplock != null:
		$tppivot.position = tplock.global_position

	RenderingServer.global_shader_parameter_set("player_pos", $player.position)
	
func _unhandled_input(event):
	if Input.is_action_just_pressed("f2"):
		_on_died_animation_finished(true)
		#$player.hurt(100, "ragdoll")
	if Input.is_action_just_pressed("f3"):
		$canvas.visible = !$canvas.visible
		if $"player/camera/gun".get_children().size() >= 1:
			$"player/camera/gun".get_child(0).queue_free()
		print("hudgone")
	if Input.is_action_just_pressed("f11"):
		_on_fullscreen_pressed()
	if Input.is_action_just_pressed("enter"):
		if $player.dead:
			if !$canvas/hud/died.is_playing() && transition == [""]:
				$canvas/hud/died.play("end")
	if Input.is_action_just_pressed("click"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if Input.is_action_just_pressed("esc"):
		if !$canvas/hud/pause.visible && !$canvas/hud/transitionin.is_playing() && !$canvas/hud/transitionout.is_playing():
			if !$canvas/hud/pause/pausebg.is_playing():
				$canvas/hud/pause/pausebg.play("start")
				$canvas/hud/pause.show()
				$canvas/hud.show()
				$canvas/hud/pause.alpha = 0
				$canvas/hud/pause.isin = true
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
				$canvas/hud/pause/options/Master.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")))
				$canvas/hud/pause/options/Music.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music")))
				$canvas/hud/pause/options/Sensitivity.value = sensitivity
				$music.stream_paused = true
				get_tree().paused = true
	if Input.is_action_just_pressed("x"):
		if $canvas/hud/steamdisconnect.visible:
			$canvas/hud/steamdisconnect.hide()
	if Input.is_action_just_pressed("trainhorn"):
		$trainhorn.stream = load("res://audio/trainhorn.mp3")
		$trainhorn.play()
		if $player.screenshake <= 0.1: $player.screenshake = 0.1
	if Input.is_action_just_released("trainhorn"):
		$trainhorn.stream = load("res://audio/trainhornstop.wav")
		$trainhorn.play()
	#gimme code
	if true:
		if Input.is_action_just_pressed("up"): gimme = 0
		if gimme == 0:
			if Input.is_action_just_pressed("g"): gimme = 1
		elif gimme == 1:
			if Input.is_action_just_pressed("i"): gimme = 2
		elif gimme == 2:
			if Input.is_action_just_pressed("m"): gimme = 3
		elif gimme == 3:
			if Input.is_action_just_pressed("m"): gimme = 4
		elif gimme == 4:
			if Input.is_action_just_pressed("e"):
				gimme = 0
				bits += 1000
				var popup = load("res://popup.tscn").instantiate()
				popup.bits = 1000
				$"sfx".stream = load("res://audio/gainbits.mp3")
				$"sfx".play()
				$"canvas/hud".add_child(popup)
			if Input.is_action_just_pressed("i"):
				gimme = 0
				beatelevator = 2
				unlockedheads.append("elevator")
				beatcat = 2
				unlockedheads.append("catsoldier")
				beatwizard = 2
				unlockedheads.append("wizardhat")
				beatgunman = 2
				unlockedheads.append("gunman")
				loadmap("res://maps/lobby.tscn", -1, "none")

func loadmap(mappath, diff, chal):
	if $map != null:
		$map.name = "deletemap"
		$deletemap.queue_free()
	$player.position = Vector3.ZERO
	if mappath == "res://maps/elevatorarena.tscn":
		$player.position = Vector3(-10, 0, 0)
	if mappath == "res://maps/gunmanarena.tscn":
		$player.position = Vector3(8, 0, -8)
	$player.dead = false
	$player.health = 100
	$player.camera.current = true
	$player.velocity = Vector3.ZERO
	$player.SPEED = 2
	$player.JUMP_VELOCITY = 12
	$player.candoublejump = false
	$player.djseconds = 3
	$player.camlock = false
	$player.cancrouch = false
	$player.falloff = true
	$canvas/hud/died.animation = "start"
	$canvas/hud/died.frame = 0
	timer = 100
	$canvas/hud/timer.hide()
	$canvas/hud/gunmanbossbar.hide()
	for child in $"player/camera/gun".get_children():
		if !child.has_meta("held"):
			child.queue_free()
	$"player/camera/gun".show()
	print(mappath)
	var mapload = load(mappath).instantiate()
	$canvas/hud/difficultylabel.hide()
	if chal != "none":
		mapload.chal = chal
	if diff != -1:
		mapload.diff = diff
		if mappath == "res://maps/catarena.tscn":
			if diff == 0: mapload.wave = catwaveeasy
			if diff == 1: mapload.wave = catwavemedium
			if diff == 2: mapload.wave = catwavehard
			if chal == "catrpg": mapload.wave = catwaverpg
		$canvas/hud/difficultylabel.show()
		if diff == 0: $canvas/hud/difficultylabel.texture = load("res://ui/easy.png")
		if diff == 1: $canvas/hud/difficultylabel.texture = load("res://ui/medium.png")
		if diff == 2: $canvas/hud/difficultylabel.texture = load("res://ui/hard.png")
		if chal != "none": $canvas/hud/difficultylabel.texture = load("res://ui/challenge.png")
	add_child(mapload)
	mapload.name = "map"
	if mapload.get_child(0).editor_description != "":
		var activity = mapload.get_child(0).editor_description
		if mapload.get_child(0).has_meta("discdiff"):
			if diff == 0: activity = activity+" - Easy"
			if diff == 1: activity = activity+" - Medium"
			if diff == 2: activity = activity+" - Hard"
			if chal != "none": activity = activity+" - Challenge (chal: "+chal+")"
		DiscordRPC.state = activity
		DiscordRPC.refresh()
	else:
		DiscordRPC.state = "Doing something idk i forgot to put the discord activity thing for whatever hes playing"
		DiscordRPC.refresh()
	for item in itemdata:
		if itemdata[item]["map"] == mappath:
			var placed = load("res://items/placed/"+item+".tscn").instantiate()
			print(itemdata[item])
			if itemdata[item].has("posx"):
				placed.position.x = itemdata[item]["posx"]
				placed.position.y = itemdata[item]["posy"]
				placed.position.z = itemdata[item]["posz"]
				placed.rotation.y = itemdata[item]["rot"]
			if itemdata[item].has("extrainfo"):
				placed.extrainfo = itemdata[item]["extrainfo"]
			mapload.add_child(placed)

func _on_transitionin_animation_finished():
	if transition[0] == "loadmap":
		if transition.size() == 2:
			loadmap(transition[1], -1, "none")
		elif transition.size() == 4:
			loadmap(transition[1], transition[2], transition[3])
		else:
			loadmap(transition[1], transition[2], "none")
	if transition[0] == "quit":
		get_tree().quit()
		
	$canvas/hud/transitionin.frame = 0
	transition = [""]
	$canvas/hud/transitionout.play()

func _on_died_animation_finished(manual = false):
	if $canvas/hud/died.animation == "end" || manual:
		$canvas/hud/transitionin.play()
		var dildo = $map.diff
		var chal = "none"
		if "chal" in $map:
			chal = $map.chal
		transition = ["loadmap", "res://maps/"+$map.get_child(0).name+".tscn", dildo, chal]
		
func spawnlobbyportal():
	var randangle = randf_range(0, PI*2)
	var portal = load("res://lobbyportal.tscn").instantiate()
	portal.name = "lobbyportal"
	portal.position = Vector3($player.position.x+sin(randangle)*15, $player.position.y ,$player.position.z+cos(randangle)*15)
	$map.add_child(portal)
	
	var currenthead = $"player/Armature/Skeleton3D/headbone/offset".get_child(0)
	if currenthead.has_meta("winsound"):
		var tempaudio = load("res://tempaudio.tscn").instantiate()
		$player.add_child(tempaudio)
		tempaudio.stream = load("res://audio/winsounds/"+str(currenthead.get_meta("winsound"))+".mp3")
		tempaudio.play()
	
func calcbits(curbeat, prevbeat, mult):
	var addbits = 0
	if curbeat == 0: addbits = 200
	if curbeat == 1: addbits = 500
	if curbeat == 2: addbits = 1000
	if prevbeat == 0: addbits -= 200
	if prevbeat == 1: addbits -= 500
	if prevbeat == 2: addbits -= 1000
	return addbits*mult

func save_game():
	var save_path = "user://SlapstickBosses.save"
	
	var isfullscreen = false
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN: isfullscreen = true
	
	var uhdict = {}
	var spot = 0
	for i in unlockedheads:
		uhdict[str(spot)] = i
		spot += 1
		
	var handwassaved = false
	for child in $"player/camera/gun".get_children():
		if child.has_meta("held"):
			savedhand["item"] = "res://items/held/"+child.item+".tscn"
			savedhand["extrainfo"] = child.extrainfo
			handwassaved = true
	if !handwassaved: 
		savedhand = {"item": "", "extrainfo": {}}
	
	var content = {
		"!hey_you_the_guy_lookin_at_the_save_data": "if u edit the save data yur a booty chewer",
		"fullscreen": isfullscreen,
		"master" : AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")),
		"music" : AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music")),
		"sensitivity" : sensitivity,
		"head" : head,
		"bodycolor_r" : bodycolor.r,
		"bodycolor_g" : bodycolor.g,
		"bodycolor_b" : bodycolor.b,
		"beatelevator" : beatelevator,
		"beatcat" : beatcat,
		"beatwizard" : beatwizard,
		"beatgunman" : beatgunman,
		"beatchallenges" : beatchallenges,
		"catwaveeasy" : catwaveeasy,
		"catwavemedium" : catwavemedium,
		"catwavehard" : catwavehard,
		"catwaverpg" : catwaverpg,
		"unlockedheads" : uhdict,
		"bits" : bits,
		"bitbags" : bitbags,
		"gearmotime" : gearmotime,
		"tedtime" : tedtime,
		"lilwizardtime" : lilwizardtime,
		"canmantime" : canmantime,
		"deadboing" : deadboing,
		"freebits" : freebits,
		"itemdata" : itemdata,
		"savedhand" : savedhand,
		"boughtitems" : boughtitems,
		"didintro" : didintro,
		"didpiracygag" : didpiracygag,
		"baskets" : baskets
	}
	
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_line(JSON.stringify(content))
	
func load_game():
	var save_path = "user://SlapstickBosses.save"
	if FileAccess.file_exists(save_path):
		var save_game = FileAccess.open(save_path, FileAccess.READ)
		
		var json = JSON.new()
		json.parse(save_game.get_line())
		var data = json.get_data()
		
		if data.has("master"): AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), data["master"])
		if data.has("music"): AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), data["music"])
		if data.has("sensitivity"): sensitivity = data["sensitivity"]

		print("Save Data: ")
		print(data)

		if data.has("head"): head = data["head"]
		if data.has("bodycolor_r"): bodycolor = Color(data["bodycolor_r"], data["bodycolor_g"], data["bodycolor_b"])
		$player.updatelook()

		if data.has("beatelevator"): beatelevator = data["beatelevator"]
		if data.has("beatcat"): beatcat = data["beatcat"]
		if data.has("beatwizard"): beatwizard = data["beatwizard"]
		if data.has("beatgunman"): beatgunman = data["beatgunman"]
		if data.has("catwaveeasy"): catwaveeasy = data["catwaveeasy"]
		if data.has("catwavemedium"): catwavemedium = data["catwavemedium"]
		if data.has("catwavehard"): catwavehard = data["catwavehard"]
		if data.has("catwaverpg"): catwaverpg = data["catwaverpg"]
		
		if data.has("unlockedheads"):
			unlockedheads = []
			for i in range(40):
				if data["unlockedheads"].has(str(i)):
					unlockedheads.append(data["unlockedheads"][str(i)])
				else:break
					
		if data.has("bits"): bits = data["bits"]
		if data.has("bitbags"): bitbags = data["bitbags"]
		if data.has("beatchallenges"): beatchallenges = data["beatchallenges"]
		
		if data.has("gearmotime"): gearmotime = data["gearmotime"]
		if data.has("tedtime"): tedtime = data["tedtime"]
		if data.has("lilwizardtime"): lilwizardtime = data["lilwizardtime"]
		if data.has("canmantime"): canmantime = data["canmantime"]
		if data.has("deadboing"): deadboing = data["deadboing"]
		if data.has("freebits"): freebits = data["freebits"]
		if data.has("itemdata"): itemdata = data["itemdata"]
		if data.has("boughtitems"): boughtitems = data["boughtitems"]
		if data.has("didintro"): didintro = data["didintro"]
		if data.has("didpiracygag"): didpiracygag = data["didpiracygag"]
		if data.has("baskets"): baskets = data["baskets"]
		
		if data.has("savedhand"):
			savedhand = data["savedhand"]
			if savedhand["item"] != "":
				var item = load(savedhand["item"]).instantiate()
				item.extrainfo = savedhand["extrainfo"]
				$"player/camera/gun".add_child(item)
	else:
		$player.updatelook()
		
		
func getchalbits(chal):
	var returnbits = 200
	if chal == "rats": returnbits = 500
	if chal == "2elevators": returnbits = 750
	if chal == "6pack": returnbits = 750
	if chal == "catrpg": returnbits = 250
	if chal == "timedwizard": returnbits = 250
	if chal == "pimpleremix": returnbits = 1000
	if chal == "gunmanfast": returnbits = 750
	if chal == "gunmanrockets": returnbits = 750
	return returnbits
	
func _on_quit_pressed():
	get_tree().paused = false
	$canvas/hud/transitionin.play()
	transition = ["quit"]
	$sfx2.stream = load("res://audio/byebye.mp3")
	$sfx2.play()
	
func _exit_tree():
	save_game()
	
func _on_options_pressed():
	$canvas/hud/pause/text.hide()
	$canvas/hud/pause/options.show()
func _on_fullscreen_pressed():
	if DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
func _on_options_back_pressed():
	$canvas/hud/pause/text.show()
	$canvas/hud/pause/options.hide()

func _on_master_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))
	print(linear_to_db(0.5))
	$canvas/hud/pause/options/mastertick.play()

func _on_music_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(value))
	$canvas/hud/pause/options/mastertick.play()


func _on_music_focus_entered(): $canvas/hud/pause/options/musicpreview.play()
func _on_music_focus_exited(): $canvas/hud/pause/options/musicpreview.stop()


func _on_music_finished():
	if $music.stream.resource_path.get_file() == "deathmusic.mp3":
		$music.stream = load("res://audio/music/deathmusicloop.mp3")
		$music.play()
	
func anybutton():
	$sfx.stream = load("res://audio/click.mp3")
	$sfx.play()
	
func anybuttonfocus():
	$tick.play()


func _on_outlineshadertimer_timeout():
	var noise = $outlineshader.get_surface_override_material(0).get_shader_parameter("noise_texture").noise
	noise.offset.x = randf_range(-100, 100)
	noise.offset.y = randf_range(-100, 100)
	noise.offset.z = randf_range(-100, 100)

func _on_sensitivity_value_changed(value):
	sensitivity = value
	if sensitivity == 5: $canvas/hud/pause/options/Sensitivity.modulate = Color(0.9, 0.9, 1)
	else: $canvas/hud/pause/options/Sensitivity.modulate = Color.WHITE
