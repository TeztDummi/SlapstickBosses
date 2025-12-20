extends Node3D

@onready var main = get_node("/root").get_node("main")
@onready var player = main.get_node("player")
@onready var map = main.get_node("map")

var diff = 0
var chal = "none"
var level = 1
var revivelist = []
var hurtlist = []
var heatwave = false
var filllevel = false
var lastmusictick = 0
var beat = (120.0/140.0)
var diddoublejump = false

func _ready() -> void:
	var gun = load("res://laserpointer.tscn").instantiate()
	$"../player/camera/gun".add_child(gun)
	$"../player".scroll = 1
	
	$"../player".candoublejump = true
	if diff == 0: $"../player".djseconds = 3
	if diff == 1: $"../player".djseconds = 6
	if diff == 2: $"../player".djseconds = 14
	
	if diff == 0: $spleefboss.setattack(8)
	if diff == 1: $spleefboss.setattack(4)
	if diff == 2: $spleefboss.setattack(3)
	
	$"../music".stop()
	
	$lavaanim.play("RESET")
	
	$heatwaveanim.play("RESET")
	
	if $"../".restarted != 1 && chal == "none":
		$Armature.show()
		$cutscene.play("start")
		$spleefboss.hide()
		$campivot/camera.current = true
	else:
		_on_cutscene_animation_finished("start")
	
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
	
func dodafreeze():
	$spleefboss.freezeattack()
	$"../".transitionmusic("res://audio/music/coldspleef.mp3", 0.85, false)
	
func endbreak():
	$anim.playfps("breakchain", 12)
	$stoneplataudio.play()

func _on_anim_animation_finished(anim_name: StringName) -> void:
	if anim_name == "breakchain":
		$spleefboss.move = true
		$anim.playfps("sink", 8)
	if anim_name == "sink":
		$stoneplat.queue_free()
	if anim_name == "jumptolevel2":
		$spleefboss.move = true
		$spleefboss.lasergoup = false
		$"../".transitionmusic("res://audio/music/coldspleef.mp3", 0.85, false)
	if anim_name == "jumptolevel3":
		$spleefboss.move = true
		$spleefboss.lasergoup = false
		$spleefboss.dosuperice = true
		$"../".transitionmusic("res://audio/music/coldspleef.mp3", 0.85, false)
		
func _process(delta: float) -> void:
	if diff == 2:
		if !diddoublejump:
			if player.doublejump != 1:
				diddoublejump = true
	if chal == "musicspleef" && revivelist.size() == 0 && level < 4 && !player.dead:
		var pos = $"../music".get_playback_position()
		if pos < lastmusictick:
			lastmusictick = 0
		var tick = floor(pos/(4*beat))*(4*beat)
		var warntick = floor((pos+2*beat)/(4*beat))*(4*beat)-2*beat
		
		if lastmusictick < warntick:
			lastmusictick = warntick
			if $musicspleef.volume_linear >= 0.5:
				for block in get_node("level"+str(level)).get_children():
					if !block.ice:
						block.warning()
		if lastmusictick < tick:
			lastmusictick = tick
			if $musicspleef.volume_linear < 0.5:
				$musicspleef.volume_linear = 1
			else:
				print("tick: "+str(tick))
				for block in get_node("level"+str(level)).get_children():
					if !block.ice:
						if block.health <= 0:
							block.revive()
						else:
							block.hurt(false)
	else:
		$musicspleef.volume_linear = 0
func nextlevel():
	if level < 4:
		level += 1
	if level < 4:
		revivelist = get_node("level"+str(level)).get_children()
		hurtlist = get_node("level"+str(level-1)).get_children()
		$revivetimer.start()
		filllevel = false
	
func levelgroup():
	return get_node("level"+str(level))

func _on_lavaarea_area_entered(area: Area3D) -> void:
	#print("eneterd lava: "+str(area))
	if area.name == "lavacheck":
		var splash = load("res://spleef/lavaparticles.tscn").instantiate()
		splash.position = area.global_position
		#splash.position.y = $lava.position.y
		add_child(splash)
		if area.get_parent().is_in_group("spleefboss"):
			area.get_parent().fallinlava()
		if area.get_parent().is_in_group("playergroup"):
			area.get_parent().hurt(100, "lava")
			
func toggleicecloud(val):
	if chal == "icecloud":
		$icecloud.visible = val

func _on_revivetimer_timeout() -> void:
	if level <= 4:
		if player.position.y >= get_node("level"+str(level)).position.y:
			filllevel = true
		if filllevel:
			if revivelist.size() > 0:
				var randid = randi_range(0, revivelist.size()-1)
				var block = revivelist.pop_at(randid)
				if !block.is_in_group("bossrevives"):
					block.revive()
			if hurtlist.size() > 0:
				var randid2 = randi_range(0, hurtlist.size()-1)
				hurtlist.pop_at(randid2).hurt(false)
			if hurtlist.size() <= 0 && revivelist.size() <= 0:
				print("WE SHOULD BE RISING RN!!!")
				print(level)
				if level == 2:
					$revivetimer.stop()
					$spleefboss.move = false
					$spleefboss.vulnerable = false
					if diff == 0: $spleefboss.setattack(8)
					if diff == 1: $spleefboss.setattack(3)
					if diff == 2: $spleefboss.setattack(2)
					$spleefboss.position.x = 0
					$spleefboss.position.z = 0
					$spleefboss.lasergoup = true
					$spleefboss.dominions = true
					$lavaanim.play("level2")
					toggleicecloud(true)
				if level == 3:
					$revivetimer.stop()
					$spleefboss.move = false
					$spleefboss.vulnerable = false
					if diff == 0: $spleefboss.setattack(6)
					if diff == 1: $spleefboss.setattack(4)
					if diff == 2: $spleefboss.setattack(3)
					$spleefboss.position.x = 0
					$spleefboss.position.z = 0
					$spleefboss.lasergoup = true
					$lavaanim.play("level3")
					#startheatwavetimer()
					$heatwavestarttimer.start()
					toggleicecloud(true)
			
