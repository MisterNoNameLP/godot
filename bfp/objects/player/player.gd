extends RigidBody2D

@onready var animation = $AnimatedSprite2D
@onready var groundCast = $GroundCast

const SPEED = 400.0
const ACCELERATION = 2000
const JUMP_FORCE = -400.0
const BREAK_FOCE_VELOCITY_THRESHOLD = 10
const SLEEP_SPEED_THRESHOLD = 10

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func isOnFloor(): #ToDo: 
	return groundCast.is_colliding()

func _ready():
	animation.play("idle")
	pass
	
func  _physics_process(delta):
	var velocity = linear_velocity
	var gotInput = false
	
	if Input.is_action_just_pressed("ui_up") and isOnFloor():
		gotInput = true
		apply_central_impulse(Vector2(0, JUMP_FORCE))

	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		gotInput = true
		var acceleration = ACCELERATION
		if direction < 0 and velocity.x > 0 \
		or direction > 0 and velocity.x < 0:
			acceleration *= 2
		
		if abs(velocity.x) < SPEED:
			apply_central_force(Vector2(direction * acceleration, 0))
	else:
		var moveDirection = clamp(1 * velocity.x * 100, -1, 1)
		
		if abs(velocity.x) > BREAK_FOCE_VELOCITY_THRESHOLD:
			apply_central_force(Vector2(-moveDirection * ACCELERATION, 0))
	
	if abs(velocity.x) < SLEEP_SPEED_THRESHOLD and abs(velocity.y) < SLEEP_SPEED_THRESHOLD and isOnFloor() and not gotInput:
			sleeping = true
	
		
func _process(delta):
	var velocity = linear_velocity
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		animation.play("run")
		if direction < 0:
			animation.scale.x = move_toward(animation.scale.x, -1, 20 * delta)
		elif direction > 0:
			animation.scale.x = move_toward(animation.scale.x, 1, 20 * delta)
	else:
		var targetScale = clamp(1 * animation.scale.x * 100, -1, 1)
		animation.scale.x = move_toward(animation.scale.x, targetScale, 20 * delta)
	
	if not isOnFloor():
		if velocity.y < 0:
			animation.play("jump")
		elif velocity.y > 0:
			animation.play("fall")
	elif abs(velocity.x) < BREAK_FOCE_VELOCITY_THRESHOLD:
		animation.play("idle")
	
	
	#move_and_slide()
