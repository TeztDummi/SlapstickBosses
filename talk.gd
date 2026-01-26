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
var characterobject = null
var soundalternate = false

func start(thething, characterobjfunc = null):
	clickdelay = 0.1 
	show()
	
	characterobject = characterobjfunc
	
	conv = null
	
	if thething == "gearmo": conv = $"../../../conversations/gearmo/start"
	if thething == "gearmo2nd": conv = $"../../../conversations/gearmo/2nd"
	if thething == "gearmo3rd": conv = $"../../../conversations/gearmo/3rd"
	if thething == "gearmoartstore": conv = $"../../../conversations/gearmo/artstore"
	if thething == "gearmobehindartstore": conv = $"../../../conversations/gearmo/behindartstore"
	if thething == "gearmofathotel": conv = $"../../../conversations/gearmo/fathotel"
	if thething == "gearmofountain": conv = $"../../../conversations/gearmo/fountain"
	if thething == "gearmoalley": conv = $"../../../conversations/gearmo/alley"
	if thething == "gearmoboings": conv = $"../../../conversations/gearmo/boings"
	if thething == "gearmobillboard": conv = $"../../../conversations/gearmo/billboard"
	if thething == "gearmogloop": conv = $"../../../conversations/gearmo/gloop"
	if thething == "gearmoburgshelter": conv = $"../../../conversations/gearmo/burgshelter"
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
	if thething == "crustystart": conv = $"../../../conversations/crusty/start"
	if thething == "crusty2nd": conv = $"../../../conversations/crusty/2nd"
	if thething == "crustytrespass": conv = $"../../../conversations/crusty/trespass"
	if thething == "canmanstealingpaint": conv = $"../../../conversations/canman/stealingpaint"
	
	if conv == null:
		conv = $"../../../conversations".get_node(thething)
	
	decode()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().paused = true
	playtime = $"../../../music".get_playback_position()
	song = $"../../../music".stream.resource_path.get_file()
	if (conv.get_parent() == $"../../../conversations/ted"):
		$"../../../".transitionmusic("res://audio/music/tedmusic.mp3", 1, !(song == "lobbymusic.mp3"))
	elif (conv.get_parent() == $"../../../conversations/lips"):
		$"../../../".transitionmusic("res://audio/music/outfittheme.mp3", 1, !(song == "lobbymusic.mp3"))
	else:
		$"../../../".transitionmusic("res://audio/music/talkymusic.mp3", 1, !(song == "lobbymusic.mp3"))
		
func end():
	hide()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	get_tree().paused = false
	$"../../../".save_game()
	#print(song)
	$"../../../".transitionmusic("res://audio/music/"+str(song), 1, !(song == "lobbymusic.mp3"))
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
					var soundplayer = $talksound
					#if soundalternate: soundplayer = $talksound2
					#soundalternate = !soundalternate 
					if !$firstsound.playing:
						if $talklabel.get_parsed_text()[$talklabel.visible_characters] != "*":
							if $talklabel.get_parsed_text()[$talklabel.visible_characters] != " ":
								soundplayer.stream = load("res://audio/characters/"+sound+"_"+str(randi_range(0, 2))+".mp3")
								soundplayer.play()
						else:
							soundplayer.stream = load("res://audio/characters/censortext.mp3")
							soundplayer.play()
						soundtimer = 0 
		spokentext += delta*talkspeed
		if $talklabel.visible_ratio < 1:
			$talklabel.visible_characters = round(spokentext)
			$talklabel.scroll_to_line($talklabel.get_visible_line_count()-3)
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
							for i in range(100):
								if (option.size.x > 539):
									var fontsize = option.get_theme_font_size("font_size")
									option.add_theme_font_size_override("font_size", fontsize-1)
									option.size.x = 539
								else:
									var fontsize = option.get_theme_font_size("font_size")
									option.add_theme_font_size_override("font_size", fontsize-2)
									break
						if option.size.x != 539 && option.get_theme_font_size("font_size") != 76:
							option.size.x = 539
				optionsappear = true
		if $talklabel.size.y > 231:
			var fontsize = $talklabel.get_theme_font_size("font_size")
			$talklabel.add_theme_font_size_override("font_size", fontsize-200*delta)
	
