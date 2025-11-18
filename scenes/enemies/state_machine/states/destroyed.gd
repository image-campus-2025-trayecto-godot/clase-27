extends TurretState

func enter() -> void:
	agent.play_destroyed_animation()

func exit() -> void:
	pass
	
func on_tick(delta: float) -> void:
	pass

func on_physics_tick(delta: float) -> void:
	pass

func handle_event(event: Turret.Event) -> void:
	pass
