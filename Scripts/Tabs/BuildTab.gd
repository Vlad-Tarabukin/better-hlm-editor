extends TabBar

class_name BuildTab

const TAB_INDEX = 0

var active
var start_pos
var curr_tiles
var curr_pos
var curr_wall
var corner_mode
var curr_barrier

var erase_texture = preload("res://Textures/tile_erase.png")

@onready var tile_select = $TileSelect
@onready var option_button = $OptionButton
@onready var check_box = $CheckBox
@onready var wall_panel = $"Wall Panel"
@onready var corner_select = $"CornerSelect"
@onready var barrier_button = $"Barrier Button"
@onready var entry_button = $"Entry Button"
@onready var door_button = $"Door Button"
@onready var direction_option_button = $"Direction OptionButton"
@onready var locked_check_box = $"Locked CheckBox"
@onready var cutscene_check_box = $"Cutscene CheckBox"

func _on_TabContainer_tab_selected(tab):
	active = tab == TAB_INDEX
	if active:
		option_button.select(0)
		curr_tiles = 0
		App.cursor.texture = ObjectsLoader.tiles[0]["tiles"]["0 0"]
		App.cursor.snap = 16
		App.cursor.region_rect = Rect2i(0, 0, 16, 16)
		App.cursor.offset = Vector2i.ZERO
		refresh_tiles()
		App.cursor.outline = false
		App.cursor.region_enabled = true

func refresh_tiles():
	curr_pos = Vector2i.ZERO
	tile_select.texture = ObjectsLoader.tiles[curr_tiles]["tilemap"]
	tile_select.set_pos(null)
	tile_select.tile_size = ObjectsLoader.tiles[curr_tiles]["size"]
	App.cursor.texture = null
	App.cursor.snap = tile_select.tile_size
	App.cursor.region_rect = Rect2i(0, 0, tile_select.tile_size, tile_select.tile_size)

func set_tile(pos):
	curr_pos = pos
	curr_wall = null
	corner_mode = false
	corner_select.set_pos(null)
	wall_panel.set_pos(null)
	barrier_button.button_pressed = false
	entry_button.button_pressed = false
	door_button.button_pressed = false
	curr_barrier = null
	direction_option_button.visible = false
	locked_check_box.visible = false
	cutscene_check_box.visible = false
	App.cursor.region_enabled = true
	App.cursor.move = true
	App.submode = 0
	App.cursor.offset = Vector2.ZERO
	App.cursor.snap = tile_select.tile_size
	App.cursor.region_rect = Rect2i(0, 0, 16, 16)
	pos = str(pos.x) + " " + str(pos.y)
	if ObjectsLoader.tiles[curr_tiles]["tiles"].has(pos):
		App.cursor.texture = ObjectsLoader.tiles[curr_tiles]["tiles"][pos]
	else:
		App.cursor.texture = null

func set_wall(wall):
	curr_wall = wall
	curr_pos = null
	corner_mode = false
	corner_select.set_pos(null)
	tile_select.set_pos(null)
	barrier_button.button_pressed = false
	entry_button.button_pressed = false
	door_button.button_pressed = false
	curr_barrier = null
	direction_option_button.visible = false
	locked_check_box.visible = false
	cutscene_check_box.visible = false
	App.cursor.region_enabled = true
	App.cursor.move = true
	App.submode = 1
	App.cursor.offset = Vector2.ZERO
	App.cursor.snap = 32
	App.cursor.region_rect = Rect2i(0, 0, 32, 32)
	App.cursor.texture = curr_wall["texture"]
	
