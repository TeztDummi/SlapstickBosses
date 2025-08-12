extends Node3D



func _on_playerdetect_body_entered(body: Node3D) -> void:
	if $anim.current_animation != "launch":
		if body.is_in_group("playergroup"):
			$anim.play("step")

func _on_playerdetect_body_exited(body: Node3D) -> void:
	if $anim.current_animation != "launch":
		if body.is_in_group("playergroup"):
			if $anim.current_animation == "step" || $anim.current_animation == "stepidle":
				$anim.play("stepoff")
				for body2 in $launch.get_overlapping_bodies():
					if body2.is_in_group("playergroup"):
						body2.velocity.y += 8
			
func launch():
	if $anim.current_animation != "launch":
		$anim.play("launch")
		$plat/plataudio.play()
	
func dolaunchfr():
	for body in $launch.get_overlapping_bodies():
		if body.is_in_group("playergroup"):
			#body.position.y += 5
			#body.velocity.y = 0
			pass
	
func _on_anim_animation_finished(anim_name: StringName) -> void:
	if anim_name == "launch":
		$anim.play("idle")
	if anim_name == "step":
		$anim.play("stepidle")
	if anim_name == "stepoff":
		$anim.play("idle")

func _on_hurtplayercheck_timeout() -> void:
	for body in $hurtplayer.get_overlapping_bodies():
		if body.is_in_group("playergroup"):
			if body.health > 0:
				body.hurt(2, "ragdoll")
				if body.health <= 0:
					$"../../../".setAchievement("oshasnotgonnalikethat")
