extends Marker3D

var hitdelay = 0
@onready var player = $"../../../../player"
var shooting = false
var buttonheld = false
var recoil = 1
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#$body/longshoot.rotation_degrees.z = randf_range(-85, -95)
	if !buttonheld:
		shooting = false
		if $AnimationPlayer.current_animation != "shootend":
			$audio.stream = load("res://audio/minigunend.mp3")
			$audio.play()
		if $AnimationPlayer.is_playing():
			$AnimationPlayer.play("shootend")
	
	buttonheld = false
	if hitdelay > 0:
		hitdelay -= delta

func shoot(raycast):
	if hitdelay <= 0:
		if !shooting || $AnimationPlayer.current_animation != "intro" || $AnimationPlayer.current_animation != "shootloop" || !$AnimationPlayer.is_playing():
			if $shoottimer.is_stopped():
				if $AnimationPlayer.current_animation != "shoot":
					$audio.stream = load("res://audio/minigunstart.mp3")
					$audio.play()
				$AnimationPlayer.play("shoot")
	buttonheld = true
			
func shootbullet():
	hitdelay = 0.5
	
	var collision = $raycast.get_collider()
	var pos = $raycast.get_collision_point()
	var normal = $raycast.get_collision_normal()
	
	var bullet = load("res://bullet.tscn").instantiate()
	$body/shootfrom.look_at_from_position($body/shootfrom.global_position, pos)
	bullet.rotation = $body/shootfrom.global_rotation
	bullet.rotation.x *= 2.2
	print($body/shootfrom.global_rotation.x)
	bullet.position = $body/shootfrom.global_position
	bullet.scale *= 0.1
	bullet.speed = 50
	bullet.fromplayer = true
	$"../../../../map".add_child(bullet)
	#$audio.play()
	#$audio.pitch_scale = randf_range(0.9, 1.1)
	player.screenshake += 0.025
	player.velocity.x += sin(player.rotation.y)*recoil
	player.velocity.z += cos(player.rotation.y)*recoil

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "shoot":
		shooting = true
		$AnimationPlayer.play("shootloop")
		$shoottimer.start()
		if $audio.stream.resource_path.get_file() != "minigunloop.mp3":
			$audio.stream = load("res://audio/minigunloop.mp3")
			$audio.play()

func _on_shoottimer_timeout():
	if shooting:
		$shoottimer.start()
		shootbullet()
