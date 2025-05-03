extends Area3D

@onready var player = $"../../../player"
var delay = 0.2

func _process(delta):
	if delay > 0: delay -= delta

func _on_body_entered(body):
	if body.is_in_group("playergroup"):
		if delay <= 0:
			print("zoinks")
			var room = get_parent()
			var pos = room.position
			var rot = room.rotation
			print("id: "+str(room.get_meta("id")))
			var newroom = load("res://sodaboss/room"+str(room.get_meta("id"))+".tscn").instantiate()
			newroom.position = pos
			newroom.rotation = rot
			room.get_parent().add_child(newroom)
			room.queue_free()
			player.hurt(10, "fall")
			if player.health > 0:
				print("life is pain")
				player.position = newroom.position
				player.rotation.y = newroom.rotation.y+180
				player.velocity = Vector3.ZERO
				player.screenshake += 0.5
			delay = 0.2
