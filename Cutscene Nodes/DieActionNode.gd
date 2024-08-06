extends Control

@onready var npc_button = $NPCButton
@onready var reason_option_button = $"Reason OptionButton"
@onready var delay_spin_box = $"Delay SpinBox"

var action

func _ready():
	custom_minimum_size = Vector2(360, 120)

func initialize(_action):
	action = _action
	action["character"] = action.get("character", "Player")
	action["reason"] = action.get("reason", 0)
	action["delay"] = action.get("delay", 0)
	
	npc_button.set_character(action["character"])
	reason_option_button.selected = action["reason"]
	delay_spin_box.value = action["delay"] / 60.0

func _on_npc_button_item_selected(index):
	action["character"] = npc_button.get_character()

func _on_reason_option_button_item_selected(index):
	action["reason"] = index

func _on_delay_spin_box_value_changed(value):
	action["delay"] = int(value * 60)
