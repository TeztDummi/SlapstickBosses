extends Node3D

@onready var main = get_node("/root").get_node("main")

func _ready() -> void:
	clearoutfits()

func clearoutfits():
	for child in $outfits.get_children():
		child.queue_free()
	var outfitsnode = main.get_node("canvas/hud/outfits")
	var off = 0
	for outfit in outfitsnode.outfits:
		if main.unlockedoutfits.has(outfit) && outfit != "defaultplayer" && outfit != "oiledup":
			var loadoutfit = load("res://outfits/"+outfit+".tscn").instantiate()
			var mainbody = loadoutfit.get_node("Armature/Skeleton3D/main")
			mainbody.set_surface_override_material(0, StandardMaterial3D.new())
			mainbody.get_surface_override_material(0).transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_DEPTH_PRE_PASS
			mainbody.get_surface_override_material(0).albedo_color.a = 0
			$outfits.add_child(loadoutfit)
			mainbody = loadoutfit.get_node("Armature/Skeleton3D/main")
			if main.outfitcolors.has("res://outfits/"+outfit+".tscn"):
				if mainbody.has_meta("extracolors"):
					for i in range(1, mainbody.get_meta("extracolors")+1):
						var curcolorrgb = main.outfitcolors["res://outfits/"+outfit+".tscn"][str(i)]
						var curcolor = Color(curcolorrgb["r"], curcolorrgb["g"], curcolorrgb["b"])
						mainbody.get_surface_override_material(i).albedo_color = curcolor
			var hanger = load("res://hanger.tscn").instantiate()
			hanger.position.y = 1.8
			loadoutfit.add_child(hanger)
			loadoutfit.position.z = off
			off += 1
	
	$babyoil.visible = main.unlockedoutfits.has("oiledup")
