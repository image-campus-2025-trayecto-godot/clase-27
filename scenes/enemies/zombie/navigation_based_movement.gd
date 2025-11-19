extends Node3D

@onready var navigation_agent_3d: NavigationAgent3D = $"../NavigationAgent3D"

func velocity_to_move_towards(agent: Node3D, point: Vector3, speed: float, delta: float) -> Vector3:
	navigation_agent_3d.target_position = point
	if navigation_agent_3d.is_navigation_finished():
		return Vector3.ZERO

	var next_path_pos = navigation_agent_3d.get_next_path_position()
	var direction = agent.global_position.direction_to(next_path_pos)
	
	var target_velocity = direction * speed
	
	return target_velocity

func has_reached_target(agent: Node3D, point: Vector3) -> bool:
	navigation_agent_3d.target_position = point
	return navigation_agent_3d.is_navigation_finished()
