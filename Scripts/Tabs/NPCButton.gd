extends OptionButton

class_name NPCButton

func _ready():
	add_item("Player")
	for character in App.get_current_floor().cutscene["npc"]:
		add_item(character.name)

func set_character(character_name):
	for i in range(item_count):
		if character_name == get_item_text(i):
			selected = i
			return

func get_character():
	return get_item_text(selected)
