extends Node3D

@onready var main = get_node("/root").get_node("main")
@onready var player = main.get_node("player")

var level = "testlevel"
@onready var startpos = position
var started = false
var levelobject
var preview
var hover = false
var trans = 0
var pstartpos
var pstartscl
var transition = "none"

func _ready() -> void:
	
	level = get_meta("level")
	
	var previewlevel = load("res://levels/"+level+".tscn").instantiate()
	for child in previewlevel.get_children():
		print(child)
		if child.is_in_group("preview"):
			for childchild in child.get_children():
				if childchild.name != "preview":
					childchild.queue_free()
				else:
					childchild.show()
			child.reparent($preview, false)
			print("added preview part")
		if child.name == "bounds":
			child.reparent($preview, false)
			print("added bounds")
	if $preview.has_node("bounds"):
		var bounds = $preview.get_node("bounds")
		var biggestaxis = bounds.scale.x
		if bounds.scale.y > biggestaxis:
			biggestaxis = bounds.scale.y
		if bounds.scale.z > biggestaxis:
			biggestaxis = bounds.scale.z
		
		pstartscl = ((1.0/biggestaxis)/2.0)
		pstartpos = position+$cube.position-bounds.position*pstartscl
		$preview.scale = Vector3.ONE*pstartscl
		$preview.global_position = pstartpos
		print("set pos and scale")
	
func _process(delta: float) -> void:
	
	$fracture.rotate_y(delta*0.5)
	$outline.rotate_y(delta*0.5)
	
	if transition != "none":
		hover = false
	$outline.visible = hover
	hover = false
	
	if transition == "start":
		trans += delta/2
		$preview.show()
	if transition == "end":
		trans -= delta/2
		$preview.show()
	if transition != "none":
		$preview.rotation.y = 0
		if trans > 1:
			trans = 1
			transition = "none"
			$preview.hide()
			$"../".add_child(levelobject)
			if levelobject.has_node("end"):
				position = levelobject.get_node("end").global_position
				print("set end pos")
				$fracture/anim.play("RESET")
		if trans < 0:
			trans = 0
			transition = "none"
	else:
		pass
		#$preview.rotate_y(-delta*0.5)
		

	var xztrans = pow(trans, 6)
	var scltrans = pow(clampf(trans*1.5, 0, 1), 6)
	var yoff = 1
	var ytrans
	if trans < 0.5:
		ytrans = (1-pow(1-trans*2, 2))*yoff
	else:
		ytrans = (1-pow(1-(1-trans)*2, 2))*yoff
	
	$preview.global_position.x = lerpf(pstartpos.x, startpos.x, xztrans)
	$preview.global_position.y = lerpf(pstartpos.y, startpos.y, xztrans)
	$preview.global_position.y += ytrans
	$preview.global_position.z = lerpf(pstartpos.z, startpos.z, xztrans)
	$preview.scale = Vector3.ONE*lerpf(pstartscl, 1, scltrans)

func clicked():
	if transition == "none":
		if !started:
			if main.get_node("map").currentlevel == "none":
				levelobject = load("res://levels/"+level+".tscn").instantiate()
				levelobject.position = global_position
				transition = "start"
				$fracture/anim.play("Animation")
				
				started = true
				main.get_node("map").currentlevel = level
				if level == "slidelevel":
					main.get_node("map").lobbypower(false)
					player.cancrouch = true
					player.falloff = false
		else:
			levelobject.queue_free()
			transition = "end"
			
			$fracture/anim.play_backwards("Animation")
			
			position = startpos
			player.position = position
			player.position.y += 3
			player.position.z += 5
			started = false
			
			main.get_node("map").lobbypower(true)
			main.get_node("map").currentlevel = "none"
