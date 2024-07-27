extends Control

@onready var speed_spin_box = $"Speed SpinBox"
@onready var character_option_button = $"Character OptionButton"
@onready var positions_item_list = $"Positions ItemList"

func _ready():
	custom_minimum_size = Vector2(360, 220)

func initialize(action):
	speed_spin_box.value = action["speed"]
	for pos in action["positions"]:
		positions_item_list.add_item(str(pos.x) + " " + str(pos.y))
