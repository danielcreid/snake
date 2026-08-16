# TODO:
# 1. Save high score
# 2. ...
# 3. Update food sprite, random spawn different foods, give different foods different score values

class_name Gameplay extends Node2D

const GAME_OVER_SCREEN: PackedScene = preload("res://src/menus/GameOverScreen.tscn")
const PAUSE_MENU: PackedScene = preload("res://src/menus/PauseMenu.tscn")

@onready var head = %Head
@onready var tail = %Tail
@onready var spawner = $Spawner
@onready var score_label = %ScoreLabel

@export var speed: float = 4000
@export var speed_increase: float = 200
@export var time_between_moves: float = 1000
@export var time_since_last_move: float = 0
@export var food_value: float = 100

var move_direction: Vector2 = Vector2.UP
var current_move_direction: Vector2 = move_direction
var new_snake_part: SnakePart = null
var snake_parts: Array = []

var game_over_menu: GameOverScreen
var pause_menu: PauseMenu

var direction_priority: Dictionary = {
	"left": 1,
	"right": 2,
	"up": 3,
	"down": 4
}

func sort_direction(a, b) -> bool:
	if direction_priority[a] < direction_priority[b]:
		return true
	return false

var snake_part_sprite_regions: Dictionary = {
	"head_up": Rect2(0, 64, Global.GRID_SIZE, Global.GRID_SIZE),
	"head_right": Rect2(32, 64, Global.GRID_SIZE, Global.GRID_SIZE),
	"head_down": Rect2(64, 64, Global.GRID_SIZE, Global.GRID_SIZE),
	"head_left": Rect2(96, 64, Global.GRID_SIZE, Global.GRID_SIZE),
	"tail_up": Rect2(32, 96, Global.GRID_SIZE, Global.GRID_SIZE),
	"tail_right": Rect2(96, 96, Global.GRID_SIZE, Global.GRID_SIZE),
	"tail_down": Rect2(0, 96, Global.GRID_SIZE, Global.GRID_SIZE),
	"tail_left": Rect2(64, 96, Global.GRID_SIZE, Global.GRID_SIZE),
	"body_left_down": Rect2(64, 32, Global.GRID_SIZE, Global.GRID_SIZE),
	"body_left_up": Rect2(96, 32, Global.GRID_SIZE, Global.GRID_SIZE),
	"body_right_up": Rect2(32, 0, Global.GRID_SIZE, Global.GRID_SIZE),
	"body_right_down": Rect2(0, 0, Global.GRID_SIZE, Global.GRID_SIZE),
	"body_left_right_0": Rect2(96, 0, Global.GRID_SIZE, Global.GRID_SIZE),
	"body_left_right_1": Rect2(32, 32, Global.GRID_SIZE, Global.GRID_SIZE),
	"body_up_down_0": Rect2(64, 0, Global.GRID_SIZE, Global.GRID_SIZE),
	"body_up_down_1": Rect2(0, 32, Global.GRID_SIZE, Global.GRID_SIZE),
}

func _ready() -> void:
	head.food_eaten.connect(_on_food_eaten)
	head.obstacle_hit.connect(_on_obstacle_hit)
	spawner.snake_part_added.connect(_on_snake_part_added)
	
	get_window().focus_exited.connect(_on_window_focus_exited)
	
	time_since_last_move = time_between_moves
	snake_parts.push_back(head)
	snake_parts.push_back(tail)
	spawner.spawn_food(snake_parts)
	
	head.get_node("Sprite2D").texture.region = snake_part_sprite_regions["head_up"]
	tail.get_node("Sprite2D").texture.region = snake_part_sprite_regions["tail_up"]

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

	if Input.is_action_pressed("pause"):
		pause_menu = PAUSE_MENU.instantiate()
		add_child(pause_menu)
		
	# Make sure the new_direction is valid by checking against current_move_direction
	if new_direction + current_move_direction != Vector2.ZERO and new_direction != Vector2.ZERO:
		move_direction = new_direction

func _physics_process(delta) -> void:
	time_since_last_move += speed * delta
	
	if time_since_last_move >= time_between_moves:
		if new_snake_part:
			snake_parts.push_back(new_snake_part)
			new_snake_part = null
		move_snake()
		snake_parts.back().visible = true
		time_since_last_move = 0

