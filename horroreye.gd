extends Node3D

@onready var main = get_node("/root").get_node("main")
@onready var player = main.get_node("player")
@onready var map = main.get_node("map")
@onready var camera = player.get_node("camera")

var isopen = false
var laserstopped = false

func _ready() -> void:
	pass
	#$anim.play("default")
	#$anim.seek(randf_range(0, 1))
	var dupe = $eye/eye/seethru.get_surface_override_material(0).duplicate()
	$eye/eye/seethru.set_surface_override_material(0, dupe)
	$anim.play("RESET")
	
	if has_meta("open"):
		open()
	
func bleed():
	if !has_meta("open"):
		$blood.emitting = true
		$eye/eye/black.show()
		if $anim.current_animation != "hit":
			$anim.play("hit")
	
func laser():
	if isopen:
		var rand = randf_range(0.9, 1.1)
		$anim.speed_scale = rand
		$anim.play("laser")
		var tempaudio = load("res://tempaudio.tscn").instantiate()
		add_child(tempaudio)
		tempaudio.stream = load("res://audio/horror/eyelaser.mp3")
		tempaudio.volume_db = 20
		tempaudio.pitch_scale = rand
		tempaudio.play()
		print("sup")
	
func lasershoot():
	for body in $eye/eye/area.get_overlapping_bodies():
		if body.is_in_group("playergroup"):
			body.hurt(5, "bluelaser")
			
func laserstop(val):
	laserstopped = val
	
func hit():
	if !has_meta("open"):
		$anim.play("hit")
		#if $anim.current_animation == "laser":
		main.get_node("map").openeyes -= 1
		isopen = false
	
func _process(delta: float) -> void:
	var lookat = main.get_node("lookat")
	if !$anim.current_animation == "laser":
		lookat.look_at_from_position(global_position, camera.global_position)
	else:
		var pos = player.global_position
		pos.y += 0.75
		lookat.look_at_from_position(global_position, pos)
	if !laserstopped:
		$eye/eye.global_rotation = lookat.global_rotation
	if !$anim.current_animation == "laser":
		var shake = 0.02
		$eye/eye.rotation.x += randf_range(-1, 1)*shake
		$eye/eye.rotation.y += randf_range(-1, 1)*shake
		$eye/eye.rotation.z += randf_range(-1, 1)*shake

func _on_anim_animation_finished(anim_name: StringName) -> void:
	if anim_name == "default" || anim_name == "open" || anim_name == "laser":
		$anim.speed_scale = 1
		$anim.play("default")
		$anim.seek(randf_range(0, 1))
		laserstopped = false
	
func open():
	$anim.play("open")
	isopen = true
	
func blink():
	var tempaudio = load("res://tempaudio.tscn").instantiate()
	add_child(tempaudio)
	tempaudio.stream = load("res://audio/horror/blink.mp3")
	tempaudio.play()
