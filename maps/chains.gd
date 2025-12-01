extends Node3D

var chaintobreak = 0
var started = false

func startbreak():
	if !started:
		$"../breakchain".start()
		started = true
	

func _on_breakchain_timeout() -> void:
	var children = get_children()
	if children.size() > chaintobreak:
		children[chaintobreak].hurt()
		var tempaudio = load("res://tempaudio.tscn").instantiate()
		children[chaintobreak].add_child(tempaudio)
		tempaudio.stream = load("res://audio/spleef/chainbreak.mp3")
		tempaudio.pitch_scale = 0.75+chaintobreak*0.1
		tempaudio.volume_linear = 2
		tempaudio.play()
		chaintobreak += 1
	else:
		$"../breakchain".stop()
		get_parent().endbreak()
	
