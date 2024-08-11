extends TabBar

class_name GameplayTab

const TAB_INDEX = 3

var enemy_fractions = []
var curr_fraction = 0
var enemies = []
var curr_enemy_sprite = 0
var curr_enemy_sprites_len = 1
var active = false
var enemies_on_list = []
var weapons = []
static var weapon_ids = []

@onready var enemy_list = $"Enemies/Enemy List"
@onready var fraction_label = $"Enemies/Fraction Label"
@onready var weapon_list = $"Weapon List"
@onready var check_box = $CheckBox

func show_enemies():
	curr_enemy_sprite = 0
	curr_enemy_sprites_len = 1
	enemy_list.deselect_all()
	enemy_list.clear()
	enemies_on_list = []
	fraction_label.text = enemy_fractions[curr_fraction]
	for enemy in enemies:
		if enemy["fraction"] == enemy_fractions[curr_fraction]:
			enemy_list.add_item(enemy["name"], ObjectsLoader.sprites[enemy["sprites"][0]]["frames"][0])
			enemies_on_list.append(enemy)

func show_weapons():
	weapon_list.clear()
	var i = 0
	for w in weapons:
		weapon_list.add_icon_item(ObjectsLoader.sprites[w["sprite"]]["frames"][0])
		weapon_list.set_item_tooltip(i, w["name"])
		i += 1

func _on_Gameplay_ready():
	var enemies_tsv = FileAccess.open("res://enemies.tsv", FileAccess.READ)
	while !enemies_tsv.eof_reached():
		var params = enemies_tsv.get_csv_line("\t")
		if !params[0] in enemy_fractions:
			enemy_fractions.append(params[0])
		var sprites = Array(params[3].split(","))
		for _i in range(len(sprites)):
			sprites.push_front(int(sprites.pop_back()))
		enemies.append({
			"fraction": params[0],
			"name": params[1],
			"object": int(params[2]),
			"sprites": sprites
		})
	enemies_tsv.close()
	
	var weapons_tsv = FileAccess.open("res://weapons.tsv", FileAccess.READ)
	while !weapons_tsv.eof_reached():
		var params = weapons_tsv.get_csv_line("\t")
		weapons.append({
			"name": params[0],
			"object": int(params[1]),
			"sprite": int(params[2])
		})
		weapon_ids.append(int(params[1]))
	weapons_tsv.close()

func _on_TabContainer_tab_selected(tab):
	active = tab == TAB_INDEX
	if active:
		App.cursor.snap = 1
		show_enemies()
		show_weapons()
		App.cursor.outline = true
		App.cursor.region_enabled = false
	else:
		enemy_list.deselect_all()

func _on_Fraction_Back_Button_button_up():
	curr_fraction = (len(enemy_fractions) + curr_fraction - 1) % len(enemy_fractions)
	show_enemies()

func _on_Fraction_Forward_Button_button_up():
	curr_fraction = (curr_fraction + 1) % len(enemy_fractions)
	show_enemies()

func _on_Sprite_Back_Button_button_up():
	if enemy_list.is_anything_selected():
		curr_enemy_sprite = (curr_enemy_sprites_len + curr_enemy_sprite - 1) % curr_enemy_sprites_len
		enemy_list.set_item_icon(enemy_list.get_selected_items()[0], \
		 ObjectsLoader.sprites[enemies_on_list[enemy_list.get_selected_items()[0]]["sprites"][curr_enemy_sprite]]["frames"][0])
		App.cursor.texture = ObjectsLoader.sprites[enemies_on_list[enemy_list.get_selected_items()[0]]["sprites"][curr_enemy_sprite]]["frames"][0]
		App.cursor.offset = ObjectsLoader.sprites[enemies_on_list[enemy_list.get_selected_items()[0]]["sprites"][curr_enemy_sprite]]["center"]

func _on_Sprite_Forward_Button_button_up():
	if enemy_list.is_anything_selected():
		curr_enemy_sprite = (curr_enemy_sprite + 1) % curr_enemy_sprites_len
		enemy_list.set_item_icon(enemy_list.get_selected_items()[0], \
		 ObjectsLoader.sprites[enemies_on_list[enemy_list.get_selected_items()[0]]["sprites"][curr_enemy_sprite]]["frames"][0])
		App.cursor.texture = ObjectsLoader.sprites[enemies_on_list[enemy_list.get_selected_items()[0]]["sprites"][curr_enemy_sprite]]["frames"][0]
		App.cursor.offset = ObjectsLoader.sprites[enemies_on_list[enemy_list.get_selected_items()[0]]["sprites"][curr_enemy_sprite]]["center"]

func _on_Enemy_List_item_selected(index):
	weapon_list.deselect_all()
	curr_enemy_sprite = 0
	App.cursor.rotation_degrees = 0
	curr_enemy_sprites_len = len(enemies_on_list[index]["sprites"])
	App.cursor.texture = ObjectsLoader.sprites[enemies_on_list[enemy_list.get_selected_items()[0]]["sprites"][curr_enemy_sprite]]["frames"][0]
	App.cursor.offset = ObjectsLoader.sprites[enemies_on_list[enemy_list.get_selected_items()[0]]["sprites"][curr_enemy_sprite]]["center"]

func _on_Weapon_List_item_selected(_index):
	enemy_list.deselect_all()
	App.cursor.rotation_degrees = 0
	App.cursor.texture = ObjectsLoader.sprites[weapons[weapon_list.get_selected_items()[0]]["sprite"]]["frames"][0]
	App.cursor.offset = ObjectsLoader.sprites[weapons[weapon_list.get_selected_items()[0]]["sprite"]]["center"]

func _unhandled_input(event: InputEvent):
	if active and event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_LEFT:
				if enemy_list.is_anything_selected():
					var enemy = enemies_on_list[enemy_list.get_selected_items()[0]]
					var obj = ObjectsLoader.objects[enemy["object"]].clone()
					obj.sprite_id = enemy["sprites"][curr_enemy_sprite]
					var object_sprite = ObjectSprite.new(obj, 0, TAB_INDEX, 10)
					App.add_object(object_sprite)
				elif weapon_list.is_anything_selected():
					if check_box.button_pressed:
						App.cursor.rotation_degrees = int(randf() * 360)
					var weapon = weapons[weapon_list.get_selected_items()[0]]
					var obj = ObjectsLoader.objects[weapon["object"]].clone()
					obj.sprite_id = weapon["sprite"]
					var object_sprite = ObjectSprite.new(obj, 0, TAB_INDEX, 2401)
					App.add_object(object_sprite)
			elif event.button_index == MOUSE_BUTTON_RIGHT:
				if Input.is_key_pressed(KEY_SHIFT):
					App.cursor.rotation_degrees = round(App.cursor.rotation_degrees - 90)
					get_viewport().set_input_as_handled()
			elif event.button_index == MOUSE_BUTTON_WHEEL_UP or event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				var dir = 1
				if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
					dir = -1
				if Input.is_key_pressed(KEY_SHIFT):
					App.cursor.rotation_degrees = round(App.cursor.rotation_degrees - 15 * dir)
					get_viewport().set_input_as_handled()
				elif Input.is_key_pressed(KEY_CTRL):
					App.cursor.rotation_degrees = round(App.cursor.rotation_degrees - dir)
					get_viewport().set_input_as_handled()
	elif active and event is InputEventKey:
		if event.is_pressed() and event.keycode == KEY_ESCAPE:
			enemy_list.deselect_all()
			weapon_list.deselect_all()
			App.cursor.texture = null
