extends CharacterBody3D

@onready var main = get_node("/root").get_node("main")
@onready var player = main.get_node("player")
@onready var map = main.get_node("map")

@onready var eyes = $Armature/Skeleton3D/eyes

var sawplayer = false
var speed = 50
var dashspeed = 6
var previousspeed = 0

var dead = false

func _ready() -> void:
	if map.diff <= 1:
		speed = 40
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !dead:
		$dasheffect.transparency = clamp(1-((sqrt(pow(velocity.x, 2)+pow(velocity.z, 2))-dashspeed)/dashspeed), 0, 1)
		$dasheffect.rotate_z(sqrt(pow(velocity.x, 2)+pow(velocity.z, 2))*delta*2)
		var dist = sqrt(pow(global_position.x-player.position.x, 2)+pow(global_position.y-player.position.y, 2)+pow(global_position.z-player.position.z, 2))
		var curvel = sqrt(pow(velocity.x, 2)+pow(velocity.y, 2)+pow(velocity.z, 2))
		var direction = Vector2(player.position.x-global_position.x, player.position.z-global_position.z).normalized()
		
		if sawplayer:
			global_rotation.y = atan2(-direction.x, -direction.y)
			scale = Vector3.ONE*0.5
		$playerdetect.look_at(Vector3(player.position.x, player.position.y+0.5, player.position.z))
		
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
				if curvel > 0.01:
					pass
					velocity.x *= 1-(delta*(1/curvel)*30)
					velocity.z *= 1-(delta*(1/curvel)*30)
				if dist <= 3:
					pass
				else:
					if $anim.current_animation != "walk" || !$anim.is_playing():
						$anim.play("walk")
						$audio.stream = load("res://audio/popcopwalk.tres")
						$audio.play()
					velocity.x += direction.x*speed*delta
					velocity.z += direction.y*speed*delta
					
		if !$smacked.is_stopped():
			$dasheffect.transparency = 1
			if is_on_wall_only():
				die()
					
		if sqrt(pow(velocity.x, 2)+pow(velocity.z, 2)) >= dashspeed:
			if $playerhurt.is_stopped():
				for body in $damage.get_overlapping_bodies():
					if body.is_in_group("playergroup"):
						if map.diff == 0:
							body.hurt(10, "ragdoll")
						else:
							body.hurt(15, "ragdoll")
						body.velocity.y += 15
						body.velocity.x += direction.x*30
						body.velocity.z += direction.y*30
						$playerhurt.start()
		
		if previousspeed >= dashspeed:
			if sqrt(pow(velocity.x, 2)+pow(velocity.z, 2)) <= 1:
				die()
		
		previousspeed = sqrt(pow(velocity.x, 2)+pow(velocity.z, 2))
					
		move_and_slide()
	else:
		$dasheffect.transparency = 1
		
func die():
	if !dead:
		$anim.play("death")
		$audio.stream = load("res://audio/popcopbreak.wav")
		$audio.play()
		$CollisionShape3D.disabled = true
		dead = true
			
func smack(side, strength = 5):
	var direction = Vector2(player.position.x-global_position.x, player.position.z-global_position.z).normalized()
	
	velocity.x = 0
	velocity.z = 0
	previousspeed = 0
	#if side == "left":
		#velocity.x += (-direction.y-direction.x/2)*strength
		#velocity.z += (direction.x-direction.y/2)*strength
	#if side == "right":
		#velocity.x += (direction.y-direction.x/2)*strength
		#velocity.z += (-direction.x-direction.y/2)*strength
	if side == "center":
		velocity.x += (-direction.x)*strength
		velocity.z += (-direction.y)*strength
		$anim.play("hit")
		$smacked.start()
	else:
		$anim.play("stun")
	$audio.stop()
	velocity.y += strength/2

func _on_anim_animation_finished(anim_name):
	if anim_name == "death":
		queue_free()
