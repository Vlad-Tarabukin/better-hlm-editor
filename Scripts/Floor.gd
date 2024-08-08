extends Node2D

class_name Floor

var index
var light_overlays = []
var rain = false
var rain_rects = []
var cutscene = {
	"rects": [],
	"frames": [],
	"npc": [],
	"items": []
}
var transition_markers = []

const WALL_HINT_COLOR = Color(0, 1, 0, 0.4)
const TRANSITION_HINT_COLOR = Color(1, 0, 0, 0.2)
const RAIN_TEXTURE = preload("res://Textures/rain.png")

func _init(_index):
	index = _index
	name = "Floor" + str(index)
	z_index = 99

func _draw():
	var floor_node = get_node_or_null("../Floor" + str(index - 1))
	if floor_node != null:
		for obj in floor_node.get_children():
			if obj is WallSprite:
				draw_rect(Rect2(obj.global_position, obj.get_rect().size), WALL_HINT_COLOR)
	if rain:
		for rect in rain_rects:
			draw_texture_rect(RAIN_TEXTURE, rect, true)
	
	for marker in transition_markers:
		var rect = marker.region_rect
		rect.position = marker.position + Vector2(marker.transition_offset)
		draw_rect(rect, TRANSITION_HINT_COLOR)
	
	for i in range(len(cutscene["rects"])):
		draw_rect(cutscene["rects"][i], Color.GREEN, false)
		draw_string(Control.new().get_theme_default_font(), cutscene["rects"][i].position + Vector2(0, 10), "Trigger " + str(i), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color.GREEN)

