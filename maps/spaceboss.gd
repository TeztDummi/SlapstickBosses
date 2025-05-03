extends Node3D
var diff = -1
@onready var player = $"../player"

# Called when the node enters the scene tree for the first time.
func _ready():
	var gun = load("res://tasergun.tscn").instantiate()
	$"../player/camera/gun".add_child(gun)
	$"../player".scroll = 1
	player.spaceenergy = 20

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$tilesphere.rotate_x(delta*PI*0.01)
	$"../player".position = Vector3(0, -1.5, 0)
	$energy.text = str(player.spaceenergy)+"⚡"
