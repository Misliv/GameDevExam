extends CharacterBody2D

@export var animation_tree : AnimationTree

var state_machine : AnimationNodeStateMachinePlayback
var move_state_machine : AnimationNodeStateMachinePlayback
var jump_state_machine : AnimationNodeStateMachinePlayback
var attack_state_machine : AnimationNodeStateMachinePlayback

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var speed : float = 175
var direction : float
var counter : int = 0
var delay : float
const jumpVelocity = -500.0
var doWallJump = false
const WALL_SLIDING_SPEED = 1200

var on_floor : bool :
	#Flips sprite
	set(value):
		if value == on_floor:
			if value == true:
				flip_sprite()
			return
		# Transition from falling animation to ground animations.	
		on_floor = value
		if value == true:
			state_machine.travel("Movement")
		else:
			state_machine.travel("Jump")

# Prepares the animations		
func _ready():
	state_machine = animation_tree.get("parameters/playback")
	move_state_machine = animation_tree.get("parameters/Movement/playback")
	jump_state_machine = animation_tree.get("parameters/Jump/playback")
	attack_state_machine = animation_tree.get("parameters/Attack/playback")
	
func _physics_process(delta):
	# Left and right movement, wall slide, gravity and checks if you have walljumped already.	
	if delta > 0:
		delay -= delta
	direction = Input.get_axis("left", "right")

	if is_on_wall_only() and (not GameManager.wallJumping): velocity.y = WALL_SLIDING_SPEED * delta
	elif not is_on_floor():
		velocity += get_gravity() * delta
	else:
		GameManager.jumps = 0
		GameManager.wallJumping = false
	velocity.x = direction * speed
	#velocity.y = gravity * delta
	move_and_slide()
	
	on_floor = is_on_floor()
	
	# Activates the running animation (only that I think?)
	if velocity == Vector2.ZERO:
		set_motion(false)
	else:
		set_motion(true)
	
	controls()

func controls():
	# Jump and walljump
	if Input.is_action_just_pressed("jump") and (is_on_floor() or is_on_wall_only()):
		print(velocity.y)
		print(is_on_wall())
		
		if (GameManager.jumps == 0 and is_on_wall()):
			GameManager.jumps = 1
			GameManager.wallJumping = true
			state_machine.travel("Jump")
			velocity.y = jumpVelocity
			move_and_slide()
			
		else:
			state_machine.travel("Jump")
			
			velocity.y = jumpVelocity
		print(velocity.y)
	
	# Dash	
	if Input.is_action_just_pressed("dash")	 and is_on_floor():
		move_state_machine.travel("dash")
		set_speed(300.0)
		print("test")
	
	# Right mouseclick attack	
	if Input.is_action_just_pressed("attack_right") and is_on_floor():
		play_attack("3")	
	
	# Left mouseclick attack
	if Input.is_action_just_pressed("attack_left") and delay <= 0:
		delay = 0.75
		$Reset.start()
		if is_on_floor():
			print(counter)
			counter += 1
			attack ((counter % 3 == 0))
		if not is_on_floor():
			jump_state_machine.travel("jump_attack")		
	
	# Special move
	if Input.is_action_just_pressed("special") and is_on_floor():
		play_attack("special")
		#state_machine.travel("GroupAttack/attack_1")

# Switches movement conditions		
func set_motion(value : bool):
	animation_tree.set("parameters/Movement/conditions/can_run", value)
	animation_tree.set("parameters/Movement/conditions/is_stopped", not value)

# Sets the speed	
func set_speed(value: float = 175):
	speed = value	

# Flips the sprite according to which way you're going	
func flip_sprite():
	if direction < 0:
		$Sprite2D.flip_h = true
	elif direction > 0:
		$Sprite2D.flip_h = false

# Plays the attack animations		
func play_attack(type : String):
	attack_state_machine.travel("attack_" + type)
	
	state_machine.travel("Attack")
	set_speed(0)

# The ability to attack once or twice depending on how many times you click in a short amount of time.	
func attack(is_third):
	print("attacking")
	if is_third:
		play_attack("2")
		counter = 0
		return
	play_attack("1")	

# Resets the attack counter if you do nothing after one click for too long
func _on_reset_timeout() -> void:
	counter = 0
