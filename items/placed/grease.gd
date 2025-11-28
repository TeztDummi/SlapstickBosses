extends CharacterBody3D
var extrainfo = {"guh": true}
var held = false
var item = "grease"
var placed
var preview
var delay = 0.5
var rusure = false
var hover = false
var rot = 0
var distlimit = 1.5
var petspeed = 1
var dontmove = false

@onready var main = get_node("/root").get_node("main")
@onready var player = main.get_node("player")

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# Called when the node enters the scene tree for the first time.
func _ready():
	if has_meta("held"):
		held = get_meta("held")
			
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
		if $"../..".boughtitems.has(item):
			$pricetag.hide()
			$cage.hide()
			$StaticBody3D.queue_free()
			remove_meta("price")
			print("TF HOE")

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
	if held:
		preview.hide()
		if $raycast.get_collider() != null:
			#preview position
			preview.global_position.x = round($raycast.get_collision_point().x*4)/4
			preview.global_position.y = $raycast.get_collision_point().y
			preview.global_position.z = round($raycast.get_collision_point().z*4)/4
			if Input.is_action_pressed("rightclick"): preview.global_position = $raycast.get_collision_point()
			preview.global_rotation = Vector3.ZERO
			preview.global_rotation.y = rot
			if !$raycast.get_collider().is_in_group("painting") && !$raycast.get_collider().is_in_group("door") && !$raycast.get_collider().is_in_group("talk") && !$raycast.get_collider().is_in_group("noitems"):
				if sqrt(pow($"../../../".position.x-preview.global_position.x, 2) + pow($"../../../".position.z-preview.global_position.z, 2)) > distlimit:
					preview.show()
	if !held:
		if $"../..".boughtitems.has(item):
			if petspeed > 1:
				petspeed *= 1-(delta*1)
				$purr.volume_linear += delta/30
			else:
				petspeed = 1
				$purr.volume_linear -= delta/60
				
			$purr.volume_linear = clampf($purr.volume_linear, 0, 0.2)
			
			$sprite.position.x = randf_range(-0.3, 0.3)*$purr.volume_linear
			$sprite.position.z = randf_range(-0.3, 0.3)*$purr.volume_linear
			
			if !is_on_floor():
				velocity.y -= delta*gravity
			if $sprite.animation == "roll": 
				$raycast.look_at(player.position)
				$raycast.rotation.x = 0
				$raycast2.rotation = $raycast.rotation
				var uppos = (player.position-position)
				uppos.y = 0
				$upray.position = uppos.normalized()*0.5
				
				if is_on_wall() || is_on_ceiling():
					velocity.y = 4
			if $sprite.animation == "roll" || $sprite.animation == "startroll":
				var direction = Vector2(player.position.x-global_position.x, player.position.z-global_position.z).normalized()
				if is_on_ceiling():
					direction *= -1
				velocity.x = direction.x*8
				velocity.z = direction.y*8
			else:
				velocity.x = 0
				velocity.z = 0
			if !$flytimer.is_stopped():
				velocity.y += delta*gravity*1.2
			else:
				if $sprite.animation == "fly":
					if is_on_floor():
						$sprite.play("endfly")
						$audio.stream = load("res://audio/grease/land.mp3")
						$audio.play()
						
			if global_position.y <= -100:
				global_position = $"../../player/".global_position
				global_position.x -= sin($"../../player/".rotation.y)*6
				global_position.z -= cos($"../../player/".rotation.y)*6
				global_position.y += 100
				$sprite.play("fly")
						
			move_and_slide()
		

func _unhandled_input(event):
	if held:
		if Input.is_action_just_pressed("otherscrollup"): rot -= PI/8
		if Input.is_action_just_pressed("otherscrolldown"): rot += PI/8
			
		if delay <= 0:
			if $raycast.get_collider() != null:
				if Input.is_action_just_pressed("click"):
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

func _on_action_timeout() -> void:
	var dist = sqrt(pow(global_position.x-player.position.x, 2)+pow(global_position.y-player.position.y, 2)+pow(global_position.z-player.position.z, 2))
	$action.wait_time = randf_range(6, 12)
	$action.start()
	
	if $sprite.animation != "step" && $sprite.animation != "roll" && !has_meta("price"):
		if dist >= 20:
			if $sprite.animation != "roll" && !dontmove:
				$sprite.play("startroll")
		else:
			if $sprite.animation == "spin" || $sprite.animation == "bounce":
				$sprite.play("idle")
				$audio.stop()
				$action.wait_time = randf_range(2, 4)
				$action.start()
			else:
				var rand = randi_range(0, 4)
				if rand == 0:
					$sprite.play("spin")
					$audio.stream = load("res://audio/grease/spin.mp3")
					$audio.play()
				if rand == 1:
					var meow = randi_range(0, 4)
					if meow < 4:
						$sprite.play("meow")
					else:
						$sprite.play("bigmeow")
					$audio.stream = load("res://audio/grease/meow"+str(meow)+".mp3")
					$audio.play()
				if rand == 2:
					$sprite.play("hairball")
					$audio.stream = load("res://audio/grease/hairball.mp3")
					$audio.play()
				if rand == 3:
					$sprite.play("startfly")
					$audio.stream = load("res://audio/grease/fly.mp3")
					$audio.play()
				if rand == 4:
					$sprite.play("bounce")
					$audio.stream = load("res://audio/grease/bounce.mp3")
					$audio.play()
			
func pet():
	if $sprite.animation != "pet" && $sprite.animation != "step":
		$sprite.play("pet", petspeed)

		$audio.stop()
		
		$pet.pitch_scale = petspeed
		$pet.play()
		$action.start()
		petspeed += 1

func _on_sprite_animation_finished() -> void:
			
	if $sprite.animation == "endroll" || $sprite.animation == "endfly" || $sprite.animation == "meow" || $sprite.animation == "bigmeow" || $sprite.animation == "hairball" || $sprite.animation == "pet" || $sprite.animation == "unstep":
		$sprite.play("idle")
		
	if $sprite.animation == "roll" || $sprite.animation == "startroll":
		var dist = sqrt(pow(global_position.x-player.position.x, 2)+pow(global_position.y-player.position.y, 2)+pow(global_position.z-player.position.z, 2))
	
		if dist >= 6:
			$sprite.play("roll")
		else:
			$sprite.play("endroll")
		$action.start()
	
	if $sprite.animation == "startfly":
		$sprite.play("fly")
		$flytimer.start()
	
func _on_step_body_entered(body: Node3D) -> void:
	print("gee")
	if body.is_in_group("playergroup"):
		$sprite.play("step")
		$audio.stream = load("res://audio/grease/step.mp3")
		$audio.play()
		$flytimer.stop()
		
func _on_step_body_exited(body: Node3D) -> void:
	if body.is_in_group("playergroup"):
		$action.start()
		$sprite.play("unstep")
		$audio.stream = load("res://audio/grease/unstep.mp3")
		$audio.play()
