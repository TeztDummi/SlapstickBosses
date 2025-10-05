extends StaticBody3D
var delay = 0
var time = 1
@onready var player = $"../../player"
var savedatadelay = 0.2
	
func talk():
	if delay <= 0:
		if time == 1: $"../../canvas/hud/talk".start("levelguy/start", self)
		if time >= 2: $"../../canvas/hud/talk".start("levelguy/"+str(randi_range(1, 19)), self)
		time += 1
		$"../../".levelguytime = time
		delay = 1
		
func _process(delta):
	if savedatadelay > 0: savedatadelay -= delta
	elif savedatadelay != -10:
		time = $"../../".levelguytime
		savedatadelay = -10
	if delay > 0: delay -= delta
