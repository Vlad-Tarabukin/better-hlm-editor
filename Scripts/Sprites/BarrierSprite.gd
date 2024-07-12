extends BaseSprite

class_name BarrierSprite

const COLOR = Color(1, 0, 0, 0.4)
var lenght

func _init(_lenght):
	lenght = _lenght
	
	mode = BuildTab.TAB_INDEX

func _draw():
	draw_line(Vector2.ZERO, Vector2(0, lenght * 16), COLOR, 3)
