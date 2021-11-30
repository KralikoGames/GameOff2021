tool
extends AudioStreamPlayer2D
class_name SpriteSound


export var animation_name: String = ""
export var frame: int = 0


onready var parent_sprite: AnimatedSprite = get_parent() as AnimatedSprite


func _get_configuration_warning():
	if not parent_sprite:
		return "Parent must be an Animated Sprite"
	if not animation_name in parent_sprite.frames.get_animation_names():
		return "Animation Name must be a valid animation name"
	var max_frames = parent_sprite.frames.get_frame_count(animation_name)
	if frame > max_frames - 1:
		return "Frame must not be greater then the frame count of the animation"
	return ""


func _ready():
	parent_sprite.connect("frame_changed", self, "_on_parent_sprite_animation_changed")


func _on_parent_sprite_animation_changed():
	if parent_sprite.animation == animation_name and parent_sprite.frame == frame:
		play()
