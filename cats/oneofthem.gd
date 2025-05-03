extends CharacterBody3D
var health = 5
@onready var player = $"../../../player"
var isdead = false

func _ready():
	if randi_range(0, 1) == 0:
		$visual/cat1.hide()
		$visual/cat2.show()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !isdead:
		if !is_on_floor():
			velocity.y -= 30*delta
		
		if !player.dead:
			var direction = Vector2(player.position.x-position.x, player.position.z-position.z).normalized()
			if $anim.current_animation != "hit":
				velocity.x = direction.x*7
				velocity.z = direction.y*7
				rotation.y = atan2(player.position.x-position.x, player.position.z-position.z)
			else:
				velocity.x = 0
				velocity.z = 0
			#$walldetect.rotation.y = atan2(direction.x, direction.y)
			if $walldetect.is_colliding():
				if $walldetect.get_collider() != null:
					var collision = $walldetect.get_collider()
					if collision.is_in_group("catwalls"):
						velocity.x = direction.y*7
						velocity.z = direction.x*-7
						#velocity.y = 10
				
		if $anim.current_animation != "hit":
			for person in $hitarea.get_overlapping_bodies():
				if person.is_in_group("playergroup"):
					if !person.dead:
						person.hurt(5, "ragdoll")
						animplay("hit")
						playsound("res://audio/oneofthemmeow.mp3")
		move_and_slide()
		
		#if sqrt(pow(velocity.x, 2) + pow(velocity.y, 2)  + pow(velocity.z, 2)) < 0.1:
		#	if is_on_floor() && alivers.size() != 0:
		#		velocity.y += 20
	else:
		if !$visual/deathparticle.emitting:
			delete()

func _on_anim_animation_finished(anim_name):
	if !isdead:
		if anim_name == "hit":
			animplay("move")
	
func hurt(amount):
	$SubViewport/healthbar.value -= 5
	$SubViewport/healthbar/healthlabel.text = str(0)
	$SubViewport/healthbar.tint_progress = Color.from_hsv(0*0.003*(100/$SubViewport/healthbar.max_value), 0.5, 1)
	$visual/deathparticle.emitting = true
	$visual/cat1.hide()
	$visual/cat2.hide()
	playsound("res://audio/oneofthemdeath.mp3")
	isdead = true
	$CollisionShape3D.disabled = true
	
func playsound(sound):
	$audio.stream = load(sound)
	$audio.pitch_scale = randf_range(0.75, 1.25)
	$audio.play()
	
func animplay(animation):
	$anim.play(animation)
	
func delete():
	queue_free()
