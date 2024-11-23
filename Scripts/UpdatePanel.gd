extends Panel

var current_version
var releases_url
var latest_url

@onready var rich_text_label = $RichTextLabel
@onready var http_request = $HTTPRequest
@onready var load_button = $"Load Button"

func _on_http_request_request_completed(result, response_code, headers, body):
	var releases = JSON.parse_string(body.get_string_from_utf8())
	var should_show = false
	for release in releases:
		if int(release["tag_name"].left(6).replace(".", "")) > current_version:
			should_show = true
			rich_text_label.pop_all()
			rich_text_label.append_text("[font_size=22]" + release["tag_name"] + "[/font_size]\n")
			rich_text_label.push_list(1, RichTextLabel.LIST_DOTS, false)
			for st in release["body"].split("\r\n"):
				st = st.strip_edges() + "\n"
				if st.begins_with("-"):
					rich_text_label.append_text(st.right(-2))
				else:
					rich_text_label.pop()
					rich_text_label.append_text(st)
	if should_show:
		if !rich_text_label.is_ready():
			await rich_text_label.finished
		visible = true
		load_button.button_up.connect(func(): )

func _ready():
	var version = FileAccess.open("res://version.txt", FileAccess.READ)
	current_version = int(version.get_line())
	releases_url = version.get_line()
	latest_url = version.get_line()
	http_request.request(releases_url)

func _on_close_button_button_up():
	visible = false

func _on_load_button_button_up():
	OS.shell_open(latest_url)
