extends Control

func _on_up_button_button_up():
	var action_index = $"..".get_index()
	if action_index > 0:
		var frame_index = $"../../..".get_index()
		App.get_current_floor().cutscene["frames"][frame_index]["actions"].insert(action_index - 1, App.get_current_floor().cutscene["frames"][frame_index]["actions"].pop_at(action_index))
		$"../../..".refresh_action_nodes()

func _on_down_button_button_up():
	var action_index = $"..".get_index()
	var frame_index = $"../../..".get_index()
	if action_index < len(App.get_current_floor().cutscene["frames"][frame_index]["actions"]) - 1:
		App.get_current_floor().cutscene["frames"][frame_index]["actions"].insert(action_index + 1, App.get_current_floor().cutscene["frames"][frame_index]["actions"].pop_at(action_index))
		$"../../..".refresh_action_nodes()

func _on_delete_button_button_up():
	App.get_current_floor().cutscene["frames"][$"../../..".get_index()]["actions"].remove_at($"..".get_index())
	$"../../..".refresh_action_nodes()
