extends Node

var wad_pasrer = WadParser.new()
var checksums = {}

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

func should_load(file_path):
	if checksums.has(file_path):
		if wad_pasrer.files[file_path].content.get_string_from_ascii().md5_text() == checksums[file_path]:
			return false
	checksums[file_path] = wad_pasrer.files[file_path].content.get_string_from_ascii().md5_text()
	return true

func load_wads(wads):
	wad_pasrer.load_wads(wads)
	var wad_sprites = {}
	var f
	for file_name in wad_pasrer.files:
		if file_name.get_extension() == "meta":
			if !should_load(file_name) and !should_load(file_name.replace(".meta", ".png")):
				continue
			var meta = wad_pasrer.files[file_name]
			var page = Image.new()
			page.load_png_from_buffer(wad_pasrer.files[file_name.replace(".meta", ".png")].content)
			meta.pos += 24
			while meta.pos < len(meta.content):
				var sprite_name = meta.get_string(meta.get_8()).split("/")[-1]
				var frames = meta.get_32()
				if !wad_sprites.has(sprite_name):
					wad_sprites[sprite_name] = {"file_name": file_name, "frames": []}
					for i in range(frames):
						meta.pos += 4
						var width = meta.get_32()
						var height = meta.get_32()
						var x = meta.get_32()
						var y = meta.get_32()
						meta.pos += 16
						var texture = ImageTexture.create_from_image(page.get_region(Rect2i(x, y, width, height)))
						wad_sprites[sprite_name]["frames"].append(texture)
				else:
					meta.pos += frames * 36
			meta.pos = 0
	for key in sprites:
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
	
	for file_name in wad_pasrer.files:
		if file_name.get_extension() == "wav":
			var file = wad_pasrer.files[file_name]
			var stream = AudioStreamWAV.new()
			
			var riff_found = false
			var wave_found = false
			var fmt_found = false
			var data_found = false
			while file.pos < len(file.content) and !(riff_found and wave_found and fmt_found and data_found):
				var flag = file.get_string(4)
				if flag == "RIFF":
					riff_found = true
					file.pos += 4
				elif flag == "WAVE":
					wave_found = true
				elif flag == "fmt ":
					fmt_found = true
					file.pos += 4
					stream.format = file.get_16()
					stream.stereo = file.get_16() == 2
					stream.mix_rate = file.get_32()
					file.pos += 8
				elif flag == "data":
					data_found = true
					stream.data = file.get_buffer(file.get_32())
					file.pos += 4
				else:
					file.pos -= 3
			
			sounds[file_name.replace(".wav", "").replace("Sounds/", "")] = stream
			file.pos = 0

func get_sprite(sprite_id):
	if sprites.has(sprite_id):
		return sprites[sprite_id]
	return sprites[-1]
