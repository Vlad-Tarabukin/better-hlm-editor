extends Node

class_name WadSpriteParser

static var basewad
static var basewad_asset_locations
static var basewad_asset_offset
static var modified = []

func parse_sprites(file_path, base):
	if base and len(modified) > 0:
		return reload_modified()
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
				sprites.merge(parse_meta(file, meta_location["len"], image_buffer))
	else:
		for asset_name in asset_locations.keys():
			if asset_name.get_extension() == "png":
				modified.append(asset_name)
				var meta_location = basewad_asset_locations[asset_name.replace(".png", ".meta")]
				var image_location = asset_locations[asset_name]
				file.seek(asset_offset + image_location["start"])
				var image_buffer = file.get_buffer(image_location["len"])
				basewad.seek(basewad_asset_offset + meta_location["start"])
				sprites.merge(parse_meta(basewad, meta_location["len"], image_buffer))
	file.close()
	return sprites

func parse_meta(file:FileAccess, meta_len, image_buffer:PackedByteArray):
	var sprites = {}
	var f = file
	var start = f.get_position()
	f.seek(start + 24)
	var page = Image.new()
	page.load_png_from_buffer(image_buffer)
	while f.get_position() - start < meta_len:
		var sprite_name_len = f.get_8()
		var sprite_name = f.get_buffer(sprite_name_len).get_string_from_ascii().split("/")[-1]
		var frames_amount = f.get_32()
		sprites[sprite_name] = []
		for _i in range(frames_amount):
			f.seek(f.get_position() + 4)
			var width = f.get_32()
			var height = f.get_32()
			var x = f.get_32()
			var y = f.get_32()
			f.seek(f.get_position() + 16)
			var image = page.get_region(Rect2i(x, y, width, height))
			var texture = ImageTexture.create_from_image(image)
			sprites[sprite_name].append(texture)
	f.seek(start + meta_len)
	return sprites

func reload_modified():
	var sprites = {}
	for asset_name in modified:
		var meta_location = basewad_asset_locations[asset_name.replace(".png", ".meta")]
		var image_location = basewad_asset_locations[asset_name]
		basewad.seek(basewad_asset_offset + image_location["start"])
		var image_buffer = basewad.get_buffer(image_location["len"])
		basewad.seek(basewad_asset_offset + meta_location["start"])
		sprites.merge(parse_meta(basewad, meta_location["len"], image_buffer))
	modified.clear()
	return sprites
