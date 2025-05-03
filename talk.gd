extends Control
var spokentext = 0
var talkspeed = 20 #edit other variable
@onready var conv = $"../../../conversations/testguy/start"
var camera
var pos
var rot
var camtween = 0
var spos
var srot
var soundtimer = 0
var sound = "gearmonormal"
var soundletters = 2
var optionsappear = false
var clickdelay = 0
var talkcam = false
var song = "guh"
var playtime = 0

func start(thething):
	clickdelay = 0.1 
	show()
	if thething == "gearmo": conv = $"../../../conversations/gearmo/start"
	if thething == "gearmo2nd": conv = $"../../../conversations/gearmo/2nd"
	if thething == "gearmo3rd": conv = $"../../../conversations/gearmo/3rd"
	if thething == "gearmoartstore": conv = $"../../../conversations/gearmo/artstore"
	if thething == "gearmofathotel": conv = $"../../../conversations/gearmo/fathotel"
	if thething == "gearmofountain": conv = $"../../../conversations/gearmo/fountain"
	if thething == "gearmoalley": conv = $"../../../conversations/gearmo/alley"
	if thething == "gearmoboings": conv = $"../../../conversations/gearmo/boings"
	if thething == "gearmobillboard": conv = $"../../../conversations/gearmo/billboard"
	if thething == "ted": conv = $"../../../conversations/ted/start"
	if thething == "lilwizardstart": conv = $"../../../conversations/lilwizard/start"
	if thething == "lilwizard2nd": conv = $"../../../conversations/lilwizard/2nd"
	if thething == "canmanstart": conv = $"../../../conversations/canman/start"
	if thething == "canman2nd": conv = $"../../../conversations/canman/2nd"
	if thething == "ted0": conv = $"../../../conversations/ted/rand0"
	if thething == "ted1": conv = $"../../../conversations/ted/rand1"
	if thething == "ted2": conv = $"../../../conversations/ted/rand2"
	if thething == "ted3": conv = $"../../../conversations/ted/rand3"
	if thething == "challengeguystart": conv = $"../../../conversations/ted/rand3"
	if thething == "lookupguystart": conv = $"../../../conversations/lookupguy/start"
	if thething == "lookupguy0": conv = $"../../../conversations/lookupguy/1"
	if thething == "lookupguy1": conv = $"../../../conversations/lookupguy/2"
	if thething == "lookupguy2": conv = $"../../../conversations/lookupguy/3"
	if thething == "lookupguy3": conv = $"../../../conversations/lookupguy/4"
	decode()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().paused = true
	playtime = $"../../../music".get_playback_position()
	song = $"../../../music".stream.resource_path.get_file()
	$"../../../music".stream = load("res://audio/music/talkymusic.mp3")
	if (conv.get_parent() == $"../../../conversations/ted"):
		$"../../../music".stream = load("res://audio/music/tedmusic.mp3")
	$"../../../music".play()
	if song == "lobbymusic.mp3":
		$"../../../music".seek(playtime)
	
func end():
	hide()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	get_tree().paused = false
	$"../../../".save_game()
	#print(song)
	var newplaytime = $"../../../music".get_playback_position()
	$"../../../music".stream = load("res://audio/music/"+str(song))
	$"../../../music".play()
	if song == "lobbymusic.mp3": $"../../../music".seek(newplaytime)
	else: $"../../../music".seek(playtime)
# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if talkcam:
		if camtween < PI/2:
			camtween += delta*(PI/2)
			var ct = sin(camtween)
			print(ct)
			camera.global_position = Vector3(spos.x*(1-ct)+pos.x*ct, spos.y*(1-ct)+pos.y*ct, spos.z*(1-ct)+pos.z*ct)
			#camera.global_rotation = Vector3(srot.x*(1-ct)+rot.x*ct, srot.y*(1-ct)+rot.y*ct, srot.z*(1-ct)+rot.z*ct)
	if visible:
		if clickdelay > 0: clickdelay -= delta
		soundtimer += delta*talkspeed
		if $talklabel.visible_ratio < 1:
			if soundtimer > soundletters:
				if sound != "":
					if $talklabel.text[$talklabel.visible_characters] != "*":
						if $talklabel.text[$talklabel.visible_characters] != " ":
							$talksound.stream = load("res://audio/characters/"+sound+"_"+str(randi_range(0, 2))+".mp3")
							$talksound.play()
					else:
						$talksound.stream = load("res://audio/characters/censortext.mp3")
						$talksound.play()
					soundtimer = 0 
		spokentext += delta*talkspeed
		if $talklabel.visible_ratio < 1:
			$talklabel.visible_characters = round(spokentext)
			optionsappear = false
		else:
			if !optionsappear:
				if conv.get_meta("Skip") != null:
					option_press(0)
				else:
					$talkoptions.show()
					for num in range(conv.get_child_count()):
						var option = get_node("talkoptions/"+str(num))
						if option.size.x > 539:
							var extra = option.size.x - 539
							option.add_theme_font_size_override("font_size", (539/option.size.x)*70)
						if option.size.x != 539 && option.get_theme_font_size("font_size") != 76:
							option.size.x = 539
				optionsappear = true
		if $talklabel.size.y > 231:
			$talklabel.add_theme_font_size_override("font_size", (231/$talklabel.size.y)*70)
	
