extends Area2D

var speed = 1200
var velocity
var playerObject
var direction = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	playerObject = get_node("../Player").get_node("AnimatedSprite2D")
	$Timer.connect("timeout", _on_timer_timeout)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if direction == 1:
		velocity = Vector2(-1, 0).rotated(rotation_degrees) * speed * delta
		$Magic/CPUParticles2D.gravity.x = 3000
	else:
		velocity = Vector2(1, 0).rotated(rotation_degrees) * speed * delta
		$Magic/CPUParticles2D.gravity.x = -3000
		position += velocity
	
func _on_timer_timeout():
	queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Enemy"):
		GameManager.score += 500
		area.get_parent().queue_free()
		queue_free()
