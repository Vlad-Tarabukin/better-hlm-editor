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

func _unhandled_input(event):
	if App.level == level and App.mode == mode and event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.double_click:
			if App.cursor.texture == null and get_rect().has_point(to_local(GlobalCamera.get_mouse_position())):
				App.selected_object = self
				get_tree().get_root().get_node("Main/CanvasLayer/Main GUI/Edit Panel").visible = true
				get_tree().get_root().set_input_as_handled()

func set_ids(object_id, sprite_id, _frame):
	object.object_id = object_id
	object.sprite_id = sprite_id
	object_frame = _frame
	var spr = ObjectsLoader.get_sprite(sprite_id)
	texture = spr["frames"][object_frame]
	offset = spr["center"]
	object.object_name = ""
