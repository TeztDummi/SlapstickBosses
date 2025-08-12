extends Area3D
var time = 0

@onready var main = get_node("/root").get_node("main")
@onready var player = main.get_node("player")
@onready var map = main.get_node("map")

func _process(delta):
	time += delta
	position.y += sin(time*5)*0.01

func _on_body_entered(body):
	if $Timer.is_stopped():
		if body.is_in_group("playergroup"):
			if !main.bitbags.has(str(get_meta("id"))):
				var popup = load("res://popup.tscn").instantiate()
				popup.bits = 100
				main.bits += 100
				main.get_node("sfx").stream = load("res://audio/gainbits.mp3")
				main.get_node("sfx").play()
				main.get_node("canvas/hud").add_child(popup)
				main.bitbags[str(get_meta("id"))] = true
				$particle.emitting = true
				$MeshInstance3D.hide()
				$Timer.start()

func _on_timer_timeout():
	queue_free()

func _on_starttimer_timeout():
	if main.bitbags.has(str(get_meta("id"))):
		queue_free()
