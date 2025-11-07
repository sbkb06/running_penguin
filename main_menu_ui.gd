extends CanvasLayer

@onready var start_button = $MenuUI/VBoxContainer/StartButton
@onready var quit_button = $MenuUI/VBoxContainer/QuitButton

func _ready():
	start_button.pressed.connect(_on_start_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _on_start_pressed():
	Global.game_started_flag = true  # يبدأ اللعب هون فقط
	hide()  # يخفي القائمة

func _on_quit_pressed():
	get_tree().quit()
