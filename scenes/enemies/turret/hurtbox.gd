extends Area3D

signal shot

func was_shot(shooter):
	shot.emit(shooter)
