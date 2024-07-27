extends Control

@onready var sound_option_button = $"Sound OptionButton"

func _ready():
	custom_minimum_size = Vector2(360, 80)

func initialize(action):
	sound_option_button.selected = sound_option_button.get_item_index(action["sound_id"])
