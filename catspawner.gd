extends Node3D
var wave = 0
@onready var startingchildren = get_child_count()
var multiplier = 1
@onready var player = $"../../player"
var amountofwaves
var spawnedportal = false
var chal = "none"
var maxenemys = 5
var enemyqueue = []

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
	$"../../canvas/hud/catcount/current".text = str(get_child_count()-startingchildren)
	$"../../canvas/hud/catcount/upcoming".text = str(enemyqueue.size())
	
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
		if wave <= amountofwaves:
			player.health = 100
			spawnflagcat(getrandompos(), wave)
			if chal == "none":
				if wave == 1:
					maxenemys = 100
					for i in range(ceil(4*multiplier)):
						#spawnenemy(getrandompos(), "res://cats/oneofthem.tscn")
						enemyqueue.append("res://cats/oneofthem.tscn")
					for i in range(ceil(1*multiplier)):
						enemyqueue.append("res://cats/lilwhisker.tscn")
				if wave == 2:
					maxenemys = 100
					for i in range(ceil(8*multiplier)):
						enemyqueue.append("res://cats/oneofthem.tscn")
					for i in range(ceil(2*multiplier)):
						enemyqueue.append("res://cats/lilwhisker.tscn")
					for i in range(ceil(1*multiplier)):
						enemyqueue.append("res://cats/floatyshadowykitty.tscn")
				if wave == 3:
					maxenemys = (ceil(4*multiplier)+ceil(2*multiplier))/2
					for i in range(ceil(4*multiplier)):
						enemyqueue.append("res://cats/lilwhisker.tscn")
					for i in range(ceil(2*multiplier)):
						enemyqueue.append("res://cats/floatyshadowykitty.tscn")
				if wave == 4:
					maxenemys = 100
					for i in range(ceil(2*multiplier)):
						enemyqueue.append("res://cats/lilwhisker.tscn")
					for i in range(ceil(1*multiplier)):
						enemyqueue.append("res://cats/roobeer.tscn")
				if wave == 5:
					maxenemys = (ceil(2*multiplier)+ceil(2*multiplier))*0.6
					for i in range(ceil(2*multiplier)):
						enemyqueue.append("res://cats/floatyshadowykitty.tscn")
					for i in range(ceil(2*multiplier)):
						enemyqueue.append("res://cats/roobeer.tscn")
				if wave == 6:
					if $"../../music".stream.resource_path.get_file() != "spicycatboss.mp3":
						$"../../".transitionmusic("res://audio/music/spicycatboss.mp3", 1, true, 22.58, -2.82)
					maxenemys = (ceil(8*multiplier)+ceil(4*multiplier)+ceil(2*multiplier)+ceil(2*multiplier))*0.75
					for i in range(ceil(8*multiplier)):
						enemyqueue.append("res://cats/oneofthem.tscn")
					for i in range(ceil(4*multiplier)):
						enemyqueue.append("res://cats/lilwhisker.tscn")
					for i in range(ceil(2*multiplier)):
						enemyqueue.append("res://cats/floatyshadowykitty.tscn")
					for i in range(ceil(2*multiplier)):
						enemyqueue.append("res://cats/roobeer.tscn")
			elif chal == "6pack":
				if wave == 1:
					maxenemys = 4
					for i in range(ceil(6)):
						enemyqueue.append("res://cats/roobeer.tscn")
			elif chal == "catrpg":
				if wave == 1:
					maxenemys = 100
					for i in range(ceil(64)):
						enemyqueue.append("res://cats/oneofthem.tscn")
					for i in range(ceil(8)):
						enemyqueue.append("res://cats/floatyshadowykitty.tscn")
				if wave == 2:
					maxenemys = 100
					for i in range(ceil(12)):
						enemyqueue.append("res://cats/lilwhisker.tscn")
					for i in range(ceil(6)):
						enemyqueue.append("res://cats/floatyshadowykitty.tscn")
				if wave == 3:
					maxenemys = (18+12+8+1)*0.75
					for i in range(ceil(18)):
						enemyqueue.append("res://cats/oneofthem.tscn")
					for i in range(ceil(12)):
						enemyqueue.append("res://cats/lilwhisker.tscn")
					for i in range(ceil(8)):
						enemyqueue.append("res://cats/floatyshadowykitty.tscn")
					for i in range(ceil(1)):
						enemyqueue.append("res://cats/roobeer.tscn")
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
	elif get_child_count()-startingchildren < maxenemys && !spawnedportal:
		var enemystospawn = maxenemys-(get_child_count()-startingchildren)
		for i in range(enemystospawn):
			if enemyqueue.size() > 0:
				spawnenemy(getrandompos(), enemyqueue[0])
				enemyqueue.pop_front()
			
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
