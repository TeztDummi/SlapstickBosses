extends Node3D
@onready var srotx = rotation.x
var speed = 30
var fromplayer = false
@onready var player = $"../../player"
@onready var gunman = $"../boss"
var damagemult = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	var dir = (global_position-$direction.global_position).normalized()
	position += dir*1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$raycast.global_rotation = Vector3.ZERO
	var dir = (global_position-$direction.global_position).normalized()
	if $Icosphere.visible: position += dir*delta*speed
	if $raycast.get_collider() != null:
		var distance = ($raycast.global_position.y-$raycast.get_collision_point().y)
		if rotation.x <= 0:
			rotation.x = srotx*((distance-1.5)/2.5)
			if rotation.x > 0: rotation.x = 0

func _on_area_body_entered(body):
	if body.is_in_group("playergroup"):
		if !fromplayer:
			var alsoonwall = false
			for bodyguh in $area.get_overlapping_bodies():
				if bodyguh.is_in_group("glasswall"):
					alsoonwall = true
				if bodyguh.is_in_group("riotshield"):
					if bodyguh.get_parent().get_parent().up:
						alsoonwall = true
			if !alsoonwall:
				if player.camera.current:
					body.hurt(10*damagemult*scale.x, "ragdoll")
	if body.is_in_group("gunman"):
		if fromplayer && !$hit.visible:
			body.hurt(50*scale.x)
	if body.is_in_group("glasswall"):
		body.get_parent().get_parent().hit(50*scale.x)
	if body.is_in_group("riotshield"):
		if body.get_parent().get_parent().up:
			rotation.y = lerp_angle(player.rotation.y, atan2(player.position.x-gunman.position.x, player.position.z-gunman.position.z), 0.75)
			position.y = 1
			fromplayer = true
			body.get_parent().get_parent().hit(10*scale.x)
	if body.is_in_group("drone"):
		body.get_parent().boom()
	var onriot = false
	for bodyguh in $area.get_overlapping_bodies():
		if bodyguh.is_in_group("riotshield"):
			onriot = true
	if (!body.is_in_group("gunman") && !fromplayer) || (body.is_in_group("gunman") && fromplayer):
		if !onriot:
			$hit.show()
			$Icosphere.hide()
			$Icosphere2.hide()
			$Timer.start()
			if body.is_in_group("gunman"):
				$audio.stream = load("res://audio/shootperson.wav")
				$audio.play()
			elif body.is_in_group("playergroup"):
				pass
			else:
				$audio.stream = load("res://audio/shootground.wav")
				$audio.play()
func _on_timer_timeout():
	queue_free()