func set_corner(pos):
	curr_pos = pos
	corner_mode = true
	curr_wall = null
	wall_panel.set_pos(null)
	tile_select.set_pos(null)
	barrier_button.button_pressed = false
	entry_button.button_pressed = false
	door_button.button_pressed = false
	curr_barrier = null
	direction_option_button.visible = false
	locked_check_box.visible = false
	cutscene_check_box.visible = false
	App.cursor.move = true
	App.cursor.region_enabled = false
	App.submode = 2
	App.cursor.offset = Vector2.ZERO
	App.cursor.snap = 8
	pos = str(pos.x) + " " + str(pos.y)
	App.cursor.texture = ObjectsLoader.tiles[-1]["tiles"][pos]

func erase_tile_rect():
	var erase_rect = Rect2i(start_pos + App.cursor.region_rect.position, App.cursor.region_rect.size)
	var erase = App.get_current_floor().get_children().filter(func(obj): return obj.visible and obj is TileSprite and obj.depth == ObjectsLoader.tiles[curr_tiles]["depth"] and Rect2(obj.global_position, obj.get_rect().size).intersects(erase_rect))
	App.undo_redo.create_action("Remove tiles")
	App.undo_redo.add_do_method(func(): erase.map(func(obj): obj.set_visibile_no_register(false)))
	App.undo_redo.add_undo_method(func(): erase.map(func(obj): obj.set_visibile_no_register(true)))
	App.undo_redo.commit_action()

func erase_wall_rect():
	var erase_rect = Rect2i(start_pos + App.cursor.region_rect.position, App.cursor.region_rect.size)
	var erase = App.get_current_floor().get_children().filter(func(obj): return obj.visible and obj is WallSprite and Rect2(obj.global_position, obj.get_rect().size).intersects(erase_rect))
	App.undo_redo.create_action("Remove walls")
	App.undo_redo.add_do_method(func(): erase.map(func(obj): obj.set_visibile_no_register(false)))
	App.undo_redo.add_undo_method(func(): erase.map(func(obj): obj.set_visibile_no_register(true)))
	App.undo_redo.commit_action()

func snap_vector(vector):
	vector.x = floor(vector.x / App.cursor.snap) * App.cursor.snap
	vector.y = floor(vector.y / App.cursor.snap) * App.cursor.snap
	return vector

