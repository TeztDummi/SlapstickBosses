extends Node3D

var diff = 0
var chal = "none"

func _ready() -> void:
	var gun = load("res://laserpointer.tscn").instantiate()
	$"../player/camera/gun".add_child(gun)
	$"../player".scroll = 1
	
	$"../player".candoublejump = true
	$"../player".djseconds = 2
	
func dodafreeze():
	$spleefboss.freezeattack()
	
func endbreak():
	$anim.playfps("breakchain", 12)

func _on_anim_animation_finished(anim_name: StringName) -> void:
	if anim_name == "breakchain":
		$spleefboss.move = true
		$anim.playfps("sink", 8)
