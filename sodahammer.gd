extends Marker3D

@onready var main = get_node("/root").get_node("main")
@onready var player = main.get_node("player")
@onready var map = main.get_node("map")

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("click"):
		if $cooldown.is_stopped():
			$anim.play("RESET")
			$anim.play("use")
			$audio2.play()
			var amountofcans = 0
			for body in $area.get_overlapping_bodies():
				if body.is_in_group("sodacanpickup"):
					if body.get_parent().get_node("can").visible:
						$audio.play()
						
						if body.get_parent().is_in_group("canrigid"):
							amountofcans += 1
							var box = get_node("/root").get_node("main/map/sodabox")
							if box != null:
								var pos = box.global_position
								pos += box.velocity*2
								pos.y += 4
								$dirpivot.look_at(box.global_position)
							else:
								$dirpivot.rotation = Vector3.ZERO
							
							var dir = Vector3($dirpivot/dir.global_position.x-global_position.x, $dirpivot/dir.global_position.y-global_position.y, $dirpivot/dir.global_position.z-global_position.z)
							body.get_parent().linear_velocity = dir*100
							body.get_parent().linear_velocity.y += 10
						if body.get_parent().is_in_group("sodacan"):
							#amountofcans += 1
							$dirpivot.rotation = Vector3.ZERO
							var dir = Vector3($dirpivot/dir.global_position.x-global_position.x, $dirpivot/dir.global_position.y-global_position.y, $dirpivot/dir.global_position.z-global_position.z)
							var power = 40
							if body.get_parent().healthcan: power = -1
							shootprojectile(dir, power, body.get_parent().healthcan, body.get_parent().global_position)
							body.get_parent().queue_free()
				if body.is_in_group("popcop"):
					$audio.play()
					body.smack("center", 30)
					body.eyes.visible = true
				if body.is_in_group("endcan"):
					if body.get_parent().get_node("endcan").visible:
						body.get_parent()._on_kick_body_entered(player, true)
						$audio.play()
			$cooldown.start()
			if amountofcans >= 6:
				$timestop.start()
				get_tree().paused = true
				
				var box = get_node("/root").get_node("main/map/sodabox")
				if box != null:
					var pos = box.global_position
					pos += box.velocity*2
					pos.y += 4
					$dirpivot.look_at(box.global_position)
				else:
					$dirpivot.rotation = Vector3.ZERO
					
				var dir = Vector3($dirpivot/dir.global_position.x-global_position.x, $dirpivot/dir.global_position.y-global_position.y, $dirpivot/dir.global_position.z-global_position.z)
				var dirnormalized = Vector2(dir.x, dir.z).normalized()
				player.velocity.x += -dirnormalized.x*50
				player.velocity.y += 20
				player.velocity.z += -dirnormalized.y*50

func _on_timestop_timeout():
	get_tree().paused = false
			
func shootprojectile(dir, power, healthcan, pos):
	var projectile = load("res://sodaboss/sodacanrigid.tscn").instantiate()
	pos.y += 1
	projectile.position = pos
	var linvel = dir*power
	linvel.y = 10
	projectile.linear_velocity = linvel
	projectile.angular_velocity = Vector3(randf_range(-5, 5), randf_range(-5, 5), randf_range(-5, 5))
	projectile.add_to_group("fromplayer")
	if healthcan: projectile.healthcan = true
	$"../../../../".add_child(projectile)

func _on_anim_animation_finished(anim_name: StringName) -> void:
	if anim_name == "use":
		$anim.play("idle")
		
func shoot(raycast):
	pass
