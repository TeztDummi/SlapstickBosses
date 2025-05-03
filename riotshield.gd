extends Marker3D

var delay = 0
var up = false
var health = 15
var dead = false
@onready var player = $"../../../../player"
@onready var playerspeed = player.SPEED

# Called when the node enters the scene tree for the first time.
func _ready():
	$SubViewport/healthbar.max_value = health
	$SubViewport/healthbar.value = health

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if delay >= 0: delay -= delta

func hit(amount):
	if !dead:
		if up:
			if !$AnimationPlayer.is_playing():
				$AnimationPlayer.play("hit")
			$mesh/audio.stream = load("res://audio/riotshieldhit"+str(randi_range(0, 1))+".mp3")
			$mesh/audio.play()
			$mesh/audio.pitch_scale = randf_range(0.75, 1.2)
			health -= amount
			$SubViewport/healthbar.value = health
			if health <= 0:
				$AnimationPlayer.play("flyaway")
				$mesh/static.queue_free()
				reparent($"../../../../map")
				global_rotation.x = 0
				global_rotation.z = 0
				global_position.x = player.position.x - sin(player.rotation.y)*2
				global_position.z = player.position.z - cos(player.rotation.y)*2
				global_position.y = 1.5
				dead = true
				player.SPEED = playerspeed
				$mesh/audio.stream = load("res://audio/riotshieldflip.mp3")
				$mesh/audio.play()
				$mesh/audio.pitch_scale = 1
	
func shoot(raycast):
	if !dead:
		if delay <= 0:
			delay = 0.5
			if !up:
				$AnimationPlayer.play("pullup")
				up = true
				player.SPEED = playerspeed*0.5
			else:
				$AnimationPlayer.play("pulldown")
				up = false
				player.SPEED = playerspeed

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "flyaway":
		queue_free()
