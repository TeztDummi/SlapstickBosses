extends Node3D
var shrinktime = 200
var speed = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	var procdupe = $GPUParticles3D.process_material.duplicate()
	$GPUParticles3D.process_material = procdupe

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$shockwave.scale.x += delta*32*speed
	$shockwave.scale.z = $shockwave.scale.x
	$GPUParticles3D.process_material.emission_shape_scale.x = $shockwave.scale.x*0.14
	$GPUParticles3D.process_material.emission_shape_scale.z = $shockwave.scale.x*0.14
	if $shockwave.scale.x > shrinktime:
		$shockwave.scale.y -= delta*8*speed
		$GPUParticles3D.emitting = false
	if $shockwave.scale.y <= 0:
		queue_free()
