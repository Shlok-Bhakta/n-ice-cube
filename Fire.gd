extends CharacterBody2D

@export var speed := 50
@export var gravity := 4000

var player: CharacterBody2D

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# Chase the player
	if player:
		var dir := (player.global_position - global_position).normalized()
		velocity.x = dir.x * speed  

	move_and_slide()

	#Check if plater is collided or something else
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()

		if collider.is_in_group("player") and not player.jal_power:
			get_tree().reload_current_scene()
