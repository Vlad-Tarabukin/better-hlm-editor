extends Panel

class_name WallPanel

static var walls = []

@onready var build = $".."

var pos

func set_pos(_pos):
	pos = _pos
	queue_redraw()

func _on_Main_objects_loaded():
	var i = 0
	for wall in walls:
		var texture_rect = TextureRect.new()
		var sprite = ObjectsLoader.get_sprite(wall["sprite_id"])
		wall["horizontal"] = i % 2 == 0
		var texture = ImageTexture.create_from_image(sprite["frames"][0].get_image().get_region(Rect2(sprite["center"], Vector2(32, 32)))) #,2
		wall["texture"] = texture
		var texture_sprite
		if wall["horizontal"]:
			texture_sprite = ImageTexture.create_from_image(texture.get_image().get_region(Rect2(Vector2.ZERO, Vector2(32, 8))))
		else:
			texture_sprite = ImageTexture.create_from_image(texture.get_image().get_region(Rect2(Vector2.ZERO, Vector2(8, 32))))
		wall["texture_sprite"] = texture_sprite
		texture_rect.texture = texture
		var x = floor(i / 4) * 32
		var y = (i % 4) * 32
		texture_rect.offset_left = x
		texture_rect.offset_top = y
		texture_rect.offset_right = x + 32
		texture_rect.offset_bottom = y + 32
		i += 1
		add_child(texture_rect)

func _on_Wall_Panel_ready():
	var walls_tsv = FileAccess.open("res://walls.tsv", FileAccess.READ)
	while !walls_tsv.eof_reached():
		var params = walls_tsv.get_csv_line("\t")
		walls.append({
			"object_id": int(params[0]),
			"sprite_id": int(params[1]),
			"next": int(params[2])
		})
	walls_tsv.close()

func _draw():
	if pos != null:
		draw_rect(Rect2i(pos, Vector2i(32, 32)), Color.YELLOW)

func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == 1 and event.is_pressed():
		var mouse_pos = get_local_mouse_position()
		mouse_pos.x = floor(mouse_pos.x / 32) * 32
		mouse_pos.y = floor(mouse_pos.y / 32) * 32
		set_pos(mouse_pos)
		build.set_wall(walls[int(pos.y + pos.x * 4) / 32])

func set_next_wall(wall):
	set_pos(Vector2i(floor(wall["next"] / 4), wall["next"] % 4) * 32)
	build.set_wall(walls[wall["next"]])