func _unhandled_input(event):
	if active:
		if event is InputEventMouseButton:
			if event.button_index == 1 and event.is_pressed():
				if corner_mode:
					var tile = TileSprite.new(ObjectsLoader.tiles[-1]["id"], curr_pos.x, curr_pos.y, ObjectsLoader.tiles[-1]["depth"], 2)
					App.add_object(tile)
				if door_button.button_pressed:
					var door = DoorSprite.new(DoorSprite.object_ids[direction_option_button.selected], int(locked_check_box.button_pressed), int(cutscene_check_box.button_pressed))
					App.add_object(door)
			if event.button_index == 2 and event.is_pressed() and curr_wall != null and Input.is_key_pressed(KEY_SHIFT):
				wall_panel.set_next_wall(curr_wall)
			if !corner_mode and !door_button.button_pressed and (event.button_index == 1 or event.button_index == 2 and Input.is_key_pressed(KEY_CTRL)) and event.is_pressed():
				start_pos = App.cursor.global_position
				App.cursor.move = false
				if event.button_index == 2 and curr_barrier == null:
					App.cursor.texture = erase_texture
				if curr_barrier:
					App.add_object(curr_barrier)
			if !corner_mode and !door_button.button_pressed and start_pos != null and !event.is_pressed():
				if curr_pos != null:
					if event.button_index == 1:
						if check_box.button_pressed:
							erase_tile_rect()
						var tiles = []
						for x in range(start_pos.x + App.cursor.region_rect.position.x, start_pos.x + App.cursor.region_rect.end.x, 16):
							for y in range(start_pos.y + App.cursor.region_rect.position.y, start_pos.y + App.cursor.region_rect.end.y, 16):
								var tile = TileSprite.new(ObjectsLoader.tiles[curr_tiles]["id"], curr_pos.x + ((x % tile_select.tile_size + tile_select.tile_size) % tile_select.tile_size), curr_pos.y + ((y % tile_select.tile_size + tile_select.tile_size) % tile_select.tile_size), ObjectsLoader.tiles[curr_tiles]["depth"])
								var pos = Vector2(x, y)
								pos.x = floor(pos.x / 16) * 16
								pos.y = floor(pos.y / 16) * 16
								tile.global_position = pos
								tile.register_creation = false
								tiles.append(tile)
								App.add_object(tile, false)
						App.cursor.region_rect = Rect2i(0, 0, tile_select.tile_size, tile_select.tile_size)
						
						App.undo_redo.create_action("Place tiles")
						App.undo_redo.add_do_method(func(): tiles.map(func(obj): obj.set_visibile_no_register(true)))
						App.undo_redo.add_undo_method(func(): tiles.map(func(obj): obj.set_visibile_no_register(false)))
						App.undo_redo.commit_action(false)
					elif event.button_index == 2 and Input.is_key_pressed(KEY_CTRL):
						erase_tile_rect()
						set_tile(curr_pos)
					elif event.button_index == 3:
						for obj in App.get_current_floor().get_children():
							if obj is TileSprite and obj.tile_id != 10 and Rect2(obj.global_position, obj.get_rect().size).has_point(GlobalCamera.get_mouse_position()):
								if obj.is_pixel_opaque(obj.to_local(GlobalCamera.get_mouse_position())):
									var index = option_button.get_item_index(obj.tile_id)
									option_button.select(index)
									_on_OptionButton_item_selected(index)
									set_tile(snap_vector(Vector2(obj.tile_x, obj.tile_y)))
					App.cursor.move = true
				elif curr_wall != null:
					if event.button_index == 1:
						var walls = []
						for x in range(start_pos.x + App.cursor.region_rect.position.x, start_pos.x + App.cursor.region_rect.end.x, 32):
							for y in range(start_pos.y + App.cursor.region_rect.position.y, start_pos.y + App.cursor.region_rect.end.y, 32):
								var wall = WallSprite.new(curr_wall["object_id"], curr_wall["sprite_id"])
								wall.global_position = snap_vector(Vector2i(x, y))
								wall.register_creation = false
								walls.append(wall)
								App.add_object(wall, false)
						App.cursor.region_rect = Rect2i(0, 0, 32, 32)
						
						App.undo_redo.create_action("Place walls")
						App.undo_redo.add_do_method(func(): walls.map(func(obj): obj.set_visibile_no_register(true)))
						App.undo_redo.add_undo_method(func(): walls.map(func(obj): obj.set_visibile_no_register(false)))
						App.undo_redo.commit_action(false)
					elif event.button_index == 2 and Input.is_key_pressed(KEY_CTRL):
						erase_wall_rect()
						set_wall(curr_wall)
					App.cursor.move = true
				elif curr_barrier != null:
					App.cursor.move = true
					curr_barrier = BarrierSprite.new()
					start_pos = null
				elif entry_button.button_pressed:
					App.cursor.move = true
					App.cursor.texture = null
					App.cursor.region_rect.position = start_pos
					var entry_sprite = EntrySprite.new(App.cursor.region_rect, direction_option_button.selected)
					App.add_object(entry_sprite, false)
					entry_button.button_pressed = false
					_on_entry_button_button_up()
					start_pos = null
					App.cursor.region_rect = Rect2(0, 0, 0, 0)
		if event is InputEventMouseMotion and !corner_mode and !door_button.button_pressed:
			if (Input.is_mouse_button_pressed(1) or Input.is_mouse_button_pressed(2) and Input.is_key_pressed(KEY_CTRL)) and start_pos != null:
				var pos = snap_vector(GlobalCamera.get_mouse_position())
				if curr_barrier == null:
					var size = snap_vector(pos - start_pos) + Vector2.ONE * App.cursor.snap
					if curr_wall != null and !Input.is_mouse_button_pressed(2):
						if curr_wall["horizontal"]:
							size.y = App.cursor.snap
						else:
							size.x = App.cursor.snap
					if entry_button.button_pressed:
						size.x = max(8, size.x)
						size.y = max(8, size.y)
						if direction_option_button.selected % 2 == 0:
							size.x = App.cursor.snap
						else:
							size.y = App.cursor.snap
					var offset = Vector2(min(size.x, 0), min(size.y, 0))
					App.cursor.global_position = start_pos + offset
					App.cursor.region_rect = Rect2(offset, size.abs())
				else:
					var line_vector = Vector2(pos - start_pos)
					curr_barrier.rotation = line_vector.angle()
					curr_barrier.set_lenght(line_vector.length() / 16)
					curr_barrier.queue_redraw()

