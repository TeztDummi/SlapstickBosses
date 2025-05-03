extends RigidBody3D
@onready var player = $"../../player"
@onready var dupe = $warning.get_surface_override_material(0).duplicate()
var warningcolor = Color(0, 219, 152)
# Called when the node enters the scene tree for the first time.
func _ready():
	$warning.set_surface_override_material(0, dupe)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#print(sqrt(pow(linear_velocity.x, 2)+pow(linear_velocity.y, 2)+pow(linear_velocity.z, 2)))
	dupe.albedo_color = warningcolor
	
func activate():
	freeze = true
	for person in $hitarea.get_overlapping_bodies():
		if person.is_in_group("playergroup"):
			if !person.dead:
				person.hurt(20, "ragdoll")
	player.screenshake += 0.1
func unfreeze():
	freeze = false

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "start":
		delete()
		
func delete():
	queue_free()

func _on_area_3d_body_entered(body):
	print("gyeaaaaaaaah: "+str(sqrt(pow(linear_velocity.x, 2)+pow(linear_velocity.y, 2)+pow(linear_velocity.z, 2))))
	if body.is_in_group("playergroup"):
		var speed = sqrt(pow(linear_velocity.x, 2)+pow(linear_velocity.y, 2)+pow(linear_velocity.z, 2))
		if speed >= 6:
			if body.health <= 10 && !player.dead:
				$"../../".setAchievement("icanquitwheneveriwant")
			body.hurt(10, "ragdoll")
			linear_velocity *= -1
			$donk.play()
