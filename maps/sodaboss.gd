extends Node3D

@onready var main = get_node("/root").get_node("main")
@onready var player = main.get_node("player")
@onready var map = main.get_node("map")

var allrooms = 14
var testroom = "0"
var diff = -1
var chal = "none"
var loaded = []
var loadingrooms = []
@onready var end = $end
var over = false
var dotutorial = true
var roomsloaded = 0
var roomstillboss = 25 #25
var chalroom = 0
var noenemyroomstotal = 4
var enemyroomstotal = 10
var noenemyrooms = enemyroomstotal
var startrooms = 0

#github test edit again lol mwah

# Called when the node enters the scene tree for the first time.
func _ready():
	
	player.cancrouch = true
	player.falloff = false
	
	$"../music".stream = load("res://audio/music/factoryescapecalm.mp3")
	$"../music".play()
	
	preload("res://audio/music/factoryescape.mp3")
	preload("res://audio/music/factoryescapespicy.mp3")
	preload("res://bitchslapper.tscn")
	
	if diff == 2:
		roomstillboss = 30
		noenemyroomstotal = 0
		
	if chal == "justbox":
		addroom()
		$poobottle.queue_free()
		$pedestal.queue_free()
		var gun = load("res://sodahammer.tscn").instantiate()
		$"../player/camera/gun".add_child(gun)
		$"../player".scroll = 1
		
	if chal != "sodaspeedrun":
		$speedrunsign.queue_free()
	
func _on_startdelay_timeout() -> void:
	pass
	
func changemusic(from, to):
	if $"../music".stream.resource_path.get_file() == from+".mp3":
		$"../".transitionmusic("res://audio/music/"+to+".mp3", 1, true, 12, 0)
	
func start():	
	$audio.stream = load("res://audio/wallexplode.mp3")
	$audio.play()
	
	$anim.play("start")
	$lightanim.play("default")
	
	$"../sfx".stream = load("res://audio/grab.mp3")
	$"../sfx".play()
	
	changemusic("factoryescapecalm", "factoryescapepolice")
	
	var gun = load("res://mentos.tscn").instantiate()
	$"../player/camera/gun".add_child(gun)
	$"../player".scroll = 1
	
func startmixing():
	$audio.stream = load("res://audio/mixingmachineexplode.mp3")
	$audio.play()
	
	$mixinganim.play("start")
	
	if chal == "sodaspeedrun":
		addroom("roomtutorial")
	elif testroom == "0" && diff != 2:
		addroom("roomtutorial")
		startrooms = 4
	elif chal != "justbox":
		addroom()
		startrooms = 4
	
	#print("whaat")
	
	#for i in range(4):
		#addroom()
	
func mixingburst():
	for body in $mixingburst.get_overlapping_bodies():
		if body.is_in_group("playergroup"):
			body.hurt(1000, "ragdoll")
	player.screenshake += 0.5
			
func givebitchslapper():
	var gun = load("res://bitchslapper.tscn").instantiate()
	$"../player/camera/gun".add_child(gun)
	$"../player".scroll = 1
	player.screenshake += 0.5
	player.impactframe()
	
	changemusic("factoryescapepolice", "factoryescape")
		
func addroom(custom = "none"):
	if !over:
		var roompath
		if custom != "none":
			roompath = "res://sodaboss/"+custom+".tscn"
			if custom == "roomsimpleend":
				over = true
		elif (chal == "none" && roomsloaded >= roomstillboss) || chal == "justbox":
			roompath = "res://sodaboss/sodaboxarena.tscn"
			over = true
		elif testroom != "0":
			roompath = "res://sodaboss/room"+testroom+".tscn"
		else:
			roompath = "res://sodaboss/room"+str(randi_range(1, allrooms))+".tscn"
				
		ResourceLoader.load_threaded_request(roompath)
		
		loadingrooms.append(roompath)
		
		roomsloaded += 1
			
func finishloading(roompath):
	
	var room = ResourceLoader.load_threaded_get(roompath).instantiate()
	loaded.append(room)
	
	if end != null:
		room.position = end.global_position
		room.rotation = end.global_rotation
	if (room.get_node("end") != null):
		end = room.get_node("end")
	else:
		print("ZAWG u forgot to mark the end")
	if noenemyrooms <= 0:
		room.add_to_group("noenemys")
		
	add_child(room)
	print(room.position)
	
	for child in room.get_children():
		if chal == "sodaspeedrun" || noenemyrooms <= 0:
			if chal == "sodaspeedrun":
				if !$"../canvas/hud/timer".visible:
					$"../".timer = 50
					$"../canvas/hud/timer".show()
			if child.is_in_group("popcop") || child.is_in_group("sodacan") || child.has_meta("nospeedrun"):
				child.queue_free()
		if diff != 2:
			if child.has_meta("hard"):
				child.queue_free()
		else:
			if child.has_meta("nohard"):
				child.queue_free()
	
	noenemyrooms -= 1
	if noenemyrooms <= noenemyroomstotal*-1:
		noenemyrooms = enemyroomstotal
		
	if loaded.size()+loadingrooms.size() > 6:
		if chal != "sodaspeedrun":
			if loaded[0] != null:
				loaded[0].queue_free()
			loaded.remove_at(0)
	
	var filler = load("res://sodaboss/room"+"filler"+".tscn").instantiate()
	if end != null:
		filler.position = end.global_position
		filler.rotation = end.global_rotation
	if (filler.get_node("end") != null):
		end = filler.get_node("end")
	else: print("ZAWG u forgot to mark the end")
	add_child(filler)
	
	if chal == "sodaspeedrun":
		chalroom += 1
		if chalroom <= allrooms:
			addroom("room"+str(chalroom))
		else:
			addroom("roomsimpleend")
	
	if startrooms > 0:
		startrooms -= 1;
		addroom()
	
	if $fakehall != null:
		$fakehall.queue_free()
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if chal != "sodaspeedrun":
		var size = loaded.size()+loadingrooms.size()
		if size <= 5 && loaded.size() > 3:
			if loaded[3] != null:
				var midroom = loaded[3]
				var disttoend = sqrt(pow(player.position.x-midroom.position.x, 2)+pow(player.position.y-midroom.position.y, 2)+pow(player.position.z-midroom.position.z, 2))
				if disttoend <= 16:
					addroom()
					print("load a new room")
	else:
		if $"../".timer <= 10 && $"../canvas/hud/timer".visible:
			changemusic("factoryescapespicy", "factoryescapespicy")
				
	if $"../".timer < 0 && $"../canvas/hud/timer".visible:
		player.hurt(100, "ragdoll")
		$"../canvas/hud/timer".hide()
	

func _on_timer_timeout() -> void:
	for i in range(loadingrooms.size()):
		if loadingrooms.size() > i:
			var roompath = loadingrooms[i]
			var progress = []
			ResourceLoader.load_threaded_get_status(roompath, progress)
			if progress[0] == 1:
				finishloading(loadingrooms[i])
				loadingrooms.remove_at(i)

func _on_anim_animation_finished(anim_name: StringName) -> void:
	if anim_name == "start":
		$anim.play("Animation")
		player.screenshake += 1
		player.impactframe()
