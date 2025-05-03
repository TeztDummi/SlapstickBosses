extends MeshInstance3D

var began = false
var dir
var rot
var moved = false

var heat = 0

@onready var ogpos = position
var shake = 0

func _ready():
	var dupe = material_overlay.duplicate()
	material_overlay = dupe
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if began:
		rotation += rot*delta
		position += dir*delta
		
	if heat > 0:
		heat -= delta*10
	else:
		heat = 0
	
	material_overlay.albedo_color.a = heat/1000
	
	if shake > 0:
		if !began && !moved:
			shake -= delta/5
			position.x = ogpos.x+randf_range(-1,1)*shake
			position.y = ogpos.y+randf_range(-1,1)*shake
			position.z = ogpos.z+randf_range(-1,1)*shake
		
func hurt(amount):
	shake += 0.003*amount
	heat += amount
	var particle = load("res://spaceboss/tileparticles.tscn").instantiate()
	particle.position = position
	particle.look_at(Vector3.ZERO)
	if heat >= 100:
		particle.get_child(0).amount = 100
		queue_free()
	get_parent().add_child(particle)
	
func begin():
	began = true
	dir = position.normalized()*1.5
	rot = Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1))*0.4
	
