extends Sprite2D

class_name BaseSprite

var mode
var submode = 0
var level
var custom_rect

func _ready():
	centered = false

func should_delete():
	return !Input.is_key_pressed(KEY_SHIFT)

func _input(_event):
	if App.level == level and App.mode == mode and App.submode == submode and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) and should_delete():
		if custom_rect and custom_rect.has_point(to_local(GlobalCamera.get_mouse_position())) or custom_rect == null and get_rect().has_point(to_local(GlobalCamera.get_mouse_position())):
			queue_free()
			if !Input.is_key_pressed(KEY_CTRL):
				get_viewport().set_input_as_handled()
