extends Node3D

var waittime = 1
var bulge = 0
var startpop = true
var popping = false
var popped = false
var hurttimer = 0
var entered = false

@onready var player = $"../../../player"

# Called when the node enters the scene tree for the first time.
func _ready():
	if has_meta("popping"):
		startpop = get_meta("popping")
	if has_meta("waittime"):
		waittime = get_meta("waittime")
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if popping:
		if bulge < 1: bulge += delta*(1.0/waittime)
		else:
			bulge = 1
			if !popped:
				pop()
	
	if popped:
		if hurttimer <= 0.05:
			hurttimer += delta
		else:
			hurttimer = 0
			
			var personin = false
			for body in $area.get_overlapping_bodies():
				if body.is_in_group("playergroup"):
					if !entered: body.hurt(10, "bluelaser")
					body.hurt(2, "bluelaser")
					entered = true
					personin = true
					
			if !personin: entered = false
	
func start():
	if !popping:
		if startpop:
			popping = true
			$anim/AnimationPlayer.play("default")
			$anim/AnimationPlayer.speed_scale = 1.0/waittime
		
func pop():
	$particles.emitting = true
	if has_meta("twohole"):
		$particles2.emitting = true
	popped = true
	$hole.show()
	$anim.hide()
		
func reverse():
	if popping:
		popping = false
		popped = false
		$anim/AnimationPlayer.stop()
		$particles.emitting = false
		if has_meta("twohole"):
			$particles2.emitting = false
	else:
		popping = true
		$anim/AnimationPlayer.play("default")
		$anim/AnimationPlayer.speed_scale = 1.0/waittime
