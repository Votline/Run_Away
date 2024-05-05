extends CharacterBody3D

@onready var head = $Head; @onready var camera = $Head/Camera3D
@onready var sensitivity: float = 0.001

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta):
	pass
		
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * sensitivity)
		camera.rotate_x(-event.relative.y * sensitivity)
		#camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(-60))
	
