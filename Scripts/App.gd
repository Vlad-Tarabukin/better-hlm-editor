extends Node2D

signal objects_loaded

var mode = 0
var submode = 0
var level = 0
var level_path
var level_info = {}
var selected_object : ObjectSprite

@onready var cursor = get_tree().get_root().get_node("Main/Cursor")

func _ready():
	ObjectsLoader.load_sprites_info()
	ObjectsLoader.load_sprites()
	objects_loaded.emit()
	
	get_tree().get_root().get_node("Main/CanvasLayer/Level List").set_visible(true)
	get_tree().get_root().get_node("Main/CanvasLayer/Main GUI").set_visible(false)

func _draw():
	if level_info.has("level_boundaries"):
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

func get_current_floor() -> Floor:
	return get_tree().get_root().get_node("Main/Floors/Floor" + str(level))

func add_floor():
	level_info["floors"] += 1
	var level_floor = Floor.new(level_info["floors"])
	level_floor.visible = false
	get_tree().get_root().get_node("Main/Floors").add_child(level_floor)

func load_level(_level_path):
	level_path = _level_path
	
	get_tree().get_root().get_node("Main/Floors")
	
	var mods = DirAccess.get_files_at(level_path + "/mods")
	for mod in mods:
		if mod.match("*.patchwad"):
			ObjectsLoader.load_sprites(level_path + "/mods/" + mod)
	
	get_tree().get_root().get_node("Main/CanvasLayer/Level List").set_visible(false)
	get_tree().get_root().get_node("Main/CanvasLayer/Main GUI").set_visible(true)
	
	var floors_node = get_tree().get_root().get_node("Main/Floors")
	var file = FileAccess.open(level_path + "/level.hlm", FileAccess.READ)
	level_info["name"] = file.get_line()
	level_info["floors"] = int(file.get_line())
	level_info["author"] = file.get_line()
	file.get_line()
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
		level_floor.visible = i == 0
		level_floor.load_floor(level_path + "/level" + str(i) + ".obj")
		level_floor.load_floor(level_path + "/level" + str(i) + ".tls")
		level_floor.load_floor(level_path + "/level" + str(i) + ".wll")
		level_floor.load_floor(level_path + "/level" + str(i) + ".npc")
		level_floor.load_floor(level_path + "/level" + str(i) + ".itm")
		level_floor.load_floor(level_path + "/level" + str(i) + ".csf")
		floors_node.add_child(level_floor)
	queue_redraw()
	get_tree().get_root().get_node("Main/CanvasLayer").show_levels()
	get_tree().get_root().get_node("Main/CanvasLayer/Main GUI/Panel/TabContainer/Level").show_level_info()

func save_level():
	var file = FileAccess.open(level_path + "/level.hlm", FileAccess.WRITE)
	file.store_line(level_info["name"])
	file.store_line(str(level_info["floors"]))
	file.store_line(level_info["author"])
	file.store_line("1")
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
		level_floor.save()

func _unhandled_input(event):
	if event is InputEventKey and event.is_pressed():
		if event.keycode == KEY_O:
			if level_path:
				OS.shell_show_in_file_manager(level_path)
