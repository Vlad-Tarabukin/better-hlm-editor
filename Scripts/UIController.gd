extends CanvasLayer

@onready var tab_container = $"Main GUI/Panel/TabContainer"
@onready var floor_list = $"Main GUI/Bottom-Left/Floor List"
@onready var main_gui = $"Main GUI"
@onready var settings_menu_button = $"Main GUI/Buttons HBoxContainer/Settings MenuButton"

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
	settings_menu_button.get_popup().hide_on_checkable_item_selection = false
	settings_menu_button.get_popup().index_pressed.connect(_on_settings_menu_button_pressed)

func _on_floor_list_item_selected(index):
	App.set_floor(index)

func show_levels():
	floor_list.clear()
	for i in range(App.level_info["floors"] + 1):
		floor_list.add_item("Floor " + str(i + 1))

func _on_new_floor_button_button_up():
	App.add_floor()
	show_levels()
	floor_list.select(App.level_info["floors"])

func _on_duplicate_floor_button_button_up():
	App.duplicate_floor()
	show_levels()
	floor_list.select(App.level_info["floors"])

func _on_delete_floor_button_button_up():
	if App.level_info["floors"] > 0:
		$"../Delete Floor ConfirmationDialog".show()

func _on_delete_floor_confirmation_dialog_confirmed():
	App.delete_floor()
	show_levels()
	floor_list.select(App.level)

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

func _on_quit_button_button_up():
	$"../Quit ConfirmationDialog".show()

func _on_quit_confirmation_dialog_confirmed():
	get_tree().quit()

func _on_open_button_button_up():
	OS.shell_show_in_file_manager(App.level_path)

func _on_settings_menu_button_pressed(index):
	var state = !settings_menu_button.get_popup().is_item_checked(index)
	settings_menu_button.get_popup().set_item_checked(index, state)
	if index == 0:
		App.settings["grid"] = state
		GlobalCamera.queue_redraw()
	elif index == 1:
		App.settings["wall"] = state
		App.get_current_floor().queue_redraw()
	elif index == 2:
		App.settings["transition"] = state
		App.get_current_floor().queue_redraw()
	elif index == 3:
		App.settings["rain"] = state
		App.get_current_floor().queue_redraw()
	elif index == 4:
		App.settings["border"] = state
		App.queue_redraw()
