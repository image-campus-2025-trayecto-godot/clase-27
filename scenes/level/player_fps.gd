class_name Player
extends CharacterBody3D

const BULLET_HOLE_DECAL = preload("uid://bt2tprq6f1rre")
const BULLET_RIGID_BODY = preload("uid://bwb8kiif8akov")
const MAX_HP = 100.0

enum WeaponMode {
	Automatic,
	SemiAutomatic
}

enum ShootMode {
	RIGID_BODY,
	HITSCAN
}

@export var doom_mode_enabled: bool = false
@export var camera_fov_while_sprinting: float = 90
@export var SPEED: float = 5.0
@export var SPRINT_SPEED: float = 8.0
@export var JUMP_VELOCITY: float = 4.5
@export var time_without_hits_until_hp_regeneration: float = 4.0
@export var regeneration_speed: float = 5.0

@export_range(0.01, 1.0, 0.01) var mouse_sensitivity: float = 0.15
@export_category("Weapon")


var _mouse_motion: Vector2
var movement_enabled: bool = true
@onready var camera_3d: Camera3D = %PlayerCamera
@onready var bullet_spawn_point: Marker3D = %BulletSpawnPoint
@onready var hit_scan_ray_cast: RayCast3D = %HitScanRayCast
@onready var camera_animation_player: AnimationPlayer = $CameraAnimationPlayer
@onready var camera_3d_original_fov: float = camera_3d.fov
@onready var camera_pivot: Node3D = %CameraPivot
#@onready var weapon_animation_player: AnimationPlayer = $CameraPivot/PlayerCamera/WeaponPivot/WeaponModel/AnimationPlayer
@onready var camera_pivot_target_rotation_offset: Vector2
@onready var weapon_pivot_animation_player: AnimationPlayer = $CameraPivot/PlayerCamera/WeaponPivot/WeaponPivotAnimationPlayer
@onready var weapon_controller: WeaponController = $CameraPivot/PlayerCamera/WeaponPivot/WeaponController
@onready var weapon_model: Node3D = $CameraPivot/PlayerCamera/WeaponPivot/WeaponModel
@onready var hp := MAX_HP :
	set(new_value):
		hp = new_value
		hp_changed.emit(hp)
var time_since_last_hit: float = 0.0


signal hp_changed(new_hp)

var _time_until_can_shoot: float = 0.0
var _changing_weapon_mode: bool = false

func get_hit():
	time_since_last_hit = 0.0
	self.hp -= 30.0
	camera_pivot_target_rotation_offset += Vector2(randf_range(PI / 4, PI / 2), 0.0)

func _ready() -> void:
	weapon_controller.weapon_model_changed.connect(func(new_model):
		weapon_model = new_model
	)

func can_shoot() -> bool:
	return _time_until_can_shoot <= 0.0 and not _changing_weapon_mode

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_mouse_motion = event.screen_relative * mouse_sensitivity

