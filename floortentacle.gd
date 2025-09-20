extends Node3D

@onready var main = get_node("/root").get_node("main")

func _ready() -> void:
	if $"../../".chal == "horrorgun":
		$mesh/seethru.hide()

func start():
	$anim.play("default")
	$audio.play()

func _on_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("playergroup"):
		body.hurt(10, "ragdoll")
		body.velocity = Vector3.ZERO

func _on_hurttimer_timeout() -> void:
	for body in $mesh/area.get_overlapping_bodies():
		if body.is_in_group("playergroup"):
			body.hurt(1, "ragdoll")
