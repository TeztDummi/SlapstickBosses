extends Node3D

var up = true
var exploded = false
@onready var realy = position.y

func _ready() -> void:
	rotation.x = PI
	var dupe = $ball.get_surface_override_material(0).duplicate()
	$ball.set_surface_override_material(0, dupe)

func _on_textureupdate_timeout() -> void:
	$ball.get_surface_override_material(0).uv1_offset.y += -0.03

func _process(delta: float) -> void:
	if position.y > 40:
		up = false
		position.x = floor(randf_range(-16, 16)/2)*2+1
		position.z = floor(randf_range(-16, 16)/2)*2+1
		rotation.x = 0
		
	if up:
		realy += delta*64
	else:
		realy -= delta*4
	position.y = round(realy*2)/2
		
	if !exploded:
		if $raycast.is_colliding():
			hurt()
			
func hurt():
	if !exploded:
		exploded = true
		$explodeparticles.emitting = true
		$particles.emitting = false
		$ball.hide()
		$static/col.disabled = true
		$colsphere.queue_free()
		for body in $area.get_overlapping_bodies():
			if body.is_in_group("spleefblock"):
				if !body.get_parent().ice:
					body.get_parent().hurt()
		
