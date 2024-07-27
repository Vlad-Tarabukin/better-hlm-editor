extends TabBar

class_name EffectsTab

const TAB_INDEX = 2

var active

@onready var sunset_check_box = $"Sunset CheckBox"
@onready var day_check_box = $"Day CheckBox"
@onready var twilight_check_box = $"Twilight CheckBox"
@onready var darkness_button = $"Darkness Button"
@onready var rain_check_box = $"Rain CheckBox"
@onready var rain_button = $"Rain Button"

var last_floor
var start_pos

func _process(delta):
	if active and last_floor != App.level:
		last_floor = App.level
		var light_overlays = App.get_current_floor().light_overlays
		sunset_check_box.button_pressed = 0 in light_overlays
		day_check_box.button_pressed = 1 in light_overlays
		twilight_check_box.button_pressed = 2 in light_overlays
		rain_check_box.button_pressed = App.get_current_floor().rain

func _on_tab_container_tab_selected(tab):
	active = tab == TAB_INDEX
	if active:
		App.cursor.snap = 8
		App.cursor.outline = false
		App.cursor.region_enabled = true

func _on_effect_check_box_button_up():
	var light_overlays = App.get_current_floor().light_overlays
	light_overlays.clear()
	if sunset_check_box.button_pressed:
		light_overlays.append(0)
	if day_check_box.button_pressed:
		light_overlays.append(1)
	if twilight_check_box.button_pressed:
		light_overlays.append(2)

func _unhandled_input(event):
	if active:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT:
				if darkness_button.button_pressed:
					if event.pressed:
						start_pos = App.cursor.position
						App.cursor.move = false
					else:
						var darkness = DarknessSprite.new(App.cursor.region_rect)
						App.add_object(darkness, false)
						App.cursor.move = true
						start_pos = null
						App.cursor.region_rect = Rect2(0, 0, 8, 8)
				if rain_button.button_pressed:
					if event.pressed:
						start_pos = App.cursor.position
						App.cursor.move = false
					else:
						App.get_current_floor().rain_rects.append(App.cursor.region_rect)
						App.get_current_floor().queue_redraw()
						App.cursor.move = true
						start_pos = null
						App.cursor.region_rect = Rect2(0, 0, 8, 8)
			if event.button_mask == MOUSE_BUTTON_RIGHT and rain_button.button_pressed:
				var i = 0
				while i < len(App.get_current_floor().rain_rects):
					var rect = App.get_current_floor().rain_rects[i]
					if rect.has_point(GlobalCamera.get_mouse_position()):
						App.get_current_floor().rain_rects.remove_at(i)
					i += 1
				App.get_current_floor().queue_redraw()
		elif event is InputEventMouseMotion:
			if start_pos != null and event.button_mask == MOUSE_BUTTON_LEFT:
				var pos = GlobalCamera.get_mouse_position()
				pos.x = max(floor(pos.x / App.cursor.snap) * App.cursor.snap, start_pos.x + App.cursor.snap)
				pos.y = max(floor(pos.y / App.cursor.snap) * App.cursor.snap, start_pos.y + App.cursor.snap)
				App.cursor.region_rect = Rect2(start_pos, pos - start_pos)

func _on_darkness_button_button_up():
	if darkness_button.button_pressed:
		App.submode = 0
		App.cursor.texture = DarknessSprite.TEXTURE
	else:
		App.cursor.texture = null

func _on_rain_check_box_button_up():
	rain_button.disabled = !rain_check_box.button_pressed
	rain_button.button_pressed = false
	App.get_current_floor().rain = rain_check_box.button_pressed
	App.get_current_floor().queue_redraw()

func _on_rain_button_button_up():
	if rain_check_box.button_pressed:
		App.submode = 1
		App.cursor.texture = Floor.RAIN_TEXTURE
	else:
		App.cursor.texture = null
