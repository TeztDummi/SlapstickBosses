extends CharacterBody3D
@onready var player = $"../../player"
var diff = -1
var chal = "none"
var turntoplayer = true
var shotgunoff = Vector3.ZERO
var cancelshotgun = false
var disttoplayer = 10
var walking = false
var walktimer = 0
var choice = ""
var shotgunshots = 2
var sniper = -1
var phase = 0
var health = 1500
var isdead = false
var hurttime = 0

const easydmg = 0.6
const easyspeed = 0.75
const harddmg = 1.2
const hardspeed = 1.75

var fastspeed = 1.5
var rocketchance = 0.1

# Called when the node enters the scene tree for the first time.
func _ready():
	if chal == "gunmanfast":
		health = 1000
	if chal == "gunmanrockets":
		phase = 3
		health = 500
	$"../".phasechange(phase)
	$"../../canvas/hud/gunmanbossbar".max_value = health
	$"../../canvas/hud/gunmanbossbar".value = health
	$"../../canvas/hud/gunmanbossbar/healthlabel".text = str(round(health))
	$"../../canvas/hud/gunmanbossbar".tint_progress = Color.from_hsv(health*0.003*(100/$"../../canvas/hud/gunmanbossbar".max_value), 0.5, 1)
	$"../../music".stop()
	turntoplayer = false
	if $"../../".restarted != 1:
		$anim.play("intro")
		$introcam.current = true
	else:
		_on_anim_animation_finished("intro")
	
	if chal == "gunmanfast":
		$".".scale *= 0.5
		$gunman/torso/head.scale *= 2
		$deadhead.scale *= 2
		$anim.speed_scale = fastspeed
		$audio.pitch_scale = fastspeed
		$gunman/torso/shotgun/anim.speed_scale = fastspeed
		$introcam/cutsceneaudio.pitch_scale = fastspeed
		
	$"../../canvas/hud/gunmanbossbar/gunmanicon".play("default")
	$"../../canvas/hud/gunmanbossbar/gunmanicon".frame = 0

