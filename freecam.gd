extends Marker3D
var on = false
var speed = 2
var velocity = Vector3.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if on:
		var input_dir = Input.get_vector("left", "right", "up", "down")
		var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

		if direction:
			velocity.x += direction.x*delta*speed
			velocity.z += direction.z*delta*speed

		if Input.is_action_pressed("jump"):
			velocity.y += delta*speed
		if Input.is_action_pressed("crouch"):
			velocity.y -= delta*speed
			
		velocity *= 1-(5*delta)

		position += velocity
		
		#print($area.get_overlapping_areas())
		
func _unhandled_input(event):
	if Input.is_action_just_pressed("f1"):
		if $"../".escapedcube == "none":
			if !on:
				if !get_tree().paused:
					#get_tree().paused = true
					on = true
					$"../canvas/hud".visible = false
					$cam.current = true
					position = $"../player".position
					rotation = $"../player".rotation
					velocity.y = 0.1
					speed = 2
					$cam.fov = 75
			else:
				get_tree().paused = false
				on = false
				$"../canvas/hud".visible = true
				$"../player".camera.current = true
		else:
			$"../".crash("pauseinshutdown")
			
	if on:
		if !Input.is_action_pressed("dash"):
			if speed <= 50:
				if Input.is_action_just_pressed("scrollup"): speed *= 1.5
			if Input.is_action_just_pressed("scrolldown"): speed /= 1.5
		else:
			if Input.is_action_just_pressed("scrollup"): $cam.fov *= 1.05
			if Input.is_action_just_pressed("scrolldown"): $cam.fov /= 1.05
		if Input.is_action_pressed("enter"):
			if $"../".escapedcube == "none":
				get_tree().paused = !get_tree().paused
		if event is InputEventMouseMotion:
			rotate_y(-event.relative.x * .005)
			$cam.rotate_x(-event.relative.y * .005)
			$cam.rotation.x = clamp($cam.rotation.x, -PI/2, PI/2)


func _on_area_area_exited(area: Area3D) -> void:
	print("area exiting: ")
	print(area)
	if area.name == "cubearea":
		var pos = position-$"../player".position
		var dist = sqrt(pow(pos.x, 2)+pow(pos.y, 2)+pow(pos.z, 2))
		print(dist)
		if dist > 500:
			$"../".escapecube("freecam")

func _on_area_area_entered(area: Area3D) -> void:
	print("area entering: ")
	print(area)
	if area.name == "cubearea":
		velocity = -velocity+position.normalized()*10
