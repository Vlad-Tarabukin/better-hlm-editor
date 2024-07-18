extends BaseSprite

class_name ElevatorSprite

var target_floor
var transition_offset

func _init(_target_floor, _transition_offset):
	target_floor = _target_floor
	transition_offset = _transition_offset
	
	mode = LevelTab.TAB_INDEX
	var sprite = ObjectsLoader.get_sprite(1512)
	texture = sprite["frames"][-1]
	offset = sprite["center"]
	flip_v = true
