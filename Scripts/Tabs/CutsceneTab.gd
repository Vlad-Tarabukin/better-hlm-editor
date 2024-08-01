extends TabBar

class_name CutsceneTab

const TAB_INDEX = 5
const FRAME_NODE = preload("res://Cutscene Nodes/frame_node.tscn")

@onready var v_box_container = $TabContainer/Cutscene/ScrollContainer/VBoxContainer

var active
var last_floor

func _process(delta):
	if active and last_floor != App.level:
		last_floor = App.level
		refresh_frames()

func refresh_frames():
	for child in v_box_container.get_children():
		child.queue_free()
	for i in range(len(App.get_current_floor().cutscene["frames"])):
		var frame_node = FRAME_NODE.instantiate()
		v_box_container.add_child(frame_node)
		frame_node.initialize(App.get_current_floor().cutscene["frames"][i], i)

func _on_tab_container_tab_selected(tab):
	active = tab == TAB_INDEX

func _on_add_frame_button_button_up():
	App.get_current_floor().cutscene["frames"].append({
		"actions": [],
		"focus": "Player"
	})
	refresh_frames()
