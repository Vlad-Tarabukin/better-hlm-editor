extends BaseSprite

class_name ElevatorSprite

var target_floor
var transition_offset

func _init(_target_floor, _transition_offset):
	target_floor = _target_floor
	transition_offset = _transition_offset
	
	mode = LevelTab.TAB_INDEX
	texture = ObjectsLoader.get_sprite(1512)["frames"][0]
