extends Control

@onready var npc_button = $NPCButton
@onready var sprite_spin_box = $"Sprite SpinBox"

var action

func _ready():
	custom_minimum_size = Vector2(360, 80)

func initialize(_action):
	action = _action
	action["character"] = action.get("character", "Player")
	action["sprite_id"] = action.get("sprite_id", 0)
	
	npc_button.set_character(action["character"])
	sprite_spin_box.value = action["sprite_id"]

func _on_npc_button_item_selected(index):
	action["character"] = npc_button.get_character()

func _on_sprite_spin_box_value_changed(value):
	action["sprite_id"] = value
