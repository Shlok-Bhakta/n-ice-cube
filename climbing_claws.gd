extends Area2D

signal picked_up

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("player"): 
		picked_up.emit()
		queue_free()
