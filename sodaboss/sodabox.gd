extends CharacterBody3D

@onready var main = get_node("/root").get_node("main")
@onready var player = main.get_node("player")
@onready var map = main.get_node("map")

@onready var center = global_position
@onready var randpoint = center
@onready var arena = get_parent()

#holy shit
#@onready var wetoffs = $Armature/Skeleton3D/main.get_surface_override_material(0).next_pass.next_pass.albedo_texture.color_ramp.offsets
@onready var wetnoise = $Armature/Skeleton3D/main.get_surface_override_material(0).next_pass.next_pass.albedo_texture
var health = 300
var diff = 0
var rotdiff = 0
var choice = ""
var disttoplayer = 10
var started = false
var rollspeed = 1
var dead = false

func _ready() -> void:
	wetnoise.noise.seed = randi_range(0, 100)
	
	diff = $"../../".diff
	
	if diff == 0:
		health = 150
	elif diff == 1:
		health = 300
	elif diff == 2:
		health = 400
		
	if map.chal == "justbox":
		health = 3000
	 
	for i in range(6):
		var path = "res://sodaboss/sodacan.tscn"
		ResourceLoader.load_threaded_request(path)
		
	if $"../../".chal == "justbox":
		wetnoise.color_ramp.set_offset(1, 1)
		wetnoise.color_ramp.set_offset(0, 0.99)

func _process(delta: float) -> void:
	if started && !dead && !player.dead:
		$"../../lookat".look_at_from_position(position, player.position)
		#$lookatplayer.global_rotation = $"../../lookat".rotation
		
		#var diff = (wrap(rotation.y, -PI*2, PI*2)-wrap($"../../lookat".global_rotation.y, -PI*2, PI*2))
		rotdiff = (rotation.y-$"../../lookat".global_rotation.y)
		rotdiff = wrap(rotdiff, -PI, PI)
		
		disttoplayer = sqrt(pow(position.x-player.position.x, 2) + pow(position.z-player.position.z, 2))
		
		if disttoplayer <= 2 && !$anim.is_playing():
			$anim.play("slam")
			var tempaudio = load("res://tempaudio.tscn").instantiate()
			add_child(tempaudio)
			tempaudio.stream = load("res://audio/sodabox/movebig.mp3")
			tempaudio.play()
		
		if $rotatetimer.is_stopped() && !$anim.is_playing():
			
			if rotdiff > PI/4:
				#rotate_y(-PI/2)
				$anim.play("rotate")
				$audio.stream = load("res://audio/sodabox/move.mp3")
				$audio.play()
				$rotatetimer.start()
				
			if rotdiff < -PI/4:
				#rotate_y(PI/2)
				$anim.play("rotatecounter")
				$audio.stream = load("res://audio/sodabox/move.mp3")
				$audio.play()
				$rotatetimer.start()
		
		if $anim.current_animation == "roll":
			var facing = $facing.global_position-global_position
			if !$canroll.is_colliding():
				$anim.speed_scale = rollspeed
				$rollaudio.pitch_scale = rollspeed
				position += facing*delta*10*rollspeed
				rollspeed += delta*2
			else:
				$anim.play("getup")
				$audio.stream = load("res://audio/sodabox/getup.mp3")
				$audio.play()
		else:
			rollspeed = 1
			if diff == 2:
				rollspeed = 2
			$anim.speed_scale = 1
			$rollaudio.pitch_scale = 1
			
		if $anim.current_animation == "move" || $anim.current_animation == "movebig":
			var dir = atan2(position.x-randpoint.x, position.z-randpoint.z)
			var dist = sqrt(pow(position.x-randpoint.x, 2) + pow(position.z-randpoint.z, 2))
			if dist >= 0.5:
				position.x -= sin(dir)*delta*10
				position.z -= cos(dir)*delta*10
				rotation.y = lerp_angle(rotation.y, dir, delta*10)
		else:
			#rotation.y = lerp_angle(rotation.y, round(rotation.y*(PI/2))/(PI/2), delta*10)
			rotation.y = round(rotation.y/(PI/2))*(PI/2)
			
