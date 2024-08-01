extends Control

@onready var sound_option_button = $"Sound OptionButton"

var action

func _ready():
	custom_minimum_size = Vector2(360, 80)

func initialize(_action):
	action = _action
	action["sound_id"] = action.get("sound_id", 3)
	
	sound_option_button.selected = sound_option_button.get_item_index(action["sound_id"])

func _on_sound_option_button_item_selected(index):
	action["sound_id"] = sound_option_button.get_item_id(index)
