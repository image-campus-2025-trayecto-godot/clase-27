extends Node3D

@export var player: CharacterBody3D
@export var free_camera: Camera3D
@export var player_camera: Camera3D

func _physics_process(delta: float) -> void:
	for zombie in %Zombies.get_children():
		zombie.move_to_target_position(player.global_position)

var is_free_camera: bool = false :
	set(new_value):
		is_free_camera = new_value
		if player_camera:
			#free_camera.global_transform = player_camera.global_transform
			free_camera.current = is_free_camera
			_update_player_movement_enabled()
			_update_camera_enabled()

func _update_player_movement_enabled():
	if player:
		player.movement_enabled = !is_free_camera and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_free_camera"):
		is_free_camera = !is_free_camera
	if event.is_action_pressed("pause"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		_update_player_movement_enabled()
		_update_camera_enabled()

	if event is InputEventMouseButton and is_free_camera:
		if event.button_index == MOUSE_BUTTON_LEFT:
			#var camera_raycast: RayCast3D = free_camera.get_node("RayCast3D")
			#var collision_point = camera_raycast.get_collision_point()

			var RAY_LENGTH = 500
			var mouse_position = event.position
			var ray_origin = free_camera.project_ray_origin(mouse_position)
			var ray_normal = free_camera.project_ray_normal(mouse_position)
			var ray_end = ray_origin + ray_normal * RAY_LENGTH

			var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
			query.collide_with_areas = true # Set to true if you want to hit Area3D nodes

			var space_state = get_world_3d().direct_space_state
			var result = space_state.intersect_ray(query)

			if result:
				for zombie in %Zombies.get_children():
					zombie.move_to_target_position(result.position)

func _update_camera_enabled():
	free_camera.movement_enabled = is_free_camera and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
