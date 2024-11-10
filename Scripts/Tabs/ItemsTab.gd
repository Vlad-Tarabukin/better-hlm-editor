extends TabBar

class_name ItemsTab

const TAB_INDEX = 1

@onready var item_list = $ItemList
@onready var texture_rect = $"Object Info/TextureRect"
@onready var name_label = $"Object Info/Name Label"
@onready var size_label = $"Object Info/Size Label"
@onready var frame_label = $"Object Info/Frame Label"
@onready var line_edit = $LineEdit

var active = false

var curr_obj = 0
var curr_frame = 0
var curr_frames_len = 1

var objects = []
var object_list = {}

func filter_list():
	item_list.clear()
	object_list = []
	var i = 0
	for o in objects:
		if (line_edit.text == "" or o.object_name.to_lower().count(line_edit.text.to_lower()) > 0):
			var texture = ObjectsLoader.get_sprite(o.sprite_id)["frames"][0]
			if texture != null:
				item_list.add_icon_item(texture)
				item_list.set_item_tooltip(i, o.object_name)
				object_list.append(o)
				i += 1

func _on_ItemList_item_selected(index):
	curr_obj = index
	var spr = ObjectsLoader.get_sprite(object_list[curr_obj].sprite_id)
	curr_frame = 0
	curr_frames_len = len(spr["frames"])
	
	refresh_sprite()
	name_label.text = object_list[index].object_name
	size_label.text = str(spr["frames"][0].get_width()) + " x " + str(spr["frames"][0].get_height())

func _on_BackButton_button_up():
	curr_frame = (curr_frames_len + curr_frame - 1) % curr_frames_len
	refresh_sprite()

func _on_ForwardButton_button_up():
	curr_frame = (curr_frame + 1) % curr_frames_len
	refresh_sprite()

func refresh_sprite():
	if item_list.is_anything_selected():
		var spr = ObjectsLoader.get_sprite(object_list[curr_obj].sprite_id)
		var texture = spr["frames"][curr_frame]
		texture_rect.texture = texture
		frame_label.text = str(curr_frame + 1) + " / " + str(curr_frames_len)
		App.cursor.texture = texture
		App.cursor.offset = spr["center"]
	else:
		texture_rect.texture = null
		App.cursor.texture = null
		name_label.text = ""
		size_label.text = ""
		frame_label.text = ""

func refresh_list():
	filter_list()
	refresh_sprite()

func set_filter(filter):
	line_edit.text = filter
	refresh_list()

func _on_LineEdit_text_changed(_new_text):
	refresh_list()

func _on_TabContainer_tab_selected(tab):
	active = tab == TAB_INDEX
	if active:
		App.cursor.snap = 1
		refresh_list()
		App.cursor.outline = true
		App.cursor.region_enabled = false
	else:
		item_list.deselect_all()

func _unhandled_input(event: InputEvent):
	if active and event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_LEFT:
				if item_list.is_anything_selected():
					var object_sprite = ObjectSprite.new(object_list[curr_obj], curr_frame, 1)
					App.add_object(object_sprite)
			elif event.button_index == MOUSE_BUTTON_RIGHT:
				if Input.is_key_pressed(KEY_SHIFT):
					App.cursor.rotation_degrees = round(App.cursor.rotation_degrees - 90)
					get_viewport().set_input_as_handled()
			elif event.button_index == MOUSE_BUTTON_WHEEL_UP or event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				var dir = 1
				if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
					dir = -1
				if Input.is_key_pressed(KEY_ALT):
					if dir == 1:
						_on_ForwardButton_button_up()
					else:
						_on_BackButton_button_up()
					get_viewport().set_input_as_handled()
				elif Input.is_key_pressed(KEY_SHIFT):
					App.cursor.rotation_degrees = round(App.cursor.rotation_degrees - 15 * dir)
					get_viewport().set_input_as_handled()
				elif Input.is_key_pressed(KEY_CTRL):
					App.cursor.rotation_degrees = round(App.cursor.rotation_degrees - dir)
					get_viewport().set_input_as_handled()
	elif active and event is InputEventKey:
		if event.is_pressed() and event.keycode == KEY_ESCAPE:
			item_list.deselect_all()
			refresh_sprite()

func _ready():
	var objects_tsv_paths = []
	var custom_tsv_folder = App.custom_folder_path + "custom_tsv"
	if !DirAccess.dir_exists_absolute(custom_tsv_folder):
		DirAccess.make_dir_recursive_absolute(custom_tsv_folder)
	else:
		for tsv in DirAccess.get_files_at(custom_tsv_folder):
			objects_tsv_paths.append(custom_tsv_folder + "/" + tsv)
		for objects_tsv_path in objects_tsv_paths:
			var objects_tsv = FileAccess.open(objects_tsv_path, FileAccess.READ)
			while !objects_tsv.eof_reached():
				var st = objects_tsv.get_csv_line("\t")
				if st[0].is_valid_int() and ObjectsLoader.objects.has(int(st[0])) and st[2].is_valid_int() and st[3].is_valid_int():
					objects.append(HLMObject.new(int(st[0]), st[1], int(st[2]), -int(st[3]), 
					ObjectsLoader.objects[int(st[0])].mask_id))
					if !ObjectsLoader.sprites.has(objects[-1].sprite_id):
						objects[-1].sprite_id = -1
	
	objects.append_array(ObjectsLoader.objects.values())
