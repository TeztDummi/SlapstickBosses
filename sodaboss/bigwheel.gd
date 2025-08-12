extends MeshInstance3D

var hover = false
var spun = 0.2

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if spun > 0: spun -= delta
	if spun <= 0:
		$wheel/outline.visible = hover
		hover = false
	else:
		$wheel/outline.visible = false
	
func spin():
	if spun <= 0:
		spun = 0.2
		$anim.play("default")
		$audio.stream = load("res://audio/valveturn.mp3")
		$audio.play()
		print(get_meta("pipes"))
		for pipe in get_meta("pipes"):
			get_node(pipe).reverse()
