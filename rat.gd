extends Node3D
var velocity = Vector3.ZERO
var time = 0
var dietime = randf_range(20, 30)
var speed = 75
@onready var player = $"../../player"
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta
	$particles2.rotate_y(delta*100)
	if time < dietime: 
		if !$floordetect.is_colliding(): velocity.y -= 0.01*delta*speed
		else:
			position.y = pow(sin(time*10), 2)*0.1
			velocity.y = 0
		rotate_y(randf_range(-1*delta*speed, 1*delta*speed))
		var totalvel = sqrt(pow(velocity.x, 2)+pow(velocity.z, 2))
		if totalvel < 0.15:
			velocity.x = sin(rotation.y)*0.1
			velocity.z = cos(rotation.y)*0.1
		else:
			velocity *= 1-(0.05*delta*speed)
		position += velocity*delta*speed
	else:
		rotation_degrees.z = 180
		if velocity.y < 0: queue_free()
		position.y = 0.4
		$particles.emitting = false
		$particles2.emitting = false
		$audio.stop()
	
	if velocity.y < -10: queue_free()


func _on_timer_timeout():
	if time < dietime:
		for person in $radiation.get_overlapping_bodies():
			if person.is_in_group("playergroup"):
				person.hurt(5, "radiation")
