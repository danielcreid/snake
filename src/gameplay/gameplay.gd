# TODO:
# 2. Set up score tracking
# 3. Start and Game Over screens
# 4. Save high score
# 5. Pause state
# 6. ...
# 7. Do cool ass art + animations (continuous snake where the parts are aware of how the snake is twisted/turned)

class_name Gameplay extends Node2D

@onready var head = %Head
@onready var tail = %Tail
@onready var spawner = $Spawner

@export var speed: float = 5000
@export var time_between_moves: float = 1000
@export var time_since_last_move: float = 0

var move_direction: Vector2 = Vector2.UP
var current_move_direction: Vector2 = move_direction
var snake_parts: Array = []

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
	#"body_up_down": Rect2(64, 0, Global.GRID_SIZE, Global.GRID_SIZE),
	"body_up_down_0": Rect2(64, 0, Global.GRID_SIZE, Global.GRID_SIZE),
	"body_up_down_1": Rect2(0, 32, Global.GRID_SIZE, Global.GRID_SIZE),
}

func _ready() -> void:
	head.food_eaten.connect(_on_food_eaten)
	head.obstacle_hit.connect(_on_obstacle_hit)
	spawner.snake_part_added.connect(_on_snake_part_added)
	
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
	
	# Swap head sprite based on move direction... very specific and probably can be done differently
	match move_direction:
		Vector2.UP:
			head.get_node("Sprite2D").texture.region = snake_part_sprite_regions["head_up"]
		Vector2.RIGHT:
			head.get_node("Sprite2D").texture.region = snake_part_sprite_regions["head_right"]
		Vector2.DOWN:
			head.get_node("Sprite2D").texture.region = snake_part_sprite_regions["head_down"]
		Vector2.LEFT:
			head.get_node("Sprite2D").texture.region = snake_part_sprite_regions["head_left"]
	
	# Move each snake part in array to last_position of the part in front of it, including the head
	for i in range(1, snake_parts.size()):
		snake_parts[i].move_to(snake_parts[i-1].last_position)
	
	for i in range(1, snake_parts.size()):
		var current_part_pos = snake_parts[i].position
		var prev_part_pos = snake_parts[i-1].position
		var next_part_pos
		var prev_part_direction
		var next_part_direction
		var direction_array: Array
		
		if i + 1 < snake_parts.size():
			next_part_pos = snake_parts[i+1].position
		
		prev_part_direction = (prev_part_pos - current_part_pos) / Global.GRID_SIZE
		
		if next_part_pos:
			next_part_direction = (next_part_pos - current_part_pos) / Global.GRID_SIZE
		else:
			next_part_direction = null

		match prev_part_direction:
			Vector2.UP:
				prev_part_direction = "up"
			Vector2.RIGHT:
				prev_part_direction = "right"
			Vector2.DOWN:
				prev_part_direction = "down"
			Vector2.LEFT:
				prev_part_direction = "left"
		
		match next_part_direction:
			Vector2.UP:
				next_part_direction = "up"
			Vector2.RIGHT:
				next_part_direction = "right"
			Vector2.DOWN:
				next_part_direction = "down"
			Vector2.LEFT:
				next_part_direction = "left"
		
		direction_array = [
			prev_part_direction,
			next_part_direction
		]
		
		if next_part_direction:
			direction_array.sort_custom(sort_direction)
			
			if direction_array.has("left") and direction_array.has("right") or direction_array.has("up") and direction_array.has("down"):
				snake_parts[i].get_node("Sprite2D").texture.region = snake_part_sprite_regions["body_" + direction_array[0] + "_" + direction_array[1] + "_" + str(randi_range(0,1))]
			else:
				snake_parts[i].get_node("Sprite2D").texture.region = snake_part_sprite_regions["body_" + direction_array[0] + "_" + direction_array[1]]
		else:
			snake_parts[i].get_node("Sprite2D").texture.region = snake_part_sprite_regions["tail_" + prev_part_direction]

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
	
	## TODO: This prevents the wrong sprite from showing before update_snake() gets called normally, but adding here moves the snake prematurely, so it looks like it gets a boost of speed.
	update_snake()

func _on_obstacle_hit(area) -> void:
	print("Obstacle hit: ", area)
	# Game Over
