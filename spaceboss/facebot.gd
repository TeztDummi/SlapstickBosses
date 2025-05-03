extends Node3D

var randvel = Vector3.ZERO
var velocity = Vector3.ZERO
var rotvel = Vector3.ZERO

@onready var player = $"../../player"

var dizzy = 0

var zapped = "no"

@onready var deadrot = Vector3(randf_range(-1,1), randf_range(-1,1), randf_range(-1,1))*PI*0.5

# Called when the node enters the scene tree for the first time.
func _ready():
	var dupe = $mesh/main.get_surface_override_material(1).duplicate()
	$mesh/main.set_surface_override_material(1, dupe)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if zapped == "no":
		var thrust = Vector3.ZERO
		if dizzy:
			thrust = -velocity
		if sqrt(pow(position.x,2)+pow(position.y,2)+pow(position.z,2)) < 15:
			thrust = -(-position)
		elif sqrt(pow(position.x,2)+pow(position.y,2)+pow(position.z,2)) > 25:
			thrust = (-position)
		elif sqrt(pow(velocity.x,2)+pow(velocity.y,2)+pow(velocity.z,2)) > 3:
			thrust = -velocity+randvel
		else:
			thrust = randvel
			
		thrust = thrust.normalized()*0.01
			
		if sqrt(pow(velocity.x,2)+pow(velocity.y,2)+pow(velocity.z,2)) > 4:
			velocity = velocity*(1-2*delta)
		
		velocity += thrust
		
		$test.global_position = position+thrust*500
		#rotvel = -($test.position)
		rotvel.x = lerpf(rotvel.x, -($test.position.x), delta*5)
		rotvel.y = lerpf(rotvel.y, -($test.position.y), delta*5)
		rotvel.z = lerpf(rotvel.z, -($test.position.z), delta*5)
		var scl = 0.3
		
		if rotvel.x >= 0: $mesh/rocket/flame.scale = Vector3.ONE*rotvel.x*scl
		else: $mesh/rocket/flame.scale = Vector3.ZERO
		if rotvel.x <= 0:  $mesh/rocket_001/flame.scale = -Vector3.ONE*rotvel.x*scl
		else: $mesh/rocket_001/flame.scale = Vector3.ZERO
		if rotvel.y >= 0:  $mesh/rocket_002/flame.scale = Vector3.ONE*rotvel.y*scl
		else: $mesh/rocket_002/flame.scale = Vector3.ZERO
		if rotvel.y <= 0:  $mesh/rocket_003/flame.scale = -Vector3.ONE*rotvel.y*scl
		else: $mesh/rocket_003/flame.scale = Vector3.ZERO
		if rotvel.z >= 0: $mesh/rocket_004/flame.scale = Vector3.ONE*rotvel.z*scl
		else: $mesh/rocket_004/flame.scale = Vector3.ZERO
		if dizzy <= 0:
			look_at(Vector3.ZERO)
		else:
			rotate_y(PI*4*delta*dizzy)
		
		var total = sqrt(pow(thrust.x,2)+pow(thrust.y,2)+pow(thrust.z,2))
		
		$light.light_energy = total*5
		
	elif zapped == "dead":
		rotation += deadrot*delta
		rotate_y(PI*4*delta*dizzy)
		
	if dizzy > 0:
		dizzy -= delta
		$Timer.start()
		
	position += velocity*delta
	
func zap():
	if zapped == "no":
		zapped = "yes"
		$anim.play("zap")
		player.camlock = true
		velocity = Vector3.ZERO
		$mesh/rocket/flame.hide()
		$mesh/rocket_001/flame.hide()
		$mesh/rocket_002/flame.hide()
		$mesh/rocket_003/flame.hide()
		$mesh/rocket_004/flame.hide()
		$light.hide()
	
func _on_timer_timeout():
	if zapped == "no":
		$anim.play("shoot")
		var bomb = load("res://spaceboss/bomb.tscn").instantiate()
		bomb.position = position
		bomb.vel = (-position).normalized()*0.1
		get_parent().add_child(bomb)

func _on_randommovement_timeout():
	randvel = Vector3(randf_range(-1,1), randf_range(-1,1), randf_range(-1,1))
	
func _on_dodge_area_entered(area):
	if area.is_in_group("zaphead"):
		if !dizzy:
			print("guyh")
			velocity += ($dodge.global_position-area.global_position).normalized()*20
			#velocity -= position.normalized()*5

func _on_anim_animation_finished(anim_name):
	if anim_name == "zap":
		zapped = "dead"
		player.camlock = false
		velocity = (-position).normalized()*0.1
