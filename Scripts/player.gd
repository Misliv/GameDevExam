extends CharacterBody2D

@onready var sprite = $Sprite2D
@onready var anim_player = $AnimationPlayer
@onready var anim_tree = $AnimationTree
@onready var state_machine = anim_tree["parameters/playback"]

const SPEED = 200.0
const JUMP_VELOCITY = -500.0
const WALL_SLIDING_SPEED = 1200
const JUMP_POWER = -400

const attack = ["slash"]

enum States {IDLE, MOVING, JUMPING, MAGIC}

var jumpsMade = 0
var doWallJump = false
var state = States.IDLE
var direction
var runMultiplier = 1
var isAttacking = false

func _physics_process(delta: float) -> void:
	direction = Input.get_axis("left", "right")
	# Add the gravity
	if is_on_wall_only(): velocity.y = WALL_SLIDING_SPEED * delta
	elif not is_on_floor():
		velocity += get_gravity() * delta
	else: GameManager.jumps = 0
	
	magic()
	handle_state_transitions()
	perform_state_actions(delta)
	move_and_slide()
	
func handle_state_transitions() -> void:
	if is_on_floor():
		state = States.IDLE
	elif is_on_floor():
		state = States.MAGIC	
	
	# Get the input direction and handle the movement/deceleration.		
	if Input.is_action_just_pressed("jump"):
		state = States.JUMPING
		if is_on_wall_only():
			velocity.y = JUMP_VELOCITY
			velocity.x = -direction * SPEED
			doWallJump = true
			$WallJumpTimer.start()
		elif is_on_floor() || GameManager.jumps < 2:
			velocity.y = JUMP_VELOCITY
			GameManager.jumps += 1
			
	direction = Input.get_axis("left", "right")
	
	if Input.is_action_pressed("run"):
		state = States.MOVING
		runMultiplier = 2
	else:
		runMultiplier = 1	
		
	if direction != 0:
		# Flip sprite depending on direction you're facing.	
		if direction < 0:
			sprite.flip_h = true
		else:
			sprite.flip_h = false
		state = States.MOVING
	elif is_on_floor() and state != States.JUMPING:
		state = States.IDLE
		
	# Ability to run
	if direction && not doWallJump:
		velocity.x = direction * SPEED * runMultiplier
	elif not doWallJump:
		velocity.x = move_toward(velocity.x, 0, SPEED * runMultiplier)
		
	# Ability to shoot out magic.
	#if Input.is_action_just_pressed("magic"):
		#state = States.MAGIC
		#var magicNode = load("res://Scenes/magic_area.tscn")
		#var newMagic = magicNode.instantiate()
		#if $AnimatedSprite2D.flip_h == false:
			#newMagic.direction = -1
		#else:
			#newMagic.direction = 1
		#newMagic.set_position(%MagicSpawnpoint.global_transform.origin)
		#get_parent().add_child(newMagic)
		
func perform_state_actions(delta: float) -> void:
	match state:
		States.IDLE:
			anim_player.play("idle")
			velocity.x = move_toward(velocity.x, 0, SPEED * runMultiplier)
			
		States.MOVING:
			if is_on_floor_only():
				anim_player.play("run")
				velocity.x = direction * SPEED * runMultiplier
			
		States.JUMPING:
			if velocity.y < 0:
				anim_player.play("jump")
			elif velocity.y > 0:
				anim_player.play("fall")
				
		States.MAGIC:
				anim_player.play("slash")

func magic(): 
	if Input.is_action_just_pressed("magic"):
		state = States.MAGIC
		isAttacking = true	
		var magicNode = load("res://Scenes/magic_area.tscn")
		var newMagic = magicNode.instantiate()
		if sprite.flip_h == false:
			newMagic.direction = -1
		else:
			newMagic.direction = 1
		newMagic.set_position(%MagicSpawnpoint.global_transform.origin)
		get_parent().add_child(newMagic)
	
func _on_sprite_finished():
	if anim_player.animation == "magic":
		isAttacking = false

func take_damage():
	anim_player.play("hit")
	
# Player respawn.
func killPlayer():
	position = %RespawnPoint.position
	sprite.flip_h = false

# Player death.
func _on_death_area_body_entered(body: Node2D) -> void:
	killPlayer()


func _on_wall_jump_timer_timeout() -> void:
	doWallJump = false
