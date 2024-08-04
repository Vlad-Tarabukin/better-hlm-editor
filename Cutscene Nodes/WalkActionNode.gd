extends Control

@onready var speed_spin_box = $"Speed SpinBox"
@onready var npc_button = $NPCButton
@onready var positions_item_list = $"Positions ItemList"
@onready var add_point_button = $"Add Point Button"

var action

func _ready():
	custom_minimum_size = Vector2(360, 250)

func initialize(_action):
	action = _action
	action["character"] = action.get("character", "Player")
	action["speed"] = action.get("speed", 1)
	action["positions"] = action.get("positions", [])
	
	npc_button.set_character(action["character"])
	speed_spin_box.value = action["speed"]
	for pos in action["positions"]:
		positions_item_list.add_item(str(pos.x) + " " + str(pos.y))

func _on_speed_spin_box_value_changed(value):
	action["speed"] = value

func _on_npc_button_item_selected(index):
	action["character"] = npc_button.get_character()

func _unhandled_input(event):
	if add_point_button.button_pressed and event is InputEventMouseButton:
		if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
			var pos = GlobalCamera.get_mouse_position()
			pos.x = int(pos.x)
			pos.y = int(pos.y)
			action["positions"].append(pos)
			positions_item_list.add_item(str(pos.x) + " " + str(pos.y))

func _on_delete_point_button_button_up():
	if positions_item_list.is_anything_selected():
		var index = positions_item_list.get_selected_items()[0]
		positions_item_list.remove_item(index)
		action["positions"].remove_at(index)
