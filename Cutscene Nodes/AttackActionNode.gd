extends Control

@onready var npc_button = $NPCButton
@onready var manual_check_button = $"Manual CheckButton"
@onready var target_npc_button = $"Target NPCButton"
@onready var angle_spin_box = $"Angle SpinBox"
@onready var fire_rate_spin_box = $"Fire Rate SpinBox"

var action

func _ready():
	custom_minimum_size = Vector2(360, 190)

func initialize(_action):
	action = _action
	action["character"] = action.get("character", "Player")
	action["manual"] = action.get("manual", false)
	action["target"] = action.get("target", "Player")
	action["angle"] = action.get("angle", 0)
	action["fire_rate"] = action.get("fire_rate", 0)
	action["keep"] = action.get("keep", false)
	
	npc_button.set_character(action["character"])
	manual_check_button.button_pressed = action["manual"]
	_on_manual_check_button_button_up()
	target_npc_button.set_character(action["target"])
	angle_spin_box.value = action["angle"]
	fire_rate_spin_box.value = action["fire_rate"] * int(action["keep"])

func _on_manual_check_button_button_up():
	action["manual"] = manual_check_button.button_pressed
	target_npc_button.visible = manual_check_button.button_pressed
	angle_spin_box.visible = !manual_check_button.button_pressed

func _on_npc_button_item_selected(index):
	action["character"] = npc_button.get_character()

func _on_target_npc_button_item_selected(index):
	action["target"] = target_npc_button.get_character()

func _on_angle_spin_box_value_changed(value):
	action["angle"] = value

func _on_fire_rate_spin_box_value_changed(value):
	action["fire_rate"] = value
	action["keep"] = value != 0
