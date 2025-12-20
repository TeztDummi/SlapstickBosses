extends Node3D
var time = 0
var pile = true

func _ready():
	if !pile:
		$ashpile.hide()
		$Smoke.hide()

func _process(delta):
	if pile:
		time += delta
		if time < 5:
			if $floordetect.is_colliding():
				if position.y > $floordetect.get_collision_point().y:
					position.y = $floordetect.get_collision_point().y
