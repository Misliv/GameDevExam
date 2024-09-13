extends CharacterBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D

const SPEED = 200.0
const JUMP_VELOCITY = -500.0
const WALL_SLIDING_SPEED = 1200
const JUMP_POWER = -400

enum States {IDLE, MOVING, JUMPING, MAGIC}

var jumpsMade = 0
var doWallJump = false
var state = States.IDLE
var direction

var main_sm: LimboHSM

func _physics_process(delta: float) -> void:
	direction = Input.get_axis("left", "right")
	# Add the gravity
	if is_on_wall_only(): velocity.y = WALL_SLIDING_SPEED * delta
	elif not is_on_floor():
		velocity += get_gravity() * delta
	else: jumpsMade = 0
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var run_multiplier = 1
	
	# Ability to run
	if Input.is_action_pressed("run"):
		run_multiplier = 2
	else:
		run_multiplier = 1
	
	
	if direction && not doWallJump:
		velocity.x = direction * SPEED * run_multiplier
	elif not doWallJump:
		velocity.x = move_toward(velocity.x, 0, SPEED * run_multiplier)
	
	# Ability to shoot out magic.
	if Input.is_action_just_pressed("magic"):
		var magicNode = load("res://Scenes/magic_area.tscn")
		var newMagic = magicNode.instantiate()
		if $AnimatedSprite2D.flip_h == false:
			newMagic.direction = -1
		else:
			newMagic.direction = 1
		newMagic.set_position(%MagicSpawnpoint.global_transform.origin)
		get_parent().add_child(newMagic)
		
	handle_state_transitions()
	perform_state_actions(delta)
	move_and_slide()
	
func handle_state_transitions() -> void:
	direction = Input.get_axis("left", "right")
	if Input.is_action_just_pressed("jump"):
		state = States.JUMPING
		if is_on_wall_only():
			velocity.y = JUMP_VELOCITY
			velocity.x = -direction * SPEED
			doWallJump = true
			$WallJumpTimer.start()
		elif is_on_floor() || jumpsMade < 2:
			velocity.y = JUMP_VELOCITY
			jumpsMade += 1

		if direction != 0:
			# Flip sprite depending on direction you're facing.	
			if direction < 0:
				animated_sprite_2d.flip_h = true
			else:
				animated_sprite_2d.flip_h = false
			state = States.MOVING
		elif is_on_floor() and state != States.JUMPING:
			state = States.IDLE

func perform_state_actions(delta: float) -> void:
	match state:
		States.IDLE:
			animated_sprite_2d.play("idle")
			velocity.x = 0
			
		States.MOVING:
			animated_sprite_2d.play("run")
			velocity.x = direction * SPEED
	
	
# Player respawn.
func killPlayer():
	position = %RespawnPoint.position
	$AnimatedSprite2D.flip_h = false

# Player death.
func _on_death_area_body_entered(body: Node2D) -> void:
	killPlayer()


func _on_wall_jump_timer_timeout() -> void:
	doWallJump = false
