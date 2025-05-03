extends MeshInstance3D
var hover = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$outline.visible = hover
	hover = false
