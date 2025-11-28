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
		chaintobreak += 1
	else:
		$"../breakchain".stop()
		get_parent().endbreak()
	
