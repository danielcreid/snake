class_name GameOverScreen extends CanvasLayer

@onready var restart: Button = %RestartButton
@onready var quit: Button = %QuitButton

func _ready() -> void:
	restart.pressed.connect(_on_restart_button_pressed)
	quit.pressed.connect(_on_quit_button_pressed)
	
	if OS.has_feature("web"):
		quit.visible = false

func _on_restart_button_pressed() -> void:
	get_tree().reload_current_scene()
	Global.score = 0

func _on_quit_button_pressed() -> void:
	get_tree().quit()

# Pause based on when GameOverScene enters or exits the tree
func _notification(what):
	match what:
		NOTIFICATION_ENTER_TREE:
			get_tree().paused = true
		NOTIFICATION_EXIT_TREE:
			get_tree().paused = false
