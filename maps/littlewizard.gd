extends StaticBody3D
var delay = 0
var time = 1
@onready var player = $"../../player"
var savedatadelay = 0.2
	
func talk():
	if delay <= 0:
		var hasjar = false
		for child in $"../../player/camera/gun".get_children():
			if child.has_meta("held"):
				if child.item == "jar":
					hasjar = true
		if !hasjar:
			if time == 1:
				$"../../canvas/hud/talk".start("lilwizardstart")
				var gun = load("res://dagger.tscn").instantiate()
				$"../../player/camera/gun".add_child(gun)
				$"../../player".scroll = 1
			if time >= 2: $"../../canvas/hud/talk".start("lilwizard2nd")
			time += 1
			$"../../".lilwizardtime = time
			delay = 1
		
func _process(delta):
	if savedatadelay > 0: savedatadelay -= delta
	elif savedatadelay != -10:
		time = $"../../".lilwizardtime
		if time == -1:
			queue_free()
		savedatadelay = -10
	if delay > 0: delay -= delta
