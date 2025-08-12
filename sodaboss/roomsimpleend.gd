extends Node3D
var winned = false

func _ready() -> void:
	pass

func _on_win_body_entered(body: Node3D) -> void:
	print(body)
	if body.is_in_group("playergroup"):
		if !winned:
			winned = true
			$"../../".spawnlobbyportal($portalspawn.global_position)
			if ceil($"../../".timer) >= 15:
				$"../../".setAchievement("masterofslidejitsu")
				$audio.stream = load("res://audio/goalreachedbetter.mp3")
				
				if !$"../../".beatchallenges.has("slidejitzumaster"):
					$"../../".beatchallenges["slidejitzumaster"] = true
					var popup = load("res://popup.tscn").instantiate()
					popup.bits = $"../../".getchalbits("slidejitzumaster")
					$"../../".bits += $"../../".getchalbits("slidejitzumaster")
					$"../../sfx".stream = load("res://audio/gainbits.mp3")
					$"../../sfx".play()
					$"../../canvas/hud".add_child(popup)
			$"../../music".stop()
			
			$audio.play()
			$confetti.emitting = true
			$confetti2.emitting = true
			
			$"../../".timer = 100
			$"../../canvas/hud/timer".hide()
			if $"../".chal == "none":
				pass
			else:
				if !$"../../".beatchallenges.has($"../".chal):
					$"../../".beatchallenges[$"../".chal] = true
					var popup = load("res://popup.tscn").instantiate()
					popup.bits = $"../../".getchalbits($"../".chal)
					$"../../".bits += $"../../".getchalbits($"../".chal)
					$"../../sfx".stream = load("res://audio/gainbits.mp3")
					$"../../sfx".play()
					$"../../canvas/hud".add_child(popup)
