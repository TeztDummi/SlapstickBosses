extends Node3D

func _ready() -> void:
	$particles.emitting = true
	$audio.pitch_scale = randf_range(0.8, 1.2)

func _on_remove_timeout() -> void:
	queue_free()
