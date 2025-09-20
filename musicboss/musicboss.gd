extends Node3D
var diff = -1
@onready var main = get_node("/root").get_node("main")
@onready var player = main.get_node("player")
@onready var map = main.get_node("map")

var unroundedbeat = 0
var beat = 0
var halfbeat = 0
var zpos = 15
var preplatpos = Vector3.ZERO
var started = false
var alternateplat = false
var curattacks = []
var timer = -1
var changedtex = false
var startdelay = 0.2
var wizarddown = 0
var hasgreenbeam = Steam.getAchievement("greenbeam")["achieved"]
var chal = "none"
var kickparticlehue = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	if chal != "pimpleremix": $"../music".stream = load("res://audio/music/musicbosswait.mp3")
	elif chal == "pimpleremix": $"../music".stream = load("res://audio/music/remixwait.mp3")
	$"../music".play()
	if chal == "pimpleremix":
		player.SPEED = 4
	elif chal == "timedwizard":
		player.SPEED = 5
	else:
		player.SPEED = 3.5
	
	player.candoublejump = true
	player.djseconds = 2
	
	if $"../".lilwizardtime != 1 && $"../".lilwizardtime != 0:
		var gun = load("res://dagger.tscn").instantiate()
		$"../player/camera/gun".add_child(gun)
		$"../player".scroll = 1
	
	if chal != "pimpleremix":
		preload("res://audio/music/musicbossmain.mp3")
		preload("res://audio/music/musicbosskicks.mp3")
		preload("res://audio/music/musicbossbassline.mp3")
		preload("res://audio/music/musicbossvariety.mp3")
		preload("res://audio/music/musicbosshats.mp3")
		preload("res://audio/music/musicbosswait.mp3")
		preload("res://audio/music/musicbossfinal.mp3")
		preload("res://audio/music/musicbossend.mp3")
	elif chal == "pimpleremix":
		preload("res://audio/music/remixmain.mp3")
		preload("res://audio/music/remixkicks.mp3")
		preload("res://audio/music/remixbassline.mp3")
		preload("res://audio/music/remixvariety.mp3")
		preload("res://audio/music/remixhats.mp3")
		preload("res://audio/music/remixwait.mp3")
		preload("res://audio/music/remixfinal.mp3")
		preload("res://audio/music/remixend.mp3")
	
	$wizard.get_surface_override_material(0).albedo_texture = load("res://characters/wizard.tres")
	
	if $"../".bitbags.has("3") || chal != "none":
		$bitpath.queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if wizarddown > 0:
		$wizard.position.y -= delta*wizarddown
		wizarddown += delta*10
	$particles.position = player.position
	if timer == -1:
		if diff == 0: timer = 30
		if diff == 1: timer = 50
		if diff == 2: timer = 65
		if chal == "timedwizard": timer = 500
	if startdelay > 0: startdelay -= delta
	if started:
		timer -= delta
		var wizardpos = zpos+timer*2
		if chal == "timedwizard": wizardpos = timer*2
		$wizard.position.z = (wizardpos+$wizard.position.z*99)/100
		$wizard.position.x = (preplatpos.x+$wizard.position.x*99)/100
		if chal == "timedwizard": $wizard.position.x = (player.position.x+$wizard.position.x*99)/100
		var beforebeat = beat
		unroundedbeat += delta*8
		beat = floor(unroundedbeat)
		halfbeat = floor(unroundedbeat*2)
		
		if beforebeat != beat:
			beatfunc()
			
	$wizard/particlepivot.look_at(player.position)
		
	if player.dead:
		if started:
			started = false
			$mainmusic.stop()
			$music0.stop()
			$music1.stop()
			$music2.stop()
			$music3.stop()
			$wizard.get_surface_override_material(0).albedo_texture = load("res://characters/wizard.tres")
	
	kickparticlehue += delta/5
	$wizard/particlepivot/kicks.process_material.color = Color.from_hsv(kickparticlehue, 1, 1)
		
