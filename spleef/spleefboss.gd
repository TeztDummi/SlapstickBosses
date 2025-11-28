extends CharacterBody3D

@onready var main = get_node("/root").get_node("main")
@onready var player = main.get_node("player")
@onready var map = main.get_node("map")

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var fall = 0
var diff = 0
var choice = ""
var laseron = false
var cold = true
var temp = 0
var move = false

func settemp(iscold):
	cold = iscold
	print("settemp: "+str(cold))

func _ready():
	freezeblocks()

func _process(delta: float) -> void:
	#var floordetects = [$floordetect1, $floordetect2, $floordetect3, $floordetect4]
	fall = 0
	#for ray in floordetects:
		#if !ray.is_colliding():
			#fall += 1
		#else:
			#position.y = ray.get_collision_point().y
			#break
	if !is_on_floor():
		fall = 4
	if fall == 4:
		velocity.y -= gravity*delta 
		print(velocity.y)
	move_and_slide()
	freezeblocks()
	#print(position)
	
	if $main/cannon.is_playing() || $main/laser.is_playing() || $main/antenna.is_playing():
		$main/body/hatchL.scale.z -= delta*6
		$main/body/hatchR.scale.z -= delta*6
	else:
		$main/body/hatchL.scale.z += delta*2
		$main/body/hatchR.scale.z += delta*2
	$main/body/hatchL.scale.z = clampf($main/body/hatchL.scale.z, 0, 1)
	$main/body/hatchR.scale.z = clampf($main/body/hatchR.scale.z, 0, 1)
	
	if laseron:
		if $main/body/lasergun/axel/raycast.is_colliding():
			$laserhit.show()
			$laserhit.global_position = $main/body/lasergun/axel/raycast.get_collision_point()
			var col = $main/body/lasergun/axel/raycast.get_collider()
			if col != null:
				if col.is_in_group("spleefblock"):
					col.get_parent().breaking = 2
					
		else:
			$laserhit.hide()
	else:
		$laserhit.hide()
		
	var glowmat = $main/body.get_surface_override_material(1)
	if cold:
		temp -= delta*4
	else:
		temp += delta*4
		
	temp = clampf(temp, 0, 1)
	
	glowmat.emission_energy_multiplier = lerpf(16, 2.5, temp)
	glowmat.emission = Color.from_hsv(0.625, lerpf(0.95, 0, temp), 1)
	
func _on_movecheck_timeout() -> void:
	$movecheck.wait_time = 1.2
	if fall != 4 && move:
		var directions = {
			"center" : {
				"obj" : [$"check/4", $"check/5", $"check/8", $"check/9"],
				"place" : 0.0,
				"dir" : "center"
			},
			"left" : {
				"obj" : [$"check/3", $"check/4", $"check/7", $"check/8"],
				"place" : 0.1,
				"dir" : "left"
			},
			"right" : {
				"obj" : [$"check/5", $"check/6", $"check/9", $"check/10"],
				"place" : 0.1,
				"dir" : "right"
			},
			"down" : {
				"obj" : [$"check/1", $"check/2", $"check/4", $"check/5"],
				"place" : 0.2,
				"dir" : "down"
			},
			"up" : {
				"obj" : [$"check/8", $"check/9", $"check/11", $"check/12"],
				"place" : 0.2,
				"dir" : "up"
			}
		}
		
		#0 is perfect 2x2 in center
		
		for iterdir in directions:
			print(iterdir)
			for ray in directions[iterdir]["obj"]:
				if !ray.is_colliding():
					directions[iterdir]["place"] += 1
			if directions[iterdir]["place"] == 0:
				break;
				
		var movedir = directions["center"]
		for iterdir in directions:
			if directions[iterdir]["place"] == 0:
				break
			elif directions[iterdir]["place"] < movedir["place"]:
				movedir = directions[iterdir]
			elif directions[iterdir]["place"] == movedir["place"]:
				if randf() > 0.5:
					movedir = directions[iterdir]
					
		for iterdir in directions:
			print(directions[iterdir]["place"])
		print(movedir)
					
		if movedir["dir"] == "left":
			$main/anim.playfps("moveleft")
		if movedir["dir"] == "right":
			$main/anim.playfps("moveright")
		if movedir["dir"] == "up":
			$main/anim.playfps("moveup")
		if movedir["dir"] == "down":
			$main/anim.playfps("movedown")
			

