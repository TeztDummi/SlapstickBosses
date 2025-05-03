extends RigidBody3D


# Called when the node enters the scene tree for the first time.
func _ready():
	$audio.stream = load("res://audio/dumbfuck/dumbfuck ("+str(randi_range(1, 4))+").wav")
	$audio.play()
