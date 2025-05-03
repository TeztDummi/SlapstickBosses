extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	var dupe = $warning.get_surface_override_material(0).duplicate()
	$warning.set_surface_override_material(0, dupe)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$warning.get_surface_override_material(0).uv1_offset.x += delta*0.2
