extends Node3D
var choices = []
var time = 1
var mult = 1
var goup = 0

func _ready():
	if randf() > 0.5: mult = -1
# Called when the node enters the scene tree for the first time.
func detect():
	var possibilitys = []
	for body in $Area3D.get_overlapping_bodies():
		if body.is_in_group("musicplat"):
			if body.position.x+body.position.z == 0:
				possibilitys.append(body)
	if possibilitys.size() == 0: queue_free()
	else:
		for i in range(5):
			var choice = possibilitys.pick_random()
			choices.append(choice)
			var marker = load("res://musicboss/musicplatmovermarker.tscn").instantiate()
			marker.target = choice.get_parent()
			if mult == 1: marker.rotation_degrees.y = 180
			get_parent().add_child(marker)
		print(choices)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if choices != []:
		for choice in choices:
			if choice != null:
				if time > 0: time -= delta/3
				else: time = 0
				choice.get_child(0).get_surface_override_material(0).albedo_color = Color(1, 1-time, 1-time)
				print(time)
				
				if goup == 0: choice.get_parent().position.x += pow(time, 4)*delta*mult*15
				else: choice.get_parent().position.y += pow(time, 4)*delta*15*goup

func _on_timer_timeout():
	detect()
