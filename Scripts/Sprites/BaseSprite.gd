extends Sprite2D

class_name BaseSprite

var mode
var submode = 0
var level
var custom_rect
var loaded = false
var register_vibility_change = true

func _ready():
	z_as_relative = false
	centered = false
	visibility_changed.connect(_visibility_changed)
	
	App.undo_redo.create_action("Added " + name)
	App.undo_redo.add_do_method(set_visibile_no_register.bind(true))
	App.undo_redo.add_undo_method(set_visibile_no_register.bind(false))
	App.undo_redo.commit_action(false)

func should_delete():
	return !Input.is_key_pressed(KEY_SHIFT)

func _input(_event):
	if visible and App.level == level and App.mode == mode and App.submode == submode and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) and should_delete():
		if custom_rect and custom_rect.has_point(to_local(GlobalCamera.get_mouse_position())) or custom_rect == null and get_rect().has_point(to_local(GlobalCamera.get_mouse_position())):
			visible = false
			if !Input.is_key_pressed(KEY_CTRL):
				get_viewport().set_input_as_handled()

func set_visibile_no_register(_visible):
	register_vibility_change = false
	visible = _visible

func _visibility_changed():
	if !visible:
		if register_vibility_change:
			App.undo_redo.create_action("Removed " + name)
			App.undo_redo.add_do_method(set_visibile_no_register.bind(false))
			App.undo_redo.add_undo_method(set_visibile_no_register.bind(true))
			App.undo_redo.commit_action(false)
		else:
			register_vibility_change = true
