extends CharacterBody3D
var health = 500
@onready var player = $"../../../player"
var isdead = false
var hurttime = 0
var speed = 3
var shake = 0
var slamming = false
var dashing = "no"
var prevvel = Vector3.ZERO

func _ready():
	var dupe = $visual/cat.get_surface_override_material(0).duplicate()
	$visual/cat.set_surface_override_material(0, dupe)
	
	var slamwarndupe = $slamwarning.get_surface_override_material(0).duplicate()
	$slamwarning.set_surface_override_material(0, slamwarndupe)
	
	var explodedupe = $warning.get_surface_override_material(0).duplicate()
	$warning.set_surface_override_material(0, explodedupe)
	
	$shoottimer.wait_time = randf_range(4, 8)
	$shoottimer.start()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if position.y < -4 || position.y > 10:
		position.y = 1
		velocity.y = 0
		collider(false)
	if hurttime > 0:
		hurttime -= delta*4
		$visual/cat.get_surface_override_material(0).emission = Color(hurttime/2, 0, 0)
	else: 
		hurttime = 0
		$visual/cat.get_surface_override_material(0).emission = Color(0, 0, 0)
		
	if $anim.current_animation == "death":
		shake += delta*1.5
		$visual.position.x = randf_range(-shake, shake)
		$visual.position.z = randf_range(-shake, shake)
	
	if !isdead:
		if !is_on_floor() && !slamming && !$CollisionShape3D.disabled:
			velocity.y -= 30*delta
		
		if !player.dead:
			var disttoclosest = sqrt(pow(position.x-player.position.x, 2)+pow(position.z-player.position.z, 2))
			var direction = Vector2(player.position.x-position.x, player.position.z-position.z).normalized()
			if dashing == "no":
				velocity.x = direction.x*speed
				velocity.z = direction.y*speed
			if dashing == "yes":
				velocity.x += direction.x*speed*delta*15
				velocity.z += direction.y*speed*delta*15
				
				for person in $dash.get_overlapping_bodies():
					if person.is_in_group("playergroup"):
						if !person.dead:
							if person.velocity.y <= 20:
								var knockdir = atan2(person.global_position.x-global_position.x, person.global_position.z-global_position.z)
								person.velocity.x += sin(knockdir)*50
								person.velocity.y += 30
								person.velocity.z += cos(knockdir)*50
								person.hurt(20, "ragdoll")
								
								var tempaudio = load("res://tempaudio.tscn").instantiate()
								add_child(tempaudio)
								tempaudio.stream = load("res://audio/roobeerwallhit.mp3")
								tempaudio.pitch_scale = 0.75
								tempaudio.volume_db = 16
								tempaudio.play()
			if dashing != "no":
				velocity.x *= 1-(delta*0.2)
				velocity.z *= 1-(delta*0.2)
				
				$dashparticles.emitting = (velocity.length() > 20)
				var amount = ((prevvel.length()-velocity.length())/delta)
				if (amount > 2500):
					print("HIT WALL!!!")
					print(amount)
					var tempaudio = load("res://tempaudio.tscn").instantiate()
					add_child(tempaudio)
					tempaudio.stream = load("res://audio/roobeerwallhit.mp3")
					tempaudio.volume_db = 16
					tempaudio.play()
				prevvel = velocity
				
			if slamming:
				velocity *= (0.5+disttoclosest/4)
				#position.y = 1
						
		move_and_slide()
		
		#if sqrt(pow(velocity.x, 2) + pow(velocity.y, 2)  + pow(velocity.z, 2)) < 0.1:
		#	if is_on_floor() && alivers.size() != 0:
		#		velocity.y += 20

func _on_anim_animation_finished(anim_name):
	print("tf")
	if anim_name == "death":
		delete()
	if anim_name == "throw2L":
		animplay("move")
	if anim_name == "slam":
		slamming = false
		collider(false)
		animplay("move")
	if anim_name == "dash":
		$dashcollider.disabled = true
		$dashparticles.emitting = false
		prevvel = Vector3.ZERO
		dashing = "no"
		animplay("move")
			
func activateexplode():
	for person in $explode.get_overlapping_bodies():
		if person.is_in_group("playergroup"):
			if !person.dead:
				person.hurt(75, "ragdoll")
	player.screenshake += 2
	player.impactframe()
					
func changedashing(val):
	dashing = val
	
func hurt(amount):
	if !isdead:
		health -= amount
		hurttime = 1
		$shoottimer.wait_time = 4*(float(((500-500/1.1)+health/1.1))/500)
		$SubViewport/healthbar.value = health
		$SubViewport/healthbar/healthlabel.text = str(round(health))
		$SubViewport/healthbar.tint_progress = Color.from_hsv(health*0.003*(100/$SubViewport/healthbar.max_value), 0.5, 1)
		if health <= 0:
			$visual/healthsprite.hide()
			animplay("death")
			playsound("res://audio/roobeerdeath.mp3", 1)
			isdead = true 
	
func playsound(sound, pitch):
	$visual/audio.stream = load(sound)
	$visual/audio.pitch_scale = pitch
	$visual/audio.play()
	
func animplay(animation):
	$anim.play("RESET")
	$anim.play(animation)
	
func delete():
	queue_free()

func shootprojectile(dir, angvel):
	var projectile = load("res://cats/2Lroobeer.tscn").instantiate()
	projectile.position = position
	projectile.position.y += 3
	projectile.rotation.x = PI/2
	projectile.position -= dir.normalized()*4
	var linvel = dir*0.8
	linvel.y -= 5
	projectile.linear_velocity = -linvel
	projectile.angular_velocity = angvel
	$"../../".add_child(projectile)
	
func slam():
	for person in $slam.get_overlapping_bodies():
		if person.is_in_group("playergroup"):
			if !person.dead:
				person.hurt(30, "squish")
	$slamparticles.restart()
	shockwave()
		
func shockwave():
	var shockwave = load("res://shockwave.tscn").instantiate()
	shockwave.position = position
	shockwave.position.y = -2
	$"../../".add_child(shockwave)
	player.screenshake += 0.5

func collider(val):
	$CollisionShape3D.disabled = val

func _on_shoottimer_timeout():
	if !isdead:
		var choices = []
		for person in $range.get_overlapping_bodies():
			if person.is_in_group("playergroup"):
				if !person.dead:
					choices.append(person)
		if !slamming && dashing == "no":
			var rand = randi_range(0, 5)
			if rand > 2:
				if choices.size() != 0:
					var choice = choices[randi_range(0, choices.size()-1)]
					var pos = choice.position
					pos = Vector3(pos.x+randf_range(-5, 5)+choice.velocity.x*2, pos.y, pos.z+randf_range(-5, 5)+choice.velocity.z*2)
					pos.y += 0.5
					var dir = Vector3(position.x-pos.x, position.y-pos.y, position.z-pos.z)
					var angvel = Vector3(randf_range(-5, 5), randf_range(-5, 5), randf_range(-5, 5))
					shootprojectile(dir, angvel)
					animplay("throw2L")
					playsound("res://audio/2Lroobeerthrow.mp3", 1)
			elif rand == 0:
				slamming = true
				collider(true)
				animplay("slam")
				playsound("res://audio/roobeerslam.mp3", 1)
			elif rand == 1:
				dashing = "notmoving"
				$dashcollider.disabled = false
				animplay("dash")
				playsound("res://audio/roobeerdash.mp3", 1)
