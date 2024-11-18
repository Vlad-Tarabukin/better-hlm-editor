extends Control

@onready var speed_spin_box = $"Speed SpinBox"
@onready var npc_button = $NPCButton
@onready var positions_item_list = $"Positions ItemList"
@onready var add_point_button = $"Add Point Button"
@onready var x_spin_box = $"X SpinBox"
@onready var y_spin_box = $"Y SpinBox"

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
			var pos = Waypoints.get_mouse_point(action["positions"][-1] if len(action["positions"]) > 0 else null)
			pos.x = int(pos.x)
			pos.y = int(pos.y)
			action["positions"].append(pos)
			positions_item_list.add_item(str(pos.x) + " " + str(pos.y))
			positions_item_list.select(positions_item_list.item_count - 1)
			if positions_item_list.item_count > 0:
				_on_positions_item_list_item_selected(positions_item_list.item_count - 1)

func _on_delete_point_button_button_up():
	if positions_item_list.is_anything_selected():
		var index = positions_item_list.get_selected_items()[0]
		positions_item_list.remove_item(index)
		action["positions"].remove_at(index)
		positions_item_list.select(positions_item_list.item_count - 1)
		if positions_item_list.item_count > 0:
			_on_positions_item_list_item_selected(positions_item_list.item_count - 1)

func _on_positions_item_list_item_selected(index):
	x_spin_box.value = action["positions"][index].x
	y_spin_box.value = action["positions"][index].y
	App.waypoints.visible = true
	App.waypoints.points = action["positions"]
	App.waypoints.selected = index

func _on_x_spin_box_value_changed(value):
	if positions_item_list.is_anything_selected():
		var index = positions_item_list.get_selected_items()[0]
		action["positions"][index].x = value
		positions_item_list.set_item_text(index, str(action["positions"][index].x) + " " + str(action["positions"][index].y))

func _on_y_spin_box_value_changed(value):
	if positions_item_list.is_anything_selected():
		var index = positions_item_list.get_selected_items()[0]
		action["positions"][index].y = value
		positions_item_list.set_item_text(index, str(action["positions"][index].x) + " " + str(action["positions"][index].y))

func _on_add_point_button_toggled(toggled_on):
	App.waypoints.visible = toggled_on or positions_item_list.is_anything_selected()
	App.waypoints.mouse = toggled_on
	if toggled_on:
		App.waypoints.points = action["positions"]
