extends Node3D

@onready var main = get_node("/root").get_node("main")
@onready var player = main.get_node("player")
@onready var map = main.get_node("map")

var visiblechecks = 0

func _ready() -> void:
	global_rotation.y = atan2(global_position.x-player.position.x, global_position.z-player.position.z)
	global_rotation.y += sign(randf_range(-1, 1))*randf_range(PI/4, (2*PI)/3)

func _on_checkplayer_timeout() -> void:
	if $visiblenotif.is_on_screen():
		visiblechecks += 1
		print("you see alien")
	else:
		visiblechecks -= 3
	if visiblechecks < 0: visiblechecks = 0
	if global_position.distance_to(player.position) < 10+visiblechecks*0.75:
		$anim.speed_scale = 1
		$anim.play("shock")
		$shockaudio.play()
		global_rotation.y = atan2(global_position.x-player.position.x, global_position.z-player.position.z)
		$checkplayer.stop()
		
func _on_anim_animation_finished(anim_name: StringName) -> void:
	if anim_name == "shock":
		$"../../../".start()
		rotation.y = 0
		$anim.speed_scale = 2
		$anim.play("run")
		$audio.play()
