extends Node3D
var transition = [""]
var timer = 0
@onready var timerpos = $canvas/hud/timer.position
var timershake = 0
var tplock = null
var AppID = "3082220"

var head = "res://objects/bowlingball.tscn"
var bodycolor = Color(96.0/255.0, 104.0/255.0, 149.0/255.0)
var outfitcolors = {}
#{"tuxedo" : {"1" : {"r": 0.5, "g": 0.5, "b": 0.5}, "2" : {"r": 1, "g": 1, "b": 1}}} 
var outfit = "res://outfits/defaultplayer.tscn"
var outfittext = ""


var beatelevator = -1
var beatcat = -1
var beatwizard = -1
var beatgunman = -1
var beatsoda = -1
var beathorror = -1

var beatsomethingnormal = false

var beatchallenges = {}

var catwaveeasy = 0
var catwavemedium = 0
var catwavehard = 0
var catwaverpg = 0

var unlockedheads = []
var unlockedoutfits = []
var bits = 0
var bitbags = {}

var gearmotime = 1
var tedtime = 1
var lilwizardtime = 1
var canmantime = 1
var crustytime = 1
var lipstime = 1
var haspaint = false

var zorbus = "zorbus"
var deadboing = false
var freebits = false

var itemdata = {}
var savedhand = {"item": "", "extrainfo": {}}
var lobbypower = {}

var boughtitems = {}
var didintro = false
var didpiracygag = false

var gimme = 0

var baskets = 0

var sensitivity = 5.0
var fov = 75
var quality = 2
var audioeffectcool = 0

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
		
func transitionmusic(file, speed, noloop = false, looptime = 0, loopoff = 0):
	print($music.stream.resource_path)
	if $music.stream.resource_path != file:
		$musictransition.stream = $music.stream
		$musictransition.play()
		$musictransition.seek($music.get_playback_position())
			
		if file != "none":
			var playtime = $music.get_playback_position()
			playtime -= loopoff
			if looptime > 0:
				for i in range(10):
					if playtime > looptime:
						playtime -= 25.6
					else:
						break
			$music.stream = load(file)
			$music.play()
			if !noloop: $music.seek(playtime)
		else:
			$music.stop()
		
		$unpausedprocess.musictransition = 0
		$unpausedprocess.musictransspeed = speed

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if $canvas/hud/timer.visible:
		timer -= delta
		var prevtext = $canvas/hud/timer.text
		$canvas/hud/timer.text = str(int(ceil(timer)))
		if prevtext != $canvas/hud/timer.text:
			if timer-2 != 0:
				var intensity = 8.0/(timer+2.0)-0.4
				if intensity >= 0:
					timershake += intensity*10
					
					$canvas/hud/timer/audio.pitch_scale = 0.5+timershake/20
					$canvas/hud/timer/audio.volume_linear = timershake/20
					$canvas/hud/timer/audio.play()
				else:
					timershake = 0
			
		timershake = lerpf(timershake, 0, delta*4)
		$canvas/hud/timer.position.x = randf_range(-1, 1)*timershake+timerpos.x
		$canvas/hud/timer.position.y = randf_range(-1, 1)*timershake+timerpos.y
		$canvas/hud/timer.modulate = Color(1, (1-timershake), (1-timershake))
		$canvas/hud/timer/particles.modulate = Color(1, 1, 1, (timershake))
		$canvas/hud/timer.scale = Vector2.ONE*(1+(timershake/10))
		
		#fuckass godot update made me do this nightmare nightmare
	var healthvalue = lerpf($canvas/hud/healthbar.value, $player.health, delta*8)
	$canvas/hud/healthbar.value = healthvalue
	if $canvas/hud/healthbar.value < $player.health+0.5 && $canvas/hud/healthbar.value > $player.health-0.5:
		$canvas/hud/healthbar.value = $player.health
	$canvas/hud/healthbar/healthlabel.text = str(int(ceil($canvas/hud/healthbar.value)))
	$canvas/hud/healthbar.tint_progress = Color.from_hsv($canvas/hud/healthbar.value*0.003, 0.5, 1)
	
	var dangerhealth = 30
	var audioeffect = 1-clamp(healthvalue/dangerhealth, 0, 1)
	if $player.dead || get_tree().paused:
		audioeffect = 0
		
	audioeffect *= audioeffectcool
	
	if audioeffectcool > 0: audioeffectcool -= delta/4
	else: audioeffectcool = 0
	
	var distort = 40
	AudioServer.get_bus_effect(0, 1).pre_gain = audioeffect*distort
	AudioServer.get_bus_effect(0, 1).post_gain = audioeffect*(-distort)*0.6
	#AudioServer.get_bus_effect(0, 2).pitch_scale = 1-audioeffect*0.5
	AudioServer.get_bus_effect(0, 3).cutoff_hz = 20500*(1-audioeffect)+50
	
	if $player.hiteffect < audioeffect*0.1: $player.hiteffect = audioeffect*0.1
	if $player.screenshake < audioeffect*0.05: $player.screenshake = audioeffect*0.05
	
	if tplock != null:
		$tppivot.position = tplock.global_position

	RenderingServer.global_shader_parameter_set("player_pos", $player.position)
	
	$canvas/hud/fps.text = "FPS: "+str(round((1.0/delta)*10)/10.0)
	
