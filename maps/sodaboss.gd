extends Node3D

var allrooms = 9
var testroom = "0"
var diff = -1
@onready var player = $"../player"
var loaded = []
var loadingrooms = []
var end

# Called when the node enters the scene tree for the first time.
func _ready():
	player.cancrouch = true
	player.falloff = false
	
	var gun = load("res://bitchslapper.tscn").instantiate()
	$"../player/camera/gun".add_child(gun)
	$"../player".scroll = 1
	
	$"../music".stream = load("res://audio/music/lobbymusic.mp3")
	$"../music".play()
	
func _on_startdelay_timeout() -> void:
	for i in range(5):
		addroom()
		
func addroom():
	var roompath
	if testroom != "0":
		roompath = "res://sodaboss/room"+testroom+".tscn"
	else:
		roompath = "res://sodaboss/room"+str(randi_range(1, allrooms))+".tscn"
		
	ResourceLoader.load_threaded_request(roompath)
	
	loadingrooms.append(roompath)
			
func finishloading(roompath):
	
	var room = ResourceLoader.load_threaded_get(roompath).instantiate()
	loaded.append(room)
	
	if end != null:
		room.position = end.global_position
		room.rotation = end.global_rotation
	if (room.get_node("end") != null):
		end = room.get_node("end")
	else: print("ZAWG u forgot to mark the end")
	add_child(room)
	print(room.position)
	
	if loaded.size()+loadingrooms.size() > 6:
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
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var size = loaded.size()+loadingrooms.size()
	if size <= 5 && loaded.size() > 3:
		var midroom = loaded[3]
		var disttoend = sqrt(pow(player.position.x-midroom.position.x, 2)+pow(player.position.y-midroom.position.y, 2)+pow(player.position.z-midroom.position.z, 2))
		
		if disttoend <= 8:
			addroom()
			print("load a new room")


func _on_timer_timeout() -> void:
	for i in range(loadingrooms.size()):
		if loadingrooms.size() > i:
			var roompath = loadingrooms[i]
			var progress = []
			ResourceLoader.load_threaded_get_status(roompath, progress)
			if progress[0] == 1:
				finishloading(loadingrooms[i])
				loadingrooms.remove_at(i)
