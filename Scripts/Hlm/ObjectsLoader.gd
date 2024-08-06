extends Node

var sprites = {}
var tiles = []

func load_sprites_info():
	var sprites_tsv = FileAccess.open("res://sprites.tsv", FileAccess.READ)
	while !sprites_tsv.eof_reached():
		var sprite = sprites_tsv.get_csv_line("\t")
		sprites[int(sprite[0])] = {
			"name": sprite[1],
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
			"tiles": {}
		})
	tiles_tsv.close()
	
	sprites[-1] = {
		"name": "noTexture",
		"center": -Vector2i(10,10),
		"frames": [preload("res://Textures/default_texture.png")]
	}

func load_sprites(file_path="res://base.wad"):
	var wad_sprite_parser = WadSpriteParser.new()
	var wad_sprites = wad_sprite_parser.parse_sprites(file_path, file_path == "res://base.wad")
	for sprite in sprites.values():
		if wad_sprites.has(sprite["name"]):
			sprite["frames"] = wad_sprites[sprite["name"]]
		elif file_path == "res://base.wad":
			sprite["frames"] = sprites[-1]["frames"]
	for tile in tiles:
		if wad_sprites.has(tile["name"]):
			var tilemap = wad_sprites[tile["name"]][0]
			tile["tilemap"] = tilemap
			tilemap = tilemap.get_image()
			for x in range(0, tilemap.get_width(), 16):
				for y in range(0, tilemap.get_height(), 16):
					var image_texture = ImageTexture.create_from_image(tilemap.get_region(Rect2i(x, y, 16, 16)))
					tile["tiles"][str(x) + " " + str(y)] = image_texture

func get_sprite(sprite_id):
	if sprites.has(sprite_id):
		return sprites[sprite_id]
	return sprites[-1]
