class_name Gameplay extends Node2D

const GRID_SIZE: int = 32

@onready var top_left = %TopLeft
@onready var bottom_right = %BottomRight
@onready var head = $Head
@onready var food = $Food

@export var speed: float = 5000
@export var time_between_moves: float = 1000
@export var time_since_last_move: float = 0

var move_direction: Vector2 = Vector2.UP



func _process(delta: float) -> void:
	var new_direction: Vector2 = Vector2.ZERO
	
	if Input.is_action_pressed("move_up"):
		new_direction = Vector2.UP
	if Input.is_action_pressed("move_right"):
		new_direction = Vector2.RIGHT
	if Input.is_action_pressed("move_down"):
		new_direction = Vector2.DOWN
	if Input.is_action_pressed("move_left"):
		new_direction = Vector2.LEFT

	if new_direction + move_direction != Vector2.ZERO and new_direction != Vector2.ZERO:
		move_direction = new_direction



func _physics_process(delta) -> void:
	time_since_last_move += speed * delta
	
	if time_since_last_move >= time_between_moves:
		#TODO: Extract this movement into a function that head and body can use
		var new_position: Vector2 = head.position + move_direction * GRID_SIZE
		head.position = new_position
		time_since_last_move = 0
