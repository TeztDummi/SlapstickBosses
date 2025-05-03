extends MeshInstance3D

# Called when the node enters the scene tree for the first time.
func _ready():
	get_surface_override_material(0).albedo_texture = load(str($"..".billboards.pick_random()))
