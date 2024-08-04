extends Panel

@onready var name_line_edit = $"Name LineEdit"
@onready var sprite_spin_box = $"Sprite SpinBox"
@onready var solid_check_box = $"NPC/Solid CheckBox"
@onready var killable_check_box = $"NPC/Killable CheckBox"
@onready var trigger_option_button = $"NPC/Trigger OptionButton"
@onready var range_spin_box = $"NPC/Range SpinBox"
@onready var active_check_box = $"Item/Active CheckBox"
@onready var visible_check_box = $"Item/Visible CheckBox"
@onready var finish_check_box = $"Item/Finish CheckBox"

var sprite

func open(_sprite):
	visible = true
	sprite = _sprite
	name_line_edit.text = sprite.name
	sprite_spin_box.value = sprite.info["sprite_id"]
	$NPC.visible = sprite.info["npc"]
	$Item.visible = !sprite.info["npc"]
	if sprite.info["npc"]:
		solid_check_box.button_pressed = sprite.info["solid"]
		killable_check_box.button_pressed = sprite.info["killable"]
		trigger_option_button.select(sprite.info["trigger_behavior"] + 1)
		range_spin_box.value = sprite.info["trigger_range"]
	else:
		active_check_box.button_pressed = sprite.info["active"]
		visible_check_box.button_pressed = sprite.info["visible"]
		finish_check_box.button_pressed = sprite.info["finish"]

func _on_trigger_option_button_item_selected(index):
	range_spin_box.editable = index == 2
	range_spin_box.value = 0

func _on_cancel_button_button_up():
	visible = false
	
func _on_delete_button_button_up():
	_on_cancel_button_button_up()
	sprite.queue_free()
	if sprite.info["npc"]:
		App.get_current_floor().cutscene["npc"].remove_at(App.get_current_floor().cutscene["npc"].find(sprite))
	else:
		App.get_current_floor().cutscene["items"].remove_at(App.get_current_floor().cutscene["items"].find(sprite))

func _on_ok_button_button_up():
	_on_cancel_button_button_up()
	sprite.name = name_line_edit.text
	sprite.change_sprite(int(sprite_spin_box.value))
	if sprite.info["npc"]:
		sprite.info["solid"] = solid_check_box.button_pressed
		sprite.info["killable"] = killable_check_box.button_pressed
		sprite.info["trigger_behavior"] = trigger_option_button.selected - 1
		sprite.info["trigger_range"] = int(range_spin_box.value)
	else:
		sprite.info["active"] = active_check_box.button_pressed
		sprite.info["visible"] = visible_check_box.button_pressed
		sprite.info["finish"] = finish_check_box.button_pressed
