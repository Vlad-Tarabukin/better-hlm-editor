extends Node2D

class_name Waypoints

var points = [Vector2(0, 0), Vector2(800, 400)]
var mouse = true
var selected = 0

static func get_mouse_point(last_point):
	if last_point == null or !Input.is_key_pressed(KEY_SHIFT):
		return App.cursor.position
	var mouse_point = App.cursor.position
	var diff = mouse_point - last_point
	var angle = int(abs(rad_to_deg(diff.angle()))) % 90
	if 22.5 < angle and angle < 67.5:
		var offset = max(abs(diff.x), abs(diff.y))
		return last_point + Vector2(sign(diff.x), sign(diff.y)) * offset
	if abs(diff.x) > abs(diff.y):
		return last_point + Vector2(diff.x, 0)
	return last_point + Vector2(0, diff.y)

func _process(_delta):
	if visible:
		queue_redraw()

func _draw():
	var drawn_points = points.duplicate()
	if mouse:
		drawn_points.append(get_mouse_point(points[-1] if len(points) > 0 else null))
	if len(drawn_points) > 0:
		for i in range(len(drawn_points) - 1):
			if i < len(drawn_points) - 1:
				var diff = drawn_points[i] - drawn_points[i + 1]
				var mid_point = drawn_points[i] - (Vector2(abs(diff.y) * sign(diff.x), diff.y) if abs(diff.x) > abs(diff.y) else Vector2(diff.x, abs(diff.x) * sign(diff.y)))
				draw_line(drawn_points[i], mid_point, Color.GREEN, 2)
				draw_line(mid_point, drawn_points[i + 1], Color.GREEN, 2)
				draw_circle(mid_point, 1, Color.GREEN)
			draw_circle(drawn_points[i], 4, Color.RED if !mouse and i == selected else Color.GREEN)
		draw_circle(drawn_points[-1], 4, Color.RED if mouse or len(drawn_points) - 1 == selected else Color.GREEN)
