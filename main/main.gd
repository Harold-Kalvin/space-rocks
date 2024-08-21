extends Node

@export var rock_scene: PackedScene
@export var enemy_scene: PackedScene

var screensize = Vector2.ZERO
var level = 0
var score = 0
var playing = false


func _ready():
	screensize = get_viewport().get_visible_rect().size


func _process(_delta):
	if not playing:
		return
	if get_tree().get_nodes_in_group("rocks").size() == 0:
		new_level()


func _on_rock_exploded(size, radius, pos, vel):
	score += 1
	$HUD.update_score(score)
	if size <= 1:
		return

	for offset in [-1, 1]:
		var dir = $Player.position.direction_to(pos).orthogonal() * offset
		var newpos = pos + dir * radius
		var newvel = dir * vel.length() * 1.1
		spawn_rock(size - 1, newpos, newvel)


func _on_enemy_timer_timeout():
	var enemy = enemy_scene.instantiate()
	add_child(enemy)
	enemy.target = $Player
	$EnemyTimer.start(randf_range(20, 40))


func _input(event):
	if event.is_action_pressed("pause"):
		if not playing:
			return
		get_tree().paused = not get_tree().paused
		var message = $HUD/VBoxContainer/Message
		if get_tree().paused:
			message.text = "Paused"
			message.show()	
		else:
			message.text = ""
			message.hide()


func new_game():
	$Music.play()
	get_tree().call_group("rocks", "queue_free")
	level = 0
	score = 0
	$HUD.update_score(score)
	$HUD.show_message("Get Ready!")
	$Player.reset()
	await $HUD/Timer.timeout
	playing = true


func new_level():
	$LevelupSound.play()
	level += 1
	$HUD.show_message("Wave %s" % level)
	for i in level:
		spawn_rock(3)
	$EnemyTimer.start(randf_range(5, 10))


func game_over():
	$Music.stop()
	playing = false
	$HUD.game_over()


func spawn_rock(size, pos=null, vel=null):
	if pos == null:
		$RockPath/RockSpawn.progress = randi()
		pos = $RockPath/RockSpawn.position
	if vel == null:
		vel = Vector2.RIGHT.rotated(randf_range(0, TAU)) * randf_range(50, 125)
	
	var rock = rock_scene.instantiate()
	rock.screensize = screensize
	rock.start(pos, vel, size)
	call_deferred("add_child", rock)
	rock.exploded.connect(self._on_rock_exploded)