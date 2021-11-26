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
	player.connect("iframes_started", self, "_on_player_iframes_started")
	player.connect("iframes_ended", self, "_on_player_iframes_ended")
	
	$FlashTimer.connect("timeout", self, "flash_player_sprite")


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


func _on_player_iframes_started():
	$FlashTimer.start()

func _on_player_iframes_ended():
	$FlashTimer.stop()
	self_modulate = Color(1,1,1,1)

func flash_player_sprite(): # doing this with shaders might be better.
	self_modulate = Color(100,100,100) if self_modulate == Color(1,1,1,1) else Color(1,1,1,1)


func _on_player_begin_death(death_time):
	_on_player_iframes_ended()
	var tween: Tween = Tween.new()
	add_child(tween)
	tween.interpolate_property(self, "self_modulate", self_modulate, Color(1,1,1,0), death_time)
	tween.start()

