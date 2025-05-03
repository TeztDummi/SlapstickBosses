extends Node3D
var yvel = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if position.y > 0:
		yvel -= delta
		position.y += yvel
	if position.y <= 0:
		position.y = 0
	$mesh.rotate_y(delta*(PI/2))

func _on_area_body_entered(body):
	if body.is_in_group("playergroup"):
		var giveitem = true
		for child in $"../../player/camera/gun".get_children():
			if child.is_in_group("riotshield"):
				giveitem = false
		if giveitem:
			var gun = load("res://riotshield.tscn").instantiate()
			$"../../player/camera/gun".add_child(gun)
			$"../../player".scroll = 1
			queue_free()

func _on_animation_player_animation_finished(anim_name):
	queue_free()
