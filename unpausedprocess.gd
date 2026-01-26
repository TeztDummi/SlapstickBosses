extends Node3D

var pausedcuzoverlay = false

var musictransition = 1.0
var musictransspeed = 1

func _ready():
	Steam.overlay_toggled.connect(_on_overlay_toggled)

func _process(delta):
	Steam.run_callbacks()

	if musictransition < 1: musictransition += delta/musictransspeed
	else: musictransition = 1
	
	$"../music".volume_linear = musictransition
	$"../musictransition".volume_linear = 1-musictransition
	
	if Input.is_action_just_pressed("f11"):
		$"../"._on_fullscreen_pressed()
	if Input.is_action_just_pressed("x"):
		if $"../canvas/hud/steamdisconnect".visible:
			$"../canvas/hud/steamdisconnect".hide()
				
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
