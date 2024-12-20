extends Sprite2D

@onready var label = $"../CanvasLayer/Main GUI/Angle Label"
@onready var position_label = $"../CanvasLayer/Main GUI/Bottom-Left/Position Label"

signal snap_changed

var snap = 1 :
	set(_snap):
		snap = _snap
		snap_changed.emit()
var move = true
var outline = true

func _unhandled_input(event):
	if move and (event is InputEventMouseMotion or event is InputEventMouseButton and \
	 (event.button_index == MOUSE_BUTTON_WHEEL_UP or event.button_index == MOUSE_BUTTON_WHEEL_DOWN)):
		global_position = GlobalCamera.get_mouse_position()
		if snap != 0:
			global_position.x = floor(global_position.x / snap) * snap
			global_position.y = floor(global_position.y / snap) * snap
		position_label.text = str(global_position.x) + " " + str(global_position.y)

func _draw():
	if outline and texture != null:
		draw_rect(get_rect(), Color.WHITE, false)

func _process(_delta):
	if Input.is_key_pressed(KEY_SHIFT) or Input.is_key_pressed(KEY_CTRL):
		label.set_position(get_viewport().get_mouse_position() + Vector2(-7, -60))
		label.text = str(-int(rotation_degrees) % 360) + "°"
	else:
		label.text = ""

func _on_Cursor_ready():
	centered = false