func move_snake() -> void:
	var new_position: Vector2 = head.position + move_direction * Global.GRID_SIZE
	head.move_to(new_position)

	# Move each snake part in array to last_position of the part in front of it, including the head
	for i in range(1, snake_parts.size()):
		snake_parts[i].move_to(snake_parts[i-1].last_position)

	# Update current_move_direction to track how the snake is actually moving
	current_move_direction = move_direction
	
	# Update snake part sprites
	update_snake_part_sprites()

func update_snake_part_sprites() -> void:
	var current_part_pos
	var prev_part_pos
	var next_part_pos
	var prev_part_direction
	var next_part_direction
	var direction_array: Array = []
	
	for i in snake_parts.size():
		# Get the current part's position
		current_part_pos = snake_parts[i].position
		
		# If this part is the head, update sprite based on move_direction
		if i == 0:
			match move_direction:
				Vector2.UP:
					snake_parts[i].get_node("Sprite2D").texture.region = snake_part_sprite_regions["head_up"]
				Vector2.RIGHT:
					snake_parts[i].get_node("Sprite2D").texture.region = snake_part_sprite_regions["head_right"]
				Vector2.DOWN:
					snake_parts[i].get_node("Sprite2D").texture.region = snake_part_sprite_regions["head_down"]
				Vector2.LEFT:
					snake_parts[i].get_node("Sprite2D").texture.region = snake_part_sprite_regions["head_left"]
			continue
		
		# If this part is not the head, grab the previous part's position
		prev_part_pos = snake_parts[i-1].position
		
		# Determine which direction the previous part is in relation to the current part
		match (prev_part_pos - current_part_pos) / Global.GRID_SIZE:
			Vector2.UP:
				prev_part_direction = "up"
			Vector2.RIGHT:
				prev_part_direction = "right"
			Vector2.DOWN:
				prev_part_direction = "down"
			Vector2.LEFT:
				prev_part_direction = "left"
		
		# If this part is the tail, update sprite based on where the previous part is
		if i + 1 >= snake_parts.size():
			snake_parts[i].get_node("Sprite2D").texture.region = snake_part_sprite_regions["tail_" + prev_part_direction]
			continue

		# If this part is not the tail, grab the next part's position
		next_part_pos = snake_parts[i+1].position

		# Determine which direction the next part is in relation to the current part
		match (next_part_pos - current_part_pos) / Global.GRID_SIZE:
			Vector2.UP:
				next_part_direction = "up"
			Vector2.RIGHT:
				next_part_direction = "right"
			Vector2.DOWN:
				next_part_direction = "down"
			Vector2.LEFT:
				next_part_direction = "left"

		# Store part directions in array
		direction_array = [
			prev_part_direction,
			next_part_direction
		]
		
		# Sort array to follow direction keyword order 
		direction_array.sort_custom(sort_direction)
		
		# Check to see if the piece is either horizontal or vertical, then choose a corresponding random sprite
		if direction_array.has("left") and direction_array.has("right") or direction_array.has("up") and direction_array.has("down"):
			snake_parts[i].get_node("Sprite2D").texture.region = snake_part_sprite_regions["body_" + direction_array[0] + "_" + direction_array[1] + "_" + str(randi_range(0,1))]
		else:
			# Render the appropriate corner sprite
			snake_parts[i].get_node("Sprite2D").texture.region = snake_part_sprite_regions["body_" + direction_array[0] + "_" + direction_array[1]]

func _on_food_eaten() -> void:
	# Spawn food
	spawner.call_deferred("spawn_food", snake_parts)

	# Call spawn_snake_part() and pass the last_position of the snake part at the end of the snake_parts array
	spawner.call_deferred("spawn_snake_part", snake_parts[snake_parts.size() - 1].last_position)

	# Update score
	Global.score += food_value
	score_label.text = "Score: " + str(snapped(Global.score, 0))

	# Increase speed
	speed += speed_increase

func _on_snake_part_added(snake_part) -> void:
	# Queue up the part to be added during the next movement update
	new_snake_part = snake_part

func _on_obstacle_hit(area) -> void:
	game_over_menu = GAME_OVER_SCREEN.instantiate()
	add_child(game_over_menu)
	# Game Over

func _on_window_focus_exited() -> void:
	pause_menu = PAUSE_MENU.instantiate()
	add_child(pause_menu)
