extends StaticBody3D

var boinging = 0

func _process(delta):
	if has_meta("boinging"):
		boinging += delta*1.5
		position.y = 1+sin(boinging)*20
		if sin(boinging) < 0:
			boinging = 0
			get_parent().playanim()
	for body in $fuckukevin.get_overlapping_bodies():
		if body.is_in_group("playergroup"):
			if body.velocity.y > 30:
				body.velocity.y = 30

func _ready():
	if has_meta("boinging"): boinging = get_meta("boinging")
	if $mesh.get_surface_override_material(0).albedo_color == Color.WHITE:
		var dupe = $mesh.get_surface_override_material(0).duplicate()
		$mesh.set_surface_override_material(0, dupe)
		
		$mesh.get_surface_override_material(0).albedo_color = Color.from_hsv(randf_range(0.333, 0.666), 0.5, 1)
	elif name == "boingtard":
		if $"../../".deadboing:
			$CollisionShape3D.disabled = true
			$mesh.get_surface_override_material(0).albedo_texture = load("res://characters/boingdead.png")
func _on_area_body_entered(body):
	if body.is_in_group("playergroup"):
		if name != "boingtard":
			body.velocity.y = 30
			body.position.y += 1
			body.doublejump = 1
			if has_meta("boingchallenge"):
				if $"../".boingchallenge == get_meta("boingchallenge") || $"../".boingchallenge-1 == get_meta("boingchallenge"):
					$"../".setboingchallenge(get_meta("boingchallenge")+1)
				else:
					$"../".setboingchallenge(0)
					print("lostchallengeboing")
			playanim()
		else:
			if !$"../../".deadboing:
				$mesh.get_surface_override_material(0).albedo_texture = load("res://characters/boingdead.png")
				$audio.play()
				$CollisionShape3D.disabled = true
				$CollisionShape3D.queue_free()
				$"../../".deadboing = true
				$"../../".save_game()
				
func playanim():
	$mesh.get_surface_override_material(0).albedo_texture = load("res://characters/boingboing.tres")
	$mesh.get_surface_override_material(0).albedo_texture.current_frame = 0
	$audio.play()
	$Timer.start()
		
func _on_timer_timeout():
	$mesh.get_surface_override_material(0).albedo_texture = load("res://characters/boingidle.tres")
	$mesh.get_surface_override_material(0).albedo_texture.current_frame = 0
