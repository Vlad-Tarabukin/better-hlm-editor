extends ItemList

@onready var uuid = preload("res://Scripts/uuid.gd")

var level_paths = []

const SINGLE_COVER = preload("res://Textures/single_cover.png")
const CAMPAIGN_COVER = preload("res://Textures/campaign_cover.png")

func get_cover(path, single):
	var image = Image.load_from_file(path)
	if image:
		return ImageTexture.create_from_image(image)
	else:
		return SINGLE_COVER if single else CAMPAIGN_COVER

func _on_visibility_changed():
	clear()
	level_paths = [null, null]
	add_item("- Create a New Level -")
	add_item("Single Levels", null, false)
	
	var single_levels_path = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS) + "/My Games/HotlineMiami2/Levels/single"
	var single_levels_dir = DirAccess.open(single_levels_path)
	single_levels_dir.list_dir_begin()
	var file_name = single_levels_dir.get_next()
	while file_name != "":
		var hlm_path = single_levels_path + "/" + file_name + "/level.hlm"
		if single_levels_dir.current_is_dir() and single_levels_dir.file_exists(hlm_path):
			var level_hlm = FileAccess.open(hlm_path, FileAccess.READ)
			add_item("   " + level_hlm.get_line(), get_cover(single_levels_path + "/" + file_name + "/level.png", true))
			level_paths.append(single_levels_path + "/" + file_name + "/level")
		file_name = single_levels_dir.get_next()
	
	add_item("Campaigns", null, false)
	level_paths.append(null)
	
	var campaigns_path = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS) + "/My Games/HotlineMiami2/Levels/campaigns"
	var campaigns_dir = DirAccess.open(campaigns_path)
	campaigns_dir.list_dir_begin()
	file_name = campaigns_dir.get_next()
	while file_name != "":
		var cpg_path = campaigns_path + "/" + file_name + "/campaign.cpg"
		if campaigns_dir.current_is_dir() and campaigns_dir.file_exists(cpg_path):
			var campaign_cpg = FileAccess.open(cpg_path, FileAccess.READ)
			add_item("   " + campaign_cpg.get_line(), get_cover(campaigns_path + "/" + file_name + "/campaign.png", false), false)
			level_paths.append(campaigns_path + "/" + file_name + "/" + file_name)
			campaign_cpg.get_line()
			var level_count = int(campaign_cpg.get_line())
			for i in range(level_count):
				var paths = ["/intro" + str(i), "/main" + str(i), "/outro" + str(i)]
				for path in paths:
					if campaigns_dir.file_exists(campaigns_path + "/" + file_name + path + ".hlm"):
						var level_hlm = FileAccess.open(campaigns_path + "/" + file_name + path + ".hlm", FileAccess.READ)
						add_item("      " + level_hlm.get_line(), get_cover(campaigns_path + "/" + file_name + "/main" + str(i) + ".png", true))
						level_paths.append(campaigns_path + "/" + file_name + path)
		file_name = campaigns_dir.get_next()

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
		FileAccess.open(path + "/level.hlm", FileAccess.WRITE).store_string(FileAccess.open("res://default_level.hlm", FileAccess.READ).get_as_text())
		App.load_level(path + "/level")
		visible = false

func _on_load_button_button_up():
	if is_anything_selected():
		App.load_level(level_paths[get_selected_items()[0]])
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
