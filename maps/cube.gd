extends MeshInstance3D
@onready var player = $"../../player"
var followplayer = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	rotate_y(delta*0.1)
	if followplayer: position = player.position
