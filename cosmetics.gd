extends Control
const objects = ["bowlingball", "car", "moyai", "glasses",
"excord", "biggerboy", "eye", "socialcredit",
"skull", "fatman", "lightbulb", "menger",
"stickbug", "mememan", "maxwell", "dummi",
"distressed", "mrheeh", "elevator", "catsoldier", "wizardhat", "gunman"]

const titledesc = [["Bowling Ball", "Bowl a turkey", 0],
["Racecar", "Go 90 mph in a school zone", 0],
["Moyai", "You're gonna use all the f***n' hot water", 1000],
["Glasses", "erm, actually", 0],
["Extension Cord", "it works trust", 100],
["Bigger Boy", "You're not to touch me", 1000],
["Eye", "Google, show me this guy's walls please", 500],
["Social Credit", "-1,000,000 social credit report to Xi Jinping immediately.", 2000],
["Skull", "fr? 💀", 3000],
["Fat Man", "My main goal is to blow up", 1945],
["Lightbulb", "What's the big idea?", 100],
["Menger", "holes", 500],
["Stikbug", "Remember this meme? No?", 500],
["Meme Man", "invests in stonks", 1000],
["Maxwell", "The dingus", 1000],
["Dummi", "A handsome fella", 500],
["Distressed Red Ball", "If the earth is round, how come the ball aint goin nowhere?", 1000],
["Mr Heeh", "Some guy, probobly related to Ted", 2000],
["Elevator", "Beat The Elevator on Hard", -1],
["Cat Soldier", "Beat The Cat Batallion on Hard", -1],
["Pimpledump's Hat", "Beat Pimpledump Kinkledorf Dingledale on Hard", -1],
["Artillertunk's Head", "Beat Artillertunk on Hard", -1]]

#"companion", "breadbug", "durrburger", "flashlighttiddy"]
var choice = 0
@onready var headpivot = $cospreview/cospeview/headpivot
@onready var color = Vector3($"../../..".bodycolor.h, $"../../..".bodycolor.s, $"../../..".bodycolor.v)

var alpha = 0
var isin = true

var unlocked = true

var bitstext = 0

var deathsound = "none"
var winsound = "none"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

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

		$text/value.modulate = Color.from_hsv(color.x, color.y, 1)

		$text/saturation.modulate = Color.from_hsv(color.x, 1, color.z)
		$text/saturationcolor.modulate = Color.from_hsv(0, 0, color.z)

		$text/hue.modulate = Color.from_hsv(0, 0, 1)
			
		$"../../..".bodycolor = Color.from_hsv(color.x, color.y, color.z)
		$cospreview/cospeview/body.get_surface_override_material(0).albedo_color = $"../../..".bodycolor
		
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
		$talklabel.visible_ratio += delta*(1/$talktimer.wait_time)*2
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
	if choice < 0: choice = objects.size()-1
	if choice >= objects.size(): choice = 0
	for child in headpivot.get_children():
		child.queue_free()
	var object = load("res://objects/"+objects[choice]+".tscn").instantiate()
	headpivot.add_child(object)
	
	$text/name.text = titledesc[choice][0]
	$text/desc.text = titledesc[choice][1]
	
	unlocked = false
	for i in $"../../..".unlockedheads:
		if objects[choice] == i:
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
		
	if object.has_meta("deathsound"):
		$deathsound.show()
		deathsound = object.get_meta("deathsound")
	else:
		$deathsound.hide()
		deathsound = "none"
		
	if object.has_meta("winsound"):
		$winsound.show()
		winsound = object.get_meta("winsound")
	else:
		$winsound.hide()
		winsound = "none"

func _on_left_pressed():
	choice -= 1
	loadhead()
func _on_right_pressed():
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
	$randomspeak.wait_time = randf_range(20, 40)
	$randomspeak.start()
	headpivot = $cospreview/cospeview/headpivot
	color = Vector3($"../../..".bodycolor.h, $"../../..".bodycolor.s, $"../../..".bodycolor.v)
	for i in objects.size():
		print($"../../..".head)
		print("res://objects/"+objects[i]+".tscn")
		if $"../../..".head == "res://objects/"+objects[i]+".tscn":
			choice = i
	loadhead()
	$text/hue.value = color.x
	$text/saturation.value = color.y
	$text/value.value = color.z