func load_floor(floor_path):
	var file = FileAccess.open(floor_path, FileAccess.READ)
	if file and file.get_length() > 0:
		if floor_path.get_extension() == "obj":
			while !file.eof_reached():
				var parent_id = int(file.get_line())
				var params = []
				var proper = true
				var params_amount = 6
				var rain_rects_amount
				if parent_id == 2297:
					params_amount = 9
				elif parent_id == 2411:
					params_amount = 4
				elif parent_id == 2412:
					params_amount = 7
				elif parent_id == 1417:
					params_amount = 4
				elif parent_id == 663:
					rain_rects_amount = int(file.get_line())
					params_amount = 4 * rain_rects_amount
				elif parent_id == 1770:
					light_overlays.append(int(file.get_line()))
					continue
				for _i in range(params_amount):
					var line = file.get_line()
					if line == "":
						proper = false
						break
					params.append(line)
				if !proper:
					break
				if parent_id == 2297:
					var trigger_rect = Rect2(int(params.pop_front()), int(params.pop_front()), int(float(params.pop_front()) * 16), int(float(params.pop_front()) * 16))
					trigger_rect.position -= trigger_rect.size / 2
					var hor_direction = max(min(int(params.pop_front()), 1), -1)
					var ver_direction = max(min(int(params.pop_front()), 1), -1)
					var target_floor = int(params.pop_front())
					var offset = Vector2(int(params.pop_front()), int(params.pop_front()))
					var direction = 0
					if hor_direction == 0 and ver_direction == -1:
						direction = 1
					elif hor_direction == -1 and ver_direction == 0:
						direction = 2
					elif hor_direction == 0 and ver_direction == 1:
						direction = 3
					
					var transition_sprite = TransitionSprite.new(trigger_rect, direction, target_floor, offset)
					transition_sprite.level = index
					transition_sprite.loaded = true
					add_child(transition_sprite)
				elif parent_id == 2410:
					var x = int(params.pop_front())
					var y = int(params.pop_front())
					var angle = int(params.pop_front())
					var target_floor = int(params.pop_front())
					var offset = Vector2i(int(params.pop_front()), int(params.pop_front()))
					
					var elevator_sprite = ElevatorSprite.new(target_floor, offset)
					elevator_sprite.level = index
					elevator_sprite.global_position = Vector2(x, y)
					elevator_sprite.global_rotation_degrees = angle
					elevator_sprite.loaded = true
					add_child(elevator_sprite)
				elif parent_id == 2411:
					var x = int(params.pop_front())
					var y = int(params.pop_front())
					var lenght = float(params.pop_front())
					var angle = -int(params.pop_front())
					
					var barrier_sprite = BarrierSprite.new(lenght)
					barrier_sprite.level = index
					barrier_sprite.global_position = Vector2(x, y)
					barrier_sprite.global_rotation_degrees = angle
					barrier_sprite.loaded = true
					add_child(barrier_sprite)
				elif parent_id == 2412:
					var trigger_rect = Rect2(int(params.pop_front()), int(params.pop_front()), int(float(params.pop_front()) * 16), int(float(params.pop_front()) * 16))
					params.pop_front()
					
					var hor_direction = max(min(int(params.pop_front()), 1), -1)
					var ver_direction = max(min(int(params.pop_front()), 1), -1)
					
					var direction = 0
					if hor_direction == 0 and ver_direction == -1:
						direction = 1
					elif hor_direction == -1 and ver_direction == 0:
						direction = 2
					elif hor_direction == 0 and ver_direction == 1:
						direction = 3
					
					var entry_sprite = EntrySprite.new(trigger_rect, direction)
					entry_sprite.level = index
					entry_sprite.loaded = true
					add_child(entry_sprite)
				elif parent_id == 1417:
					var darkness_rect = Rect2i(int(params[0]), int(params[2]), int(params[1]) - int(params[0]), int(params[3]) - int(params[2]))
					var darkness_sprite = DarknessSprite.new(darkness_rect)
					darkness_sprite.level = index
					darkness_sprite.loaded = true
					add_child(darkness_sprite)
				elif parent_id == 663:
					rain = true
					rain_rects.clear()
					for i in range(rain_rects_amount):
						var x = int(params[0 + i * 4])
						var y = int(params[2 + i * 4])
						rain_rects.append(Rect2i(x, y, int(params[1 + i * 4]) - x, int(params[3 + i * 4]) - y))
					queue_redraw()
				elif parent_id in DoorSprite.object_ids:
					var x = int(params.pop_front())
					var y = int(params.pop_front())
					params.pop_front()
					params.pop_front()
					var locked = int(params.pop_front())
					var cutscene = int(params.pop_front())
					
					var door_sprite = DoorSprite.new(parent_id, locked, cutscene)
					door_sprite.level = index
					door_sprite.position = Vector2(x, y)
					door_sprite.loaded = true
					add_child(door_sprite)
				else:
					var x = int(params.pop_front())
					var y = int(params.pop_front())
					var sprite_id = int(params.pop_front())
					var angle = -int(params.pop_front())
					var object_id = int(params.pop_front())
					var frame = int(params.pop_front())
					
					var submode = 0
					var mode = ItemsTab.TAB_INDEX
					
					if parent_id == 9 or parent_id == 10:
						mode = GameplayTab.TAB_INDEX
					elif parent_id == 1582 or parent_id == 1583:
						mode = LevelTab.TAB_INDEX
					var object = HLMObject.new(object_id, sprite_id)
					var object_sprite = ObjectSprite.new(object, frame, mode, parent_id)
					object_sprite.submode = submode
					object_sprite.global_position = Vector2(x, y)
					object_sprite.rotation_degrees = angle
					object_sprite.level = index
					object_sprite.loaded = true
					add_child(object_sprite)
		elif floor_path.get_extension() == "tls":
			while !file.eof_reached():
				var params = []
				var proper = true
				for _i in range(6):
					var line = file.get_line()
					if line == null:
						proper = false
						break
					params.append(line)
				if !proper:
					break
				var tile_id = int(params.pop_front())
				var tile_x = int(params.pop_front())
				var tile_y = int(params.pop_front())
				var x = int(params.pop_front())
				var y = int(params.pop_front())
				var depth = int(params.pop_front())
				
				var submode = 0
				if depth == -99:
					submode = 2
				
				var tile_sprite = TileSprite.new(tile_id, tile_x, tile_y, depth, submode)
				tile_sprite.global_position = Vector2(x, y)
				tile_sprite.level = index
				tile_sprite.loaded = true
				add_child(tile_sprite)
		elif floor_path.get_extension() == "wll":
			while !file.eof_reached():
				var params = []
				var proper = true
				for _i in range(5):
					var line = file.get_line()
					if line == "":
						proper = false
						break
					params.append(line)
				if !proper:
					break
				var object_id = int(params.pop_front())
				var x = int(params.pop_front())
				var y = int(params.pop_front())
				var sprite_id = int(params.pop_front())
				var _depth = int(params.pop_front())
				
				var wall_sprite = WallSprite.new(object_id, sprite_id)
				wall_sprite.global_position = Vector2(x, y) - Vector2(wall_sprite.wall_offset)
				wall_sprite.level = index
				wall_sprite.loaded = true
				add_child(wall_sprite)
		elif floor_path.get_extension() == "npc":
			for _i in range(int(file.get_line())):
				var character_name = file.get_line()
				var sprite_id = int(file.get_line())
				var angle = -int(file.get_line())
				var pos = Vector2(int(file.get_line()), int(file.get_line()))
				file.get_line()
				file.get_line()
				file.get_line()
				file.get_line()
				var trigger_index = int(file.get_line())
				var trigger_behavior = int(file.get_line())
				var trigger_range = int(file.get_line())
				var solid = file.get_line() == "1"
				var killable = file.get_line() == "1"
				file.get_line()
				file.get_line()
				file.get_line()
				
				var info = {
					"sprite_id": sprite_id,
					"npc": true,
					"trigger_index": trigger_index,
					"trigger_behavior": trigger_behavior,
					"trigger_range": trigger_range,
					"solid": solid,
					"killable": killable
				}
				
				var npc_sprite = CutsceneSprite.new(info)
				npc_sprite.name = character_name
				npc_sprite.position = pos
				npc_sprite.rotation_degrees = angle
				npc_sprite.level = index
				npc_sprite.loaded = true
				add_child(npc_sprite)
				
				cutscene["npc"].append(npc_sprite)
		elif floor_path.get_extension() == "itm":
			for _i in range(int(file.get_line())):
				var item_name = file.get_line()
				var sprite_id = int(file.get_line())
				var angle = -int(file.get_line())
				var pos = Vector2(int(file.get_line()), int(file.get_line()))
				
				var info = {
					"sprite_id": sprite_id,
					"npc": false,
					"active": file.get_line() == "1",
					"visible": file.get_line() == "1",
					"finish": file.get_line() == "1"
				}
				
				var item_sprite = CutsceneSprite.new(info)
				item_sprite.name = item_name
				item_sprite.position = pos
				item_sprite.rotation_degrees = angle
				item_sprite.level = index
				item_sprite.loaded = true
				add_child(item_sprite)
				
				cutscene["items"].append(item_sprite)
				
				file.get_line()
				file.get_line()
				file.get_line()
		elif floor_path.get_extension() == "csf":
			cutscene["rects"] = []
			for _i in range(int(file.get_line())):
				var x = int(file.get_line())
				var y = int(file.get_line())
				cutscene["rects"].append(Rect2(x, y, int(file.get_line()) - x, int(file.get_line()) - y))
			
			var dialogue_messages = []
			cutscene["frames"] = []
			for i in range(int(file.get_line()) + 1):
				cutscene["frames"].append({})
				cutscene["frames"][-1]["actions"] = []
				for j in range(int(file.get_line())):
					var action_id = int(file.get_line())
					if action_id == 0:
						var speed = float(file.get_line())
						var positions = []
						for _i in range(int(file.get_line())):
							positions.append(Vector2(int(file.get_line()), int(file.get_line())))
						var character = file.get_line()
						cutscene["frames"][-1]["actions"].append({
							"action_id": action_id,
							"speed": speed,
							"positions": positions,
							"character": character
						})
						cutscene["frames"][-1]["focus"] = file.get_line()
					elif action_id == 1:
						file.get_line()
						dialogue_messages.append({
							"index": j,
							"frame": i,
							"start": int(file.get_line()),
							"end": int(file.get_line()),
						})
						file.get_line()
						file.get_line()
						cutscene["frames"][-1]["focus"] = file.get_line()
						cutscene["frames"][-1]["actions"].append({
							"action_id": 1
						})
					elif action_id == 2:
						cutscene["frames"][-1]["actions"].append({
							"action_id": action_id,
							"sprite_id": int(file.get_line()),
							"character": file.get_line()
						})
						cutscene["frames"][-1]["focus"] = file.get_line()
					elif action_id == 3:
						cutscene["frames"][-1]["actions"].append({
							"action_id": action_id,
							"character": file.get_line(),
							"loop": file.get_line() == "1",
							"interval": int(file.get_line()),
							"freely": file.get_line() == "1",
							"stop": file.get_line() == "1"
						})
						cutscene["frames"][-1]["focus"] = file.get_line()
					elif action_id == 4:
						cutscene["frames"][-1]["actions"].append({
							"action_id": action_id,
							"character": file.get_line(),
							"manual": file.get_line() == "1",
							"angle": int(file.get_line()),
							"target": file.get_line(),
							"keep": file.get_line() == "1",
							"fire_rate": int(file.get_line())
						})
						cutscene["frames"][-1]["focus"] = file.get_line()
					elif action_id == 5:
						cutscene["frames"][-1]["actions"].append({
							"action_id": action_id,
							"delay": int(file.get_line())
						})
						file.get_line()
						cutscene["frames"][-1]["focus"] = file.get_line()
					elif action_id == 6:
						cutscene["frames"][-1]["actions"].append({
							"action_id": action_id,
							"character": file.get_line(),
							"reason": int(file.get_line()) + int(file.get_line()) * 2,
							"delay": int(file.get_line())
						})
						cutscene["frames"][-1]["focus"] = file.get_line()
					elif action_id == 7:
						file.get_line()
						cutscene["frames"][-1]["actions"].append({
							"action_id": action_id,
							"sound_id": int(file.get_line())
						})
						cutscene["frames"][-1]["focus"] = file.get_line()
					elif action_id == 8:
						file.get_line()
						cutscene["frames"][-1]["actions"].append({
							"action_id": action_id,
							"music_name": file.get_line()
						})
						cutscene["frames"][-1]["focus"] = file.get_line()
					elif action_id == 9:
						file.get_line()
						cutscene["frames"][-1]["actions"].append({
							"action_id": action_id,
							"fade": file.get_line() == "1",
							"fade_time": float(file.get_line())
						})
						file.get_line()
						cutscene["frames"][-1]["focus"] = file.get_line()
					elif action_id == 10:
						cutscene["frames"][-1]["actions"].append({
							"action_id": action_id,
							"scene_complete": file.get_line() == "1"
						})
						cutscene["frames"][-1]["focus"] = file.get_line()
					elif action_id == 11:
						cutscene["frames"][-1]["actions"].append({
							"action_id": action_id,
							"fade": file.get_line() == "1",
							"fade_time": float(file.get_line())
						})
						cutscene["frames"][-1]["focus"] = file.get_line()
					elif action_id == 12:
						cutscene["frames"][-1]["actions"].append({
							"action_id": action_id,
							"item": file.get_line(),
							"active": file.get_line() == "1",
							"visible": file.get_line() == "1"
						})
						cutscene["frames"][-1]["focus"] = file.get_line()
					elif action_id == 13:
						cutscene["frames"][-1]["actions"].append({
							"action_id": action_id,
							"character": file.get_line(),
							"angle": int(file.get_line()),
							"animate": file.get_line() == "1"
						})
						cutscene["frames"][-1]["focus"] = file.get_line()
			var messages = []
			for _i in range(int(file.get_line())):
				messages.append({})
				messages[-1]["first_line"] = file.get_line()
				messages[-1]["second_line"] = file.get_line()
				messages[-1]["sprite_id"] = int(file.get_line())
				messages[-1]["character"] = file.get_line()
			for message in dialogue_messages:
				cutscene["frames"][message["frame"]]["actions"][message["index"]]["messages"] = messages.slice(message["start"], message["end"])

