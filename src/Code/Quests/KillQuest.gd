extends Quest
class_name KillQuest

# This quest is completed when the player walks over an area with the name node_name


export var enemy_name: String


func connect_quest():
	GameInit.connect("enemy_died", self, "_on_enemy_died")


func _on_enemy_died(enemy: Enemy):
	if enemy.id == enemy_name:
		emit_signal("quest_completed")
