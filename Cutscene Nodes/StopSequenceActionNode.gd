extends Control

@onready var complete_check_box = $"Complete CheckBox"

func _ready():
	custom_minimum_size = Vector2(360, 80)

func initialize(action):
	complete_check_box.button_pressed = action["scene_complete"]