func beatfunc():
	var thewhammy = 1
	if chal == "timedwizard": thewhammy = 2
	for guh in range(thewhammy):
		var plat = load("res://musicboss/musicplat.tscn").instantiate()
		if chal == "pimpleremix": plat = load("res://musicboss/remixmusicplat.tscn").instantiate()
		plat.position.z = zpos
		if !alternateplat:
			var disttozpos = zpos-player.position.z
			var dist = 100*(1/(disttozpos+4))
			plat.position.x = randf_range(preplatpos.x-dist, preplatpos.x+dist)
			preplatpos = plat.position
			alternateplat = true
		else:
			var mult = -1
			if randf() > 0.5: mult = 1
			plat.position.x = randf_range(preplatpos.x+4*mult, preplatpos.x+8*mult)
			if randf() > 0.5: preplatpos = plat.position
			alternateplat = false
			zpos += 3
			if chal != "pimpleremix":
				if fmod(beat, 32) == 0: zpos += 6
			elif chal == "pimpleremix":
				if fmod(beat, 16) == 0: zpos += 6
		if diff == 0: plat.timer = 15
		if diff == 1: plat.timer = 10
		if diff == 2: plat.timer = 8
		if chal == "pimpleremix": plat.timer = 15
		if chal == "timedwizard": plat.timer = 45
		
		add_child(plat)
	
	if !changedtex && startdelay <= 0:
		if $wizard.position.z-player.position.z <= 20:
			$wizard.get_surface_override_material(0).albedo_texture = load("res://characters/scaredwizard.tres")
			changedtex = true
	
	if ceil(beat/128) == 4 || (chal == "timedwizard" && ceil(beat/64) == 5):
		if chal != "pimpleremix":
			if $mainmusic.stream.resource_path.get_file() == "musicbossmain.mp3":
				var playtime = $mainmusic.get_playback_position()
				$mainmusic.stream = load("res://audio/music/musicbossfinal.mp3")
				$mainmusic.play()
				$mainmusic.seek(playtime)
		elif chal == "pimpleremix":
			if $mainmusic.stream.resource_path.get_file() == "remixmain.mp3":
				var playtime = $mainmusic.get_playback_position()
				$mainmusic.stream = load("res://audio/music/remixfinal.mp3")
				$mainmusic.play()
				$mainmusic.seek(playtime)
	
	if fmod(beat, 64) == 0:
		if chal == "timedwizard":
			if ceil(beat/64) <= 4: choosenewattack(ceil(beat/64))
			else: choosenewattack(4)
		else:
			if ceil(beat/128) <= 4: choosenewattack(ceil(beat/128))
			else: choosenewattack(4)
	if fmod(beat, 16) == 0:
		roundtoseconds($mainmusic, 2)
		roundtoseconds($music0, 2)
		roundtoseconds($music1, 2)
		roundtoseconds($music2, 2)
		roundtoseconds($music3, 2)
	if curattacks.has("kicks"):
		if chal != "pimpleremix":
			if fmod(beat, 16) == 0 || ($"../canvas/hud/timer".visible && $"../".timer <= 0):
				var theattack = load("res://musicboss/musicbeam.tscn").instantiate()
				if randf() > 0.2: theattack.position.y = 0
				else: theattack.position.y = 1.5
				theattack.position.z = player.position.z+13
				theattack.position.x = preplatpos.x+randf_range(-3, 3)
				theattack.rotation_degrees.y = randf_range(30, -30)
				if randf() > 0.5: theattack.rotation_degrees.y += 180
				if !hasgreenbeam:
					theattack.green = randi_range(1, 30)
					if theattack.green == 1:
						theattack.position.y = 1.5
						theattack.position.z = player.position.z+10
						theattack.position.x = preplatpos.x
						theattack.rotation_degrees.y = 0
				if($"../canvas/hud/timer".visible && $"../".timer <= 0):
					theattack.murder = true
				add_child(theattack)
		elif chal == "pimpleremix":
			if fmod(beat, 32) == 4 || fmod(beat, 32) == 18:
				var theattack = load("res://musicboss/musicbeam.tscn").instantiate()
				if randf() > 0.2: theattack.position.y = 0
				else: theattack.position.y = 1.5
				theattack.position.z = player.position.z+16
				theattack.position.x = preplatpos.x+randf_range(-3, 3)
				theattack.rotation_degrees.y = randf_range(30, -30)
				if randf() > 0.5: theattack.rotation_degrees.y += 180
				theattack.scale *= 1.5
				theattack.rotatemode = true
				add_child(theattack)
	if curattacks.has("bassline"):
		if chal != "pimpleremix":
			var times = [0, 3, 6, 8, 12, 15, 16, 18, 21, 24, 27, 28, 30, 32, 36, 39, 40, 42, 45, 48, 51, 54, 56, 58, 62, 63]
			for i in times:
				if fmod(beat, 64) == i:
					var theattack = load("res://musicboss/musicplatmover.tscn").instantiate()
					theattack.position.z = player.position.z+20
					theattack.position.x = preplatpos.x
					add_child(theattack)
		elif chal == "pimpleremix":
			if fmod(beat, 2) == 0 || fmod(halfbeat, 16) == 14 || fmod(halfbeat, 16) == 15:
				var theattack = load("res://musicboss/musicplatmover.tscn").instantiate()
				theattack.position.z = player.position.z+30
				theattack.position.x = preplatpos.x 
				var rand = randi_range(1, 20)
				if rand == 1:
					theattack.goup = 5
					theattack.position.z = player.position.z+20
				add_child(theattack)
	if curattacks.has("variety"):
		if chal != "pimpleremix":
			if fmod(beat, 64) != 0:
				if fmod(beat, 8) == 3:
						var theattack = load("res://musicboss/platbreaker.tscn").instantiate()
						theattack.position.z = player.position.z+25
						if zpos+10 < player.position.z+25:
							theattack.position.z = zpos+10
						theattack.position.x = preplatpos.x+randf_range(-10, 10)
						add_child(theattack)
		elif chal == "pimpleremix":
			if fmod(beat, 16) == 2 || fmod(beat, 16) == 8 || fmod(beat, 16) == 14:
				for guh in range(2):
					var theattack = load("res://musicboss/platbreaker.tscn").instantiate()
					theattack.position.z = player.position.z+50
					if zpos+20 < player.position.z+50:
							theattack.position.z = zpos+20
					theattack.position.x = preplatpos.x+randf_range(-10, 10)
					add_child(theattack)
	if curattacks.has("hats"):
		if chal != "pimpleremix":
			if fmod(beat, 16) != 6 && fmod(beat, 16) != 12 && fmod(beat, 64) != 62:
				if fmod(beat, 2) == 0:
					var theattack = load("res://musicboss/musictilebomb.tscn").instantiate()
					theattack.position.x = preplatpos.x
					theattack.position.z = preplatpos.z
					if fmod(beat, 16) == 0: theattack.timer = 0.75
					if fmod(beat, 16) == 2: theattack.timer = 0.5
					if fmod(beat, 16) == 4: theattack.timer = 0.25
					if fmod(beat, 16) == 8: theattack.timer = 0.5
					if fmod(beat, 16) == 10: theattack.timer = 0.25
					if fmod(beat, 16) == 14: theattack.timer = 1
					add_child(theattack)
		elif chal == "pimpleremix":
			var times = [0, 4, 6, 8, 16, 18, 20, 21, 22, 23]
			for i in times:
				if fmod(halfbeat, 32) == i:
					var theattack = load("res://musicboss/musictilebomb.tscn").instantiate()
					theattack.position.x = preplatpos.x
					theattack.position.z = preplatpos.z
					if fmod(halfbeat, 32) < 16: theattack.timer = 0.75-(fmod(halfbeat, 16)*.0625)
					else: theattack.timer = 0.5-(fmod(halfbeat, 16)*.0625)
					add_child(theattack)
