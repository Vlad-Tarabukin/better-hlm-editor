extends TextureRect

@onready var build = $".."

var pos
var tile_size

func set_pos(_pos):
	pos = _pos
	queue_redraw()

func _gui_input(event):
	if App.mode == build.TAB_INDEX and event is InputEventMouseButton and event.button_index == 1 and event.is_pressed():
			var mouse_pos = get_local_mouse_position()
			mouse_pos.x = floor(mouse_pos.x / tile_size) * tile_size
			mouse_pos.y = floor(mouse_pos.y / tile_size) * tile_size
			set_pos(mouse_pos)
			build.set_tile(pos)

func _draw():
	if pos != null:
		draw_rect(Rect2i(pos, Vector2i.ONE * tile_size), Color.YELLOW, false)
