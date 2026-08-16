class_name StartScreen extends CanvasLayer

const GAMEPLAY_SCENE: PackedScene = preload("res://src/gameplay/gameplay.tscn")

@onready var start: Button = %StartButton
@onready var quit: Button = %QuitButton

func _ready() -> void:
	start.pressed.connect(_on_start_button_pressed)
	quit.pressed.connect(_on_quit_button_pressed)

	if OS.has_feature("web"):
		quit.visible = false

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_packed(GAMEPLAY_SCENE)

func _on_quit_button_pressed() -> void:
	get_tree().quit()
