extends TabBar

class_name LevelTab

var active
var start_pos
var trigger_rect
var placing_transition
var placing_elevator
var last_time_string
var characters = []
var cars = []
var object_to_place
var curr_player_sprite

const TAB_INDEX = 4

const TEXTURE = preload("res://Textures/transition.png")

@onready var name_line_edit = $"Name LineEdit"
@onready var author_line_edit = $"Author LineEdit"
@onready var city_line_edit = $"City LineEdit"
@onready var state_line_edit = $"State LineEdit"
@onready var address_line_edit = $"Address LineEdit"
@onready var time_line_edit = $"Time LineEdit"
@onready var music_option_button = $"Music OptionButton"
@onready var background_option_button = $"Background OptionButton"
@onready var character_option_button = $"Character OptionButton"
@onready var mask_spin_box = $"Mask SpinBox"
@onready var s_spin_box = $"S SpinBox"
@onready var top_bound_spin_box = $"Boundaries/Top Bound SpinBox"
@onready var left_bound_spin_box = $"Boundaries/Left Bound SpinBox"
@onready var right_bound_spin_box = $"Boundaries/Right Bound SpinBox"
@onready var bottom_bound_spin_box = $"Boundaries/Bottom Bound SpinBox"
@onready var player_item_list = $"Player ItemList"
@onready var car_item_list = $"Car ItemList"
@onready var sprite_h_slider = $"Sprite HSlider"
@onready var transition_panel = $"../../../Transition Panel"

func _on_TabContainer_tab_selected(tab):
	active = tab == TAB_INDEX
	if active:
		App.cursor.outline = false

func show_level_info():
	name_line_edit.text = App.level_info["name"]
	author_line_edit.text = App.level_info["author"]
	city_line_edit.text = App.level_info["city"]
	state_line_edit.text = App.level_info["state"]
	address_line_edit.text = App.level_info["address"]
	last_time_string = "{hour}:{minute} {day}/{month}/{year}".format(App.level_info)
	time_line_edit.text = last_time_string
	music_option_button.selected = App.level_info["music_id"]
	background_option_button.selected = background_option_button.get_item_index(App.level_info["background_id"])
	character_option_button.select(App.level_info["character_id"])
	mask_spin_box.set_value_no_signal(App.level_info["mask_id"])
	s_spin_box.set_value_no_signal(App.level_info["s_rank"])
	left_bound_spin_box.set_value_no_signal(App.level_info["level_boundaries"].position.x)
	top_bound_spin_box.set_value_no_signal(App.level_info["level_boundaries"].position.y)
	right_bound_spin_box.set_value_no_signal(App.level_info["level_boundaries"].end.x)
	bottom_bound_spin_box.set_value_no_signal(App.level_info["level_boundaries"].end.y)

func _on_boundaries_change(_value):
	App.change_level_boundaries(left_bound_spin_box.value, top_bound_spin_box.value, right_bound_spin_box.value, bottom_bound_spin_box.value)

func _unhandled_input(event):
	if active:
		if placing_transition:
			if event is InputEventMouseButton:
				if event.button_index == MOUSE_BUTTON_LEFT:
					if event.pressed:
						start_pos = GlobalCamera.get_mouse_position()
						App.cursor.texture = TEXTURE
						App.cursor.move = false
					else:
						trigger_rect = Rect2i(start_pos, GlobalCamera.get_mouse_position() - start_pos)
						$"../../../Transition Panel/Floor SpinBox".max_value = App.level_info["floors"] + 1
						transition_panel.set_visible(true)
					App.cursor.region_enabled = event.pressed
			elif event is InputEventMouseMotion and Input.is_mouse_button_pressed(1):
				App.cursor.region_rect = Rect2i(Vector2i.ZERO, GlobalCamera.get_mouse_position() - start_pos)
		elif placing_elevator:
			if event is InputEventMouseButton and event.pressed:
				if event.button_index == MOUSE_BUTTON_LEFT:
					$"../../../Transition Panel/Floor SpinBox".max_value = App.level_info["floors"] + 1
					transition_panel.set_visible(true)
					App.cursor.move = false
				elif event.button_index == MOUSE_BUTTON_RIGHT and Input.is_key_pressed(KEY_SHIFT):
					App.cursor.global_rotation_degrees += 90
		elif object_to_place:
			if event is InputEventMouseButton and event.pressed:
				if event.button_index == MOUSE_BUTTON_LEFT:
					var object = ObjectSprite.new(object_to_place, 0, LevelTab.TAB_INDEX, 1582)
					App.add_object(object)
					object_to_place = null
					App.cursor.texture = null
					player_item_list.deselect_all()
					car_item_list.deselect_all()
				elif event.button_index == MOUSE_BUTTON_RIGHT:
					if Input.is_key_pressed(KEY_SHIFT):
						App.cursor.rotation_degrees -= 90

func _on_transition_button_button_up():
	placing_transition = true
	placing_elevator = false
	object_to_place = null

func _on_elevator_button_button_up():
	placing_elevator = true
	placing_transition = false
	object_to_place = null
	var sprite = ObjectsLoader.get_sprite(1512)
	App.cursor.flip_v = true
	App.cursor.texture = sprite["frames"][-1]
	App.cursor.offset = sprite["center"]
	App.cursor.snap = 8
	$"../../../Transition Panel/Direction OptionButton".disabled = true

func _on_cancel_button_button_up():
	transition_panel.set_visible(false)
	App.cursor.texture = null
	App.cursor.move = true
	App.cursor.flip_v = false

