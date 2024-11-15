extends Panel

@onready var object_spin_box = $"Object SpinBox"
@onready var sprite_spin_box = $"Sprite SpinBox"
@onready var frame_spin_box = $"Frame SpinBox"
@onready var object_label = $"Object Label"
@onready var sprite_label = $"Sprite Label"
@onready var comment_line_edit = $"Comment LineEdit"
@onready var x_spin_box = $"X SpinBox"
@onready var y_spin_box = $"Y SpinBox"
@onready var angle_spin_box = $"Angle SpinBox"

var object
var old_object_id
var old_sprite_id
var old_frame
var old_position
var old_angle

func close():
	object = null
	visible = false

func _on_cancel_button_button_up():
	object.set_ids(old_object_id, old_sprite_id, old_frame)
	object.position = old_position
	object.rotation_degrees = old_angle
	close()

func _on_ok_button_button_up():
	object.comment = comment_line_edit.text
	close()

func edit(_object):
	if object == null:
		object = _object
		object_spin_box.set_value_no_signal(object.object.object_id)
		old_object_id = object.object.object_id
		sprite_spin_box.set_value_no_signal(object.object.sprite_id)
		old_sprite_id = object.object.sprite_id
		frame_spin_box.set_value_no_signal(object.object_frame)
		old_frame = object.object_frame
		x_spin_box.set_value_no_signal(object.position.x)
		y_spin_box.set_value_no_signal(object.position.y)
		old_position = object.position
		angle_spin_box.set_value_no_signal((720 - int(round(object.rotation_degrees)) % 360) % 360)
		old_angle = object.rotation_degrees
		_on_object_spin_box_value_changed(object.object.object_id)
		_on_sprite_spin_box_value_changed(object.object.sprite_id)
		visible = true

func set_ids():
	object.set_ids(int(object_spin_box.value), int(sprite_spin_box.value), int(frame_spin_box.value))

func _on_object_spin_box_value_changed(value):
	var object_name = "No Object"
	if ObjectsLoader.objects.has(int(value)):
		object_name = ObjectsLoader.objects[int(value)].object_name
	object_label.text = object_name
	set_ids()

func _on_sprite_spin_box_value_changed(value):
	frame_spin_box.value = 0
	var sprite = ObjectsLoader.get_sprite(int(value))
	frame_spin_box.max_value = len(sprite["frames"]) - 1
	sprite_label.text = sprite["file_name"]
	set_ids()

func _on_frame_spin_box_value_changed(value):
	set_ids()

func _on_x_spin_box_value_changed(value):
	object.position.x = value

func _on_y_spin_box_value_changed(value):
	object.position.y = value

func _on_angle_spin_box_value_changed(value):
	object.rotation_degrees = -value
