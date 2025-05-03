extends Marker3D

var hitdelay = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if hitdelay > 0:
		hitdelay -= delta

func shoot(raycast):
	if hitdelay <= 0:
		if $AnimationPlayer.current_animation != "intro" || !$AnimationPlayer.is_playing():
			hitdelay = 0.5
			var collision = raycast.get_collider()
			var pos = raycast.get_collision_point()
			var normal = raycast.get_collision_normal()
			var particle = load("res://shootparticlelaser.tscn").instantiate()
			particle.position = pos
			particle.look_at_from_position(raycast.get_collision_point(), raycast.get_collision_point() + raycast.get_collision_normal(), Vector3.UP)
			particle.get_node("dent").hide()
			if collision.is_in_group("cat"):
				particle.get_node("blud").show()
			$"../../../../map".add_child(particle)
			
			$kb9kparticlespivot.look_at(pos, Vector3.UP)
			$kb9kparticlespivot/kb9kparticles.emitting = true
			$AnimationPlayer.play("shoot")
			$audio.play()
			
			if collision.is_in_group("cat"):
				collision.hurt(20)
			if collision.is_in_group("gunman"):
				collision.hurt(20)
			if collision.get_parent().get_parent().name == "tilesphere":
				collision.get_parent().begin()
