extends Sprite2D

class_name CutsceneSprite

func _init(sprite_id):
	var sprite = ObjectsLoader.get_sprite(sprite_id)
	offset = sprite["center"]
	texture = sprite["frames"][0]
