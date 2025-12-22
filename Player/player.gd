extends Sprite2D

@export var speed: float = 10
@export var gravity: float = 2
@export var terminalVelocity: float = 30


var velocity_down = Vector2.ZERO
func _physics_process(delta):
	velocity_down -= Vector2(0, gravity)
	if velocity_down.y > terminalVelocity:
		velocity_down = Vector2(0, terminalVelocity)
	position += Vector2.DOWN - velocity_down

func _input(event: InputEvent) -> void:
	if event.is_action("UP"):
		velocity_down = Vector2.DOWN * speed
		position += Vector2.UP * speed
	elif event.is_action("DOWN"):
		position += Vector2.DOWN * speed
	elif event.is_action("LEFT"):
		position += Vector2.LEFT * speed
	elif event.is_action("RIGHT"):
		position += Vector2.RIGHT * speed
