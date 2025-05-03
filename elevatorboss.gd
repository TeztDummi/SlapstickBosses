extends Node3D
var slams = 0
var shockwaveonland = false
var lasering = false
var time = 90 #change other one
var dead = false
var diff = 1
var chal = "none"
@onready var player = $"../../player"
var ismain = true
@onready var anim = $anim
# Called when the node enters the scene tree for the first time.
func _ready():
	playsound("res://audio/elevator/intro.mp3")
	if ismain: $introcamera.current = true
	if !ismain:
		position.z = 6
		$introcamera/splash/splashback.hide()
	if chal == "2elevators":
		$introcamera/splash/s.show()
		$introcamera/splash.position.x -= 0.1
		
	var dupe = $elevator/glow.get_surface_override_material(0).duplicate()
	$elevator/glow.set_surface_override_material(0, dupe)
	var dupe2 = $elevator/laserwarning.get_surface_override_material(0).duplicate()
	$elevator/laserwarning.set_surface_override_material(0, dupe2)
	var dupe3 = $warning.get_surface_override_material(0).duplicate()
	$warning.set_surface_override_material(0, dupe3)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !dead:
		time = $"../../".timer
		if chal == "2elevators":
			time = $"../../".timer+30 
		
		if position.x < -18: position.x = -18
		if position.x > 18: position.x = 18
		if position.z < -18: position.z = -18
		if position.z > 18: position.z = 18
		
		if $"../../".timer <= 0:
			if !player.dead:
				if ismain: $introcamera.current = true
				
				$audio.stop()
				$audio2.stop()
				$audio3.stop()
				playsound("res://audio/elevator/death.mp3")
				
				$anim.play("die")
				
				dead = true
				
				if ismain:
					for child in $"../".get_children():
						if child.is_in_group("elevatorenemy"):
							child.queue_free()
					
					$"../../canvas/hud/timer".hide()
					$"../../music".stop()
			
		$warning.get_surface_override_material(0).uv1_offset.x += delta
		
		if $anim.current_animation == "laserblast":
			if diff == 0:
				if time >= 60: rotation_degrees.y += delta*65
				elif time >= 30: rotation_degrees.y += delta*90
				else: rotation_degrees.y += delta*135
			if diff == 1:
				if time >= 60: rotation_degrees.y += delta*90
				elif time >= 30: rotation_degrees.y += delta*135
				else: rotation_degrees.y += delta*180
			if diff == 2:
				rotation_degrees.y += delta*180
		
		if lasering:
			var peoplelasered = $lasercollider.get_overlapping_bodies()
			for person in peoplelasered:
				if person.is_in_group("playergroup"):
					player.hurt(100, "bluelaser")
				if person.is_in_group("elevatorenemy"):
					person.queue_free()
			player.screenshake = 0.2
		
		if time <= 30 || diff == 2:
			if $"../../music".stream.resource_path.get_file() == "bossmusic.mp3":
				if chal != "2elevators":
					var playtime = $"../../music".get_playback_position()
					playtime -= 1.6
					for i in range(10):
						if playtime > 25.6:
							playtime -= 25.6
						else:
							break
					
					$"../../music".stream = load("res://audio/music/spicybossmusic.mp3")
					$"../../music".play()
					$"../../music".seek(playtime)

