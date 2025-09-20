extends Node3D

func _ready() -> void:
	$screen/screen.play(get_meta("play"))
