extends BaseSprite

class_name WallSprite

var object_id
var sprite_id
var horizontal
var wall_offset

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
	var sprite = ObjectsLoader.get_sprite(sprite_id)
	wall_offset = -sprite["center"]
	texture = sprite["frames"][0]
	mode = 0
	submode = 1
