extends CharacterBody3D

var current_speed: float; var walk_speed: float; var run_speed: float; var crouch_speed: float; var slide_speed: float #Speed
var slide_direction: Vector3; var scale_normal: float; var scale_crouch: float; var scale_slide: float #Slide and crouch
var direction; var input_dir; var isMoving: bool; var isRunning: bool; var isCrouching: bool; var isSliding: bool #Move
var cb_frequency: float; var cb_amplitude: float; var cb_time: float; var cb_pos: Vector3 #Camera Bobbing
var fov_normal: float; var fov_crouch: float; var fov_run: float #Camera Fov

var canrun: bool = false;

const gravity = 9.8 


@onready var BobbysStamina=preload("res://Entities/Players/BobbysStamina.gd").new() #Get stamina script
@onready var head = $Head; @onready var camera = $Head/Camera3D; #Head and Camera for MouseController
@onready var sensitivity: float = 0.001 #Sens for mousecontroller

func _unhandled_input(event): #Input handler
	if event is InputEventMouseMotion: #Mouse event
		head.rotate_y(-event.relative.x * sensitivity) #Rotate head
		camera.rotate_x(-event.relative.y * sensitivity) #Rotate camera
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90)) #Camera clamp, now cant do somersaults
		
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED); #hide mouse
	current_speed=0; walk_speed=5; run_speed=10; crouch_speed=2; slide_speed = run_speed+crouch_speed*2 #Speed
	scale_normal=1.25; scale_crouch=0.8; scale_slide=0.5 #Scale
	fov_normal=90; fov_crouch=60; fov_run=120; #Camera Fov 
	cb_frequency=2.8; cb_amplitude=0.08; #Camera Bobbing


func _process(delta):
	print(BobbysStamina.stamina)
	headbob(delta)
	slide()
	move(delta)
	crouch()
	run()
	
	if !isSliding && !isCrouching && !isRunning: 
		BobbysStamina.stamina_change(100, 0.001)
		camera.fov = fov_change(fov_normal) #Change the camera fov to 90

func move(delta):
	if not is_on_floor(): #if character not on floor
		
		velocity.y -= gravity * delta #increasing the speed of the fall
		
	input_dir=Input.get_vector("move_left", "move_right", "move_forward", "move_back") #Get inputs
	direction=(head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized() #Making direction with character orientation
	if !isSliding:
		if direction:
			isMoving=true; 
			if !isRunning && !isCrouching:
				current_speed=lerp(current_speed, walk_speed, 0.02) #Smooth speed
		else:
			isMoving=false; current_speed=0
		velocity.x = direction.x * current_speed #Move the character along X axis
		velocity.z = direction.z * current_speed #Move the character along Z axis
		move_and_slide()

func run():
	if !isSliding:
		if !canrun && isMoving && !isCrouching && BobbysStamina.stamina > 5 && Input.is_action_pressed("run"): isRunning=true;
		else:
			isRunning = false; 
			if BobbysStamina.stamina <= 10: canrun=true;
			else: canrun=false
		if isRunning:
			current_speed=lerp(current_speed, run_speed, 0.04) #Smooth change speed to 10
			BobbysStamina.stamina_change(0, 0.01) #Change the value of stamina
			camera.fov = fov_change(fov_run) #Change the camera fov to 120

func crouch():
	if !isSliding:
		if !isRunning && Input.is_action_pressed("crouch"): isCrouching=true;
		if isCrouching:
			$CollisionShape3D.shape.height = scale_change(scale_crouch, 0.09) #Smooth change scale
			current_speed=lerp(current_speed, crouch_speed, 0.07) #Smooth change speed to 2
			camera.fov = fov_change(fov_crouch) #Change the camera fov to 60
		if isCrouching && Input.is_action_just_released("crouch"): isCrouching=false;
		if !isCrouching: $CollisionShape3D.shape.height = scale_change(scale_normal, 0.06) #Smooth change scale
		
func slide():
	if current_speed>9.7 && Input.is_action_just_pressed("crouch"): isSliding=true; current_speed=run_speed+crouch_speed*2
	if isSliding && Input.is_action_just_released("crouch"): isSliding=false;
	if isSliding && current_speed > 3:
		slide_direction = (-camera.global_transform.basis.z.normalized()) * current_speed; slide_direction.y = direction.y #Get direction for slide
		velocity.x = slide_direction.x; velocity.z=slide_direction.z; move_and_slide() #Move the character
		current_speed=lerp(current_speed, crouch_speed, 0.07) #Smooth change speed to 2
		$CollisionShape3D.shape.height = scale_change(scale_slide, 0.09) #Smooth change scale) #Smooth change scale to
		camera.fov = fov_change(fov_run) #Change the camera fov to 120
	else:
		isSliding=false; isCrouching=false;
		
func headbob(delta): # Func of simulating camera bobbing
	if !isSliding:
		cb_time += delta * velocity.length() * float(is_on_floor()) # Increase the bobbing time based on the velocity and whether the camera is on the floor
		cb_pos = Vector3.ZERO # Reset the camera position vector
		cb_pos.y = sin(cb_time * cb_frequency) * cb_amplitude # Calculate the vertical position of the camera using a sine function
		cb_pos.x = cos(cb_time * cb_frequency/2) * cb_amplitude # Calculate the horizontal position of the camera using a sine function
		camera.transform.origin = cb_pos # Update the camera position

func fov_change(fov_new) -> float: #Func of change the camera fov
	return lerp(camera.fov, fov_new, 0.03) #Return value for change camera fov

func scale_change(scale_new, time) -> float: #Func of change the height parameter of  CapsuleShape3D
	return lerp($CollisionShape3D.shape.height, scale_new, time) #Smooth change the height parameter
