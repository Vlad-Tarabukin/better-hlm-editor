extends Camera2D

const MAX_ZOOM = 20
const MIN_ZOOM = 1
const ZOOM_CHANGE = 1

const MAIN_GRID_LINE_COLOR = Color(1, 1, 1, 0.1)
const SECOND_GRID_LINE_COLOR = Color(1, 1, 1, 0.05)

var target_zoom = 1.0

func _draw():
	var main_color
	var start_x = int((position.x - get_viewport_rect().size.x / 2 * target_zoom) / 16) * 16
	var end_x = start_x + get_viewport_rect().size.x * target_zoom
	var start_y = int((position.y - get_viewport_rect().size.y / 2 * target_zoom) / 16) * 16
	var end_y = start_y + get_viewport_rect().size.y * target_zoom
	for x in range(start_x, end_x, 16):
		var actual_x = x - position.x
		var color = SECOND_GRID_LINE_COLOR
		if x % 32 == 0:
			color = MAIN_GRID_LINE_COLOR
		draw_line(Vector2(actual_x, get_viewport_rect().size.y / 2 * target_zoom), Vector2(actual_x, -get_viewport_rect().size.y / 2 * target_zoom), color)
	for y in range(start_y, end_y, 16):
		var actual_y = y - position.y
		var color = SECOND_GRID_LINE_COLOR
		if y % 32 == 0:
			color = MAIN_GRID_LINE_COLOR
		draw_line(Vector2(get_viewport_rect().size.x / 2 * target_zoom, actual_y), Vector2(-get_viewport_rect().size.x / 2 * target_zoom, actual_y), color)

func _unhandled_input(event: InputEvent):
	if event is InputEventMouseMotion:
		if event.button_mask == MOUSE_BUTTON_MASK_MIDDLE:
			position -= event.relative / target_zoom
			queue_redraw()
	elif event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				target_zoom = max(target_zoom - ZOOM_CHANGE, MIN_ZOOM)
			elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
				target_zoom = min(target_zoom + ZOOM_CHANGE, MAX_ZOOM)
			zoom.x = target_zoom
			zoom.y = target_zoom
			queue_redraw()

func get_mouse_position():
	var result = Vector2i.ZERO
	var vec = (get_viewport().get_mouse_position() - get_viewport_rect().size / 2) / target_zoom + position
	result.x = int(vec.x)
	result.y = int(vec.y)
	return vec
