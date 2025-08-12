extends Marker3D

var leftdelay = 0
var rightdelay = 0

var leftcharge = 0
var rightcharge = 0

var leftlock = false
var rightlock = false

var lefthealthcan = false
var righthealthcan = false

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var player = $"../../../../player"

# Called when the node enters the scene tree for the first time.
func _ready():
	$arm.get_surface_override_material(0).albedo_color = player.get_parent().bodycolor

	var leftfacedupe = $leftcan/can/face.get_surface_override_material(0).duplicate()
	$leftcan/can/face.set_surface_override_material(0, leftfacedupe)
	
	var rightfacedupe = $rightcan/can/face.get_surface_override_material(0).duplicate()
	$rightcan/can/face.set_surface_override_material(0, rightfacedupe)
	
	var leftdupe = $leftcan/can.get_surface_override_material(0).duplicate()
	$leftcan/can.set_surface_override_material(0, leftdupe)
	
	var rightdupe = $rightcan/can.get_surface_override_material(0).duplicate()
	$rightcan/can.set_surface_override_material(0, rightdupe)
	
	$leftcan.hide()
	$rightcan.hide()

#why is my coding so ass
func shoot(raycast):
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if leftdelay > 0:
		leftdelay -= delta
	if rightdelay > 0:
		rightdelay -= delta
		
	var dontslap = false
	
	$leftprediction.hide()
	$rightprediction.hide()
	
	if $leftcan.visible:
		if !leftlock:
			if Input.is_action_pressed("click"):
				if $leftcan/can/anim.current_animation != "left/throwloop":
					$leftcan/can/anim.play("left/throw")
					
				var predcount = $leftprediction.get_child_count()
				
				if leftcharge == 0:
					for i in range(1, predcount+1):
						var dot = $leftprediction.get_node("dot"+str(i))
						dot.transparency = 1
					
				leftcharge += delta/2
				
				var dir = Vector3(global_position.x-$dir.global_position.x, global_position.y-$dir.global_position.y, global_position.z-$dir.global_position.z)
				var curpos = global_position-dir.normalized()*1
				var linvel = dir*((leftcharge*30)+30)
				var off = -1
				$leftprediction.show()
				for i in range(1, predcount+1):
					linvel.y += gravity*0.05
					curpos -= linvel*0.05
					off *= 0.75
					var dot = $leftprediction.get_node("dot"+str(i))
					dot.transparency *= 1-(((predcount-i)*delta*0.005))
					dot.global_position = curpos
					dot.position.x += off
					
	if $rightcan.visible:
		if !rightlock:
			if Input.is_action_pressed("rightclick"):
				if $leftcan/can/anim.current_animation != "throwloop":
					$rightcan/can/anim.play("throw")
					
				var predcount = $rightprediction.get_child_count()
					
				if rightcharge == 0:
					for i in range(1, predcount+1):
						var dot = $rightprediction.get_node("dot"+str(i))
						dot.transparency = 1
						
				rightcharge += delta/2
				
				var dir = Vector3(global_position.x-$dir.global_position.x, global_position.y-$dir.global_position.y, global_position.z-$dir.global_position.z)
				var curpos = global_position-dir.normalized()*1
				var linvel = dir*((rightcharge*30)+30)
				var off = 1
				$rightprediction.show()
				for i in range(1, predcount+1):
					linvel.y += gravity*0.05
					curpos -= linvel*0.05
					off *= 0.75
					var dot = $rightprediction.get_node("dot"+str(i))
					dot.transparency *= 1-(((predcount-i)*delta*0.005))
					dot.global_position = curpos
					dot.position.x += off
			
	if leftcharge > 1: leftcharge = 1
	if rightcharge > 1: rightcharge = 1
	
	if leftcharge >= 0 && $leftcan.visible:
		if Input.is_action_just_released("click"):
			if !leftlock:
				$leftcan.hide()
				$leftprediction.hide()
				$leftcan/can.get_surface_override_material(0).albedo_texture = load("res://cantexture.png")
				var dir = Vector3(global_position.x-$dir.global_position.x, global_position.y-$dir.global_position.y, global_position.z-$dir.global_position.z)
				var angvel = Vector3(randf_range(-5, 5), randf_range(-5, 5), randf_range(-5, 5))
				shootprojectile(dir, angvel, leftcharge, lefthealthcan)
				
				leftcharge = 0
				lefthealthcan = false
			leftlock = false
			
	if rightcharge >= 0 && $rightcan.visible:
		if Input.is_action_just_released("rightclick"):
			if !rightlock:
				$rightcan.hide()
				$rightprediction.show()
				$rightcan/can.get_surface_override_material(0).albedo_texture = load("res://cantexture.png")
				var dir = Vector3(global_position.x-$dir.global_position.x, global_position.y-$dir.global_position.y, global_position.z-$dir.global_position.z)
				var angvel = Vector3(randf_range(-5, 5), randf_range(-5, 5), randf_range(-5, 5))
				shootprojectile(dir, angvel, rightcharge, righthealthcan)
				
				rightcharge = 0
				righthealthcan = false
			rightlock = false
	
	if $raycast.is_colliding():
		if $raycast.get_collider() != null:
			if $raycast.get_collider().is_in_group("pipewheel"):
				dontslap = true
			if $raycast.get_collider().is_in_group("sodacanpickup"):
				if !$raycast.get_collider().get_parent().is_in_group("fromplayer"):
					dontslap = true
					if !$leftcan.visible:
						if Input.is_action_just_pressed("click"):
							if $raycast.get_collider().get_parent().get_node("can").visible:
								$leftcan.show()
								$leftcan/can/anim.play("left/grab")
								$audio.play()
								leftlock = true
								if $raycast.get_collider().get_parent().healthcan:
									lefthealthcan = true
									$leftcan/can.get_surface_override_material(0).albedo_texture = load("res://healthcantexture.png")
								else:
									lefthealthcan = false
									$leftcan/can.get_surface_override_material(0).albedo_texture = load("res://cantexture.png")
								$raycast.get_collider().get_parent().queue_free()
					if !$rightcan.visible:
						if Input.is_action_just_pressed("rightclick"):
							if $raycast.get_collider().get_parent().get_node("can").visible:
								$rightcan.show()
								$rightcan/can/anim.play("grab")
								$audio.play()
								rightlock = true
								if $raycast.get_collider().get_parent().healthcan:
									righthealthcan = true
									$rightcan/can.get_surface_override_material(0).albedo_texture = load("res://healthcantexture.png")
								else:
									righthealthcan = false
									$rightcan/can.get_surface_override_material(0).albedo_texture = load("res://cantexture.png")
								$raycast.get_collider().get_parent().queue_free()
		
	if !dontslap:
		if Input.is_action_just_pressed("click"):
			if leftdelay <= 0:
				$anim.play("left")
				leftdelay = 1
				$audio.play()
				
		if Input.is_action_just_pressed("rightclick"):
			if rightdelay <= 0:
				$anim.play("right")
				rightdelay = 1
				$audio.play()
				
