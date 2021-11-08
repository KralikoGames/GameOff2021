extends AnimatedSprite


var player: Player
var lock_anim: bool = false


func _ready():
	yield(get_parent(), "ready")
	player = get_parent() as Player
	player.connect("moved", self, "_on_player_moved")
	player.connect("stopped", self, "_on_player_stopped")
	player.connect("attacked", self, "_on_player_attacked")
	player.connect("begin_death", self, "_on_player_begin_death")


func _process(_delta):
	_handle_flipping()
	

func _handle_flipping():
	flip_h = player.look_dir.x > 0


func _on_player_moved():
	if not lock_anim:
		play("Run")


func _on_player_stopped():
	if not lock_anim:
		play("Idle")


func _on_player_attacked():
	lock_anim = true
	play("Attack slash")
	yield(self, "animation_finished")
	lock_anim = false


func _on_player_begin_death():
	pass

