extends StaticBody3D
var delay = 0
var time = 1
var run = false
var changetex = false
@onready var player = $"../../player"
var savedatadelay = 0.2
var spot = ""

func _ready():
	time = $"../../".gearmotime
	$mesh.get_surface_override_material(0).albedo_texture = load("res://characters/gearmostand.tres")
	savedatadelay = -10
	
	if time > 3:
		var spotobject = $"../gearmospots".get_children().pick_random()
		spot = spotobject.name
		position = spotobject.position
			
func talk():
	if delay <= 0:
		if spot == "":
			if time == 1: $"../../canvas/hud/talk".start("gearmo", self)
			if time == 2: $"../../canvas/hud/talk".start("gearmo2nd", self)
			if time >= 3:
				$"../../canvas/hud/talk".start("gearmo3rd")
				run = true
				changetex = true
		else:
			$"../../canvas/hud/talk".start("gearmo"+spot)
			if spot == "alley":
				run = true
				changetex = true
			if spot == "billboard":
				var direction = Vector2(player.position.x-position.x, player.position.z-position.z).normalized()
				player.velocity.x = direction.x*40
				player.velocity.y = 5
				player.velocity.z = direction.y*40
		time += 1
		$"../../".gearmotime = time
		delay = 1
	
func _process(delta):
	if delay > 0: delay -= delta
	if run:
		if changetex:
			$mesh.get_surface_override_material(0).albedo_texture = load("res://characters/gearmorun.tres")
			changetex = false
		var direction = Vector2(player.position.x-position.x, player.position.z-position.z).normalized()
		position.x += direction.x*-10*delta
		position.z += direction.y*-10*delta
		
func removetime():
	print("remove time")
	$"../../".gearmotime -= 1
	time = $"../../".gearmotime
	
