extends Panel

@onready var object_spin_box = $"Object SpinBox"
@onready var sprite_spin_box = $"Sprite SpinBox"
@onready var frame_spin_box = $"Frame SpinBox"
@onready var object_label = $"Object Label"
@onready var sprite_label = $"Sprite Label"

func _on_cancel_button_button_up():
	App.selected_object = null
	visible = false

func _on_ok_button_button_up():
	App.selected_object.set_ids(int(object_spin_box.value), int(sprite_spin_box.value), int(frame_spin_box.value))
	_on_cancel_button_button_up()

func _on_visibility_changed():
	if visible:
		object_spin_box.value = App.selected_object.object.object_id
		sprite_spin_box.value = App.selected_object.object.sprite_id

func _on_object_spin_box_value_changed(value):
	var object_name = "No Object"
	if ObjectsLoader.objects.has(int(value)):
		object_name = ObjectsLoader.objects[int(value)].object_name
	object_label.text = object_name

func _on_sprite_spin_box_value_changed(value):
	frame_spin_box.value = 0
	var sprite = ObjectsLoader.get_sprite(int(value))
	frame_spin_box.max_value = len(sprite["frames"]) - 1
	sprite_label.text = sprite["name"]
