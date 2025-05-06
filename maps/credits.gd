extends Node3D
var diff = -1
var hue = 0

func _process(delta: float) -> void:
	hue += delta/2
	$SubViewport/bigcredits.modulate = Color.from_hsv(hue, 0.5, 1)
	$Sprite3D/particles.process_material.color = Color.from_hsv(hue, 1, 1, 50.0/255.0)

func copycredits():
	DisplayServer.clipboard_set($SubViewport/bigcredits.text+"\n\n"+$SubViewport/credits.text)
	$copy/outline/SubViewport/Label.text = "Copied to clipboard"
