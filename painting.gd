extends StaticBody3D
var showoutline = true
@onready var camera = $camera
@onready var pos = $camera.global_position
@onready var rot = $camera.global_rotation
var camtween = 0
var spos = Vector3.ZERO
var srot = Vector3.ZERO
var hover = false
var hovereasy = false
var hovermedium = false
var hoverhard = false
var map = ""
var diff = 1
var ticks = -1

func settexture(texture):
	$painting.get_surface_override_material(1).albedo_texture = load(texture)
	$painting.get_surface_override_material(1).next_pass.albedo_texture = load(texture)
	
# Called when the node enters the scene tree for the first time.
func _ready():
	
	var dupe = $painting.get_surface_override_material(1).duplicate()
	$painting.set_surface_override_material(1, dupe)
	var dupebright = dupe.next_pass.duplicate()
	dupe.next_pass = dupebright
	var dupebrush = $brush.get_surface_override_material(0).duplicate()
	$brush.set_surface_override_material(0, dupebrush)
	var dupechal = $painting/challenge.get_surface_override_material(0).duplicate()
	$painting/challenge.set_surface_override_material(0, dupechal)
	var dupechalbright = dupechal.next_pass.duplicate()
	dupechal.next_pass = dupechalbright
	var painting = name
	if has_meta("nameoverride"):
		painting = get_meta("nameoverride")
	if painting == "elevatorpainting":
		map = "elevatorarena"
		settexture("res://paintings/elevatorpainting.png")
		ticks = $"../../".beatelevator
	if painting == "catpainting":
		map = "catarena"
		settexture("res://paintings/catpainting.png")
		ticks = $"../../".beatcat
	if painting == "wizardpainting":
		map = "musicboss"
		ticks = $"../../".beatwizard
		settexture("res://paintings/wizardpainting.png")
	if painting == "gunmanpainting":
		map = "gunmanarena"
		ticks = $"../../".beatgunman
		settexture("res://paintings/gunmanpainting.png")
	if painting == "spacepainting":
		map = "spaceboss"
		ticks = 0
		settexture("res://paintings/wippainting.png")
	if painting == "sodapainting":
		map = "sodaboss"
		ticks = $"../../".beatsoda
		settexture("res://paintings/sodapainting.png")
	if painting == "horrorpainting":
		map = "horrorbossarena"
		ticks = $"../../".beathorror
		settexture("res://paintings/horrorpainting.png")
	if painting == "spleefpainting":
		map = "spleefarena"
		ticks = $"../../".beatspleef
		settexture("res://paintings/spleefpainting.png")
	if painting == "lubelordpainting":
		map = "lubelordarena"
		ticks = 0
		settexture("res://paintings/wippainting.png")
	if has_meta("challenge"):
		if ticks <= 0: #easy or less
			queue_free()
		$painting/challenge.get_surface_override_material(0).albedo_texture = load("res://paintings/"+get_meta("challenge")+".png")
		$painting/challenge.get_surface_override_material(0).next_pass.albedo_texture = load("res://paintings/"+get_meta("challenge")+".png")
		$painting/chalbits.show()
		$subview/bits.text = str($"../../".getchalbits(get_meta("challenge")))
		$subview/bits/bitsoffset/bitssprite.position.x = $subview/bits.get_total_character_count()*40
		if $"../../".beatchallenges.has(get_meta("challenge")):
			$subview/bits.self_modulate = Color.GREEN
			$painting/chal.show()
	if !has_meta("diffoverride"):
		if ticks >= 0: $painting/easy.show()
		if ticks >= 1: $painting/medium.show()
		if ticks >= 2: $painting/hard.show()
	else:
		$brush.hide()
		$palette.hide()
		$palette/StaticBody3D/CollisionShape3D.disabled = true
		$palette/easy/easy/CollisionShape3D2.disabled = true
		$palette/medium/medium/CollisionShape3D2.disabled = true
		$palette/hard/hard/CollisionShape3D2.disabled = true
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !showoutline:
		if camtween < PI/2:
			camtween += delta*(PI/2)
		var ct = sin(camtween)
		camera.global_position = Vector3(spos.x*(1-ct)+pos.x*ct, spos.y*(1-ct)+pos.y*ct, spos.z*(1-ct)+pos.z*ct)
		if $AnimationPlayer.current_animation != "secret" && $AnimationPlayer.is_playing():
			camera.global_rotation.x = lerp_angle(camera.global_rotation.x, rot.x, 4*delta)
			camera.global_rotation.y = lerp_angle(camera.global_rotation.y, rot.y, 4*delta)
			camera.global_rotation.z = lerp_angle(camera.global_rotation.z, rot.z, 4*delta)
		
	if showoutline:
		$outline.visible = hover
		hover = false
		$palette/easy/outline.visible = hovereasy
		hovereasy = false
		$palette/medium/outline.visible = hovermedium
		hovermedium = false
		$palette/hard/outline.visible = hoverhard
		hoverhard = false
	else:
		$outline.hide()
		$palette/easy/outline.hide()
		$palette/medium/outline.hide()
		$palette/hard/outline.hide()
		
func diffselect(the):
	if !$AnimationPlayer.is_playing():
		var beforediff = diff
		if the == "easy": diff = 0
		if the == "medium": diff = 1
		if the == "hard": diff = 2
		if beforediff != diff:
			$AnimationPlayer.play("select")
			var tempaudio = load("res://tempaudio.tscn").instantiate()
			add_child(tempaudio)
			if diff == 0: tempaudio.stream = load("res://audio/easy.mp3")
			if diff == 1: tempaudio.stream = load("res://audio/medium.mp3")
			if diff == 2: tempaudio.stream = load("res://audio/hard.mp3")
			tempaudio.play()

func changebrush():
	if diff == 0:
		$brush.get_surface_override_material(0).albedo_color = Color("2dc22d")
	if diff == 1:
		$brush.get_surface_override_material(0).albedo_color = Color("c2a62d")
	if diff == 2:
		$brush.get_surface_override_material(0).albedo_color = Color("c22d2d")
	
func playanim():
	showoutline = false
	camera.current = true
	camera.global_rotation = srot
	$"../../".transitionmusic("none", 2)
	if map != "horrorbossarena":
		if randf() <= 0.1 && $palette.visible:
			$AnimationPlayer.play("secret")
		else:
			$AnimationPlayer.play("default")
	else:
		$AnimationPlayer.play("horror")
		var tempaudio = load("res://tempaudio.tscn").instantiate()
		add_child(tempaudio)
		tempaudio.stream = load("res://audio/horror/horrorpainting.mp3")
		tempaudio.play()
	
func _on_animation_player_animation_finished(anim_name):
	if anim_name != "select":
		$"../../canvas/hud/transitionin".play()
		$"../../".transition = ["loadmap", "res://maps/"+map+".tscn", diff]
		if has_meta("challenge"):
			$"../../".transition.append(get_meta("challenge"))
			if get_meta("challenge") == "pimpleremix": $"../../".transition[1] = "res://maps/remixmusicboss.tscn"
		if has_meta("diffoverride"): $"../../".transition[2] = get_meta("diffoverride")
		
		$"../../".transitionfunc($"../../".transition)
