extends Control
var alpha = 0
var isin = true
var musicplace = 0
var dontplay = false

func _process(delta):
	if isin:
		if alpha < 1:
			alpha += delta*4
	else:
		if alpha > 0:
			alpha -= delta*4
	
	$text.modulate = Color(1, 1, 1, alpha)

	$text/bits2.text = str(int($"../../..".bits))
	#fuckass godot update made me do this nightmare nightmare
	if $"../difficultylabel".visible:
		$text/bits2.position.y = 70
		$text/Difficulty.show()
		$text/box5.show()
		
		for i in range(3):
			if $"../../../map".diff == i:
				$text/Difficultyselect.set_item_disabled(i, true)
			else:
				$text/Difficultyselect.set_item_disabled(i, false)
		
	else:
		$text/bits2.position.y = 0
		$text/Difficulty.hide()
		$text/box5.hide()
	
func _unhandled_input(event):
	if Input.is_action_just_pressed("esc"):
		if visible:
			if !$pausebg.is_playing():
				$pausebg.play("end")
				isin = false
				$text/Difficultyselect.visible = false
				$text/box6.visible = false

func _on_resume_pressed():
	if visible:
		if !$pausebg.is_playing():
			$pausebg.play("end")
			isin = false
			$text/Difficultyselect.visible = false
			$text/box6.visible = false
		
func _on_pausebg_animation_finished():
	if visible:
		if $pausebg.animation == "end":
			hide()
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			$"../../../music".stream_paused = false
			get_tree().paused = false
			$"../../..".save_game()
			$"../../.."._on_options_back_pressed()

func _on_lobby_pressed():
	_on_resume_pressed()
	if $"../../../map".get_child(0).name != "lobby":
		$"../../../canvas/hud/transitionin".play()
		$"../../../".transition = ["loadmap", "res://maps/lobby.tscn", -1]
		$"../../../".save_game()



func _on_difficulty_pressed() -> void:
	var dildo = $"../../../map".diff
	var chal = "none"
	if "chal" in $"../../../map":
		chal = $"../../../map".chal
	if dildo != -1 && chal == "none":
		$text/Difficultyselect.visible = !$text/Difficultyselect.visible
		$text/box6.visible = !$text/box6.visible

func _on_difficultyselect_item_selected(index: int) -> void:
	var dildo = index
	_on_resume_pressed()
	$"../../../canvas/hud/transitionin".play()
	$"../../../".transition = ["loadmap", "res://maps/"+$"../../../map".get_child(0).name+".tscn", dildo]
