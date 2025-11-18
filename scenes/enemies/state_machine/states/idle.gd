class_name Idle
extends TurretState

var time_left_to_patrol: float = 0.0
var time_left_to_stay_idle: float = 0.0

func enter() -> void:
	time_left_to_stay_idle = randf_range(2.0, 4.0)
	agent.switch_to_idle_mode_animation()

func on_tick(delta: float) -> void:
	pass

func on_physics_tick(delta: float) -> void:
	if time_left_to_patrol > 0.0:

		agent.look_around(delta)

		time_left_to_patrol = move_toward(time_left_to_patrol, 0.0, delta)
		if time_left_to_patrol <= 0.0:
			time_left_to_stay_idle = randf_range(2.0, 4.0)

	elif time_left_to_stay_idle > 0.0:
		time_left_to_stay_idle = move_toward(time_left_to_stay_idle, 0.0, delta)
		if time_left_to_stay_idle <= 0.0:
			time_left_to_patrol = randf_range(5.0, 10.0)

func exit() -> void:
	pass

func handle_event(event: Turret.Event) -> void:
	match event:
		Turret.Event.Destroyed:
			change_state("Destroyed")
		Turret.Event.PlayerDetected:
			change_state("Tracking")
