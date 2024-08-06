extends Control

@onready var npc_button = $NPCButton
@onready var angle_spin_box = $"Angle SpinBox"
@onready var animate_check_box = $"Animate CheckBox"

var action

func _ready():
	custom_minimum_size = Vector2(360, 120)

func initialize(_action):
	action = _action
	action["character"] = action.get("character", "Player")
	action["angle"] = action.get("angle", 0)
	action["animate"] = action.get("animate", false)
	
	npc_button.set_character(action["character"])
	angle_spin_box.value = action["angle"]
	animate_check_box.button_pressed = action["animate"]

func _on_npc_button_item_selected(index):
	action["character"] = npc_button.get_character()

func _on_angle_spin_box_value_changed(value):
	action["angle"] = value

func _on_animate_check_box_button_up():
	action["animate"] = animate_check_box.button_pressed
