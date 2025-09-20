extends Node3D

func _on_timer_timeout() -> void:
	if randf() < 0.01:
		$anim.play("flicker")
