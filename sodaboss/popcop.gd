extends CharacterBody3D

@onready var main = get_node("/root").get_node("main")
@onready var player = main.get_node("player")
@onready var map = main.get_node("map")

@onready var eyes = $Armature/Skeleton3D/eyes

var sawplayer = false
var speed = 12

var dead = false

func _ready() -> void:
	if map.diff <= 1:
		speed = 8

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !dead:
		var dist = sqrt(pow(global_position.x-player.position.x, 2)+pow(global_position.y-player.position.y, 2)+pow(global_position.z-player.position.z, 2))
		var direction = Vector2(player.position.x-global_position.x, player.position.z-global_position.z).normalized()
		if sawplayer:
			global_rotation.y = atan2(-direction.x, -direction.y)
			scale = Vector3.ONE*0.5
		$playerdetect.look_at(Vector3(player.position.x, player.position.y+0.5, player.position.z))
		
		if $smacked.is_stopped():
			if $anim.current_animation != "attack":
				for body in $damage.get_overlapping_bodies():
					if body.is_in_group("playergroup"):
						if $anim.current_animation != "attack" || !$anim.is_playing():
							$anim.play("attack")
							$audio.stream = load("res://audio/popcophit.wav")
							$audio.play()
		
		if !is_on_floor():
			velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity")*delta
		elif $smacked.is_stopped():
			if !sawplayer:
				if $anim.current_animation != "idle" || !$anim.is_playing():
						$anim.play("idle")
				if $playerdetect.is_colliding() && dist <= 25:
					if $playerdetect.get_collider() == player:
						sawplayer = true
			else:
				velocity.x = 0
				velocity.z = 0
				if $anim.current_animation == "attack":
					pass
				else:
					if $anim.current_animation != "walk" || !$anim.is_playing():
						$anim.play("walk")
						$audio.stream = load("res://audio/popcopwalk.tres")
						$audio.play()
					velocity.x = direction.x*speed
					velocity.z = direction.y*speed
					
		if !$smacked.is_stopped():
			if is_on_wall_only():
				die()
					
		move_and_slide()
		
func damage():
	for body in $damage.get_overlapping_bodies():
		if body.is_in_group("playergroup"):
			if map.diff == 0:
				body.hurt(3, "ragdoll")
			else:
				body.hurt(5, "ragdoll")
		
func die():
	if !dead:
		$anim.play("death")
		$audio.stream = load("res://audio/popcopbreak.wav")
		$audio.play()
		$CollisionShape3D.disabled = true
		dead = true
			
func smack(side, strength = 15):
	var direction = Vector2(player.position.x-global_position.x, player.position.z-global_position.z).normalized()

	velocity.x = 0
	velocity.z = 0
	if side == "left":
		velocity.x += (-direction.y-direction.x/2)*strength
		velocity.z += (direction.x-direction.y/2)*strength
	if side == "right":
		velocity.x += (direction.y-direction.x/2)*strength
		velocity.z += (-direction.x-direction.y/2)*strength
	if side == "center":
		velocity.x += (-direction.x)*strength
		velocity.z += (-direction.y)*strength
	$audio.stop()
	$anim.play("hit")
	velocity.y += strength/2
	$smacked.start()

func _on_anim_animation_finished(anim_name):
	if anim_name == "death":
		queue_free()