func shootprojectile(dir, angvel, power, healthcan):
	var projectile = load("res://sodaboss/sodacanrigid.tscn").instantiate()
	projectile.position = global_position
	projectile.position -= dir.normalized()*1
	var linvel = dir*((power*30)+30)
	#linvel.y -= 5
	projectile.linear_velocity = -linvel
	projectile.angular_velocity = angvel
	projectile.add_to_group("fromplayer")
	if healthcan: projectile.healthcan = true
	$"../../../../".add_child(projectile)
			
func slap(side):
	for body in $area.get_overlapping_bodies():
		if body.is_in_group("popcop"):
			body.smack(side)
			$audio2.stream = load("res://audio/smack.wav")
			if body.is_in_group("bigpopcop"):
				$audio2.stream = load("res://audio/smackfail.wav")
			$audio2.play()
			#rotate player camera
			#player.rotation.y = atan2(global_position.x-body.global_position.x, global_position.z-body.global_position.z)
			#player.camera.look_at(Vector3(body.global_position.x, body.global_position.y+1.5, body.global_position.z))
			body.eyes.visible = true
			player.camera.rotation.y = 0
			player.camera.rotation.z = 0
			$timestop.start()
			get_tree().paused = true

func _on_timestop_timeout():
	get_tree().paused = false


func leftanim(anim_name: StringName) -> void:
	if anim_name == "left/grab":
		$leftcan/can/anim.play("left/idle")
	if anim_name == "left/throw":
		print("leftthrowloop")
		$leftcan/can/anim.play("left/throwloop")

func rightanim(anim_name: StringName) -> void:
	if anim_name == "grab":
		$rightcan/can/anim.play("idle")
	if anim_name == "throw":
		print("rightthrowloop")
		$rightcan/can/anim.play("throwloop")
