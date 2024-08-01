extends Control

@onready var first_line_edit = $"First LineEdit"
@onready var second_line_edit = $"Second LineEdit"
@onready var texture_rect = $TextureRect
@onready var face_option_button = $"Face OptionButton"
@onready var face_spin_box = $"Face SpinBox"
@onready var messages_item_list = $"Messages ItemList"
@onready var focus_npc_button = $"Focus NPCButton"
@onready var timer = $Timer

var action

var face_frames
var face_frame = 0

func _ready():
	custom_minimum_size = Vector2(360, 320)

func initialize(_action):
	action = _action
	action["messages"] = action.get("messages", [])
	for message in action["messages"]:
		messages_item_list.add_item(message["first_line"])
	check_editable()
	timer.start(0.1)

func _on_messages_item_list_item_selected(index):
	check_editable()
	first_line_edit.text = action["messages"][index]["first_line"]
	second_line_edit.text = action["messages"][index]["second_line"]
	face_option_button.select(face_option_button.get_item_index(action["messages"][index]["sprite_id"]))
	face_spin_box.value = action["messages"][index]["sprite_id"]
	focus_npc_button.set_character(action["messages"][index]["character"])

func _on_face_option_button_item_selected(index):
	face_spin_box.value = face_option_button.get_item_id(index)

func _on_face_spin_box_value_changed(value):
	action["messages"][messages_item_list.get_selected_items()[0]]["sprite_id"] = value
	face_frames = ObjectsLoader.get_sprite(int(value))["frames"]
	face_frame = 0
	refresh_frame()

func refresh_frame():
	if face_frames and len(face_frames) > 0:
		texture_rect.texture = face_frames[face_frame]
		face_frame = (face_frame + 1) % len(face_frames)

func _on_first_line_edit_text_changed(new_text):
	action["messages"][messages_item_list.get_selected_items()[0]]["first_line"] = new_text
	messages_item_list.set_item_text(messages_item_list.get_selected_items()[0], " " + new_text)

func _on_second_line_edit_text_changed(new_text):
	action["messages"][messages_item_list.get_selected_items()[0]]["second_line"] = new_text

func _on_focus_npc_button_item_selected(index):
	action["messages"][messages_item_list.get_selected_items()[0]]["character"] = focus_npc_button.get_character()

func check_editable():
	first_line_edit.editable = messages_item_list.is_anything_selected()
	second_line_edit.editable = messages_item_list.is_anything_selected()
	face_option_button.disabled = !messages_item_list.is_anything_selected()
	face_spin_box.editable = messages_item_list.is_anything_selected()
	if !messages_item_list.is_anything_selected():
		face_frames = null
		refresh_frame()

func _on_add_message_button_button_up():
	action["messages"].append({
		"first_line": "",
		"second_line": "",
		"sprite_id": 500,
		"character": "Player"
	})
	messages_item_list.add_item("New message")

func _on_delete_message_button_button_up():
	if messages_item_list.is_anything_selected():
		action["messages"].remove_at(messages_item_list.get_selected_items()[0])
		messages_item_list.remove_item(messages_item_list.get_selected_items()[0])
		messages_item_list.deselect_all()
		check_editable()

func _on_messages_item_list_focus_exited():
	check_editable()
