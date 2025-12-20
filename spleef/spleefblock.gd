extends Node3D

var breaking = 0
var health = 1
var ice = false
var issuper = false
var superuvoff = 0

func _ready() -> void:
	var dupe = $Cube.get_surface_override_material(0).duplicate()
	$Cube.set_surface_override_material(0, dupe)
	var icedupe = $Cube.get_surface_override_material(0).next_pass.duplicate()
	$Cube.get_surface_override_material(0).next_pass = icedupe
	var supericedupe = icedupe.next_pass.duplicate()
	icedupe.next_pass = supericedupe
	
	rotation.y = randi_range(0, 3)*(PI/2)
	
	if get_parent().is_in_group("startdead"):
		health = 0
		$Cube.hide()
		$warning.show()
		$static/col.disabled = true
		$particlecol.hide()
		
func setsuper(val):
	var mat = $Cube.get_surface_override_material(0).next_pass.next_pass
	if val:
		mat.albedo_color.a = 1
	else:
		mat.albedo_color.a = 0
	issuper = val
	print("block set super: "+str(val))

func _process(delta: float) -> void:
	if health > 0 && get_parent().visible:
		if !issuper:
			if breaking > 0:
				if ice:
					health -= delta/1.5
				else:
					health -= delta*8*breaking
			elif health < 1:
				health += delta/4
			else:
				health = 1
		else:
			if breaking > 0:
				var mat = $Cube.get_surface_override_material(0).next_pass.next_pass
				superuvoff -= delta/2
				mat.uv1_offset.y = round(superuvoff/0.05)*0.05
			
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

func hurt(particles = true):
	health = 0
	$Cube.hide()
	$warning.show()
	$static/col.disabled = true
	$particlecol.hide()
	
	if particles:
		if ice:
			$iceparticles.restart()
			$audio.stream = load("res://audio/spleef/icebreak.mp3")
		else:
			$particles.restart()
			$audio.stream = load("res://audio/spleef/blockbreak.mp3")
	$audio.pitch_scale = randf_range(0.8, 1.2)
	$audio.play()
	
func warning():
	if !$anim.is_playing():
		$anim.play("warning")
		
func revive():
	if !$Cube.visible && !ice:
		health = 1
		$anim.play("revive")
		$Cube.get_surface_override_material(0).albedo_color = Color(1, 1, 1)
		$Cube.show()
		$warning.hide()
		$static/col.disabled = false
		$particlecol.show()