func _on_anim_animation_finished(anim_name: StringName) -> void:
	if fall != 4:
		if anim_name == "moveleft":
			position.x += 2
		if anim_name == "moveright":
			position.x -= 2
		if anim_name == "moveup":
			position.z -= 2
		if anim_name == "movedown":
			position.z += 2
	$main/anim.playfps("idle")
	
func freezeblocks():
	var doparticles = false
	for ray in [$"check/4", $"check/5", $"check/8", $"check/9"]:
		if ray.get_collider() != null:
			if ray.get_collider().is_in_group("spleefblock"):
				if !ray.get_collider().get_parent().ice:
					doparticles = true
					ray.get_collider().get_parent().ice = true
				
	if doparticles:
		$fog.restart()
		settemp(true)

func _on_attack_timeout() -> void:
	if fall != 4:
		var rand = {
			"cannon": 0.5,
			"laser": 1,
			"antenna": 0.25,
			"freeze": 1
		}
		
		if rand.has(choice): rand[choice] *= 0
		if $main/cannon.playing: rand["cannon"] *= 0
		if $main/laser.playing: rand["laser"] *= 0
		if $main/antenna.playing: rand["antenna"] *= 0
		if !move: rand["freeze"] *= 0
			
		var weightsum = 0
		var weights = {}
		for i in rand:
			weightsum += rand[i]
			weights[i] = weightsum
		var item = randf_range(0, weightsum)
		for i in weights:
			if item < weights[i]:
				choice = i
				break
				
		if choice == "cannon":
			$main/cannon.playfps("shoot", 24)
			settemp(false)
			#$audio.stream = load("res://audio/sodabox/shootfromtop.mp3")
			#$audio.play()
		if choice == "laser":
			if move:
				$main/laser.playfps("shoot", 24)
			else:
				$main/laser.playfps("shoothigh", 24)
			var lpos = $main/body/lasergun.global_position
			$main/body/lasergun.rotation.y = -PI/2+atan2(lpos.x-player.position.x, lpos.z-player.position.z)
			settemp(false)
		if choice == "antenna":
			$main/antenna.playfps("shoot", 24)
		if choice == "freeze":
			freezeattack()
		
func freezeattack():
	settemp(true)
	$fog2.emitting = true
	$movecheck.wait_time = 3
	$movecheck.start()
	for area in $revive.get_overlapping_areas():
		if area.is_in_group("spleefblock"):
			area.get_parent().revive()

func laser(val):
	$main/body/lasergun/axel/laser.visible = val
	for audio in $main/body/lasergun/axel/laser/audio.get_children():
		audio.playing = val
	laseron = val
	
func shootcannon():
	var bomb = load("res://spleef/spleefbomb.tscn").instantiate()
	bomb.position = $main/body/cannon/axel1/axel2.global_position
	bomb.position.y += 0.4
	$"../".add_child(bomb)

func _on_headrot_timeout() -> void:
	var hpos = $main/body/neck/neckmid/neckhigh/head.global_position
	$main/body/neck/neckmid/neckhigh/head.rotation.y = atan2(hpos.x-player.position.x, hpos.z-player.position.z)


func _on_antenna_animation_finished(anim_name: StringName) -> void:
	for i in range(2):
		var choices = []
		for child in get_parent().get_children():
			if child.is_in_group("spleefblockparent"):
				if child.health > 0:
					choices.append(child.position)
		
		if choices.size() > 0:
			var enemy = load("res://spleef/spleefminion.tscn").instantiate()
			var ranpos = choices.pick_random()
			enemy.position.x = ranpos.x#floor(randf_range(-16, 16)/2)*2+1
			enemy.position.z = ranpos.z#floor(randf_range(-16, 16)/2)*2+1
			enemy.position.y += 20+i*5
			$"../".add_child(enemy)
