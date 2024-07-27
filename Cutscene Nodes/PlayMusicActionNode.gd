extends Control

@onready var music_option_button = $"Music OptionButton"

const MUSIC = [
	"beams.mp3",
	"Detection.mp3",
	"Blizzard.mp3",
	"voyager.mp3",
	"SheMeditates.mp3",
	"Dust.mp3",
	"Disturbance.mp3",
	"Technoir.mp3",
	"GuidedMeditation.mp3",
	"MiamiJam.mp3",
	"Divide.mp3",
	"HollywoodHeights.mp3",
	"Richard.mp3",
	"WouJuno.mp3",
	"Decade.mp3",
	"Interlude.mp3",
	"NewWave.mp3",
	"Around.mp3",
	"evil.mp3",
	"Hideout.mp3",
	"Remorse.mp3",
	"Frantic.mp3",
	"Sexualizer.mp3",
	"Java.mp3",
	"Rust.mp3",
	"Delay.mp3",
	"Benjamin.mp3",
	"Bloodline.mp3",
	"RollerMobster.mp3",
	"KeepCalm.mp3",
	"Run.mp3",
	"Ghost.mp3",
	"HotlineTheme.mp3",
	"Quixotic.mp3",
	"WayHome.mp3",
	"Dubmood.mp3",
	"NARC.mp3",
	"Rumble.mp3",
	"LePerv.mp3",
	"MsMinnie.mp3",
	"BurningCoals.mp3",
	"AcidSpit.mp3",
	"SlumLord.mp3",
	"FutureClub.mp3",
	"Fahkeet.mp3",
	"Abyss.mp3",
	"AbyssIntro.mp3",
	"BlackTar.mp3"
]

func _ready():
	custom_minimum_size = Vector2(360, 80)

func initialize(action):
	for i in range(music_option_button.item_count):
		if MUSIC[i] == action["music_name"]:
			music_option_button.selected = i