func roundtoseconds(audio, sec):
	if audio.is_playing():
		var playback = audio.get_playback_position()
		audio.seek(round(playback/sec)*sec)
		
func particles(command):
	if command == "stop":
		$wizard/particlepivot/kicks.emitting = false
		$wizard/particlepivot/kicks2.emitting = false
		$wizard/particlepivot/hats.emitting = false
		$wizard/particlepivot/hats2.emitting = false
		$wizard/particlepivot/variety.emitting = false
		$wizard/particlepivot/variety2.emitting = false
		$wizard/particlepivot/bassline.emitting = false
		$wizard/particlepivot/bassline2.emitting = false
		
	if command == "kicks":
		$wizard/particlepivot/kicks.emitting = true
		$wizard/particlepivot/kicks2.emitting = true
	if command == "hats":
		$wizard/particlepivot/hats.emitting = true
		$wizard/particlepivot/hats2.emitting = true
	if command == "variety":
		$wizard/particlepivot/variety.emitting = true
		$wizard/particlepivot/variety2.emitting = true
	if command == "bassline":
		$wizard/particlepivot/bassline.emitting = true
		$wizard/particlepivot/bassline2.emitting = true

func choosenewattack(amount):
	particles("stop")
	
	curattacks = []
	var attacks = ["hats", "kicks", "variety", "bassline"]
	
	for i in range(amount):
		var attacknum = randi_range(0, attacks.size()-1)
		var attack = attacks[attacknum]
		curattacks.append(attacks[attacknum])
		attacks.remove_at(attacknum)
		
		var audio = $music0
		if i == 1: audio = $music1
		if i == 2: audio = $music2
		if i == 3: audio = $music3
		
		if chal != "pimpleremix":
			audio.stream = load("res://audio/music/musicboss"+attack+".mp3")
			audio.play()
		elif chal == "pimpleremix":
			audio.stream = load("res://audio/music/remix"+attack+".mp3")
			audio.play()
			
		particles(attack)


func _on_startarea_body_entered(body):
	if $"../".lilwizardtime != 1 && $"../".lilwizardtime != 0 && startdelay <= 0:
		if body.is_in_group("playergroup"):
			if !body.dead:
				if !started && beat <= 0:
					started = true
					if chal != "pimpleremix": $mainmusic.stream = load("res://audio/music/musicbossmain.mp3")
					elif chal == "pimpleremix": $mainmusic.stream = load("res://audio/music/remixmain.mp3")
					$mainmusic.play()
					$"../music".stop()
					if !$"../".bitbags.has("3") && chal == "none":
						$bitpath/anim.play("start")
					if chal == "timedwizard":
						$"../".timer = 48
						$"../canvas/hud/timer".show()

