extends CharacterBody2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

@export var speed: int = 400
@export var gravity: int = 4000
@export var jump_velocity: int = -1200

func _physics_process(delta: float) -> void:
	# Moving our boi Left and Right
	var direction := Input.get_axis("LEFT", "RIGHT")
	if direction != 0:
		if direction < 0:
			anim.play("Left")
		else:
			anim.play("Right")
		velocity.x = direction * speed
	else:
		velocity.x = 0
		anim.play("Idle")
	# You should be able to figure out what this does :)
	if not is_on_floor():
		velocity.y += gravity * delta
		anim.play("Jump")
	# Handle jump
	if Input.is_action_just_pressed("UP") and is_on_floor():
		velocity.y = jump_velocity

	move_and_slide()
