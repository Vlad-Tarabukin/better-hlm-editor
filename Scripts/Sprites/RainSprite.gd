extends BaseSprite

class_name RainSprite

const COLOR = Color(0, 0, 1, 0.2)

var rain_rects

func should_delete():
	return true

func _init(_rain_rects):
	rain_rects = _rain_rects
	queue_redraw()

func _draw():
	for i in rain_rects:
		draw_rect(i, COLOR)
