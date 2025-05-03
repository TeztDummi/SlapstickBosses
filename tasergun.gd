extends Marker3D

var hitdelay = 0

var shot = "no"
var latched = null
var shotrot = null

var playerlastrot

var marker = null

@onready var player = $"../../../../player"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#changes freed object to null idfk
	if latched == null:
		latched = null
		
	if shot == "yes" && latched == null:
		$tazergun/shot/detectfromenemy.monitorable = true
	else:
		$tazergun/shot/detectfromenemy.monitorable = false
	
	if hitdelay > 0:
		hitdelay -= delta
	if latched != null:
		latched.global_position = $tazergun/shot.global_position
	if shotrot != null:
		$"../../../../lookat".look_at_from_position(Vector3(player.position.x, player.position.y+1.5, player.position.z), shotrot.position)
		var rot = $"../../../../lookat".rotation
		#player.camera.rotation.x = lerp_angle(player.camera.rotation.x, rot.x, delta)
		#player.camera.rotation.z = lerp_angle(player.camera.rotation.z, rot.z, delta)
		#player.rotation.y = lerp_angle(player.rotation.y, rot.y, delta)
	if shot == "yes":
		if latched == null:
			if $tazergun/shot/raycast.is_colliding():
				var collision = $tazergun/shot/raycast.get_collider()
				if collision != null:
					if collision.get_parent().get_parent().name == "tilesphere":
						if !collision.get_parent().began:
							#70
							if collision.get_parent().heat >= 70:
								collision.get_parent().hurt(100)
							else:
								latched = collision.get_parent()
								latched.moved = true
								
								marker = Marker3D.new()
								$"../../../../map/tilesphere".add_child(marker)
								marker.position = collision.get_parent().position
								#marker.add_child(load("res://objects/bowlingball.tscn").instantiate())
						else: retract()
					elif collision.is_in_group("spacebomb"): 
						collision.get_parent().explode()
						retract()
					elif collision.is_in_group("facebot"): 
						if collision.get_parent().zapped == "no":
							collision.get_parent().zap()
							$AnimationPlayer.speed_scale = 0
							$unfreezecord.start()
							$gainenergy.start()
							$anim2.play("gain")
						elif collision.get_parent().zapped == "dead":
							retract()
					elif collision.is_in_group("crasherbot"): 
						if collision.get_parent().attacking == "yes":
							var future = collision.get_parent().velocity + collision.get_parent().position.normalized()*0.3
							if abs(future.normalized()-collision.get_parent().velocity.normalized()) > Vector3(0.1, 0.1, 0.1):
								collision.get_parent().endattack()
								collision.get_parent().dizzy = 2
								retract()
							collision.get_parent().velocity = future
							var dist = sqrt(pow(collision.get_parent().position.x, 2)+pow(collision.get_parent().position.y, 2)+pow(collision.get_parent().position.z, 2))/8
							$AnimationPlayer.seek((dist)/2)
						else:
							if collision.get_parent().zapped == "no":
								pass
								#collision.get_parent().zap()
								#$AnimationPlayer.speed_scale = 0
								#$unfreezecord.start()
								#$gainenergy.start()
								#$anim2.play("gain")
							elif collision.get_parent().zapped == "dead":
								retract()
					else: retract()
					#shotrot = collision.get_parent()
	if shot == "retract":
		if sqrt(pow(player.position.x-$tazergun/shot.global_position.x, 2) + pow(player.position.y+1.5-$tazergun/shot.global_position.y, 2) + pow(player.position.z-$tazergun/shot.global_position.z, 2)) <= 6:
			hitdelay = 0.25
			if marker != null && latched != null:
				if sqrt(pow(marker.global_position.x-$tazergun/shot.global_position.x, 2) + pow(marker.global_position.y-$tazergun/shot.global_position.y, 2) + pow(marker.global_position.z-$tazergun/shot.global_position.z, 2)) <= 0.75:
					latched.global_position = marker.global_position
					latched.moved = false
				else:
					latched.begin()
				marker.queue_free()
			latched = null
			shotrot = null
			shot = "no"
	if shot != "no":
		if false:
			if $cordcast.is_colliding():
				if $cordcast.get_collider(0) != null:
					if $cordcast.get_collider(0).get_parent().get_parent().name == "tilesphere":
						if $cordcast.get_collider(0).get_parent() != latched && !$cordcast.get_collider(0).get_parent().began && marker != null:
							$"../../../../lookat".look_at_from_position(Vector3(player.position.x, player.position.y+1.5, player.position.z), marker.global_position)
							var rot = $"../../../../lookat".rotation
							player.camera.rotation.x = lerp_angle(player.camera.rotation.x, rot.x, delta*5)
							player.camera.rotation.z = lerp_angle(player.camera.rotation.z, rot.z, delta*5)
							player.rotation.y = lerp_angle(player.rotation.y, rot.y, delta*5)
func shoot(raycast):
	if hitdelay <= 0:
		if $AnimationPlayer.current_animation != "intro":
			if shot == "no":
				if player.spaceenergy > 0:
					shot = "yes"
					player.spaceenergy -= 1
					hitdelay = 0.25
					$AnimationPlayer.play("shoot")
					$AnimationPlayer.speed_scale = 4
					$audio.play()
					
					$limit.start()
				
			elif shot == "yes":
				retract()
				
func retract():
	shot = "retract"
	hitdelay = 100
	$AnimationPlayer.speed_scale = -4

func _on_limit_timeout():
	if shot == "yes":
		retract()

func _on_tilearea_body_entered(body):
	if latched != null:
		if latched.get_parent().name == "tilesphere":
			if body.is_in_group("facebot"):
				body.get_parent().dizzy = 2
				body.get_parent().velocity = Vector3.ZERO
				if body.get_parent().zapped == "no":
					if shot == "yes":
						body.get_parent().velocity += (body.get_parent().position)*0.05
					elif shot == "retract":
						body.get_parent().velocity -= (body.get_parent().position)*0.1

func _on_unfreezecord_timeout():
	retract()
	$gainenergy.stop()

func _on_gainenergy_timeout():
	player.spaceenergy += 1
