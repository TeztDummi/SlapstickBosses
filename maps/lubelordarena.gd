extends Node3D

@onready var main = get_node("/root").get_node("main")
@onready var player = main.get_node("player")
@onready var map = main.get_node("map")

var diff = 0
var chal = "none"

func _ready() -> void:
	player.setsurfboard(true)
	player.falloff = false
