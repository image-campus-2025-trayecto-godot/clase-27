class_name WeaponController
extends Node3D
const PlayerFps = preload("uid://cm6bvjjhychqi")

@export var weapon: Weapon

@export var max_recoil_angle: float = PI / 10
@export var bullet_impulse: float = 100.0
@export var shoot_mode: PlayerFps.ShootMode = PlayerFps.ShootMode.HITSCAN
@export var weapon_mode: PlayerFps.WeaponMode = PlayerFps.WeaponMode.SemiAutomatic

func fire_rate() -> float:
	return weapon.fire_rate

func shoot_impulse() -> float:
	return weapon.shoot_impulse