func _on_portrait_animation_looped():
	if $talklabel.visible_ratio >= 1:
		if $portrait.animation == "gearmoscream":
			$portrait.play("gearmoscreamstop")
		elif $portrait.animation == "gearmonervous":
			$portrait.play("gearmonervousidle")
		elif $portrait.animation == "gearmonervousidle": pass
		else:
			print("stoppy")
			$portrait.stop()
		
func _unhandled_input(event):
	if visible:
		if Input.is_action_just_pressed("enter") || Input.is_action_just_pressed("click"):
			if clickdelay <= 0:
				if $talklabel.visible_ratio < 1:
					$talklabel.visible_ratio = 1
				else:
					if conv.get_child_count() == 1:
						option_press(0)
func decode():
	$talklabel.text = conv.editor_description
	if conv.get_meta("Portrait") == null:
		$portrait.animation = "default"
	else:
		$portrait.animation = conv.get_meta("Portrait")
	if conv.get_meta("Sound") == null:
		sound = "gearmonormal"
	else:
		sound = conv.get_meta("Sound")
	$portrait.play()
	spokentext = 0
	$talklabel.visible_characters = 0
	$talklabel.visible_ratio = 0
	
	$talkoptions.hide()
	optionsappear = false
	if conv.get_meta("Speed") != null:
		talkspeed = conv.get_meta("Speed")
	else: talkspeed = 20
	for num in range(4):
		if conv.get_child(num) != null:
			var option = get_node("talkoptions/"+str(num))
			option.show()
			if conv.get_child(num).name == "[NEXT]" || conv.get_child(num).name == "[LEAVE]" || conv.get_child(num).name == "[COSMETICS]" || conv.get_child(num).name == "[CUTSCENE]" || conv.get_child(num).name == "[QUIT]":
				option.hide()
			option.text = conv.get_child(num).name
			option.add_theme_font_size_override("font_size", 76)
			$talklabel.add_theme_font_size_override("font_size", 76)
			$talklabel.size.y = 231
		else:
			var option = get_node("talkoptions/"+str(num))
			option.hide()
			
		if conv.get_child_count() == 1:
			$"talkoptions/0".position = $talkoptions/middle.position
		if conv.get_child_count() == 2:
			$"talkoptions/0".position = $talkoptions/middleleft.position
			$"talkoptions/1".position = $talkoptions/middleright.position
		if conv.get_child_count() == 3:
			$"talkoptions/0".position = $talkoptions/middletop.position
			$"talkoptions/1".position = $talkoptions/bottomleft.position
			$"talkoptions/2".position = $talkoptions/bottomright.position
		if conv.get_child_count() == 4:
			$"talkoptions/0".position = $talkoptions/topleft.position
			$"talkoptions/1".position = $talkoptions/topright.position
			$"talkoptions/2".position = $talkoptions/bottomleft.position
			$"talkoptions/3".position = $talkoptions/bottomright.position

func _on_0_pressed(): option_press(0)
func _on_1_pressed(): option_press(1)
func _on_2_pressed(): option_press(2)
func _on_3_pressed(): option_press(3)
	
func option_press(num):
	if clickdelay <= 0:
		clickdelay = 0.5
		var option = conv.get_child(num)
		if num == -1:
			conv = option
			decode()
		elif option.name == "[LEAVE]":
			end()
		elif option.name == "[COSMETICS]":
			if !$"../cosmetics".visible:
				if !$"../cosmetics/cosmeticbg".is_playing():
					$"../cosmetics/cosmeticbg".play("start")
					$"../cosmetics".show()
					$"../cosmetics".start()
					$"../cosmetics".alpha = 0
					$"../cosmetics".isin = true
		elif option.name == "[CUTSCENE]":
			if $"../../../map/talkcam" != null:
				camera = $"../../../map/talkcam"
				pos = camera.global_position
				camtween = 0
				spos = $"../../../player".global_position
				srot = Vector3.ZERO
				talkcam = true
				camera.current = true
				get_tree().paused = false
				if option.editor_description == "[WIZARD]":
					$cutscenetimer.wait_time = 3.75
					$cutscenetimer.start()
					$"../../../map/wizard".get_surface_override_material(0).albedo_texture = load("res://characters/wizardlaugh.tres")
					$"../../../map/wizard/audio".play()
				hide()
		elif option.name == "[QUIT]":
			$"../../../"._on_quit_pressed()
		else:
			conv = option
			decode()

func _on_cutscenetimer_timeout():
	var option = conv.get_child(0)
	if option.editor_description == "[WIZARD]":
		$"../../../map/littlewizard".delay = 1
		$"../../../map/wizard".get_surface_override_material(0).albedo_texture = load("res://characters/wizard.tres")
	$"../../../player".camera.current = true
	show()
	$"..".show()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().paused = true
	conv = option.get_child(0)
	decode()
	
