extends Node3D
var delay = 0.5
var rusure = false
var hover = false

# Called when the node enters the scene tree for the first time.
func _ready():
	if has_meta("price"):
		$pricetag.show()
		if $"../..".lobbypower.has("slide"):
			queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if has_meta("price"):
		#pricetag
		$pricetag/chalbits.scale.x = 5.4
		$pricetag/chalbits.scale.z = $pricetag/chalbits.scale.x
		if hover:
			$subview/bits.text = str("BUY?")
			if rusure:
				$subview/bits.text = str("U SURE?")
				if $"../..".bits < get_meta("price"): $subview/bits.text = str("UR POOR")
				$pricetag/chalbits.scale.x = 4
				$pricetag/chalbits.scale.z = $pricetag/chalbits.scale.x
			$pricetag/chalbits.position.x = 1.5
			$subview/bits/bitsoffset/bitssprite.hide()
		else:
			rusure = false
			$subview/bits.text = str(get_meta("price"))
			$pricetag/chalbits.position.x = 1
			$subview/bits/bitsoffset/bitssprite.position.x = $subview/bits.get_total_character_count()*20
			$subview/bits/bitsoffset/bitssprite.show()
	hover = false
	if delay > 0:
		delay -= delta
	if $floordetect != null:
		if $floordetect.get_collider() != null:
			global_position.y = $floordetect.get_collision_point().y
			
func pickup():
	if delay <= 0:
		if has_meta("price") && !rusure:
			rusure = true
			delay = 0.5
		else: 
			var cangrab = false
			if has_meta("price"):
				if $"../..".bits >= get_meta("price"): cangrab = true
			else: cangrab = true
			if cangrab:
				#grab or spend bits and grab
				if !$anim.is_playing():
					if has_meta("price"):
						$"../..".bits -= get_meta("price")
						$"../../sfx2".stream = load("res://audio/spendbits.mp3")
						$"../../sfx2".play()
						$anim.play("use")
						$"../../".lobbypower["slide"] = "slide"
						$"../../player/".cancrouch = true
						$"../../".save_game()
