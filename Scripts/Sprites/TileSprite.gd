extends BaseSprite

class_name TileSprite

var tile_id
var tile_x
var tile_y
var depth
var missing_texture = false

const MISSING_TEXTURE = preload("res://Textures/default_texture.png")

func should_delete():
	return !Input.is_key_pressed(KEY_CTRL) and is_pixel_opaque(to_local(GlobalCamera.get_mouse_position()))

func _init(_tile_id, _tile_x, _tile_y, _depth, _submode=0):
	tile_id = _tile_id
	tile_x = _tile_x
	tile_y = _tile_y
	depth = _depth
	z_index = -depth
	for tile in ObjectsLoader.tiles:
		if tile["id"] == tile_id:
			texture = tile["tiles"].get(TileCoordinates.key(tile_x, tile_y))
			if texture == null:
				missing_texture = true
				texture = MISSING_TEXTURE
			break
	if texture == null:
		queue_free()
		return
	mode = 0
	submode = _submode
