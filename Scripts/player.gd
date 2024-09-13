extends CharacterBody2D


const SPEED = 200.0
const JUMP_VELOCITY = -500.0

var jumpsMade = 0


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else: jumpsMade = 0

	# Handle jump.
	if Input.is_action_just_pressed("jump") and (is_on_floor() || jumpsMade < 2):
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
	
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED * run_multiplier
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * run_multiplier)
	
	# Flip sprite depending on direction you're facing.
	if velocity.x < 0:
		$AnimatedSprite2D.flip_h = true
	if velocity.x > 0:
		$AnimatedSprite2D.flip_h = false
		
	# Run or idle animation depending on whether you're running or idling.
	if velocity.x != 0:
		$AnimatedSprite2D.play("run")
	else:
		$AnimatedSprite2D.play("idle")

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
		

# Player respawn.
func killPlayer():
	position = %RespawnPoint.position
	$AnimatedSprite2D.flip_h = false

# Player death.
func _on_death_area_body_entered(body: Node2D) -> void:
	killPlayer()
