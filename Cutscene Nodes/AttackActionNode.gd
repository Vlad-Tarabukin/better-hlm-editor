extends Control

@onready var character_option_button = $"Character OptionButton"
@onready var manual_check_button = $"Manual CheckButton"
@onready var target_option_button = $"Target OptionButton"
@onready var angle_spin_box = $"Angle SpinBox"
@onready var fire_rate_spin_box = $"Fire Rate SpinBox"

func _ready():
	custom_minimum_size = Vector2(360, 190)

func initialize(action):
	manual_check_button.button_pressed = action["manual"]
	_on_manual_check_button_button_up()
	angle_spin_box.value = action["angle"]
	fire_rate_spin_box.value = action["fire_rate"] * int(action["keep"])

func _on_manual_check_button_button_up():
	target_option_button.visible = manual_check_button.button_pressed
	angle_spin_box.visible = !manual_check_button.button_pressed
