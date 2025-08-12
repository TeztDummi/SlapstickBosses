extends StaticBody3D
var delay = 0
var time = 1
@onready var player = $"../../player"
var savedatadelay = 0.2

func talk():
	if delay <= 0:
		if time == 1: $"../../canvas/hud/talk".start("crustystart", self)
		if time == 2: $"../../canvas/hud/talk".start("crusty2nd", self)
		if time >= 3: $"../../canvas/hud/talk".start("crusty/"+str(randi_range(1, 18)), self)
		time += 1
		$"../../".crustytime = time
		delay = 1
	
func _process(delta):
	if savedatadelay > 0: savedatadelay -= delta
	elif savedatadelay != -10:
		time = $"../../".crustytime
		savedatadelay = -10
	if delay > 0: delay -= delta

func removetime():
	$"../../".crustytime -= 1
	time = $"../../".crustytime