func shootatplayer():
	if (abs(rotdiff) >= PI/2):
		print("cancel")
		$anim.play("RESET")
	else:
		var startpos = $Armature/Skeleton3D/middlemouth/shootpos.global_position
		
		var pos = player.position
		pos.y += 1
		
		var dir = -Vector3(startpos.x-pos.x, startpos.y-pos.y, startpos.z-pos.z).normalized()
		var angvel = Vector3(randf_range(-5, 5), randf_range(-5, 5), randf_range(-5, 5))
		
		if map.chal == "justbox":
			dir.y += disttoplayer/100
		elif diff != 2:
			dir.y += disttoplayer/100
		else:
			dir.y += disttoplayer/400
			
		var power = 35
		if map.chal == "justbox":
			power = 35
		elif diff == 2:
			power = 70
		
		shootprojectile(startpos, dir, angvel, power)
		
func shockwave():
	var shockwave = load("res://shockwave.tscn").instantiate()
	shockwave.position = position
	$"../".add_child(shockwave)
	
func block(can):
	var startpos = $Armature/Skeleton3D/middlemouth/shootpos.global_position
	
	var pos = can.position
	pos = Vector3(pos.x, pos.y, pos.z)
	
	var dir = -Vector3(startpos.x-pos.x, startpos.y-pos.y, startpos.z-pos.z)
	var angvel = Vector3(randf_range(-5, 5), randf_range(-5, 5), randf_range(-5, 5))
	
	$anim.play("quickshoot")
	$audio.stream = load("res://audio/sodabox/quickshoot.mp3")
	$audio.play()
	shootprojectile(startpos, dir, angvel, 10, true)
	
func shootfromtop():
	var mult = 1
	if diff == 0: mult = randi_range(0, 1)
	elif diff == 2: mult = randi_range(1, 2) 
	if map.chal == "justbox":
		if randf() < 0.5: mult = 1
		else: mult = 0
		
	for i in range(mult):
		var startpos = $Armature/Skeleton3D/topleft/shootpos.global_position
		startpos.x += randf_range(-1, 1)
		startpos.z += randf_range(-1, 1)
		
		var randangle = atan2(player.position.x-startpos.x, player.position.z-startpos.z)
		
		if map.chal != "justbox": randangle += randf_range(-PI/2, PI/2)
		
		var randx = randf_range(2, 9)*sin(randangle)
		var randy = randf_range(4, 6)
		var randz = randf_range(2, 9)*cos(randangle)
		
		if map.chal == "justbox":
			randx = randf_range(4, 4)*sin(randangle)
			randy = randf_range(5, 5)
			randz = randf_range(4, 4)*cos(randangle)
		
		var dir = Vector3(randx, randy, randz)
		var angvel = Vector3(randf_range(-5, 5), randf_range(-5, 5), randf_range(-5, 5))
		
		shootprojectile(startpos, dir, angvel, 3, false, true)
		
func siderelease():
	var rand = randi_range(0, 1)
	for child in $sideflapver/canspots.get_children():
		var path = "res://sodaboss/sodacan.tscn"
		ResourceLoader.load_threaded_request(path)
		
		var progress = []
		ResourceLoader.load_threaded_get_status(path, progress)
		if progress[0] == 1:
			var can = ResourceLoader.load_threaded_get(path).instantiate()
			can.position = child.global_position
			can.startsee = true
			if rand == 0 && player.health <= 30 && diff != 2:
				can.set_meta("healthcan", true)
				print("higuyshealthtime")
			$"../".add_child(can)
	
func shootprojectile(pos, dir, angvel, power = 2, extra = false, nocanexplode = false):
	var path = "res://sodaboss/sodacanrigid.tscn"
	ResourceLoader.load_threaded_request(path)
	
	var progress = []
	ResourceLoader.load_threaded_get_status(path, progress)
	if progress[0] == 1:
		var projectile = ResourceLoader.load_threaded_get(path).instantiate()
		projectile.add_to_group("frombox")
		projectile.position = pos
		projectile.rotation.x = PI/2
		var linvel = dir*power
		#linvel.y -= 5
		projectile.linear_velocity = linvel
		projectile.angular_velocity = angvel
		if extra: projectile.extra = true
		if nocanexplode: projectile.add_to_group("nocanexplode")
		$"../".add_child(projectile)

