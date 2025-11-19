extends Camera3D

@export var MOVEMENT_SPEED: float = 5.0
@export var MOVEMENT_SPEED_FAST: float = 20.0
var movement_enabled: bool = false

@export var mouse_sensitivy: float = 0.15
var _mouse_motion: Vector2

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_mouse_motion = event.screen_relative

func _physics_process(delta: float) -> void:
	if not movement_enabled:
		return
	var input := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	
	var camera_speed := MOVEMENT_SPEED_FAST if Input.is_action_pressed("fast_camera") else MOVEMENT_SPEED

	global_rotation.y -= _mouse_motion.x * delta * mouse_sensitivy
	global_rotation.x -= _mouse_motion.y * delta * mouse_sensitivy
	global_rotation.x = clampf(global_rotation.x, - PI * 9 / 10, PI / 4)
	_mouse_motion = Vector2.ZERO
	
	var movement_direction := global_basis.x.normalized() * input.x + global_basis.z.normalized() * input.y
	global_position += movement_direction * camera_speed * delta
