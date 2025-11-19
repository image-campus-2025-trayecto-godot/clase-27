extends ZombieState

var target_position: Vector3

func enter(data) -> void:
	target_position = data.target_position

func on_tick(delta: float) -> void:
	agent.animation_player.play("sprint")

func on_physics_tick(delta: float) -> void:
	if agent.has_reached_target(target_position):
		change_state("Idle")
		return
	agent.set_velocity_to_move_towards(target_position, delta)
	var look_at_position = agent.global_position + agent.velocity * Vector3(1, 0, 1) * delta
	if not look_at_position.is_equal_approx(agent.global_position):
		agent.look_at(look_at_position)

func exit() -> void:
	agent.velocity = Vector3.ZERO

func handle_event(event: Zombie.Event, data) -> void:
	match event:
		Zombie.Event.TargetPositionChanged:
			change_state("WalkingTowards", data)
