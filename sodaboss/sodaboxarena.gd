extends Node3D


@onready var player = $"../../player"
var didintro = false
var changedmusic = false

func _ready() -> void:
	preload("res://audio/music/sodaboxcutscene.mp3")
	$endcan.hide()
	if $"../".chal == "justbox":
		$intro.play("skip")

func lights(on):
	print("lights")
	$introcam.environment.background_energy_multiplier = on
	$"../DirectionalLight3D".visible = on
	
func _process(delta: float) -> void:
	if !changedmusic:
		var dist = sqrt(pow(position.x-player.position.x, 2)+pow(position.z-player.position.z, 2))
		if dist <= 5:
			$"../".changemusic("factoryescape", "factoryescapecalm")
			changedmusic = true

func _on_start_body_entered(body: Node3D) -> void:
	if body.is_in_group("playergroup") && !didintro:
		if $"../".chal != "justbox":
			$"../../music".stream = load("res://audio/music/sodaboxcutscene.mp3")
			$"../../music".play()
			$intro.play("default")
			$introcam.current = true
			for child in $"../../map".get_children():
				for roomchild in child.get_children():
					if roomchild.is_in_group("popcop"):
						roomchild.queue_free()
			player.health = 100
		else:
			$sodabox._on_anim_animation_finished("intro")
			$ceilingcans.start()
		didintro = true
		

func _on_intro_animation_finished(anim_name: StringName) -> void:
	if anim_name == "default":
		player.camera.current = true

func _on_kick_body_entered(body: Node3D, bypass = false) -> void:
	if (body.is_in_group("playergroup") || bypass) && $endcan.visible && !$endanim.is_playing():
		var totalvel = sqrt(pow(body.velocity.x, 2)+pow(body.velocity.z, 2))
		if (body.slide && totalvel > 5) || bypass:
			$endanim.play("kick")
			$"../../sfx2".stream = load("res://audio/sodabox/kickbigcan.mp3")
			$"../../sfx2".play()
			$endcancol.position.y -= 2
		
func _on_kickother_body_entered(body: Node3D) -> void:
	if body.is_in_group("playergroup") && $endcan.visible && !$endanim.is_playing():
		var totalvel = sqrt(pow(body.velocity.x, 2)+pow(body.velocity.z, 2))
		if body.slide && totalvel > 5:
			$endanim.play("kickother")
			$"../../sfx2".stream = load("res://audio/sodabox/kickbigcanother.mp3")
			$"../../sfx2".play()
			$endcancol.position.y -= 2

func _on_endanim_animation_finished(anim_name: StringName) -> void:
	if anim_name == "kick" || anim_name == "kickother":
		$"../../".spawnlobbyportal($portalspawn.global_position)
		if $"../".chal == "none":
			var earnedbits = $"../../".calcbits($"../".diff, $"../../".beatsoda, 1)
			$"../../".bits += earnedbits
			if $"../".diff == 2:
				$"../../".setAchievement("rankcleanedemout")
				if player.health >= 100: $"../../".setAchievement("100")
			if earnedbits > 0:
				var popup = load("res://popup.tscn").instantiate()
				popup.bits = earnedbits
				$"../../sfx".stream = load("res://audio/gainbits.mp3")
				if $"../".diff == 2 && !$"../../".unlockedheads.has("sodacan"):
					popup.cosmetic = true
					$"../../".unlockedheads.append("sodacan")
					$"../../sfx".stream = load("res://audio/gaincosmetic.mp3")
				$"../../sfx".play()
				$"../../canvas/hud".add_child(popup)
			if $"../".diff > $"../../".beatsoda: $"../../".beatsoda = $"../".diff
		else:
			if !$"../../".beatchallenges.has($"../".chal):
				$"../../".beatchallenges[$"../".chal] = true
				var popup = load("res://popup.tscn").instantiate()
				popup.bits = $"../../".getchalbits($"../".chal)
				$"../../".bits += $"../../".getchalbits($"../".chal)
				$"../../sfx".stream = load("res://audio/gainbits.mp3")
				$"../../sfx".play()
				$"../../canvas/hud".add_child(popup)

func _on_ceilingcans_timeout() -> void:
	if $"../".chal == "justbox":
		var dropper = load("res://sodaboss/candropper.tscn").instantiate()
		var center = $center.global_position
		dropper.position.x = randf_range(center.x-16, center.x+16)
		dropper.position.y = center.y
		dropper.position.z = randf_range(center.z-16, center.z+16)
		$"../".add_child(dropper)
