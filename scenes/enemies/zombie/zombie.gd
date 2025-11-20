class_name Zombie
extends CharacterBody3D

enum Event {
	TargetPositionChanged
}

@export var walk_speed: float = 3.5
@export var debug_path: bool = false :
	set(new_value):
		debug_path = new_value
		if not is_node_ready():
			await ready
		target_position_debug.visible = debug_path
@export var distance_to_target: float = 1.0

@onready var animation_player: AnimationPlayer = $"character-orc2/AnimationPlayer"
@onready var target_position_debug: CSGSphere3D = $TargetPositionDebug
@onready var state_machine: StateMachine = $StateMachine
@export var gigante: bool = false :
	set(new_value):
		gigante = new_value
		if gigante:
			scale = Vector3.ONE * 3
			if not is_node_ready():
				await ready
			navigation_agent_3d.set_navigation_layer_value(1, false)
			navigation_agent_3d.set_navigation_layer_value(2, true)
		else:
			if not is_node_ready():
				await ready
			navigation_agent_3d.set_navigation_layer_value(1, true)
			navigation_agent_3d.set_navigation_layer_value(2, false)
			scale = Vector3.ONE
@onready var movement: Node3D = $NavigationBasedMovement
@onready var navigation_agent_3d: NavigationAgent3D = %NavigationAgent3D


func move_to_target_position(target_position: Vector3) -> void:
	state_machine.handle_event(Event.TargetPositionChanged, { "target_position": target_position})
	target_position_debug.global_position = target_position

func set_velocity_to_move_towards(point: Vector3, delta: float) -> void:
	var target_velocity = movement.velocity_to_move_towards(self, point, walk_speed)
	velocity.x = target_velocity.x
	velocity.z = target_velocity.z
	if is_on_floor():
		velocity.y = target_velocity.y

func has_reached_target(target_position: Vector3) -> bool:
	return movement.has_reached_target(self, target_position)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	move_and_slide()
