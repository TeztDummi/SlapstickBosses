extends MeshInstance3D

func _on_notif_screen_exited():
	hide()
	$static/collider.disabled = true
