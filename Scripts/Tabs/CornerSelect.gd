extends TextureRect

class_name CornerSelect

@onready var build = $".."

var pos

func set_pos(_pos):
	pos = _pos
	queue_redraw()

func _gui_input(event):
	if App.mode == build.TAB_INDEX and event is InputEventMouseButton and event.button_index == 1 and event.is_pressed():
			var mouse_pos = get_local_mouse_position()
			mouse_pos.x = floor(mouse_pos.x / 16) * 8
			mouse_pos.y = floor(mouse_pos.y / 16) * 8
			set_pos(mouse_pos)
			build.set_corner(pos)

func _draw():
	if pos != null:
		draw_rect(Rect2i(pos * 2, Vector2i(16, 16)), Color.YELLOW, false)
