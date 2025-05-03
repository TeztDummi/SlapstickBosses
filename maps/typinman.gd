extends Node3D
@onready var player = $"../../player"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var previousrot = $head.rotation
	$head.look_at(player.position)
	$head.rotation.x = lerp_angle(previousrot.x, $head.rotation.x, delta)
	$head.rotation.y = lerp_angle(previousrot.y, $head.rotation.y, delta)
	$head.rotation.z = lerp_angle(previousrot.z, $head.rotation.z, delta)
