extends CanvasLayer

@onready var tab_container = $"Main GUI/Panel/TabContainer"
@onready var floor_list = $"Main GUI/Floor List"
@onready var main_gui = $"Main GUI"

func _on_TabContainer_tab_selected(tab):
	App.mode = tab
	App.submode = 0
	App.cursor.texture = null
	App.cursor.move = true
	App.cursor.rotation_degrees = 0
	App.cursor.offset = Vector2.ZERO

func _on_Save_Button_button_up():
	App.save_level()

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
	ObjectsLoader.load_sprites()
	for i in $"../Floors".get_children():
		i.queue_free()
	$"Main GUI".visible = false
	$"Level List".visible = true
