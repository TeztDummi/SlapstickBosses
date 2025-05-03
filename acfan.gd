extends MeshInstance3D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	rotate_z(delta*25)
	
	for body in $pull.get_overlapping_bodies():
		if body.is_in_group("playergroup"):
			if !body.dead:
				var dir = Vector2(body.global_position.x-global_position.x, body.global_position.z-global_position.z).normalized()
				body.velocity.x -= dir.x*500*delta
				body.velocity.z -= dir.y*500*delta
				print("oh yeah vector")

func _on_kill_body_entered(body):
	if body.is_in_group("playergroup"):
		if !body.dead:
			body.hurt(100, "ragdoll")
			body.position = Vector3.ZERO
