extends CharacterBody2D

@onready var anim_tree = $AnimationTree
@onready var state_machine = anim_tree["parameters/playback"]

const melee_attacks = ["5A", "5B", "214A"]
const ranged_attacks = ["6A", "6A 2"]

func melee_attack():
	state_machine.travel(melee_attacks.pick_random())
	
func ranged_attack():
	state_machine.travel(ranged_attacks.pick_random())
