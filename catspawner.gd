extends Node3D
var wave = 0
@onready var startingchildren = get_child_count()
var multiplier = 1
@onready var player = $"../../player"
var amountofwaves
var spawnedportal = false
var chal = "none"

var diff = 1
# Called when the node enters the scene tree for the first time.
func _ready():
	if chal == "none":
		if diff == 0:
			multiplier = 0.5
			amountofwaves = 5
		if diff == 1:
			multiplier = 1
			amountofwaves = 6
		if diff == 2:
			multiplier = 1.2
			amountofwaves = 6
	elif chal == "6pack":
		amountofwaves = 1
	elif chal == "catrpg":
		amountofwaves = 3

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if get_child_count()-startingchildren == 0 && !spawnedportal:
		if chal == "none":
			if diff == 0:
				$"../../".catwaveeasy = wave
			if diff == 1:
				$"../../".catwavemedium = wave
			if diff == 2:
				$"../../".catwavehard = wave
			$"../../".save_game()
		if chal == "catrpg":
			$"../../".catwaverpg = wave
			$"../../".save_game()
		wave += 1
		player.health = 100
		if wave <= amountofwaves:
			spawnflagcat(getrandompos(), wave)
			if chal == "none":
				if wave == 1:
					for i in range(ceil(4*multiplier)):
						spawnenemy(getrandompos(), "res://cats/oneofthem.tscn")
					for i in range(ceil(1*multiplier)):
						spawnenemy(getrandompos(), "res://cats/lilwhisker.tscn")
				if wave == 2:
					for i in range(ceil(8*multiplier)):
						spawnenemy(getrandompos(), "res://cats/oneofthem.tscn")
					for i in range(ceil(2*multiplier)):
						spawnenemy(getrandompos(), "res://cats/lilwhisker.tscn")
					for i in range(ceil(1*multiplier)):
						spawnenemy(getrandompos(), "res://cats/floatyshadowykitty.tscn")
				if wave == 3:
					for i in range(ceil(4*multiplier)):
						spawnenemy(getrandompos(), "res://cats/lilwhisker.tscn")
					for i in range(ceil(2*multiplier)):
						spawnenemy(getrandompos(), "res://cats/floatyshadowykitty.tscn")
				if wave == 4:
					for i in range(ceil(2*multiplier)):
						spawnenemy(getrandompos(), "res://cats/lilwhisker.tscn")
					for i in range(ceil(1*multiplier)):
						spawnenemy(getrandompos(), "res://cats/roobeer.tscn")
				if wave == 5:
					for i in range(ceil(2*multiplier)):
						spawnenemy(getrandompos(), "res://cats/floatyshadowykitty.tscn")
					for i in range(ceil(2*multiplier)):
						spawnenemy(getrandompos(), "res://cats/roobeer.tscn")
				if wave == 6:
					if $"../../music".stream.resource_path.get_file() != "spicycatboss.mp3":
						var playtime = $"../../music".get_playback_position()
						playtime -= 2.82
						for i in range(10):
							if playtime > 22.58:
								playtime -= 22.58
							else:
								break
						
						$"../../music".stream = load("res://audio/music/spicycatboss.mp3")
						$"../../music".play()
						$"../../music".seek(playtime)
					for i in range(ceil(8*multiplier)):
						spawnenemy(getrandompos(), "res://cats/oneofthem.tscn")
					for i in range(ceil(4*multiplier)):
						spawnenemy(getrandompos(), "res://cats/lilwhisker.tscn")
					for i in range(ceil(2*multiplier)):
						spawnenemy(getrandompos(), "res://cats/floatyshadowykitty.tscn")
					for i in range(ceil(2*multiplier)):
						spawnenemy(getrandompos(), "res://cats/roobeer.tscn")
			elif chal == "6pack":
				if wave == 1:
					for i in range(ceil(6)):
						spawnenemy(getrandompos(), "res://cats/roobeer.tscn")
			elif chal == "catrpg":
				if wave == 1:
					for i in range(ceil(64)):
						spawnenemy(getrandompos(), "res://cats/oneofthem.tscn")
					for i in range(ceil(8)):
						spawnenemy(getrandompos(), "res://cats/floatyshadowykitty.tscn")
				if wave == 2:
					for i in range(ceil(12)):
						spawnenemy(getrandompos(), "res://cats/lilwhisker.tscn")
					for i in range(ceil(6)):
						spawnenemy(getrandompos(), "res://cats/floatyshadowykitty.tscn")
				if wave == 3:
					for i in range(ceil(18)):
							spawnenemy(getrandompos(), "res://cats/oneofthem.tscn")
					for i in range(ceil(12)):
						spawnenemy(getrandompos(), "res://cats/lilwhisker.tscn")
					for i in range(ceil(8)):
						spawnenemy(getrandompos(), "res://cats/floatyshadowykitty.tscn")
					for i in range(ceil(1)):
						spawnenemy(getrandompos(), "res://cats/roobeer.tscn")
		else:
			$"../../".spawnlobbyportal()
			if chal == "none":
				var earnedbits = $"../../".calcbits(diff, $"../../".beatcat, 1)
				$"../../".bits += earnedbits
				if diff == 2:
					$"../../".setAchievement("dinnerisserved")
					if player.health >= 100: $"../../".setAchievement("100")
				if earnedbits > 0:
					var popup = load("res://popup.tscn").instantiate()
					popup.bits = earnedbits
					$"../../sfx".stream = load("res://audio/gainbits.mp3")
					if diff == 2 && !$"../../".unlockedheads.has("catsoldier"):
						popup.cosmetic = true
						$"../../".unlockedheads.append("catsoldier")
						$"../../sfx".stream = load("res://audio/gaincosmetic.mp3")
					$"../../sfx".play()
					$"../../canvas/hud".add_child(popup)
					
				if diff > $"../../".beatcat: $"../../".beatcat = diff
			else:
				if !$"../../".beatchallenges.has(chal):
					$"../../".beatchallenges[chal] = true
					var popup = load("res://popup.tscn").instantiate()
					popup.bits = $"../../".getchalbits(chal)
					$"../../".bits += $"../../".getchalbits(chal)
					$"../../sfx".stream = load("res://audio/gainbits.mp3")
					$"../../sfx".play()
					$"../../canvas/hud".add_child(popup)
			if chal == "catrpg":
				$"../../".catwaverpg = 0
			else:
				if diff == 0: $"../../".catwaveeasy = 0
				if diff == 1: $"../../".catwavemedium = 0
				if diff == 2: $"../../".catwavehard = 0
			
			$"../../".save_game()
			spawnedportal = true
			$"../../music".stop()
			
func getrandompos() -> Vector3:
	var rand = randi_range(0, 3)
	var rand2 = randf_range(-90, 90)
	var pos
	if rand == 0: pos = Vector3(90, 0, rand2)
	if rand == 1: pos = Vector3(-90, 0, rand2)
	if rand == 2: pos = Vector3(rand2, 0, 90)
	if rand == 3: pos = Vector3(rand2, 0, -90)
	return pos
	
func spawnenemy(pos, file):
	var enemy = load(file).instantiate()
	enemy.position = pos
	add_child(enemy)
	if wave >= 5:
		if file == "res://cats/floatyshadowykitty.tscn":
			enemy.dumber = true
	
func spawnflagcat(pos, wave):
	var enemy = load("res://cats/theflagcat.tscn").instantiate()
	enemy.position = pos
	print(enemy.flagtext)
	enemy.flagtext = str(int(wave))
	add_child(enemy)
