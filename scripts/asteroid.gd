class_name Asteroid extends Area2D

signal exploded(position, size, points)

var movement_vector := Vector2(0, -1)
var speed := 50

enum AsteroidSize{LARGE, MEDIUM, SMALL}
@export var size := AsteroidSize.LARGE

@onready var sprite = $Sprite2D
@onready var collisionshape = $CollisionShape2D

var points: int:
	get: 
		match size:
			AsteroidSize.SMALL:
				return 100
			AsteroidSize.MEDIUM:
				return 50
			AsteroidSize.LARGE:
				return 25
			_:
				return 0

func _ready():
	rotation = randf_range(0, 2+PI)
	
	match size:
		AsteroidSize.LARGE:
			speed = randf_range(50, 100)
			sprite.texture = preload("res://assets/PNG/Meteors/meteorGrey_big1.png")
			collisionshape.set_deferred("shape", preload("res://resources/asteroid_collisionshape_large.tres"))
		AsteroidSize.MEDIUM:
			speed = randf_range(100, 150)
			sprite.texture = preload("res://assets/PNG/Meteors/meteorGrey_med1.png")
			collisionshape.set_deferred("shape", preload("res://resources/asteroid_collisionshape_medium.tres"))
		AsteroidSize.SMALL:
			speed = randf_range(100, 200)
			sprite.texture = preload("res://assets/PNG/Meteors/meteorGrey_small1.png")
			collisionshape.set_deferred("shape", preload("res://resources/asteroid_collisionshape_small.tres"))

func _physics_process(delta):
	global_position += movement_vector.rotated(rotation) * speed * delta
	
	var radius = collisionshape.shape.radius
	var screen_size = get_viewport_rect().size
	if global_position.y+radius < 0:
		global_position.y = screen_size.y+radius
	elif global_position.y-radius > screen_size.y:
		global_position.y = -radius
	
	if global_position.x+radius < 0:
		global_position.x = screen_size.x+radius
	elif global_position.x-radius > screen_size.x:
		global_position.x = -radius

func explode():
	emit_signal("exploded", global_position, size, points)
	queue_free()

func _on_body_entered(body):
	if body is Player:
		var player = body
		player.die()
