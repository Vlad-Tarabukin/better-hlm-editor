extends Control

@onready var complete_check_box = $"Complete CheckBox"

var action

func _ready():
	custom_minimum_size = Vector2(360, 80)

func initialize(_action):
	action = _action
	action["scene_complete"] = action.get("scene_complete", false)
	
	complete_check_box.button_pressed = action["scene_complete"]

func _on_complete_check_box_button_up():
	action["scene_complete"] = complete_check_box.button_pressed