func _on_wizardarea_body_entered(body):
	if body.is_in_group("playergroup"):
		if !body.dead:
			if beat > 16:
				if started:
					started = false
					$music0.stop()
					$music1.stop()
					$music2.stop()
					$music3.stop()
					particles("stop")
					if chal != "pimpleremix": $mainmusic.stream = load("res://audio/music/musicbossend.mp3")
					if chal == "pimpleremix": $mainmusic.stream = load("res://audio/music/remixend.mp3")
					$mainmusic.play()
					$"../canvas/hud/timer".hide()
					$platform.position.x = player.position.x
					$platform.position.z = player.position.z
					$wizard/Armature.show()
					$wizard/Armature/AnimationPlayer.play("flipstab")
					$wizard/AnimationPlayer.play("kill")
					
					var loadoutfit = load($"../".outfit).instantiate()
					for child in $wizard/Armature/Skeleton3D/headbone/attachments.get_children():
						child.queue_free()
					if loadoutfit.has_node("Armature/Skeleton3D/head"):
						var headattachments = loadoutfit.get_node("Armature/Skeleton3D/head")
						for child in headattachments.get_children():
							child.reparent($wizard/Armature/Skeleton3D/headbone/attachments)
							child.position = headattachments.position
							child.rotation = headattachments.rotation-$wizard/Armature/Skeleton3D/headbone.rotation
							child.scale = headattachments.scalev
					var mainbody = loadoutfit.get_node("Armature/Skeleton3D/main")
					$wizard/Armature/Skeleton3D/Cube.name = "deletebody"
					$wizard/Armature/Skeleton3D/deletebody.queue_free()
					mainbody.reparent($wizard/Armature/Skeleton3D)
					mainbody.position = Vector3.ZERO
					mainbody.rotation = Vector3.ZERO
					mainbody.name = "Cube"
					if $"../".outfitcolors.has($"../".outfit):
						if mainbody.has_meta("extracolors"):
							for i in range(1, mainbody.get_meta("extracolors")+1):
								var curcolorrgb = $"../".outfitcolors[$"../".outfit][str(i)]
								var curcolor = Color(curcolorrgb["r"], curcolorrgb["g"], curcolorrgb["b"])
								mainbody.get_surface_override_material(i).albedo_color = curcolor
					
					$wizard/Armature/Skeleton3D/Cube.get_surface_override_material(0).albedo_color = $"../".bodycolor
					
					var loadhead = load($"../".head).instantiate()
					$wizard/Armature/Skeleton3D/headbone/offset.add_child(loadhead)
					player.position = $wizard/putplayerhere.global_position
					player.velocity = Vector3.ZERO
					$wizard/killcam.current = true
					for gun in $"../player/camera/gun".get_children():
						if !gun.has_meta("held"):
							gun.queue_free
					for child in get_children():
						if child.is_in_group("musicplatparent"):
							child._on_timer_timeout()

func _on_animation_player_animation_finished(anim_name):
	player.camera.current = true
	wizarddown = 0.1
	$"../".spawnlobbyportal()
	if chal == "none":
		var earnedbits = $"../".calcbits(diff, $"../".beatwizard, 1)
		$"../".bits += earnedbits
		if diff == 2:
			$"../".setAchievement("pimplepopper")
			if player.health >= 100: $"../".setAchievement("100")
		if earnedbits > 0:
			var popup = load("res://popup.tscn").instantiate()
			popup.bits = earnedbits
			$"../sfx".stream = load("res://audio/gainbits.mp3")
			if diff == 2 && !$"../".unlockedheads.has("wizardhat"):
				popup.cosmetic = true
				$"../".unlockedheads.append("wizardhat")
				$"../sfx".stream = load("res://audio/gaincosmetic.mp3")
			$"../sfx".play()
			$"../canvas/hud".add_child(popup)
		if diff == 1:
			if ceil(beat/128) < 4:
				$"../".setAchievement("potionofswiftness")
				if !$"../../".beatchallenges.has("potionofswiftness"):
					$"../../".beatchallenges["potionofswiftness"] = true
					var popup = load("res://popup.tscn").instantiate()
					popup.bits = $"../../".getchalbits("potionofswiftness")
					$"../../".bits += $"../../".getchalbits("potionofswiftness")
					$"../../sfx".stream = load("res://audio/gainbits.mp3")
					$"../../sfx".play()
					$"../../canvas/hud".add_child(popup)
					
		if diff > $"../".beatwizard: $"../".beatwizard = diff
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
