extends Control

@onready var speed_spin_box = $"Speed SpinBox"
@onready var npc_button = $NPCButton
@onready var positions_item_list = $"Positions ItemList"

func _ready():
	custom_minimum_size = Vector2(360, 220)

func initialize(action):
	npc_button.set_character(action["character"])
	speed_spin_box.value = action["speed"]
	for pos in action["positions"]:
		positions_item_list.add_item(str(pos.x) + " " + str(pos.y))
