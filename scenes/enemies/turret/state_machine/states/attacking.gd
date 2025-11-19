class_name Attacking
extends TurretState

func enter() -> void:
	agent.shoot()

func exit() -> void:
	pass

func on_tick(delta: float) -> void:
	change_state("Tracking")

func on_physics_tick(delta: float) -> void:
	pass

func handle_event(event: Turret.Event) -> void:
	match event:
		Turret.Event.Destroyed:
			change_state("Destroyed")
