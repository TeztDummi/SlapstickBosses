extends Area3D
var time = 0

func _process(delta):
	time += delta
	position.y += sin(time*5)*0.01

func _on_body_entered(body):
	if $Timer.is_stopped():
		if body.is_in_group("playergroup"):
			if !$"../../".bitbags.has(str(get_meta("id"))):
				var popup = load("res://popup.tscn").instantiate()
				popup.bits = 100
				$"../../".bits += 100
				$"../../sfx".stream = load("res://audio/gainbits.mp3")
				$"../../sfx".play()
				$"../../canvas/hud".add_child(popup)
				$"../../".bitbags[str(get_meta("id"))] = true
				$particle.emitting = true
				$MeshInstance3D.hide()
				$Timer.start()

func _on_timer_timeout():
	queue_free()

func _on_starttimer_timeout():
	if $"../../".bitbags.has(str(get_meta("id"))):
		queue_free()
