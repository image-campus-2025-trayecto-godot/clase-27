extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hurtbox: Area3D = $Hurtbox
var being_destroyed: bool = false

signal destroyed(shooter)

func _ready():
	animation_player.play("idle")
	animation_player.seek(randf_range(0, animation_player.current_animation_length))
	hurtbox.shot.connect(self.destroy)

func destroy(shooter):
	if being_destroyed:
		return
	being_destroyed = true
	animation_player.play("destroyed")
	await animation_player.animation_finished
	destroyed.emit(shooter)
	queue_free()
