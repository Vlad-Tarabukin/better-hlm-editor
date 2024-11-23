extends CanvasLayer

@onready var tab_container = $"Main GUI/Panel/TabContainer"
@onready var floor_list = $"Main GUI/Bottom-Left/Floor List"
@onready var main_gui = $"Main GUI"
@onready var settings_menu_button = $"Main GUI/Buttons HBoxContainer/Settings MenuButton"
@onready var snap_menu_button = $"Main GUI/Buttons HBoxContainer/Snap MenuButton"
@onready var screenshot_panel = $"Main GUI/Screenshot Panel"

const MAX_SNAP = 8

func _on_TabContainer_tab_selected(tab):
	App.mode = tab
	App.submode = 0
	App.cursor.texture = null
	App.cursor.move = true
	App.cursor.rotation_degrees = 0
	App.cursor.offset = Vector2.ZERO

func _on_Save_Button_button_up():
	App.save_level()

func _process(delta):
	var size_factor = min(main_gui.size.y, 1080) / 1080
	tab_container.scale = Vector2.ONE * size_factor
	tab_container.size.y = 1080 * 1080 / main_gui.size.y
	tab_container.position.x = 360 * (1 - size_factor)

func _on_CanvasLayer_ready():
	var tab = 1
	tab_container.current_tab = tab
	App.mode = tab
	var size_factor = min(main_gui.size.y, 1080) / 1080
	tab_container.scale = Vector2.ONE * size_factor
	settings_menu_button.get_popup().hide_on_checkable_item_selection = false
	settings_menu_button.get_popup().index_pressed.connect(_on_settings_menu_button_pressed)
	snap_menu_button.get_popup().index_pressed.connect(_on_snap_menu_button_pressed)
	for i in range(MAX_SNAP):
		snap_menu_button.get_popup().add_radio_check_item(str(2 ** i) + "px", i + 1)
	snap_menu_button.get_popup().set_item_checked(1, true)
	App.cursor.snap_changed.connect(func(): 
		if App.cursor.snap == 0:
			_on_snap_menu_button_pressed(0)
		else:
			_on_snap_menu_button_pressed(int(log(App.cursor.snap) / log(2)) + 1))

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
	for i in $"../Floors".get_children():
		i.queue_free()
	$"Main GUI".visible = false
	$"Level List".visible = true
	App.level_path = ""

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
		if state:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_min_size(Vector2i(1080, 720))
			DisplayServer.window_set_size(DisplayServer.screen_get_size() - Vector2i(200, 200))
	elif index == 1:
		App.settings["grid"] = state
		GlobalCamera.queue_redraw()
	elif index == 2:
		App.settings["wall"] = state
		App.get_current_floor().queue_redraw()
	elif index == 3:
		App.settings["transition"] = state
		App.get_current_floor().queue_redraw()
	elif index == 4:
		App.settings["rain"] = state
		App.get_current_floor().queue_redraw()
	elif index == 5:
		App.settings["border"] = state
		App.queue_redraw()
	elif index == 6:
		App.settings["collision"] = state
		App.get_current_floor().propagate_call("queue_redraw")
	elif index == 7:
		App.settings["center"] = state
		App.get_current_floor().propagate_call("queue_redraw")

func _on_snap_menu_button_pressed(index):
	if !snap_menu_button.get_popup().is_item_checked(index):
		for i in range(MAX_SNAP + 1):
			snap_menu_button.get_popup().set_item_checked(i, i == index)
		if index == 0:
			App.cursor.snap = 0
		else:
			App.cursor.snap = 2 ** (index - 1)
		snap_menu_button.text = "Snap: " + snap_menu_button.get_popup().get_item_text(index)

func _on_screenshot_button_button_up():
	screenshot_panel.show_panel()

func _on_open_screenshot_button_button_up():
	var path = App.custom_folder_path + "screenshots"
	if !DirAccess.dir_exists_absolute(path):
		DirAccess.make_dir_recursive_absolute(path)
	OS.shell_show_in_file_manager(path)
