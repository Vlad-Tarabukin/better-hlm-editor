extends Control

@onready var item_option_button = $"Item OptionButton"
@onready var active_check_box = $"Active CheckBox"
@onready var visible_check_box = $"Visible CheckBox"

func _ready():
	custom_minimum_size = Vector2(360, 120)

func initialize(action):
	active_check_box.button_pressed = action["active"]
	visible_check_box.button_pressed = action["visible"]
