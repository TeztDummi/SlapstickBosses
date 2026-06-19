extends CharacterBody3D
var health = 50
@onready var player = $"../../../player"
var isdead = false
var hurttime = 0
var speed = 2
var music = preload("res://audio/lilwhiskersmusic.mp3")
var dietime = 0

func _ready():
	animplay("move")
	playsound("music", 1)
	$shoottimer.start()
	
	var dupe = $visual/cat.get_surface_override_material(0).duplicate()
	$visual/cat.set_surface_override_material(0, dupe)

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
			velocity.y -= 30*delta
			
		if !player.dead:
			var direction = Vector2(player.position.x-position.x, player.position.z-position.z).normalized()
			var disttoclosest = sqrt(pow(position.x-player.position.x, 2)+pow(position.z-player.position.z, 2))
			if disttoclosest < 10:
				velocity.x = direction.x*(disttoclosest*1.5)
				velocity.z = direction.y*(disttoclosest*1.5)
			else:
				velocity.x = direction.x*(10*1.5)
				velocity.z = direction.y*(10*1.5)
			rotation.y = atan2(player.position.x-position.x, player.position.z-position.z)
			if $walldetect.is_colliding():
				if $walldetect.get_collider() != null:
					var collision = $walldetect.get_collider()
					if collision.is_in_group("catwalls"):
						velocity.x = direction.y*10*1.5
						velocity.z = direction.x*-10*1.5
						
		move_and_slide()

func _on_anim_animation_finished(anim_name):
	print("tf")
	if anim_name == "death":
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
			playsound("res://audio/lilwhiskerdeath.mp3", 1)
			isdead = true
			dietime = 0.1
			$CollisionShape3D.disabled = true

func playsound(sound, pitch):
	if sound == "music":
		$audio.stream = music
	else:
		$audio.stream = load(sound)
	$audio.pitch_scale = pitch
	$audio.play()

func animplay(animation):
	$anim.play("RESET")
	$anim.play(animation)

func shockwave():
	var shockwave = backload("res://shockwave.tscn").instantiate()
	shockwave.position = position
	shockwave.shrinktime = 25
	shockwave.speed = 1.5
	if player.screenshake <= 0.5:
		player.screenshake += 0.05
	$"../../".add_child(shockwave)

func delete():
	queue_free()

func _on_shoottimer_timeout():
	if !isdead:
		pass
		#shockwave()
			
func doashockwavecool():
	if !isdead:
		shockwave()
			
func _on_audio_finished():
	if !isdead:
		animplay("move")
		playsound("music", 1)
		$shoottimer.stop()
		$shoottimer.start()
		
func backload(path):
	ResourceLoader.load_threaded_request(path)
	var progress = []
	ResourceLoader.load_threaded_get_status(path, progress)
	var obj
	if progress[0] == 1:
		obj = ResourceLoader.load_threaded_get(path)
	else:
		obj = load(path)
	return obj
