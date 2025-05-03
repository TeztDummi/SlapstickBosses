extends Marker3D

var leftdelay = 0
var rightdelay = 0

@onready var player = $"../../../../player"

# Called when the node enters the scene tree for the first time.
func _ready():
	$arm.get_surface_override_material(0).albedo_color = player.get_parent().bodycolor

#why is my coding so ass
func shoot(raycast):
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if leftdelay > 0:
		leftdelay -= delta
	if rightdelay > 0:
		rightdelay -= delta
		
	var dontslap = false
	
	if $raycast.is_colliding():
		if $raycast.get_collider() != null:
			if $raycast.get_collider().is_in_group("pipewheel"):
				dontslap = true
		
	if !dontslap:
		if Input.is_action_just_pressed("click"):
			if leftdelay <= 0:
				$anim.play("left")
				leftdelay = 1
				$audio.play()
				
		if Input.is_action_just_pressed("rightclick"):
			if rightdelay <= 0:
				$anim.play("right")
				rightdelay = 1
				$audio.play()
			
func slap(side):
	for body in $area.get_overlapping_bodies():
		if body.is_in_group("popcop"):
			body.smack(side)
			$audio2.stream = load("res://audio/smack.wav")
			if body.is_in_group("bigpopcop"):
				$audio2.stream = load("res://audio/smackfail.wav")
			$audio2.play()
			player.rotation.y = atan2(global_position.x-body.global_position.x, global_position.z-body.global_position.z)
			player.camera.look_at(Vector3(body.global_position.x, body.global_position.y+1.5, body.global_position.z))
			body.eyes.visible = true
			player.camera.rotation.y = 0
			player.camera.rotation.z = 0
			$timestop.start()
			get_tree().paused = true


func _on_timestop_timeout():
	get_tree().paused = false