func _unhandled_input(event):
	if Input.is_action_just_pressed("f2"):
		_on_died_animation_finished(true)
		#$player.hurt(2, "ragdoll")
		#$player.hiteffect = 1
	if Input.is_action_just_pressed("f8"):
		pass
	if Input.is_action_just_pressed("f3"):
		$canvas.visible = !$canvas.visible
		if $"player/camera/gun".get_children().size() >= 1:
			$"player/camera/gun".get_child(0).visible = !$"player/camera/gun".get_child(0).visible
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
				$musictransition.stream_paused = true
				
				AudioServer.get_bus_effect(0, 1).pre_gain = 0
				AudioServer.get_bus_effect(0, 1).post_gain = 0
				AudioServer.get_bus_effect(0, 2).pitch_scale = 1
				AudioServer.get_bus_effect(0, 3).cutoff_hz = 20500
				
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
				beatsoda = 2
				unlockedheads.append("sodacan")
				beathorror = 2
				unlockedheads.append("bioplasm")
				loadmap("res://maps/lobby.tscn", -1, "none")

func loadmap(mappath, diff, chal, playerpos = Vector3.ZERO):
	if !beatsomethingnormal:
		if beatelevator >= 1: beatsomethingnormal = true
		if beatcat >= 1: beatsomethingnormal = true
		if beatwizard >= 1: beatsomethingnormal = true
		if beatgunman >= 1: beatsomethingnormal = true
		if beatsoda >= 1: beatsomethingnormal = true
		if beathorror >= 1: beatsomethingnormal = true
	
	if $map != null:
		$map.name = "deletemap"
		$deletemap.queue_free()
	$player.position = playerpos
	if mappath == "res://maps/elevatorarena.tscn":
		$player.position = Vector3(-10, 0, 0)
	if mappath == "res://maps/gunmanarena.tscn":
		$player.position = Vector3(8, 0, -8)
	if mappath == "res://maps/sodaboss.tscn":
		$player.position = Vector3(0, 0, 8)
		$player.rotation = Vector3(0, 0, 0)
		$player.camera.rotation = Vector3(PI/12, 0, 0)
	if mappath == "res://maps/horrorbossarena.tscn":
		$player.position = Vector3(0, 129.15, 74)
		$player.rotation = Vector3(0, 0, 0)
		$player.camera.rotation = Vector3(0, 0, 0)
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
	$player.candash = false
	$player.jetpack = false
	$player.physicsscale = 1
	$player.dashseconds = 2
	$player.falloff = true
	$player.gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
	setwater(0)
	$canvas/hud/died.play("nothing")
	timer = 100
	$canvas/hud/timer.hide()
	$canvas/hud/gunmanbossbar.hide()
	$canvas/hud/bossbar.hide()
	$canvas/hud/catcount.hide()
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
	$"map/WorldEnvironment".environment.sdfgi_enabled = false
	$qualityupdate.start()

