extends MeshInstance3D

@onready var main = get_node("/root").get_node("main")
@onready var player = main.get_node("player")
@onready var map = main.get_node("map")

var hover = false

func _process(delta: float) -> void:
	$hover.visible = hover
	hover = false

func clicked():
	main.itemdata = {}
	main.savedhand = {"item": "", "extrainfo": {}}
	main.lilwizardtime = 1
	main._on_died_animation_finished(true)
	main.save_game()
