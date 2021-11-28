extends AnimatedSprite
# definition_picker.connect("data_changed", self, '_on_DefinitionPicker_data_changed')

onready var parent = get_parent()

func _ready():
	parent.connect("on_spawn", self, "_on_spawn")
	self.connect("animation_finished" , self, "animation_finished")

	

func _on_spawn():
	self.play("Spawn")


func animation_finished():
	if animation == "Spawn":
		self.play("Idle")
