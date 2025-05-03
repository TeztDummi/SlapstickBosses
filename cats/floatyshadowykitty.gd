extends CharacterBody3D
var health = 200
@onready var player = $"../../../player"
var isdead = false
var hurttime = 0
var speed = 3
var closestperson
var dietime = 0
var dumber = false

func _ready():
	var dupe = $visual/cat.get_surface_override_material(0).duplicate()
	$visual/cat.set_surface_override_material(0, dupe)
	$shoottimer.wait_time = randf_range(3, 6)
	$shoottimer.start()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if dietime > 0:
		dietime += delta
		if dietime >= 5:
			delete()
	if hurttime > 0:
		hurttime -= delta*4
		$visual/cat.get_surface_override_material(0).emission = Color(hurttime/2, 0, 0)
	else: 
		hurttime = 0
		$visual/cat.get_surface_override_material(0).emission = Color(0, 0, 0)

	if !isdead:
		if !is_on_floor():
			velocity.y -= 2*delta
		
		if !player.dead:
			var disttoclosest = sqrt(pow(position.x-player.position.x, 2)+pow(position.z-player.position.z, 2))
			var direction = Vector2(player.position.x-position.x, player.position.z-position.z).normalized()
			velocity.x = direction.x*speed
			velocity.z = direction.y*speed
						
		move_and_slide()

func _on_anim_animation_finished(anim_name):
	print("tf")
	if anim_name == "death":
		print("gone???")
		delete()

func hurt(amount):
	if !isdead:
		health -= amount
		hurttime = 1
		$shoottimer.wait_time = 2*(float((100+health/2))/200)
		$SubViewport/healthbar.value = health
		$SubViewport/healthbar/healthlabel.text = str(round(health))
		$SubViewport/healthbar.tint_progress = Color.from_hsv(health*0.003*(100/$SubViewport/healthbar.max_value), 0.5, 1)
		if health <= 0:
			$visual/healthsprite.hide()
			animplay("death")
			playsound("res://audio/darkdeath.mp3", 1)
			isdead = true
			dietime = 0.1
			$CollisionShape3D.disabled = true

func playsound(sound, pitch):
	$audio.stream = load(sound)
	$audio.pitch_scale = pitch
	$audio.play()

func animplay(animation):
	$anim.play("RESET")
	$anim.play(animation)

func shootprojectile(pos):
	var projectile = load("res://cats/darkprojectile.tscn").instantiate()
	projectile.position = position
	projectile.position.y += 5
	var dir = Vector3(projectile.position.x-pos.x, projectile.position.y-pos.y, projectile.position.z-pos.z).normalized()
	projectile.position -= dir*4
	projectile.rotation.y = atan2(dir.x, dir.z)+PI
	projectile.rotation.x = dir.y
	$"../../".add_child(projectile)

func delete():
	queue_free()

func _on_shoottimer_timeout():
	if !isdead:
		if $range.get_overlapping_bodies().size() != 0:
			var choices = []
			for person in $range.get_overlapping_bodies():
				if person.is_in_group("playergroup"):
					if !person.dead:
						choices.append(person)
			if choices.size() != 0:
				var choice = choices[randi_range(0, choices.size()-1)]
				var pos = choice.position
				if randi_range(0, 2) == 0 && !dumber:
					pos = Vector3(pos.x+choice.velocity.x, pos.y, pos.z+choice.velocity.z)
				else:
					pos = Vector3(pos.x, pos.y, pos.z)
				pos.y += 0.5
				shootprojectile(pos)
				speed = 0.5
			else:
				speed = 3
		else:
			$poof.emitting = true
			var randdir = randf_range(0, PI*2)
			position = Vector3(player.position.x+sin(randdir)*12, 0, player.position.z+cos(randdir)*12)
			$poof2.emitting = true
			playsound("res://audio/darkteleport.mp3", 1)
				
