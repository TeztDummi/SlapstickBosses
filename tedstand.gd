extends Node3D

func clearheads():
	for i in $"../../".unlockedheads:
		for child in get_children():
			if i == child.name:
				child.queue_free()
