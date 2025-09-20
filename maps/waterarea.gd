extends Area3D

@onready var main = get_node("/root").get_node("main")
@onready var player = main.get_node("player")

func _process(delta: float) -> void:
	var doit = false
	for body in get_overlapping_bodies():
		if body.is_in_group("playergroup"):
			doit = true
	player.inwater = doit
	main.setwater(doit)

func _on_body_entered_or_exited(body) -> void:
	if body.is_in_group("playergroup"):
		var particle = load("res://waterparticle.tscn").instantiate()
		add_child(particle)
		particle.global_position.x = body.position.x
		particle.global_position.y = get_parent().position.y
		particle.global_position.z = body.position.z
		print("splasgh")
