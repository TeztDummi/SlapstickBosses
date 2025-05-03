extends MeshInstance3D
var squished = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_area_3d_body_entered(body):
	if !squished:
		if body.is_in_group("playergroup"):
			if !body.dead:
				squish()
				
func squish():
	squished = true
	hide()
	$audio.play()
	if name == "plant":
		$"../squishedplant".show()
	if name == "plant1":
		$"../squishedplant1".show()
	
	if $"../squishedplant".visible && $"../squishedplant1".visible:
		$"../../../".setAchievement("letitdie")
