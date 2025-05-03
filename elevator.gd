extends AnimatableBody3D

var startpos = position
var time = 0
var uppy = false
var height = 16
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if name == "elevatormore":
		height = 18
	if uppy:
		time += delta*1.2
		if time < PI/2:
			position.y = startpos.y+(pow(sin(time), 2)*height)
			if $elevatordoorleft.scale.z < 0.85:
				$elevatordoorleft.scale.z += delta*2
				$elevatordoorright.scale.z += delta*2
		else:
			if $elevatordoorleft.scale.z > 0:
				$elevatordoorleft.scale.z -= delta*2
				$elevatordoorright.scale.z -= delta*2
		if time >= PI/2+2:
			uppy = false
	else:
		if time >= PI/2:
			time = PI/2
		if time > 0:
			time -= delta*1.2
			position.y = startpos.y+(pow(sin(time), 2)*height)
			if $elevatordoorleft.scale.z < 0.85:
				$elevatordoorleft.scale.z += delta*2
				$elevatordoorright.scale.z += delta*2
		else:
			if $elevatordoorleft.scale.z > 0:
				$elevatordoorleft.scale.z -= delta*2
				$elevatordoorright.scale.z -= delta*2

func _on_area_body_entered(body):
	if !body.isdead:
		uppy = !uppy
