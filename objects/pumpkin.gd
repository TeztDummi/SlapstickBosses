extends Node3D

func _ready() -> void:
	var choice = load("res://objects/pumpkins/pumpkin_"+str(randi_range(1, 22))+".tscn").instantiate()
	choice.layers = 32
	for child in choice.get_children():
		if child is MeshInstance3D || child is OmniLight3D: child.layers = 32
		for childagain in child.get_children():
			if childagain is MeshInstance3D || childagain is OmniLight3D: childagain.layers = 32
			for childagainagain in childagain.get_children():
				if childagainagain is MeshInstance3D || childagainagain is OmniLight3D: childagainagain.layers = 32
	choice.position.x = 0
	choice.position.y = 0.54
	add_child(choice)
