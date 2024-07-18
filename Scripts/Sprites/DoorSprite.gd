extends BaseSprite

class_name DoorSprite

const object_ids = [26, 2255, 2254, 25]
const sprite_ids = [92, 3903, 3902, 91]

var object_id
var direction
var last_mode
var last_submode

func _init(_object_id):
	object_id = _object_id
	for i in range(4):
		if _object_id == object_ids[i]:
			direction = i
			var sprite = ObjectsLoader.get_sprite(sprite_ids[i])
			texture = sprite["frames"][0]
			offset = sprite["center"]
	
	mode = BuildTab.TAB_INDEX
	submode = 5

func _process(_delta):
	if last_mode != App.mode or last_submode != App.submode:
		last_mode = App.mode
		last_submode = App.submode
		queue_redraw()

func _draw():
	if App.mode == mode and App.submode == submode:
		draw_circle(Vector2.ZERO, 2, Color.YELLOW)

func should_delete():
	return super.should_delete()