func _on_transitionin_animation_finished():
	if transition[0] == "loadmap":
		if transition.size() == 2:
			loadmap(transition[1], -1, "none")
		elif transition.size() == 4:
			loadmap(transition[1], transition[2], transition[3])
		elif transition.size() == 5:
			loadmap(transition[1], transition[2], transition[3], transition[4])
		else:
			loadmap(transition[1], transition[2], "none")
	if transition[0] == "quit":
		get_tree().quit()
		
	$canvas/hud/transitionin.frame = 0
	transition = [""]
	$canvas/hud/transitionout.play()
	
func transitionfunc(array):
	$canvas/hud/transitionin.play()
	transition = array
	#transition = ["loadmap", "res://maps/"+$map.get_child(0).name+".tscn", dildo, chal]
	$canvas/hud/transitionin/tipanim.play("default")
	
	var tips = [
	"check out the shortcuts in the options menu, stop pressing the restart button like a pleb.",
	"for sega genesis players, there are graphics settings to adjust.",
	"is the music too loud? not loud enough? change it! you can shut it off but i might cry.",
	"theres lots to find in the lobby, look around some time.",
	"this game has achievements, dont you want them all?",
	"some of the harder achievements reward bits!",
	"challenges for each boss are unlocked after beating normal mode",
	"the sock's name is crusty",
	"most characters have lots of dialogue",
	"there are trailers on the youtube channel, subscribe to Tezt Dummi why dontcha.",
	"the red hoodie guy goes somewhere every time you come back to the lobby.",
	"every boss has one bag of bits hidden somewhere, each worth 100 bits",
	"links to important websites are in the credits.",
	"if you want real tips go talk to rim",
	"talk to rim for more tips",
	"labubu is respulsive",
	"santa isnt real",
	"beware the bone men",
	"my name tezt dummi :)",
	"the isnt?",
	"she slap on my stick till i boss",
	"maintaining a pg-13 rating f***ing sucks",
	"rim is kinda cute ngl",
	"icl ts pmo fr",
	"𓀔𓀇𓀅𓀋𓀡𓀡𓀕𓀠𓀧𓀨𓀣𓀷𓀷𓀿𓀿𓁀𓁶𓁰𓁴𓁿𓂀𓁾𓁵𓁯𓂞𓂤𓂗𓃃𓂾𓂺𓂹𓃞𓃙𓃖𓃓𓃕𓃓𓃜𓃘𓃙𓃟𓃛𓃞𓂺𓃂𓂿𓂺𓃃𓃂𓂛𓂏𓅱𓅥𓅩𓅦𓅹𓅸𓅳𓅩𓅪𓄭𓄫𓄮𓄬𓄗𓄑𓄌𓃦𓃧𓃨𓃤𓃟𓃓𓃅𓃁𓂽𓃂𓂊𓁾𓂀𓁽𓁼𓁠𓁛𓁟𓁦𓁜𓁭𓁡𓀔𓀇𓀅𓀋𓀡𓀡𓀕𓀠𓀧𓀨𓀣𓀷𓀷𓀿𓀿𓁀𓁶𓁰𓁴𓁿𓂀𓁾𓁵𓁯𓂞𓂤𓂗𓃃𓂾𓂺𓂹𓃞𓃙𓃖𓃓𓃕𓃓𓃜𓃘𓃙𓃟𓃛𓃞𓂺𓃂𓂿𓂺𓃃𓃂𓂛𓂏𓅱𓅥𓅩𓅦𓅹𓅸𓅳𓅩𓅪𓄭𓄫𓄮𓄬𓄗𓄑𓄌𓃦𓃧𓃨𓃤𓃟𓃓𓃅𓃁𓂽𓃂𓂊𓁾𓂀𓁽𓁼𓁠𓁛𓁟𓁦𓁜𓁭𓁡𓀔𓀇𓀅𓀋𓀡𓀡𓀕𓀠𓀧𓀨𓀣𓀷𓀷𓀿𓀿𓁀𓁶𓁰𓁴𓁿𓂀𓁾𓁵𓁯𓂞𓂤𓂗𓃃𓂾𓂺𓂹𓃞𓃙𓃖𓃓𓃕𓃓𓃜𓃘𓃙𓃟𓃛𓃞𓂺𓃂𓂿𓂺𓃃𓃂𓂛𓂏𓅱𓅥",
	"the FitnessGram Pacer Test is NOT a multistage aerobic capacity test that progressively gets more difficult as it continues, wake up sheeple.",
	"ye is not that bad",
	"zorbus borbus",
	"slapstick lore is actually deep as hell, the roobeer cat represents Ares the god of war",
	"i get like 50 views a video, if you like this game check em out on the Tezt Dummi channel",
	"theses tips are gonna be pretty unreadale for people who's pc's can load levels faster. if you can read the entirety of this message, than your pc might not be very good. bros runnin of a GeForce GTX 480, 64 MB of ram, and a cinderblock for a cpu. if you're still reading this then i feel bad.",
	"leave",
	"don't let Pimpledump show you his secret pimple",
	"long ago there was once a bread named Barry",
	"made you look, dumbahh",
	"bawls stuck to my leg",
	"nothing beats a Jet2holiday, and right now, you can save fifty pounds per person, that's two hundred pounds off for a family of four, we've got millions of free child place holidays available with twenty two kilograms of baggage included, book now with Jet2holidays package holidays you can trust",
	"stand ready for my arriwhere'somnimanareyousureihadaprettyinterestingdayareyousurewecanfinallybebeesthinkmarkareyousurewecanfinallybethebeesweweremeanttobeimmarkingitwhatyoudidwasnotniceareyousureitsnotniceSEASALTareyousureINEEDYOUareyousureSEASALTlookkidwevehadourdifferencesareyousurebutwerestillonthesamesidewerestilltryingtosavelivesareyousureandwerestillthegoodguysareyousureareyousureimsolonelyareyousurealltheotherviltrumitesareareyousurescaredofmeareyousureareyousurenoonetalkestoareyousureareyousureareyousureareyousureareyousureareyousure",
	"im stronger im smarter, im better, I AM BETTER",
	"pee is stored in the balls",
	"AGAIN, AGAIN, AGAIN, AGAIN, AGAIN, BORN AGAIN, AGAIN, AGAIN, AGAIN, AGAIN, AGAIN",
	"there's a bag of bits hidden somewhere in every boss",
	"there is no war in Ba Sing Se",
	"the wee you is underrated",
	"no game fell off harder than Roblocks",
	"zendaya is mid 3000",
	"im eating animal crackers right now, jealous?"
	]
	if randf() <= 0.05: $canvas/hud/transitionin/tip.text = "Player tip: "
	else: $canvas/hud/transitionin/tip.text = "Tip: "
	$canvas/hud/transitionin/tip.text += tips.pick_random()
	