func dothewallthingy():
	phase += 1
	if isdead && phase < 4:
		phase = 4
	$"../".phasechange(phase)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !isdead:
		if health <= 50:
			if $anim.current_animation != "death":
				turntoplayer = false
				$anim.play("death")
				$audio.stream = load("res://audio/gunman/death.mp3")
				$audio.play()
				$introcam.current = true
				isdead = true
				$CollisionShape3D.disabled = true
				hurttime = 0
				$gunman/torso.get_surface_override_material(0).emission = Color(0, 0, 0)
				$gunman/torso/shotgun/anim.play("RESET")
				$gunman/torso/shotgun.rotation_degrees = Vector3(-65.5, 90, 0)
				position = Vector3(0,0,0)
				player.rotation.y = atan2(player.position.x-global_position.x, player.position.z-global_position.z)
				return
		if sniper >= 0:
			sniper += delta
			if sniper >= 0.5:
				sniper = -1
				snipershoot()
				$anim.play("sniperend")
				$audio.stream = load("res://audio/gunman/snipershoot.mp3")
				$audio.play()
		var lookpos = player.position
		lookpos.y += 1.5
		$look.look_at(lookpos)
		if $anim.current_animation == "realidle":
			var iseeu = false
			if $look.get_collider() != null:
				if $look.get_collider().is_in_group("playergroup"):
					iseeu = true
			if disttoplayer <= 10:
				iseeu = true
			if iseeu:
				chooseattack()
		disttoplayer = sqrt(pow(position.x-player.position.x, 2) + pow(position.z-player.position.z, 2))
		
		if disttoplayer <= 4 && $anim.current_animation != "bitchslap":
			$anim.play("bitchslap")
			$audio.stream = load("res://audio/gunman/slap.mp3")
			$audio.play()
			turntoplayer = true
		
		shotgunoff.x = randf_range(shotgunoff.x-1.5, 0.5-shotgunoff.x)*0.2
		shotgunoff.y = randf_range(shotgunoff.y-1, 1-shotgunoff.y)*0.2
		shotgunoff.z = randf_range(shotgunoff.z-1, 1-shotgunoff.z)*0.2
		
		if turntoplayer:
			$"../../lookat".look_at_from_position(position, player.position)
			var turnspeed = delta*4
			if walking: turnspeed = delta*4
			rotation.y = lerp_angle(rotation.y, $"../../lookat".rotation.y, turnspeed)
		
		if !is_on_floor() && !isdead:
			velocity.y -= 30*delta
		
		if walking:
			walktimer += delta
			velocity.x = -sin(rotation.y)*12
			velocity.z = -cos(rotation.y)*12
			if chal == "gunmanfast":
				velocity.x *= fastspeed
				velocity.z *= fastspeed
			if chal == "gunmanrockets":
				velocity.x *= 2
				velocity.z *= 2
			if disttoplayer < 10 || walktimer >= 3:
				walktimer = 0
				walking = false
				chooseattack()
		else:
			velocity.x = 0
			velocity.z = 0
		
		move_and_slide()
		
		cancelshotgun = false
		
		if $gunman/torso/shotgun/anim.is_playing():
			$direction.look_at_from_position(position, player.position)
			var rot = $direction.rotation_degrees
			if rot.y > 45: cancelshotgun = true
			if rot.y < -45: cancelshotgun = true
			if disttoplayer > 40:
				cancelshotgun = true
			
		if $gunman/torso/shotgun/anim.is_playing():
			#$gunman/torso/shotgun/shotgun/shotgun.rotation = Vector3.ZERO
			var from = $gunman/torso/shotgun.global_position
			var to = player.global_position
			to.y += 1
			$"../../lookat".look_at_from_position(from, to)
			$gunman/torso/shotgun.global_rotation = $"../../lookat".global_rotation+shotgunoff*0.5
			$gunman/torso/shotgun.global_rotation.x -= 0.25
			$gunman/torso/shotgun.scale = Vector3(0.612, 0.612, 0.612)
		else:
			$gunman/torso/shotgun.rotation_degrees = Vector3(-65.5, 90, 0)
			
		if cancelshotgun:
			$gunman/torso/shotgun/anim.stop()
			_on_anim_animation_finished("shotgunshoot")
			
		if $gunman/torso/shotgun/anim.is_playing() || sniper >= 0:
			var from = $gunman/torso/head/headlook.global_position
			var to = player.global_position+player.velocity*0.1
			to.y += 1
			var pos = $gunman/torso/head.global_position
			$gunman/torso/head.look_at_from_position(from, to)
			$gunman/torso/head.global_position = pos
			
		if hurttime > 0:
			hurttime -= delta*4
			$gunman/torso.get_surface_override_material(0).emission = Color(hurttime/2, 0, 0)
		else: 
			hurttime = 0
			$gunman/torso.get_surface_override_material(0).emission = Color(0, 0, 0)
			
func slap():
	for body in $slaparea.get_overlapping_bodies():
		if body.is_in_group("playergroup"):
			var direction = atan2(player.position.x-global_position.x, player.position.z-global_position.z)
			player.velocity.x += sin(direction)*60
			player.velocity.y += 20
			player.velocity.z += cos(direction)*60
			player.hurt(20, "ragdoll")
		if body.is_in_group("glasswall"):
			body.get_parent().get_parent().shatter()
		
