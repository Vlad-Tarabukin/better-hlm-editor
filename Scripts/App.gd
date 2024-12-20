extends Node2D

signal objects_loaded

var mode = 0
var submode = 0
var level = 0
var level_path
var level_hlm_prefix
var level_prefix
var level_info = {}
var moving_object : ObjectSprite
var undo_redo : UndoRedo = UndoRedo.new()
var settings = {"grid": true, "wall": true, "transition": true, "rain": true,
 "border": true, "collision": false, "center": false}
var custom_folder_path = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS) + "/My Games/Better HLM Editor/"

@onready var cursor = get_tree().get_root().get_node("Main/Cursor")
@onready var waypoints = get_tree().get_root().get_node("Main/Waypoints")

func _ready():
	ObjectsLoader.load_info()
	ObjectsLoader.load_wads(null)
	objects_loaded.emit()
	
	get_tree().get_root().get_node("Main/CanvasLayer/Level List").set_visible(true)
	get_tree().get_root().get_node("Main/CanvasLayer/Main GUI").set_visible(false)

func _draw():
	if settings["border"] and level_info.has("level_boundaries"):
		draw_rect(level_info["level_boundaries"], Color.RED, false)

func change_level_boundaries(left, top, right, bottom):
	var pos = Vector2i(left, top)
	level_info["level_boundaries"] = Rect2i(pos, Vector2i(right, bottom) - pos)
	queue_redraw()

func add_object(ob, cursor_transform=true):
	ob.level = level
	if cursor_transform:
		ob.global_transform = cursor.global_transform
	var floor_node = get_current_floor()
	floor_node.add_child(ob)

func set_floor(_floor):
	level = _floor
	var i = 0
	for level_floor in get_tree().get_root().get_node("Main/Floors").get_children():
		level_floor.visible = level == i
		i += 1

func get_floor(index) -> Floor:
	return get_tree().get_root().get_node("Main/Floors/Floor" + str(index))

func get_current_floor() -> Floor:
	return get_floor(level)

func add_floor():
	level_info["floors"] += 1
	var level_floor = Floor.new(level_info["floors"])
	get_tree().get_root().get_node("Main/Floors").add_child(level_floor)
	set_floor(level_info["floors"])

func duplicate_floor():
	var temp_folder = custom_folder_path + "_temp"
	if !DirAccess.dir_exists_absolute(temp_folder):
		DirAccess.make_dir_recursive_absolute(temp_folder)
	get_current_floor().save_floor(temp_folder + '/temp')
	add_floor()
	var new_floor = get_current_floor()
	new_floor.load_floor(temp_folder + "/temp" + ".obj")
	new_floor.load_floor(temp_folder + "/temp" + ".tls")
	new_floor.load_floor(temp_folder + "/temp" + ".wll")
	new_floor.load_floor(temp_folder + "/temp" + ".npc")
	new_floor.load_floor(temp_folder + "/temp" + ".itm")
	new_floor.load_floor(temp_folder + "/temp" + ".csf")

func delete_floor():
	get_current_floor().queue_free()
	level_info["floors"] -= 1
	await get_current_floor().tree_exited
	for i in range(level + 1, level_info["floors"] + 2):
		get_floor(i).set_index(i - 1)
	set_floor(max(level - 1, 0))

