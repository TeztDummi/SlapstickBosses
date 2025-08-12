extends Node3D
var diff = 1
@onready var player = $"../player"
var wave = 0
var chal = "none"

func _on_starttimer_timeout():
	$"../music".stream = load("res://audio/music/catboss.mp3")
	$"../music".play()
	
	$"../canvas/hud/catcount".show()
	
	var boss = load("res://catspawner.tscn").instantiate()
	boss.diff = diff
	boss.wave = wave
	boss.chal = chal
	add_child(boss)
	boss.name = "boss"
	
	if chal == "6pack":
		player.SPEED = 3.5

	if chal == "catrpg":
		var gun = load("res://catrpg.tscn").instantiate()
		$"../player/camera/gun".add_child(gun)
		$"../player".scroll = 1
	else:
		var gun = load("res://kittyblaster9000.tscn").instantiate()
		$"../player/camera/gun".add_child(gun)
		$"../player".scroll = 1

func _on_jakesarea_body_entered(body):
	if body.is_in_group("playergroup"):
		$"../".setAchievement("jakeproof")
