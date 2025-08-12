extends CharacterBody3D

@onready var main = get_node("/root").get_node("main")
@onready var player = main.get_node("player")
@onready var map = main.get_node("map")

var sawplayer = false
var speed = 20

var moving = false

var dead = false

var randomoff = 0

var healthcan = false
var startsee = false

var warningtime = 0

# Called when the node enters the scene tree for the first time.
func _ready():
		
	if randf() <= 0.15 || has_meta("healthcan"):
		var dupe = $can.get_surface_override_material(0).duplicate()
		$can.set_surface_override_material(0, dupe)
		dupe.albedo_texture = load("res://healthcantexture.png")
		healthcan = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !dead:
		var dist = sqrt(pow(global_position.x-player.position.x, 2)+pow(global_position.y-player.position.y, 2)+pow(global_position.z-player.position.z, 2))
		var direction = Vector2((player.position.x+sin(randomoff)*2)-global_position.x, (player.position.z+cos(randomoff)*2)-global_position.z).normalized()
		if !sawplayer:
			if !startsee:
				if $playerdetect.is_colliding():
					if ($playerdetect.get_collider() == player && dist <= 40):
						sawplayer = true
						$anim.play("attack")
						$audio.stream = load("res://audio/cannotice.mp3")
						$audio.play()
			else:
				print("GO")
				sawplayer = true
				$anim.play("attack")
		else:
			if is_on_floor():
				if $jumpoverwalls.is_colliding():
					if !$jumpoverwalls.is_in_group("popcop") && !$jumpoverwalls.is_in_group("sodacan") && !$jumpoverwalls.is_in_group("playergroup"):
						#if velocity.y < 8:
							#velocity.y = 15
						pass
				
		$jumpoverwalls.look_at(Vector3(player.position.x, player.position.y, player.position.z))
		$playerdetect.look_at(Vector3(player.position.x, player.position.y+0.5, player.position.z))
		
		if !is_on_floor() && !$CollisionShape3D.disabled:
			velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity")*delta
		if is_on_floor():
			velocity.x *= 1-(delta*0.75)
			velocity.z *= 1-(delta*0.75)
		if moving:
			global_rotation.y = atan2(-velocity.normalized().x, -velocity.normalized().z)
			
			if is_on_floor():
				velocity.x += direction.x*speed*delta
				velocity.z += direction.y*speed*delta
			var totalvel = sqrt(pow(velocity.x, 2)+pow(velocity.z, 2))
			
			$can.rotation.x -= 2*PI*delta*totalvel*0.5
			
			
			#2 sec in future??
			#var playerfuture = Vector2(player.position.x+player.velocity.x*2, player.position.z+player.velocity.z*2)
			#var canfuture = Vector2(global_position.x+velocity.x*2, global_position.z+velocity.z*2)
			
			#$playerfuture.global_position = Vector3(playerfuture.x, player.position.y, playerfuture.y)
			#$canfuture.global_position = Vector3(canfuture.x, player.position.y, canfuture.y)
			#var futuredist = sqrt(pow(canfuture.x-playerfuture.x, 2)+pow(canfuture.y-playerfuture.y, 2))
			
			#var disttofuture = sqrt(pow(global_position.x-canfuture.x, 2)+pow(global_position.z-canfuture.y, 2))
			#var disttoplayer = sqrt(pow(global_position.x-player.position.x, 2)+pow(global_position.z-player.position.z, 2))
			
			#var playerfuturediff = disttofuture-disttoplayer
			
			if warningtime < 0: warningtime = 0
			
			if (dist <= 14) && is_on_floor() && (totalvel > 12 || dist < 2):
				if $playerinfront.get_overlapping_bodies().size() >= 1 || dist <= 0.5:
					if warningtime >= 0.6:
						velocity.y += 10 
						$explosiontimer.start()
						print("can be jumpin")
						$audio.stream = load("res://audio/canjump.mp3")
						$audio.play()
					else:
						if !$audio.stream.resource_path.get_file() == "canwarning.mp3":
							$audio.stream = load("res://audio/canwarning.mp3")
							$audio.play()
						warningtime += delta
			elif (dist <= 2) && is_on_floor():
				#velocity.y += randf_range(3, 5)
				if !$audio.stream.resource_path.get_file() == "canroll.mp3" && !$audio.stream.resource_path.get_file() == "canjump.mp3":
					$audio.stream = load("res://audio/canroll.mp3")
					$audio.play()
				warningtime -= delta
			else:
				if !$audio.stream.resource_path.get_file() == "canroll.mp3" && !$audio.stream.resource_path.get_file() == "canjump.mp3":
					$audio.stream = load("res://audio/canroll.mp3")
					$audio.play()
				warningtime -= delta
					
		move_and_slide()

func _on_anim_animation_finished(anim_name):
	if anim_name == "attack" || anim_name == "quickattack":
		moving = true
		$audio.stream = load("res://audio/canroll.mp3")
		$audio.play()
		
func explode(crushsound):
	if $can.visible:
		for body in $explosion.get_overlapping_bodies():
			if body.is_in_group("playergroup"):
				if !healthcan:
					if map.diff == 0:
						body.hurt(4, "ragdoll")
					else:
						body.hurt(7, "ragdoll")
				else:
					body.heal(20)
		$anim.play("burst")
		if !healthcan:
			$particleshealth.hide()
			$"2particlehealth".hide()
		else:
			$particles.hide()
			$"2particle".hide()
		moving = false
		$can.hide()
		$CollisionShape3D.disabled = true
		if crushsound:
			$audio.stream = load("res://audio/cancrush.mp3")
			$audio.play()

func _on_explosiontimer_timeout() -> void:
	explode(false)

func _on_particles_finished() -> void:
	queue_free()


func _on_randomoff_timeout() -> void:
	randomoff = randf_range(0, 2*PI)
