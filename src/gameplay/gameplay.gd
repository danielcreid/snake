# TODO:
# 2. Set up score tracking
# 3. Start and Game Over screens
# 4. Save high score
# 5. Pause state
# 6. ...
# 7. Do cool ass art + animations (continuous snake where the parts are aware of how the snake is twisted/turned)

class_name Gameplay extends Node2D

@onready var head = %Head
@onready var spawner = $Spawner

@export var speed: float = 5000
@export var time_between_moves: float = 1000
@export var time_since_last_move: float = 0

var move_direction: Vector2 = Vector2.UP
var current_move_direction: Vector2 = move_direction
var snake_parts: Array = []

func _ready() -> void:	
	head.food_eaten.connect(_on_food_eaten)
	head.obstacle_hit.connect(_on_obstacle_hit)
	spawner.snake_part_added.connect(_on_snake_part_added)
	
	time_since_last_move = time_between_moves
	snake_parts.push_back(head)
	spawner.spawn_food(snake_parts)

func _process(_delta: float) -> void:
	var new_direction: Vector2 = Vector2.ZERO
	
	if Input.is_action_pressed("move_up"):
		new_direction = Vector2.UP
	if Input.is_action_pressed("move_right"):
		new_direction = Vector2.RIGHT
	if Input.is_action_pressed("move_down"):
		new_direction = Vector2.DOWN
	if Input.is_action_pressed("move_left"):
		new_direction = Vector2.LEFT

	# Make sure the new_direction is valid by checking against current_move_direction
	if new_direction + current_move_direction != Vector2.ZERO and new_direction != Vector2.ZERO:
		move_direction = new_direction



func _physics_process(delta) -> void:
	time_since_last_move += speed * delta
	
	if time_since_last_move >= time_between_moves:
		update_snake()
		time_since_last_move = 0

func update_snake() -> void:
	var new_position: Vector2 = head.position + move_direction * Global.GRID_SIZE
	head.move_to(new_position)
	
	# Move each snake part in array to last_position of the part in front of it, including the head
	for i in range(1, snake_parts.size()):
		snake_parts[i].move_to(snake_parts[i-1].last_position)

	# Update current_move_direction to track how the snake is actually moving
	current_move_direction = move_direction

func _on_food_eaten() -> void:
	# Spawn food
	spawner.call_deferred("spawn_food", snake_parts)

	# Call spawn_snake_part() and pass the last_position of the snake part at the end of the snake_parts array
	spawner.call_deferred("spawn_snake_part", snake_parts[snake_parts.size() - 1].last_position)

	# Update score

func _on_snake_part_added(snake_part) -> void:
	# Add new snake part to the end of the snake_parts array
	snake_parts.push_back(snake_part)

func _on_obstacle_hit(area) -> void:
	print("Obstacle hit: ", area)
	# Game Over
