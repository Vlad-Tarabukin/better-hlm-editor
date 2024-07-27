extends Control

@onready var loop_check_box = $"Loop CheckBox"
@onready var freely_check_box = $"Freely CheckBox"
@onready var stop_check_box = $"Stop CheckBox"
@onready var interval_spin_box = $"Interval SpinBox"
@onready var character_option_button = $"Character OptionButton"

func _ready():
	custom_minimum_size = Vector2(360, 120)

func initialize(action):
	loop_check_box.button_pressed = action["loop"]
	freely_check_box.button_pressed = action["freely"]
	stop_check_box.button_pressed = action["stop"]
	interval_spin_box.value = action["interval"] / 60.0

func _on_stop_check_box_button_up():
	loop_check_box.disabled = stop_check_box.button_pressed
	freely_check_box.disabled = stop_check_box.button_pressed
	interval_spin_box.editable = !stop_check_box.button_pressed

func _on_loop_check_box_button_up():
	interval_spin_box.editable = loop_check_box.button_pressed
