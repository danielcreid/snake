class_name Spawner extends Node

signal snake_part_added(snake_part)

@export var boundary: Boundary

var food_scene: PackedScene = preload("res://src/gameplay/Food.tscn")
var snake_part_scene: PackedScene = preload("res://src/gameplay/SnakePart.tscn")

func spawn_food(snake_parts) -> void:
	# Generate spawn point
	var spawn_point: Vector2 = generate_spawn_point()
	
	# Validate that the generated spawn point doesn't overlap with any snake part
	while not is_spawn_point_valid(spawn_point, snake_parts):
		# If invalid, generate new spawn point
		spawn_point = generate_spawn_point()

	# If valid spawn point, instantiate the scene and add to the tree
	var food = food_scene.instantiate()
	food.position = spawn_point
	get_parent().add_child(food)

func generate_spawn_point() -> Vector2:
	var spawn_point: Vector2 = Vector2.ZERO
	spawn_point.x = snapped(randf_range(boundary.x_min, boundary.x_max - Global.GRID_SIZE), Global.GRID_SIZE)
	spawn_point.y = snapped(randf_range(boundary.y_min, boundary.y_max - Global.GRID_SIZE), Global.GRID_SIZE)
	return spawn_point

func is_spawn_point_valid(spawn_point, snake_parts) -> bool:
	# Loop through eacn part's position and compare against the generated spawn point
	# If match, return false and generate a new spawn point
	for part in snake_parts:
		if part.position == spawn_point:
			return false
	return true

func spawn_snake_part(position: Vector2) -> void:
	var snake_part: SnakePart = snake_part_scene.instantiate() as SnakePart
	snake_part.position = position
	snake_part.visible = false # Hide snake part by default; make visible after snake moves
	get_parent().add_child(snake_part)
	snake_part_added.emit(snake_part)
