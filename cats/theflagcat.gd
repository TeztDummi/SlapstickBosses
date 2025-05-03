extends CharacterBody3D
var health = 10000
@onready var player = $"../../../player"
var isdead = false
var hurttime = 0
var speed = 2
var toldpeople = []
var toldeveryone = false
var flagtext = "??"
var runaway = false

func _ready():
	$SubViewport2/wavetext.text = flagtext
	print(0.8+float(flagtext)/10)
	playsound("res://audio/wave/wave ("+flagtext+").wav", 0.8+float(flagtext)/10)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if hurttime > 0:
		hurttime -= delta*4
		$visual/cat.get_surface_override_material(0).emission = Color(hurttime/2, 0, 0)
	else: 
		hurttime = 0
		$visual/cat.get_surface_override_material(0).emission = Color(0, 0, 0)
	
	if !player.dead:
		if !isdead:
			if !is_on_floor():
				velocity.y -= 30*delta
			
			if sqrt(pow(velocity.x, 2) + pow(velocity.y, 2)  + pow(velocity.z, 2)) < 0.1:
				if is_on_floor() && !player.dead:
					velocity.y += 15
			
			var direction = Vector2(player.position.x-position.x, player.position.z-position.z).normalized()
			var disttoclosest = sqrt(pow(position.x-player.position.x, 2)+pow(position.z-player.position.z, 2))
			if !runaway:
				if disttoclosest < 20:
					velocity.x = direction.x*(disttoclosest*1.5)
					velocity.z = direction.y*(disttoclosest*1.5)
				else:
					velocity.x = direction.x*(20*1.5)
					velocity.z = direction.y*(20*1.5)
			else:
				velocity.x = 20
				velocity.z = 0
				if position.x >= 90:
					delete()
				
			if disttoclosest < 8:
				runaway = true
							
			move_and_slide()

func hurt(amount):
	if !isdead:
		health -= amount
		hurttime = 1
		if health <= 0:
			$visual/healthsprite.hide()
			isdead = true 

func playsound(sound, pitch):
	$audio.stream = load(sound)
	$audio.pitch_scale = pitch
	$audio.play()

func delete():
	queue_free()

func _on_audio_finished():
	playsound("res://audio/wave/wave ("+flagtext+").wav", 0.8+float(flagtext)/10)
