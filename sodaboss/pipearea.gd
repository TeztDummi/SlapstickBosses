extends Area3D

var started = false

var waitasec = 0.5

func _process(delta):
	if waitasec > 0: waitasec -= delta

func _on_body_entered(body):
	if body.is_in_group("playergroup"):
		if waitasec <= 0:
			if !started:
				for child in get_overlapping_bodies():
					print(child)
					if child.get_parent().is_in_group("pipehole"):
						child.get_parent().start()
				started = true
