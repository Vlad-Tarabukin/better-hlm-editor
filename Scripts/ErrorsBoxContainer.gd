extends VBoxContainer

@onready var no_player = $"No Player"
@onready var no_fans_vehicle = $"No Fans Vehicle"
@onready var no_soldier_vehicle = $"No Soldier Vehicle"
@onready var no_son_vehicle = $"No Son Vehicle"
@onready var no_cobra_vehicle = $"No Cobra Vehicle"
@onready var no_name = $"No Name"
@onready var no_author = $"No Author"

var player_ids = []

func _ready():
	player_ids = LevelTab.characters.map(func(c): return c["object_id"])

func _process(delta):
	if App.level_path:
		var first_floor = App.get_floor(0)
		if first_floor:
			no_name.visible = App.level_info["name"] == "UNTITLED"
			no_author.visible = App.level_info["author"] == "" or App.level_info["author"] == "BETTER HLM EDITOR"
			no_player.visible = not(App.level_info["character_id"] in [0, 3, 4, 6])
			no_fans_vehicle.visible = App.level_info["character_id"] == 0
			no_soldier_vehicle.visible = App.level_info["character_id"] == 3
			no_son_vehicle.visible = App.level_info["character_id"] == 4
			no_cobra_vehicle.visible = App.level_info["character_id"] == 6
			for obj in first_floor.get_children():
				if obj is ObjectSprite and obj.visible:
					no_player.visible = no_player.visible and not(obj.object.object_id in player_ids)
					no_fans_vehicle.visible = no_fans_vehicle.visible and obj.object.object_id != 236
					no_soldier_vehicle.visible = no_soldier_vehicle.visible and obj.object.object_id != 1341
					no_son_vehicle.visible = no_son_vehicle.visible and obj.object.object_id != 1366
					no_cobra_vehicle.visible = no_cobra_vehicle.visible and not(obj.object.object_id in [870, 2267])
