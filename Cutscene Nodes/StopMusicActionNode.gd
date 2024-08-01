extends Control

@onready var fade_spin_box = $"Fade SpinBox"

var action

func _ready():
	custom_minimum_size = Vector2(360, 80)

func initialize(_action):
	action = _action
	action["fade_time"] = action.get("fade_time", 0)
	action["fade"] = action.get("fade", false)
	
	fade_spin_box.value = action["fade_time"] / 60.0 * int(action["fade"])

func _on_fade_spin_box_value_changed(value):
	action["fade_time"] = int(value * 60)
	action["fade"] = value != 0
