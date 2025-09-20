extends Node3D

@onready var main = get_node("/root").get_node("main")
@onready var player = main.get_node("player")
@onready var map = main.get_node("map")

var diff = 0
var chal = "none"

var maxhealth = 6000.0
var health = maxhealth

var started = false
var dead = false

var eyestoopen = []
var openeyes = 0
var maxeyesopen = 0

var previouswall = 0
var previoustentacle = 0

var didfloorveindamage = false

var startFT = 0
var curFT = 0

var height = 0

var gun

var ended = false

var tentaclesparried = 0

func _ready() -> void:
	if diff == 0:
		maxhealth = 4000.0
		maxeyesopen = 12
	if diff == 1:
		maxhealth = 6000.0
		maxeyesopen = 6
	if diff == 2:
		maxhealth = 6000.0
		maxeyesopen = 8
	if chal == "horrorgun":
		maxhealth = 8000.0
		maxeyesopen = 16
		player.JUMP_VELOCITY = 22
		
	health = maxhealth
	
	player.falloff = false
	player.candash = true
	player.dashseconds = 2
	player.SPEED = 6
	
	if chal == "eyes":
		player.dashseconds = 1
		maxhealth = 100000.0
		health = maxhealth
		#for i in range(1, 4):
			#var vein = get_node("wallvein"+str(i))
			#vein.permanent()
	else:
		$extrawalls.queue_free()
	
	if chal == "horrorgun":
		gun = load("res://horrorgun.tscn").instantiate()
		$"../player/camera/gun".add_child(gun)
		$"../player".scroll = 1
	else:
		gun = load("res://katana.tscn").instantiate()
		$"../player/camera/gun".add_child(gun)
		$"../player".scroll = 1
	
	eyestoopen = $eyes.get_children()
	eyestoopen.shuffle()
	
	$floorveins/anim.play("RESET")
	
	$"../music".stop()
	
	$Armature.show()
	if chal == "horrorgun":
		$Armature/Skeleton3D/hand/gun.show()
	else:
		$Armature/Skeleton3D/hand/katana.show()
	$cutscene.play("start")
	$cutscenecam.current = true
	
	var loadoutfit = load($"../".outfit).instantiate()
	for child in $Armature/Skeleton3D/headbone/attachments.get_children():
		child.queue_free()
	if loadoutfit.has_node("Armature/Skeleton3D/head"):
		var headattachments = loadoutfit.get_node("Armature/Skeleton3D/head")
		for child in headattachments.get_children():
			child.reparent($Armature/Skeleton3D/headbone/attachments)
			child.position = headattachments.position
			child.rotation = headattachments.rotation-$Armature/Skeleton3D/headbone.rotation
			child.scale = headattachments.scale
	var mainbody = loadoutfit.get_node("Armature/Skeleton3D/main")
	$Armature/Skeleton3D/Cube.name = "deletebody"
	$Armature/Skeleton3D/deletebody.queue_free()
	mainbody.reparent($Armature/Skeleton3D)
	mainbody.position = Vector3.ZERO
	mainbody.rotation = Vector3.ZERO
	mainbody.name = "Cube"
	if $"../".outfitcolors.has($"../".outfit):
		if mainbody.has_meta("extracolors"):
			for i in range(1, mainbody.get_meta("extracolors")+1):
				var curcolorrgb = $"../".outfitcolors[$"../".outfit][str(i)]
				var curcolor = Color(curcolorrgb["r"], curcolorrgb["g"], curcolorrgb["b"])
				mainbody.get_surface_override_material(i).albedo_color = curcolor
	
	$Armature/Skeleton3D/Cube.get_surface_override_material(0).albedo_color = $"../".bodycolor
					
	var loadhead = load($"../".head).instantiate()
	$Armature/Skeleton3D/headbone/offset.add_child(loadhead)
	
func hurt(dmg):
	if started:
		if !dead:
			health -= dmg
		
		if health < 0 && !dead:
			dead = true
			$"../".transitionmusic("res://audio/music/horrorthemespicy.mp3", 0.25, false, 42.666, -2.666)
			health = 0
			$topgunk.queue_free()
			$tentacletimer.wait_time = 2
			$tentacletimer.start()
			maxeyesopen = 0
			for eye in $eyes.get_children():
				eye.bleed()
				
			if tentaclesparried == 0 && diff == 2 && chal == "none":
				$"../".setAchievement("stophittingyourself")
				if !$"../../".beatchallenges.has("stophittingyourself"):
					$"../../".beatchallenges["stophittingyourself"] = true
					var popup = load("res://popup.tscn").instantiate()
					popup.bits = $"../../".getchalbits("stophittingyourself")
					$"../../".bits += $"../../".getchalbits("stophittingyourself")
					$"../../sfx".stream = load("res://audio/gainbits.mp3")
					$"../../sfx".play()
					$"../../canvas/hud".add_child(popup)
				
			
		print("monster damaged:" +str(dmg))
		
		var pitch = clampf((dmg)/80, 0.75, 1.5)
		var vol = -80+clampf((dmg)*3, 60, 90) 
		
		var tempaudio = load("res://tempaudio.tscn").instantiate()
		tempaudio.position = $soundpos.position
		add_child(tempaudio)
		tempaudio.stream = load("res://audio/horror/pain"+str(randi_range(0, 3))+".mp3")
		tempaudio.pitch_scale = pitch
		tempaudio.volume_db = vol
		tempaudio.play()
		
		$center/anim.play("RESET")
		$center/anim.play("hurt")
	
