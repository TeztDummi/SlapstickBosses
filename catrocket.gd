extends Node3D

var exploded = false
var pos = Vector3.ZERO
@onready var player = $"../../player"

# Called when the node enters the scene tree for the first time.
func _ready():
	look_at(pos+position)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	print(pos)
	for guh in $hitdetect.get_overlapping_bodies():
		if !exploded:
			exploded = true
			$explode.emitting = true
			$Timer.start()
			$rocket.hide()
			$trail.emitting = false
			$audio.play()
			for body in $area.get_overlapping_bodies():
				player.screenshake += 0.2
				if body.is_in_group("cat"):
					body.hurt(100)
				if body.is_in_group("playergroup"):
					body.hurt(1, "bluelaser")
					var dir = (body.global_position-global_position).normalized()
					body.velocity += dir*50
					body.velocity.y += 5
	position -= pos*delta*50

func _on_timer_timeout():
	queue_free()