func shotgunshoot(slower = false):
	player.screenshake += 0.2
	var range = 4.0
	print(randf())
	if chal == "gunmanrockets" && randf() <= rocketchance*4:
		for i in range(range):
			var bullet = backload("res://gunmanrocket.tscn").instantiate()
			bullet.rotation = Vector3(-PI/2,0,0)
			bullet.position = $gunman/torso/shotgun/shotgun/shotgun/Node3D/bullets.global_position
			$"../".add_child(bullet)
	else:
		for i in range(range):
			var bullet = backload("res://bullet.tscn").instantiate()
			bullet.rotation = $gunman/torso/shotgun.global_rotation
			if health <= 50:
				bullet.rotation.x *= 2.2
			if slower: bullet.speed *= 2.0/3.0
			bullet.rotation_degrees.y += ((i+1)-range/2)*90*(1/range)
			bullet.scale *= 0.3
			bullet.position = $gunman/torso/shotgun/shotgun/shotgun/Node3D/bullets.global_position
			if diff == 0:
				bullet.damagemult = easydmg
				bullet.speed *= easyspeed
			if diff == 2:
				bullet.damagemult = harddmg
				bullet.speed *= hardspeed
			if chal == "gunmanfast": bullet.scale *= 0.75
			$"../".add_child(bullet)
		
func smgshoot():
	player.screenshake += 0.02
	var range = 2.0
	if health <= 50:
		range = 2.0
	if chal == "gunmanfast": range = 1.0
	
	if chal == "gunmanrockets" && randf() <= rocketchance/2:
		for i in range(range):
			var bullet = backload("res://bullet.tscn").instantiate()
			bullet.rotation = Vector3(-PI/2,0,0)
			bullet.position = $gunman/torso/smgarm/Armature/Skeleton3D/Vert_001/smgbullets.global_position
			$"../".add_child(bullet)
	else:
		for i in range(range):
			var bullet = backload("res://bullet.tscn").instantiate()
			bullet.rotation = $gunman/torso/smgarm/Armature/Skeleton3D/Vert_001/smgbullets.global_rotation
			bullet.rotation.x *= 2.2
			if health <= 50:
				bullet.rotation_degrees.y += ((i+1)-range/2)*360*(1/range)
			else:
				bullet.rotation_degrees.y += (i-0.5)*randf_range(5, 20)
				
			if randf() < 0.5:
				bullet.rotation.y = atan2(player.position.x-global_position.x, player.position.z-global_position.z)+PI+randf_range(-PI/8, PI/8)
			bullet.scale *= 0.2
			bullet.position = $gunman/torso/smgarm/Armature/Skeleton3D/Vert_001/smgbullets.global_position
			if diff == 0:
				bullet.damagemult = easydmg
				bullet.speed *= easyspeed
			if diff == 2:
				bullet.damagemult = harddmg
				bullet.speed *= hardspeed
			if chal == "gunmanfast": bullet.scale *= 0.75
			$"../".add_child(bullet)
				
func backload(path):
	ResourceLoader.load_threaded_request(path)
	var progress = []
	ResourceLoader.load_threaded_get_status(path, progress)
	var obj
	if progress[0] == 1:
		obj = ResourceLoader.load_threaded_get(path)
	else:
		obj = load(path)
	return obj
	
				
func shootrocket(rocket):
	var target = get_node(rocket)
	var bullet = backload("res://gunmanrocket.tscn").instantiate()
	bullet.rotation = Vector3(-PI/2,0,0)
	bullet.position = target.global_position
	$"../".add_child(bullet)
	
func snipershoot():
	player.screenshake += 0.1
	var bullet = backload("res://sniperbullet.tscn").instantiate()
	bullet.rotation = $gunman/torso/head.global_rotation
	#bullet.rotation_degrees.y += 180
	bullet.scale *= 1
	bullet.position = $gunman/torso/head/sniper/Cylinder_001/Cylinder_002/snipershoot.global_position
	bullet.speed = 150
	#if diff == 0:
		#bullet.damagemult = easydmg
		#bullet.speed *= easyspeed
	if diff == 2:
		bullet.damagemult = harddmg
	if chal == "gunmanfast": bullet.scale *= 0.75
	$"../".add_child(bullet)
	
