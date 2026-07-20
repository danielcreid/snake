class_name Boundary extends Node2D

@onready var top_left: Marker2D = %TopLeft
@onready var bottom_right: Marker2D = %BottomRight

var x_min: float
var x_max: float
var y_min: float
var y_max: float

func _ready() -> void:
	x_min = top_left.position.x
	x_max = bottom_right.position.x
	y_min = top_left.position.y
	y_max = bottom_right.position.y