func _on_died_animation_finished(manual = false):
	if $canvas/hud/died.animation == "end" || manual:
		var dildo = $map.diff
		var chal = "none"
		if "chal" in $map:
			chal = $map.chal
		transitionfunc(["loadmap", "res://maps/"+$map.get_child(0).name+".tscn", dildo, chal])
		
func spawnlobbyportal(custompos = Vector3.ZERO):
	var randangle = randf_range(0, PI*2)
	var portal = load("res://lobbyportal.tscn").instantiate()
	portal.name = "lobbyportal"
	if custompos == Vector3.ZERO:
		portal.position = Vector3($player.position.x+sin(randangle)*15, $player.position.y ,$player.position.z+cos(randangle)*15)
	else:
		portal.position = custompos
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
	var uodict = {}
	spot = 0
	for i in unlockedoutfits:
		uodict[str(spot)] = i
		spot += 1
	var ocdict = {}
	spot = 0
		
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
		"fov" : fov,
		"quality" : quality,
		"head" : head,
		"outfit" : outfit,
		"outfittext" : outfittext,
		"bodycolor_r" : bodycolor.r,
		"bodycolor_g" : bodycolor.g,
		"bodycolor_b" : bodycolor.b,
		"outfitcolors" : outfitcolors,
		"beatelevator" : beatelevator,
		"beatcat" : beatcat,
		"beatwizard" : beatwizard,
		"beatgunman" : beatgunman,
		"beatsoda" : beatsoda,
		"beathorror" : beathorror,
		"beatchallenges" : beatchallenges,
		"catwaveeasy" : catwaveeasy,
		"catwavemedium" : catwavemedium,
		"catwavehard" : catwavehard,
		"catwaverpg" : catwaverpg,
		"unlockedheads" : uhdict,
		"unlockedoutfits" : uodict,
		"bits" : bits,
		"bitbags" : bitbags,
		"gearmotime" : gearmotime,
		"tedtime" : tedtime,
		"lipstime" : lipstime,
		"lilwizardtime" : lilwizardtime,
		"canmantime" : canmantime,
		"crustytime" : crustytime,
		"haspaint" : haspaint,
		"zorbus" : zorbus,
		"deadboing" : deadboing,
		"freebits" : freebits,
		"itemdata" : itemdata,
		"savedhand" : savedhand,
		"lobbypower" : lobbypower,
		"boughtitems" : boughtitems,
		"didintro" : didintro,
		"didpiracygag" : didpiracygag,
		"baskets" : baskets
	}
	
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_line(JSON.stringify(content))
	
	$canvas/hud/saveicon/anim.play("default")
	
