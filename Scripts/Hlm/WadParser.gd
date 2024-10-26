extends Node

class_name WadParser

static var basewad
static var basewad_asset_locations
static var basewad_asset_offset

func parse_sprites(file_path, base):
	var file = FileAccess.open(file_path, FileAccess.READ)
	if base:
		basewad = FileAccess.open(file_path, FileAccess.READ)
	file.seek(16)
	
	# Parsing header
	
	var asset_locations = {}
	var assets_amount = file.get_32()
	for _i in range(assets_amount):
		var asset_name_len = file.get_32()
		var asset_name = file.get_buffer(asset_name_len).get_string_from_ascii()
		asset_locations[asset_name] = {}
		asset_locations[asset_name]["len"] = file.get_64()
		asset_locations[asset_name]["start"] = file.get_64()
	if base:
		basewad_asset_locations = asset_locations
	
	# Skipping all directories names
	
	var dirs_amount = file.get_32()
	for _i in range(dirs_amount):
		var dir_name_len = file.get_32()
		file.seek(file.get_position() + dir_name_len)
		var entries_amount = file.get_32()
		for _j in range(entries_amount):
			var entry_name_len = file.get_32()
			file.seek(file.get_position() + 1 + entry_name_len)
	
	# Getting sprites
	
	var sprites = {}
	var asset_offset = file.get_position()
	if base:
		basewad_asset_offset = asset_offset
		for asset_name in asset_locations.keys():
			if asset_name.get_extension() == "meta":
				var meta_location = asset_locations[asset_name]
				var image_location = asset_locations[asset_name.replace(".meta", ".png")]
				file.seek(asset_offset + image_location["start"])
				var image_buffer = file.get_buffer(image_location["len"])
				file.seek(asset_offset + meta_location["start"])
				sprites.merge(parse_meta(file, meta_location["len"], image_buffer, asset_name.replace(".meta", "")))
	else:
		for asset_name in asset_locations.keys():
			if asset_name.get_extension() == "png":
				var meta_location = basewad_asset_locations[asset_name.replace(".png", ".meta")]
				var image_location = asset_locations[asset_name]
				file.seek(asset_offset + image_location["start"])
				var image_buffer = file.get_buffer(image_location["len"])
				basewad.seek(basewad_asset_offset + meta_location["start"])
				sprites.merge(parse_meta(basewad, meta_location["len"], image_buffer, asset_name.replace(".png", "")))
	file.close()
	return sprites

func parse_meta(file:FileAccess, meta_len, image_buffer:PackedByteArray, file_name):
	var sprites = {}
	var f = file
	var start = f.get_position()
	f.seek(start + 24)
	var page = Image.new()
	page.load_png_from_buffer(image_buffer)
	while f.get_position() - start < meta_len:
		var sprite_name_len = f.get_8()
		var sprite_name = f.get_buffer(sprite_name_len).get_string_from_ascii()
		var frames_amount = f.get_32()
		sprites[sprite_name.split("/")[-1]] = {"file_name": file_name, "frames": []}
		for _i in range(frames_amount):
			f.seek(f.get_position() + 4)
			var width = f.get_32()
			var height = f.get_32()
			var x = f.get_32()
			var y = f.get_32()
			f.seek(f.get_position() + 16)
			var image = page.get_region(Rect2i(x, y, width, height))
			var texture = ImageTexture.create_from_image(image)
			sprites[sprite_name.split("/")[-1]]["frames"].append(texture)
	f.seek(start + meta_len)
	return sprites

func parse_sounds():
	var sounds = {}
	var file : FileAccess = basewad
	for asset_name in basewad_asset_locations.keys():
		if asset_name.get_extension() == "wav":
			var location = basewad_asset_locations[asset_name]
			file.seek(basewad_asset_offset + location["start"])
			var start_location = file.get_position()
			var stream = AudioStreamWAV.new()
			
			var riff_found = false
			var wave_found = false
			var fmt_found = false
			var data_found = false
			while file.get_position() < start_location + location["len"] and !(riff_found and wave_found and fmt_found and data_found):
				var flag = file.get_buffer(4).get_string_from_ascii()
				if flag == "RIFF":
					riff_found = true
					file.seek(file.get_position() + 4)
				elif flag == "WAVE":
					wave_found = true
				elif flag == "fmt ":
					fmt_found = true
					file.seek(file.get_position() + 4)
					stream.format = file.get_16()
					stream.stereo = file.get_16() == 2
					stream.mix_rate = file.get_32()
					file.seek(file.get_position() + 8)
				elif flag == "data":
					data_found = true
					var data_size = file.get_32()
					stream.data = file.get_buffer(data_size)
					file.seek(file.get_position() + 4)
				else:
					file.seek(file.get_position() - 3)
			
			sounds[asset_name.replace(".wav", "").replace("Sounds/", "")] = stream
	return sounds
