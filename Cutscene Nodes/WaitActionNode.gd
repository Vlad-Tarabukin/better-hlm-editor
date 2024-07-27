extends Control

@onready var delay_spin_box = $"Delay SpinBox"

func _ready():
	custom_minimum_size = Vector2(360, 80)

func initialize(action):
	delay_spin_box.value = action["delay"] / 60.0
