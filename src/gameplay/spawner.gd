class_name Spawner extends Node

signal snake_part_added(snake_part)

@export var boundary: Boundary

var food_scene: PackedScene = preload("res://src/gameplay/Food.tscn")
var body_scene: PackedScene = preload("res://src/gameplay/Body.tscn")

func spawn_food() -> void:
	var spawn_point: Vector2 = Vector2.ZERO
	spawn_point.x = snapped(randf_range(boundary.x_min, boundary.x_max - Global.GRID_SIZE), Global.GRID_SIZE)
	spawn_point.y = snapped(randf_range(boundary.y_min, boundary.y_max - Global.GRID_SIZE), Global.GRID_SIZE)

	var food = food_scene.instantiate()
	food.position = spawn_point
	get_parent().add_child(food)

func spawn_snake_part(position: Vector2) -> void:
	var snake_part: Body = body_scene.instantiate() as Body
	snake_part.position = position
	get_parent().add_child(snake_part)
	snake_part_added.emit(snake_part)
