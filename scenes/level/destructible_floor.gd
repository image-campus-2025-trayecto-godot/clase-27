extends CSGBox3D

@export var navigation_region: NavigationRegion3D
var hp: int = 3

func was_shot(shooter):
	hp -= 1
	if hp < 0:
		queue_free()
		navigation_region.navigation_layers = 0
