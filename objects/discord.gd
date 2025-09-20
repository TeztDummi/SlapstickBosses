extends Node3D

func _ready() -> void:
	$discord/Cube.rotate_y(randf_range(0, 2*PI))
	$cosmeticver/Cube.rotate_y(randf_range(0, 2*PI))
	
	if $"../../".name == "cospeview":
		$discord.hide()
		$cosmeticver.show()

func _process(delta: float) -> void:
	$discord/Cube.rotate_y(delta*0.2)
	$cosmeticver/Cube.rotate_y(delta*0.2)
