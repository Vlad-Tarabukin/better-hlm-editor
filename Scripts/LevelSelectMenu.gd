extends ItemList

@onready var uuid = preload("res://Scripts/uuid.gd")

var level_paths = []

func _on_visibility_changed():
	clear()
	level_paths = []
	add_item("-Create Level-")
	var levels_path = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS) + "/My Games/HotlineMiami2/Levels/single"
	var dir = DirAccess.open(levels_path)
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		var hlm_path = levels_path + "/" + file_name + "/level.hlm"
		if dir.current_is_dir() and dir.file_exists(hlm_path):
			var level_hlm = FileAccess.open(hlm_path, FileAccess.READ)
			var level_name = level_hlm.get_line()
			add_item(level_name)
			level_paths.append(levels_path + "/" + file_name)
		file_name = dir.get_next()

func new_folder():
	var path = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS) + "/My Games/HotlineMiami2/Levels/single/" + uuid.v4()
	var error = DirAccess.make_dir_recursive_absolute(path)
	while error != OK:
		path = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS) + "/My Games/HotlineMiami2/Levels/single/" + uuid.v4()
		error = DirAccess.make_dir_recursive_absolute(path)
	return path

func _on_Level_List_item_selected(index):
	if index == 0:
		var path = new_folder()
		DirAccess.copy_absolute("res://default_level.hlm", path + "/level.hlm")
		App.load_level(path)
		visible = false

func _on_load_button_button_up():
	if is_anything_selected():
		App.load_level(level_paths[get_selected_items()[0] - 1])
		visible = false

func _on_backup_button_button_up():
	if is_anything_selected():
		var path = level_paths[get_selected_items()[0] - 1]
		var new_path = new_folder()
		for file_name in DirAccess.get_files_at(path):
			DirAccess.copy_absolute(path + "/" + file_name, new_path + "/" + file_name)
		var new_hlm = FileAccess.open(path + "/level.hlm", FileAccess.READ).get_as_text().split("\n")
		new_hlm[0] = new_hlm[0] + " (backup {time})".format({"time": Time.get_datetime_string_from_system()})
		var hlm_file = FileAccess.open(new_path + "/level.hlm", FileAccess.WRITE)
		for st in new_hlm:
			hlm_file.store_line(st)
		hlm_file.close()
		App.load_level(path)
		visible = false
