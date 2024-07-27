extends Control

@onready var fade_spin_box = $"Fade SpinBox"

func _ready():
	custom_minimum_size = Vector2(360, 80)

func initialize(action):
	fade_spin_box.value = action["fade_time"] * int(action["fade"])
