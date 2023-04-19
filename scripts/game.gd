extends Node2D

@onready var lasers = $Lasers
@onready var player = $Player
@onready var asteroids = $Asteroids
@onready var hud = $UI/HUD
@onready var game_over_screen = $UI/GameOverScreen
@onready var leaderboard = $UI/GameOverScreen/Leaderboard
@onready var player_spawn_position = $PlayerSpawnPosition
@onready var player_spawn_area = $PlayerSpawnPosition/PlayerSpawnArea

var asteroid_scene = preload("res://scenes/asteroid.tscn")

var score := 0:
	set(value):
		score = value
		hud.score = score

var lives: int:
	set(value):
		lives = value
		hud._init_lives(lives)

func _ready():
	game_over_screen.visible = false
	score = 0
	lives = 3
	player.connect("laser_shot", _on_player_laser_shot)
	player.connect("died", _on_player_died)
	
	for asteroid in asteroids.get_children():
		asteroid.connect("exploded", _on_asteroid_exploded)
	
func _on_player_laser_shot(laser):
	lasers.add_child(laser)

func _on_asteroid_exploded(position, size, points):
	score += points
	for i in range(2):
		match size:
			Asteroid.AsteroidSize.LARGE:
				spawn_asteroid(position, Asteroid.AsteroidSize.MEDIUM)
			Asteroid.AsteroidSize.MEDIUM:
				spawn_asteroid(position, Asteroid.AsteroidSize.SMALL)
			Asteroid.AsteroidSize.SMALL:
				pass
	if (asteroids.get_child_count() < 8):
		spawn_asteroid(Vector2(199, 796), Asteroid.AsteroidSize.LARGE) #WORK IN PROGRESS
	
func spawn_asteroid(position, size):
	var a = asteroid_scene.instantiate()
	a.global_position = position
	a.size = size
	a.connect("exploded", _on_asteroid_exploded)
	asteroids.call_deferred("add_child", a)

func _on_player_died():
	lives -= 1
	player.global_position = player_spawn_position.global_position
	if lives <= 0:
		save_score(hud.score.text)
		leaderboard.set_text(str("Highscore: " + load_score()))
		await get_tree().create_timer(2).timeout
		game_over_screen.visible = true
	else:
		await get_tree().create_timer(1).timeout
		while !player_spawn_area.is_empty:
			await get_tree().create_timer(0.1).timeout
		player.respawn(player_spawn_position.global_position)

func save_score(content):
	content = content.trim_prefix("SCORE: ")
	var score_from_file = load_score()
	if (content.to_int() > score_from_file.to_int()):
		var file = FileAccess.open("user://save_game.dat", FileAccess.WRITE)
		file.store_string(content)

func load_score():
	var file = FileAccess.open("user://save_game.dat", FileAccess.READ)
	var content = file.get_as_text()
	return content
