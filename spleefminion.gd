extends StaticBody3D

@onready var main = get_node("/root").get_node("main")
@onready var player = main.get_node("player")
@onready var map = main.get_node("map")
var dir = 0
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var checkbreak = 0
var velocity = Vector3.ZERO

func finishmove():
	position.x += sin(dir)*2
	position.z += cos(dir)*2
	
func _process(delta):
	if $main.visible:
		if !$floordetect.is_colliding():
			velocity.y -= gravity*delta*0.01
			position.y += velocity.y
		else:
			velocity.y = 0
			position.y = 0

		var dothe = null
		for body in $break.get_overlapping_bodies():
			if body != self:
				if body.is_in_group("spleefminion") || body.is_in_group("playergroup"):
					dothe = body
		if dothe != null:
			checkbreak += delta*24
		else:
			checkbreak = 0
		checkbreak = clampf(checkbreak, 0, 1)
		if dothe != null && checkbreak >= 1:
			hurt(10)
			dothe.hurt(10, "bluelaser")
			
		if position.y < -40:
			queue_free()
			
func checkblock(thedir):
	var check = $"check/1"
	if sin(thedir) == 1:
		check = $"check/3"
	if sin(thedir) == -1:
		check = $"check/4"
	if cos(thedir) == 1:
		check = $"check/2"
	if cos(thedir) == -1:
		check = $"check/1"
		
	if check.is_colliding():
		if check.get_collider().is_in_group("spleefblock"):
			if !check.get_collider().get_parent().ice:
				return true
			else:
				return false
		else:
			return false
	else:
		return false

func _on_chooseblock_timeout() -> void:
	if $floordetect.is_colliding() && $main.visible:
		dir = PI+round(atan2(position.x-player.position.x, position.z-player.position.z)/(PI/2))*(PI/2)
		
		if checkblock(dir):
			$main.rotation.y = dir
			moveanim()
		elif checkblock(dir+PI/2):
			dir += PI/2
			$main.rotation.y = dir
			moveanim()
		elif checkblock(dir-PI/2):
			dir -= PI/2
			$main.rotation.y = dir
			moveanim()
		elif checkblock(dir+PI):
			dir += PI
			$main.rotation.y = dir
			moveanim()
			
func moveanim():
	$anim.playfps("move", 24)
	$audio.play()

func _on_anim_animation_finished(anim_name: StringName) -> void:
	finishmove()
	$anim.play("RESET")
			
func hurt(dmg, idk = "idk"):
	if $main.visible:
		$col.disabled = true
		$explodeparticles.emitting = true
		$main.hide()
		$audio.stream = load("res://audio/spleef/firebreak.mp3")
		$audio.play()
		for body in $area.get_overlapping_bodies():
			if body.is_in_group("spleefblock"):
				body.get_parent().hurt()

func _on_checkbreak_timeout() -> void:
	for body in $break.get_overlapping_bodies():
		if body != self:
			if body.is_in_group("spleefminion") || body.is_in_group("playergroup"):
				hurt(10)
				body.hurt(15, "bluelaser")

func _on_sfx_timeout() -> void:
	if $main.visible:
		$audio2.stream = load("res://audio/spleef/minionsound"+str(randi_range(1, 6))+".mp3")
		$audio2.play()
