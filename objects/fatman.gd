extends Node3D
var reducelight = false

# Called when the node enters the scene tree for the first time.
func death():
	$fatman2.hide()
	$boomlight.show()
	$fatman3.show()
	reducelight = true
	
func _process(delta):
	if reducelight:
		$boomlight.light_energy = lerp($boomlight.light_energy, 0.0, delta*2)


func _on_timer_timeout():
	if reducelight:
		$fatman3.hide()
