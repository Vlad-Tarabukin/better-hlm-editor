extends TabBar

class_name LevelTab

var active
var start_pos
var trigger_rect
var placing_transition
var placing_elevator

const TAB_INDEX = 3

const TEXTURE = preload("res://Textures/transition.png")

@onready var name_line_edit = $"Name LineEdit"
@onready var author_line_edit = $"Author LineEdit"
@onready var top_bound_spin_box = $"Boundaries/Top Bound SpinBox"
@onready var left_bound_spin_box = $"Boundaries/Left Bound SpinBox"
@onready var right_bound_spin_box = $"Boundaries/Right Bound SpinBox"
@onready var bottom_bound_spin_box = $"Boundaries/Bottom Bound SpinBox"
@onready var transition_panel = $"../../../Transition Panel"

func _on_TabContainer_tab_selected(tab):
	active = tab == TAB_INDEX
	if active:
		App.cursor.outline = false

func show_level_info():
	name_line_edit.text = App.level_info["name"]
	author_line_edit.text = App.level_info["author"]
	left_bound_spin_box.set_value_no_signal(App.level_info["level_boundaries"].position.x)
	top_bound_spin_box.set_value_no_signal(App.level_info["level_boundaries"].position.y)
	right_bound_spin_box.set_value_no_signal(App.level_info["level_boundaries"].end.x)
	bottom_bound_spin_box.set_value_no_signal(App.level_info["level_boundaries"].end.y)

func _on_boundaries_change(_value):
	App.change_level_boundaries(left_bound_spin_box.value, top_bound_spin_box.value, right_bound_spin_box.value, bottom_bound_spin_box.value)

func _unhandled_input(event):
	if active:
		if placing_transition:
			if event is InputEventMouseButton:
				if event.button_index == MOUSE_BUTTON_LEFT:
					if event.pressed:
						start_pos = GlobalCamera.get_mouse_position()
						App.cursor.texture = TEXTURE
						App.cursor.move = false
					else:
						trigger_rect = Rect2i(start_pos, GlobalCamera.get_mouse_position() - start_pos)
						$"../../../Transition Panel/Floor SpinBox".max_value = App.level_info["floors"] + 1
						transition_panel.set_visible(true)
					App.cursor.region_enabled = event.pressed
			elif event is InputEventMouseMotion and Input.is_mouse_button_pressed(1):
				App.cursor.region_rect = Rect2i(Vector2i.ZERO, GlobalCamera.get_mouse_position() - start_pos)
		elif placing_elevator:
			if event is InputEventMouseButton and event.pressed:
				if event.button_index == MOUSE_BUTTON_LEFT:
					$"../../../Transition Panel/Floor SpinBox".max_value = App.level_info["floors"] + 1
					transition_panel.set_visible(true)
					App.cursor.move = false
				elif event.button_index == MOUSE_BUTTON_RIGHT and Input.is_key_pressed(KEY_SHIFT):
					App.cursor.global_rotation += 90

func _on_transition_button_button_up():
	placing_transition = true

func _on_elevator_button_button_up():
	placing_elevator = true
	App.cursor.texture = ObjectsLoader.get_sprite(1512)["frames"][0]
	$"../../../Transition Panel/Direction OptionButton".disabled = true

func _on_cancel_button_button_up():
	transition_panel.set_visible(false)
	App.cursor.texture = null
	App.cursor.move = true

func _on_ok_button_button_up():
	_on_cancel_button_button_up()
	if placing_transition:
		var direction = $"../../../Transition Panel/Direction OptionButton".get_selected_id()
		var target_floor = $"../../../Transition Panel/Floor SpinBox".value - 1
		var offset = Vector2i($"../../../Transition Panel/X SpinBox".value, $"../../../Transition Panel/Y SpinBox".value)
		var transition_sprite = TransitionSprite.new(trigger_rect, direction, target_floor, offset)
		App.add_object(transition_sprite, false)
		transition_sprite.global_position = start_pos
		placing_transition = false
	elif placing_elevator:
		var target_floor = $"../../../Transition Panel/Floor SpinBox".value - 1
		var offset = Vector2i($"../../../Transition Panel/X SpinBox".value, $"../../../Transition Panel/Y SpinBox".value)
		var elevator_sprite = ElevatorSprite.new(target_floor, offset)
		App.add_object(elevator_sprite)
		placing_elevator = false
		$"../../../Transition Panel/Direction OptionButton".disabled = false