func load_game():
	var save_path = "user://SlapstickBosses.save"
	if FileAccess.file_exists(save_path):
		var save_game = FileAccess.open(save_path, FileAccess.READ)
		
		var json = JSON.new()
		json.parse(save_game.get_line())
		var data = json.get_data()
		
		print("Save Data: ")
		print(data)
		
		if data.has("master"): AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), data["master"])
		if data.has("music"): AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), data["music"])
		if data.has("sensitivity"): _on_sensitivity_value_changed(data["sensitivity"])
		if data.has("fov"): _on_fov_value_changed(data["fov"])
		if data.has("quality"): _on_quality_value_changed(data["quality"])

		if data.has("head"): head = data["head"]
		if data.has("outfit"): outfit = data["outfit"]
		if data.has("outfittext"): outfittext = data["outfittext"]
		if data.has("bodycolor_r"): bodycolor = Color(data["bodycolor_r"], data["bodycolor_g"], data["bodycolor_b"])

		if data.has("beatelevator"): beatelevator = data["beatelevator"]
		if data.has("beatcat"): beatcat = data["beatcat"]
		if data.has("beatwizard"): beatwizard = data["beatwizard"]
		if data.has("beatgunman"): beatgunman = data["beatgunman"]
		if data.has("beatsoda"): beatsoda = data["beatsoda"]
		if data.has("beathorror"): beathorror = data["beathorror"]
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
				
		if data.has("unlockedoutfits"):
			unlockedoutfits = []
			for i in range(40):
				if data["unlockedoutfits"].has(str(i)):
					unlockedoutfits.append(data["unlockedoutfits"][str(i)])
				else:break
				
		if data.has("outfitcolors"):
			outfitcolors = data["outfitcolors"]
				
				
		if data.has("lobbypower"): lobbypower = data["lobbypower"]
					
		if data.has("bits"): bits = data["bits"]
		if data.has("bitbags"): bitbags = data["bitbags"]
		if data.has("beatchallenges"): beatchallenges = data["beatchallenges"]
		
		if data.has("gearmotime"): gearmotime = data["gearmotime"]
		if data.has("tedtime"): tedtime = data["tedtime"]
		if data.has("lipstime"): lipstime = data["lipstime"]
		if data.has("lilwizardtime"): lilwizardtime = data["lilwizardtime"]
		if data.has("canmantime"): canmantime = data["canmantime"]
		if data.has("crustytime"): crustytime = data["crustytime"]
		if data.has("haspaint"): haspaint = data["haspaint"]
		if data.has("zorbus"): zorbus = data["zorbus"]
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
				
		$player.updatelook()
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
	if chal == "potionofswiftness": returnbits = 500
	if chal == "gunmanfast": returnbits = 750
	if chal == "gunmanrockets": returnbits = 750
	if chal == "sodaspeedrun": returnbits = 750
	if chal == "slidejitzumaster": returnbits = 750
	if chal == "justbox": returnbits = 750
	if chal == "eyes": returnbits = 350
	if chal == "horrorgun": returnbits = 650
	if chal == "boingchallenge": returnbits = 300
	if chal == "stophittingyourself": returnbits = 250
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

