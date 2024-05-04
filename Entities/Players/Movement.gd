extends CharacterBody3D

var move_direction: Vector3; var isMoving: bool; var isRunning: bool; var isCrouching: bool; var isSliding: bool; #Move
var current_speed:float; var walk_speed:float; var run_speed: float; var crouch_speed: float #Speed


func _ready():
	isMoving=false; isRunning=false; isCrouching=false; isSliding=false
	current_speed=0; walk_speed=5; run_speed=10; crouch_speed=2; 


func _process(delta):
	print(current_speed)
	slide(delta)
	move(delta)
	crouch()
	run()
func move(delta):
	move_direction = Vector3(
		Input.get_axis('move_left', 'move_right'), 
		0 , 	
		Input.get_axis('move_forward', 'move_back')
		)
	if move_direction.x == 0 && move_direction.z == 0 && !isSliding:
		isMoving=false; current_speed=0; return

	isMoving=true
	if !isSliding:
		if !isCrouching && !isSliding && !isRunning:
			current_speed=lerp(current_speed, walk_speed, 0.02)
		translate(move_direction * current_speed * delta)
func run():
	if !isSliding:
		if isMoving && !isCrouching && Input.is_action_pressed("run"):
			isRunning=true; current_speed=lerp(current_speed, run_speed, 0.07)
		if isRunning && Input.is_action_just_released("run"):
			isRunning=false
func crouch():
	if !isSliding:
		if !isRunning && Input.is_action_pressed("crouch"):
			isCrouching=true; current_speed=lerp(current_speed, crouch_speed, 0.07)
		if isCrouching && Input.is_action_just_released("crouch"):
			isCrouching=false
func slide(delta):
	if current_speed>9.7 && Input.is_action_pressed("crouch"): isSliding=true
	if isSliding && current_speed > 2:
		current_speed=lerp(current_speed, crouch_speed, 0.01)
		translate(Vector3.FORWARD * current_speed * delta)
	else:
		isSliding=false;
