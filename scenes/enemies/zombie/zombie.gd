extends CharacterBody3D

@export var walk_speed: float = 3.5
@export var target_position: Vector3 :
	set(new_value):
		target_position = new_value
		if not is_node_ready():
			await ready
		target_position_debug.global_position = target_position
@export var debug_path: bool = false :
	set(new_value):
		debug_path = new_value
		if not is_node_ready():
			await ready
		target_position_debug.visible = debug_path

@onready var animation_player: AnimationPlayer = $"character-orc2/AnimationPlayer"
@onready var target_position_debug: CSGSphere3D = $TargetPositionDebug


func _ready() -> void:
	target_position = global_position


func set_velocity_to_move_towards(point: Vector3, delta: float) -> void:
	var direction := (global_position.direction_to(point) * Vector3(1, 0, 1)).normalized()
	var target_velocity = direction * walk_speed
	velocity.x = target_velocity.x
	velocity.z = target_velocity.z
	if global_position.distance_to(point) < 0.3:
		velocity = Vector3.ZERO

func _physics_process(delta: float) -> void:
	if not target_position.is_equal_approx(global_position):
		set_velocity_to_move_towards(target_position, delta)
		if not is_on_floor():
			velocity += get_gravity() * delta
		look_at(target_position * Vector3(1, 0, 1) + Vector3(0, global_position.y, 0))
	else:
		velocity = Vector3.ZERO
	
	move_and_slide()

	if velocity.is_zero_approx():
		animation_player.play("idle")
	else:
		animation_player.play("sprint")
