extends Node3D

var rotate = Vector3.ZERO
var rotspeed = 0.1
var rotrate = 0.5

func _ready() -> void:
	for child in $main.get_children():
		child.get_node("anim").speed_scale = randf_range(0.75, 1.5)
		
func _process(delta: float) -> void:
	$main.rotation += rotate*rotspeed
	rotate.x += delta*randf_range(-1, 1)*rotrate
	rotate.x = clampf(rotate.x, -1, 1)
	rotate.y += delta*randf_range(-1, 1)*rotrate
	rotate.y = clampf(rotate.y, -1, 1)
	rotate.z += delta*randf_range(-1, 1)*rotrate
	rotate.z = clampf(rotate.z, -1, 1)
