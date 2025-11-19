extends ZombieState

func enter(data) -> void:
	pass
	
func on_tick(delta: float) -> void:
	agent.animation_player.play("idle")


func on_physics_tick(delta: float) -> void:
	pass

func exit() -> void:
	pass

func handle_event(event: Zombie.Event, data) -> void:
	match event:
		Zombie.Event.TargetPositionChanged:
			change_state("WalkingTowards", data)
