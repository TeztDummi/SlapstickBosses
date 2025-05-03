extends Node3D
var alleyobjects = []

# Called when the node enters the scene tree for the first time.
func _ready():
	for child in get_parent().get_children():
		if child.has_meta("alley"):
			alleyobjects.append(child)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var showalley = false
	for body in $Node3D/Area3D.get_overlapping_bodies():
		if body.is_in_group("playergroup"):
			showalley = true
	$backalley.visible = showalley
	var i = 0
	for object in alleyobjects:
		if object != null:
			object.visible = showalley
		else:
			alleyobjects[i]
		i += 1