func _process(delta: float) -> void:
	#$DirectionalLight3D.rotation.y += (delta*PI*2)*0.1
	
	var healthval = health
	if chal == "eyes": healthval = openeyes
	$"../canvas/hud/bossbar".value = healthval
	$"../canvas/hud/bossbar"/healthlabel.text = str(int(round(healthval)))
	$"../canvas/hud/bossbar".tint_progress = Color.from_hsv(healthval*0.003*(100/maxhealth), 0.5, 1)
	
	if health <= maxhealth/2:
		if dead:
			height += delta*7
			$blood.emitting = true
			if $water.position.y < 125:
				$waterpour.volume_linear = lerpf($waterpour.volume_linear, 0.5, delta*10)
			else:
				$waterpour.volume_linear = lerpf($waterpour.volume_linear, 0.1, delta*1)
		else:
			height = 1.0-(health/maxhealth)
			height = height*height*height*height*height*height*height*height
			height *= 30
			if height-$water.position.y >= 0.1:
				$blood.emitting = true
				$waterpour.volume_linear = lerpf($waterpour.volume_linear, 1, delta*2)
			else:
				$blood.emitting = false
				$waterpour.volume_linear = lerpf($waterpour.volume_linear, 0, delta*1)
		$water.position.y = lerpf($water.position.y, height, delta*1)
		if $water.position.y > 125:
			$water.position.y = 125
			
	if started:
		if chal != "eyes":
			if openeyes < maxeyesopen:
				eyestoopen[0].open()
				eyestoopen.push_back(eyestoopen[0])
				eyestoopen.pop_front()
				
				openeyes += 1
			
	if dead && !ended:
		if $floortentacleisgoing.is_stopped():
			$floortentacletimer.stop()
			_on_floortentacletimer_timeout()
			
	if !dead && !ended && $"../music".stream.resource_path.get_file() == "horrortheme.mp3":
		var totalvel = sqrt(pow(player.velocity.x, 2)+pow(player.velocity.z, 2))
		var vol = -80+clampf((totalvel/player.SPEED)*15, 0, 85)
		$drums.volume_db = lerpf($drums.volume_db, vol, delta*1)
	else:
		$drums.volume_db = lerpf($drums.volume_db, -80, delta*5)
		
	if chal == "eyes":
		if openeyes <= 0 && started && !ended:
			ended = true
			$"../canvas/hud/timer".hide()
			$"../".spawnlobbyportal()
			$"../".transitionmusic("none", 6)
			win()
		
		
	if $"../".timer < 0 && $"../canvas/hud/timer".visible:
		player.hurt(100, "ragdoll")
		$"../canvas/hud/timer".hide()

func _on_wallveintimer_timeout() -> void:
	if !dead && diff != 0 && chal != "eyes" && !ended:
		var rand = randi_range(1, 4)
		while rand == previouswall: rand = randi_range(1, 4)
		var vein = get_node("wallvein"+str(randi_range(1, 4)))
		vein.start()
		if diff == 1:
			$wallveintimer.wait_time = randf_range(7, 15)
		if diff == 2:
			$wallveintimer.wait_time = randf_range(4, 5)

func _on_floorveintimer_timeout() -> void:
	if !dead && !ended:
		$floorveins/anim.play("default")
		didfloorveindamage = false
		
		var tempaudio = load("res://tempaudio.tscn").instantiate()
		player.add_child(tempaudio)
		tempaudio.stream = load("res://audio/floorveins.mp3")
		tempaudio.play()
		if diff <= 1:
			$floorveintimer.wait_time = randf_range(20, 40)
		if diff == 2:
			$floorveintimer.wait_time = randf_range(80, 100)

func _on_floorveinarea_body_entered(body: Node3D) -> void:
	if !didfloorveindamage:
		if body.is_in_group("playergroup"):
			body.hurt(20, "ragdoll")
			didfloorveindamage = true

