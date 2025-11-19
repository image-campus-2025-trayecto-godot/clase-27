extends Node3D

func velocity_to_move_towards(agent: Node3D, point: Vector3, speed: float) -> Vector3:
	var direction := (global_position.direction_to(point) * Vector3(1, 0, 1)).normalized()

	return direction * speed

func has_reached_target(agent: Node3D, point: Vector3) -> bool:
	return agent.global_position.distance_to(point) < agent.distance_to_target
