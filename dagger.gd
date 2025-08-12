extends Node3D

func _ready() -> void:
	$anim.play("intro")

func shoot(raycast):
	pass

func _on_anim_animation_finished(anim_name: StringName) -> void:
	if anim_name == "intro":
		$anim.play("idle")
