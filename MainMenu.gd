extends Control

@onready var start_button = $StartButton
@onready var quit_button = $QuitButton

func _ready():
	start_button.pressed.connect(_on_start_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _on_start_pressed():
	hide()  # يخفي القائمة
	get_tree().paused = false  # يشغل اللعبة

func _on_quit_pressed():
	get_tree().quit()  # يخرج من اللعبة
