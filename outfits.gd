extends Control
const outfits = ["defaultplayer", "hoodieplayer", "tuxedo", "bakini", "kingrobe", "jersey", "oiledup"]

const titledesc = [["Default", "Your birthday suit", 0],
["Guillermo's hoodie", "\"He's supposed to be Spanish?\"", 750],
["Tuxedo", "Look good for the huzz", 750],
["Bakini", "Boukisha's Bakini", 500],
["King's Robe", "Only for the richest", 2000],
["Jersey", "Ba Ba Ba, lin, lin", 500],
["Oiled Up", "1000 bottles of oil", 500],]

var choice = 0
@onready var headpivot = $cospreview/cospeview/headpivot
@onready var color = Vector3($"../../..".bodycolor.h, $"../../..".bodycolor.s, $"../../..".bodycolor.v)

var colornum = 0
var extracolors = 0

var alpha = 0
var isin = true

var unlocked = true

var bitstext = 0

var textboxsize = 600
var textfontsize = 64

func _process(delta):
	if isin:
		if alpha < 1:
			alpha += delta*4
	else:
		if alpha > 0:
			alpha -= delta*4
	
	$text.modulate = Color(1, 1, 1, alpha)
	
	if visible:
		if $text/Sprite2D/clickdetect.button_pressed:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

		$text/value["theme_override_styles/slider"].modulate_color = Color.from_hsv(color.x, color.y, 1)
		$text/saturation["theme_override_styles/slider"].modulate_color = Color.from_hsv(color.x, 1, color.z)
		$text/saturationcolor.modulate = Color.from_hsv(0, 0, color.z)
		$text/hue.modulate = Color.from_hsv(0, 0, 1)
		
		if colornum == 0:
			$"../../..".bodycolor = Color.from_hsv(color.x, color.y, color.z)
		else:
			var curcolor = Color.from_hsv(color.x, color.y, color.z)
			$"../../..".outfitcolors["res://outfits/"+outfits[choice]+".tscn"][str(colornum)] = {"r" : curcolor.r, "g" : curcolor.g, "b" : curcolor.b}
		
		if colornum == 0:
			$text/colornum.text = "Skin"
		else:
			$text/colornum.text = str(colornum)
			
		$text/colorleft.visible = !(colornum == 0)
		$text/colorright.visible = !(colornum == extracolors)
			
		#print(colornum)
		var previewcolor = Color.from_hsv(color.x, color.y, color.z)
		if $cospreview/cospeview/body != null:
			if colornum == 0:
				$cospreview/cospeview/body.get_surface_override_material(0).albedo_color = previewcolor
			else:
				$cospreview/cospeview/body.get_surface_override_material(colornum).albedo_color = previewcolor
		
		if titledesc[choice][2] > 0 && !unlocked && $"../../..".bits >= titledesc[choice][2]:
			$text/buy.show()
			if $text/buy.is_hovered():
				$text/buy.modulate = Color(1, 1, 1, 1)
				$text/bits.hide()
			else:
				$text/buy.modulate = Color(1, 1, 1, 0)
				$text/bits.show()
		else: $text/buy.hide()
		
		if $text/Sprite2D/clickdetect.button_pressed:
			$text/bars.modulate = Color(1, 1, 1, 0.2)
		else: $text/bars.modulate = Color(1, 1, 1, 1)

		if $"../../..".bits < bitstext:
			bitstext -= delta*500
		if $"../../..".bits > bitstext:
			bitstext = $"../../..".bits
		$text/bits2.text = str(int(round(bitstext)))
	
	if !$talktimer.is_stopped():
		$talklabel.visible_ratio += delta*(1/$talktimer.wait_time)*4
	else:
		$talklabel.visible_ratio = 0
