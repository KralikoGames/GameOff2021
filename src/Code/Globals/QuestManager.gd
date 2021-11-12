extends Node


signal quests_changed


var quests = []

func get_file_path(path, file: String):
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
#				print("Found directory: " + file_name)
				pass
			else:
#				print("Found file: " + file_name)
				if file_name.begins_with(file):
					return path + file_name
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
		return ""



func give_quest(args: Array):
	if args.size() < 1: 
		push_error("give_quest failed. improper input")
		return
	var quest_name = args[0] as String
	if not quest_name: 
		push_error("give_quest failed. improper input")
		return
	var quest_path = get_file_path("res://Code/Quests/Quests/", quest_name)
	if quest_path:
		var quest = load(quest_path)
		add_quest(quest)
	else:
		push_error("Tried to add a non-existant quest.")


func add_quest(q: Quest):
	quests.append(q)
	q.connect("quest_completed", self, "_quest_completed", [q])
	q.connect_quest()
	emit_signal("quests_changed")


func _quest_completed(quest: Quest):
	quests.erase(quest)
	quest.provide_reward(GameInit.player)
	emit_signal("quests_changed")
