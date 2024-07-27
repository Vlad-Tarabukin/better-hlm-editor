extends Control

@onready var name_label = $"Name Label"
@onready var v_box_container = $VBoxContainer
@onready var after_v_box = $"After VBox"

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

func initialize(frame):
	name_label.text = name
	for action in frame["actions"]:
		var action_node = ACTION_NODES[action["action_id"]].instantiate()
		v_box_container.add_child(action_node)
		action_node.initialize(action)
	

func _on_v_box_container_resized():
	custom_minimum_size = Vector2(360, 90 + v_box_container.size.y)
	after_v_box.position.y = 50 + v_box_container.size.y
