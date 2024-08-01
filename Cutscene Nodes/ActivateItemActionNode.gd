extends Control

@onready var item_option_button = $"Item OptionButton"
@onready var active_check_box = $"Active CheckBox"
@onready var visible_check_box = $"Visible CheckBox"

var action

func _ready():
	custom_minimum_size = Vector2(360, 120)
	for item in App.get_current_floor().cutscene["items"].keys():
		item_option_button.add_item(item)

func initialize(_action):
	action = _action
	action["active"] = action.get("active", true)
	action["visible"] = action.get("visible", true)
	action["item"] = action.get("item", null)
	
	active_check_box.button_pressed = action["active"]
	visible_check_box.button_pressed = action["visible"]
	for i in range(item_option_button.item_count):
		if item_option_button.get_item_text(i) == action["item"]:
			item_option_button.selected = 1
			return

func _on_item_option_button_item_selected(index):
	action["item"] = item_option_button.get_item_text(index)

func _on_active_check_box_button_up():
	action["item"]