func chooseattack():
	var iseeu = false
	if $look.get_collider() != null:
		if $look.get_collider().is_in_group("playergroup"):
			iseeu = true
	if disttoplayer <= 10:
		iseeu = true
	if iseeu:
		var rand = {
			"shotgun": 1,
			"smg": 1,
			"rockets": 0.25,
			"sniper": 0,
			"walk": 0
		}
		if disttoplayer <= 10:
			rand["shotgun"] = 3
			rand["rockets"] = 0
		if disttoplayer > 20:
			rand["shotgun"] = 0
		if disttoplayer > 30 && disttoplayer <= 40:
			rand["smg"] *= 2
		if disttoplayer > 40:
			rand["sniper"] = 5
		if disttoplayer > 10: rand["walk"] = 0.25
		if disttoplayer > 30: rand["walk"] = 1
		if disttoplayer > 50: rand["walk"] = 1.5
		
		if chal == "gunmanrockets": rand["rockets"] = 1
		
		if phase <= 0:
			rand["smg"] = 0
			rand["rockets"] = 0
		if phase <= 1:
			rand["sniper"] = 0
		
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
		if chal == "gunmanfast":
			if health <= 750:
				if phase == 0:
					choice = "wall"
			if health <= 400:
				if phase == 1:
					choice = "shootplayergun"
			if health <= 200:
				if phase == 2:
					choice = "wall"
		elif chal != "gunmanrockets":
			if health <= 1200:
				if phase == 0:
					choice = "wall"
			if health <= 600:
				if phase == 1:
					choice = "shootplayergun"
			if health <= 250:
				if phase == 2:
					choice = "wall"
		
		if choice == "slap":
			$anim.play("bitchslap")
			$audio.stream = load("res://audio/gunman/slap.mp3")
			$audio.play()
			turntoplayer = true
		if choice == "walk":
			$anim.play("run")
			$audio.stream = load("res://audio/gunman/run.mp3")
			$audio.play()
			walking = true
			turntoplayer = true
		if choice == "shotgun":
			$anim.play("shotgun")
			$audio.stream = load("res://audio/gunman/shotgunready.mp3")
			$audio.play()
			shotgunshots = randi_range(2, 5)
			turntoplayer = true
		if choice == "smg":
			$anim.play("smg")
			$audio.stream = load("res://audio/gunman/smgshoot.mp3")
			$audio.play()
			turntoplayer = true
		if choice == "rockets":
			if chal == "gunmanrockets":
				$anim.play("morerockets")
				$audio.stream = load("res://audio/gunman/morerockets.mp3")
				$audio.play()
				turntoplayer = false
			else:
				$anim.play("rockets")
				$audio.stream = load("res://audio/gunman/rockets.mp3")
				$audio.play()
				turntoplayer = false
		if choice == "sniper":
			$anim.play("sniper")
			$audio.stream = load("res://audio/gunman/sniperstart.mp3")
			$audio.play()
			turntoplayer = true
		if choice == "wall":
			$anim.play("activatewall")
			$audio.stream = load("res://audio/gunman/activatewall.mp3")
			$audio.play()
			turntoplayer = false
		if choice == "shootplayergun":
			phase += 1
			$"../".phasechange(phase)
			$anim.play("shootplayergun")
			$introcam/cutsceneaudio.stream = load("res://audio/gunman/shootplayergun.mp3")
			$introcam/cutsceneaudio.play()
			position = Vector3(0,0,0)
			player.position = $Armature.global_position
			player.rotation.y = atan2(player.position.x-global_position.x, player.position.z-global_position.z)
			for gun in $"../../player/camera/gun".get_children():
				if !gun.has_meta("held"):
					gun.queue_free()
			$introcam.current = true
			
			var loadoutfit = load($"../../".outfit).instantiate()
			if loadoutfit.has_node("Armature/Skeleton3D/head"):
				var headattachments = loadoutfit.get_node("Armature/Skeleton3D/head")
				for child in headattachments.get_children():
					print("load attachments")
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
			mainbody.scale = Vector3.ONE
			mainbody.name = "Cube"
			if $"../../".outfitcolors.has($"../../".outfit):
				if mainbody.has_meta("extracolors"):
					for i in range(1, mainbody.get_meta("extracolors")+1):
						var curcolorrgb = $"../../".outfitcolors[$"../../".outfit][str(i)]
						var curcolor = Color(curcolorrgb["r"], curcolorrgb["g"], curcolorrgb["b"])
						mainbody.get_surface_override_material(i).albedo_color = curcolor
			
			print("loaded outfit")
			
			$Armature/Skeleton3D/Cube.get_surface_override_material(0).albedo_color = $"../../".bodycolor
			var loadhead = load($"../../".head).instantiate()
			$Armature/Skeleton3D/headbone/offset.add_child(loadhead)
			turntoplayer = false
			
			print("loaded head")
	else:
		$anim.play("realidle")
		turntoplayer = false
	
