extends Node3D

@onready var main = get_node("/root").get_node("main")
@onready var player = main.get_node("player")
@onready var map = main.get_node("map")
var didnoise = false
var didlargenoise = false

var shakerate = 0
var damage = 0

func shoot(raycast):
	pass
	
func turnflashlighton():
	$flashlight.show()
	
func _process(delta: float) -> void:
	if shakerate <= 2:
		$canvas/damage.modulate.a -= delta
	else:
		$canvas/damage.modulate.a = 1
		
	shakerate = lerpf(shakerate, 0, delta)
	
	if Input.is_action_just_pressed("click"):
		if $cooldown.is_stopped():
			var tempaudio = load("res://tempaudio.tscn").instantiate()
			add_child(tempaudio)
			tempaudio.stream = load("res://audio/horror/katanaswing.mp3")
			tempaudio.play()
			$cooldown.start()
			$spam.start()
			if !$spam.is_stopped():
				if $anim.speed_scale > 0.4:
					$cooldown.wait_time *= 1.5
					$spam.wait_time *= 1.5
					$anim.speed_scale /= 1.5
			$anim.play("RESET")
			$anim.play("swing")
			didlargenoise = false
			didnoise = false
			for ray in $raycasts.get_children():
				if ray.is_colliding():
					var particle = load("res://katanaparticle.tscn").instantiate()
					particle.position = ray.get_collision_point()
					var totalvel = sqrt(pow(player.velocity.x, 2)+pow(player.velocity.z, 2))
					var totalwallvel = sqrt(pow(player.walljumpvel.x, 2) + pow(player.walljumpvel.z, 2))
					var pitch = clampf((totalwallvel/player.SPEED)/10, 0.75, 1.5)
					var vol = -80+clampf((totalwallvel/player.SPEED)*10, 60, 78)  
					if ray.get_collider().is_in_group("flesh"):
						var power = 10
						var mult = 0.9
						
						particle.blood = true
						
						if ray.get_collider().is_in_group("eye") || ray.get_collider().is_in_group("tentacle") || ray.get_collider().is_in_group("floortentacle"):
							if ray.get_collider().is_in_group("eye"):
								if ray.get_collider().get_parent().isopen:
									particle.customscale = 2
									player.screenshake += 0.3
							else: particle.customscale = 2
							if !didlargenoise:
								mult = 2
								power = 20
								$audio.stream = load("res://audio/pipehitgreat.mp3")
								
								main.get_node("map").hurt(totalwallvel*2)
								damage = totalwallvel*2
								shakerate = damage
								_on_texttimer_timeout()
								
								if damage >= 200:
									main.setAchievement("aroundtheworld")
									
								if damage >= 150:
									player.impactframe()
									player.screenshake += 2
								
								if ray.get_collider().is_in_group("eye"):
									if ray.get_collider().get_parent().isopen:
										ray.get_collider().get_parent().hit()
										print("eye")
										$timestop.start()
										get_tree().paused = true
								if ray.get_collider().is_in_group("tentacle"):
									ray.get_collider().get_parent().get_parent().hit()
									print("tentacle")
									$timestop.start()
									get_tree().paused = true
								if ray.get_collider().is_in_group("floortentacle"):
									$timestop.start()
									get_tree().paused = true
						else:
							if !didlargenoise && !didnoise:
								$audio.stream = load("res://audio/pipehitgood.mp3")
								main.get_node("map").hurt(totalwallvel*0.25)
								damage = totalwallvel*0.25
								shakerate = damage*4
								_on_texttimer_timeout()
						if !didlargenoise:
							player.velocity.x = sin(player.rotation.y)*totalwallvel*mult+sin(player.rotation.y)*power
							player.velocity.y = 15*mult
							player.velocity.z = cos(player.rotation.y)*totalwallvel*mult+cos(player.rotation.y)*power
						totalvel = sqrt(pow(player.velocity.x, 2)+pow(player.velocity.z, 2))
						pitch = clampf((totalwallvel/player.SPEED)/10, 0.75, 1.5)
						vol = -80+clampf((totalwallvel/player.SPEED)*10, 60, 78) 
						
						didnoise = true
						
						if ray.get_collider().is_in_group("eye"):
							didlargenoise = true 
						if ray.get_collider().is_in_group("tentacle"):
							didlargenoise = true
						if ray.get_collider().is_in_group("floortentacle"):
							didlargenoise = true
					else:
						if !didnoise:
							if !ray.get_collider() is Area3D:
								$audio.stream = load("res://audio/pipehitbad.mp3")
								particle.customscale = 0.5
					$audio.pitch_scale = pitch
					$audio.play()
					$audio.volume_db = vol
					
					main.get_node("map").add_child(particle)

func _on_timestop_timeout():
	get_tree().paused = false


func _on_texttimer_timeout() -> void:
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

func _on_spam_timeout() -> void:
	$cooldown.wait_time = 0.15
	$spam.wait_time = 0.25
	$anim.speed_scale = 1
