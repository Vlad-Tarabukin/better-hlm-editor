extends BaseSprite

class_name BarrierSprite

const COLOR = Color(1, 0, 0, 0.4)
var lenght

func _init(_lenght = 0):
	set_lenght(_lenght)
	
	mode = BuildTab.TAB_INDEX
	submode = 3

func set_lenght(_lenght):
	lenght = _lenght
	custom_rect = Rect2(Vector2.ZERO, Vector2(4, lenght * 16))

func _draw():
	draw_line(Vector2.ZERO, Vector2(0, lenght * 16), COLOR, 3)

func should_delete():
	return super.should_delete()
