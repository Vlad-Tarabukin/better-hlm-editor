extends BaseSprite

class_name TileSprite

var tile_id
var tile_x
var tile_y
var depth

func should_delete():
	return !Input.is_key_pressed(KEY_CTRL)

func _init(_tile_id, _tile_x, _tile_y, _depth, _texture=null, _submode=0):
	tile_id = _tile_id
	tile_x = _tile_x
	tile_y = _tile_y
	depth = _depth
	z_index = -depth
	if _texture == null:
		for tile in ObjectsLoader.tiles:
			if tile["id"] == tile_id:
				texture = tile["tiles"][str(tile_x) + " " + str(tile_y)]
				break
		if texture == null:
			queue_free()
			return
	else:
		texture = _texture
	mode = 0
	submode = _submode
