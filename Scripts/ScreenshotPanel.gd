extends Panel

@onready var texture_rect = $ScrollContainer/TextureRect
@onready var start_x_spin_box = $"Start X SpinBox"
@onready var start_y_spin_box = $"Start Y SpinBox"
@onready var end_x_spin_box = $"End X SpinBox"
@onready var end_y_spin_box = $"End Y SpinBox"
@onready var file_name_line_edit = $"File Name LineEdit"
@onready var save_button = $"Save Button"
@onready var checkboxes = $VBoxContainer.get_children()
var viewport

func _on_checkbox_toggled(_toggled_on):
	checkboxes[4].disabled = !checkboxes[3].button_pressed
	for i in range(len(checkboxes)):
		viewport.get_child(0).get_child(i).visible = checkboxes[i].button_pressed and !checkboxes[i].disabled

func _ready():
	for checkbox in checkboxes:
		checkbox.toggled.connect(_on_checkbox_toggled)

func calculate_size():
	viewport.get_child(0).position = -Vector2(start_x_spin_box.value, start_y_spin_box.value)
	viewport.size.x = end_x_spin_box.value - start_x_spin_box.value
	viewport.size.y = end_y_spin_box.value - start_y_spin_box.value
	start_x_spin_box.max_value = end_x_spin_box.value - 1
	start_y_spin_box.max_value = end_y_spin_box.value - 1
	end_x_spin_box.min_value = start_x_spin_box.value + 1
	end_y_spin_box.min_value = start_y_spin_box.value + 1

func _spinbox_on_value_changed(_value):
	calculate_size()

func _process(_delta):
	if visible:
		texture_rect.texture = viewport.get_texture()

func show_panel():
	viewport = get_tree().get_root().get_node("Main/Screenshot SubViewport")
	var viewport_main = viewport.get_child(0)
	for checkbox in checkboxes:
		checkbox.button_pressed = true
	for category in viewport_main.get_children():
		for obj in category.get_children():
			obj.queue_free()
	for obj in App.get_current_floor().get_children():
		if obj.visible:
			if obj is WallSprite:
				viewport_main.get_child(0).add_child(obj.duplicate(0))
			elif obj is TileSprite:
				if obj.submode == 0:
					viewport_main.get_child(1).add_child(obj.duplicate(0))
				else:
					viewport_main.get_child(2).add_child(obj.duplicate(0))
			elif obj is ObjectSprite or obj is ElevatorSprite or obj is CutsceneSprite:
				if int(obj.rotation_degrees) % 90 == 0:
					viewport_main.get_child(3).add_child(obj.duplicate(0))
				else:
					viewport_main.get_child(4).add_child(obj.duplicate(0))
			elif obj is DoorSprite:
				viewport_main.get_child(3).add_child(obj.duplicate(0))
			else:
				viewport_main.get_child(5).add_child(obj.duplicate(0))
	var boundaries_rect = App.level_info["level_boundaries"]
	start_x_spin_box.set_value_no_signal(boundaries_rect.position.x)
	start_y_spin_box.set_value_no_signal(boundaries_rect.position.y)
	end_x_spin_box.set_value_no_signal(boundaries_rect.end.x)
	end_y_spin_box.set_value_no_signal(boundaries_rect.end.y)
	calculate_size()
	visible = true

func _on_file_name_line_edit_text_changed(new_text):
	save_button.disabled = !(new_text + ".png").is_valid_filename()

func _on_save_button_button_up():
	var path = App.custom_folder_path + "screenshots/"
	if !DirAccess.dir_exists_absolute(path):
		DirAccess.make_dir_recursive_absolute(path)
	viewport.get_texture().get_image().save_png(path + file_name_line_edit.text + ".png")

func _on_close_button_button_up():
	visible = false