func resetshootparticle():
	$gunman/torso/shotgun/shotgun/shotgun/Node3D/shotgunparticle.draw_pass_1.material.albedo_texture.current_frame = 0
	$gunman/torso/shotgun/shotgun/shotgun/Node3D/shotgunparticle.draw_pass_2.material.albedo_texture.current_frame = 0

func hurt(amount):
	if !isdead:
		health -= amount
		if health < 50:
			health = 50
		else:
			$"../../canvas/hud/gunmanbossbar/gunmanicon".play("hurt")
			$"../../canvas/hud/gunmanbossbar/gunmanicon".frame = 0
		hurttime = 1
		
		$"../../canvas/hud/gunmanbossbar".value = health
		$"../../canvas/hud/gunmanbossbar"/healthlabel.text = str(int(round(health)))
		#fuckass godot update made me do this nightmare nightmare
		$"../../canvas/hud/gunmanbossbar".tint_progress = Color.from_hsv(health*0.003*(100/$"../../canvas/hud/gunmanbossbar".max_value), 0.5, 1)

func _on_anim_animation_finished(anim_name):
	if anim_name == "shotgun":
		if phase <= 0:
			$gunman/torso/shotgun/anim.play("shotgunshootslower")
			var tempaudio = load("res://tempaudio.tscn").instantiate()
			tempaudio.stream = load("res://audio/gunman/shotgunshoot.mp3")
			tempaudio.volume_db = $audio.volume_db
			if chal == "gunmanfast": tempaudio.pitch_scale = fastspeed
			add_child(tempaudio)
			tempaudio.play()
		else:
			$gunman/torso/shotgun/anim.play("shotgunshoot")
			var tempaudio = load("res://tempaudio.tscn").instantiate()
			tempaudio.stream = load("res://audio/gunman/shotgunshootslower.mp3")
			tempaudio.volume_db = $audio.volume_db
			if chal == "gunmanfast": tempaudio.pitch_scale = fastspeed
			add_child(tempaudio)
			tempaudio.play()
			
		turntoplayer = false
		
	if anim_name == "shotgunshoot" || anim_name == "shotgunshootslower":
		if shotgunshots > 0:
			if phase <= 0:
				if !$gunman/torso/shotgun/anim.is_playing():
					var tempaudio = load("res://tempaudio.tscn").instantiate()
					tempaudio.stream = load("res://audio/gunman/shotgunshoot.mp3")
					tempaudio.volume_db = $audio.volume_db
					if chal == "gunmanfast": tempaudio.pitch_scale = fastspeed
					add_child(tempaudio)
					tempaudio.play()
				$gunman/torso/shotgun/anim.play("shotgunshootslower")
			else:
				if !$gunman/torso/shotgun/anim.is_playing():
					var tempaudio = load("res://tempaudio.tscn").instantiate()
					tempaudio.stream = load("res://audio/gunman/shotgunshootslower.mp3")
					tempaudio.volume_db = $audio.volume_db
					if chal == "gunmanfast": tempaudio.pitch_scale = fastspeed
					add_child(tempaudio)
					tempaudio.play()
				$gunman/torso/shotgun/anim.play("shotgunshoot")
			shotgunshots -= 1
			turntoplayer = false
		else:
			$anim.play("shotgunend")
			$audio.stream = load("res://audio/gunman/shotgunend.mp3")
			$audio.play()
	if anim_name == "bitchslap":
		chooseattack()
	if anim_name == "shotgunend":
		chooseattack()
	if anim_name == "smg":
		chooseattack()
	if anim_name == "rockets":
		chooseattack()
	if anim_name == "morerockets":
		chooseattack()
	if anim_name == "sniper":
		sniper = 0
	if anim_name == "sniperend":
		chooseattack()
	if anim_name == "activatewall":
		chooseattack()
	if anim_name == "shootplayergun":
		player.camera.current = true
		chooseattack()
	if anim_name == "intro":
		player.camera.current = true
		chooseattack()
		if chal == "gunmanrocket":
			$"../../music".stream = load("res://audio/music/spicygunmanmusic.mp3")
			$"../../music".play()
		else:
			$"../../music".stream = load("res://audio/music/gunmanmusic.mp3")
			$"../../music".play()
		
	if anim_name == "death":
		if !player.dead:
			$"../../".spawnlobbyportal()
			if chal == "none":
				var earnedbits = $"../../".calcbits(diff, $"../../".beatgunman, 1)
				$"../../".bits += earnedbits
				if diff == 2:
					$"../../".setAchievement("tacticletorsion")
					if player.health >= 100: $"../../".setAchievement("100")
				if earnedbits > 0:
					var popup = load("res://popup.tscn").instantiate()
					popup.bits = earnedbits
					$"../../sfx".stream = load("res://audio/gainbits.mp3")
					if diff == 2 && !$"../../".unlockedheads.has("gunman"):
						popup.cosmetic = true
						$"../../".unlockedheads.append("gunman")
						$"../../sfx".stream = load("res://audio/gaincosmetic.mp3")
					$"../../sfx".play()
					$"../../canvas/hud".add_child(popup)
				if diff > $"../../".beatgunman: $"../../".beatgunman = diff
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

