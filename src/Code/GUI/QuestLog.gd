extends Control


onready var quest_list: Control = $Panel/ScrollContainer/VBoxContainer


var quest_desc: PackedScene = preload("res://Code/GUI/QuestDescription.tscn")


func _ready():
	QuestManager.connect("quests_changed", self, "update_quests")
	$Panel.connect("visibility_changed", self, "_on_open_quest_log")


func _on_open_quest_log():
	$QuestNotification.hide()


func update_quests():
	for child in quest_list.get_children():
		child.queue_free()
	
	for quest in QuestManager.quests:
		var q = quest_desc.instance()
		q.set_title(quest.title)
		q.set_description(quest.description)
		quest_list.add_child(q)
	
	$anim.play("wiggle_notification")
