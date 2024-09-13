extends CharacterBody2D

@onready var animation_sprite = $AnimatedSprite2D
@onready var animation_player = $AnimationPlayer

const SPEED = 200.0
const JUMP_VELOCITY = -500.0
const WALL_SLIDING_SPEED = 1200

var jumpsMade = 0
var doWallJump = false

var main_sm: LimboHSM

func _ready():
	initiate_state_machine()

func _physics_process(delta: float) -> void:
	var direction := Input.get_axis("left", "right")
	# Add the gravity & jump
	if is_on_wall_only(): velocity.y = WALL_SLIDING_SPEED * delta
	elif not is_on_floor():
		velocity += get_gravity() * delta
	else: jumpsMade = 0
	
	if Input.is_action_just_pressed("jump"):
		if is_on_wall_only():
			velocity.y = JUMP_VELOCITY
			velocity.x = -direction * SPEED
			doWallJump = true
			$WallJumpTimer.start()
			
		elif is_on_floor() || jumpsMade < 2:
			velocity.y = JUMP_VELOCITY
			jumpsMade += 1
	
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
	
	# Flip sprite depending on direction you're facing.
	if velocity.x < 0:
		$AnimatedSprite2D.flip_h = true
	if velocity.x > 0:
		$AnimatedSprite2D.flip_h = false
		
	# Run or idle animation depending on whether you're running or idling.


	move_and_slide()
	
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
			
		$AnimatedSprite2D.play("attack")
		
func initiate_state_machine():
	main_sm = LimboHSM.new()
	add_child(main_sm)
	
	var idle_state = LimboState.new().named("idle").call_on_enter(idle_start).call_on_update(idle_update)
	var run_state = LimboState.new().named("run").call_on_enter(run_start).call_on_update(run_update)
	var jump_state = LimboState.new().named("jump").call_on_enter(jump_start).call_on_update(jump_update)
	var attack_state = LimboState.new().named("attack").call_on_enter(attack_start).call_on_update(attack_update)
	
	main_sm.add_child(idle_state)
	main_sm.add_child(run_state)
	main_sm.add_child(jump_state)
	main_sm.add_child(attack_state)
	
	main_sm.initial_state = idle_state
	main_sm.add_transition(main_sm.ANYSTATE, idle_state, &"state_ended")
	
	main_sm.add_transition(idle_state, run_state, &"to_run")
	
	main_sm.initialize(self)
	main_sm.set_active(true)
	
func idle_start():
	animation_sprite.play("idle")
func idle_update(delta: float):
	if velocity.x != 0:
		main_sm.dispatch(&"to_run")
	
func run_start():
	animation_sprite.play("run")
func run_update(delta: float):
	if velocity.x == 0:
		main_sm.dispatch(&"state_ended")
	
func jump_start():
	pass
func jump_update(delta: float):
	pass
		
func attack_start():
	pass
func attack_update(delta: float):
	pass

# Player respawn.
func killPlayer():
	position = %RespawnPoint.position
	$AnimatedSprite2D.flip_h = false

# Player death.
func _on_death_area_body_entered(body: Node2D) -> void:
	killPlayer()


func _on_wall_jump_timer_timeout() -> void:
	doWallJump = false
