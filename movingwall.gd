extends AnimatableBody3D

var off = 0
var delay = 0.5
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var thex = position.x
	print(thex)
	if thex > 100:
		off = 211.0
	if delay > 0:
		delay -= delta
	else:
		if is_in_group("moveleft"): thex -= delta*10
		else: thex += delta*10
		thex = wrapf(thex, -25+off, 25+off)
		
		position = Vector3(thex, position.y, position.z)
