extends Node3D

@onready var main = get_node("/root").get_node("main")

var head = "res://objects/defaultobject.tscn"
var vel = Vector3.ZERO
var spinmult = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	var loadhead = load(head).instantiate()
	$head.add_child(loadhead)
	if loadhead.has_meta("death"):
		loadhead.death()
	for child in loadhead.get_children():
		if child is MeshInstance3D:
			child.create_convex_collision(true, true)
			for staticbod in child.get_children():
				if staticbod is StaticBody3D:
					staticbod.get_child(0).reparent($head, true)
					staticbod.queue_free()
					
	$head.linear_velocity = vel
	$head.angular_velocity = spinmult*Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1))
	
	$bones.emitting = true