func _on_gunmanicon_animation_finished() -> void:
	if $canvas/hud/gunmanbossbar/gunmanicon.animation == "hurt":
		$canvas/hud/gunmanbossbar/gunmanicon.play("default")
		
func _on_shortcuts_pressed() -> void:
	$canvas/hud/pause/shortcuts.visible = !$canvas/hud/pause/shortcuts.visible


func _on_colorleft_pressed() -> void:
	pass # Replace with function body.


func _on_colorright_pressed() -> void:
	pass # Replace with function body.
	
func setwater(val):
	$water.visible = val
	AudioServer.set_bus_effect_enabled(0, 4, val)
	AudioServer.set_bus_effect_enabled(0, 5, val)
	
func setquality(val):
	if val == -1:
		get_viewport().disable_3d = true
		$player.setshaders(false)
	else:
		get_viewport().disable_3d = false
	if val == 0:
		$"map/WorldEnvironment".environment.sdfgi_enabled = false
		$"map/WorldEnvironment".environment.ssr_enabled = false
		$"map/WorldEnvironment".environment.ssao_enabled = false
		$"map/WorldEnvironment".environment.glow_enabled = false
		for child in $"map".get_children():
			if child is DirectionalLight3D:
				child.shadow_enabled = false
		RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_HARD)
		RenderingServer.positional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_HARD)
		RenderingServer.directional_shadow_atlas_set_size(512, true)
		RenderingServer.viewport_set_positional_shadow_atlas_size(get_viewport(), 512)
		get_viewport().scaling_3d_mode = Viewport.SCALING_3D_MODE_BILINEAR
		get_viewport().scaling_3d_scale = 0.5
		RenderingServer.sub_surface_scattering_set_quality(RenderingServer.SUB_SURFACE_SCATTERING_QUALITY_DISABLED)
		$distanceblurshader.hide()
		$outlineshader.hide()
		$player.setshaders(false)
	if val == 1:
		$"map/WorldEnvironment".environment.sdfgi_enabled = false
		$"map/WorldEnvironment".environment.ssr_enabled = false
		$"map/WorldEnvironment".environment.ssao_enabled = false
		$"map/WorldEnvironment".environment.glow_enabled = false
		for child in $"map".get_children():
			if child is DirectionalLight3D:
				child.shadow_enabled = true
		RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_MEDIUM)
		RenderingServer.positional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_MEDIUM)
		RenderingServer.directional_shadow_atlas_set_size(1024, true)
		RenderingServer.viewport_set_positional_shadow_atlas_size(get_viewport(), 1024)
		get_viewport().scaling_3d_mode = Viewport.SCALING_3D_MODE_BILINEAR
		get_viewport().scaling_3d_scale = 0.75
		RenderingServer.sub_surface_scattering_set_quality(RenderingServer.SUB_SURFACE_SCATTERING_QUALITY_DISABLED)
		$distanceblurshader.show()
		$outlineshader.hide()
		$player.setshaders(false)
	if val == 2:
		$"map/WorldEnvironment".environment.sdfgi_enabled = true
		$"map/WorldEnvironment".environment.ssr_enabled = false
		$"map/WorldEnvironment".environment.ssao_enabled = false
		$"map/WorldEnvironment".environment.glow_enabled = true
		for child in $"map".get_children():
			if child is DirectionalLight3D:
				child.shadow_enabled = true
		RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_HIGH)
		RenderingServer.positional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_HIGH)
		RenderingServer.directional_shadow_atlas_set_size(2048, true)
		RenderingServer.viewport_set_positional_shadow_atlas_size(get_viewport(), 2048)
		get_viewport().scaling_3d_mode = Viewport.SCALING_3D_MODE_BILINEAR
		get_viewport().scaling_3d_scale = 1
		RenderingServer.sub_surface_scattering_set_quality(RenderingServer.SUB_SURFACE_SCATTERING_QUALITY_DISABLED)
		$distanceblurshader.show()
		$outlineshader.show()
		$player.setshaders(true)
	if val == 3:
		$"map/WorldEnvironment".environment.sdfgi_enabled = true
		$"map/WorldEnvironment".environment.ssr_enabled = true
		$"map/WorldEnvironment".environment.ssao_enabled = true
		$"map/WorldEnvironment".environment.glow_enabled = true
		for child in $"map".get_children():
			if child is DirectionalLight3D:
				child.shadow_enabled = true
		RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_ULTRA)
		RenderingServer.positional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_ULTRA)
		RenderingServer.directional_shadow_atlas_set_size(4096, true)
		RenderingServer.viewport_set_positional_shadow_atlas_size(get_viewport(), 8192)
		get_viewport().scaling_3d_mode = Viewport.SCALING_3D_MODE_FSR2
		get_viewport().scaling_3d_scale = 1
		RenderingServer.sub_surface_scattering_set_quality(RenderingServer.SUB_SURFACE_SCATTERING_QUALITY_HIGH)
		$distanceblurshader.show()
		$outlineshader.show()
		$player.setshaders(true)
	$"map/WorldEnvironment".environment.ssao_power = 5.5

