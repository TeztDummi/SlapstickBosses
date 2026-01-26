extends StaticBody3D
var delay = 0
var time = 1
@onready var player = $"../../player"
var savedatadelay = 0.2

func talk():
	if delay <= 0:
		#$"../../canvas/hud/talk".start("lookupguy/christmas")
		if time == 1: $"../../canvas/hud/talk".start("lookupguystart")
		if time >= 2: $"../../canvas/hud/talk".start("lookupguy"+str(randi_range(0, 3)))
		time += 1
		delay = 1
	
func _process(delta):
	if savedatadelay > 0: savedatadelay -= delta
	elif savedatadelay != -10:
		savedatadelay = -10
	if delay > 0: delay -= delta
