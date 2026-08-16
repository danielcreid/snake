class_name PauseMenu extends CanvasLayer

@onready var resume: Button = %ResumeButton
@onready var quit: Button = %QuitButton

func _ready() -> void:
	resume.pressed.connect(_on_resume_button_pressed)
	quit.pressed.connect(_on_quit_button_pressed)
	
	if OS.has_feature("web"):
		quit.visible = false

func _on_resume_button_pressed() -> void:
	hide()
	get_tree().paused = false

func _on_quit_button_pressed() -> void:
	get_tree().quit()

# Pause based on when PauseMenu enters or exits the tree
func _notification(what):
	match what:
		NOTIFICATION_ENTER_TREE:
			get_tree().paused = true
