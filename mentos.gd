extends Marker3D

func shoot(raycast):
	pass

func _process(delta: float) -> void:
	if !$anim.is_playing():
		if Input.is_action_just_pressed("click"):
			if $raycast.is_colliding():
				if $raycast.get_collider().name == "mixingstationtrigger":
					$anim.play("use")
					
func start():
	$"../../../../map".startmixing()
