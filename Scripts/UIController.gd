extends CanvasLayer

@onready var tab_container = $"Main GUI/Panel/TabContainer"
@onready var floor_list = $"Main GUI/Floor List"
@onready var main_gui = $"Main GUI"

const PREVIEW_SCALE = 5

func _on_TabContainer_tab_selected(tab):
	App.mode = tab
	App.submode = 0
	App.cursor.texture = null
	App.cursor.move = true
	App.cursor.rotation_degrees = 0
	App.cursor.offset = Vector2.ZERO

func _on_Save_Button_button_up():
	App.save_level()
	
	var viewport = get_tree().get_root().get_node("Main/Screenshot SubViewport")
	for obj in viewport.get_children().slice(2):
		obj.queue_free()
	viewport.size = (App.level_info["level_boundaries"].size - App.level_info["level_boundaries"].position) * PREVIEW_SCALE
	for obj in get_tree().get_root().get_node("Main/Floors").get_children()[0].get_children():
		if obj is ObjectSprite or obj is TileSprite or obj is WallSprite or obj is DoorSprite or obj is ElevatorSprite or obj is DarknessSprite or obj is CutsceneSprite:
			var new_obj = obj.duplicate(0)
			new_obj.position *= PREVIEW_SCALE
			new_obj.scale *= PREVIEW_SCALE
			viewport.add_child(new_obj)
	await get_tree().create_timer(0.1, false).timeout
	viewport.get_texture().get_image().save_png(App.level_path + "/screen.png")

func _on_CanvasLayer_ready():
	var tab = 1
	tab_container.current_tab = tab
	App.mode = tab
	var size_factor = min(main_gui.size.y, 1080) / 1080
	tab_container.scale = Vector2.ONE * size_factor 
	tab_container.size.x = 360 / size_factor

func _on_floor_list_item_selected(index):
	App.set_floor(index)

func show_levels():
	floor_list.clear()
	for i in range(App.level_info["floors"] + 1):
		floor_list.add_item("Floor " + str(i + 1))

func _on_new_floor_button_button_up():
	App.add_floor()
	show_levels()

func _on_load_button_button_up():
	for i in tab_container.get_children():
		i.active = false
	ObjectsLoader.load_assets()
	for i in $"../Floors".get_children():
		i.queue_free()
	$"Main GUI".visible = false
	$"Level List".visible = true

func _on_undo_button_button_up():
	App.undo_redo.undo()

func _on_redo_button_button_up():
	App.undo_redo.redo()
