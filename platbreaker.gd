extends Node3D
var time = 0
@onready var player = $"../../player"

# Called when the node enters the scene tree for the first time.
func detect():
	var possibilitys = []
	for body in $Area3D.get_overlapping_bodies():
		if body.is_in_group("musicplat"):
			body.get_parent().queue_free()
	player.screenshake += 0.05
			
func _process(delta):
	if time < 1: time += delta
	else: time = 1
	for body in $Area3D.get_overlapping_bodies():
		if body.is_in_group("musicplat"):
			body.get_child(0).get_surface_override_material(0).emission_energy_multiplier = time*10
