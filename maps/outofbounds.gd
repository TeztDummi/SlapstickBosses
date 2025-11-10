extends Node3D

var diff = -1
var speed = 0.5

func _ready() -> void:
	$"../music".stream = load("res://audio/music/outofbounds.mp3")
	$"../music".play()
	
	$cube/cube/cubeparticles.restart()
	$anim.play("start")
	
func _process(delta: float) -> void:
	if speed >= 0:
		speed -= 0.5*(delta/16)
	else:
		speed = 0
	$cube.rotate_y(delta*speed)
