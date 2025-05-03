extends Node3D

# Called when the node enters the scene tree for the first time.
func _ready():
	var rand = randi_range(0, 3)
	get_child(rand).show()