func _input(event):
	if visible:
		if event is InputEventMouseMotion:
			if $text/Sprite2D/clickdetect.button_pressed:
				$cospreview/cospeview/tppivot.rotate_y(-event.relative.x * .005)
				$cospreview/cospeview/tppivot/tppivot2.rotate_x(event.relative.y * .005)
				$cospreview/cospeview/tppivot/tppivot2.rotation.x = clamp($cospreview/cospeview/tppivot/tppivot2.rotation.x, -PI/2, PI/2)
	
func loadhead():
	if choice < 0: choice = outfits.size()-1
	if choice >= outfits.size(): choice = 0

	var loadoutfit = load("res://outfits/"+outfits[choice]+".tscn").instantiate()
	
	for child in $cospreview/cospeview/attachments.get_children():
		child.queue_free()
		
	if loadoutfit.has_node("Armature/Skeleton3D/head"):
		var headattachments = loadoutfit.get_node("Armature/Skeleton3D/head")
		for child in headattachments.get_children():
			var gpos = headattachments.position-$cospreview/cospeview/attachments.position
			var grot = headattachments.rotation
			var gscl = headattachments.scale
			#var gscl = global_scale()
			child.reparent($cospreview/cospeview/attachments)
			child.position = gpos
			child.rotation = grot
			child.scale = gscl
	
	var mainbody = loadoutfit.get_node("Armature/Skeleton3D/main")
	$cospreview/cospeview/body.name = "deletebody"
	$cospreview/cospeview/deletebody.queue_free()
	mainbody.reparent($cospreview/cospeview)
	mainbody.position = Vector3.ZERO
	mainbody.rotation = Vector3.ZERO
	mainbody.name = "body"
	if $"../../..".outfitcolors.has("res://outfits/"+outfits[choice]+".tscn"):
		if mainbody.has_meta("extracolors"):
			for i in range(1, mainbody.get_meta("extracolors")+1):
				var curcolorrgb = $"../../..".outfitcolors["res://outfits/"+outfits[choice]+".tscn"][str(i)]
				var curcolor = Color(curcolorrgb["r"], curcolorrgb["g"], curcolorrgb["b"])
				mainbody.get_surface_override_material(i).albedo_color = curcolor
				
	$cospreview/cospeview/body.get_surface_override_material(0).albedo_color = $"../../..".bodycolor
	
	if $cospreview/cospeview/body.has_meta("extracolors"):
		extracolors = $cospreview/cospeview/body.get_meta("extracolors")
	else:
		extracolors = 0
		
	if $cospreview/cospeview/body.has_meta("textedit"):
		$textedit.show()
		$textedit.text = ""
		var text = $cospreview/cospeview/body/text/text
		textboxsize = text.size.x
		textfontsize = text.get_theme_font_size("font_size")
	else:
		$textedit.hide()
		
	var was = colornum
	if colornum > extracolors:
		colornum = extracolors
	if extracolors >= 1 && colornum == 0:
		colornum = 1
	setoutfitcolor(was)
	
	$text/name.text = titledesc[choice][0]
	$text/desc.text = titledesc[choice][1]
	
	unlocked = false
	for i in $"../../..".unlockedoutfits:
		if outfits[choice] == i:
			unlocked = true
			break
	
	if titledesc[choice][2] != 0 && !unlocked:
		if $text/bars.animation != "start":
			$text/bars.play("start")
			$"../../../sfx".stream = load("res://audio/jailclose.mp3")
			$"../../../sfx".play()
		if titledesc[choice][2] != -1:
			$text/bits.text = str(titledesc[choice][2])
			
			$text/bits/bitsoffset/bitssprite.position.x = $text/bits.get_total_character_count()*20
			$text/bits.show()
		else:
			$text/bits.hide()
	else:
		if $text/bars.animation != "end":
			$text/bars.play("end")
			$"../../../sfx".stream = load("res://audio/jailopen.mp3")
			$"../../../sfx".play()
		$text/bits.hide()

func _on_left_pressed():
	setoutfitcolor(colornum, true)
	choice -= 1
	loadhead()
func _on_right_pressed():
	setoutfitcolor(colornum, true)
	choice += 1
	loadhead()

