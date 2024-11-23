extends Node

class_name WadParser

const FILTERS = ["Atlases/*", "Sounds/*"]

var constant_files = load_constant_wads()
var files = {}

func parse_wads(file_paths): 
	var result = {}
	var r_file_paths = file_paths.duplicate()
	r_file_paths.reverse()
	for file_path in r_file_paths:
		var file = FileAccess.open(file_path, FileAccess.READ)
		file.seek(16)
		var asset_locations = {}
		var assets_amount = file.get_32()
		for _i in range(assets_amount):
			var asset_name = file.get_buffer(file.get_32()).get_string_from_ascii()
			if !result.has(asset_name) and FILTERS.any(func(x): return asset_name.match(x)):
				asset_locations[asset_name] = {}
				asset_locations[asset_name]["len"] = file.get_64()
				asset_locations[asset_name]["start"] = file.get_64()
			else:
				file.seek(file.get_position() + 16)
		var dirs_amount = file.get_32()
		for _i in range(dirs_amount):
			var dir_name_len = file.get_32()
			file.seek(file.get_position() + dir_name_len)
			var entries_amount = file.get_32()
			for _j in range(entries_amount):
				var entry_name_len = file.get_32()
				file.seek(file.get_position() + 1 + entry_name_len)
		var files_position = file.get_position()
		for asset_name in asset_locations:
			file.seek(files_position + asset_locations[asset_name]["start"])
			result[asset_name] = WadFile.new(file.get_buffer(asset_locations[asset_name]["len"]))
		file.close()
	return result

func load_constant_wads():
	var mods = ["res://base.wad"]
	var mods_path = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS) + "/My Games/HotlineMiami2/mods/"
	if DirAccess.dir_exists_absolute(mods_path):
		for mod in DirAccess.get_files_at(mods_path):
			if mod.get_extension() == "patchwad":
				mods.append(mods_path + mod)
	else:
		DirAccess.make_dir_recursive_absolute(mods_path)
	return parse_wads(mods)

func load_wads(wads):
	if wads:
		files = parse_wads(wads)
		files.merge(constant_files)
	else:
		files = constant_files.duplicate()
