extends CharacterBody3D

var direction; var input_dir; var isMoving: bool; var isRunning: bool; var isCrouching: bool; var isSliding: bool #Move
var current_speed:float; var walk_speed:float; var run_speed: float; var crouch_speed: float #Speed
var slide_direction: Vector3
var gravity: float 


@onready var head = $Head; @onready var camera = $Head/Camera3D #Head and Camera for MouseController
@onready var sensitivity: float = 0.001 #Sens for mousecontroller

func _unhandled_input(event): #Input handler
	if event is InputEventMouseMotion: #Mouse handler
		head.rotate_y(-event.relative.x * sensitivity) #Rotate head
		camera.rotate_x(-event.relative.y * sensitivity) #Rotate camera
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90)) #Camera clamp, now cant do somersaults
		
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) #hide mouse
	isMoving=false; isRunning=false; isCrouching=false; isSliding=false
	current_speed=0; walk_speed=5; run_speed=10; crouch_speed=2;
	gravity = 9.8

func _process(delta):
	print(scale.y)
	slide(delta)
	move(delta)
	crouch()
	run()

func move(delta):
	if not is_on_floor(): #if character not on floor
		velocity.y -= gravity * delta #increasing the speed of the fall
		
	input_dir=Input.get_vector("move_left", "move_right", "move_forward", "move_back") #Get inputs
	direction=(head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized() #Making direction with character orientation
	if !isSliding:
		if direction:
			isMoving=true; 
			if !isRunning && !isCrouching && !isSliding:
				current_speed=lerp(current_speed, walk_speed, 0.02) #Smooth speed
		else:
			isMoving=false; current_speed=0
		velocity.x = direction.x * current_speed #Move the character along X axis
		velocity.z = direction.z * current_speed #Move the character along Z axis
		move_and_slide()

func run():
	if !isSliding:
		if isMoving && !isCrouching && Input.is_action_pressed("run"):
			isRunning=true; current_speed=lerp(current_speed, run_speed, 0.07)
		if isRunning && Input.is_action_just_released("run"):
			isRunning=false
func crouch():
	if !isSliding:
		if !isRunning && Input.is_action_pressed("crouch"):
			scale.y = lerp(scale.y, 0.8, 0.09)
			isCrouching=true; current_speed=lerp(current_speed, crouch_speed, 0.07)
		if isCrouching && Input.is_action_just_released("crouch"): isCrouching=false
		if !isCrouching && !isSliding:
			scale.y = lerp(scale.y, 1.25, 0.04)
func slide(delta):
	if current_speed>9.5 && Input.is_action_pressed("crouch"): isSliding=true
	if isSliding && current_speed > 3:
		slide_direction = -camera.global_transform.basis.z.normalized(); slide_direction.y = direction.y
		scale.y = lerp(scale.y, 0.5, 0.09)

		current_speed=lerp(current_speed, crouch_speed, 0.01)
		translate(slide_direction * current_speed * delta)
	else:
		isSliding=false;
