extends Node3D

var waittime = 1
var bulge = 0
var startpop = true
var popping = false
var popped = false
var hurttimer = 0
var entered = false
@onready var startpos = position

@onready var main = get_node("/root").get_node("main")
@onready var player = main.get_node("player")
@onready var map = main.get_node("map")

# Called when the node enters the scene tree for the first time.
func _ready():
	if has_meta("popping"):
		startpop = get_meta("popping")
	if has_meta("waittime"):
		waittime = get_meta("waittime")
	print(map)
		
	if map != null:
		if map.chal == "sodaspeedrun" || get_parent().is_in_group("noenemys"):
			startpop = false
		
	$audio.volume_db = -10
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if popping:
		if bulge < 1:
			bulge += delta*(1.0/waittime)
			$warning.speed_scale = (bulge)
			$warning.transparency = (1-bulge*0.5)
			if has_meta("twohole"):
				$warning2.speed_scale = (bulge)
				$warning2.transparency = (1-bulge*0.5)
			var r = bulge*0.1
			position.x = startpos.x+randf_range(-r, r)
			position.y = startpos.y+randf_range(-r, r)
			position.z = startpos.z+randf_range(-r, r)
		else:
			position = startpos
			$warning.transparency = 1
			if has_meta("twohole"):
				$warning2.transparency = 1
			bulge = 1
			if !popped:
				pop()
	else:
		position = startpos
		$warning.transparency = 1
		if has_meta("twohole"):
			$warning2.transparency = 1
	
	if popped:
		if hurttimer <= 0.05:
			hurttimer += delta
		else:
			hurttimer = 0
			
			var personin = false
			for body in $area.get_overlapping_bodies():
				if body.is_in_group("playergroup"):
					if !entered:
						if map.diff == 0:
							body.hurt(5, "ragdoll")
						else:
							body.hurt(10, "ragdoll")
					if map.diff == 0:
						body.hurt(1, "ragdoll")
					else:
						body.hurt(2, "ragdoll")
					entered = true
					personin = true
					
			if !personin: entered = false
		if !$audio.playing:
			$audio.stream = load("res://audio/pipespray.mp3")
			$audio.play()
	
func start():
	if !popping:
		if startpop:
			popping = true
			$anim/AnimationPlayer.play("default")
			$anim/AnimationPlayer.speed_scale = 1.0/waittime
			$audio.stream = load("res://audio/pipepopping.mp3")
			$audio.play()
		
func pop():
	$particles.emitting = true
	if has_meta("twohole"):
		$particles2.emitting = true
	popped = true
	if !$hole.visible:
		$audio.stream = load("res://audio/pipepop.mp3")
	else:
		$audio.stream = load("res://audio/pipeon.mp3")
	$hole.show()
	$anim.hide()
	$audio.play()
		
func reverse():
	if popping:
		popping = false
		popped = false
		$anim/AnimationPlayer.stop()
		$particles.emitting = false
		if has_meta("twohole"):
			$particles2.emitting = false
		if $hole.visible:
			$audio.stream = load("res://audio/pipeoff.mp3")
			$audio.play()
		else:
			$audio.stop()
	else:
		popping = true
		if !$hole.visible:
			$anim/AnimationPlayer.play("default")
			$anim/AnimationPlayer.speed_scale = 1.0/waittime
			$audio.stream = load("res://audio/pipepopping.mp3")
			$audio.play()
		else:
			$audio.stream = load("res://audio/pipeon.mp3")
			$audio.play()
