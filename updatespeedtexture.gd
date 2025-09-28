extends MeshInstance3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var amount = delta*2
	if is_in_group("speedtextureslower"):
		amount = delta*3
	get_surface_override_material(0).uv1_offset.z += amount
