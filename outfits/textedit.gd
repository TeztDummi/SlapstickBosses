extends MeshInstance3D

var timer = 0

func _process(delta: float) -> void:
	timer -= delta
	if timer <= 0:
		timer = 1
		var tex = ViewportTexture.new()
		tex.viewport_path = "outfittext"
		set_surface_override_material(3, tex)
