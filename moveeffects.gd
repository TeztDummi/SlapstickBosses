extends Node3D

var effect = "land"

func _ready():
	for child in get_children():
		if str(child.get_class()) == "MeshInstance3D":
			child.visible = false
	if effect == "land": $landeffect.visible = true
	if effect == "run": $runeffect.visible = true
	if effect == "jump": $jumpeffect.visible = true
	if effect == "walljump":
		$jumpeffect.visible = true
	if effect == "walllatch":
		$landeffect.visible = true

func _on_animplayer_animation_finished(anim_name):
	queue_free()
