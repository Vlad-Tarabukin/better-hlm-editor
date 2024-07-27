extends Control

@onready var first_line_edit = $"First LineEdit"
@onready var second_line_edit = $"Second LineEdit"
@onready var texture_rect = $TextureRect
@onready var face_option_button = $"Face OptionButton"
@onready var face_spin_box = $"Face SpinBox"
@onready var messages_item_list = $"Messages ItemList"
@onready var focus_option_button = $"Focus OptionButton"
@onready var timer = $Timer

var messages = []
var face_frames
var face_frame = 0

func _ready():
	custom_minimum_size = Vector2(360, 320)

func initialize(action):
	messages = action["messages"]
	for message in messages:
		messages_item_list.add_item(message["first_line"])
	messages_item_list.select(0)
	_on_messages_item_list_item_selected(0)
	timer.start(0.1)

func _on_messages_item_list_item_selected(index):
	first_line_edit.text = messages[index]["first_line"]
	second_line_edit.text = messages[index]["second_line"]
	face_option_button.select(face_option_button.get_item_index(messages[index]["sprite_id"]))
	face_spin_box.value = messages[index]["sprite_id"]

func _on_face_option_button_item_selected(index):
	face_spin_box.value = face_option_button.get_item_id(index)

func _on_face_spin_box_value_changed(value):
	face_frames = ObjectsLoader.get_sprite(int(value))["frames"]
	face_frame = 0
	refresh_frame()

func refresh_frame():
	if face_frames and len(face_frames) > 0:
		texture_rect.texture = face_frames[face_frame]
		face_frame = (face_frame + 1) % len(face_frames)
