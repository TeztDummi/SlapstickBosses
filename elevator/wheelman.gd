extends CharacterBody3D

const speed = 50
var damagedelay = 0
@onready var player = $"../../player"
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	if is_on_floor():		
		var direction = Vector2(player.position.x-position.x, player.position.z-position.z).normalized()
		velocity.x += direction.x*0.4*delta*speed
		velocity.z += direction.y*0.4*delta*speed
		velocity *= 1-(0.5*delta)
	
	var totalvel = sqrt(pow(velocity.x, 2)+pow(velocity.z, 2))
	$wheels.rotate_z(totalvel/200)
	#totalvel*200-80
	$audio.volume_db = -200
	rotation.y = atan2(velocity.x, velocity.z)+PI/2
	
	if velocity.y < -10: queue_free()
	
	if damagedelay > 0:
		damagedelay -= delta
		
	move_and_slide()
	
	for body in $hitarea.get_overlapping_bodies():
		if body.is_in_group("playergroup"):
			if damagedelay <= 0:
				body.velocity.x += velocity.x
				body.velocity.y += 30
				body.velocity.z += velocity.z
				damagedelay = 1
				if body.health <= 20 && !player.dead:
					$"../../".setAchievement("handicapable")
				body.hurt(20, "ragdoll")
