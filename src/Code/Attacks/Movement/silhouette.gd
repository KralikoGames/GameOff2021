extends Sprite


func _ready():
	$Tween.interpolate_property(self, "modulate", modulate, Color(1,1,1,0), 0.3, Tween.TRANS_CUBIC, Tween.EASE_IN)
	$Tween.start()


func init_animated_sprite(sprite: AnimatedSprite):
	texture = get_animated_sprite_texture(sprite)
	global_position = sprite.global_position
	flip_h = sprite.flip_h
	flip_v = sprite.flip_v
	scale = sprite.scale


static func get_animated_sprite_texture(s: AnimatedSprite) -> Texture:
	return s.frames.get_frame(s.animation, s.frame)


func _on_Tween_tween_all_completed():
	queue_free()