func load_level(_level_path):
	var prefix_index = _level_path.rfind("/") + 1
	level_path = _level_path.substr(0, prefix_index)
	level_hlm_prefix = _level_path.substr(prefix_index)
	level_prefix = level_hlm_prefix + ("_" if level_hlm_prefix.right(1).is_valid_int() else "")
	
	for fl in get_tree().get_root().get_node("Main/Floors").get_children():
		fl.queue_free()
	
	var mods = []
	var level_mods_path = level_path + "/mods/"
	if DirAccess.dir_exists_absolute(level_mods_path):
		for mod in DirAccess.get_files_at(level_mods_path):
			if mod.get_extension() == "patchwad":
				mods.append(level_mods_path + mod)
		ObjectsLoader.load_wads(mods)
	else:
		DirAccess.make_dir_recursive_absolute(level_mods_path)
		ObjectsLoader.load_wads(null)
	
	get_tree().get_root().get_node("Main/CanvasLayer/Level List").set_visible(false)
	get_tree().get_root().get_node("Main/CanvasLayer/Main GUI").set_visible(true)
	
	var floors_node = get_tree().get_root().get_node("Main/Floors")
	var file = FileAccess.open(level_path + "/" + level_hlm_prefix + ".hlm", FileAccess.READ)
	level_info["name"] = file.get_line()
	level_info["floors"] = int(file.get_line())
	level_info["author"] = file.get_line()
	level_info["cutscene"] = file.get_line() == "1"
	level_info["s_rank"] = int(file.get_line())
	level_info["character_id"] = int(file.get_line())
	file.get_line()
	level_info["mask_id"] = int(file.get_line())
	level_info["music_id"] = int(file.get_line())
	var left = int(file.get_line())
	var top = int(file.get_line())
	var right = int(file.get_line())
	var bottom = int(file.get_line())
	level_info["level_boundaries"] = Rect2(left, top, right - left, bottom - top)
	level_info["background_id"] = int(file.get_line())
	file.get_line()
	level_info["hour"] = file.get_line()
	level_info["minute"] = file.get_line()
	level_info["day"] = file.get_line()
	level_info["month"] = file.get_line()
	level_info["year"] = file.get_line()
	level_info["city"] = file.get_line()
	level_info["state"] = file.get_line()
	level_info["address"] = file.get_line()
	
	for i in range(level_info["floors"] + 1):
		var level_floor = Floor.new(i)
		level_floor.visible = false
		floors_node.add_child(level_floor)
	
	for i in range(level_info["floors"] + 1):
		var level_floor = floors_node.get_child(i)
		var start_path = level_path + "/" + level_prefix + str(i)
		if FileAccess.file_exists(start_path + ".obj") and FileAccess.file_exists(start_path + ".wll"):
			level_floor.load_floor(start_path + ".obj")
			level_floor.load_floor(start_path + ".wll")
		else:
			level_floor.load_floor(start_path + ".play")
		level_floor.load_floor(start_path + ".tls")
		level_floor.load_floor(start_path + ".npc")
		level_floor.load_floor(start_path + ".itm")
		level_floor.load_floor(start_path + ".csf")
	
	queue_redraw()
	get_tree().get_root().get_node("Main/CanvasLayer").show_levels()
	get_tree().get_root().get_node("Main/CanvasLayer/Main GUI/Panel/TabContainer/Level").show_level_info()
	get_tree().get_root().get_node("Main/CanvasLayer/Main GUI/Bottom-Left/Floor List").select(0)
	
	set_floor(0)
	undo_redo.clear_history()

func save_level():
	var file = FileAccess.open(level_path + "/" + level_hlm_prefix + ".hlm", FileAccess.WRITE)
	file.store_line(level_info["name"])
	file.store_line(str(level_info["floors"]))
	file.store_line(level_info["author"])
	file.store_line(str(int(level_info["cutscene"])))
	file.store_line(str(level_info["s_rank"]))
	file.store_line(str(level_info["character_id"]))
	file.store_line("1")
	file.store_line(str(level_info["mask_id"]))
	file.store_line(str(level_info["music_id"]))
	file.store_line(str(level_info["level_boundaries"].position.x))
	file.store_line(str(level_info["level_boundaries"].position.y))
	file.store_line(str(level_info["level_boundaries"].end.x))
	file.store_line(str(level_info["level_boundaries"].end.y))
	file.store_line(str(level_info["background_id"]))
	file.store_line("0")
	file.store_line(level_info["hour"])
	file.store_line(level_info["minute"])
	file.store_line(level_info["day"])
	file.store_line(level_info["month"])
	file.store_line(level_info["year"])
	file.store_line(level_info["city"])
	file.store_line(level_info["state"])
	file.store_line(level_info["address"])
	
	for level_floor in get_tree().get_root().get_node("Main/Floors").get_children():
		level_floor.save_floor()
