extends AnimatedSprite2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# Coin pick-up and score value.
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group('Player'):
		GameManager.playSoundFX(load("res://Assets/SFX/Retro PickUp Coin 04.wav"))
		GameManager.coins += 1
		GameManager.score += 100
		queue_free()
