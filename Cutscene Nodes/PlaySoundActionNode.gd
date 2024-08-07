extends Control

@onready var sound_option_button = $"Sound OptionButton"
@onready var play_button = $"Play Button"
@onready var audio_stream_player = $AudioStreamPlayer

var action

func _ready():
	custom_minimum_size = Vector2(360, 80)

func initialize(_action):
	action = _action
	action["sound_id"] = action.get("sound_id", 3)
	
	sound_option_button.select(sound_option_button.get_item_index(action["sound_id"]))
	_on_sound_option_button_item_selected(sound_option_button.selected)

func _on_sound_option_button_item_selected(index):
	action["sound_id"] = sound_option_button.get_item_id(index)
	audio_stream_player.stream = ObjectsLoader.sounds[sound_option_button.get_item_text(index)]

func _on_play_button_toggled(toggled_on):
	if toggled_on:
		play_button.text = "Stop"
	else:
		play_button.text = "Play"
	audio_stream_player.playing = toggled_on

func _on_audio_stream_player_finished():
	play_button.button_pressed = false
