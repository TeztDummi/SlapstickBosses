extends Node3D

@onready var scl = scale
var patchscale = 2

func _ready() -> void:
	print("start")
	
	scale = Vector3.ONE*patchscale
	scl /= patchscale
	
	var col = $StaticBody3D/CollisionShape3D.shape.duplicate()
	$StaticBody3D/CollisionShape3D.shape = col
	col.size = scl*2
	$preview.scale = scl*2
	
	for corner in $corners.get_children():
		corner.position *= scl
	for side in $sides.get_children():
		var sclvect = Vector3.ONE-abs(side.position)
		var vect = abs(sclvect*scl*2)
		side.scale.x *= (vect.x+vect.y+vect.z)-1
		side.position *= scl
		var mat = side.get_surface_override_material(0).duplicate()
		side.set_surface_override_material(0, mat)
		mat.uv1_scale = side.scale*2
		if round(fmod(side.scale.x, 2)) == 1:
			mat.uv1_offset.x = 0.5
	for center in $centers.get_children():
		var sclvect = Vector3.ONE-abs(center.position)
		center.scale *= abs(sclvect*scl*2-(Vector3.ONE*1))
		center.position *= scl
		var mat = center.get_surface_override_material(0).duplicate()
		center.set_surface_override_material(0, mat)
		mat.uv1_scale = center.scale*2
		if round(fmod(center.scale.x/2, 2)) != 0:
			mat.uv1_offset.x = 0.5
		if round(fmod(center.scale.y/2, 2)) != 0:
			mat.uv1_offset.y = 0.5
		if round(fmod(center.scale.z/2, 2)) != 0:
			mat.uv1_offset.z = 0.5
