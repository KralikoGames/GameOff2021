extends Quest
class_name GoToQuest


# This quest is completed when the player walks over an area with the name node_name


export var node_name: String


func connect_quest():
	GameInit.player.connect("area_entered", self, "_on_player_area_entered")


func _on_player_area_entered(area: Area2D):
	if area.name == node_name:
		emit_signal("quest_completed")