func _on_anim_animation_finished(anim_name):
	
	if anim_name == "die" && ismain:
		player.camera.current = true
		$"../../".spawnlobbyportal()
		if chal == "none":
			var earnedbits = $"../../".calcbits(diff, $"../../".beatelevator, 1)
			$"../../".bits += earnedbits
			if diff == 2:
				$"../../".setAchievement("anormalelevator")
			if earnedbits > 0:
				var popup = load("res://popup.tscn").instantiate()
				popup.bits = earnedbits
				$"../../sfx".stream = load("res://audio/gainbits.mp3")
				if diff == 2 && !$"../../".unlockedheads.has("elevator"):
					popup.cosmetic = true
					$"../../".unlockedheads.append("elevator")
					$"../../sfx".stream = load("res://audio/gaincosmetic.mp3")
				$"../../sfx".play()
				$"../../canvas/hud".add_child(popup)
			if diff > $"../../".beatelevator: $"../../".beatelevator = diff
		else:
			if !$"../../".beatchallenges.has(chal):
				$"../../".beatchallenges[chal] = true
				var popup = load("res://popup.tscn").instantiate()
				popup.bits = $"../../".getchalbits(chal)
				$"../../".bits += $"../../".getchalbits(chal)
				$"../../sfx".stream = load("res://audio/gainbits.mp3")
				$"../../sfx".play()
				$"../../canvas/hud".add_child(popup)
			
		$"../../".save_game()
	
	if !dead:
		if (time < 30 || diff == 2) && diff != 0 && $slamtimer.wait_time != 0.6: $slamtimer.wait_time = 0.6
		
		if anim_name == "goupcomedown":
			if diff == 2 && time >= 30:
				slams = 0
			else:
				slams = randi_range(0, 1)
			if player.dead: queue_free()
			if (time >= 30 && diff != 2) || diff == 0:
				$anim.play("comedown")
				playsound("res://audio/elevator/comedown.mp3")
			else:
				if diff == 2:
					$anim.play("comedownhitfloorfast")
					playsound("res://audio/elevator/comedownhitfloorfast.mp3")
					shockwaveonland = true
				else:
					$anim.play("comedownfast")
					playsound("res://audio/elevator/comedownfast.mp3")
			if randf() >= 0.5 && time >= 30 && diff != 2:
				position = Vector3(player.position.x+randf_range(-3, 3), 0, player.position.z+randf_range(-3, 3))
			else:
				position = Vector3(player.position.x+player.velocity.x*0.9, 0, player.position.z+player.velocity.z*0.9)
			$slamtimer.start()
			
		if anim_name == "comedown" || anim_name == "comedownfast":
			if slams > 0:
				slams -= 1
				if (time >= 30 && diff != 2) || diff == 0:
					$anim.play("comedown")
					playsound("res://audio/elevator/comedown.mp3")
				else:
					$anim.play("comedownfast")
					playsound("res://audio/elevator/comedownfast.mp3")

				if randf() >= 0.5 && time >= 30 && diff != 2:
					position = Vector3(player.position.x+randf_range(-3, 3), 0, player.position.z+randf_range(-3, 3))
				else:
					position = Vector3(player.position.x+player.velocity.x*0.9, 0, player.position.z+player.velocity.z*0.9)
					
				rotation_degrees.y = randi_range(0, 3)*90
				$slamtimer.start()
			else:
				if (time >= 30 && diff != 2) || diff == 0:
					$anim.play("comedownhitfloor")
					playsound("res://audio/elevator/comedownhitfloor.mp3")
				else:
					$anim.play("comedownhitfloorfast")
					playsound("res://audio/elevator/comedownhitfloorfast.mp3")
				if randf() >= 0.5 && time >= 30 && diff != 2:
					position = Vector3(player.position.x+randf_range(-3, 3), 0, player.position.z+randf_range(-3, 3))
				else:
					position = Vector3(player.position.x+player.velocity.x*0.9, 0, player.position.z+player.velocity.z*0.9)
				$slamtimer.start()
				shockwaveonland = true
				
		if anim_name == "laserblast":
			chooseattack()
			lasering = false
			
		if anim_name == "getwheelmen":
			chooseattack()
			
		if anim_name == "getrats":
			chooseattack()
			
		if anim_name == "getdummi":
			chooseattack()
			
		if anim_name == "intro":
			var dupe4 = $elevator/elevator.get_surface_override_material(7).duplicate()
			$elevator/elevator.set_surface_override_material(7, dupe4)
			chooseattack()
			player.camera.current = true
				
