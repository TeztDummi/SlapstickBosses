extends Node3D
@onready var player = $"../../player"
var time = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta
	
	if time >= 20:
		delete()
		
	if $projectile.visible:
		$projectile.position.z += delta*50

func _on_area_body_entered(body):
	if !body.is_in_group("cat"):
		if $projectile.visible:
			hit()
					
func delete():
	queue_free()

func hit():
	$projectile.hide()
	$explosion.position = $projectile.position
	$projectile/projectileparticle.emitting = false
	$explosion.emitting = true
	$explosion/audio.play()
	player.screenshake += 0.1
	for person in $projectile/areaexplode.get_overlapping_bodies():
		if person.is_in_group("playergroup"):
			if !person.dead:
				person.hurt(15, "darkmagic")
