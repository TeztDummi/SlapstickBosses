extends Node3D
var color = Color(1, 1, 1)
var head = "res://objects/defaultobject.tscn"
var time = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	$mesh.get_surface_override_material(0).albedo_color = color
	var loadhead = load(head).instantiate()
	$headpivot.add_child(loadhead)

func _process(delta):
	time += delta
	if time < 5:
		if $floordetect.is_colliding():
			if position.y > $floordetect.get_collision_point().y:
				position.y = $floordetect.get_collision_point().y
