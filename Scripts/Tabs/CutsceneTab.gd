extends TabBar

class_name CutsceneTab

const TAB_INDEX = 5
const FRAME_NODE = preload("res://Cutscene Nodes/frame_node.tscn")

@onready var v_box_container = $TabContainer/Cutscene/ScrollContainer/VBoxContainer
@onready var item_list = $TabContainer/NPC/ItemList
@onready var name_line_edit = $"TabContainer/NPC/Name LineEdit"
@onready var npc_check_button = $"TabContainer/NPC/NPC CheckButton"
@onready var solid_check_box = $"TabContainer/NPC/NPC/Solid CheckBox"
@onready var killable_check_box = $"TabContainer/NPC/NPC/Killable CheckBox"
@onready var active_check_box = $"TabContainer/NPC/Item/Active CheckBox"
@onready var visible_check_box = $"TabContainer/NPC/Item/Visible CheckBox"
@onready var finish_check_box = $"TabContainer/NPC/Item/Finish CheckBox"
@onready var used_label = $"TabContainer/NPC/Name LineEdit/Used Label"
@onready var triggers_item_list = $"TabContainer/Cutscene/Triggers ItemList"
@onready var add_trigger_button = $"TabContainer/Cutscene/Add Trigger Button"
@onready var cutscene_check_box = $"TabContainer/Cutscene/Cutscene CheckBox"

var active
var last_floor

func _process(delta):
	if active and last_floor != App.level:
		last_floor = App.level
		refresh_frames()
		refresh_triggers()
		cutscene_check_box.button_pressed = App.level_info["cutscene"]

func refresh_frames():
	for child in v_box_container.get_children():
		child.queue_free()
	for i in range(len(App.get_current_floor().cutscene["frames"])):
		var frame_node = FRAME_NODE.instantiate()
		v_box_container.add_child(frame_node)
		frame_node.initialize(App.get_current_floor().cutscene["frames"][i], i)

func refresh_triggers():
	triggers_item_list.clear()
	for i in range(len(App.get_current_floor().cutscene["rects"])):
		triggers_item_list.add_item("Trigger " + str(i))

func _on_tab_container_tab_selected(tab):
	active = tab == TAB_INDEX

func _on_add_frame_button_button_up():
	App.get_current_floor().cutscene["frames"].append({
		"actions": [],
		"focus": "Player"
	})
	refresh_frames()

var listed_sprites = []

func refresh_sprites(filter = ""):
	item_list.clear()
	listed_sprites = []
	for sprite_id in ObjectsLoader.sprites.keys():
		var sprite = ObjectsLoader.sprites[sprite_id]
		if filter == "" or sprite["name"].to_lower().count(filter.to_lower()) > 0:
			listed_sprites.append(sprite_id)
			item_list.add_item("{name} ({id})".format({"name": sprite["file_name"], "id": sprite_id}), sprite["frames"][0])

func _on_cutscene_tab_container_tab_selected(tab):
	App.cursor.texture = null
	if tab == 1:
		refresh_sprites()

func _on_search_line_edit_text_changed(new_text):
	refresh_sprites(new_text)

func _on_item_list_item_selected(index):
	var sprite = ObjectsLoader.sprites[listed_sprites[index]]
	App.cursor.texture = sprite["frames"][0]
	App.cursor.offset = sprite["center"]

var start_pos

func _unhandled_input(event):
	if active:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_MASK_LEFT:
				if item_list.is_anything_selected() and !used_label.visible and name_line_edit.text != "" and event.pressed:
					var info = {
						"sprite_id": listed_sprites[item_list.get_selected_items()[0]],
						"npc": npc_check_button.button_pressed
					}
					if npc_check_button.button_pressed:
						info.merge({
							"trigger_index": 0,
							"trigger_behavior": -1,
							"trigger_range": 0,
							"solid": solid_check_box.button_pressed,
							"killable": killable_check_box.button_pressed
						})
					else:
						info.merge({
							"active": active_check_box.button_pressed,
							"visible": visible_check_box.button_pressed,
							"finish": finish_check_box.button_pressed
						})
					var cutscene_sprite = CutsceneSprite.new(info)
					App.add_object(cutscene_sprite)
					cutscene_sprite.name = name_line_edit.text
					cutscene_sprite.level = App.level
					if npc_check_button.button_pressed:
						App.get_current_floor().cutscene["npc"].append(cutscene_sprite)
					else:
						App.get_current_floor().cutscene["items"].append(cutscene_sprite)
					used_label.visible = true
				elif add_trigger_button.button_pressed:
					if event.pressed:
						start_pos = GlobalCamera.get_mouse_position()
						App.cursor.region_enabled = true
						App.cursor.texture = Texture
						App.cursor.outline = true
					else:
						App.get_current_floor().cutscene["rects"].append(Rect2(start_pos, GlobalCamera.get_mouse_position() - start_pos))
						App.get_current_floor().queue_redraw()
						App.cursor.region_enabled = false
						refresh_triggers()
						add_trigger_button.button_pressed = false
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
		elif event is InputEventMouseMotion and Input.is_mouse_button_pressed(1) and add_trigger_button.button_pressed:
			App.cursor.region_rect = Rect2i(Vector2i.ZERO, GlobalCamera.get_mouse_position() - start_pos)

func _on_name_line_edit_text_changed(new_text):
	if npc_check_button.button_pressed:
		for sprite in App.get_current_floor().cutscene["npc"]:
			if sprite.name == new_text:
				used_label.visible = true
				return
	for sprite in App.get_current_floor().cutscene["items"]:
		if sprite.name == new_text:
			used_label.visible = true
			return
	used_label.visible = false

func _on_npc_check_button_button_up():
	_on_name_line_edit_text_changed(name_line_edit.text)
	$TabContainer/NPC/NPC.visible = npc_check_button.button_pressed
	$TabContainer/NPC/Item.visible = !npc_check_button.button_pressed

func _on_delete_trigger_button_button_up():
	if triggers_item_list.is_anything_selected():
		var index = triggers_item_list.get_selected_items()[0]
		App.get_current_floor().cutscene["rects"].remove_at(index)
		App.get_current_floor().queue_redraw()
		triggers_item_list.remove_item(index)

func _on_cutscene_check_box_toggled(toggled_on):
	App.level_info["cutscene"] = toggled_on
