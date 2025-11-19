extends Button

func _toggled(toggled_on: bool) -> void:
	if toggled_on:
		$"../../Door/Door/CSGBox3D2/AnimationPlayer".play("open_door")
	else:
		$"../../Door/Door/CSGBox3D2/AnimationPlayer".play_backwards("open_door")