func _on_save_pressed():
	if visible:
		if titledesc[choice][2] == 0 || unlocked:
			if !$cosmeticbg.is_playing():
				$"../../..".bodycolor = Color.from_hsv(color.x, color.y, color.z)
				$"../../..".head = "res://objects/"+objects[choice]+".tscn"
				$"../../../player".updatelook()
				$cosmeticbg.play("end")
				isin = false
		else:
			if titledesc[choice][2] == -1:
				var rand = randi_range(1, 4)
				if rand == 1: tedtalk("You go play games first!!")
				if rand == 2: tedtalk("Do hard games!")
				if rand == 3: tedtalk("No buy, play game!")
				if rand == 4: tedtalk("Specialty! Kill boss!")
			else:
				var rand = randi_range(1, 8)
				if rand == 1: tedtalk("It costs bits!")
				if rand == 2: tedtalk("You cant!")
				if rand == 3: tedtalk("It freen't!")
				if rand == 4: tedtalk("Cant buy without bits for buying!!")
				if rand == 5: tedtalk("Wrong!")
				if rand == 6: tedtalk("Ted need bits!")
				if rand == 7: tedtalk("You give Ted bits, Ted give you heads.")
				if rand == 8: tedtalk("Come back when richer!")

func _on_cosmeticbg_animation_finished():
	if visible:
		if $cosmeticbg.animation == "end":
			hide()
			$"../talk".option_press(-1)
			$"../../..".save_game()
			if $"../../../map/tedstand" != null:
				$"../../../map/tedstand".clearheads()

func _on_buy_pressed():
	if $"../../..".bits >= titledesc[choice][2]:
		unlocked = true
		$"../../..".unlockedheads.append(objects[choice])
		$"../../..".bits -= titledesc[choice][2]
		$"../../../sfx2".stream = load("res://audio/spendbits.mp3")
		$"../../../sfx2".play()
		loadhead()
		if titledesc[choice][2] < 1000:
			var rand = randi_range(1, 6)
			if rand == 1: tedtalk("Choice is good!")
			if rand == 2: tedtalk("Cool Head!")
			if rand == 3: tedtalk("Thank you shopping here!")
			if rand == 4: tedtalk("Buying!")
			if rand == 5: tedtalk("Thank!       ............ HEY WHY YOU STEALING MY HEADS!?")
			if rand == 6: tedtalk("Yay Bits!!")
		else:
			var rand = randi_range(1, 6)
			if rand == 1: tedtalk("Ooooh, spender BIG!")
			if rand == 2: tedtalk("That Antique!")
			if rand == 3: tedtalk("Mr MoneyMan Bags Man!")
			if rand == 4: tedtalk("Enjoy luxury head!")
			if rand == 5: tedtalk("Aw I wanted that one")
			if rand == 6: tedtalk("Im rich!!!")
		
func tedtalk(text):
	if $talktimer.is_stopped():
		$talktimer.wait_time = text.length()*0.1
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
	if $talklabel.visible_ratio < 1:
		$talksound.stream = load("res://audio/characters/tednormal_"+str(randi_range(0, 2))+".mp3")
		$talksound.play()

func _on_randomspeak_timeout():
	if visible:
		var rand = randi_range(1, 6)
		if rand == 1: tedtalk("You like my heads!")
		if rand == 2: tedtalk("That one is a head!")
		if rand == 3: tedtalk("So uhhh... how day?")
		if rand == 4: tedtalk("You "+str($"../../..".bits)+" bits by the way")
		if rand == 5: tedtalk("You is having bits of "+str($"../../..".bits))
		if rand == 6: tedtalk("You like the my stand? Ted made with tape and myself!")


func _on_deathsound_pressed():
	if deathsound != "none":
		$sounds.stream = load("res://audio/deathsounds/"+deathsound+".mp3")
		$sounds.play()
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), true)

func _on_winsound_pressed():
	if winsound != "none":
		$sounds.stream = load("res://audio/winsounds/"+winsound+".mp3")
		$sounds.play()
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), true)

func _on_sounds_finished():
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), false)