func _on_Build_ready():
	for tile in ObjectsLoader.tiles.slice(0, -1):
		option_button.add_item(tile["title"], tile["id"])

func _on_OptionButton_item_selected(index):
	curr_tiles = index
	refresh_tiles()

func _on_barrier_button_button_up():
	curr_wall = null
	curr_pos = null
	corner_mode = false
	wall_panel.set_pos(null)
	corner_select.set_pos(null)
	tile_select.set_pos(null)
	entry_button.button_pressed = false
	door_button.button_pressed = false
	App.cursor.texture = null
	direction_option_button.visible = entry_button.button_pressed or door_button.button_pressed
	locked_check_box.visible = false
	cutscene_check_box.visible = false
	App.cursor.offset = Vector2.ZERO
	if barrier_button.button_pressed:
		App.cursor.move = true
		App.cursor.region_enabled = false
		curr_barrier = BarrierSprite.new()
		App.submode = 3
		App.cursor.offset = Vector2.ZERO
		App.cursor.snap = 8

func _on_entry_button_button_up():
	curr_wall = null
	curr_pos = null
	corner_mode = false
	wall_panel.set_pos(null)
	corner_select.set_pos(null)
	tile_select.set_pos(null)
	curr_barrier = null
	barrier_button.button_pressed = false
	door_button.button_pressed = false
	App.cursor.texture = EntrySprite.TEXTURE
	direction_option_button.visible = entry_button.button_pressed or door_button.button_pressed
	locked_check_box.visible = false
	cutscene_check_box.visible = false
	App.cursor.offset = Vector2.ZERO
	if entry_button.button_pressed:
		App.cursor.move = true
		App.cursor.region_enabled = true
		App.submode = 4
		App.cursor.offset = Vector2.ZERO
		App.cursor.snap = 8
		App.cursor.region_rect = Rect2i(0, 0, 8, 8)

func _on_door_button_button_up():
	curr_wall = null
	curr_pos = null
	corner_mode = false
	wall_panel.set_pos(null)
	corner_select.set_pos(null)
	tile_select.set_pos(null)
	curr_barrier = null
	barrier_button.button_pressed = false
	entry_button.button_pressed = false
	direction_option_button.visible = entry_button.button_pressed or door_button.button_pressed
	locked_check_box.visible = door_button.button_pressed
	cutscene_check_box.visible = door_button.button_pressed
	if door_button.button_pressed:
		var sprite = ObjectsLoader.get_sprite(DoorSprite.sprite_ids[direction_option_button.selected])
		App.cursor.texture = sprite["frames"][0]
		App.cursor.offset = sprite["center"]
		App.cursor.move = true
		App.cursor.region_enabled = false
		App.submode = 5
		App.cursor.snap = 32

func _on_direction_option_button_item_selected(index):\
	if door_button.button_pressed:
		var sprite = ObjectsLoader.get_sprite(DoorSprite.sprite_ids[direction_option_button.selected])
		App.cursor.texture = sprite["frames"][0]
		App.cursor.offset = sprite["center"]

func _on_main_objects_loaded():
	corner_select.texture = ObjectsLoader.tiles[-1]["tilemap"]
