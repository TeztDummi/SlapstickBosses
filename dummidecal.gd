extends Decal
var timer = 0

func _ready():
	preload("res://dummirigid.tscn")

func _process(delta):
	if timer > 0: timer -= delta

func doit():
	if timer <= 0:
		timer = 1
		for i in range(5):
			var dummi = load("res://dummirigid.tscn").instantiate()
			dummi.position = Vector3(position.x, position.y, position.z)
			dummi.linear_velocity = Vector3(-randf_range(5, 50), randf_range(0, 10), 0)
			print(dummi.linear_velocity)
			dummi.rotation = Vector3(randf_range(0, 2*PI), randf_range(0, 2*PI), randf_range(0, 2*PI))
			$"../".add_child(dummi)
