extends Node3D
var time = 0

func _process(delta):
	time += delta
	if time < 5:
		if $floordetect.is_colliding():
			if position.y > $floordetect.get_collision_point().y:
				position.y = $floordetect.get_collision_point().y