func _on_lavaanim_animation_finished(anim_name: StringName) -> void:
	print("lavafinished")
	if anim_name == "level2":
		$anim.playfps("jumptolevel2")
		$spleefboss/jumpaudio.play()
	if anim_name == "level3":
		$anim.playfps("jumptolevel3")
		$spleefboss/jumpaudio.play()
		$heatwavestarttimer.stop()
		$heatwavestarttimer.one_shot = true

func setheatwave(val):
	heatwave = val
	if val:
		$spleefboss.setsuper(false)
		
func checkfloorplan():
	if diff >= 1 && chal == "none":
		var alive = 0.0
		for block in get_node("level"+str(level)).get_children():
			if block.health > 0:
				alive += 1
		alive /= get_node("level"+str(level)).get_child_count()
		print("alive percentage: ")
		print(alive)
		if alive >= 0.8:
			$"../".setAchievement("openfloorplan")
		
func win():
	$"../".spawnlobbyportal($portalpos.position)
	$campivot/camera.set_meta("showhud", true)
	$"../canvas/hud".show()
	if chal == "none":
		var earnedbits = $"../".calcbits(diff, $"../".beatspleef, 1)
		$"../".bits += earnedbits
		if diff == 2:
			$"../".setAchievement("chillthekiln")
			if player.health >= 100: $"../".setAchievement("100")
		if earnedbits > 0:
			var popup = load("res://popup.tscn").instantiate()
			popup.bits = earnedbits
			$"../sfx".stream = load("res://audio/gainbits.mp3")
			if diff == 2 && !$"../".unlockedheads.has("rustychiln"):
				popup.cosmetic = true
				$"../".unlockedheads.append("rustychiln")
				$"../sfx".stream = load("res://audio/gaincosmetic.mp3")
			$"../sfx".play()
			$"../canvas/hud".add_child(popup)
		if diff > $"../".beatspleef: $"../".beatspleef = diff
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

	
func startheatwavetimer():
	$heatwavestarttimer.start()
	$"../".transitionmusic("res://audio/music/hotspleef.mp3", 0.425, false)
	print("started heatwave timer")


func _on_heatwavetimer_timeout() -> void:
	if heatwave:
		$heatwaveray.position.x = round(((player.position.x-1)/2.0)*2)+1
		$heatwaveray.position.z = round(((player.position.z-1)/2.0)*2)+1
		$heatwaveray.position.y = player.position.y-10
		if $heatwaveray.is_colliding():
			if $heatwaveray.get_collider().is_in_group("playergroup"):
				if chal != "icecloud":
					$heatwaveray.get_collider().hurt(2, "lasernopile")
				else:
					$heatwaveray.get_collider().hurt(1, "lasernopile")

func _on_heatwavestarttimer_timeout() -> void:
	$heatwaveanim.play("heatwave")
	$heatwaveaudio.play()
	print("did heatwave")

func _on_cutscene_animation_finished(anim_name: StringName) -> void:
	if anim_name == "start":
		$cutsceneboss.hide()
		$Armature.hide()
		$chains.show()
		$spleefboss.show()
		$campivot/bg.hide()
		player.camera.current = true
		$spleefboss.start()
		$"../music".stream = load("res://audio/music/hotspleef.mp3")
		$"../music".play()
		if chal == "musicspleef":
			$musicspleef.play()
			for i in range(4):
				var bomb = load("res://spleef/spleefbomb.tscn").instantiate()
				bomb.position.z = 9
				bomb.position.x = 9-i*6
				bomb.position.y = 5+i/2.0
				add_child(bomb)
				bomb.turn()
		if chal == "icecloud":
			var icecloud = load("res://spleef/icecloud.tscn").instantiate()
			icecloud.position = $icecloudspot.position
			add_child(icecloud)
	if anim_name == "end":
		get_node("lobbyportal").do()
		
func end():
	$cutscene.play("RESET")
	$cutscene.play("end")
	$Armature.show()
	$spleefboss.hide()
	$cutsceneboss.show()
	$heatwave.hide()
	$spleefboss.get_node("attack").stop()
	$spleefboss.get_node("main/fallaudio").stop()
	$campivot/camera.current = true
	$"../music".stop()
	if chal == "musicspleef":
		$musicspleef.stop()
		
func checkdoublejump():
	if diff == 2 && chal == "none":
		if !diddoublejump:
			$"../".setAchievement("groundedindividual")
			if !$"../".beatchallenges.has("groundedindividual"):
				$"../".beatchallenges["groundedindividual"] = true
				var popup = load("res://popup.tscn").instantiate()
				popup.bits = $"../".getchalbits("groundedindividual")
				$"../".bits += $"../".getchalbits("groundedindividual")
				$"../sfx".stream = load("res://audio/gainbits.mp3")
				$"../sfx".play()
				$"../canvas/hud".add_child(popup)
		
func filllevel4():
	#level += 1
	revivelist = get_node("level"+str(4)).get_children()
	hurtlist = get_node("level"+str(3)).get_children()
	$revivetimer.start()
	filllevel = true