func _on_slamtimer_timeout():
	if !dead:
		var peopleunder = $bottomcollider.get_overlapping_bodies()
		for person in peopleunder:
			if person.is_in_group("playergroup"):
				player.hurt(100, "squish")
				print("slamkill")
			if person.is_in_group("elevatorenemy"):
				person.get_parent().queue_free()
		if shockwaveonland:
			spawnenemy("shockwave", 10)
			player.screenshake += 0.5
			shockwaveonland = false
			chooseattack()
			
func chooseattack():
	if !dead:
		var rand = randi_range(0, 3)
		if diff == 2 && time >= 30:
			rand = randi_range(-3, 3)
		if rand >= -3 && rand <= 1 || player.dead:
			$anim.play("goupcomedown")
			playsound("res://audio/elevator/goup.mp3")
		elif rand == 2:
			$anim.play("laserblast")
			playsound("res://audio/elevator/laserblast.mp3")
			$lasertimer.start()
		else:
			if randi_range(0, 30) == 0:
				$anim.play("getdummi")
				playsound("res://audio/elevator/getenemy.mp3")
				$enemytimer.start()
			elif randi_range(0, 5) != 0 && chal != "rats":
				$anim.play("getrats")
				playsound("res://audio/elevator/getenemy.mp3")
				$enemytimer.start()
			else:
				$anim.play("getwheelmen")
				playsound("res://audio/elevator/getenemy.mp3")
				$enemytimer.start()

func _on_lasertimer_timeout():
	lasering = true

func _on_enemytimer_timeout():
	if !dead:
		var rand = randi_range(5, 8)
		spawnenemy($anim.current_animation, rand)
			
func playsound(sound):
	var player = $audio
	if $audio.is_playing():
		player = $audio2
		if $audio2.is_playing():
			player = $audio3
	
	player.stream = load(sound)
	player.play()

func spawnenemy(anim, rand):
	if !dead:
		if anim == "getwheelmen":
			for i in range(1):
				var wheelman = load("res://elevator/wheelman.tscn").instantiate()
				wheelman.position = Vector3(position.x, position.y, position.z)
				wheelman.velocity = Vector3(sin(rotation.y-PI/2)*10, 0, cos(rotation.y-PI/2)*10)
				$"../".add_child(wheelman)
		elif anim == "getrats":
			var amount = 1
			if diff == 2: amount = 2
			if diff == 0: amount = 0.5
			for i in range(rand*amount):
				var rat = load("res://elevator/rat.tscn").instantiate()
				rat.position = Vector3(position.x+randf_range(-2, 2), position.y, position.z+randf_range(-2, 2))
				rat.velocity = Vector3(sin(rotation.y-PI/2)*0.6, 0, cos(rotation.y-PI/2)*0.6)
				$"../".add_child(rat)
		elif anim == "getdummi":
			for i in range(5):
				var dummi = load("res://dummirigid.tscn").instantiate()
				dummi.position = Vector3(position.x, position.y+0.6, position.z)
				dummi.linear_velocity = Vector3(sin(rotation.y-PI/2+randf_range(-0.5, 0.5))*randf_range(20, 50), randf_range(0, 10), cos(rotation.y-PI/2+randf_range(-0.5, 0.5))*randf_range(20, 50))
				print(dummi.linear_velocity)
				dummi.rotation = Vector3(randf_range(0, 2*PI), randf_range(0, 2*PI), randf_range(0, 2*PI))
				$"../".add_child(dummi)
		elif anim == "shockwave":
			var shockwave = load("res://shockwave.tscn").instantiate()
			shockwave.position = position
			$"../".add_child(shockwave)
			
			if diff == 2:
				var newshockwave = load("res://shockwave.tscn").instantiate()
				newshockwave.position = position
				newshockwave.scale.x = -2
				newshockwave.scale.z = -2
				$"../".add_child(newshockwave)

func launchup():
	for body in $launchup.get_overlapping_bodies():
		if body.is_in_group("playergroup"):
			body.position.y += 10
			body.velocity.y = 40
			body.hurt(30, "ragdoll")
			print("diddy party")
