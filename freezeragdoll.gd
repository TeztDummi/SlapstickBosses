extends Node3D

@onready var main = get_node("/root").get_node("main")

var color = Color(1, 1, 1)
var head = "res://objects/defaultobject.tscn"
var vel = Vector3.ZERO
var spinmult = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	var loadhead = load(head).instantiate()
	$head.add_child(loadhead)
	if loadhead.has_meta("death"):
		loadhead.death()
	for child in loadhead.get_children():
		if child is MeshInstance3D:
			for staticbod in child.get_children():
				if staticbod is StaticBody3D:
					staticbod.get_child(0).reparent($head, true)
					staticbod.queue_free()
	var loadoutfit = load(main.outfit).instantiate()
	if loadoutfit.has_node("Armature/Skeleton3D/head"):
		var headattachments = loadoutfit.get_node("Armature/Skeleton3D/head")
		for child in headattachments.get_children():
			child.reparent($body/attachments)
			child.position = headattachments.position
			child.rotation = headattachments.rotation-$body/attachments.rotation
			child.scale = headattachments.scale
	var mainbody = loadoutfit.get_node("Armature/Skeleton3D/main")
	$body/Cube.name = "deletebody"
	$body/deletebody.queue_free()
	mainbody.reparent($body)
	mainbody.position = Vector3.ZERO
	mainbody.rotation = Vector3.ZERO
	mainbody.name = "Cube"
	if main.outfitcolors.has(main.outfit):
		if mainbody.has_meta("extracolors"):
			for i in range(1, mainbody.get_meta("extracolors")+1):
				var curcolorrgb = main.outfitcolors[main.outfit][str(i)]
				var curcolor = Color(curcolorrgb["r"], curcolorrgb["g"], curcolorrgb["b"])
				mainbody.get_surface_override_material(i).albedo_color = curcolor
	
	$body/Cube.get_surface_override_material(0).albedo_color = color
