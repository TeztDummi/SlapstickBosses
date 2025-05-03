extends Node3D
var time = 0
var done = false
var grow = false
@onready var player = $"../../player"

# Called when the node enters the scene tree for the first time.
func _ready():
	if $floordetect.is_colliding():
		position.y = $floordetect.get_collision_point().y
	$startparticle.emitting = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta
	$MeshInstance3D.get_surface_override_material(0).emission = Color.from_hsv(time, 1, 0.25)
	if grow:
		$MeshInstance3D.scale.x += delta
		$MeshInstance3D.scale.y += delta
		$MeshInstance3D.scale.z += delta
		
	if player.position != position:
		player.screenshake += delta*5*(1/(pow(position.x-player.position.x, 2) + pow(position.y-player.position.y, 2) + pow(position.z-player.position.z, 2)))

func _on_area_3d_body_entered(body):
	print("buh")
	if !done:
		if body.is_in_group("playergroup"):
			if !body.dead:
				print("guh")
				done = true
				grow = true
				$audio.stream = load("res://audio/portalenter.mp3")
				$audio.play()
				$"../../canvas/hud/transitionin".play()
				$"../../".transition = ["loadmap", "res://maps/lobby.tscn"]
