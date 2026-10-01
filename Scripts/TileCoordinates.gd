extends RefCounted

class_name TileCoordinates

static func normalize(x, y) -> Vector2i:
	return Vector2i(int(x), int(y))

static func key(x, y) -> String:
	var coordinates = normalize(x, y)
	return "%d %d" % [coordinates.x, coordinates.y]
