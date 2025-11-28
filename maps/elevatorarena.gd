extends Node3D
var diff = 1
var chal = "none"
var neo = 0
var neostart = Vector3.ZERO
@onready var player = $"../player"
var boss

func _on_starttimer_timeout():
	$"../music".stream = load("res://audio/music/bossmusic.mp3")
	$"../music".play()
	
	boss = load("res://elevator/elevatorboss.tscn").instantiate()
	boss.name = "boss"
	boss.diff = diff
	boss.chal = chal
	add_child(boss)
	
	if chal == "2elevators":
		var boss2 = load("res://elevator/elevatorboss.tscn").instantiate()
		boss2.name = "boss2"
		boss2.diff = diff
		boss2.chal = chal
		boss2.ismain = false
		add_child(boss2)
	
	if chal == "2elevators": $"../".timer = 60
	else: $"../".timer = 90
	$"../canvas/hud/timer".show()
	
	if chal == "rats":
		for i in range(20):
			var rat = load("res://elevator/rat.tscn").instantiate()
			rat.position = Vector3(position.x+randf_range(0, 20), 20, position.z+randf_range(-20, 20))
			add_child(rat)

func _on_rats_timeout():
	if chal == "rats":
		var rat = load("res://elevator/rat.tscn").instantiate()
		rat.position = Vector3(position.x+randf_range(-20, 20), 20, position.z+randf_range(-20, 20))
		add_child(rat)
		
func _physics_process(delta):
	if neo >= 1:
		if player.is_on_floor():
			if neo == 2:
				if sqrt(pow(player.position.x-neostart.x, 2)+pow(player.position.z-neostart.z, 2)) >= 4:
					if sqrt(pow(player.position.x-boss.position.x, 2)+pow(player.position.z-boss.position.z, 2)) <= 8:
						print("neo'd:")
						$"../".setAchievement("straitupneodon")
			neo = 0

func _on_neodetect_body_entered(body):
	if body.is_in_group("playergroup"):
		if boss.anim.current_animation == "laserblast":
			if abs(boss.position.x) >= 17 || abs(boss.position.z) >= 17:
				neo = 1
				neostart = player.position
				
func _on_neodetect_body_exited(body):
	if body.is_in_group("playergroup"):
		if neo == 1:
			neo = 2
