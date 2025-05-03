extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_timer_timeout():
	if $"../../../".bits >= 500:
		if randf() <= 0.01:
			if !$"../../../".didpiracygag:
				if $"../../../map".get_child(0).name == "lobby":
					if $"..".visible:
						if !get_tree().paused:
							$anim.play("default")
							show()
							get_tree().paused = true
							AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), true)
							$"../../../".didpiracygag = true

func _on_anim_animation_finished(anim_name):
	hide()
	get_tree().paused = false
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), false)
