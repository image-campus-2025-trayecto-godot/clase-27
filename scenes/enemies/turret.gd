class_name Turret
extends Node3D

const TURRET_PROJECTILE = preload("uid://563ue053bg5k")

enum Event {
	Destroyed,
	PlayerDetected,
	PlayerOutOfSight,
	PlayerLockedOn
}

var hp: int = 2
## Controla si las armas de la torreta deben mirar hacia el [member targeted_node] o no.
@export var weapons_track_target: bool = false
## Nodo al que apunta la torreta.
@export var targeted_node: Node3D
## Velocidad de los proyectiles que dispara la torreta.
@export var shoot_speed: float = 5.0
## Tiempo que tarda entre que empieza la animación de disparo y que el proyectil es disparado.
@export var attack_telegraph_time: float = 2.0
## Tiempo entre que un proyectil fue disparado y que comienza la animación de disparo de nuevo.
@export var time_between_shoots: float = 3.0
@export var patrolling_turn_speed: float = 3.0

@onready var face: Node3D = %Face
@onready var shoot_spawn_position: Marker3D = %ShootSpawnPosition
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var field_of_view: Area3D = $FacePivot/Face/FieldOfView
@onready var when_does_not_have_targeted_node_collision_shape: CollisionShape3D = $FacePivot/Face/FieldOfView/WhenDoesNotHaveTargetedNodeCollisionShape
@onready var when_targeted_node_collision_shape: CollisionShape3D = $FacePivot/Face/FieldOfView/WhenTargetedNodeCollisionShape
@onready var eye_1: Node3D = $FacePivot/Face/Eyes/Eye
@onready var eye_2: Node3D = $FacePivot/Face/Eyes/Eye2
@onready var state_machine: StateMachine = $StateMachine

signal player_detected
signal player_out_of_sight
signal destroyed

func _ready():
	for eye in [eye_1, eye_2]:
		eye.destroyed.connect(self.was_damaged)
	field_of_view.body_entered.connect(func(body):
		target_node(body)
	)
	field_of_view.body_exited.connect(func(body):
		lose_target()
	)

func target_node(node_to_target):
	targeted_node = node_to_target
	when_does_not_have_targeted_node_collision_shape.set_deferred("disabled", true)
	when_targeted_node_collision_shape.set_deferred("disabled", false)
	player_detected.emit()
	state_machine.handle_event(Event.PlayerDetected)

func lose_target():
	targeted_node = null
	when_does_not_have_targeted_node_collision_shape.set_deferred("disabled", false)
	when_targeted_node_collision_shape.set_deferred("disabled", true)
	player_out_of_sight.emit()
	state_machine.handle_event(Event.PlayerOutOfSight)

## Método auxiliar que rota un nodo para que mire a cierto punto.
func _smoothed_look_at(node_to_rotate: Node3D, point_to_look_at: Vector3, weight: float) -> void:
	var node_transform = node_to_rotate.global_transform
	var target_transform := node_transform.looking_at(point_to_look_at)
	var new_quaternion: Quaternion = node_transform.basis.get_rotation_quaternion().slerp(target_transform.basis.get_rotation_quaternion(), weight)
	var new_transform := Transform3D(Basis(new_quaternion), node_transform.origin)
	node_to_rotate.global_transform = new_transform

func _physics_process(delta: float) -> void:
	if is_target_locked_on():
		state_machine.handle_event(Event.PlayerLockedOn)

func switch_to_aggresive_mode_animation():
	animation_player.play("switch_to_aggresive")

func switch_to_idle_mode_animation():
	animation_player.play_backwards("switch_to_aggresive")

func play_destroyed_animation():
	animation_player.play("destroyed")

## Método que mueve la "cara" y las armas de la torreta hacia el [member targeted_node] (si hay uno).
func look_at_target(delta: float):
	if targeted_node:
		var point_to_look_at := targeted_node.global_position
		_smoothed_look_at(face, point_to_look_at, 1 - pow(0.01, delta))
		if weapons_track_target:
			for weapon in face.weapons:
				_smoothed_look_at(weapon, point_to_look_at, 1 - pow(0.01, delta))

func look_around(delta: float):
	face.global_basis = face.global_basis.rotated(Vector3.UP, delta * patrolling_turn_speed)

func is_target_locked_on() -> bool:
	if targeted_node:
		var targeted_node_position = targeted_node.global_position
		var face_position = face.global_position
		var direction_to_target = face_position.direction_to(targeted_node_position)
		var angle = direction_to_target.angle_to(-face.global_basis.z)
		return angle < deg_to_rad(5)
	return false

func shoot():
	var turret_projectile = TURRET_PROJECTILE.instantiate()
	get_parent().add_child(turret_projectile)
	turret_projectile.global_position = shoot_spawn_position.global_position
	turret_projectile.direction = -face.global_basis.z
	turret_projectile.speed = shoot_speed

func play_charging_attack_animation():
	for weapon in face.weapons:
		weapon.play_shoot_animation()

func was_damaged(shooter):
	hp -= 1
	if hp <= 0:
		destroyed.emit()
		state_machine.handle_event(Event.Destroyed)
	else:
		target_node(shooter)
