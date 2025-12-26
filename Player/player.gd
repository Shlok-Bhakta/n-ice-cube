extends CharacterBody2D

@export var speed: int = 400
@export var gravity: int = 4000
@export var jump_velocity: int = -1200
@export var climb_speed: int = 150

var wall_climb_enabled := false
var jal_power = false
var on_wall := false

func _ready() -> void:
	add_to_group("can_interact_with_water")
	add_to_group("player")

func enable_wall_climb():
	wall_climb_enabled = true
	
func enable_jal_power():
	jal_power = true

func _physics_process(delta: float) -> void:
		# Left / Right movement
	var direction := Input.get_axis("LEFT", "RIGHT")
	velocity.x = direction * speed

		# Gravity
	if not is_on_floor():
		velocity.y += gravity * delta

		# Jump
	if Input.is_action_just_pressed("UP") and is_on_floor():
		velocity.y = jump_velocity

		# Check walls
	on_wall = is_on_wall()

	 # Wall climbing
	if wall_climb_enabled and on_wall:
	 # cancel gravity
		velocity.y = 0

		var vertical := 0.0
		if Input.is_action_pressed("UP"):
			vertical -= 1
		if Input.is_action_pressed("DOWN"):
			vertical += 1

		velocity.y = vertical * climb_speed

	move_and_slide()



func _on_climbing_claws_picked_up() -> void:
	enable_wall_climb()


func _on_jalapeno_jal_picked_up() -> void:
	enable_jal_power()
