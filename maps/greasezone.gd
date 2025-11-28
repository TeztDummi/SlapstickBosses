extends Area3D

func _process(delta: float) -> void:
	for body in get_overlapping_bodies():
		if body.is_in_group("grease"):
			body.dontmove = true


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("grease"):
		body.dontmove = true


func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("grease"):
		body.dontmove = false
