extends Node3D
@onready var player = $"../../player"
var time = 0
var dirstart = Vector3.ZERO
var direction
var warning
var boom = false
@onready var off = Vector3(randf_range(-8, 8), 0, randf_range(-8, 8))
var speed = randf_range(0.25, 1)

# Called when the node enters the scene tree for the first time.
func _ready():
	$fakedir.position.z = (1/speed)*100
	direction = MeshInstance3D.new()
	#direction.mesh = BoxMesh.new()
	direction.position = $fakedir.global_position
	direction.position.x += randf_range(-10, 10)
	direction.position.y += randf_range(-10, 10)
	direction.position.z += randf_range(-10, 10)
	$"../".add_child(direction)
	dirstart = direction.position
	
	warning = load("res://spherewarning.tscn").instantiate()
	warning.position = player.position+off
	$"../".add_child(warning)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !boom:
		time += delta*speed
		off *= 1-(-0.1*delta)
		var ct = pow(sin(time), 2)
		warning.position.x = position.x
		warning.position.z = position.z
		warning.position.y = 0
		if time >= PI/2-0.5*speed:
			if !warning.get_child(0).is_playing():
				warning.get_child(0).play("default")
		if time < PI/2:
			direction.global_position = Vector3(dirstart.x*(1-ct)+(player.position.x+off.x)*ct, dirstart.y*(1-ct)+0*ct, dirstart.z*(1-ct)+(player.position.z+off.z)*ct)
		else:
			if time < 1.6:
				direction.global_position.x = lerpf(direction.global_position.x, player.position.x+off.x, 0.5*delta)
				direction.global_position.z = lerpf(direction.global_position.z, player.position.z+off.z, 0.5*delta)
				direction.global_position.y = 0
		var dir = (global_position-direction.global_position).normalized()
		if round(position.y) == round(direction.position.y) && time >= 1.6:
			boom = true
			explode()
		look_at(direction.position)
		position -= dir*delta*30*(1+0.1*pow(time, 2))
		
func explode():
	$killtimer.start()
	$boom.emitting = true
	$boom2.emitting = true
	$rocket.hide()
	$trail.emitting = false
	$audio.stream = load("res://audio/gunman/rocketexplode.mp3")
	$audio.play()
	player.screenshake += 0.1
	warning.hide()
	for body in $area.get_overlapping_bodies():
		if body.is_in_group("playergroup"):
			body.hurt(10, "bluelaser")

func _on_killtimer_timeout():
	queue_free()
	direction.queue_free()
	warning.queue_free()