func _on_value_value_changed(value):
	color.z = value
	$"../pause/options/mastertick".play()

func _on_saturation_value_changed(value):
	color.y = value
	$"../pause/options/mastertick".play()

func _on_hue_value_changed(value):
	color.x = value
	$"../pause/options/mastertick".play()
	
func start():
	for fit in outfits:
		print(fit)
		var loadoutfit = load("res://outfits/"+fit+".tscn").instantiate()
		var mainbody = loadoutfit.get_node("Armature/Skeleton3D/main")
		if !$"../../..".outfitcolors.has("res://outfits/"+fit+".tscn"):
			if mainbody.has_meta("extracolors"):
				for i in range(1, mainbody.get_meta("extracolors")+1):
					print("set "+fit+" color "+str(i))
					var outfitcolor = mainbody.get_surface_override_material(i).albedo_color
					var colordict = {"r" : outfitcolor.r, "g" : outfitcolor.g, "b" : outfitcolor.b}
					if !$"../../..".outfitcolors.has("res://outfits/"+fit+".tscn"):
						$"../../..".outfitcolors["res://outfits/"+fit+".tscn"] = {}
					$"../../..".outfitcolors["res://outfits/"+fit+".tscn"][str(i)] = colordict
	
	print("outfitcolors start:")
	print($"../../..".outfitcolors)
	
	$randomspeak.wait_time = randf_range(20, 40)
	$randomspeak.start()
	headpivot = $cospreview/cospeview/headpivot
	color = Vector3($"../../..".bodycolor.h, $"../../..".bodycolor.s, $"../../..".bodycolor.v)
	for i in outfits.size():
		if $"../../..".outfit == "res://outfits/"+outfits[i]+".tscn":
			choice = i
			
	for child in headpivot.get_children():
		child.queue_free()
	
	var object = load($"../../..".head).instantiate()
	headpivot.add_child(object)
	
	loadhead()
	$text/hue.value = color.x
	$text/saturation.value = color.y
	$text/value.value = color.z

func _on_save_pressed():
	if visible:
		if titledesc[choice][2] == 0 || unlocked:
			if !$cosmeticbg.is_playing():
				$"../../..".outfit = "res://outfits/"+outfits[choice]+".tscn"
				$"../../..".outfittext = $textedit.text
				print("outfitcolors save:")
				print($"../../..".outfitcolors)
				$"../../../player".updatelook()
				$cosmeticbg.play("end")
				isin = false
		else:
			if titledesc[choice][2] == -1:
				var rand = randi_range(1, 4)
				if rand == 1: tedtalk("naw baby that aint for sale")
				if rand == 2: tedtalk("you gotta work for this one")
				if rand == 3: tedtalk("aint for sale, you gotta earn it")
				if rand == 4: tedtalk("you got the skills? you need em for this!")
			else:
				var rand = randi_range(1, 8)
				if rand == 1: tedtalk("you is poor as hell!")
				if rand == 2: tedtalk("you aint got the funds!")
				if rand == 3: tedtalk("naw baby, no bits no fits")
				if rand == 4: tedtalk("you is broke as a joke!")
				if rand == 5: tedtalk("no mo money on ya, get a job!")
				if rand == 6: tedtalk("come back when u got the guap!")
				if rand == 7: tedtalk("you broke, and no there aint \"another way you can pay me\"")
				if rand == 8: tedtalk("you want that gud sh*t? get cho money up!")

func _on_cosmeticbg_animation_finished():
	if visible:
		if $cosmeticbg.animation == "end":
			hide()
			$"../talk".option_press(-1)
			$"../../..".save_game()
			if $"../../../map/lipsstuff" != null:
				$"../../../map/lipsstuff".clearoutfits()