func _on_portrait_animation_looped():
	if $talklabel.visible_ratio >= 1:
		if $portrait.animation == "gearmoscream":
			$portrait.play("gearmoscreamstop")
		elif $portrait.animation == "gearmonervous":
			$portrait.play("gearmonervousidle")
		elif $portrait.animation == "crustycrazy":
			$portrait.play("crustycrazystop")
		elif $portrait.animation == "crustysketchy":
			$portrait.play("crustysketchystop")
		elif $portrait.animation == "gearmonervousidle": pass
		elif $portrait.animation == "crustytweaking": pass
		elif $portrait.animation == "crustycrazystop": pass
		elif $portrait.animation == "crustysketchystop": pass
		elif $portrait.animation == "levelguyhappy": pass
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
	var parsed = $talklabel.get_parsed_text()
	var translation = tr(parsed)
	print("parsed:")
	if translation != parsed:
		$talklabel.text = translation
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
	
	$talklabel.add_theme_font_size_override("font_size", 76)
	
	$talkoptions.hide()
	optionsappear = false
	if conv.has_meta("speed"):
		talkspeed = conv.get_meta("speed")
	else: talkspeed = 20
	
	
	if conv.has_meta("firstsound"):
		$firstsound.stream = load("res://audio/characters/"+conv.get_meta("firstsound")+".mp3")
		$firstsound.play()
	
	for num in range(4):
		if conv.get_child(num) != null:
			var option = get_node("talkoptions/"+str(num))
			option.show()
			
			if conv.get_child(num).name == "[NEXT]": option.hide()
			if conv.get_child(num).name == "[LEAVE]": option.hide()
			if conv.get_child(num).name == "[COSMETICS]": option.hide()
			if conv.get_child(num).name == "[OUTFITS]": option.hide()
			if conv.get_child(num).name == "[CUTSCENE]": option.hide()
			if conv.get_child(num).name == "[QUIT]": option.hide()
			if conv.get_child(num).name == "[GOTO]": option.hide()
			if conv.get_child(num).name == "[SHOOT]": option.hide()
			if conv.get_child(num).name == "[PAINT]":
				if $"../../../".haspaint:
					conv.get_child(num).name = "yes"
				else: option.hide()
			
			option.text = tr(conv.get_child(num).name)
			option.add_theme_font_size_override("font_size", 76)
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
		if option.name == "[LEAVE]" || option.name == "[QUIT]" || option.name == "[SHOOT]":
			if option.editor_description == "[NOPROGRESS]":
				if characterobject != null:
					characterobject.removetime()
					print("no progress")
				print(characterobject)
		if num == -1:
			conv = option
			decode()
		elif option.name == "[LEAVE]":
			end()
		elif option.name == "[GOTO]":
			print(option.editor_description)
			option = $"../../../conversations".get_node(option.editor_description)
			print(option)
			conv = option
			decode()
		elif option.name == "[SHOOT]":
			$"../../../player".hurt(100, "ragdoll")
			$"../../../sfx2".stream = load("res://audio/shoot.wav")
			$"../../../sfx2".play()
			end()
		elif option.name == "[COSMETICS]":
			if !$"../cosmetics".visible:
				if !$"../cosmetics/cosmeticbg".is_playing():
					$"../cosmetics/cosmeticbg".play("start")
					$"../cosmetics".show()
					$"../cosmetics".start()
					$"../cosmetics".isin = true
		elif option.name == "[OUTFITS]":
			if !$"../outfits".visible:
				if !$"../outfits/cosmeticbg".is_playing():
					$"../outfits/cosmeticbg".play("start")
					$"../outfits".show()
					$"../outfits".start()
					$"../outfits".alpha = 0
					$"../outfits".isin = true
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
	
