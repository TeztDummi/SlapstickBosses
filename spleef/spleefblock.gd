extends Node3D

var breaking = 0
var health = 1
var ice = false

func _ready() -> void:
	var dupe = $Cube.get_surface_override_material(0).duplicate()
	$Cube.set_surface_override_material(0, dupe)
	var icedupe = $Cube.get_surface_override_material(0).next_pass.duplicate()
	$Cube.get_surface_override_material(0).next_pass = icedupe
	
	rotation.y = randi_range(0, 3)*(PI/2)
	
	if get_parent().is_in_group("startdead"):
		health = 0
		$Cube.hide()
		$static/col.disabled = true
		$particlecol.hide()

func _process(delta: float) -> void:
	if health > 0:
		if breaking > 0:
			if ice:
				health -= delta/1.5
			else:
				health -= delta*8*breaking
		elif health < 1:
			health += delta/4
		else:
			health = 1
			
		if health < 1 || ice:
			var fac = 0.5+health/2
			if ice: fac = health
			$Cube.get_surface_override_material(0).albedo_color = Color(1, fac, fac)
			if ice:
				$Cube.get_surface_override_material(0).next_pass.set_shader_parameter("alpha", 0.5)
			else:
				$Cube.get_surface_override_material(0).next_pass.set_shader_parameter("alpha", 1)
		
		if health <= 0:
			hurt()
		breaking = 0

func hurt():
	health = 0
	$Cube.hide()
	$static/col.disabled = true
	$particlecol.hide()
	if ice:
		$iceparticles.restart()
		$audio.stream = load("res://audio/spleef/icebreak.mp3")
	else:
		$particles.restart()
		$audio.stream = load("res://audio/spleef/blockbreak.mp3")
	$audio.pitch_scale = randf_range(0.8, 1.2)
	$audio.play()
		
func revive():
	if !$Cube.visible && !ice:
		health = 1
		$anim.play("revive")
		$Cube.get_surface_override_material(0).albedo_color = Color(1, 1, 1)
		$Cube.show()
		$static/col.disabled = false
		$particlecol.show()