func _physics_process(delta: float) -> void:
	if not movement_enabled:
		return
	
	time_since_last_hit += delta
	
	if time_since_last_hit > time_without_hits_until_hp_regeneration:
		self.hp = move_toward(hp, MAX_HP, delta * regeneration_speed)

	_time_until_can_shoot -= delta

	camera_3d.rotation = Vector3(
		camera_3d.rotation.x -_mouse_motion.y * delta,
		camera_3d.rotation.y - _mouse_motion.x * delta,
		0.0
	)
	camera_3d.global_rotation.x = clampf(camera_3d.global_rotation.x, - PI / 3, PI / 4)
	_mouse_motion = Vector2.ZERO
	
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (camera_3d.global_basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var is_sprinting: bool = Input.is_action_pressed("sprint")
	var current_speed := SPRINT_SPEED if is_sprinting else SPEED
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = 0.0
		velocity.z = 0.0
	
	if velocity.is_zero_approx():
		camera_animation_player.stop()
	elif not(camera_animation_player.is_playing() and camera_animation_player.current_animation == "walk_camera_movement"):
		camera_animation_player.play("walk_camera_movement")
	
	#var fov_acceleration: float = 15.0
	if is_sprinting:
		camera_3d.fov = lerp(camera_3d.fov, camera_fov_while_sprinting, 1 - pow(0.01, delta))
	else:
		camera_3d.fov = lerp(camera_3d.fov, camera_3d_original_fov, 1 - pow(0.01, delta))
	
	if Input.is_action_just_pressed("toggle_doom_mode"):
		doom_mode_enabled = not doom_mode_enabled
		if doom_mode_enabled:
			weapon_pivot_animation_player.play("toggle_doom_mode")
		else:
			weapon_pivot_animation_player.play_backwards("toggle_doom_mode")
	
	if Input.is_action_just_pressed("toggle_weapon_mode"):
		_changing_weapon_mode = true
		match weapon_controller.weapon_mode:
			WeaponMode.SemiAutomatic:			
				weapon_controller.weapon_mode = WeaponMode.Automatic
			WeaponMode.Automatic:
				weapon_controller.weapon_mode = WeaponMode.SemiAutomatic
		await weapon_model.play_toggle_weapon_animation()
		_changing_weapon_mode = false

	match weapon_controller.weapon_mode:
		WeaponMode.SemiAutomatic:
			if Input.is_action_just_pressed("shoot") and can_shoot():
				shoot_weapon()
		WeaponMode.Automatic:
			if Input.is_action_pressed("shoot") and can_shoot():
				shoot_weapon()

	camera_pivot_target_rotation_offset = camera_pivot_target_rotation_offset.lerp(Vector2.ZERO, 1 - pow(0.001, delta))
	
	var target_quat := Quaternion.from_euler(Vector3(camera_pivot_target_rotation_offset.x, camera_pivot_target_rotation_offset.y, 0.0))
	var current_quat := Quaternion.from_euler(camera_pivot.rotation)
	camera_pivot.rotation = current_quat.slerp(target_quat, 1 - pow(0.001, delta)).get_euler()

	move_and_slide()

func shoot_weapon():
	_time_until_can_shoot = 1.0 / weapon_controller.fire_rate()
	weapon_model.play_shoot_animation()
	match weapon_controller.shoot_mode():
		ShootMode.RIGID_BODY:
			var bullet: RigidBody3D = BULLET_RIGID_BODY.instantiate()
			get_parent().add_child(bullet)
			var target_position = camera_3d.global_position - camera_3d.global_basis.z * weapon_controller.bullet_impulse()
			bullet.global_position = bullet_spawn_point.global_position
			bullet.look_at(target_position)
			bullet.apply_central_impulse(bullet.global_position.direction_to(target_position) * weapon_controller.bullet_impulse())
		ShootMode.HITSCAN:
			if hit_scan_ray_cast.is_colliding():
				var collider = hit_scan_ray_cast.get_collider()
				if collider is RigidBody3D:
					collider.apply_impulse(
						-hit_scan_ray_cast.global_basis.z * weapon_controller.shoot_impulse(),
						hit_scan_ray_cast.get_collision_point() - collider.global_position
						)
				elif collider.has_method("was_shot"):
					collider.was_shot(self)
				var bullet_hole_decal: Node3D = BULLET_HOLE_DECAL.instantiate()
				collider.add_child(bullet_hole_decal)
				bullet_hole_decal.setup_visibility(collider)
				bullet_hole_decal.global_position = hit_scan_ray_cast.get_collision_point()
				if not hit_scan_ray_cast.get_collision_normal().cross(Vector3.UP).is_zero_approx():
					bullet_hole_decal.look_at(hit_scan_ray_cast.get_collision_point() + hit_scan_ray_cast.get_collision_normal())
					bullet_hole_decal.rotate_object_local(Vector3.RIGHT, PI / 2)
	var max_recoil_angle = weapon_controller.max_recoil_angle()
	camera_pivot_target_rotation_offset = Vector2(randf_range(- max_recoil_angle, max_recoil_angle), randf_range(- max_recoil_angle, max_recoil_angle))
