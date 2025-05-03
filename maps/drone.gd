extends MeshInstance3D
@onready var player = $"../../player"
var starttimer = 0
var dead = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !dead:
		starttimer += delta
		$propeller.rotation.y += delta*5
		$propeller2.rotation.y += delta*5
		$propeller3.rotation.y += delta*5
		$propeller4.rotation.y += delta*5
		var off = get_meta("offset")
		if get_meta("follow") == "player":
			position.x = lerp(position.x, player.position.x+off.x, 0.5*delta)
			position.y = lerp(position.y, player.position.y+off.y, 0.5*delta)
			position.z = lerp(position.z, player.position.z+off.z, 0.5*delta)
			look_at(player.position)
			rotation.x = 0
			$viewport/Camera3D.position = $campoint.global_position
			$viewport/Camera3D.look_at(player.position)
		if get_meta("follow") == "gunman":
			if starttimer >= 1.5:
				position.x = lerp(position.x, $"../boss".position.x+off.x, 0.5*delta)
				position.y = lerp(position.y, $"../boss".position.y+off.y, 0.5*delta)
				position.z = lerp(position.z, $"../boss".position.z+off.z, 0.5*delta)
				look_at($"../boss".position)
				rotation.x = 0
				$viewport/Camera3D.position = $campoint.global_position
				$viewport/Camera3D.look_at($"../boss".position)
				
func boom():
	position.y -= 40
	$"boom".position.y += 40/scale.x
	$"boom2".position.y += 40/scale.x
	$"boom".emitting = true
	$"boom2".emitting = true
	dead = true
	$viewport/Camera3D.position = Vector3(0, -5, 0)
	$viewport/Camera3D.rotation = Vector3.ZERO
