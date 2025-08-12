extends Area3D

@onready var main = get_node("/root").get_node("main")
@onready var player = main.get_node("player")
@onready var map = main.get_node("map")

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
			for child in newroom.get_children():
				if room.get_parent().chal == "sodaspeedrun" || room.is_in_group("noenemys"):
					if child.is_in_group("popcop") || child.is_in_group("sodacan")  || child.has_meta("nospeedrun"):
						child.queue_free()
				if room.get_parent().diff != 2:
					if child.has_meta("hard"):
						child.queue_free()
				else:
					if child.has_meta("nohard"):
						child.queue_free()
			if room.is_in_group("noenemys"):
				newroom.add_to_group("noenemys")
			room.get_parent().add_child(newroom)
			room.queue_free()
			if map.diff == 2:
				player.hurt(10, "fall")
			else:
				player.hurt(6, "fall")
			if player.health > 0:
				print("life is pain")
				player.position = newroom.position
				player.rotation.y = newroom.rotation.y+180
				player.velocity = Vector3.ZERO
				player.screenshake += 0.5
			delay = 0.2
