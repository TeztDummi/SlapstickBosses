extends Node3D

var boom = false
var vel = Vector3.ZERO
var rot = Vector3(randf_range(-1,1), randf_range(-1,1), randf_range(-1,1))
# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !boom:
		position += vel
		rotation += rot*0.1
	
func explode():
	if !boom:
		boom = true
		for body in $boomarea.get_overlapping_bodies():
			if body.get_parent().get_parent().name == "tilesphere":
				var hurt = 4-sqrt(pow(position.x-body.global_position.x, 2) + pow(position.y-body.global_position.y, 2) + pow(position.z-body.global_position.z, 2))
				body.get_parent().hurt(hurt*45)
			
			if body.is_in_group("playergroup"):
				body.hurt(25, "bluelaser")
				
			$mesh.hide()
			$boom.emitting = true
			$boom2.emitting = true
			$Timer.start()

func _on_area_body_entered(body):
	print(body)
	if body.get_parent().get_parent().name == "tilesphere":
		explode()
	if body.is_in_group("playergroup"):
		explode()

func _on_timer_timeout():
	queue_free()
