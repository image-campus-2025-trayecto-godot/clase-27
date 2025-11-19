class_name ChargingAttack
extends TurretState

var time_until_attack: float = 0.0

func enter() -> void:
	time_until_attack = agent.attack_telegraph_time
	agent.play_charging_attack_animation()

func on_tick(delta: float) -> void:
	time_until_attack = move_toward(time_until_attack, 0.0, delta)
	if time_until_attack <= 0:
		change_state("Attacking")

func on_physics_tick(delta: float) -> void:
	pass

func exit() -> void:
	pass

func handle_event(event: Turret.Event) -> void:
	match event:
		Turret.Event.Destroyed:
			change_state("Destroyed")
