extends Node3D

var direction = 0
var speed = 30
var time = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	$sign.get_surface_override_material(0).albedo_texture = load(str($"..".billboards.pick_random()))
	direction = randf_range(0, PI*2)
	rotation.y = direction
	position.x = sin(direction-PI/2)*200
	position.z = cos(direction-PI/2)*200
	position.x += sin(direction)*600
	position.z += cos(direction)*600
	$plane.get_surface_override_material(0).albedo_color = Color.from_hsv(randf(), randf(), randf())
	time = 0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position.x -= sin(direction)*delta*speed
	position.z -= cos(direction)*delta*speed
	time += delta
	if time >= 40:
		_ready()

func _on_basketballarea_body_entered(body):
	if body.is_in_group("basketball"):
		$audio.play()
		$AnimationPlayer.speed_scale = 1
		$AnimationPlayer.play("boom")
		print("boomplane")
		$"../../".setAchievement("and1")
