class_name Head extends SnakePart

signal food_eaten
signal obstacle_hit(obstacle)

func _ready() -> void:
	self.area_entered.connect(_on_collision)
	self.body_entered.connect(_on_collision)

func _on_collision(object) -> void:
	if object.is_in_group("food"):
		food_eaten.emit()
		object.call_deferred("queue_free")
	else:
		obstacle_hit.emit(object)
