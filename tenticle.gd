extends Node3D

@onready var main = get_node("/root").get_node("main")
@onready var player = main.get_node("player")

var active = false
var progress = 0
var limit = 100
var limithurt = 90
var seconds = 3
var hurtplayer = false

func activate():
	active = true
	progress = 0
	hurtplayer = false
	$mesh/audio.stream = load("res://audio/horror/tentacle.mp3")
	$mesh/audio.play()
	
func hit():
	$playerstuck.stop()
	progress = 1
	hurtplayer = true
	$mesh/audio.stream = load("res://audio/horror/tentacleparry.mp3")
	$mesh/audio.play()
	main.get_node("map").tentaclesparried += 1

func _process(delta: float) -> void:
	
	visible = ($mesh.position.z <= limit-0.5)
	
	var pos = player.position
	pos.y += 0.75
	look_at(pos)
	var dist = sqrt(pow(global_position.x-pos.x, 2) + pow(global_position.y-pos.y, 2) + pow(global_position.z-pos.z, 2))
	var rotdist = sqrt(pow($mesh.global_position.x-pos.x, 2) + pow($mesh.global_position.y-pos.y, 2) + pow($mesh.global_position.z-pos.z, 2))
	if active:
		$mesh.rotation.x += delta*PI
		$mesh.rotation.y = deg_to_rad(-90)
		$mesh.rotation.z = ((rotdist-limithurt)*PI)/20000
		$blud.emitting = true
		$mesh/circle.show()
		
	else:
		$mesh.rotation = Vector3(0, deg_to_rad(-90), 0)
		$blud.emitting = false
		$mesh/circle.hide()
	if !$playerstuck.is_stopped() && !hurtplayer:
		player.velocity = Vector3.ZERO
	elif active:
		if !hurtplayer:
			for body in $mesh/area.get_overlapping_bodies():
				if body.is_in_group("playergroup"):
					$playerstuck.start()
					body.hurt(5, "ragdoll")
					$mesh/audio.stream = load("res://audio/horror/tentaclegrab.mp3")
					$mesh/audio.play()
		if $raycast.is_colliding():
			if !$raycast.get_collider().is_in_group("playergroup"):
				progress = 1
		if progress >= 1:
			if $mesh/audio.stream.resource_path.get_file() == "tentacle.mp3":
				$mesh/audio.stop()
			active = false
		else:
			var newpos = limithurt-(dist*progress)
			if newpos < $mesh.position.z:
				$mesh.position.z = newpos
			if $mesh.position.z > limit:
				$mesh.position.z = limit
			if progress < 1: progress += delta/seconds
			else: progress = 1
	else:
		$mesh.position.z = lerpf($mesh.position.z, limit, delta*5)

func _on_playerstuck_timeout() -> void:
	if !hurtplayer:
		for body in $mesh/area.get_overlapping_bodies():
			if body.is_in_group("playergroup"):
				body.hurt(10, "ragdoll")
				hurtplayer = true
				progress = 1
