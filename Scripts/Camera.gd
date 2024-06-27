extends Camera2D

const MAX_ZOOM = 20
const MIN_ZOOM = 1
const ZOOM_CHANGE = 1
var target_zoom = 1.0

func _unhandled_input(event: InputEvent):
	if event is InputEventMouseMotion:
		if event.button_mask == MOUSE_BUTTON_MASK_MIDDLE:
			position -= event.relative / target_zoom
	elif event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				target_zoom = max(target_zoom - ZOOM_CHANGE, MIN_ZOOM)
			elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
				target_zoom = min(target_zoom + ZOOM_CHANGE, MAX_ZOOM)
			zoom.x = target_zoom
			zoom.y = target_zoom

func get_mouse_position():
	var result = Vector2i.ZERO
	var vec = (get_viewport().get_mouse_position() - get_viewport_rect().size / 2) / target_zoom + position
	result.x = int(vec.x)
	result.y = int(vec.y)
	return vec
