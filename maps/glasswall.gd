extends MeshInstance3D
var health = 200

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func rise():
	$anim.play("comeup")
	health = 200
	$wall/shatter.hide()
	
func hit(amount):
	health -= amount
	if health > 0:
		$anim.play("damage")
		$audio.stream = load("res://audio/gunman/glassshoot"+str(randi_range(0,1))+".mp3")
		$audio.play()
		if health <= 100:
			$wall/shatter.show()
	if health <= 0:
		shatter()
	
func shatter():
	health = 0
	$anim.play("break")
	$audio.stream = load("res://audio/gunman/glassbreak.mp3")
	$audio.play()
	$Timer.start()

func _on_timer_timeout():
	rise()
