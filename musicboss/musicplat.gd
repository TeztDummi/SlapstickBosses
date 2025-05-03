extends Node3D
var timer = 4

func _ready():
	$Timer.wait_time = timer
	$Timer.start()
	var dupe = $StaticBody3D/MeshInstance3D.get_surface_override_material(0).duplicate()
	$StaticBody3D/MeshInstance3D.set_surface_override_material(0, dupe)
	rotation.y = ceil(randf_range(0, PI*2.0)/(PI/2))*(PI/2)

func _process(delta):
	if $StaticBody3D/MeshInstance3D.get_surface_override_material(0).emission_energy_multiplier > 0:
		$StaticBody3D/MeshInstance3D.get_surface_override_material(0).emission_energy_multiplier -= delta*5
	else:
		$StaticBody3D/MeshInstance3D.get_surface_override_material(0).emission_energy_multiplier = 0
	
func _on_timer_timeout():
	if $AnimationPlayer.current_animation != "down":
		$AnimationPlayer.play("down")
