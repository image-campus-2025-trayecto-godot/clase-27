@abstract
class_name TurretState
extends Node

var agent: Turret

signal change_state_requested(new_state_name)

@abstract func enter() -> void

@abstract func on_tick(delta: float) -> void

@abstract func on_physics_tick(delta: float) -> void

@abstract func exit() -> void

@abstract func handle_event(event: Turret.Event) -> void

func change_state(new_state_name: String):
	change_state_requested.emit(new_state_name)
