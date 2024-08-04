extends BaseSprite

class_name CutsceneSprite

var info

func _init(_info):
	info = _info
	change_sprite(info["sprite_id"])
	
	mode = CutsceneTab.TAB_INDEX

func should_delete():
	return false

func change_sprite(id):
	info["sprite_id"] = id
	var sprite = ObjectsLoader.get_sprite(info["sprite_id"])
	offset = sprite["center"]
	texture = sprite["frames"][0]

func _unhandled_input(event):
	if App.level == level and App.mode == mode and event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.double_click:
			if App.cursor.texture == null and get_rect().has_point(to_local(GlobalCamera.get_mouse_position())):
				get_tree().get_root().get_node("Main/CanvasLayer/Main GUI/Edit Cutscene Sprite Panel").open(self)
				get_tree().get_root().set_input_as_handled()
