extends ItemList

@onready var uuid = preload("res://Scripts/uuid.gd")

var level_paths = []

func _on_Level_List_ready():
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

func _on_Level_List_item_selected(index):
	if index == 0:
		var path = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS) + "/My Games/HotlineMiami2/Levels/single/" + uuid.v4()
		var error = DirAccess.make_dir_recursive_absolute(path)
		while error != OK:
			path = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS) + "/My Games/HotlineMiami2/Levels/single/" + uuid.v4()
			error = DirAccess.make_dir_recursive_absolute(path)
		FileAccess.open(path + "/level.hlm", FileAccess.WRITE).store_string(FileAccess.open("res://default_level.hlm", FileAccess.READ).get_as_text())
		App.load_level(path)
	else:
		App.load_level(level_paths[index - 1])
	visible = false
