extends Node3D

func _ready() -> void:
	rotation.y += PI/2
	$slamparticles.restart()
	$slamparticles2.restart()
