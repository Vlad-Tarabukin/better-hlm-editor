extends Object

class_name WadFile

var pos = 0
var content

func _init(_content):
	content = _content

func get_buffer(len):
	var result = content.slice(pos, pos + len)
	pos += len
	return result

func get_string(len):
	return get_buffer(len).get_string_from_ascii()

func get_8():
	return get_buffer(1).decode_s8(0)

func get_16():
	return get_buffer(2).decode_s16(0)

func get_32():
	return get_buffer(4).decode_s32(0)

func get_64():
	return get_buffer(8).decode_s64(0)
