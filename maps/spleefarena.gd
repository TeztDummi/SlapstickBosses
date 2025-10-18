extends Node3D

var diff = 0
var chal = "none"

func _ready() -> void:
	var gun = load("res://laserpointer.tscn").instantiate()
	$"../player/camera/gun".add_child(gun)
	$"../player".scroll = 1
