extends Node3D
var projectile = null
var checkcan = false

func _ready() -> void:
	$spherewarning.get_child(0).play("default")

func _on_spawntimer_timeout() -> void:
	print("GRAAAAAAAAAAAAAAAA")
	var path = "res://sodaboss/sodacan.tscn"
	var rand = randi_range(0, 2)
	if rand == 0:
		path = "res://sodaboss/popcop.tscn"
	if rand == 1:
		path = "res://sodaboss/bigpopcop.tscn"
		
	ResourceLoader.load_threaded_request(path)
	
	var progress = []
	ResourceLoader.load_threaded_get_status(path, progress)
	if progress[0] == 1:
		var projectile = ResourceLoader.load_threaded_get(path).instantiate()
		projectile.position = global_position
		projectile.position.y += 15
		$"../../".add_child(projectile)
		checkcan = true
	$leavetimer.start()

func _on_leavetimer_timeout() -> void:
	queue_free()
