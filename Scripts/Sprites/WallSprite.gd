extends BaseSprite

class_name WallSprite

var object_id
var sprite_id
var horizontal

func should_delete():
	return !Input.is_key_pressed(KEY_CTRL) and !Input.is_key_pressed(KEY_SHIFT)

func _init(_object_id, _sprite_id, wall = null):
	object_id = _object_id
	sprite_id = _sprite_id
	if wall == null:
		for _wall in WallPanel.walls:
			if _wall["object_id"] == object_id and _wall["sprite_id"] == sprite_id:
				wall = _wall
				break
	if wall == null:
		horizontal = null
		var sprite = ObjectsLoader.get_sprite(sprite_id)
		texture = sprite["frames"][0]
		offset = sprite["center"]
	else:
		horizontal = wall["horizontal"]
		texture = wall["texture_sprite"]
	mode = 0
	submode = 1
