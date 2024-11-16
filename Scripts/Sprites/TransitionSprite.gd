extends BaseSprite

class_name TransitionSprite

const TEXTURE = preload("res://Textures/transition.png")

var trigger_rect
var direction
var target_floor
var transition_offset

func should_delete():
	return true

func _init(_trigger_rect, _direciton, _target_floor, _transition_offset):
	trigger_rect = _trigger_rect
	direction = _direciton
	target_floor = _target_floor
	transition_offset = _transition_offset
	
	mode = LevelTab.TAB_INDEX
	texture = TEXTURE
	position = trigger_rect.position
	region_enabled = true
	region_rect = trigger_rect

func _draw():
	draw_texture(ObjectsLoader.get_sprite(286)["frames"][direction], Vector2(trigger_rect.size) / 2 - Vector2(6, 6))

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

func _visibility_changed():
	if visible:
		App.get_floor(target_floor).transition_markers.append(self)
	else:
		App.get_floor(target_floor).transition_markers.erase(self)
