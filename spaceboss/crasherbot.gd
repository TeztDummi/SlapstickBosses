extends Node3D

var randvel = Vector3.ZERO
var velocity = Vector3.ZERO
var rotvel = Vector3.ZERO

@onready var player = $"../../player"

var dizzy = 0

var zapped = "no"

var attacking = "no"

var ontile = []

var ringprevrot = Vector3(0, -PI, 0)

@onready var deadrot = Vector3(randf_range(-1,1), randf_range(-1,1), randf_range(-1,1))*PI*0.5

# Called when the node enters the scene tree for the first time.
func _ready():
	var dupe = $mesh/main.get_surface_override_material(3).duplicate()
	$mesh/main.set_surface_override_material(3, dupe)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for tile in ontile:
		if tile == null || tile.began:
			ontile.erase(tile)
		
	if zapped == "no":
		var thrust = Vector3.ZERO
		
		if dizzy > 0:
			thrust = -velocity
			print("Dizzy thrusting: canceling velocity")
		elif attacking == "yes":
			thrust = (-position)
			print("Attack thrusting: going towards center")
		elif attacking == "prep":
			velocity *= (1-delta*2)
			thrust = (-position)
			print("Prep Attack thrusting: kinda resetting velocity")
		elif sqrt(pow(position.x,2)+pow(position.y,2)+pow(position.z,2)) < 15:
			thrust = -(-position)
			print("Too close thrusting: going away from center")
		elif sqrt(pow(position.x,2)+pow(position.y,2)+pow(position.z,2)) > 25:
			thrust = (-position)
			print("Too far thrusting: going towards center")
		else:
			var futurevel = thrust.normalized()*0.01+velocity
			if sqrt(pow(futurevel.x,2)+pow(futurevel.y,2)+pow(futurevel.z,2)) > 5:
				thrust = -velocity
				print("Too fast thrusting: cancelling velocity")
			elif sqrt(pow(futurevel.x,2)+pow(futurevel.y,2)+pow(futurevel.z,2)) > 4.8:
				if sqrt(pow(futurevel.x,2)+pow(futurevel.y,2)+pow(futurevel.z,2)) > sqrt(pow(velocity.x,2)+pow(velocity.y,2)+pow(velocity.z,2)):
					thrust = Vector3.ZERO
					print("About to be too fast thrusting: no thrust")
			else:
				thrust = randvel
				print("Random Thrusting")
			
		thrust = thrust.normalized()*0.01
		
		print(thrust)
		
		
		if attacking != "yes": 
			if sqrt(pow(velocity.x,2)+pow(velocity.y,2)+pow(velocity.z,2)) > 4:
				velocity = velocity*(1-2*delta)
		
		if ontile == []:
			if attacking == "yes": 
				velocity += thrust*3
			else:
				velocity += thrust
		
		$test.global_position = position+thrust*500
		
		var saverotationagain = rotation
		look_at($test.global_position)
		
		$mesh/ring.rotation = Vector3(0, -PI, 0)
		#if moving away from center
		if sqrt(pow(position.x, 2)+pow(position.y, 2)+pow(position.z, 2)) < sqrt(pow(position.x+thrust.x, 2)+pow(position.y+thrust.y, 2)+pow(position.z+thrust.z, 2)):
			rotation.y += PI
			rotation.x *= -1
			if dizzy <= 0: $mesh/ring.rotation.y += PI
		var savethatrotation = $mesh/ring.global_rotation
		$test2.look_at(Vector3.ZERO)
		rotation.x = $test2.global_rotation.x
		
		rotation.x = lerp_angle(saverotationagain.x, rotation.x, delta*2)
		rotation.y = lerp_angle(saverotationagain.y, rotation.y, delta*2)
		rotation.z = lerp_angle(saverotationagain.z, rotation.z, delta*2)
		
		$mesh/ring.global_rotation.x = lerp_angle(ringprevrot.x, savethatrotation.x, delta*3)
		#$mesh/ring.global_rotation.x = savethatrotation.x
		ringprevrot = $mesh/ring.global_rotation
		
		#mesh rot goes towards rotation while ring rot goes towards the variable
		
		$test2.look_at(Vector3.ZERO)
		$dodgepivot.global_rotation = $test2.global_rotation
		
		var total = sqrt(pow(thrust.x,2)+pow(thrust.y,2)+pow(thrust.z,2))
		
		if total >= 0: $mesh/ring/flame.scale = Vector3.ONE*total*100
		else: $mesh/ring/flame.scale = Vector3.ZERO

		if dizzy <= 0:
			pass
			#look_at(Vector3.ZERO)
		else:
			rotate_y(PI*4*delta*dizzy)
		
		$mesh/ring/light.light_energy = total*5
		
		$mesh/seethru/blur.transparency = $mesh/blur.transparency
		$mesh/seethru/blur.rotation = $mesh/blur.rotation
		$mesh/seethru/main.visible = $mesh/main.visible
		$mesh/seethru/main.rotation = $mesh/main.rotation
		$mesh/seethru/ring.rotation = $mesh/ring.rotation
		$mesh/seethru/main/spikes.scale = $mesh/main/spikes.scale
		
	elif zapped == "dead":
		rotation += deadrot*delta
		rotate_y(PI*4*delta*dizzy)
		
	if dizzy > 0:
		dizzy -= delta
		
	position += velocity*delta
	
func zap():
	if zapped == "no":
		zapped = "yes"
		$anim.play("zap")
		player.camlock = true
		velocity = Vector3.ZERO
		$mesh/ring/flame.hide()
		$mesh/ring/light.hide()

func _on_randommovement_timeout():
	randvel = Vector3(randf_range(-1,1), randf_range(-1,1), randf_range(-1,1))
	
func _on_dodge_area_entered(area):
	print(attacking)
	if attacking == "no":
		if area.is_in_group("zaphead"):
			if !dizzy:
				print("guyh")
				velocity += ($dodgepivot/dodge.global_position-area.global_position).normalized()*5
				#velocity -= position.normalized()*5

func _on_anim_animation_finished(anim_name):
	print("hi")
	if anim_name == "zap":
		zapped = "dead"
		player.camlock = false
		velocity = (-position).normalized()*0.1

func _on_attacktimer_timeout():
	$attacktimer.wait_time = randf_range(7, 13)
	attacking = "prep"
	$anim.play("attack")

func attackingturnyes():
	attacking = "yes"

func _on_damage_body_entered(body):
	if body.get_parent().get_parent().name == "tilesphere":
		if attacking == "yes":
			if !body.get_parent().began:
				ontile.append(body.get_parent())
				var futuredist = sqrt(pow(position.x+velocity.x,2)+pow(position.y+velocity.y,2)+pow(position.z+velocity.z,2)) 
				var dist = sqrt(pow(position.x,2)+pow(position.y,2)+pow(position.z,2))
				if futuredist < dist:
					velocity = Vector3.ZERO
			else:
				body.get_parent().hurt(100)
	if body.is_in_group("playergroup"):
		if attacking == "yes":
			body.hurt(50)
			endattack()
			
func endattack():
	attacking = "no"
	$anim.play("attackend")
	attacking = "no"
	$attacktimer.start()

func _on_tilehurt_timeout():
	if ontile != []:
		for tile in ontile:
			if tile.heat+(0.2/1.5)*100 >= 100:
				ontile.erase(tile)
				if ontile == []:
					$anim.play("attackend")
					attacking = "no"
					$attacktimer.start()
					#audio stop
			tile.hurt((0.2/1.5)*100)
