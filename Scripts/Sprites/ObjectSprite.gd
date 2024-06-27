extends BaseSprite

class_name ObjectSprite

var object: HLMObject
var object_frame
var parent
var depth
var last_mode

func _init(_object: HLMObject, _object_frame, _mode, _parent = 11, _depth = 0):
	object = _object
	object_frame = _object_frame
	mode = _mode
	var spr = ObjectsLoader.get_sprite(object.sprite_id)
	texture = spr["frames"][object_frame]
	offset = spr["center"]
	parent = _parent
	depth = _depth
	z_index = -depth

func _draw():
	if App.mode == mode:
		draw_rect(get_rect(), Color.WHITE, false)

func _process(_delta):
	if last_mode != App.mode:
		last_mode = App.mode
		queue_redraw()
