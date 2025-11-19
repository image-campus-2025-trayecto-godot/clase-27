class_name Tracking
extends TurretState

func enter(data) -> void:
	agent.switch_to_aggresive_mode_animation()

func on_tick(delta: float) -> void:
	agent.look_at_target(delta)

func on_physics_tick(delta: float) -> void:
	if not agent.targeted_node:
		change_state("Idle")

func exit() -> void:
	pass

func handle_event(event: Turret.Event, data) -> void:
	match event:
		Turret.Event.Destroyed:
			change_state("Destroyed")
		Turret.Event.PlayerOutOfSight:
			change_state("Idle")
		Turret.Event.PlayerLockedOn:
			change_state("ChargingAttack")
