extends Control

@onready var npc_button = $NPCButton
@onready var angle_spin_box = $"Angle SpinBox"
@onready var animate_check_box = $"Animate CheckBox"

func _ready():
	custom_minimum_size = Vector2(360, 120)

func initialize(action):
	npc_button.set_character(action["character"])
	angle_spin_box.value = action["angle"]
	animate_check_box.button_pressed = action["animate"]
