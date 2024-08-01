extends Control

@onready var delay_spin_box = $"Delay SpinBox"

var action

func _ready():
	custom_minimum_size = Vector2(360, 80)

func initialize(_action):
	action = _action
	action["delay"] = action.get("delay", 0)
	
	delay_spin_box.value = action["delay"] / 60.0

func _on_delay_spin_box_value_changed(value):
	action["delay"] = int(value * 60)
