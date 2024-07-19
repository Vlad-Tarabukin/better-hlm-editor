extends BaseSprite

class_name DarknessSprite

const TEXTURE = preload("res://Textures/darkness.png")

var darkness_rect

func should_delete():
	return true

func _init(_darkness_rect):
	darkness_rect = _darkness_rect
	
	mode = EffectsTab.TAB_INDEX
	submode = 0
	texture = TEXTURE
	position = darkness_rect.position
	region_enabled = true
	region_rect = darkness_rect