func _on_blockarea_body_entered(body: Node3D) -> void:
	if started && !dead && !player.dead:
		print("was gud???")
		if body.is_in_group("canrigid") && !body.is_in_group("frombox"):
			if $blocktime.is_stopped():
				if !$anim.current_animation == "siderelease":
					if !$anim.current_animation == "fall":
						if !$anim.current_animation == "roll":
							if !$anim.current_animation == "fall":
								block(body)
								$blocktime.start()


func _on_anim_animation_finished(anim_name: StringName) -> void:
	
	if anim_name != "end":
		$collision.disabled = false
		$sidecollision.disabled = true
	
	if anim_name == "intro":
		reparent($"../../")
		
		global_position.x = center.x
		global_position.z = center.z
		
		player = $"../../player"
		started = true
		
		player.health = 100
		
		$"../../canvas/hud/sodaboxbossbar".show()
		$"../../canvas/hud/sodaboxbossbar".max_value = health
		hurt(0)
		
		$"../../music".stream = load("res://audio/music/factoryescapespicy.mp3")
		$"../../music".play()
		
		$anim.play("RESET")
	if anim_name == "fall":
		$anim.play("roll")
		$rollaudio.play()
	elif anim_name == "roll":
		if !$canroll.is_colliding():
			$anim.play("roll")
			$rollaudio.play()
		else:
			$anim.play("getup")
	elif anim_name == "move" || anim_name == "movebig":
		var dist = sqrt(pow(position.x-randpoint.x, 2) + pow(position.z-randpoint.z, 2))
		if dist < 0.5:
			$anim.play("RESET")
		else:
			var chance = 0.15
			if diff == 2: chance = 0.5
			var tempaudio = load("res://tempaudio.tscn").instantiate()
			add_child(tempaudio)
			if randf() <= chance:
				$anim.play("movebig")
				tempaudio.stream = load("res://audio/sodabox/movebig.mp3")
			else:
				$anim.play("move")
				tempaudio.stream = load("res://audio/sodabox/move.mp3")
			tempaudio.play()
	elif anim_name == "end":
		var mark = arena.get_node("endcutsceneplayerpos")
		player.position = mark.global_position
		arena.get_node("endcan").visible = true
		arena.get_node("ceilingcans").stop()
		arena.get_node("arrow").transparency = 0
		arena.get_node("endcancol").position.y += 2
		player.camera.current = true
	elif anim_name == "siderelease":
		$attackdelay.wait_time = 3
		if diff == 2:
			$attackdelay.wait_time = 1
		if map.chal == "justbox":
			$attackdelay.wait_time = 0.1
		$attackdelay.start()
	else:
		$attackdelay.wait_time = 0.5
		if map.chal == "justbox":
			$attackdelay.wait_time = 0.1
		$attackdelay.start()

func dointro():
	$anim.play("intro")
	wetnoise.color_ramp.set_offset(1, 1)
	wetnoise.color_ramp.set_offset(0, 0.99)

func _on_attackdelay_timeout() -> void:
	if !$anim.is_playing() && started && !dead && !player.dead:
		
		var rand = {
			"shootmany": 1.25,
			"shootfromtop": 1,
			"siderelease": 1.75,
			"roll": 0,
			"move": 0.75
		}
		
		if map.chal == "justbox":
			rand = {
			"shootmany": 2,
			"shootfromtop": 2,
			"siderelease": 0.5,
			"roll": 0,
			"move": 1
			}
		
		if !$canfall.is_colliding():
			rand["roll"] = 1.25
			
		if player.health <= 30:
			rand["siderelease"] *= 2
		
		if rand.has(choice): rand[choice] *= 0.2
			
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
				
		if choice == "shootmany":
			if diff == 0:
				$anim.play("shoot")
				$audio.stream = load("res://audio/sodabox/shoot.mp3")
				$audio.play()
			else:
				$anim.play("shootmany")
				$audio.stream = load("res://audio/sodabox/shootmany.mp3")
				$audio.play()
		if choice == "shootfromtop":
			$anim.play("shootfromtop")
			$audio.stream = load("res://audio/sodabox/shootfromtop.mp3")
			$audio.play()
		if choice == "siderelease":
			$anim.play("siderelease")
			$audio.stream = load("res://audio/sodabox/siderelease.mp3")
			$audio.play()
		if choice == "roll":
			$anim.play("fall")
			$audio.stream = load("res://audio/sodabox/fall.mp3")
			$audio.play()
		if choice == "move":
			var randside = randi_range(1, 4)
			var r = randf_range(-16, 16)
			if randside == 1: randpoint = Vector3(center.x+r, 0, center.z+16)
			if randside == 2: randpoint = Vector3(center.x+r, 0, center.z+-16)
			if randside == 3: randpoint = Vector3(center.x+16, 0, center.z+r)
			if randside == 4: randpoint = Vector3(center.x+-16, 0, center.z+r)
			$anim.play("move")
			$audio.stream = load("res://audio/sodabox/move.mp3")
			$audio.play()
		#$anim.play("shootmany")

