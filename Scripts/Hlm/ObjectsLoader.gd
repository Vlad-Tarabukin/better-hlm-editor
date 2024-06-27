extends Node

var objects = []
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

func load_objects():
	load_sprites()
	objects.clear()
	var objects_tsv = FileAccess.open("res://objects.tsv", FileAccess.READ)
	while !objects_tsv.eof_reached():
		var st = objects_tsv.get_csv_line("\t")
		objects.append(HLMObject.new(int(st[0]), int(st[2]), st[1]))
		if !sprites.has(objects[-1].sprite_id):
			objects[-1].sprite_id = -1

func load_sprites():
	var wad_sprite_parser = WadSpriteParser.new()
	var wad_sprites = wad_sprite_parser.parse_sprites()
	for sprite in sprites.values():
		if wad_sprites.has(sprite["name"]):
			sprite["frames"] = wad_sprites[sprite["name"]]
		else:
			sprite["frames"] = sprites[-1]["frames"]
	for tile in tiles:
		var tilemap = wad_sprites[tile["name"]][0]
		tile["tilemap"] = tilemap
		tilemap = tilemap.get_image()
		for x in range(0, tilemap.get_width(), tile["size"]):
			for y in range(0, tilemap.get_height(), tile["size"]):
				var image_texture = ImageTexture.create_from_image(tilemap.get_region(Rect2i(x, y, tile["size"], tile["size"])))
				tile["tiles"][str(x) + " " + str(y)] = image_texture

func get_sprite(sprite_id):
	if sprites.has(sprite_id):
		return sprites[sprite_id]
	return sprites[-1]