func _on_tentacletimer_timeout() -> void:
	if !ended:
		var rand = randi_range(1, 4)
		while rand == previoustentacle: rand = randi_range(1, 4)
		var tentacle = get_node("tenticle"+str(randi_range(1, 4)))
		tentacle.activate()
		if !dead:
			if diff == 0:
				$tentacletimer.wait_time = randf_range(15, 20)
			if diff == 1:
				$tentacletimer.wait_time = randf_range(6, 10)
			if diff == 2:
				$tentacletimer.wait_time = randf_range(4, 6)
		else:
			if diff == 2:
				$tentacletimer.wait_time = 4
			elif diff == 1:
				$tentacletimer.wait_time = 5
			else:
				$tentacletimer.stop()
 
func _on_eyelasertimer_timeout() -> void:
	if !dead && !ended:
		for child in $eyes.get_children():
			child.laser()
		if diff <= 1:
			$eyelasertimer.wait_time = randf_range(30, 40)
		if diff == 2:
			$eyelasertimer.wait_time = randf_range(5, 8)
		print("eyelasers")


func _on_floortentacletimer_timeout() -> void:
	if !ended:
		startFT = randi_range(0, 7)
		curFT = wrap(startFT+1, 0, 8)
		$floortentacletimer.wait_time = randf_range(40, 60)
		$floortentacletimerdelay.start()
		$floortentacleisgoing.start()
		print("floortentacles")
		print("start: "+str(startFT))
	
func _on_floortentacletimerdelay_timeout() -> void:
	var floortentacle = $floortentacles.get_child(curFT)
	floortentacle.start()
	if curFT != startFT:
		curFT = wrap(curFT+1, 0, 8)
		$floortentacletimerdelay.start()
		$floortentacleisgoing.start()

func _on_startarea_body_entered(body: Node3D) -> void:
	if !started:
		if body.is_in_group("playergroup"):
			started = true
			var timers = [$wallveintimer, $floorveintimer, $tentacletimer, $eyelasertimer, $floortentacletimer]
			if diff == 2:
				$tentacletimer.wait_time = 5
			for timer in timers:
				timer.start()
			$"../canvas/hud/bossbar".show()
			$"../canvas/hud/bossbar".max_value = health
			gun.turnflashlighton()
			$"../music".stream = load("res://audio/music/horrortheme.mp3")
			$"../music".play()
			$drums.play()
			
			$topgunk/gunkcol.remove_from_group("flesh")
			$topgunk/horroreye.queue_free()
			
			if chal == "eyes":
				if !$"../canvas/hud/timer".visible:
					$"../".timer = 70
					$"../canvas/hud/timer".show()
				for eye in $eyes.get_children():
					eye.open()
					openeyes += 1
				$"../canvas/hud/bossbar".max_value = $eyes.get_child_count()
				var wait = 0.1
				for timer in timers:
					if timer.name != "floortentacletimer":
						timer.wait_time = wait
						wait += 5
						timer.start()
						
			hurt(0)


func _on_endarea_body_entered(body: Node3D) -> void:
	if !ended && dead:
		if body.is_in_group("playergroup"):
			ended = true
			for i in range(1, 4):
				get_node("tenticle"+str(i)).progress = 1
			$"../".spawnlobbyportal($portalpos.position)
			$"../".transitionmusic("none", 6)
			win()

func win():
	if chal == "none":
		var earnedbits = $"../".calcbits(diff, $"../".beathorror, 1)
		$"../".bits += earnedbits
		if diff == 2:
			$"../".setAchievement("carcinocide")
			if player.health >= 100: $"../".setAchievement("100")
		if earnedbits > 0:
			var popup = load("res://popup.tscn").instantiate()
			popup.bits = earnedbits
			$"../sfx".stream = load("res://audio/gainbits.mp3")
			if diff == 2 && !$"../".unlockedheads.has("bioplasm"):
				popup.cosmetic = true
				$"../".unlockedheads.append("bioplasm")
				$"../sfx".stream = load("res://audio/gaincosmetic.mp3")
			$"../sfx".play()
			$"../canvas/hud".add_child(popup)
		if diff > $"../".beathorror: $"../".beathorror = diff
	else:
		if !$"../".beatchallenges.has(chal):
			$"../".beatchallenges[chal] = true
			var popup = load("res://popup.tscn").instantiate()
			popup.bits = $"../".getchalbits(chal)
			$"../".bits += $"../".getchalbits(chal)
			$"../sfx".stream = load("res://audio/gainbits.mp3")
			$"../sfx".play()
			$"../canvas/hud".add_child(popup)
	$"../".save_game()

func _on_cutscene_animation_finished(anim_name: StringName) -> void:
	player.camera.current = true
