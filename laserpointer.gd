extends Node3D

var lookpos = Vector3.ZERO

func shoot(raycast):
	pass
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("click"):
		$anim.play("click")
		$click.pitch_scale = 1
		$click.play()
		$ambience.play()
		$ambience.seek(randf_range(0, 5.6))
	if Input.is_action_just_released("click"):
		$anim.play("unclick")
		$click.pitch_scale = 0.9
		$click.play()
		$ambience.stop()
		
	if Input.is_action_pressed("click"):
		if $raycast.is_colliding():
			$hit.show()
			var col = $raycast.get_collider()
			if col != null:
				if col.is_in_group("spleefblock"):
					col.get_parent().breaking = 1
					if col.get_parent().issuper:
						var rayvect = ($raycast.global_position-$raycast.get_collision_point()).normalized()
						var reflection = rayvect.reflect($raycast.get_collision_normal())
						$hit.look_at(reflection+$hit.global_position)
						$hit/reflect.show()
					else:
						$hit/reflect.hide()
				else:
					$hit/reflect.hide()
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
		
	updatelook(delta)

func _on_updatelook_timeout() -> void:
	pass
	#updatelook()
	
func lerpvect(from, to, time):
	var ret = Vector3.ZERO
	ret.x = lerpf(from.x, to.x, time)
	ret.y = lerpf(from.y, to.y, time)
	ret.z = lerpf(from.z, to.z, time)
	return ret
	
func updatelook(delta):
	if $raycast.is_colliding():
		lookpos = lerpvect(lookpos, $raycast.get_collision_point(), delta*32)
	else:
		lookpos = lerpvect(lookpos, $lookfar.global_position, delta*32)
		
	$pointer/laser/spiral.rotation.x += 0.021*PI*20
