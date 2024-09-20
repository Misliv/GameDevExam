extends Node

var coins = 0
var score = 0
var jumps = 0
var wallJumping = false

func playSoundFX(stream):
	$CoinPickupSFX.stream = stream
#	$CoinPickupSFX.play()
	
# Picking up coins updates the UI to increase the amount of coins you have and the score.
func _process(delta: float) -> void:
	$"GUI/CoinsValue".text = str(coins)
	$"GUI/ScoreValue".text = str(score)
