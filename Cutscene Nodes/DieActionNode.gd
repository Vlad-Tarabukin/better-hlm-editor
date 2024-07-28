extends Control

@onready var npc_button = $NPCButton
@onready var reason_option_button = $"Reason OptionButton"
@onready var delay_spin_box = $"Delay SpinBox"

func _ready():
	custom_minimum_size = Vector2(360, 120)

func initialize(action):
	npc_button.set_character(action["character"])
	reason_option_button.selected = action["reason"]
	delay_spin_box.value = action["delay"] / 60