func _on_buy_pressed():
	if $"../../..".bits >= titledesc[choice][2]:
		unlocked = true
		$"../../..".unlockedoutfits.append(outfits[choice])
		$"../../..".bits -= titledesc[choice][2]
		$"../../../sfx2".stream = load("res://audio/spendbits.mp3")
		$"../../../sfx2".play()
		loadhead()
		if titledesc[choice][2] < 1000:
			var rand = randi_range(1, 6)
			if rand == 1: tedtalk("thats gon look gud on u!")
			if rand == 2: tedtalk("you lookin spiffy!")
			if rand == 3: tedtalk("gud choice baby!")
			if rand == 4: tedtalk("ay you a snack!")
			if rand == 5: tedtalk("makes ya look skinnier, HA!")
			if rand == 6: tedtalk("thanks for the funds baby!")
		else:
			var rand = randi_range(1, 6)
			if rand == 1: tedtalk("OOH you a big spenda now!")
			if rand == 2: tedtalk("lookin drippy as hell baby!")
			if rand == 3: tedtalk("AYYY im stacked! haHA!")
			if rand == 4: tedtalk("gettin luxurious up in this b*tch!")
			if rand == 5: tedtalk("That was mah grannies!")
			if rand == 6: tedtalk("Yeeaaaah fill up mah bitbag!")
		
func tedtalk(text):
	if $talktimer.is_stopped():
		$talktimer.wait_time = text.length()*0.1+1
		$talktimer.start()
		$talkbox.show()
		$talklabel.show()
		$talktimer2.start()
		_on_talktimer_2_timeout()
		$talklabel.text = text
		$randomspeak.wait_time = randf_range(20, 40)
		$randomspeak.start()

func _on_talktimer_timeout():
	$talkbox.hide()
	$talklabel.hide()
	$talktimer2.stop()

func _on_talktimer_2_timeout():
	if visible:
		if $talklabel.visible_ratio < 1:
			$talksound.stream = load("res://audio/characters/lipsnormal_"+str(randi_range(0, 2))+".mp3")
			$talksound.play()

func _on_randomspeak_timeout():
	if visible:
		var rand = randi_range(1, 6)
		if rand == 1: tedtalk("you like whatchu seen?")
		if rand == 2: tedtalk("dat one got some stank!")
		if rand == 3: tedtalk("how you doin baby?")
		if rand == 4: tedtalk("you got a gud "+str(int($"../../..".bits))+" bits to spend baby")
		if rand == 5: tedtalk("dont you walk away with all "+str(int($"../../..".bits))+" of those bits!")
		if rand == 6: tedtalk("you need some style!")

func _on_sounds_finished():
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), false)

func _on_colorleft_pressed() -> void:
	if colornum > 0:
		colornum -= 1
		setoutfitcolor(colornum+1)

func _on_colorright_pressed() -> void:
	if colornum < extracolors:
		colornum += 1
		setoutfitcolor(colornum-1)
		
func setoutfitcolor(was, justsave = false):
	if !justsave:
		if colornum != 0:
			var curcolorrgb = $"../../..".outfitcolors["res://outfits/"+outfits[choice]+".tscn"][str(colornum)]
			var curcolor = Color(curcolorrgb["r"], curcolorrgb["g"], curcolorrgb["b"])
			color = Vector3(curcolor.h, curcolor.s, curcolor.v)
		else:
			color = Vector3($"../../..".bodycolor.h, $"../../..".bodycolor.s, $"../../..".bodycolor.v)
		$text/value.value = color.z
		$text/saturation.value = color.y
		$text/hue.value = color.x


func _on_textedit_text_changed() -> void:
	if $cospreview/cospeview/body.has_meta("textedit"):
		var text = $cospreview/cospeview/body/text/text
		text.text = $textedit.text
		text.add_theme_font_size_override("font_size", textfontsize)
		if text.size.x > textboxsize:
			for i in range(100):
				var fontsize = text.get_theme_font_size("font_size")
				if (text.size.x > textboxsize):
					text.add_theme_font_size_override("font_size", fontsize-1)
					text.size.x = 539
				else:
					text.add_theme_font_size_override("font_size", fontsize-2)
					break
