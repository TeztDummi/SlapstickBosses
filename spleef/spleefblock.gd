extends Node3D

var breaking = false
var health = 1

func _ready() -> void:
	var dupe = $Cube.get_surface_override_material(0).duplicate()
	$Cube.set_surface_override_material(0, dupe)

func _process(delta: float) -> void:
	if health > 0:
		if breaking:
			health -= delta*8
		elif health < 1:
			health += delta/4
		else:
			health = 1
			
		if health < 1:
			var fac = 0.5+health/2.0
			$Cube.get_surface_override_material(0).albedo_color = Color(1, fac, fac)
		
		if health <= 0:
			hurt()
		breaking = false

func hurt():
	$Cube.queue_free()
	$StaticBody3D.queue_free()
	$particlecol.hide()
	$particles.emitting = true
