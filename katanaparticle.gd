extends Node3D

var time = 0
var blood = false
var white = false
var customscale = 1

func _ready() -> void:
	var dupe = $shine.draw_pass_1.duplicate()
	$shine.draw_pass_1 = dupe
	
	var dupe2 = $blud.draw_pass_1.duplicate()
	$blud.draw_pass_1 = dupe2
	
	$shine.draw_pass_1.size *= customscale
	$blud.draw_pass_1.size *= customscale
	
	if blood: $blud.emitting = true
	$shine.emitting = true
	
	if white: dupe.material.albedo_texture = load("res://shinecolorless.png")

func _process(delta):
	time += delta
	if time > 2: queue_free()