func _on_roll_body_entered(body: Node3D) -> void:
	if $anim.current_animation == "roll":
		if body.is_in_group("playergroup"):
			body.hurt(25, "squish")
			body.velocity.y += 20
			
func endmusic():
	$"../../music".stop()
			
func hurt(amount):
	health -= amount
	
	print(wetnoise.color_ramp.get_offset(0))
	print(wetnoise.color_ramp.get_offset(1))
	
	if health <= 0:
		health = 0
		
		if !dead && !player.dead:
			$anim.play("end")
			
			$"../../sfx2".stream = load("res://audio/sodabox/end.mp3")
			$"../../sfx2".play()
			
			$endcam.current = true
			var mark = arena.get_node("endcutscenepos")
			position = mark.global_position
			rotation = mark.global_rotation
			
			var loadoutfit = load($"../../".outfit).instantiate()
			for child in $cameraplayer/Skeleton3D/headbone/attachments.get_children():
				child.queue_free()
			if loadoutfit.has_node("Armature/Skeleton3D/head"):
				var headattachments = loadoutfit.get_node("Armature/Skeleton3D/head")
				for child in headattachments.get_children():
					child.reparent($cameraplayer/Skeleton3D/headbone/attachments)
					child.position = headattachments.position
					child.rotation = headattachments.rotation-$cameraplayer/Skeleton3D/headbone.rotation
					child.scale = headattachments.scale
			var mainbody = loadoutfit.get_node("Armature/Skeleton3D/main")
			$cameraplayer/Skeleton3D/Cube.name = "deletebody"
			$cameraplayer/Skeleton3D/deletebody.queue_free()
			mainbody.reparent($cameraplayer/Skeleton3D)
			mainbody.position = Vector3.ZERO
			mainbody.rotation = Vector3.ZERO
			mainbody.name = "Cube"
			if $"../../".outfitcolors.has($"../../".outfit):
				if mainbody.has_meta("extracolors"):
					for i in range(1, mainbody.get_meta("extracolors")+1):
						var curcolorrgb = $"../../".outfitcolors[$"../../".outfit][str(i)]
						var curcolor = Color(curcolorrgb["r"], curcolorrgb["g"], curcolorrgb["b"])
						mainbody.get_surface_override_material(i).albedo_color = curcolor
			
			$cameraplayer/Skeleton3D/Cube.get_surface_override_material(0).albedo_color = $"../../".bodycolor
			var loadhead = load($"../../".head).instantiate()
			$cameraplayer/Skeleton3D/headbone/offset.add_child(loadhead)
			
			
			dead = true
			$"../../canvas/hud/sodaboxbossbar".hide()
			
			for child in get_parent().get_children():
				if child.is_in_group("sodacan"):
					child.queue_free()
	else:
		var maxhealth = $"../../canvas/hud/sodaboxbossbar".max_value
		
		wetnoise.color_ramp.set_offset(0, ((health/maxhealth)*0.5)+0.4)
		wetnoise.color_ramp.set_offset(1, ((health/maxhealth)*0.5)+0.5)
		
		$"../../canvas/hud/sodaboxbossbar".value = health
		$"../../canvas/hud/sodaboxbossbar"/healthlabel.text = str(int(round(health)))