func _on_ok_button_button_up():
	_on_cancel_button_button_up()
	if placing_transition:
		var direction = $"../../../Transition Panel/Direction OptionButton".get_selected_id()
		var target_floor = $"../../../Transition Panel/Floor SpinBox".value - 1
		var offset = Vector2i($"../../../Transition Panel/X SpinBox".value, $"../../../Transition Panel/Y SpinBox".value)
		var transition_sprite = TransitionSprite.new(trigger_rect, direction, target_floor, offset)
		App.add_object(transition_sprite, false)
		transition_sprite.global_position = start_pos
	elif placing_elevator:
		var target_floor = $"../../../Transition Panel/Floor SpinBox".value - 1
		var offset = Vector2i($"../../../Transition Panel/X SpinBox".value, $"../../../Transition Panel/Y SpinBox".value)
		var elevator_sprite = ElevatorSprite.new(target_floor, offset)
		App.add_object(elevator_sprite)
		$"../../../Transition Panel/Direction OptionButton".disabled = false
	placing_elevator = false
	placing_transition = false


func _on_name_line_edit_text_changed(new_text):
	App.level_info["name"] = new_text

func _on_author_line_edit_text_changed(new_text):
	App.level_info["author"] = new_text

func _on_city_line_edit_text_changed(new_text):
	App.level_info["city"] = new_text

func _on_state_line_edit_text_changed(new_text):
	App.level_info["state"] = new_text

func _on_address_line_edit_text_changed(new_text):
	App.level_info["address"] = new_text

const TIME_MASK = "??:?? ??/??/????"
func _on_time_line_edit_text_submitted(new_text: String):
	if new_text.length() == TIME_MASK.length():
		var is_valid = true
		for i in range(TIME_MASK.length()):
			is_valid = is_valid and (new_text[i] == TIME_MASK[i] or TIME_MASK[i] == "?" and new_text[i].is_valid_int())
		if is_valid:
			last_time_string = new_text
			App.level_info["hour"] = new_text.substr(0, 2)
			App.level_info["minute"] = new_text.substr(3, 2)
			App.level_info["day"] = new_text.substr(6, 2)
			App.level_info["month"] = new_text.substr(9, 2)
			App.level_info["year"] = new_text.substr(12, 4)
			return
	time_line_edit.text = last_time_string

func _ready():
	var music = FileAccess.open("res://music.txt", FileAccess.READ)
	while !music.eof_reached():
		music_option_button.add_item(music.get_line())
	var backgrounds = FileAccess.open("res://backgrounds.tsv", FileAccess.READ)
	while !backgrounds.eof_reached():
		var params = backgrounds.get_csv_line("\t")
		background_option_button.add_item(params[1], int(params[0]))
	var characters_file = FileAccess.open("res://characters.tsv", FileAccess.READ)
	while !characters_file.eof_reached():
		var params = characters_file.get_csv_line("\t")
		character_option_button.add_item(params[0], int(params[1]))
	var players = FileAccess.open("res://players.tsv", FileAccess.READ)
	while !players.eof_reached():
		var params = players.get_csv_line("\t")
		var sprites = []
		for i in params[2].split(","):
			sprites.append(int(i))
		characters.append({
			"object_name": params[0],
			"object_id": params[1],
			"sprites": sprites
		})
		player_item_list.add_item(params[0], ObjectsLoader.get_sprite(sprites[0])["frames"][0])
	var cars_file = FileAccess.open("res://cars.tsv", FileAccess.READ)
	while !cars_file.eof_reached():
		var params = cars_file.get_csv_line("\t")
		cars.append(HLMObject.new(int(params[1]), int(params[2])))
		car_item_list.add_item(params[0], ObjectsLoader.get_sprite(int(params[2]))["frames"][0])

func _on_music_option_button_item_selected(index):
	App.level_info["music_id"] = index

func _on_background_option_button_item_selected(index):
	App.level_info["background_id"] = background_option_button.get_item_id(index)

func _on_character_option_button_item_selected(index):
	App.level_info["character_id"] = index
	mask_spin_box.value = -1
	mask_spin_box.editable = bool(character_option_button.get_item_id(index))

func _on_mask_spin_box_value_changed(value):
	App.level_info["mask_id"] = value

func _on_player_item_list_item_selected(index):
	car_item_list.deselect_all()
	curr_player_sprite = 0
	sprite_h_slider.value = 0
	sprite_h_slider.max_value = len(characters[index]["sprites"]) - 1
	refresh_sprite()

func refresh_sprite():
	if player_item_list.is_anything_selected():
		var index = player_item_list.get_selected_items()[0]
		object_to_place = HLMObject.new(characters[index]["object_id"], characters[index]["sprites"][curr_player_sprite])
		var sprite = ObjectsLoader.get_sprite(characters[index]["sprites"][curr_player_sprite])
		App.cursor.texture = sprite["frames"][0]
		App.cursor.offset = sprite["center"]
		player_item_list.set_item_icon(index, sprite["frames"][0])
	elif car_item_list.is_anything_selected():
		var index = car_item_list.get_selected_items()[0]
		object_to_place = cars[index]
		var sprite = ObjectsLoader.get_sprite(cars[index].sprite_id)
		App.cursor.texture = sprite["frames"][0]
		App.cursor.offset = sprite["center"]
	else:
		App.cursor.texture = null
	sprite_h_slider.editable = player_item_list.is_anything_selected()

func _on_sprite_h_slider_value_changed(value):
	curr_player_sprite = int(value)
	refresh_sprite()

func _on_car_item_list_item_selected(index):
	player_item_list.deselect_all()
	refresh_sprite()

func _on_s_spin_box_value_changed(value):
	App.level_info["s_rank"] = value
