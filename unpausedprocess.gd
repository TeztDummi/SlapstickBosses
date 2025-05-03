extends Node3D

var pausedcuzoverlay = false

func _ready():
	Steam.overlay_toggled.connect(_on_overlay_toggled)

func _process(delta):
	Steam.run_callbacks()
				
func _on_overlay_toggled(param1, param2, param3):
	if param1:
		if !get_tree().paused:
			pausedcuzoverlay = true
			get_tree().paused = true
	else:
		if pausedcuzoverlay:
			get_tree().paused = false
			pausedcuzoverlay = false
	print("param1: "+str(param1))
	print("param2: "+str(param2))
	print("param3: "+str(param3))
	print("pausedcuzoverlay: "+str(pausedcuzoverlay))