func makecamplayercam(string):
	if string == "start":
		player.camera.current = true
		$introcam.current = false
		if $"../../music".stream.resource_path.get_file() == "gunmanmusic.mp3":
			$"../../".transitionmusic("res://audio/music/spicygunmanmusic.mp3", 1, true, 48, 0)
	if string == "endcut":
		if !player.dead:
			player.camera.current = false
			$introcam.current = true
			$introcam.set_meta("showhud", true)
			$"../../canvas/hud".show()
			position = Vector3(0,0,0)
			player.rotation.y = atan2(player.position.x-global_position.x, player.position.z-global_position.z)
			if chal == "gunmanrockets": $"../rockets".stop()
			$"../../canvas/hud/gunmanbossbar/gunmanicon".play("end")
			$"../../canvas/hud/gunmanbossbar/gunmanicon".frame = 0
	if string == "end":
		player.camera.current = true
		$introcam.current = false
		$"../../music".stop()
func remove10health():
	health -= 10
	$"../../canvas/hud/gunmanbossbar/gunmanicon".play("hurt")
	$"../../canvas/hud/gunmanbossbar/gunmanicon".frame = 0
	
	$"../../canvas/hud/gunmanbossbar".value = health
	$"../../canvas/hud/gunmanbossbar"/healthlabel.text = str(round(health))
	$"../../canvas/hud/gunmanbossbar".tint_progress = Color.from_hsv(health*0.003*(100/$"../../canvas/hud/gunmanbossbar".max_value), 0.5, 1)

func _on_slaparea_body_entered(body):
	if body.is_in_group("glasswall"):
		print("GYEEEAH")
		walking = false
		if $anim.current_animation != "bitchslap":
			$anim.play("bitchslap")
			$audio.stream = load("res://audio/gunman/slap.mp3")
			$audio.play()


func _on_deathsmg_timeout():
	smgshoot()
