extends Node3D
var diff = -1
var hover = false
var triedtograbpaint = false

func _ready() -> void:
	if $"../".haspaint:
		$acrylicpaint.queue_free()
		
func _process(delta: float) -> void:
	if $acrylicpaint != null:
		$acrylicpaint/hover.visible = hover
		hover = false

func takepaint():
	if $canman.eyesshown:
		if !triedtograbpaint:
			$"../canvas/hud/talk".start("canmanstealingpaint")
			triedtograbpaint = true
	else:
		$acrylicpaint.queue_free()
		$"../sfx".stream = load("res://audio/grab.mp3")
		$"../sfx".play()
		$"../".haspaint = true
		$"../".save_game()
		
