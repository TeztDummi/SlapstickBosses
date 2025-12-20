extends Node3D

@onready var main = get_node("/root").get_node("main")
@onready var player = main.get_node("player")
@onready var map = main.get_node("map")

var speed = 0.3

func _process(delta: float) -> void:
	if visible:
		position.x = lerpf(position.x, player.position.x, delta*speed)
		position.y = lerpf(position.y, player.position.y, delta*speed*1.5)
		position.z = lerpf(position.z, player.position.z, delta*speed)
		var dist = position.distance_to(player.position)
		var maxdist = 20
		if dist < maxdist:
			var pitch = 1.65*((maxdist-dist)/maxdist)
			$audio.pitch_scale = pitch
		$audio.volume_linear = 1
	else:
		$audio.volume_linear = 0

func _on_hurttimer_timeout() -> void:
	if visible:
		for body in $hurt.get_overlapping_bodies():
			if body.is_in_group("playergroup"):
				body.hurt(1, "freeze")
