extends Node

var sprites = {}
var masks = {}
var objects = {}
var tiles = []
var sounds = {}

func load_info():
	var sprites_tsv = FileAccess.open("res://sprites.tsv", FileAccess.READ)
	while !sprites_tsv.eof_reached():
		var sprite = sprites_tsv.get_csv_line("\t")
		sprites[int(sprite[0])] = {
			"name": sprite[1],
			"center": -Vector2i(int(sprite[2]), int(sprite[3]))
		}
		masks[int(sprite[0])] = {
			"center": -Vector2i(int(sprite[2]), int(sprite[3]))
		}
	sprites_tsv.close()
	
	var tiles_tsv = FileAccess.open("res://tiles.tsv", FileAccess.READ)
	while !tiles_tsv.eof_reached():
		var tile = tiles_tsv.get_csv_line("\t")
		tiles.append({
			"title": tile[0],
			"name": tile[1],
			"id": int(tile[2]),
			"depth": int(tile[3]),
			"size": int(tile[4]),
			"tiles": {},
			"view_tiles": {}
		})
	tiles_tsv.close()
	
	sprites[-1] = {
		"name": "No Texture",
		"file_name": "-",
		"center": -Vector2i(10,10),
		"frames": [preload("res://Textures/default_texture.png")]
	}
	
	var objects_tsv = FileAccess.open("res://objects.tsv", FileAccess.READ)
	while !objects_tsv.eof_reached():
		var st = objects_tsv.get_csv_line("\t")
		objects[int(st[0])] = HLMObject.new(int(st[0]), st[1], int(st[2]), -int(st[3]), int(st[4]) if st[4] != "-" else null)
		if !ObjectsLoader.sprites.has(objects[int(st[0])].sprite_id):
			objects[int(st[0])].sprite_id = -1

func load_assets(file_path="res://base.wad"):
	var base = file_path == "res://base.wad"
	var wad_sprite_parser = WadParser.new()
	var wad_sprites = wad_sprite_parser.parse_sprites(file_path, file_path == "res://base.wad")
	for key in sprites.keys():
		var sprite = sprites[key]
		if wad_sprites.has(sprite["name"]):
			sprite["frames"] = wad_sprites[sprite["name"]]["frames"]
			sprite["file_name"] = wad_sprites[sprite["name"]]["file_name"] + "/" + sprite["name"]
			var first_frame = sprite["frames"][0]
			var first_frame_data = first_frame.get_image().get_data()
			var new_data = PackedByteArray()
			for a in Array(first_frame_data).slice(3, len(first_frame_data), 4):
				new_data.append(255)
				new_data.append(255 if a != 0 else 0)
			masks[key]["texture"] = ImageTexture.create_from_image(
				Image.create_from_data(first_frame.get_width(), first_frame.get_height(), false, Image.FORMAT_LA8, new_data))
		elif file_path == "res://base.wad":
			sprite["frames"] = sprites[-1]["frames"]
	
	for tile in tiles:
		if wad_sprites.has(tile["name"]):
			var tilemap = wad_sprites[tile["name"]]["frames"][0]
			tile["tilemap"] = tilemap
			tilemap = tilemap.get_image()
			var size = 16
			if tile["size"] == 8:
				size = 8
			for x in range(0, tilemap.get_width(), size):
				for y in range(0, tilemap.get_height(), size):
					var image_texture = ImageTexture.create_from_image(tilemap.get_region(Rect2i(x, y, size, size)))
					tile["tiles"][str(x) + " " + str(y)] = image_texture
			if tile["size"] != 8 and tile["size"] != 16:
				size = tile["size"]
				for x in range(0, tilemap.get_width(), size):
					for y in range(0, tilemap.get_height(), size):
						var image_texture = ImageTexture.create_from_image(tilemap.get_region(Rect2i(x, y, size, size)))
						tile["view_tiles"][str(x) + " " + str(y)] = image_texture
			else:
				tile["view_tiles"] = tile["tiles"]
	
	sounds = wad_sprite_parser.parse_sounds()

func get_sprite(sprite_id):
	if sprites.has(sprite_id):
		return sprites[sprite_id]
	return sprites[-1]
