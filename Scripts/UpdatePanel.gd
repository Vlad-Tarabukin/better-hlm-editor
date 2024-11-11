extends Panel

const current_version = 113
const releases_url = "https://api.github.com/repos/Vlad-Tarabukin/better-hlm-editor/releases"

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
		await rich_text_label.finished
		visible = true
		load_button.button_up.connect(func(): OS.shell_open(releases[0]["html_url"]))

func _ready():
	http_request.request(releases_url)

func _on_close_button_button_up():
	visible = false
