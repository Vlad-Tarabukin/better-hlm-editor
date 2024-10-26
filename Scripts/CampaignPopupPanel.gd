extends PopupPanel

@onready var first_line_edit = $"TabContainer/Credits/First LineEdit"
@onready var second_line_edit = $"TabContainer/Credits/Second LineEdit"
@onready var credits_item_list = $"TabContainer/Credits/Credits ItemList"
@onready var remove_button = $"TabContainer/Credits/Remove Button"

var credits = []

func _process(delta):
	first_line_edit.editable = credits_item_list.is_anything_selected()
	second_line_edit.editable = credits_item_list.is_anything_selected()
	remove_button.disabled = !credits_item_list.is_anything_selected()

func _on_line_edit_text_changed(new_text):
	var index = credits_item_list.get_selected_items()[0]
	credits_item_list.set_item_text(index, first_line_edit.text + "\n" + second_line_edit.text + "\n")
	credits[index] = {
		"first": first_line_edit.text,
		"second": second_line_edit.text
	}

func _on_credits_item_list_item_selected(index):
	first_line_edit.text = credits[index]["first"]
	second_line_edit.text = credits[index]["second"]

func _on_create_button_button_up():
	credits.append({"first": "", "second": ""})
	credits_item_list.add_item("\n\n")
	credits_item_list.select(credits_item_list.item_count - 1)
	_on_credits_item_list_item_selected(credits_item_list.item_count - 1)
