extends CharacterBody2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var bullet = preload("res://scenes/bullet.tscn")
@onready var muzzle: Marker2D = $Muzzle

const SPEED = 130.0
const JUMP_VELOCITY = -300.0

enum PlayerState {
	IDLE,
	RUN,
	JUMP,
	SHOOT,
	RUN_SHOOT,
	JUMP_SHOOT
}

#MUZZLE POSITION VARIABLE
var muzzle_position
# GLOBAL PLAYER STATE
var state: PlayerState = PlayerState.IDLE
# SHOOT LOCK FLAG
var shooting_locked: bool = false

# MAIN FUNCTION
func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	handle_jump()
	handle_movement_input()
	update_state()
	play_animation()
	move_character()
	
	if Input.is_action_just_pressed("shoot") and not shooting_locked:
		player_shooting(delta)


	print("State: ", PlayerState.keys()[state], " | Locked: ", shooting_locked)


# TO APPLY GRAVITY
func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta


# TO HANDLE JUMP INPUT
func handle_jump() -> void:
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY


# TO HANDLE SPRITE FLIPPING
func handle_movement_input() -> void:
	var direction := Input.get_axis("move_left", "move_right")
	if direction > 0:
		animated_sprite.flip_h = false
		muzzle.position.x = abs(muzzle_position.x)  # → facing right
	elif direction < 0:
		animated_sprite.flip_h = true
		muzzle.position.x = -abs(muzzle_position.x) # ← facing left
		
	



# TO UPDATE ALL THE STATES
func update_state() -> void:
	#NO UPDATION IF SHOOTING LOCKED
	if shooting_locked:
		return

	var direction := Input.get_axis("move_left", "move_right")
	var is_shooting := shooting_locked

	if not is_on_floor():
		if is_shooting:
			state = PlayerState.JUMP_SHOOT
			shooting_locked = true
		else:
			state = PlayerState.JUMP
	elif direction == 0:
		if is_shooting:
			state = PlayerState.SHOOT
			shooting_locked = true
		else:
			state = PlayerState.IDLE
	else:
		if is_shooting:
			state = PlayerState.RUN_SHOOT
			shooting_locked = true
		else:
			state = PlayerState.RUN


# TO PLAY ANIMATIONS
func play_animation() -> void:
	match state:
		PlayerState.IDLE:
			animated_sprite.play("idle")
		PlayerState.RUN:
			animated_sprite.play("run")
		PlayerState.JUMP:
			animated_sprite.play("jump")
		PlayerState.SHOOT:
			animated_sprite.play("shoot")
		PlayerState.RUN_SHOOT:
			animated_sprite.play("run_shoot")
		PlayerState.JUMP_SHOOT:
			animated_sprite.play("jump_shoot")


# TO CHANGE VELOCITY WHILE MOVING
func move_character() -> void:
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()


# SHOOTING LOGIC
func player_shooting(delta: float) -> void:
	#CREATED BULLET ISNTANCE AND ADDED TO GAME ROOT
	var bullet_instance = bullet.instantiate() as Node2D
	bullet_instance.global_position = muzzle.global_position
	
	if(animated_sprite.flip_h):
		bullet_instance.direction = -1
	else:
		bullet_instance.direction = 1
		
	
	get_parent().add_child(bullet_instance)
	
	# Set bullet direction based on sprite flip



# CONNECT SIGNAL WHEN READY
func _ready() -> void:
	animated_sprite.animation_finished.connect(_on_animation_finished)
	muzzle_position = muzzle.position

# UNLOCK SHOOTING STATE ON ANIMATION END
func _on_animation_finished() -> void:
	if shooting_locked and (
		state == PlayerState.SHOOT or
		state == PlayerState.RUN_SHOOT or
		state == PlayerState.JUMP_SHOOT
	):
		shooting_locked = false
		update_state()
