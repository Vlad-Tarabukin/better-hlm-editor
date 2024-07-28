extends Control

@onready var npc_button = $NPCButton
@onready var sprite_spin_box = $"Sprite SpinBox"

func _ready():
	custom_minimum_size = Vector2(360, 80)

func initialize(action):
	npc_button.set_character(action["character"])
	sprite_spin_box.value = action["sprite_id"]
