extends MeshInstance3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$MeshInstance3D/smallorb.rotation.y += 0.08*delta*75
	$MeshInstance3D2/mediumorb.rotation.y += 0.06*delta*75
	$MeshInstance3D3/largeorb.rotation.y += 0.04*delta*75
	var pspeed = 0.5
	$propeller.rotation.y += pspeed*delta*75
	$propeller2.rotation.y = $propeller.rotation.y
	$propeller3.rotation.y = $propeller.rotation.y
	$propeller4.rotation.y = $propeller.rotation.y
