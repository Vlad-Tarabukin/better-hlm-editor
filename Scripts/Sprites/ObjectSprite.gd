extends BaseSprite

class_name ObjectSprite

var object: HLMObject
var object_frame
var comment = ""
var parent
var last_mode
var patrol_path_points = []
var motion
var not_moved_position

func _init(_object: HLMObject, _object_frame, _mode, _parent = 11):
	object = _object.clone()
	object_frame = _object_frame
	mode = _mode
	var spr = ObjectsLoader.get_sprite(object.sprite_id)
	texture = spr["frames"][object_frame]
	offset = spr["center"]
	parent = _parent
	z_index = object.z_index

func _draw():
	if App.settings["collision"] and object.mask_id != null:
		var mask = ObjectsLoader.masks[object.mask_id]
		draw_texture(mask["texture"], mask["center"], COLLISION_HINT_COLOR)
	if App.settings["center"]:
		draw_circle(Vector2.ZERO, 2, Color.YELLOW)
	if App.mode == mode:
		draw_rect(get_rect(), Color.WHITE, false)

func _process(_delta):
	if last_mode != App.mode:
		last_mode = App.mode
		queue_redraw()

func _unhandled_input(event):
	if App.level == level and App.mode == mode:
		if event is InputEventMouseButton and App.cursor.texture == null:
			if get_rect().has_point(to_local(GlobalCamera.get_mouse_position())):
				if event.button_index == MOUSE_BUTTON_LEFT and event.double_click:
					get_tree().get_root().get_node("Main/CanvasLayer/Main GUI/Edit Panel").edit(self)
					get_tree().get_root().set_input_as_handled()
				elif event.button_index == MOUSE_BUTTON_LEFT and Input.is_key_pressed(KEY_SHIFT):
					if event.pressed:
						App.moving_object = self
						motion = Vector2.ZERO
						not_moved_position = position
				elif mode == ItemsTab.TAB_INDEX and event.button_index == MOUSE_BUTTON_MIDDLE and event.pressed:
					get_tree().get_root().get_node("Main/CanvasLayer/Main GUI/Panel/TabContainer/Items").set_filter(object.object_name)
					get_tree().get_root().set_input_as_handled()
			if !event.pressed and App.moving_object == self:
				App.moving_object = null
		elif event is InputEventMouseMotion:
			if event.button_mask == MOUSE_BUTTON_MASK_LEFT:
				if App.moving_object == self:
					motion += event.relative / GlobalCamera.target_zoom
					position = not_moved_position + (motion if App.cursor.snap == 0 else round(motion / App.cursor.snap) * App.cursor.snap)
					get_tree().get_root().set_input_as_handled()

func set_ids(object_id, sprite_id, _frame):
	object.object_id = object_id
	object.sprite_id = sprite_id
	object_frame = _frame
	var spr = ObjectsLoader.get_sprite(sprite_id)
	texture = spr["frames"][object_frame]
	offset = spr["center"]
	object.object_name = ""
