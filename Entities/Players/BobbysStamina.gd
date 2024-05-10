extends "res://Entities/Players/BobbysMovement.gd"
var stamina: float = 100
func stamina_change(stamina_new, time):
	stamina = lerp(float(stamina), float(stamina_new), float(time))
