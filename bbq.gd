extends Node2D

@onready var spawn_timer = $spawnTimer
const Enemy = preload("res://Enemy_Scene.tscn")

var spawn_count: int = 0
@export var max_spawns: int = 5

func _on_spawn_timer_timeout() -> void:
	if spawn_count >= max_spawns:
		return  # Do nothing once the limit is hit

	var new_enemy = Enemy.instantiate()
	get_parent().add_child(new_enemy)

	new_enemy.global_position = global_position
	spawn_count += 1
