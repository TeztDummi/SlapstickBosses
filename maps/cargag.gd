extends Node3D
var time = 0
var nextlight = randf_range(60, 120)
var sendcar = randf_range(4, 8)
var red = false
var cargoing = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta
	if red == false:
		if time >= nextlight:
			time = 0
			nextlight = randf_range(60, 120)
			togglelight()
	if red == true:
		if time >= sendcar:
			time = 0
			sendcar = randf_range(4, 8)
			cargoing = true
	if cargoing:
		$car.show()
		$car/audio.volume_db = 0
		$car.position.z += delta*150
	else:
		$car.hide()
		$car/audio.volume_db = -80
		$car.position.z = -100
	if $car.position.z >= 100:
		togglelight()
		cargoing = false
func togglelight():
	time = 0
	if red == false:
		red = true
		$trafficlight/redlight.get_surface_override_material(0).emission_energy_multiplier = 1
		$trafficlight/greenlight.get_surface_override_material(0).emission_energy_multiplier = 0
	elif red == true:
		red = false
		$trafficlight/redlight.get_surface_override_material(0).emission_energy_multiplier = 0
		$trafficlight/greenlight.get_surface_override_material(0).emission_energy_multiplier = 1

func _on_redlightarea_body_entered(body):
	if body.is_in_group("playergroup"):
		if red == false && randi_range(1, 6) == 1:
			togglelight()

func _on_sendcararea_body_entered(body):
	if body.is_in_group("playergroup"):
		if red == true:
			cargoing = true

func _on_cararea_body_entered(body):
	if body.is_in_group("playergroup"):
		body.hurt(100, "squish")