func sorting(a, b):
	if a is WallSprite and b is WallSprite:
		if a.position.x == b.position.x:
			return a.position.y < b.position.y
		if a.position.y == b.position.y:
			return a.position.x < b.position.x
		return a.position.x < b.position.x or a.position.y < b.position.y
	return false

func save():
	var obj_file = FileAccess.open(App.level_path + "/level" + str(index) + ".obj", FileAccess.WRITE)
	var tls_file = FileAccess.open(App.level_path + "/level" + str(index) + ".tls", FileAccess.WRITE)
	var wll_file = FileAccess.open(App.level_path + "/level" + str(index) + ".wll", FileAccess.WRITE)
	var play_file = FileAccess.open(App.level_path + "/level" + str(index) + ".play", FileAccess.WRITE)
	var npc_file = FileAccess.open(App.level_path + "/level" + str(index) + ".npc", FileAccess.WRITE)
	var itm_file = FileAccess.open(App.level_path + "/level" + str(index) + ".itm", FileAccess.WRITE)
	var csf_file = FileAccess.open(App.level_path + "/level" + str(index) + ".csf", FileAccess.WRITE)
	play_file.store_line("0")
	play_file.store_line("-1")
	npc_file.store_line(str(len(cutscene["npc"])))
	itm_file.store_line(str(len(cutscene["items"])))
	
	var objects = get_children().duplicate()
	objects.sort_custom(sorting)
	
	for obj in objects:
		if obj.visible:
			if obj is ObjectSprite:
				obj_file.store_line(str(obj.parent))
				obj_file.store_line(str(obj.position.x))
				obj_file.store_line(str(obj.position.y))
				obj_file.store_line(str(obj.object.sprite_id))
				obj_file.store_line(str((720 - int(round(obj.rotation_degrees)) % 360) % 360) )
				obj_file.store_line(str(obj.object.object_id))
				obj_file.store_line(str(obj.object_frame))
				play_file.store_line(str(obj.object.object_id))
				play_file.store_line(str(obj.position.x))
				play_file.store_line(str(obj.position.y))
				play_file.store_line(str(obj.object.sprite_id))
				play_file.store_line(str((720 - int(round(obj.rotation_degrees)) % 360) % 360) )
				play_file.store_line(str(obj.object_frame))
			elif obj is TileSprite:
				tls_file.store_line(str(obj.tile_id))
				tls_file.store_line(str(obj.tile_x))
				tls_file.store_line(str(obj.tile_y))
				tls_file.store_line(str(obj.position.x))
				tls_file.store_line(str(obj.position.y))
				tls_file.store_line(str(obj.depth))
			elif obj is WallSprite:
				wll_file.store_line(str(obj.object_id))
				wll_file.store_line(str(obj.position.x + obj.wall_offset.x))
				wll_file.store_line(str(obj.position.y + obj.wall_offset.y))
				wll_file.store_line(str(obj.sprite_id))
				wll_file.store_line("0")
				play_file.store_line(str(obj.object_id))
				play_file.store_line(str(obj.position.x + obj.wall_offset.x))
				play_file.store_line(str(obj.position.y + obj.wall_offset.y))
				play_file.store_line(str(obj.sprite_id))
				play_file.store_line("0")
				play_file.store_line("0")
			elif obj is TransitionSprite:
				obj_file.store_line("2297")
				obj_file.store_line(str(obj.position.x + obj.trigger_rect.size.x / 2))
				obj_file.store_line(str(obj.position.y + obj.trigger_rect.size.y / 2))
				obj_file.store_line(str(obj.trigger_rect.size.x / 16.0))
				obj_file.store_line(str(obj.trigger_rect.size.y / 16.0))
				obj_file.store_line(str(obj.get_hor_direction()))
				obj_file.store_line(str(obj.get_ver_direction()))
				obj_file.store_line(str(obj.target_floor))
				obj_file.store_line(str(obj.transition_offset.x))
				obj_file.store_line(str(obj.transition_offset.y))
				play_file.store_line("124")
				play_file.store_line(str(obj.position.x + obj.trigger_rect.size.x / 2))
				play_file.store_line(str(obj.position.y + obj.trigger_rect.size.y / 2))
				play_file.store_line(str(obj.trigger_rect.size.x / 16.0))
				play_file.store_line(str(obj.trigger_rect.size.y / 16.0))
				play_file.store_line(str(obj.get_hor_direction()))
				play_file.store_line(str(obj.get_ver_direction()))
				play_file.store_line(str(obj.target_floor))
				play_file.store_line(str(obj.transition_offset.x))
				play_file.store_line(str(obj.transition_offset.y))
			elif obj is ElevatorSprite:
				obj_file.store_line("2410")
				obj_file.store_line(str(obj.position.x))
				obj_file.store_line(str(obj.position.y))
				obj_file.store_line(str((720 - int(obj.rotation_degrees) % 360) % 360))
				obj_file.store_line(str(obj.target_floor))
				obj_file.store_line(str(obj.transition_offset.x))
				obj_file.store_line(str(obj.transition_offset.y))
				play_file.store_line("810")
				play_file.store_line(str(obj.position.x))
				play_file.store_line(str(obj.position.y))
				play_file.store_line(str((720 - int(obj.rotation_degrees) % 360) % 360))
				play_file.store_line(str(obj.target_floor))
				play_file.store_line(str(obj.transition_offset.x))
				play_file.store_line(str(obj.transition_offset.y))
			elif obj is BarrierSprite:
				obj_file.store_line("2411")
				obj_file.store_line(str(obj.position.x))
				obj_file.store_line(str(obj.position.y))
				obj_file.store_line(str(obj.lenght))
				obj_file.store_line(str((720 - int(obj.rotation_degrees) % 360) % 360))
				play_file.store_line("2411")
				play_file.store_line(str(obj.position.x))
				play_file.store_line(str(obj.position.y))
				play_file.store_line(str(obj.lenght))
				play_file.store_line(str((720 - int(obj.rotation_degrees) % 360) % 360))
			elif obj is EntrySprite:
				obj_file.store_line("2412")
				obj_file.store_line(str(obj.position.x))
				obj_file.store_line(str(obj.position.y))
				obj_file.store_line(str(obj.trigger_rect.size.x / 16.0))
				obj_file.store_line(str(obj.trigger_rect.size.y / 16.0))
				obj_file.store_line(str(obj.get_obj_object()))
				obj_file.store_line(str(obj.get_hor_direction()))
				obj_file.store_line(str(obj.get_ver_direction()))
				play_file.store_line(str(obj.get_play_object()))
				play_file.store_line(str(obj.position.x))
				play_file.store_line(str(obj.position.y))
				play_file.store_line(str(obj.trigger_rect.size.x / 16.0))
				play_file.store_line(str(obj.trigger_rect.size.y / 16.0))
				play_file.store_line(str(obj.get_hor_direction() + obj.get_ver_direction()))
			elif obj is DarknessSprite:
				obj_file.store_line("1417")
				obj_file.store_line(str(obj.position.x))
				obj_file.store_line(str(obj.darkness_rect.end.x))
				obj_file.store_line(str(obj.position.y))
				obj_file.store_line(str(obj.darkness_rect.end.y))
				play_file.store_line("1417")
				play_file.store_line(str(obj.position.x))
				play_file.store_line(str(obj.darkness_rect.end.x))
				play_file.store_line(str(obj.position.y))
				play_file.store_line(str(obj.darkness_rect.end.y))
			elif obj is DoorSprite:
				obj_file.store_line(str(obj.object_id))
				obj_file.store_line(str(obj.position.x))
				obj_file.store_line(str(obj.position.y))
				obj_file.store_line(str(DoorSprite.sprite_ids[obj.direction]))
				obj_file.store_line("0")
				obj_file.store_line(str(obj.locked))
				obj_file.store_line(str(obj.cutscene))
				play_file.store_line(str(obj.object_id))
				play_file.store_line(str(obj.position.x))
				play_file.store_line(str(obj.position.y))
				play_file.store_line(str(DoorSprite.sprite_ids[obj.direction]))
				play_file.store_line("0")
				play_file.store_line(str(obj.locked))
				play_file.store_line(str(obj.cutscene))
			elif obj is CutsceneSprite:
				if obj.info["npc"]:
					npc_file.store_line(obj.name)
					npc_file.store_line(str(obj.info["sprite_id"]))
					npc_file.store_line(str((720 - int(obj.rotation_degrees) % 360) % 360))
					npc_file.store_line(str(obj.position.x))
					npc_file.store_line(str(obj.position.y))
					npc_file.store_line("1")
					npc_file.store_line("99999")
					npc_file.store_line("99999")
					npc_file.store_line(str(int(obj.info["trigger_behavior"] != -1)))
					npc_file.store_line(str(obj.info["trigger_index"]))
					npc_file.store_line(str(obj.info["trigger_behavior"]))
					npc_file.store_line(str(obj.info["trigger_range"]))
					npc_file.store_line(str(int(obj.info["solid"])))
					npc_file.store_line(str(int(obj.info["killable"])))
					npc_file.store_line("1")
					npc_file.store_line(str(obj.position.x))
					npc_file.store_line(str(obj.position.y))
				else:
					itm_file.store_line(obj.name)
					itm_file.store_line(str(obj.info["sprite_id"]))
					itm_file.store_line(str((720 - int(obj.rotation_degrees) % 360) % 360))
					itm_file.store_line(str(obj.position.x))
					itm_file.store_line(str(obj.position.y))
					itm_file.store_line(str(int(obj.info["active"])))
					itm_file.store_line(str(int(obj.info["visible"])))
					itm_file.store_line(str(int(obj.info["finish"])))
					itm_file.store_line("0")
					itm_file.store_line("10000")
					itm_file.store_line("10000")
	
	for light_overlay in light_overlays:
		obj_file.store_line("1770")
		obj_file.store_line(str(light_overlay))
		play_file.store_line("1770")
		play_file.store_line(str(light_overlay))
	
	if rain:
		obj_file.store_line("663")
		obj_file.store_line(str(len(rain_rects)))
		for i in rain_rects:
			obj_file.store_line(str(i.position.x))
			obj_file.store_line(str(i.end.x))
			obj_file.store_line(str(i.position.y))
			obj_file.store_line(str(i.end.y))
		play_file.store_line("663")
		play_file.store_line(str(len(rain_rects)))
		for i in rain_rects:
			play_file.store_line(str(i.position.x))
			play_file.store_line(str(i.end.x))
			play_file.store_line(str(i.position.y))
			play_file.store_line(str(i.end.y))
	
	csf_file.store_line(str(len(cutscene["rects"])))
	for i in range(len(cutscene["rects"])):
		csf_file.store_line(str(cutscene["rects"][i].position.x))
		csf_file.store_line(str(cutscene["rects"][i].position.y))
		csf_file.store_line(str(cutscene["rects"][i].end.x))
		csf_file.store_line(str(cutscene["rects"][i].end.y))
	csf_file.store_line(str(len(cutscene["frames"]) - 1))
	var messages = []
	for frame in cutscene["frames"]:
		csf_file.store_line(str(len(frame["actions"])))
		for action in frame["actions"]:
			csf_file.store_line(str(action["action_id"]))
			if action["action_id"] == 0:
				csf_file.store_line(str(action["speed"]))
				csf_file.store_line(str(len(action["positions"])))
				for pos in action["positions"]:
					csf_file.store_line(str(pos.x))
					csf_file.store_line(str(pos.y))
				csf_file.store_line(action["character"])
			elif action["action_id"] == 1:
				csf_file.store_line(str(len(action["messages"])))
				var first_len = str(len(messages))
				csf_file.store_line(str(first_len))
				messages.append_array(action["messages"])
				csf_file.store_line(str(len(messages)))
				csf_file.store_line(str(first_len))
				csf_file.store_line("0")
			elif action["action_id"] == 2:
				csf_file.store_line(str(action["sprite_id"]))
				csf_file.store_line(action["character"])
			elif action["action_id"] == 3:
				csf_file.store_line(action["character"])
				csf_file.store_line(str(int(action["loop"])))
				csf_file.store_line(str(action["interval"]))
				csf_file.store_line(str(int(action["freely"])))
				csf_file.store_line(str(int(action["stop"])))
			elif action["action_id"] == 4:
				csf_file.store_line(action["character"])
				csf_file.store_line(str(int(!action["manual"])))
				csf_file.store_line(str(action["angle"]))
				csf_file.store_line(action["target"])
				csf_file.store_line(str(int(action["keep"])))
				csf_file.store_line(str(action["fire_rate"]))
			elif action["action_id"] == 5:
				csf_file.store_line(str(action["delay"]))
				csf_file.store_line("0")
			elif action["action_id"] == 6:
				csf_file.store_line(action["character"])
				csf_file.store_line(str(action["reason"] % 2))
				csf_file.store_line(str(floor(action["reason"] / 2)))
				csf_file.store_line(str(action["delay"]))
			elif action["action_id"] == 7:
				csf_file.store_line("0")
				csf_file.store_line(str(action["sound_id"]))
			elif action["action_id"] == 8:
				csf_file.store_line("0")
				csf_file.store_line(action["music_name"])
			elif action["action_id"] == 9:
				csf_file.store_line("0")
				csf_file.store_line(str(int(action["fade"])))
				csf_file.store_line(str(action["fade_time"]))
				csf_file.store_line("0")
			elif action["action_id"] == 10:
				csf_file.store_line(str(int(action["scene_complete"])))
			elif action["action_id"] == 11:
				csf_file.store_line(str(int(action["fade"])))
				csf_file.store_line(str(action["fade_time"]))
			elif action["action_id"] == 12:
				csf_file.store_line(action["item"])
				csf_file.store_line(str(int(action["active"])))
				csf_file.store_line(str(int(action["visible"])))
			elif action["action_id"] == 13:
				csf_file.store_line(action["character"])
				csf_file.store_line(str(action["angle"]))
				csf_file.store_line(str(int(action["animate"])))
			csf_file.store_line(frame["focus"])
	csf_file.store_line(str(len(messages)))
	for message in messages:
		csf_file.store_line(message["first_line"])
		csf_file.store_line(message["second_line"])
		csf_file.store_line(str(message["sprite_id"]))
		csf_file.store_line(message["character"])
	
	obj_file.close()
	tls_file.close()
	wll_file.close()
	play_file.close()
	npc_file.close()
	itm_file.close()
	csf_file.close()
