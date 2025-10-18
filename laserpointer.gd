extends Node3D

func shoot(raycast):
	pass
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("click"):
		$anim.play("click")
	if Input.is_action_just_released("click"):
		$anim.play("unclick")
		
	if Input.is_action_pressed("click"):
		if $raycast.is_colliding():
			$pointer.look_at($raycast.get_collision_point())
			$pointer.rotate_y(PI)
			var col = $raycast.get_collider()
			if col != null:
				if col.is_in_group("spleefblock"):
					col.get_parent().breaking = true
		$pointer/laser.show()
	else:
		$pointer/laser.hide()
