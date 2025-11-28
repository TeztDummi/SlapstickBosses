extends MeshInstance3D

var breaking = 0
var health = 1
var ice = false
@onready var startpos = position
var stages = [0.75, 0.5, 0.25]

func _ready() -> void:
	var dupe = get_surface_override_material(0).duplicate()
	set_surface_override_material(0, dupe)
	var dupe2 = dupe.next_pass.duplicate()
	dupe.next_pass = dupe2
	
	$particles.global_rotation = Vector3.ZERO

func _process(delta: float) -> void:
	if health > 0:
		if breaking > 0:
			health -= delta/8*breaking
		elif health < 1:
			pass
			#health += delta/32
		else:
			health = 1
			
		if health < 1 || ice:
			var fac = 1-health
			var col = Color(lerpf(0, 1, fac), lerpf(112/255.0, 0, fac), lerpf(1, 0, fac))
			position.x = startpos.x+randf_range(-1, 1)*fac*0.25
			position.y = startpos.y+randf_range(-1, 1)*fac*0.25
			position.z = startpos.z+randf_range(-1, 1)*fac*0.25
			$StaticBody3D.global_position = startpos
			get_surface_override_material(0).set_shader_parameter("color", col)
			
			if stages.size() > 0:
				if health < stages[0]:
					$particles.restart()
					stages.remove_at(0)
					get_surface_override_material(0).next_pass.albedo_color.a += 0.15
		
		if health <= 0:
			hurt()
		breaking = 0

func hurt():
	health = 0
	visibility_range_end = 0.01
	$StaticBody3D/CollisionShape3D.disabled = true
	$particles.restart()
	get_parent().startbreak()
