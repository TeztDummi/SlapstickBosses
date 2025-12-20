extends Node3D

@onready var main = get_node("/root").get_node("main")
#@onready var player = main.get_node("player")
@onready var map = main.get_node("map")

var up = true
var exploded = false
@onready var realy = position.y
var heightlimit = 40

func _ready() -> void:
	rotation.x = PI
	var dupe = $ball.get_surface_override_material(0).duplicate()
	$ball.set_surface_override_material(0, dupe)
	
	if map != null:
		heightlimit = map.levelgroup().position.y+40

func _on_textureupdate_timeout() -> void:
	$ball.get_surface_override_material(0).uv1_offset.y += -0.03

func turn():
	up = false
	$Decal.show()
	rotation.x = 0

func _process(delta: float) -> void:
	if position.y > heightlimit && up:
		turn()
		
		var choices = []
		for child in map.levelgroup().get_children():
			if child.health > 0:
				choices.append(child.global_position)
		if choices.size() > 0:
			var ranpos = choices.pick_random()
			position.x = ranpos.x
			position.z = ranpos.z
		else:
			position.x = floor(randf_range(-16, 16)/2)*2+1
			position.z = floor(randf_range(-16, 16)/2)*2+1
		
	if up:
		realy += delta*64
	else:
		realy -= delta*4
	position.y = round(realy*2)/2
		
	if !exploded:
		if $raycast.is_colliding():
			hurt()
			
	if position.y < -40:
		queue_free()
			
func hurt():
	if !exploded:
		exploded = true
		$explodeparticles.emitting = true
		$particles.emitting = false
		$ball.hide()
		$Decal.hide()
		$static/col.disabled = true
		$colsphere.queue_free()
		$audio.stream = load("res://audio/spleef/firebreak.mp3")
		$audio.play()
		for body in $area.get_overlapping_bodies():
			if body.is_in_group("spleefblock"):
				if !body.get_parent().ice:
					body.get_parent().hurt()
			if body.is_in_group("playergroup"):
				body.hurt(20, "bluelaser")
		
