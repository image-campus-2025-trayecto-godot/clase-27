@tool
extends Path3D

@onready var path_follows := [$PathFollow3D, $PathFollow3D2, $PathFollow3D3, $PathFollow3D4, $PathFollow3D5]
@onready var weapons := [$"../Weapon2", $"../Weapon5", $"../Weapon1", $"../Weapon4", $"../Weapon3"]

@export var speed: float = 1.0
@export var active: bool :
	set(new_value):
		active = new_value
		if not is_node_ready():
			await ready
		if active:
			var path_follows_amount = path_follows.size()
			var progress_ratio_offset: float = 0.0
			for path_follow in path_follows:
				path_follow.progress_ratio = progress_ratio_offset
				progress_ratio_offset += 1.0 / path_follows_amount

func _physics_process(delta: float) -> void:
	if not active:
		return
	for i in range(0, weapons.size()):
		path_follows[i].progress_ratio += delta * speed
		weapons[i].global_position = weapons[i].global_position.lerp(path_follows[i].global_position, 1 - pow(0.01, delta))
