extends TextureRect

@onready var build = $".."

var pos

func set_pos(_pos):
	pos = _pos
	queue_redraw()

func _gui_input(event):
	if App.mode == build.TAB_INDEX and event is InputEventMouseButton and event.button_index == 1 and event.is_pressed():
			var mouse_pos = get_local_mouse_position()
			mouse_pos.x = floor(mouse_pos.x / 16) * 16
			mouse_pos.y = floor(mouse_pos.y / 16) * 16
			set_pos(mouse_pos)
			build.set_tile(pos)

func _draw():
	if pos != null:
		draw_rect(Rect2i(pos, Vector2i(16, 16)), Color.YELLOW, false)
