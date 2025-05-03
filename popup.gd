extends Control
var bits = 0
var cosmetic = false
var achievement = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	$bits.text = "+"+str(bits)
	$cosmetic.visible = cosmetic
	if achievement != "":
		$bits.hide()

func _on_animation_player_animation_finished(anim_name):
	queue_free()
