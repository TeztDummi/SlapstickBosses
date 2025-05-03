extends StaticBody3D
var delay = 0
var time = 1
@onready var player = $"../../player"
var savedatadelay = 0.2

func talk():
	if delay <= 0:
		if time == 1: $"../../canvas/hud/talk".start("gearmo")
		if time == 2: $"../../canvas/hud/talk".start("gearmo2nd")
		if time >= 3: $"../../canvas/hud/talk".start("gearmo3rd")
		time += 1
		$"../../".gearmotime = time
		delay = 1
	
func _process(delta):
	if savedatadelay > 0: savedatadelay -= delta
	elif savedatadelay != -10:
		time = $"../../".gearmotime
		$mesh.get_surface_override_material(0).albedo_texture = load("res://characters/gearmostand.tres")
		savedatadelay = -10
	if delay > 0: delay -= delta
