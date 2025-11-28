extends Node3D

var lookpos = Vector3.ZERO

func shoot(raycast):
	pass
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("click"):
		$anim.play("click")
	if Input.is_action_just_released("click"):
		$anim.play("unclick")
		
	if Input.is_action_pressed("click"):
		if $raycast.is_colliding():
			$hit.show()
			var col = $raycast.get_collider()
			if col != null:
				if col.is_in_group("spleefblock"):
					col.get_parent().breaking = 1
				if col.is_in_group("spleefbomb"):
					col.get_parent().hurt()
		else:
			$hit.hide()
		$pointer/laser.show()
		
		$pointer.look_at(lookpos)
		$pointer.rotation.y += PI
		$pointer.rotation.x *= -1
		$hit.global_position = lookpos
	else:
		$pointer/laser.hide()
		$hit.hide()

func _on_updatelook_timeout() -> void:
	if $raycast.is_colliding():
		lookpos = $raycast.get_collision_point()
	else:
		lookpos = $lookfar.global_position
		
	$pointer/laser/spiral.rotation.x += 0.021*PI*20
