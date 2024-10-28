extends Node

class_name HLMObject

var object_id
var sprite_id
var object_name
var z_index
var mask_id

func _init(_object_id, _object_name, _sprite_id, _z_index, _mask_id):
	object_id = _object_id
	sprite_id = _sprite_id
	object_name = _object_name
	z_index = _z_index
	mask_id = _mask_id

func clone():
	return HLMObject.new(object_id, object_name, sprite_id, z_index, mask_id)
