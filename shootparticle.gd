extends Node3D

var time = 0
var shotplayer = false
# Called when the node enters the scene tree for the first time.
func _ready():
	$particles.emitting = true
	$smoke.emitting = true
	$blud.emitting = true
	var dupe = $blud.draw_pass_1.material.duplicate()
	$blud.draw_pass_1.material = dupe
	$blud.draw_pass_1.material.albedo_texture.current_frame = 0
	if shotplayer:
		$audio.stream = load("res://audio/shootperson.wav")
		$audio.pitch_scale = randf_range(0.75, 1.25)
		$audio.play()
	else:
		$audio.stream = load("res://audio/shootground.wav")
		$audio.pitch_scale = randf_range(0.75, 1.25)
		$audio.play()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta
	if time > 10: queue_free()
