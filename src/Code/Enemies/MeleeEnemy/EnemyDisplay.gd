extends AnimatedSprite

export var state = ""

func _process(delta):
	play(state)


func _changeState(newStateName):
	#Helpful transition print. Will remove as of higher stability.
	#if(newStateName != state):
		#print("Received: " + str(newStateName) + " state")
		
	state = newStateName