func _on_quality_value_changed(value: float) -> void:
	quality = value
	$canvas/hud/pause/options/Quality.value = value
	if quality == -1:
		$canvas/hud/pause/options/Qualitylabel.text = "Quality: peak preformance"
		$canvas/hud/pause/options/Qualitylabel.add_theme_font_size_override("font_size", 32)
	else:
		$canvas/hud/pause/options/Qualitylabel.add_theme_font_size_override("font_size", 52)
	if quality == 0: $canvas/hud/pause/options/Qualitylabel.text = "Quality: dog water"
	if quality == 1: $canvas/hud/pause/options/Qualitylabel.text = "Quality: real sh*t"
	if quality == 2: $canvas/hud/pause/options/Qualitylabel.text = "Quality: hot"
	if quality == 3: $canvas/hud/pause/options/Qualitylabel.text = "Quality: creamy"
	if $"map/WorldEnvironment" != null:
		$"map/WorldEnvironment".environment.sdfgi_enabled = false
		$qualityupdate.start()
		
	
func _on_fov_value_changed(value: float) -> void:
	fov = value
	if fov == 75: $canvas/hud/pause/options/FOV.modulate = Color(0.9, 0.9, 1)
	else: $canvas/hud/pause/options/FOV.modulate = Color.WHITE

func _on_qualityupdate_timeout() -> void:
	setquality(quality)
