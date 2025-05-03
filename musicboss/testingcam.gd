extends Marker3D
var on = true
var speed = 2
var velocity = Vector3.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	if $cam.current:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if $cam.current:
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
		
func _unhandled_input(event):
	if $cam.current:
		if on:
			if !Input.is_action_pressed("crouch"):
				if Input.is_action_just_pressed("scrollup"): speed *= 1.5
				if Input.is_action_just_pressed("scrolldown"): speed /= 1.5
			else:
				if Input.is_action_just_pressed("scrollup"): $cam.fov *= 1.05
				if Input.is_action_just_pressed("scrolldown"): $cam.fov /= 1.05
			if Input.is_action_pressed("enter"):
				get_tree().paused = !get_tree().paused
			if event is InputEventMouseMotion:
				rotate_y(-event.relative.x * .005)
				$cam.rotate_x(-event.relative.y * .005)
				$cam.rotation.x = clamp($cam.rotation.x, -PI/2, PI/2)
				
			if Input.is_action_pressed("click"):
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			if Input.is_action_pressed("esc"):
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
