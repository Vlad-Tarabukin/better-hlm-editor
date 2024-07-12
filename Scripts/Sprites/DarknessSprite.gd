extends BaseSprite

class_name DarknessSprite

const TEXTURE = preload("res://Textures/transition.png")

var darkness_rect

func should_delete():
	return true

func _init(_darkness_rect):
	darkness_rect = _darkness_rect
	
	mode = LevelTab.TAB_INDEX
	texture = TEXTURE
	position = darkness_rect.position
	region_enabled = true
	region_rect = darkness_rect
