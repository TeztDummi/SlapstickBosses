extends Node3D

func _ready() -> void:
	var dupe3 = $warning.get_surface_override_material(0).duplicate()
	$warning.set_surface_override_material(0, dupe3)
	var dupe = $wallveins.get_surface_override_material(0).duplicate()
	$wallveins.set_surface_override_material(0, dupe)

func start():
	$anim.play("default")
	$audio.play()
	
func permanent():
	$anim.play("permanent")

func _on_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("playergroup"):
		body.hurt(7, "ragdoll")
