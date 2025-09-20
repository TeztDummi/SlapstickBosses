extends Node3D
var diff = 1
var chal = "none"
@onready var player = $"../player"
var phase = 0

var dronesdestroyed = false

func _ready():
	player.JUMP_VELOCITY = 8

func _on_starttimer_timeout():
	
	var boss = load("res://gunman.tscn").instantiate()
	boss.name = "boss"
	boss.diff = diff
	boss.chal = chal
	add_child(boss)
	$"../canvas/hud/gunmanbossbar".show()
	
	if chal != "gunmanrockets":
		var gun = load("res://minigun.tscn").instantiate()
		$"../player/camera/gun".add_child(gun)
		$"../player".scroll = 1
	
	if chal == "gunmanrockets":
		$rockets.start()
		player.SPEED = 3.5
		player.JUMP_VELOCITY = 14
		player.candoublejump = true
		player.djseconds = 8

func _process(delta):
	if $"../".quality >= 2:
		$light.rotation.y += delta*0.5
	
	if !dronesdestroyed:
		if $drone.dead:
			if $drone2.dead:
				if $drone3.dead:
					if $drone4.dead:
						$"../".setAchievement("ineedsomeprivacy")
						dronesdestroyed = true
					

func phasechange(phaseguh):
	phase = phaseguh
	
	if phaseguh == 0: _on_anim_animation_finished("start")
	if phaseguh == 1:
		$mapsoicanscaleit/anim.play("first")
		if chal == "gunmanrockets": $rockets.wait_time = 1.5
	if phaseguh == 2:
		$riotshielddrop.start()
		for i in range(3):
			_on_riotshielddrop_timeout()
	if phaseguh == 3:
		$mapsoicanscaleit/anim.play("second")
		if chal == "gunmanrockets":
			$rockets.wait_time = 1
			$mapsoicanscaleit/anim.play("settomax")
			$riotshielddrop.start()
			for i in range(3):
				_on_riotshielddrop_timeout()
	if phaseguh == 4:
		$mapsoicanscaleit/anim.play("third")
		if chal == "gunmanrockets": $rockets.wait_time = 0.75
	if phaseguh == 5:
		$mapsoicanscaleit/anim.play("settomax")
		$riotshielddrop.stop()
		if chal == "gunmanrockets": $rockets.wait_time = 0.5
	
	print(phaseguh)

func _on_anim_animation_finished(anim_name):
	if anim_name == "start":
		for child in $glass0.get_children():
			child.rise()
	if anim_name == "first":
		for child in $glass1.get_children():
			child.rise()
	if anim_name == "second":
		for child in $glass2.get_children():
			child.rise()

func _on_riotshielddrop_timeout():
	var item = load("res://riotshielditem.tscn").instantiate()
	item.position.y = 68
	if phase >= 3:
		item.position.x = round((randf_range(-40, 50))/10)*10-5
		item.position.z = round((randf_range(-40, 50))/10)*10-5
	elif phase >= 1:
		item.position.x = round((randf_range(-20, 30))/10)*10-5
		item.position.z = round((randf_range(-20, 30))/10)*10-5
	$"../map".add_child(item)

func _on_rockets_timeout():
	if chal == "gunmanrockets":
		var bullet = load("res://gunmanrocket.tscn").instantiate()
		bullet.rotation = Vector3(PI/2,0,0)
		bullet.position.y = 68
		if phase >= 3:
			bullet.position.x = round((randf_range(-40, 50))/10)*10-5
			bullet.position.z = round((randf_range(-40, 50))/10)*10-5
		elif phase >= 1:
			bullet.position.x = round((randf_range(-20, 30))/10)*10-5
			bullet.position.z = round((randf_range(-20, 30))/10)*10-5
		bullet.time = PI/2-0.5
		$"../map".add_child(bullet)
