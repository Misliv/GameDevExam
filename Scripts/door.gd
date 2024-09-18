extends Area2D

class_name Door

@export var destinationLevelTag : String
@export var destinationDoorTag : String
@export var spawnDirection = "right"

@onready var spawn = $Spawn


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		pass
