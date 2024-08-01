extends Control

@onready var loop_check_box = $"Loop CheckBox"
@onready var freely_check_box = $"Freely CheckBox"
@onready var stop_check_box = $"Stop CheckBox"
@onready var interval_spin_box = $"Interval SpinBox"
@onready var npc_button = $NPCButton

var action

func _ready():
	custom_minimum_size = Vector2(360, 120)

func initialize(_action):
	action = _action
	action["loop"] = action.get("loop", false)
	action["freely"] = action.get("freely", false)
	action["stop"] = action.get("stop", false)
	action["interval"] = action.get("interval", 0)
	action["character"] = action.get("character", "Player")
	
	loop_check_box.button_pressed = action["loop"]
	freely_check_box.button_pressed = action["freely"]
	stop_check_box.button_pressed = action["stop"]
	interval_spin_box.value = action["interval"] / 60.0
	npc_button.set_character(action["character"])

func _on_stop_check_box_button_up():
	loop_check_box.disabled = stop_check_box.button_pressed
	freely_check_box.disabled = stop_check_box.button_pressed
	interval_spin_box.editable = !stop_check_box.button_pressed
	if stop_check_box.button_pressed:
		loop_check_box.button_pressed = false
		action["loop"] = false
		freely_check_box.button_pressed = false
		action["freely"] = false

func _on_loop_check_box_button_up():
	action["loop"] = loop_check_box.button_pressed
	interval_spin_box.editable = loop_check_box.button_pressed

func _on_freely_check_box_button_up():
	action["freely"] = freely_check_box.button_pressed

func _on_interval_spin_box_value_changed(value):
	action["interval"] = int(value * 60)

func _on_npc_button_item_selected(index):
	action["character"] = npc_button.get_character()

func refresh_action():
	action
