extends Node3D

@onready var main = get_node("/root").get_node("main")
@onready var player = main.get_node("player")

var ammo = 0.0
var reloadrate = 0.08
var minreloadvel = 20
var bigdamage = 50
var timelock = false
var audioeffect = 0
var shootammo = 0.1
var upvel = 30
var combo = 0

var damage = 0 
var shakerate = 0
var timeslow = false

func _ready() -> void:
	$canvas/anim.play("start")

func shoot(raycast):
	pass
	
func turnflashlighton():
	$flashlight.show()
	
func _process(delta: float) -> void:
	var text = "[shake rate="
	text += str(int(round(shakerate*0.5)))
	text += " level="
	text += str(int(round(shakerate*3)))
	text += " connected=1]"
	text += str(int(round(damage)))
	text += "[/shake]"
	$canvas/damage.text = text
	$canvas/damage.modulate.g = clampf(1-shakerate/20, 0, 1)
	$canvas/damage.modulate.b = clampf(1-shakerate/20, 0, 1)
	if shakerate <= 2:
		$canvas/damage.modulate.a -= delta
	else:
		$canvas/damage.modulate.a = 1
		
	shakerate = lerpf(shakerate, 0, delta)
	
	var totalvel = sqrt(pow(player.velocity.x, 2)+pow(player.velocity.y, 2)+pow(player.velocity.z, 2))
	var totalwallvel = sqrt(pow(player.walljumpvel.x, 2) + pow(player.walljumpvel.z, 2))
	ammo += (totalvel-minreloadvel)*reloadrate*delta
	if ammo > 6:
		ammo = 6
	if ammo < 0:
		ammo = 0
		
	$hiss.pitch_scale = (ammo/6)*2
	$hiss.volume_linear = (ammo/6)*2
		
	var needlerot = lerpf(45, -225, ammo/6)
	$gun/needle.rotation_degrees.x = needlerot+randf_range(-5, 5)*(ammo/6)
	if Input.is_action_just_pressed("rightclick"):
		timelock = false
	
	timeslow = false
	if Input.is_action_pressed("rightclick") && !timelock && ammo >= 1:
		player.physicsscale = 0.25
		$anim.speed_scale = 0.25
		ammo -= delta*5
		timeslow = true
		$cooldown.wait_time = 0.1
		$gun/timeslow.show()
		$gun/timeslow2.show()
		audioeffect = lerpf(audioeffect, 1, delta*4)
		main.fov = lerpf(main.fov, 60, delta*4)
		bigdamage = 100
	else:
		if Input.is_action_pressed("rightclick") && !timelock:
			timelock = true
		player.physicsscale = 1
		$anim.speed_scale = 1
		$cooldown.wait_time = 0.5
		$gun/timeslow.hide()
		$gun/timeslow2.hide()
		audioeffect = lerpf(audioeffect, 0, delta*10)
		main.fov = lerpf(main.fov, 75, delta*4)
		bigdamage = 50
	if audioeffect < 0.01: audioeffect = 0
	if audioeffect > 0.99: audioeffect = 1
	AudioServer.get_bus_effect(0, 2).pitch_scale = 1-audioeffect*0.5
	$gun/cylinders.rotation.x += delta*(audioeffect*0.9+0.1)*PI*4
	
	if Input.is_action_just_pressed("click"):
		if $cooldown.is_stopped() && ammo >= shootammo:
			if !timeslow:
				ammo -= 0.5
			$anim.play("RESET")
			$anim.play("shoot")
			$shot.stop()
			$shot.play("default")
			$gun/particles.restart()
			$audio.stream = load("res://audio/horror/gunshoot.mp3")
			$audio.play()
			$cooldown.start()
			if $raycast.is_colliding():
				var col = $raycast.get_collider()
				var particle = load("res://katanaparticle.tscn").instantiate()
				particle.position = $raycast.get_collision_point()
				particle.white = true
				var tempaudio = load("res://tempaudio.tscn").instantiate()
				tempaudio.position = $raycast.get_collision_point()
				tempaudio.volume_linear = 3
				$particlepivot.look_at($raycast.get_collision_point(), Vector3.UP)
				$particlepivot/particles.restart()
				var power = 2
				var mult = 0.8
				if col.is_in_group("flesh"):
					power = 5
					mult = 0.9
					
					particle.blood = true
					
					if col.is_in_group("eye"):
						if col.is_in_group("eye"):
							if col.get_parent().isopen:
								particle.customscale = 2
								player.screenshake += 0.3
								col.get_parent().hit()
								hurt(true)
								tempaudio.stream = load("res://audio/horror/gungreat.mp3")
								mult = 2
								power = 20
								#$timestop.start()
								#get_tree().paused = true
					elif col.is_in_group("tentacle"):
						particle.customscale = 2
						col.get_parent().get_parent().hit()
						hurt(true)
						tempaudio.stream = load("res://audio/horror/gungreat.mp3")
						mult = 2
						power = 20
						#$timestop.start()
						#get_tree().paused = true
					else:
						hurt(false)
						tempaudio.stream = load("res://audio/horror/gungood.mp3")
				else:
					tempaudio.stream = load("res://audio/shootground.wav")
					combo = 0
				if !timeslow:
					player.velocity.x = sin(player.rotation.y)*totalvel*mult+sin(player.rotation.y)*power*0.5
					if player.velocity.y < 0: player.velocity.y = 0
					if player.camera.rotation.x < 0:
						player.velocity.y -= (player.camera.rotation.x/(PI/2))*mult+(player.camera.rotation.x/(PI/2))*upvel
					player.velocity.y += power*0.5
					player.velocity.z = cos(player.rotation.y)*totalvel*mult+cos(player.rotation.y)*power*0.5
				main.get_node("map").add_child(tempaudio)
				tempaudio.play()
				main.get_node("map").add_child(particle)
		elif $cooldown.is_stopped():
			$cooldown.start()
			$anim.play("RESET")
			$anim.play("fail")
			$shot.stop()
			$shot.play("default")
			$shot.frame = 2
			$audio.stream = load("res://audio/horror/gunfail.mp3")
			$audio.play()

func hurt(big):
	var dmg = 10
	if big:
		if !timeslow:
			combo = 0
		dmg = bigdamage+combo*20
		if timeslow:
			combo += 1
			ammo += 1.5
	else:
		combo = 0
	if combo > 10:
		combo = 10
	main.get_node("map").hurt(dmg)
	damage = dmg
	shakerate = damage
	$combo.pitch_scale = (combo/5.0+0.5)
	$combo.volume_linear = clampf((combo/2.5), 0, 1)
	$combo.play()
	
