extends Node3D

@onready var main = get_node("/root").get_node("main")
@onready var player = main.get_node("player")
@onready var map = main.get_node("map")

var diff = 0
var chal = "none"

func _ready() -> void:
	player.setsurfboard(true)
	player.falloff = false
	

func _on_spawnlubeball_timeout() -> void:
	var r = 4
	var sign = -1
	print(player.position.x)
	if player.position.x > 30:
		sign = 1
	elif player.position.x >= -30:
		sign = sign(randf_range(-1, 1))
	for i in range(r+1):
		var ball = load("res://lube/lubeball.tscn").instantiate()
		ball.position.x = player.position.x+(i-(r/2.0))*6
		ball.position.z = player.position.z-30+player.velocity.z*2+(i-(r/2.0))*3*sign
		ball.position.y = ball.position.z*0.26794919
		add_child(ball)
