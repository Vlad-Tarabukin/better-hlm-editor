extends Control

@onready var name_label = $"Name Label"
@onready var v_box_container = $VBoxContainer
@onready var after_v_box = $"After VBox"
@onready var action_option_button = $"After VBox/Action OptionButton"

const ACTION_NODES = [
	preload("res://Cutscene Nodes/walk_action_node.tscn"),
	preload("res://Cutscene Nodes/dialogue_action_node.tscn"),
	preload("res://Cutscene Nodes/change_sprite_action_node.tscn"),
	preload("res://Cutscene Nodes/animation_action_node.tscn"),
	preload("res://Cutscene Nodes/attack_action_node.tscn"),
	preload("res://Cutscene Nodes/wait_action_node.tscn"),
	preload("res://Cutscene Nodes/die_action_node.tscn"),
	preload("res://Cutscene Nodes/play_sound_action_node.tscn"),
	preload("res://Cutscene Nodes/play_music_action_node.tscn"),
	preload("res://Cutscene Nodes/stop_music_action_node.tscn"),
	preload("res://Cutscene Nodes/stop_sequence_action_node.tscn"),
	preload("res://Cutscene Nodes/next_level_action_node.tscn"),
	preload("res://Cutscene Nodes/activate_item_action_node.tscn"),
	preload("res://Cutscene Nodes/rotate_action_node.tscn")
]

const DEFAULT_ACTIONS = [
	{
		"action_id": 0,
		"speed": 1,
		"positions": [],
		"character": "Player"
	},
	{
		"action_id": 1,
		"messages": []
	},
	{
		"action_id": 2,
		"sprite_id": 0,
		"character": "Player"
	},
	{
		"action_id": 3,
		"character": "Player",
		"loop": false,
		"interval": 0,
		"freely": false,
		"stop": false
	},
	{
		"action_id": 4,
		"character": "Player",
		"manual": false,
		"angle": 0,
		"target": "Player",
		"keep": false,
		"fire_rate": 10
	},
	{
		"action_id": 5,
		"delay": 0
	},
	{
		"action_id": 6,
		"character": "Player",
		"reason": 0,
		"delay": 0
	},
	{
		"action_id": 7,
		"sound_id": 3
	},
	{
		"action_id": 8,
		"music_name": "beams.mp3"
	},
	{
		"action_id": 9,
		"fade": false,
		"fade_time": 0
	},
	{
		"action_id": 10,
		"scene_complete": false
	},
	{
		"action_id": 11,
		"fade": false,
		"fade_time": 0
	},
	{
		"action_id": 12,
		"item": "",
		"active": true,
		"visible": true
	},
	{
		"action_id": 13,
		"character": "Player",
		"angle": 0,
		"animate": false
	}
]


func initialize(frame):
	name_label.text = name
	for action in frame["actions"]:
		var action_node = ACTION_NODES[action["action_id"]].instantiate()
		v_box_container.add_child(action_node)
		action_node.initialize(action)

func _on_v_box_container_resized():
	custom_minimum_size = Vector2(360, 90 + v_box_container.size.y)
	after_v_box.position.y = 50 + v_box_container.size.y

func refresh_action_nodes():
	for child in v_box_container.get_children():
		child.queue_free()
	for action in App.get_current_floor().cutscene["frames"][get_index()]["actions"]:
		var action_node = ACTION_NODES[action["action_id"]].instantiate()
		v_box_container.add_child(action_node)
		action_node.initialize(action)

func _on_create_action_button_button_up():
	App.get_current_floor().cutscene["frames"][get_index()]["actions"].append(DEFAULT_ACTIONS[action_option_button.selected])
	refresh_action_nodes()
