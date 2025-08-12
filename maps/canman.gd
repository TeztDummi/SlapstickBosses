extends StaticBody3D
@onready var player = $"../../player"
var eyesshown = false
var savedatadelay = 0.2
var time = 1
var delay = 0

func _ready() -> void:
	$mesh.get_surface_override_material(0).albedo_texture = load("res://characters/canmaneyeshidden.tres")
# Called when the node enters the scene tree for the first time.
func talk():
	if delay <= 0:
		if time == 1: $"../../canvas/hud/talk".start("canmanstart")
		if time >= 2: $"../../canvas/hud/talk".start("canman2nd")
		time += 1
		$"../../".canmantime = time
		delay = 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if savedatadelay > 0: savedatadelay -= delta
	elif savedatadelay != -10:
		time = $"../../".canmantime
		savedatadelay = -10
	if delay > 0: delay -= delta
	var dist = sqrt(pow(position.x-player.position.x, 2)+pow(position.z-player.position.z, 2))
	var totalvel = sqrt(pow(player.velocity.x, 2)+pow(player.velocity.y, 2)+pow(player.velocity.z, 2))
	
	if dist <= 7 && totalvel >= 7:
		print(totalvel)
		if !eyesshown:
			$mesh.get_surface_override_material(0).albedo_texture = load("res://characters/canmaneyeup.tres")
			$Timer.start()
			eyesshown = true

func _on_timer_timeout():
	$mesh.get_surface_override_material(0).albedo_texture = load("res://characters/canman.tres")
