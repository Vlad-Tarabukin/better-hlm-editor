extends ItemList

var level_paths = []

func _on_Level_List_ready():
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

func _on_Level_List_item_selected(index):
	App.load_level(level_paths[index])
	queue_free()
