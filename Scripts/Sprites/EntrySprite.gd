extends BaseSprite

class_name EntrySprite

const TEXTURE = preload("res://Textures/entry.png")

var trigger_rect
var direction

func _init(_trigger_rect, _direciton):
	trigger_rect = _trigger_rect
	direction = _direciton
	
	mode = BuildTab.TAB_INDEX
	texture = TEXTURE
	position = trigger_rect.position
	texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	region_enabled = true
	region_rect = trigger_rect

func _draw():
	draw_texture(ObjectsLoader.get_sprite(286)["frames"][direction], trigger_rect.size / 2 - Vector2i(6, 6))

func get_ver_direction():
	if direction == 1:
		return -1
	elif direction == 3:
		return 1
	return 0
	
func get_hor_direction():
	if direction == 2:
		return -1
	elif direction == 0:
		return 1
	return 0

func get_play_object():
	if direction == 0 or direction == 2:
		return 302
	return 303

func get_obj_object():
	if direction == 0 or direction == 2:
		return 4356
	return 4355
