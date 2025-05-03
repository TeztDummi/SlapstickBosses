extends Node3D
var timer = 1
var hitplayer = true

# Called when the node enters the scene tree for the first time.
func _ready():
	$Timer.wait_time = timer
	$Timer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !hitplayer:
		for body in $Area3D.get_overlapping_bodies():
			if body.is_in_group("playergroup"):
				if !body.dead:
					body.hurt(20, "darkmagic")
					hitplayer = true

func _on_timer_timeout():
	$AnimationPlayer.play("bust")
	
	hitplayer = false
	$Timer2.start()

func _on_timer_2_timeout():
	queue_free()
