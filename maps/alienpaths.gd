extends Node3D

var run = false
@onready var pathfollow = PathFollow3D.new()

func _ready() -> void:
	if randf() <= 0.5:
		var path = get_children().pick_random()
		pathfollow.loop = false
		path.add_child(pathfollow)
		var alien = load("res://alienrig.tscn").instantiate()
		pathfollow.add_child(alien)
	
func start():
	run = true
	
func _process(delta: float) -> void:
	if run:
		pathfollow.progress += delta*40
		if pathfollow.progress_ratio >= 1:
			pathfollow.queue_free()
			run = false
