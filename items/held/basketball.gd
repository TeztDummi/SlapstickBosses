extends Node3D
var extrainfo = {"guh": true}
var held = false
var item = "basketball"
var placed
var preview
var delay = 0.5
var rusure = false
var hover = false
var rot = 0
var distlimit = 1.5
var power = 0
var goingup = true

# Called when the node enters the scene tree for the first time.
func _ready():
	if has_meta("held"):
		held = get_meta("held")
	if held:
		placed = load("res://items/placed/"+item+".tscn").instantiate()
	else:
		if has_meta("price"):
			$pricetag.show()
			$RigidBody3D.freeze = true
			if $"../..".boughtitems.has(item):
				queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if has_meta("price"):
		#pricetag
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
	if !held:
		if $RigidBody3D.global_position.y <= -20:
			$RigidBody3D.global_position = $"../../player/".global_position
			$RigidBody3D.global_position.x -= sin($"../../player/".rotation.y)*2
			$RigidBody3D.global_position.z -= cos($"../../player/".rotation.y)*2
			$RigidBody3D.global_position.y += 2
			$RigidBody3D.linear_velocity = Vector3.ZERO
	else:
		if Input.is_action_pressed("click"):
			if goingup:
				power *= (1+delta*2)
			else:
				power *= (1-delta*2)
			if power >= 1:
				goingup = false
				power = 1
			$SubViewport/healthbar.value = power

func _unhandled_input(event):
	if held:
		if Input.is_action_just_pressed("click"):
			power = 0.1
		if delay <= 0:
			if Input.is_action_just_released("click"):
				var player = $"../../../"
				placed.global_position = $throwfrom.global_position
				placed.extrainfo = extrainfo
				placed.rotation.y = player.rotation.y
				if power >= 0.95:
					power = 5
				placed.get_child(0).linear_velocity = ($throwfrom.global_position-global_position).normalized()*power*30
				if power < 1:
					placed.get_child(0).linear_velocity.y += power*10
				placed.get_child(0).angular_velocity = Vector3(power*randf_range(-10, 10), power*randf_range(-10, 10), power*randf_range(-10, 10))
				$"../../../../map".add_child(placed)
				$"../../../../".itemdata[item] = {
					"map": "res://maps/"+$"../../../../map".get_child(0).name+".tscn",
					"posx": global_position.x,
					"posy": global_position.y,
					"posz": global_position.z,
					"extrainfo": extrainfo,
					"rot": 0
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
						#grab or spend bits and grab
						if has_meta("price"):
							$"../..".bits -= get_meta("price")
							$"../..".boughtitems[item] = true
							$"../../sfx2".stream = load("res://audio/spendbits.mp3")
							$"../../sfx2".play()
						var grab = load("res://items/held/"+item+".tscn").instantiate()
						print(grab)
						grab.extrainfo = extrainfo
						grab.rot = global_rotation.y
						$"../../player/camera/gun".add_child(grab)
						$"../../".itemdata.erase(item)
						$"../../".save_game()
						$"../../player".scroll = 1
						queue_free()

func _on_rigid_body_3d_body_entered(body):
	var amount = sqrt(pow($RigidBody3D.linear_velocity.x, 2)+pow($RigidBody3D.linear_velocity.y, 2)+pow($RigidBody3D.linear_velocity.z, 2))
	print(amount)
