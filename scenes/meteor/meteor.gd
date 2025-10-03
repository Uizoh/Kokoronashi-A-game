extends CharacterBody2D

const speed = -380;
var y: int;
var vary: int;
var rng = RandomNumberGenerator.new()

func _ready():
	y = rng.randi_range(128, 628);
	vary = rng.randi_range(-40, 40);
	
	position = Vector2(1502, y);

func _process(dt: float):
	position += Vector2(speed * dt, vary * dt);
