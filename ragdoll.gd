extends Node3D
var color = Color(1, 1, 1)
var head = "res://objects/defaultobject.tscn"
var vel = Vector3.ZERO
var spinmult = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	$body/mesh.get_surface_override_material(0).albedo_color = color
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
			#break
	print($head.get_children())
	$body.linear_velocity = vel
	$body.angular_velocity = spinmult*Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1))
	$head.linear_velocity = vel
	$head.angular_velocity = spinmult*Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1))
