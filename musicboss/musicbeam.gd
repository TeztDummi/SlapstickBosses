extends Node3D
var hitplayer = false
var areaon = false
var green = 0
var rotatemode = false
var rotaterandom = randf_range(-1, 1)
@onready var player = $"../../player"
var murder = false
var murderoff = randf_range(0, 5)

func _ready():
	var rand = randf_range(0, 1)
	$Marker3D/Plane.get_surface_override_material(0).albedo_color = Color.from_hsv(rand, 1, 1)
	$Marker3D/warning.get_surface_override_material(0).albedo_color = Color.from_hsv(rand, 1, 1, 0.1)
	if green == 1:
		$Marker3D/Plane.get_surface_override_material(0).albedo_color = Color.from_hsv(0.333, 1, 0.5)
		$Marker3D/warning.get_surface_override_material(0).albedo_color = Color.from_hsv(0.333, 1, 0.5, 0.1)

func _process(delta):
	if murder:
		position = player.position
		position.y += 1.5
		position.z += murderoff
	if rotatemode:
		rotation.y += rotaterandom*delta*1
	for body in $Marker3D/beam/Area3D.get_overlapping_bodies():
		if body.is_in_group("playergroup"):
			if !body.dead && !hitplayer && areaon:
				if green:
					if body.health <= 20:
						$"../../".setAchievement("greenbeam")
				if murder: body.hurt(90, "bluelaser")
				elif !rotatemode: body.hurt(20, "bluelaser")
				else: body.hurt(30, "bluelaser")
				hitplayer = true
				
func turnareaon():
	areaon = true
	player.screenshake += 0.2
