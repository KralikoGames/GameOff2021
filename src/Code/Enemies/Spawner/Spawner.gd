extends Node2D

export(PackedScene) var enemy_tscn
export(int) var number_of_waves = 3
export(int, 1, 1) var spawns_per_wave = 1
export(float) var time_between_spawns = 1.0
export var tigger_when_near_player: bool = true
export var one_shot: bool = true

var waves_spawned: int = 0

signal on_spawn



func _ready():
	$Timer.wait_time = time_between_spawns
	$Timer.one_shot = true
	

func set_target(_t):
	if tigger_when_near_player:
		start()


func start():
	if one_shot and waves_spawned > 0: return
	
	waves_spawned = 0
	_spawn_wave()


func _on_Timer_timeout():
	if waves_spawned < number_of_waves:
		_spawn_wave()


func _spawn_wave():
	emit_signal("on_spawn")
	for _i in range(spawns_per_wave):
		var e = enemy_tscn.instance()
#		call_deferred("add_child", e)
		$Timer.call_deferred("add_child", e)#add_child(e)
		e.global_position = global_position
		if e.has_method("on_spawn"): e.on_spawn(self)
	waves_spawned += 1
	$Timer.start()





