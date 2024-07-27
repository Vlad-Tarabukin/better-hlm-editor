extends Control

@onready var character_option_button = $"Character OptionButton"
@onready var angle_spin_box = $"Angle SpinBox"
@onready var animate_check_box = $"Animate CheckBox"

func _ready():
	custom_minimum_size = Vector2(360, 120)

func initialize(action):
	angle_spin_box.value = action["angle"]
	animate_check_box.button_pressed = action["animate"]
