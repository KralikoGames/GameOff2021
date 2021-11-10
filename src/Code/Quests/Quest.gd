extends Resource
class_name Quest


# warning-ignore:unused_signal
signal quest_completed


export var title: String
export(String, MULTILINE) var description: String
export(int) var skillpoints: int = 1


func connect_quest():
	# connects to the player and emits the complete signal when the player does something
	pass


func provide_reward(p: Player):
	p.passive_points += skillpoints
