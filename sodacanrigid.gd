extends RigidBody3D

@onready var main = get_node("/root").get_node("main")
@onready var player = main.get_node("player")
@onready var map = main.get_node("map")

var delay = 0.2

var healthcan = false

var extra = false

# Called when the node enters the scene tree for the first time.
func _ready():
	if healthcan:
		var dupe = $can.get_surface_override_material(0).duplicate()
		$can.set_surface_override_material(0, dupe)
		dupe.albedo_texture = load("res://healthcantexture.png")
		healthcan = true
	if extra:
		$CollisionShape3D.scale *= 3
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if delay > 0: delay -= delta
	
func _physics_process(delta: float) -> void:
	if get_contact_count() >= 1:
		for body in get_colliding_bodies():
			if !body.is_in_group("nocanexplode"):
				explode()
		
func explode():
	if $can.visible:
		for body in $explosion.get_overlapping_bodies():
			if body.is_in_group("playergroup"):
				if !healthcan:
					if map.diff == 0:
						body.hurt(5, "ragdoll")
					else:
						body.hurt(10, "ragdoll")
				else:
					body.heal(20)
			if body.is_in_group("sodabox"):
				if !body.is_in_group("nocanexplode"):
					if !healthcan:
						body.hurt(20)
					else:
						body.hurt(-20)
			if body.is_in_group("popcop"):
				if !healthcan:
					body.die()
		$anim.play("burst")
		if !healthcan:
			$particleshealth.hide()
			$"2particlehealth".hide()
		else:
			$particles.hide()
			$"2particle".hide()
		$can.hide()
		$audio.stream = load("res://audio/cancrush.mp3")
		if extra:
			for body in get_colliding_bodies():
				if body.is_in_group("canrigid"):
					$audio.stream = load("res://audio/canblock.mp3")
		$audio.play()
		freeze = true
		$CollisionShape3D.disabled = true
