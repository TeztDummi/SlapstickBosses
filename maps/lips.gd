extends StaticBody3D
var delay = 0
var time = 1
@onready var player = $"../../player"
var savedatadelay = 0.2
	
func talk():
	if delay <= 0:
		if time == 1: $"../../canvas/hud/talk".start("lips/start")
		if time >= 2: $"../../canvas/hud/talk".start("lips/"+str(randi_range(1, 4)))
		time += 1
		$"../../".lipstime = time
		delay = 1
		
func _process(delta):
	if savedatadelay > 0: savedatadelay -= delta
	elif savedatadelay != -10:
		time = $"../../".lipstime
		savedatadelay = -10
	if delay > 0: delay -= delta
