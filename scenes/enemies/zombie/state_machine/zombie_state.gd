@abstract
class_name ZombieState
extends Node

var agent: Zombie

signal change_state_requested(new_state_name, data)

@abstract func enter(data) -> void

@abstract func on_tick(delta: float) -> void

@abstract func on_physics_tick(delta: float) -> void

@abstract func exit() -> void

@abstract func handle_event(event: Zombie.Event, data) -> void

func change_state(new_state_name: String, data = {}):
	change_state_requested.emit(new_state_name, data)
