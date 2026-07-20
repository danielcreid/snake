class_name SnakePart extends Node

var last_position: Vector2

func move_to(new_position) -> void:
	last_position = self.position
	self.position = new_position
