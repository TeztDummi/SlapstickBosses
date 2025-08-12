extends Node3D
var extrainfo = {"haswizard" : false}
var held = false
var item = "jar"
var placed
var preview
@onready var jarpos = $jar.position
var delay = 0.5
var rusure = false
var hover = false
var rot = 0
var distlimit = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	
	if has_meta("held"):
		held = get_meta("held")
		
	if extrainfo["haswizard"]:
		if held:
			$lilwizard.show()
			$"../../../../".setAchievement("jarred")
		if !held:
			$lilwizard.show()
			$anim.play("default")
			
	if held:
		placed = load("res://items/placed/"+item+".tscn").instantiate()
		preview = placed.get_child(0)
		$preview.add_child(preview)
		preview.reparent($preview)
		preview.global_position = $"../../../".global_position
	else:
		if has_meta("price"):
			$pricetag.show()
			if $"../..".boughtitems.has(item) && $"../..".itemdata.has(item):
				queue_free()
			elif $"../..".boughtitems.has(item):
				$pricetag.hide()
				remove_meta("price")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if has_meta("price"):
		$pricetag/chalbits.scale.x = 5.4
		$pricetag/chalbits.scale.z = $pricetag/chalbits.scale.x
		if hover:
			$subview/bits.text = str("BUY?")
			if rusure:
				$subview/bits.text = str("U SURE?")
				if $"../..".bits < get_meta("price"): $subview/bits.text = str("UR POOR")
				$pricetag/chalbits.scale.x = 4
				$pricetag/chalbits.scale.z = $pricetag/chalbits.scale.x
			$pricetag/chalbits.position.x = 1.5
			$subview/bits/bitsoffset/bitssprite.hide()
		else:
			rusure = false
			$subview/bits.text = str(get_meta("price"))
			$pricetag/chalbits.position.x = 1
			$subview/bits/bitsoffset/bitssprite.position.x = $subview/bits.get_total_character_count()*20
			$subview/bits/bitsoffset/bitssprite.show()
	hover = false
	if delay > 0:
		delay -= delta
	if held:
		if extrainfo["haswizard"]:
			$jar.position.x = jarpos.x+randf_range(-0.01, 0.01)
			$lilwizard.position.x = jarpos.x+randf_range(-0.01, 0.01)
			$jar.position.z = jarpos.z+randf_range(-0.01, 0.01)
			$lilwizard.position.z = jarpos.z+randf_range(-0.01, 0.01)
		preview.hide()
		if $raycast.get_collider() != null:
			preview.global_position.x = round($raycast.get_collision_point().x*4)/4
			preview.global_position.y = $raycast.get_collision_point().y
			#if preview.get_child(0).get_collider() != null:
				#preview.global_position.y = lerp(preview.global_position.y, preview.get_child(0).get_collision_point().y, 0.1)
			preview.global_position.z = round($raycast.get_collision_point().z*4)/4
			if Input.is_action_pressed("rightclick"): preview.global_position = $raycast.get_collision_point()
			preview.global_rotation = Vector3.ZERO
			preview.global_rotation.y = rot
			if !$raycast.get_collider().is_in_group("painting") && !$raycast.get_collider().is_in_group("lilwizard") && !$raycast.get_collider().is_in_group("door") && !$raycast.get_collider().is_in_group("talk") && !$raycast.get_collider().is_in_group("noitems"):
				if sqrt(pow($"../../../".position.x-preview.global_position.x, 2) + pow($"../../../".position.z-preview.global_position.z, 2)) > distlimit:
					preview.show()
	if !held:
		if $floordetect.get_collider() != null:
			if delay <= 0:
				global_position.y = $floordetect.get_collision_point().y

func _unhandled_input(event):
	if held:
		if Input.is_action_just_pressed("otherscrollup"): rot -= PI/8
		if Input.is_action_just_pressed("otherscrolldown"): rot += PI/8
			
		if delay <= 0:
			if $raycast.get_collider() != null:
				if Input.is_action_just_pressed("click"):
					if $raycast.get_collider().is_in_group("lilwizard"):
						$raycast.get_collider().queue_free()
						$"../../../../".lilwizardtime = -1
						delay = 0.2
						$anim.play("swipe")
						$"../../../../".setAchievement("jarred")
					if preview.visible:
						placed.global_position = round(preview.global_position*4)/4
						placed.extrainfo = extrainfo
						placed.rotation.y = preview.global_rotation.y
						$"../../../../map".add_child(placed)
						$"../../../../".itemdata[item] = {
							"map": "res://maps/"+$"../../../../map".get_child(0).name+".tscn",
							"posx": placed.global_position.x,
							"posy": placed.global_position.y,
							"posz": placed.global_position.z,
							"extrainfo": extrainfo,
							"rot": placed.global_rotation.y
						}
						$"../../../../".save_game()
						queue_free()
func pickup():
	if !held:
		if delay <= 0:
			if has_meta("price") && !rusure:
				rusure = true
				delay = 0.5
			else: 
				var full = false
				for child in $"../../player/camera/gun".get_children():
					if child.has_meta("held"):
						full = true
					
				if !full:
					var cangrab = false
					if has_meta("price"):
						if $"../..".bits >= get_meta("price"): cangrab = true
					else: cangrab = true
					if cangrab:
						if has_meta("price"):
							$"../..".bits -= get_meta("price")
							$"../..".boughtitems[item] = true
							$"../../sfx2".stream = load("res://audio/spendbits.mp3")
							$"../../sfx2".play()
						var grab = load("res://items/held/"+item+".tscn").instantiate()
						grab.extrainfo = extrainfo
						grab.rot = global_rotation.y
						$"../../player/camera/gun".add_child(grab)
						$"../../".itemdata.erase(item)
						$"../../".save_game()
						$"../../player".scroll = 1
						queue_free()
			
func swipewizard():
	extrainfo["haswizard"] = true
	$lilwizard.show()
